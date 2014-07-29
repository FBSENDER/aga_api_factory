module AgaApiFactory
  module Service
    class CreativeService < BaseService
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

    end
  end
end
