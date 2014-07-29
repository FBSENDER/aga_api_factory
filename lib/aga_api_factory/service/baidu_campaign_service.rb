module AgaApiFactory
  module Service
    class CampaignService < BaseService

      def baidu_upload(campaigns)
        campaign_service = Baidu::SEM::CampaignService.new(get_auth)
        campaigns.each do |campaign|
          campaign_type ={
            :campaignName => campaign.campaign_name,
            :negativeWords => campaign.negative_words.split(","),
            :exactNegativeWords => campaign.exact_negative_words.split(",")
          }
          response = campaign_service.addCampaign({:campaignTypes => [campaign_type]})
          result = response.body[:campaign_types]
          campaign.se_id = result[:campaign_id].to_i
          campaign.status = case result[:status].to_i
                    when 21 then 1
                    when 23 then 2
                    else 0
                    end
        end
      end

      def baidu_update(campaigns)
        campaign_service = Baidu::SEM::CampaignService.new(get_auth)
        campaigns.each do |campaign|
          begin
            campaign_type ={
              :campaignId => campaign.se_id,
              :negativeWords => campaign.negative_words.split(","),
            }
            response = campaign_service.updateCampaign({:campaignTypes => [campaign_type]})
            p response
            result = response.body[:campaign_types]
            if campaign.se_id = result[:campaign_id].to_i
              campaign.status = campaign.status % 10
            end
          rescue Exception => ex 
            puts ex.to_s
            next
          end
        end
      end

      def baidu_get_info(campaigns)
        campaign_service = Baidu::SEM::CampaignService.new(get_auth)
        campaign_ids = campaigns.map{|item| item.se_id}
        response = campaign_service.getCampaignByCampaignId(:campaignIds => campaign_ids)
        response.body[:campaign_types].each do |campaign_type|
          campaign = campaigns.select{|item| item.se_id == campaign_type[:campaign_id].to_i}.first
          next if campaign.nil?
          campaign.campaign_name = campaign_type[:campaign_name]
          campaign.status = case campaign_type[:status].to_i
                    when 21 then 1
                    when 23 then 2
                    else 0
                    end
          campaign.se_status = campaign_type[:status].to_i
        end
      end

      def baidu_repaire(campaigns)
        campaign_service = Baidu::SEM::CampaignService.new(get_auth)
        response = campaign_service.getAllCampaign
        response.body[:campaign_types].each do |campaign_type|
          campaign = campaigns.select{|item| item.campaign_name == campaign_type[:campaign_name]}.first
          next if campaign.nil?
          campaign.se_id = campaign_type[:campaign_id]
          campaign.status = case campaign_type[:status].to_i
                    when 21 then 1
                    when 23 then 3
                    else 0
                    end
        end
      end

      def baidu_get_all
        campaigns = Array.new
        campaign_service = Baidu::SEM::CampaignService.new(get_auth)
        response = campaign_service.getAllCampaign
        campaign_types = response.body[:campaign_types]
        return campaigns if campaign_types.nil?
        if campaign_types.class == Array
          campaign_types.each do |campaign_type|
            campaign = AgaApiFactory::Model::Campaign.new
            campaign.se_id = campaign_type[:campaign_id]
            campaign.campaign_name = campaign_type[:campaign_name]
            campaign.se_status = campaign_type[:status].to_i
            campaign.status = case campaign_type[:status].to_i
                      when 21 then 1
                      when 23 then 3
                      else 0
                      end
            unless campaign_type[:negative_words].nil?
              if campaign_type[:negative_words].class == Array
                campaign.negative_words = campaign_type[:negative_words].join(",")
              else 
                campaign.negative_words = campaign_type[:negative_words].to_s 
              end
            end
            unless campaign_type[:exact_negative_words].nil?
              if campaign_type[:exact_negative_words].class == Array
                campaign.exact_negative_words = campaign_type[:exact_negative_words].join(",") 
              else 
                campaign.exact_negative_words = campaign_type[:exact_negative_words].to_s
              end
            end
            campaigns << campaign 
          end
        else
          campaign = AgaApiFactory::Model::Campaign.new
            campaign.se_id = campaign_types[:campaign_id]
            campaign.campaign_name = campaign_types[:campaign_name]
            campaign.se_status = campaign_types[:status].to_i
            campaign.status = case campaign_types[:status].to_i
                      when 21 then 1
                      when 23 then 2
                      else 0
                      end
            unless campaign_types[:negative_words].nil?
              if campaign_types[:negative_words].class == Array
                campaign.negative_words = campaign_types[:negative_words].join(",")
              else 
                campaign.negative_words = campaign_types[:negative_words].to_s 
              end
            end
            unless campaign_types[:exact_negative_words].nil?
              if campaign_types[:exact_negative_words].class == Array
                campaign.exact_negative_words = campaign_types[:exact_negative_words].join(",") 
              else 
                campaign.exact_negative_words = campaign_types[:exact_negative_words].to_s
              end
            end
            campaigns << campaign 
        end
        campaigns
      end

    end
  end
end
