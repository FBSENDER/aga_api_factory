module AgaApiFactory
  module Service
    #BaseServcie 该层级下其他service的父类
    #负责设置service所需的基础数据及有效性验证
    #获取认证
    class BaseService
      attr_accessor :account,:token_is_error
      def set_account(account)
        raise "account should be AgaApiFactory::Model::Account" if account.class != AgaApiFactory::Model::Account
        self.account = account
        self.token_is_error = false
      end
      def get_auth
        verificate
        self.send(self.account.search_engine + "_get_auth")
      end
      def baidu_get_auth
        auth = Baidu::Auth.new
        auth.username = self.account.account_name
        auth.password = self.account.password
        auth.token = self.account.api_key
        auth
      end
      def qihu_get_auth
        app_id = ENV["QIHUID"] 
        app_pub_key = ENV["QIHUKEY"]
        auth = Qihu::Auth.new(app_id,app_pub_key)
        auth.get_token_from_hash(:access_token => self.account.api_key)
        auth
      end
      def sogou_get_auth
        auth = Sogou::Auth.new
        auth.username = self.account.account_name
        auth.password = self.account.password
        auth.token = self.account.api_key
        auth
      end
      def handle(args,operation)
        verificate
        self.send([self.account.search_engine,operation].join("_"),args)
      end

      def verificate
        raise "please set account first" if self.account.nil?
        raise "未知的搜索引擎" unless ["baidu","qihu","sogou"].include?(self.account.search_engine)
      end

    end
  end
end
