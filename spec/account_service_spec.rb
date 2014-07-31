require 'spec_helper'

describe AgaApiFactory::Service::AccountService do
  subject{AgaApiFactory::Service::AccountService.new}
  describe "#baidu_get_info" do
    it "works" do
      subject.set_account($account_baidu)
      subject.baidu_get_info
      expect(subject.account.se_id).to be > 0
    end
    it "#get_info result is same with #baidu_get_info" do 
      subject.set_account($account_baidu)
      subject.baidu_get_info
      se_id = subject.account.se_id 
      subject.account.se_id = 0
      subject.handle(nil,"get_info")
      expect(se_id).to be > 0
      expect(subject.account.se_id).to eql(se_id)
    end
  end

  describe "#sogou_get_info" do
    it "works" do
      subject.set_account($account_sogou)
      subject.sogou_get_info
      expect(subject.account.se_id).to be > 0
    end
    it "#get_info result is same with #sogou_get_info" do 
      subject.set_account($account_sogou)
      subject.sogou_get_info
      se_id = subject.account.se_id 
      subject.account.se_id = 0
      subject.handle(nil,"get_info")
      expect(se_id).to be > 0
      expect(subject.account.se_id).to eql(se_id)
    end
  end

  describe "#qihu_get_info" do
    it "works" do
      subject.set_account($account_360)
      subject.qihu_get_info
      expect(subject.account.se_id).to be > 0
    end
    it "#get_info result is same with #qihu_get_info" do 
      subject.set_account($account_360)
      subject.qihu_get_info
      se_id = subject.account.se_id 
      subject.account.se_id = 0
      subject.handle(nil,"get_info")
      expect(se_id).to be > 0
      expect(subject.account.se_id).to eql(se_id)
    end
  end
end
