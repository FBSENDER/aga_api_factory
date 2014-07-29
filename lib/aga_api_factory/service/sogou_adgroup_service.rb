module AgaApiFactory
  module Service
    class AdgroupService < BaseService

      def sogou_upload(adgroups)
        group_service = Sogou::SEM::AdgroupService.new(get_auth)
        adgroups.each do |adgroup|
          adgroupType_add = {:cpcPlanId => adgroup.campaign_se_id,:cpcGrpName => adgroup.adgroup_name,:maxPrice => adgroup.price}
          begin
            response = group_service.addCpcGrp({:cpcGrpTypes => [adgroupType_add]})
            adgroup.se_id = response.body[:cpc_grp_types][:cpc_grp_id]
            adgroup.se_status = response.body[:cpc_grp_types][:status]
          rescue Exception => ex
            p ex
            next
          end
        end
      end

      def sogou_get_info(adgroups)
        group_service = Sogou::SEM::AdgroupService.new(get_auth)
        adgroups.each do |adgroup|
          begin
            response = group_service.getCpcGrpByCpcGrpId(:cpcGrpIds => [adgroup.se_id])
            adgroup_types = response.body[:cpc_grp_types]
            adgroup.adgroup_name = adgroup_types[:cpc_grp_name]
            adgroup.price = adgroup_types[:max_price].to_f
            adgroup.status = case adgroup_types[:status].to_i
                      when 21 then 1
                      when 22 then 2
                      when 23 then adgroup.status
                      else 0
                      end   
          rescue Exception => ex 
            puts ex.to_s
            next
          end
        end
      end
      def sogou_repaire(adgroups)
        group_service = Sogou::SEM::AdgroupService.new(get_auth)
        adgroups.each do |adgroup|
          next if adgroup.se_id && adgroup.se_id > 0
          next if adgroup.campaign_se_id.nil? || adgroup.campaign_se_id <= 0
          response = group_service.getCpcGrpByCpcPlanId(:cpcPlanIds => [adgroup.campaign_se_id])
          response.body[:cpc_plan_grps][:cpc_grp_types].each do |grp|
            next if adgroup.adgroup_name != grp[:cpc_grp_name]
            adgroup.se_id = grp[:cpc_grp_id].to_i
            adgroup.price = grp[:max_price].to_f
            adgroup.status = case grp[:status].to_i
                    when 21 then 1
                    when 22 then 2
                    when 23 then adgroup.status
                    else 0
                    end
          end
        end
      end
      def sogou_pause(adgroups) 
        group_service = Sogou::SEM::AdgroupService.new(get_auth)
        adgroups.each do |adgroup|
          response = group_service.updateCpcGrp({:cpcGrpTypes => [{:cpcGrpId => adgroup.se_id,:pause => true}]})
          adgroup.status = 2 if response.body[:cpc_grp_types][:pause]
        end
      end
    end
  end
end
