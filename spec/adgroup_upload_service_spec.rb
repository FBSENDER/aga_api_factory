require 'spec_helper'
# require File.open(File.join(__dir__,'spec_helper.rb')) 

#describe AgaApiFactory::Service::AdgroupService do
#	subject{AgaApiFactory::Service::AdgroupService.new}
#	describe "#upload" do
#		it "works" do
			# subject.set_account($account)
			# adgroups = []
			# group = AgaApiFactory::Model::Adgroup.new
			# group.campaign_se_id = 818090339
			# group.adgroup_name = "test_adgroup_4"
			# group.price = 1.1
			# adgroups << group
			# group = AgaApiFactory::Model::Adgroup.new
			# group.campaign_se_id = 818090339
			# group.adgroup_name = "test_adgroup_5"
			# group.price = 1.2
			# adgroups << group
			# subject.adgroup_upload(adgroups)
			# p adgroups
#		end
#	end
	#describe '#baidu_get_all' do 
		#it "works" do 
			#subject.set_account($account_360)
			#adgroups = subject.qihu_get_all(1053016902)
			#p adgroups
		#end
	#end
	# describe '#baidu_get_all' do 
	# 	it "works" do 
	# 		subject.set_account($account_baidu)
	# 		adgroups = subject.baidu_get_all([12110121])
	# 		p adgroups
	# 	end
	# end
	# describe "#pause" do 
	# 	it "works" do
	# 		subject.set_account($account_360)
	# 		adgroups = []
	# 		group = AgaApiFactory::Model::Adgroup.new
	# 		group.se_id = 3485708174
	# 		group.status = 1
	# 		adgroups << group 
	# 		group = AgaApiFactory::Model::Adgroup.new
	# 		group.se_id = 3485707150
	# 		group.status = 1
	# 		adgroups << group 
	# 		subject.handle("pause",adgroups)
	# 		p adgroups
	# 	end
	# end
	# describe "#update" do 
	# 	it "works" do
	# 		subject.set_account($account_360)
	# 		adgroups = []
	# 		group = AgaApiFactory::Model::Adgroup.new
	# 		group.adgroup_name = "东方广场"
	# 		group.price = 5
	# 		group.se_id = 3485708174
	# 		group.status = 1
	# 		group.match_type = "exact"
	# 		adgroups << group 
	# 		group = AgaApiFactory::Model::Adgroup.new
	# 		group.se_id = 3485707150
	# 		group.adgroup_name = "中国国际展览中心"
	# 		group.price = 5
	# 		group.status = 1
	# 		group.match_type = "exact"
	# 		adgroups << group 
	# 		subject.handle("update",adgroups)
	# 		p adgroups
	# 	end
	# end
	#describe "#get_info" do
	 #	it "works" do
      subject = AgaApiFactory::Service::AdgroupService.new
	 		subject.set_account($account_360)
	 		adgroups = []
	 		group = AgaApiFactory::Model::Adgroup.new
	 		group.se_id = 1841439590 
	 		adgroups << group 
	 		group = AgaApiFactory::Model::Adgroup.new
	 		group.se_id = 1841443430 
	 		adgroups << group 
	 		subject.qihu_get_info(adgroups)
	 		p adgroups
	 #	end
	 #end

	# describe "#sogou_repaire" do
	# 	it "works" do
	# 		subject.set_account($account_sogou)
	# 		adgroups = []
	# 		group = AgaApiFactory::Model::Adgroup.new
	# 		group.adgroup_name = '苏州科技学院'
	# 		group.campaign_se_id = 184209819
	# 		adgroups << group 
	# 		subject.handle(adgroups,"repaire")
	# 		p adgroups
	# 	end
	# end
	# describe "#qihu_repaire" do
	# 	it "works" do
	# 		subject.set_account($account_360)
	# 		adgroups = []
	# 		group = AgaApiFactory::Model::Adgroup.new
	# 		group.adgroup_name = '东方广场'
	# 		group.campaign_se_id = 1053016902
	# 		adgroups << group 
	# 		subject.handle(adgroups,"repaire")
	# 		p adgroups
	# 	end
	# end
#end
