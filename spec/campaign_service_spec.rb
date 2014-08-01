require 'spec_helper'

describe AgaApiFactory::Service::CampaignService do 
  subject{AgaApiFactory::Service::CampaignService.new}
  describe "#baidu upload get_info delete" do 
    it "upload,get_info,delete,get_info again" do
      subject.set_account($account_baidu)
      #upload
      campaign = AgaApiFactory::Model::Campaign.new
      campaign.campaign_name = 'apit_test_campaign'
      campaign.negative_words = 'test1,test2'
      campaign.exact_negative_words = 'test3,test4'
      subject.baidu_upload([campaign])
      expect(campaign.se_id).to be > 0
      #se_id
      se_id = campaign.se_id 
      #get_info
      campaign_1 = AgaApiFactory::Model::Campaign.new
      campaign_1.se_id = se_id
      subject.baidu_get_info([campaign_1])
      expect(campaign_1.campaign_name).to eq(campaign.campaign_name)
      #delete
      subject.baidu_delete([campaign_1])
      expect(campaign_1.status).to eq(9)
      #get_info again
      campaign_2 = AgaApiFactory::Model::Campaign.new
      campaign_2.se_id = se_id
      result = subject.baidu_get_info([campaign_2])
      expect(result[:code]).to eql('90111') #Campaign is not exist
    end    
  end
end
