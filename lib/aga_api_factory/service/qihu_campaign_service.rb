module AgaApiFactory
	module Service
		class CampaignService < BaseService
			def qihu_upload(campaigns)
				campaign_service = Qihu::DianJing::Client.new(get_auth).campaign 
				campaigns.each do |campaign|
					response = campaign_service.add(name: campaign.campaign_name)
					campaign.se_id = JSON.parse(response.body)["id"]
					sleep 1
				end
			end

			def qihu_update(campaigns)
				campaign_service = Qihu::DianJing::Client.new(get_auth).campaign 
				campaigns.each do |campaign|
					response = campaign_service.add(name: campaign.campaign_name)
					campaign.se_id = JSON.parse(response.body)["id"]
					sleep 1
				end
			end

			def qihu_get_info(campaigns)
				campaign_service = Qihu::DianJing::Client.new(get_auth).campaign
				campaigns.each do |campaign|
					response = campaign_service.getInfoById(id: campaign.se_id)
					info = JSON.parse(response.body)
					campaign.campaign_name = info["name"]
					campaign.budget = info["budget"].to_f
					campaign.status = case info["status"] 
										when "enable" then 1
										when "pause" then 2
										else 0
										end
					campaign.se_status = campaign.status
				end
			end
			def qihu_pause(campaigns)
				campaign_service = Qihu::DianJing::Client.new(get_auth).campaign
				campaigns.each do |campaign|
					response = campaign_service.update(id: campaign.se_id,status: "pause")
					info = JSON.parse(response.body)
					begin
						raise "campaign pause error : " unless campaign.se_id == JSON.parse(response.body)["id"]
						campaign.status = 2
					rescue Exception => ex
						p ex
						p response
						campaign.status += 100
						next 
					end
				end
			end

			def qihu_enable(campaigns)
				campaign_service = Qihu::DianJing::Client.new(get_auth).campaign
				campaigns.each do |campaign|
					response = campaign_service.update(id: campaign.se_id,status: "enable")
					info = JSON.parse(response.body)
					begin
						raise "campaign pause error : " unless campaign.se_id == JSON.parse(response.body)["id"]
						campaign.status = 1
					rescue Exception => ex
						p ex
						p response
						campaign.status += 100
						next 
					end
				end
			end

			def qihu_repair
			end
		end
	end
end