module AgaApiFactory
  module Model
    class Adgroup
      #source_id => adgroup在mysql中的自增Id
      #campaign_se_id => 单元所在计划的se_id
      #price => 单元的出价
      #match_type => 单元的匹配方式
      #negative_words => 单元的否定词 360只能在单元层级添加否定词
      #exact_negative_words => 单元的精确否定词
      #status => 单元在mysql中的状态
      #se_status => 单元在搜索引擎端的状态
      attr_accessor :source_id,:adgroup_name,:se_id,:campaign_se_id,:se_status,:price
      attr_accessor :negative_words,:exact_negative_words,:status,:match_type
    end
  end
end
