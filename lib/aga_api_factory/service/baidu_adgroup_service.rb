module AgaApiFactory
  module Service
    class AdgroupService < BaseService
      def baidu_upload(adgroups)
        group_service = Baidu::SEM::AdgroupService.new(get_auth)
        adgroups.each do |adgroup|
          begin
            adgroup_type = {
              :adgroupName => adgroup.adgroup_name,
              :campaignId => adgroup.campaign_se_id,
              :maxPrice => adgroup.price
            }
            response = group_service.addAdgroup({:adgroupTypes => [adgroup_type]})
            p response
            result = response.body[:adgroup_types]
            adgroup.se_id = result[:adgroup_id].to_i
            adgroup.status = case result[:status].to_i
                      when 31 then 1
                      when 32 then 2
                      else 0
                      end
          rescue Exception => ex 
            puts ex 
            next
          end
        end
      end

      def baidu_get_info(adgroups)
        group_service = Baidu::SEM::AdgroupService.new(get_auth)
        adgroups.each do |adgroup|
          p adgroup
          response = group_service.getAdgroupByAdgroupId(:adgroupIds => [adgroup.se_id])
          adgroup_type = response.body[:adgroup_types]
          next if adgroup_type.nil?
          adgroup.adgroup_name = adgroup_type[:adgroup_name]
          adgroup.price = adgroup_type[:max_price].to_f
          adgroup.status = case adgroup_type[:status].to_i
                    when 31 then 1
                    when 32 then 2
                    else 0
                    end
          adgroup.se_status = adgroup_type[:status].to_i
        end
      end

      def baidu_repaire(adgroups)
        group_service = Baidu::SEM::AdgroupService.new(get_auth)
        return if adgroups.size == 0
        response = group_service.getAdgroupIdByCampaignId(campaignIds: [adgroups.first.campaign_se_id])
        id_list = response.body[:campaign_adgroup_ids][:adgroup_ids]
        id_list.each do |id|
          begin
            response = group_service.getAdgroupByAdgroupId(adgroupIds: [id])
            group_info = response.body[:adgroup_types]
            adgroup = adgroups.select{|item| item.adgroup_name == group_info[:adgroup_name]}.first
            next if adgroup.nil?
            adgroup.se_id = id
            adgroup.status = case group_info[:status]
                      when 31 then 1
                      when 32 then 2
                      else 0
                      end
            p adgroup
          rescue Exception => ex
            puts ex.to_s
            next
          end
        end
      end

      def baidu_get_all(campaign_se_ids)
        adgroups = Array.new
        group_service = Baidu::SEM::AdgroupService.new(get_auth)
        response = group_service.getAdgroupByCampaignId(campaignIds: campaign_se_ids)
        return adgroups if response.body[:campaign_adgroups].nil? || response.body[:campaign_adgroups][:adgroup_types].nil?
        adgroup_types = response.body[:campaign_adgroups][:adgroup_types]
        if adgroup_types.class == Array
          adgroup_types.each do |adgroup_type|
            adgroup = AgaApiFactory::Model::Adgroup.new
            adgroup.se_id = adgroup_type[:adgroup_id].to_i
            adgroup.adgroup_name = adgroup_type[:adgroup_name]
            adgroup.price = adgroup_type[:max_price].to_f
            adgroup.se_status = adgroup_type[:status].to_i
            adgroup.status = case adgroup_type[:status].to_i
                        when 31 then 1
                        when 32 then 2
                        else 0
                        end
            adgroups << adgroup
          end
        else
          adgroup = AgaApiFactory::Model::Adgroup.new
          adgroup.se_id = adgroup_types[:adgroup_id].to_i
          adgroup.adgroup_name = adgroup_types[:adgroup_name]
          adgroup.price = adgroup_types[:max_price].to_f
          adgroup.se_status = adgroup_types[:status].to_i
          adgroup.status = case adgroup_types[:status].to_i
                      when 31 then 1
                      when 32 then 2
                      else 0
                      end
          adgroups << adgroup
        end
        adgroups
      end

      def baidu_update(adgroups)
        group_service = Baidu::SEM::AdgroupService.new(get_auth) 
        page = 0 
        loop do 
          begin
            break if adgroups.size <= page * 100
            response = group_service.updateAdgroup(:adgroupTypes => adgroups[page * 100,100].map{|item| {:adgroupId => item.se_id,:negativeWords => item.negative_words}})
            [response.body[:adgroup_types]].flatten.each_with_index do |adgroup_type,index|
              if adgroup_type[:adgroup_id].to_i == adgroups[page * 100 + index].se_id
                adgroups[page * 100 + index].status = adgroups[page * 100 + index].status % 10
              else
                adgroups[page * 100 + index].status += 100
              end
            end
            page += 1
          rescue Exception => ex 
            puts ex 
            next
          end
        end
      end
      def baidu_pause(adgroups)
        group_service = Baidu::SEM::AdgroupService.new(get_auth) 
        page = 0 
        loop do 
          begin
            break if adgroups.size <= page * 100
            response = group_service.updateAdgroup(:adgroupTypes => adgroups[page * 100,100].map{|item| {:adgroupId => item.se_id,:pause => true}})
            [response.body[:adgroup_types]].flatten.each_with_index do |adgroup_type,index|
              if adgroup_type[:adgroup_id].to_i == adgroups[page * 100 + index].se_id
                adgroups[page * 100 + index].status = 2 
              else
                adgroups[page * 100 + index].status += 100
              end
            end
            page += 1
          rescue Exception => ex 
            puts ex 
            next
          end
        end
      end
      def baidu_enable(adgroups)
        group_service = Baidu::SEM::AdgroupService.new(get_auth) 
        page = 0 
        loop do 
          begin
            break if adgroups.size <= page * 100
            response = group_service.updateAdgroup(:adgroupTypes => adgroups[page * 100,100].map{|item| {:adgroupId => item.se_id,:pause => false}})
            [response.body[:adgroup_types]].flatten.each_with_index do |adgroup_type,index|
              if adgroup_type[:adgroup_id].to_i == adgroups[page * 100 + index].se_id
                adgroups[page * 100 + index].status = 1   
              else
                adgroups[page * 100 + index].status += 100
              end
            end
            page += 1
          rescue Exception => ex 
            puts ex 
            next
          end
        end
      end
    end
  end
end
