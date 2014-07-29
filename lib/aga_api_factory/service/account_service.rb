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
            :body => {:client_id => "0b7e2630bbf293b98fb0fec2e106c652",
                  :response_type => "code",
                  :redirect_uri => "oob",
                  :username => account.account_name,
                  :password => account.password
                  })
        code = response.request.last_uri.to_s.scan(/code=.*/)[0]
        code_string = code[5..code.size-1]
        auth = Qihu::Auth.new('0b7e2630bbf293b98fb0fec2e106c652', '9699ba7f22206b4e9a4c1e281431125f')
        response = auth.get_token(code_string)
        account.api_key = response.token.token
      end
      #sogou api response is same with baidu
      def sogou_get_info(accounts)
        account_service = Sogou::SEM::AccountService.new(get_auth)
        response = account_service.getAccountInfo()
        self.account.status = 1 #sogou该接口未返回账户状态，故默认该值为1 有效
        self.account.se_id = response.body[:account_info_type][:accountid].to_i
        self.account.balance = response.body[:account_info_type][:balance].to_f
        self.account.quota = response.rquota
        self.account.budget = response.body[:account_info_type][:budget].to_f
        self.account
      end
      def baidu_get_info(accounts)
        account_service =  Baidu::SEM::AccountService.new(get_auth)
        response = account_service.getAccountInfo()
        self.account.status = 1#baidu该接口未返回账户状态，故默认该值为1 有效
        self.account.se_id = response.body[:account_info_type][:userid].to_i
        self.account.balance = response.body[:account_info_type][:balance].to_f
        self.account.quota = response.rquota
        self.account.budget = response.body[:account_info_type][:budget].to_f
        self.account
      end
    end
  end
end
