module AgaApiFactory
  module Service
    class KeywordService < BaseService
      def baidu_get_service
        10.times do |i| 
          begin
            #service 实例化时会savon调取api信息 有网络请求 于是可能失败
            keyword_service = Baidu::SEM::KeywordService.new(get_auth)
            return keyword_service
          rescue Exception => ex
            sleep i * 0.5
            next
          end
        end
        raise "初始化 baidu keyword service 超时"
      end

      def baidu_upload(keywords)
        keyword_service = baidu_get_service 
        options = {:keywordTypes => keywords.map{|keyword| {
                                      :adgroupId => keyword.adgroup_se_id,
                                      :keyword => keyword.keyword,
                                      :price => keyword.price,
                                      :pcDestinationUrl => keyword.url,
                                      :mobileDestinationUrl => keyword.url,
                                      :matchType => keyword.baidu_match_type_enum
                                    }}
                  }
        begin
          response = keyword_service.addKeyword(options)
          baidu_keyword_update(keywords,response)
        rescue Exception => ex
          #这里报错通常是api超时 稍等一下再访问即可 实际数据已上传成功
          #数据库与百度后台数据不一致，需后续修复
          #puts ex.to_s
          sleep 2
        end
      end

      def baidu_keyword_update(keywords,response)
        keyword_types = [response.body[:keyword_types]].flatten if !response.body.nil? && response.body.has_key?(:keyword_types)
        failures = [response.header[:failures]].flatten if !response.header.nil? && response.header.has_key?(:failures)
        if keyword_types
          keyword_types.each_with_index do |k,index|
            keywords[index].se_id = k[:keyword_id].to_i
            keywords[index].status = transfer_keyword_status(k[:status].to_i)
          end
        end
        if failures
          p failures
          failures.each do |failure|
            error_code = failure[:code].to_i
            position = failure[:position].scan(/\[\d*\]/).first.delete("[]").to_i
            case error_code
              when 901635 then keywords[position].status = 8 #已上传 未获得se_id
              when 901634 then keywords[position].status = 6 #超长
              when 901638 then keywords[position].status = 7 #触发了黑名单
              when 901639 then keywords[position].status = 7 #包含别人的注册商标
              when 901640 then keywords[position].status = 7 #包含触犯他人权益的词
              when 901637 then keywords[position].status = 5 #含非法字符
            end
          end
        end
      end

      def baidu_update(keywords)
        keyword_service = baidu_get_service
        options = []
        keywords.each do |keyword|
          update_hash = Hash.new
          update_hash[:keywordId] = keyword.se_id
          update_hash[:price] = keyword.price if keyword.price && keyword.price > 0
          update_hash[:pcDestinationUrl] = keyword.url if keyword.url && keyword.url.size > 0
          update_hash[:mobileDestinationUrl] = keyword.url if keyword.url && keyword.url.size > 0
          options << update_hash
        end
        response = keyword_service.updateKeyword(:keywordTypes => options) 
        if response.body && response.body.has_key?(:keyword_types) 
          keywordtypes = [response.body[:keyword_types]].flatten
          keywordtypes.each do |keyword_type|
            keyword = keywords.select{|item| item.se_id == keyword_type[:keyword_id].to_i}.first
            keyword.status = transfer_keyword_status(keyword_type[:status].to_i)
          end
        end
        if response.header && response.header.has_key?(:failures)
          failures = [response.header[:failures]].flatten
          failures.each do |failure|
            position = failure[:position].scan(/\[\d*\]/).first.delete("[]").to_i
            keywords[position].status += 100 
          end
        end
      end

      def baidu_pause(keywords)
        keyword_service = baidu_get_service
        options = []
        keywords.each do |keyword|
          update_hash = Hash.new
          update_hash[:keywordId] = keyword.se_id
          update_hash[:pause] = true
          options << update_hash
        end
        response = keyword_service.updateKeyword(:keywordTypes => options) 
        p response
        if response.header[:desc] == "failure"
          keywords.each{|keyword| keyword.status += 100}
          return
        end
        if response.body.has_key?(:keyword_types) 
          keywordtypes = [response.body[:keyword_types]].flatten
          keywordtypes.each do |keyword_type|
            keyword = keywords.select{|item| item.se_id == keyword_type[:keyword_id].to_i}.first
            keyword.status = transfer_keyword_status(keyword_type[:status].to_i)
          end
        end
        if response.header.has_key?(:failures)
          failures = [response.header[:failures]].flatten
          failures.each do |failure|
            position = failure[:position].scan(/\[\d*\]/).first.delete("[]").to_i
            keywords[position].status += 100 
          end
        end
      end

      def baidu_enable(keywords)
        keyword_service = baidu_get_service
        keywords.each do |keyword|
          begin
            response = keyword_service.updateKeyword(:keywordTypes =>[{:keywordId => keyword.se_id,:pause => false}])
            raise "keyword enable error : " unless keyword.se_id == response.body[:keyword_types][:keyword_id].to_i
            keyword.status = 1
          rescue Exception => ex 
            p ex
            p response
            keyword.status += 100
            next 
          end
        end
      end

      def baidu_get_all(adgroup_se_ids)
        keywords = Array.new
        keyword_service = baidu_get_service
        response = keyword_service.getKeywordByAdgroupId(:adgroupIds => adgroup_se_ids)
        if response.desc != "success"
          p response
          raise "api error"
        end
        return keywords if response.body[:group_keywords].nil? || response.body[:group_keywords][:keyword_types].nil?
        keyword_types = [response.body[:group_keywords][:keyword_types]]
        keyword_types.flatten.each do |keyword_type|
          keyword = AgaApiFactory::Model::Keyword.new
          keyword.se_id = keyword_type[:keyword_id].to_i
          keyword.keyword = keyword_type[:keyword]
          keyword.price = keyword_type[:price].to_f
          keyword.url = keyword_type[:pc_destination_url] || keyword_type[:mobile_destination_url]
          keyword.match_type = case keyword_type[:match_type].to_i
                               when 1 then "exact"
                               when 2 then "phrase"
                               when 3 then "wide"
                               end
          keyword.se_status = keyword_type[:status].to_i
          keyword.status = transfer_keyword_status(keyword_type[:status].to_i)
          keywords << keyword
        end
        keywords
      end

      def baidu_repaire(keywords)
        api_keywords = Array.new
        keyword_service = baidu_get_service
        begin
          response = keyword_service.getKeywordByAdgroupId(:adgroupIds => [keywords[0].adgroup_se_id])
          p response
          return if response.body[:group_keywords].nil? || response.body[:group_keywords][:keyword_types].nil?
          keyword_types = [response.body[:group_keywords][:keyword_types]].flatten
          keyword_types.each do |keyword_type|
            keyword = AgaApiFactory::Model::Keyword.new
            keyword.se_id = keyword_type[:keyword_id].to_i
            keyword.keyword = keyword_type[:keyword]
            keyword.price = keyword_type[:price].to_f
            keyword.url = keyword_type[:pc_destination_url] || keyword_type[:mobile_destination_url]
            keyword.match_type = case keyword_type[:match_type].to_i
                                 when 1 then "exact"
                                 when 2 then "phrase"
                                 when 3 then "wide"
                                 end
            keyword.se_status = keyword_type[:status].to_i
            keyword.status = transfer_keyword_status(keyword_type[:status].to_i)
            api_keywords << keyword
          end
          keywords.each do |keyword|
            #简体与繁体转换 半角与全角转换
            api_keyword = api_keywords.select{|item| item.keyword == keyword.keyword || ZhConv.convert("zh-cn", keyword.keyword) == item.keyword || item.keyword == keyword.keyword.gsub(/[＋－]/,'＋' => '+','－' => '-') }.first
            next if api_keyword.nil?
            keyword.se_id = api_keyword.se_id 
            keyword.status = api_keyword.status
            keyword.price = api_keyword.price
          end
        rescue Exception => ex
          p ex
        end
      end

      def baidu_get_info(keywords)
        keyword_service = baidu_get_service
        keywords.each do |keyword|
          response = keyword_service.getKeywordByKeywordId(keywordIds: [keyword.se_id])
          keyword_type = response.body[:keyword_types]
          keyword.price = keyword_type[:price].to_f
          keyword.url = keyword_type[:pc_destination_url] || keyword_type[:mobile_destination_url] || ""
          keyword.status = transfer_keyword_status(keyword_type[:status].to_i)
        end
      end
    
      def baidu_get_status(keywords)
        keyword_service = baidu_get_service
        response = keyword_service.getKeyword10Quality(:ids => keywords.map{|item| item.se_id},:type => 11,:device => 2,:hasScale => false)
        quality_types = [response.body[:keyword10_quality]].flatten
        quality_types.each_with_index do |quality_type,index|
          keywords[index].quality_score = [quality_type[:pc_quality].to_i,quality_type[:mobile_quality].to_i].max
        end
      end

      def transfer_keyword_status(se_status)
        status = case se_status
                 when 41 then 1 #有效
                 when 42 then 2 #暂停推广
                 when 47 then 1 #搜索量过低
                 when 48 then 1 #部分无效
                 when 49 then 1 #计算机搜索无效
                 when 50 then 1 #移动搜索无效
                 when 43 then 4 #不宜推广
                 when 44 then 4 #搜索无效
                 when 45 then 4 #待激活
                 when 46 then 4 #审核中
                 else 0
                 end
        status 
      end

      def baidu_delete(keywords)
        keyword_service = baidu_get_service
        response = keyword_service.deleteKeyword(:keywordIds => keywords.map{|item| item.se_id})
        if response.body[:result].to_i == 1
          keywords.each do |keyword|
            keyword.status = 9
          end
        end
      end
    end
  end
end
