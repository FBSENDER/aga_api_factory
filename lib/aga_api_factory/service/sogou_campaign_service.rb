module AgaApiFactory
	module Service
		class CampaignService < BaseService

			def sogou_upload(campaigns)
				campaign_service = Sogou::SEM::CampaignService.new(get_auth)
				campaigns.each do |campaign|
					campaign_type_add = {
						:cpcPlanName=> campaign.campaign_name,
						#:budget => '100',
						#:negativeWords => ['7day'],
						#:exactNegativeWords => ['7daysin']
					}
					options = {:cpcPlanTypes => [campaign_type_add]}
					begin
						response = campaign_service.addCpcPlan(options)
						campaign.se_id = response.body[:cpc_plan_types][:cpc_plan_id].to_i
						sleep 1
					rescue Exception => ex
						p ex
						next
					end
				end
			end

			def sogou_get_info(campaigns)
				campaign_service = Sogou::SEM::CampaignService.new(get_auth)
				response = campaign_service.getCpcPlanByCpcPlanId(cpcPlanIds: campaigns.map{|campaign| campaign.se_id})
				response.body[:cpc_plan_types].each do |plan|
					campaign = campaigns.select{|item| item.se_id == plan[:cpc_plan_id].to_i}.first
					next if campaign.nil?
					campaign.status = case plan[:status].to_i
										when 11 then 1
										when 12 then 2
										else 0
										end
					campaign.campaign_name = plan[:cpcPlanName]
					campaign.negative_words = plan[:negativeWords]
					campaign.exact_negative_words = plan[:exactNegativeWords]
					campaign.se_status = campaign_type[:status].to_i
				end
			end

			def sogou_pause(campaigns)
			end

			def sogou_enable(campaigns)
			end

			def sogou_repair
			end

			def sogou_update(campaigns)
				campaign_service = Sogou::SEM::CampaignService.new(get_auth)
				campaigns.each do |campaign|
					campaign_type = {
						:cpcPlanId => campaign.se_id,
						:negativeWords => campaign.negative_words.split(","),
						:exactNegativeWords => campaign.exact_negative_words.split(",")
					}
					options = {:cpcPlanTypes => [campaign_type]}
					begin
						response = campaign_service.updateCpcPlan(options)
						if campaign.se_id == response.body[:cpc_plan_types][:cpc_plan_id].to_i
							campaign.status = campaign.status % 30
						end
						sleep 1
					rescue Exception => ex
						p ex
						next
					end
				end
			end
		end
	end
end