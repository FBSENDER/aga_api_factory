module AgaApiFactory
  module Service
    class CreativeService < BaseService
      def qihu_upload(creatives)
        creative_service = Qihu::DianJing::Client.new(get_auth).creative
        creatives.each do |creative|
          begin
            response = creative_service.add(
              groupId: creative.adgroup_se_id,
              title: creative.title,
              description1: creative.description1,
              #qihu 若传入description2 会报错 创意描述超长...
              description2: "",
              destinationUrl: creative.destination_url,
              displayUrl: creative.display_url)
            body = JSON.parse(response.body)
            if body.has_key?("id")
              creative.se_id = body["id"]
            end
            if body.has_key?("failures")
              p body["failures"]
              failures = [body["failures"]].flatten
              failures.each do |failure|
                error_code = failure["code"]
                case error_code
                  when 50402 then creative.status = 6 #超长
                  when 50403 then creative.status = 6 #超长
                  when 50607 #包含商标
                    creative.status = 7 
                    creative.trademark = failure["message"]
                  when 50608 #包含竞品词
                    creative.status = 7 
                    creative.competing_word = failure["message"]
                  when 50609 #包含黑名单
                    creative.status = 7 
                    creative.black_word = failure["message"]
                  when 50606 then creative.status = 8 #包含非法字符
                  when 50406 then creative.status = 10 #单元内创意过多，由于上传时获取上传结果超市，重复上传导致
                end 
              end
            end
          rescue Exception => ex 
            puts ex.to_s
          end
        end
      end
    end
  end
end
