module AagApiFactory
  module Service
    class CreativeService < BaseService
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
    end
  end
end
