require 'spec_helper'
#require File.open(File.join(__dir__,'spec_helper.rb'))

describe AgaApiFactory::Service::KeywordService do
	subject{AgaApiFactory::Service::KeywordService.new}
	# describe '#baidu_get_all' do 
	# 	it "works" do 
	# 		subject.set_account($account_baidu)
	# 		keywords = subject.baidu_get_all([236114400])
	# 		p keywords
	# 	end
	# end
	# describe '#baidu_get_all' do 
	# 	it "works" do 
	# 		subject.set_account($account_baidu)
	# 		keywords = subject.baidu_get_all([236114400])
	# 		p keywords
	# 	end
	# end

	# describe "#keyword_pause" do
	# 	it "works" do
	# 		subject.set_account($account_360)
	# 		keywords = []
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 316219936
	# 		keywords << keyword
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 316231968
	# 		keywords << keyword
	# 		subject.handle(keywords,"pause")
	# 	end
	# end

	# describe "#keyword_enable" do
	# 	it "works" do
	# 		subject.set_account($account_360)
	# 		keywords = []
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 316219936
	# 		keywords << keyword
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 316231968
	# 		keywords << keyword
	# 		subject.handle(keywords,"enable")
	# 	end
	# end
	# describe "#sogou_keyword_update" do
	# 	it "works" do 
	# 		subject.set_account($account_sogou)
	# 		keywords = []
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 1307804812
	# 		keyword.price = 1
	# 		keyword.status = 31
	# 		keywords << keyword
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 1307804813
	# 		keyword.price = 3.36
	# 		keyword.status = 31
	# 		keywords << keyword
	# 		subject.handle(keywords,"update")
	# 	end
	# end
	# describe "#sogou_keyword_repaire" do
	# 	it "works" do 
	# 		subject.set_account($account_sogou)
	# 		keywords = []
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.adgroup_se_id = 189321231
	# 		keyword.keyword = '北京东方广场附近的酒店'
	# 		keywords << keyword
	# 		subject.handle(keywords,"repaire")
	# 		p keywords
	# 	end
	# end
	# describe "#qihu_keyword_repaire" do
	# 	it "works" do 
	# 		subject.set_account($account_360)
	# 		keywords = []
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.adgroup_se_id = 3485708174
	# 		keyword.keyword = '东方广场附近酒店'
	# 		keywords << keyword
	# 		subject.handle(keywords,"repaire")
	# 		p keywords
	# 	end
	# end
end
