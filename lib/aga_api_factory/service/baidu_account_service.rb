module AgaApiFactory
  module Service
    class AccountService < BaseService

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
