require 'spec_helper'

describe AgaApiFactory::Service::CampaignService do
	describe "#upload" do
		it "works" do
			# service = AgaApiFactory::Service::CampaignUploadService.new
			# service.set_account($account)
			# campaign = AgaApiFactory::Model::Campaign.new
			# campaign.campaign_name = 'test_2'
			# campaign.se_id = 0
			# campaigns = [campaign]
			# service.campaign_upload(campaigns)
			# campaign.se_id.should > 0
		end
	end
	# describe "#baidu_get_all" do
	# 	it "works" do
	# 		service = AgaApiFactory::Service::CampaignService.new
	# 		service.set_account($account_baidu)
	# 		campaigns = service.baidu_get_all
	# 		p campaigns
	# 	end
	# end
	describe "#qihu_get_all" do
		it "works" do
			service = AgaApiFactory::Service::CampaignService.new
			service.set_account($account_360)
			campaigns = service.qihu_get_all
			p campaigns
		end
	end
end
