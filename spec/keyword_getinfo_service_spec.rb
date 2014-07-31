require 'spec_helper'
#require File.open(File.join(__dir__,'spec_helper.rb'))

describe AgaApiFactory::Service::KeywordService do
	subject{AgaApiFactory::Service::KeywordService.new}
	# describe "#qihu_get_all" do
	# 	it "works" do
	# 		subject.set_account($account_360)
	# 		keywords = subject.qihu_get_all(3485708174)
	# 		p keywords
	# 		end
	# end
	# describe "#get_status" do
	# 	it "works" do
	# 		subject.set_account($account_360)
	# 		keywords = []
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 316219936
	# 		keywords << keyword
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 316231968
	# 		keywords << keyword
	# 		subject.handle(keywords,"get_status")
	# 		p keywords
	# 	end
	# end
	# describe "#get_id_list" do
	# 	it "works" do
	# 		subject.set_account($account_360)
	# 		adgroup_se_id = 3485707150
	# 		p subject.handle(adgroup_se_id,"get_id_list")
	# 	end
	# end
	# describe "#get_info" do
	# 	it "works" do
	# 		subject.set_account($account_baidu)
	# 		keywords = []
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 4386468625
	# 		keywords << keyword
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 4386468622
	# 		keywords << keyword
	# 		subject.handle(keywords,"get_status")
	# 		p keywords
	# 	end
	# end
	# describe "#sogou_get_info" do
	# 	it "works" do
	# 		subject.set_account($account_sogou)
	# 		keywords = []
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 1307804812
	# 		keywords << keyword
	# 		keyword = AgaApiFactory::Model::Keyword.new
	# 		keyword.se_id = 1307804813
	# 		keywords << keyword
	# 		subject.handle(keywords,"get_info")
	# 		p keywords
	# 	end
	# end
end
