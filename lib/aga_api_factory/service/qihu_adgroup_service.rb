module AgaApiFactory
  module Service
    class AdgroupService < BaseService

      def qihu_upload(adgroups)
        group_service = Qihu::DianJing::Client.new(get_auth).group 
        adgroups.each do |adgroup|
          begin
            negative_words_json = JSON.generate(:phrase => adgroup.negative_words,:exact => adgroup.exact_negative_words)
            response = group_service.add(campaignId: adgroup.campaign_se_id,name: adgroup.adgroup_name,price: adgroup.price,negativeWords: negative_words_json)
            body = JSON.parse(response.body)
            adgroup.se_id = body["id"]
            sleep 0.1
            if body.has_key?("failures")
              p body["failures"]
            end
          rescue Exception => ex 
            puts ex 
            p adgroup
            p response
            next
          end
        end
      end

      def qihu_get_info(adgroups)
        group_service = Qihu::DianJing::Client.new(get_auth).group
        adgroups.each do |adgroup|
          response = group_service.getInfoById(id: adgroup.se_id)
          group_info = JSON.parse(response.body)
          adgroup.price = group_info["price"].to_f
          adgroup.adgroup_name = group_info["name"]
          adgroup.campaign_se_id = group_info["campaignId"].to_i
          adgroup.negative_words = group_info["negativeWords"]
          adgroup.exact_negative_words = group_info["exactNegativeWords"]
          p group_info["status"]
          adgroup.status = case group_info["status"]
                    when "enable" then 1
                    when "pause" then 2
                    else 0
                    end
          adgroup.se_status = adgroup.status
        end
      end

      def qihu_update(adgroups)
        group_service = Qihu::DianJing::Client.new(get_auth).group
        adgroups.each do |adgroup|
          # negative_words_json = JSON.generate(:phrase => adgroup.negative_words,:exact => adgroup.exact_negative_words)
          negative_words_json = JSON.generate(:phrase => adgroup.negative_words,:exact => adgroup.exact_negative_words)
          response = group_service.update(id: adgroup.se_id,name: adgroup.adgroup_name,price: adgroup.price,negativeWords: negative_words_json)
          p response.body
          begin
            raise "adgroup update error : " unless adgroup.se_id == JSON.parse(response.body)["id"].to_i
            adgroup.status = adgroup.status % 10
          rescue Exception => ex
            p ex
            p response
            # adgroup.status += 100
            next 
          end
        end
      end

      def qihu_pause(adgroups)
        group_service = Qihu::DianJing::Client.new(get_auth).group
        adgroups.each do |adgroup|
          response = group_service.update(id: adgroup.se_id,status: "pause")
          begin
            raise "adgroup pause error : " unless adgroup.se_id == JSON.parse(response.body)["id"].to_i
            adgroup.status = 2
          rescue Exception => ex
            p ex
            p response
            adgroup.status += 100
            next 
          end
        end
      end

      def qihu_enable(adgroups)
        group_service = Qihu::DianJing::Client.new(get_auth).group
        adgroups.each do |adgroup|
          response = group_service.update(id: adgroup.se_id,status: "enable")
          begin
            raise "adgroup enable error : " unless adgroup.se_id == JSON.parse(response.body)["id"].to_i
            adgroup.status = 1
          rescue Exception => ex
            p ex
            p response
            adgroup.status += 100
            next 
          end
        end
      end

      def qihu_delete(adgroups)
        group_service = Qihu::DianJing::Client.new(get_auth).group
        adgroups.each do |adgroup|
          response = group_service.deleteById(id: adgroup.se_id)
          begin
            raise "adgroup delete error : " unless JSON.parse(response.body)["affectedRecords"].to_i > 0
            adgroup.status = 9
          rescue Exception => ex
            p ex
            p response
            adgroup.status += 100
            next 
          end
        end
      end

      def qihu_repaire(adgroups)
        group_service = Qihu::DianJing::Client.new(get_auth).group
        adgroups.each do |adgroup|
          begin
            response = group_service.getIdListByCampaignId(campaignId: adgroup.campaign_se_id)
            id_list = JSON.parse(response.body)["groupIdList"]
            id_list.each do |id|
              response = group_service.getInfoById(id: id)
              group_info = JSON.parse(response.body)
              next if adgroup.adgroup_name != group_info["name"]
              adgroup.se_id = id
              adgroup.price = group_info["price"].to_f
              adgroup.negative_words = group_info["negativeWords"]
              adgroup.exact_negative_words = group_info["exactNegativeWords"]
              adgroup.status = case group_info["status"]
                        when "enable" then 1
                        when "pause" then 2
                        else 0
                        end
              break
            end
          rescue Exception => ex 
            p ex
          end
        end
      end
      
      # def qihu_get_all(campaign_se_id)
      #   adgroups = Array.new
      #   group_service = Qihu::DianJing::Client.new(get_auth).group
      #   response = group_service.getIdListByCampaignId(campaignId: campaign_se_id)
      #   id_list = JSON.parse(response.body)["groupIdList"]
      #   index = 0 
      #   loop do 
      #     break if index > id_list.size
      #     response = group_service.getInfoByIdList(idList: JSON.generate(id_list[index,50]))
      #     adgroup_types = JSON.parse(response.body)["groupList"]
      #     adgroup_types.each do |adgroup_type|
      #       adgroup = AgaApiFactory::Model::Adgroup.new
      #       adgroup.se_id = adgroup_type["id"].to_i
      #       adgroup.adgroup_name = adgroup_type["name"]
      #       adgroup.price = adgroup_type["price"].to_f
      #       adgroup.negative_words = adgroup_type["negativeWords"]
      #       adgroup.exact_negative_words = adgroup_type["exactNegativeWords"]
      #       adgroup.status = case adgroup_type["status"]
      #                         when "enable" then 1
      #                         when "pause" then 2
      #                         else 0
      #                       end
      #       adgroup.se_status = adgroup.status
      #       adgroups << adgroup
      #     end
      #     index += 50
      #   end
      #   adgroups
      # end

      def qihu_get_all(campaign_se_id)
        adgroups = Array.new
        group_service = Qihu::DianJing::Client.new(get_auth).group
        response = group_service.getIdListByCampaignId(campaignId: campaign_se_id)
        id_list = JSON.parse(response.body)["groupIdList"]
        id_list.each do |id|
          adgroup = AgaApiFactory::Model::Adgroup.new
          adgroup.se_id = id.to_i
          adgroup.adgroup_name = id 
          adgroup.price = 0
          adgroup.negative_words = ""
          adgroup.exact_negative_words = ""
          adgroup.status = 0
          adgroup.se_status = adgroup.status
          adgroups << adgroup
        end
        adgroups
      end

    end
  end
end
