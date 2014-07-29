# AgaApiFactory

统一调用各搜索引擎SEM API

## Installation

Add this line to your application's Gemfile:

    gem 'aga_api_factory'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aga_api_factory

## Usage

1.Update Keyword 

account_360 = AgaApiFactory::Model::Account.new
account_360.account_name = 'xxxxx'
account_360.password = 'xxx'
account_360.api_key = 'xxx'
account_360.search_engine = 'qihu'

service = AgaApiFactory::Service::KeywordService.new
service.set_account(account_360)
service.handle(keywords,"update")  #keywords is AgaApiFactory::Model::Keyword Array     update is function

2.Pause Keyword

account_360 = AgaApiFactory::Model::Account.new
account_360.account_name = 'xxxxx'
account_360.password = 'xxx'
account_360.api_key = 'xxx'
account_360.search_engine = 'qihu'

service = AgaApiFactory::Service::KeywordService.new
service.set_account(account_360)
service.handle(keywords,"pause")  #keywords is AgaApiFactory::Model::Keyword Array     pause is function

3.Enable Keyword

account_360 = AgaApiFactory::Model::Account.new
account_360.account_name = 'xxxxx'
account_360.password = 'xxx'
account_360.api_key = 'xxx'
account_360.search_engine = 'qihu'

service = AgaApiFactory::Service::KeywordService.new
service.set_account(account_360)
service.handle(keywords,"enable")  #keywords is AgaApiFactory::Model::Keyword Array     enable is function

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request