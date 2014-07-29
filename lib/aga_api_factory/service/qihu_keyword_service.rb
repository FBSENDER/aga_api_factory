module AgaApiFactory
  module Service
    class KeywordService < BaseService
      def qihu_upload(keywords)
        keyword_service = Qihu::DianJing::Client.new(get_auth).keyword 
        keyword_infos = keywords.map{|keyword| {:word => keyword.keyword,:price => keyword.price,:url => keyword.url}}
        match_type = keywords[0].match_type
        match_type = "broad" if match_type == "wide"
        response = keyword_service.add(groupId: keywords[0].adgroup_se_id,keywords: JSON.generate({match_type => keyword_infos}))
        body = JSON.parse(response.body)
        if body.has_key?("keywordIdList")
          body["keywordIdList"].each_with_index do |id,index|
            keywords[index].se_id = id.to_i
          end
        end
        if body.has_key?("failures")
          failures = [body["failures"]].flatten
          failures.each do |failure|
            error_code = failure["code"]
            position = failure["description"].split(".").last.to_i
            case error_code
              when 60304 then keywords[position].status = 8 #已上传 未获得se_id
              when 60406 then keywords[position].status = 6 #超长
              when 60609 then keywords[position].status = 7 #触发了黑名单
              when 60606 then keywords[position].status = 5 #含非法字符
              when 80102 then self.token_is_error = true
            end 
          end
        end
        
        # keywords.each do |keyword|
        #   begin
        #     keyword_info = {
        #       :word => keyword.keyword,
        #       :price => keyword.price,
        #       :url => keyword.url
        #     }
        #     response = keyword_service.add(groupId: keyword.adgroup_se_id,keywords: JSON.generate({keyword.match_type => [keyword_info]}))
        #     keyword.se_id = JSON.parse(response.body)["keywordIdList"].first if JSON.parse(response.body)["keywordIdList"]
        #     p response unless JSON.parse(response.body)["keywordIdList"]
        #   rescue Exception => ex 
        #     p ex
        #     error_code = ex.to_s.scan(/\[.*?\]/).first
        #     case error_code
        #     when "[60304]" then keyword.status = 8 #已上传 未获得se_id
        #     when "[60406]" then keyword.status = 6 #超长
        #     when "[60609]" then keyword.status = 7 #触发了黑名单
        #     when "[80102]" then self.token_is_error = true
        #     end
        #     p keyword
        #     next
        #   end
        # end
      end

      def qihu_pause(keywords)
        keyword_service = Qihu::DianJing::Client.new(get_auth).keyword
        keywords.each do |keyword|
          response = keyword_service.update(:id => keyword.se_id,:status => "pause")
          begin
            raise "keyword pause error : " unless keyword.se_id == JSON.parse(response.body)["id"]
            keyword.status = 2
          rescue Exception => ex
            p ex
            p response
            keyword.status += 100
            next 
          end
        end
      end

      def qihu_enable(keywords)
        keyword_service = Qihu::DianJing::Client.new(get_auth).keyword
        keywords.each do |keyword|
          response = keyword_service.update(:id => keyword.se_id,:status => "enable")
          begin
            raise "keyword enable error : " unless keyword.se_id == JSON.parse(response.body)["id"]
            keyword.status = 1
          rescue Exception => ex
            p ex
            p response
            keyword.status += 100
            next 
          end
        end
      end

      def qihu_update(keywords)
        keyword_service = Qihu::DianJing::Client.new(get_auth).keyword
        keywords.each do |keyword|
          update_hash = Hash.new
          update_hash[:id] = keyword.se_id
          update_hash[:price] = keyword.price if keyword.price && keyword.price > 0
          update_hash[:url] = keyword.url if keyword.url && keyword.url.size > 0
          response = keyword_service.update(update_hash)
          begin
            raise "keyword update error : " unless keyword.se_id == JSON.parse(response.body)["id"]
            keyword.status = keyword.status % 10
          rescue Exception => ex
            p ex
            p response
            keyword.status += 100
            next 
          end
        end
      end

      def qihu_delete(keywords)
        keyword_service = Qihu::DianJing::Client.new(get_auth).keyword
        keywords.each do |keyword|
          response = keyword_service.deleteByIdList(:idList => JSON.generate([keyword.se_id]))
          begin
            raise "keyword delete error : " unless JSON.parse(response.body)["affectedRecords"] == 1
            keyword.status = 9
          rescue Exception => ex
            p ex
            p response
            keyword.status += 100
            next 
          end
        end
      end

      def qihu_repaire(keywords)
        api_keywords = Array.new
        keyword_service = Qihu::DianJing::Client.new(get_auth).keyword
        begin
          response = keyword_service.getIdListByGroupId(:groupId => keywords[0].adgroup_se_id)
          id_list = JSON.parse(response.body)["keywordIdList"]
          index = 0
          loop do
            break if index > id_list.size
            response = keyword_service.getInfoByIdList(idList: JSON.generate(id_list[index,100]))
            keyword_types= JSON.parse(response.body)["keywordList"]
            keyword_types.each do |keyword_type|
              keyword = AgaApiFactory::Model::Keyword.new
              keyword.keyword = keyword_type["word"] 
              keyword.se_id = keyword_type["id"].to_i
              keyword.adgroup_se_id = keyword_type["groupId"]
              keyword.price = keyword_type["price"].to_f
              keyword.match_type = keyword_type["matchType"]
              keyword.match_type = "wide" if keyword_type["matchType"] == "broad"
              keyword.url = keyword_type["destinationUrl"]
              keyword.status = case keyword_type["status"]
                                when "enable" then 1
                                when "pause" then 2
                                when "pending" then 3
                                when "reject" then 4  
                                else 0
                                end
              api_keywords << keyword
            end
            index += 100
          end
          keywords.each do |keyword|
            api_keyword = api_keywords.select{|item| item.keyword == keyword.keyword}.first
            next if api_keyword.nil?
            keyword.se_id = api_keyword.se_id 
            keyword.status = api_keyword.status
            keyword.price = api_keyword.price
          end
        rescue Exception => ex
          p ex 
        end
      end

      def qihu_get_id_list(adgroup_se_id)
        keyword_service = Qihu::DianJing::Client.new(get_auth).keyword
        response = keyword_service.getIdListByGroupId(groupId: adgroup_se_id)
        keyword_id_list = JSON.parse(response.body)["keywordIdList"]
        keyword_id_list #返回结果为Array
      end

      def qihu_get_status(keywords)
        keyword_service = Qihu::DianJing::Client.new(get_auth).keyword
        id_list = keywords.map{|item| item.se_id}
        index = 0
        loop do 
          break if index > id_list.size
          response = keyword_service.getStatusByIdList(idList: JSON.generate(id_list[index,100]))
          p response
          body = JSON.parse(response.body)
          if body.has_key?("failures")
            p body["failures"]
            return
          end
          return if !body.has_key?("keywordList") || body["keywordList"].size == 0
          keyword_list = body["keywordList"]
          keyword_list.each do |result|
            keyword = keywords.select{|item| item.se_id == result["id"]}.first
            keyword.status =
              case result["status"]
              when "enable" then 1
              when "pause" then 2
              when "pending" then 3
              when "reject" then 4
              else 0
              end
            keyword.quality_score = result["qualityScore"]
          end
          index += 100
        end
        p keywords
      end

      def qihu_get_info(keywords)
        keyword_service = Qihu::DianJing::Client.new(get_auth).keyword
        id_list = keywords.map{|item| item.se_id}
        response = keyword_service.getInfoByIdList(idList: JSON.generate(id_list))
        keyword_list = JSON.parse(response.body)["keywordList"]
        keywords.each do |keyword|
          keyword.status = 0 
          result = keyword_list.select{|item| item["id"] == keyword.se_id}
          next if result.size <= 0
          keyword.status =
            case result.first["status"]
            when "enable" then 1
            when "pause" then 2
            when "pending" then 3
            when "reject" then 4
            else 0
            end
          keyword.adgroup_se_id = result.first["groupId"]
          keyword.keyword = result.first["word"]
          keyword.price = result.first["price"].to_f
          keyword.match_type = result.first["matchType"]
          keyword.url = result.first["destinationUrl"]
        end
      end

      def qihu_get_all(adgroup_se_id)
        keywords = Array.new
        keyword_service = Qihu::DianJing::Client.new(get_auth).keyword
        response = keyword_service.getIdListByGroupId(groupId: adgroup_se_id)
        id_list = JSON.parse(response.body)["keywordIdList"]
        return keywords if id_list.nil? || id_list.size == 0
        id_index = 0
        loop do 
          break if id_index >= id_list.size
          response = keyword_service.getInfoByIdList(idList: JSON.generate(id_list[id_index,10]))
          keyword_types= JSON.parse(response.body)["keywordList"]
          keyword_types.each do |keyword_type|
            keyword = AgaApiFactory::Model::Keyword.new
            keyword.keyword = keyword_type["word"] 
            keyword.se_id = keyword_type["id"].to_i
            keyword.adgroup_se_id = keyword_type["groupId"]
            keyword.price = keyword_type["price"].to_f
            keyword.match_type = keyword_type["matchType"]
            keyword.match_type = "wide" if keyword_type["matchType"] == "broad"
            keyword.url = keyword_type["destinationUrl"]
            keyword.status = case keyword_type["status"]
                              when "enable" then 1
                              when "pause" then 2
                              when "pending" then 3
                              when "reject" then 4
                              else 0
                              end
            keywords << keyword
          end
          id_index += 10
        end
        keywords
      end

    end
  end
end
