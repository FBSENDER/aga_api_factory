module AgaApiFactory
  module Service
    class CreativeService < BaseService
      def qihu_upload(creatives)
        creative_service = Qihu::DianJing::Client.new(get_auth).creative
        creatives.each do |creative|
          begin
            response = creative_service.add(
              groupId: creative.adgroup_se_id,
              title: creative.title,
              description1: creative.description1,
              description2: "",
              destinationUrl: creative.destination_url,
              displayUrl: creative.display_url)
            body = JSON.parse(response.body)
            if body.has_key?("id")
              creative.se_id = body["id"]
            end
            if body.has_key?("failures")
              p body["failures"]
              failures = [body["failures"]].flatten
              failures.each do |failure|
                error_code = failure["code"]
                case error_code
                  when 50402 then creative.status = 6 #超长
                  when 50403 then creative.status = 6 #超长
                  when 50607 #包含商标
                    creative.status = 7 
                    creative.trademark = failure["message"]
                  when 50608 #包含竞品词
                    creative.status = 7 
                    creative.competing_word = failure["message"]
                  when 50609 #包含黑名单
                    creative.status = 7 
                    creative.black_word = failure["message"]
                  when 50606 then creative.status = 8 #包含非法字符
                  when 50406 then creative.status = 10 #单元内创意过多，由于上传时获取上传结果超市，重复上传导致
                end 
              end
            end
          rescue Exception => ex 
            puts ex.to_s
          end
        end
      end

      def sogou_upload(creatives)
        creative_service = Sogou::SEM::CreativeService.new(get_auth)
        creatives.each do |creative|
          creative_type = {
                  :cpcGrpId => creative.adgroup_se_id,
                  :title => creative.title,
                  :description1 => creative.description1,
                  :description2 => creative.description2,
                  :visitUrl => creative.destination_url,
                  :showUrl=> creative.display_url
                }
          begin
            response = creative_service.addCpcIdea({:cpcIdeaTypes => [creative_type]})
            creative.se_id = response.body[:cpc_idea_types][:cpc_idea_id]
            creative.se_status = response.body[:cpc_idea_types][:status]
          rescue Exception => ex
            p ex
            next
          end
        end
      end

      def baidu_upload(creatives)
        creative_service =  Baidu::SEM::CreativeService.new(get_auth)
        creativeTypes = []
        creatives.each do |creative|
          creativeTypes << {
            :adgroupId => creative.adgroup_se_id,
            :title => creative.title,
            :description1 => creative.description1,
            :description2 => creative.description2,
            :pcDestinationUrl => creative.destination_url,
            :pcDisplayUrl => creative.display_url,
            :mobileDestinationUrl => creative.destination_url,
            :mobileDisplayUrl => creative.display_url
          }
        end
        options = {:creativeTypes => creativeTypes}
        begin
          response = creative_service.addCreative(options)
          p response
          baidu_creative_update(creatives,response)
        rescue Exception => ex 
          puts ex.to_s
        end
      end

      def baidu_creative_update(creatives,response)
        creativeTypes = [response.body[:creative_types]].flatten
        failures = [response.header[:failures]].flatten
        creativeTypes.each_with_index do |creative_type,index|
            creatives[index].se_id = creative_type[:creative_id].to_i
            creatives[index].se_status = creative_type[:status].to_i
            creatives[index].status = case creative_type[:status].to_i
                      when 51 then 1
                      when 52 then 2
                      else 0
                      end
        end
        failures.each do |failure|
          error_code = failure[:code].to_i
          position = failure[:position].scan(/\[\d*\]/).first.delete("[]").to_i
          case error_code
          when 901833 then creatives[position].status = 6 #超长
          when 901843 then creatives[position].status = 6 #超长
          when 901851 then creatives[position].status = 6 #超长
          when 901836 #包含商标
            creatives[position].status = 7 
            creatives[position].trademark = failure[:content]
          when 901839 #包含商标
            creatives[position].status = 7 
            creatives[position].trademark = failure[:content]
          when 901846 #包含商标
            creatives[position].status = 7 
            creatives[position].trademark = failure[:content]
          when 901849 #包含商标
            creatives[position].status = 7 
            creatives[position].trademark = failure[:content]
          when 901854 #包含商标
            creatives[position].status = 7 
            creatives[position].trademark = failure[:content]
          when 901857 #包含商标
            creatives[position].status = 7 
            creatives[position].trademark = failure[:content]
          when 901893 #包含商标
            creatives[position].status = 7 
            creatives[position].trademark = failure[:content]
          when 901882 #包含竞品词
            creatives[position].status = 7 
            creatives[position].competing_word = failure[:content]
          when 901883 #包含竞品词
            creatives[position].status = 7 
            creatives[position].competing_word = failure[:content]
          when 901884 #包含竞品词
            creatives[position].status = 7 
            creatives[position].competing_word = failure[:content]
          when 901886 #包含竞品词
            creatives[position].status = 7 
            creatives[position].competing_word = failure[:content]
          when 901887 #包含竞品词
            creatives[position].status = 7 
            creatives[position].competing_word = failure[:content]
          when 901888 #包含竞品词
            creatives[position].status = 7 
            creatives[position].competing_word = failure[:content]
          when 901894 #包含竞品词
            creatives[position].status = 7 
            creatives[position].competing_word = failure[:content]
          when 901835 #包含黑名单
            creatives[position].status = 7 
            creatives[position].black_word = failure[:content]
          when 901838 #包含黑名单
            creatives[position].status = 7 
            creatives[position].black_word = failure[:content]
          when 901845 #包含黑名单
            creatives[position].status = 7 
            creatives[position].black_word = failure[:content]
          when 901848 #包含黑名单
            creatives[position].status = 7 
            creatives[position].black_word = failure[:content]
          when 901953 #包含黑名单
            creatives[position].status = 7 
            creatives[position].black_word = failure[:content]
          when 901856 #包含黑名单
            creatives[position].status = 7 
            creatives[position].black_word = failure[:content]
          when 901892 #包含黑名单
            creatives[position].status = 7 
            creatives[position].black_word = failure[:content]
          when 901853 #包含黑名单
            creatives[position].status = 7 
            creatives[position].black_word = failure[:content]
          when 901834 then creatives[position].status = 8 #包含非法字符
          when 901837 then creatives[position].status = 8 #包含非法字符
          when 901844 then creatives[position].status = 8 #包含非法字符
          when 901847 then creatives[position].status = 8 #包含非法字符
          when 901852 then creatives[position].status = 8 #包含非法字符
          when 901855 then creatives[position].status = 8 #包含非法字符
          end 
        end
      end

      def qihu_delete(creatives)
        creative_service = Qihu::DianJing::Client.new(get_auth).creative
        id_list = creatives.map{|item| item.se_id}
        response = creative_service.deleteByIdList(:idList => JSON.generate(id_list))
        if JSON.parse(response.body)["affectedRecords"].to_i > 0
          creatives.each{|item| item.status = 9 }
        end
      end

      def baidu_delete(creatives)
        creative_service =  Baidu::SEM::CreativeService.new(get_auth)
        creative_ids = creatives.map{|item| item.se_id}
        begin
          response = creative_service.deleteCreative(:creativeIds => creative_ids)
          p response
          success_count = response.body[:result].to_i
          fail_count = 0
          unless response.header[:failures].nil?
            fail_count = response.header[:failures].select{|item| item[:code] == '90114'}.count
          end
          if success_count + fail_count == creatives.size
            creatives.each{|item| item.status = 9}
          end
        rescue Exception => ex 
          puts ex.to_s
        end
      end

      def qihu_repaire(creatives)
        api_creatives = Array.new
        creative_service = Qihu::DianJing::Client.new(get_auth).creative
        begin
          response = creative_service.getIdListByGroupId(:groupId => creatives[0].adgroup_se_id)
          id_list = JSON.parse(response.body)["creativeIdList"]
          index = 0
          loop do
            break if index > id_list.size
            response = creative_service.getInfoByIdList(idList: JSON.generate(id_list[index,100]))
            creative_types= JSON.parse(response.body)["creativeList"]
            creative_types.each do |creative_type|
              creative = AgaApiFactory::Model::Creative.new
              creative.se_id = creative_type["id"].to_i
              creative.title = creative_type["title"]
              creative.description1 = creative_type["description1"]
              creative.description2 = creative_type["description2"]
              creative.destination_url = creative_type["destinationUrl"]
              creative.display_url = creative_type["displayUrl"]
              creative.status = case creative_type["status"]
                                when "enable" then 1
                                when "pause" then 2
                                when "pending" then 3
                                when "reject" then 4
                                else 0
                                end
              api_creatives << creative
            end
            index += 100
          end
          creatives.each do |creative|
            api_creative = api_creatives.select{|item| item.title == creative.title && item.description1 == creative.description1 }.first
            next if api_creative.nil?
            creative.se_id = api_creative.se_id 
            creative.status = api_creative.status
          end
        rescue Exception => ex
          p ex 
        end
      end

      def qihu_get_all(adgroup_se_id)
        api_creatives = Array.new
        creative_service = Qihu::DianJing::Client.new(get_auth).creative
        begin
          response = creative_service.getIdListByGroupId(:groupId => adgroup_se_id)     
          body = JSON.parse(response.body)
          id_list = body["creativeIdList"]
          if body.has_key?("failures")
            raise body["failures"]
          end
          return api_creatives if id_list.nil? || id_list.size == 0
          index = 0
          loop do
            break if index > id_list.size
            response = creative_service.getInfoByIdList(idList: JSON.generate(id_list[index,100]))
            body = JSON.parse(response.body)
            if body.has_key?("failures")
              raise body["failures"]
            end
            creative_types= body["creativeList"]
            next if creative_types.nil?
            creative_types.each do |creative_type|
              creative = AgaApiFactory::Model::Creative.new
              creative.se_id = creative_type["id"].to_i
              creative.title = creative_type["title"]
              creative.description1 = creative_type["description1"]
              creative.description2 = creative_type["description2"]
              creative.destination_url = creative_type["destinationUrl"]
              creative.display_url = creative_type["displayUrl"]
              creative.status = case creative_type["status"]
                                when "enable" then 1
                                when "pause" then 2
                                when "pending" then 3
                                when "reject" then 4
                                else 0
                                end
              api_creatives << creative
            end
            index += 100
          end
          api_creatives
        rescue Exception => ex
          p ex 
        end
      end

      def baidu_get_all(adgroup_se_ids)
        creatives = Array.new
        creative_service = Baidu::SEM::CreativeService.new(get_auth)
        response = creative_service.getCreativeByAdgroupId(:adgroupIds => adgroup_se_ids)
        if response.desc != "success"
          raise "api error"
        end
        return creatives if response.body[:group_creatives].nil? || response.body[:group_creatives][:creative_types].nil?
        creative_types = [response.body[:group_creatives][:creative_types]].flatten
        creative_types.each do |creative_type|
          creative = AgaApiFactory::Model::Creative.new
          creative = AgaApiFactory::Model::Creative.new
          creative.se_id = creative_type[:creative_id].to_i
          creative.title = creative_type[:title]
          creative.description1 = creative_type[:description1]
          creative.description2 = creative_type[:description2]
          creative.destination_url = creative_type[:pc_destination_url]
          creative.display_url = creative_type[:pc_display_url]
          creative.status = case creative_type[:status].to_i
                            when 51 then 1
                            when 52 then 2
                            when 56 then 1
                            else 0
                            end
          creatives << creative
        end
        creatives
      end

    end
  end
end
