module AgaApiFactory
  module Model
    class Campaign
      #source_id => Campaign在mysql中的自增Id
      #pause => 是否为暂停状态
      #negative_words => 计划的否定词
      #exact_negative_words => 计划的精确否定词
      #status => 计划在mysql中的状态
      #budget => 计划每日的限制消费
      #regionTarget => 计划的投放地域 暂未使用
      #se_status => 计划在搜索引擎端的状态 暂未使用
      attr_accessor :source_id,:se_id,:se_status,:campaign_name,:pause,:negative_words
      attr_accessor :status,:budget,:regionTarget,:device,:exact_negative_words
    end
  end
end
