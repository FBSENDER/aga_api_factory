module AgaApiFactory
  module Model
    class Account
      attr_accessor :account_name,:password,:se_id,:api_key,:search_engine,:device
      #balance => 余额 quota => 配额 budget => 账户每日限制消费 status => 账户状态 se_status => 账户在搜索引擎端的状态
      attr_accessor :balance,:quota,:budget,:status,:se_status
    end
  end
end
