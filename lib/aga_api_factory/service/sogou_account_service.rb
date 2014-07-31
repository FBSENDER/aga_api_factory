module AgaApiFactory
  module Service
    class AccountService < BaseService
      
      #sogou api response is same with baidu
      def sogou_get_info(accounts = nil)
        account_service = Sogou::SEM::AccountService.new(get_auth)
        response = account_service.getAccountInfo()
        p response if $debug
        self.account.status = 1 #sogou该接口未返回账户状态，故默认该值为1 有效
        self.account.se_id = response.body[:account_info_type][:accountid].to_i
        self.account.balance = response.body[:account_info_type][:balance].to_f
        self.account.quota = response.rquota
        self.account.budget = response.body[:account_info_type][:budget].to_f
        self.account
      end

    end
  end
end
