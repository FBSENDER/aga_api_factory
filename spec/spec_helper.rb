require 'aga_api_factory'

$account_360 = AgaApiFactory::Model::Account.new
$account_360.account_name = ENV["QIHU_USER"] 
$account_360.password = ENV["QIHU_PASSWORD"]
$account_360.api_key = ENV["QIHU_API_KEY"]
$account_360.search_engine = 'qihu'

$account_baidu = AgaApiFactory::Model::Account.new
$account_baidu.account_name = ENV["BAIDU_USER"]
$account_baidu.password = ENV["BAIDU_PASSWORD"]
$account_baidu.api_key = ENV["BAIDU_API_KEY"]
$account_baidu.search_engine = 'baidu'

$account_sogou = AgaApiFactory::Model::Account.new
$account_sogou.account_name = ENV["SOGOU_USER"] 
$account_sogou.password = ENV["SOGOU_PASSWORD"]
$account_sogou.api_key = ENV["SOGOU_API_KEY"]
$account_sogou.search_engine = 'sogou'

$debug = false
