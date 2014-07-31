module AgaApiFactory
  module Service
    class AccountService < BaseService

      def qihu_get_info(accounts)
        account_service = Qihu::DianJing::Client.new(get_auth).account
        response = account_service.getInfo()
        info = JSON.parse(response.body)
        self.account.status = 1 #360该接口未返回账户状态，故默认该值为1 有效
        self.account.balance = info["balance"].to_f
        self.account.budget = info["budget"].to_f
        self.account.se_id = info["uid"].to_i
        self.account.quota = response.headers["quotaremain"].to_i
        self.account
      end
      
      #360token采用auth2验证 需要定期刷新token
      #现在上传物料时一个操作的持续时间可能超过token的有效时间，故会引发一些问题
      #下面的方法为刷新token 没有采用refresh_token的形式
      #如果360又启用了图片验证码，则该方法失效
      def qihu_refresh_token(accounts)
        url = "https://openapi.360.cn/oauth2/authorize"
        response = HTTParty.post(url,
            :body => {:client_id => ENV["QIHUID"],
                  :response_type => "code",
                  :redirect_uri => "oob",
                  :username => account.account_name,
                  :password => account.password
                  })
        code = response.request.last_uri.to_s.scan(/code=.*/)[0]
        code_string = code[5..code.size-1]
        auth = Qihu::Auth.new(ENV["QIHUID"], ENV["QIHUKEY"])
        response = auth.get_token(code_string)
        account.api_key = response.token.token
      end

    end
  end
end
