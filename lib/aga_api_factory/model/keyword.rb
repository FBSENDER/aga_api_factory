module AgaApiFactory
  module Model
    class Keyword
      #source_id => keyword在mysql中的自增Id
      #keyword => 关键词字符串
      #price => 关键词出价
      #url => 关键词的目标url 目前pc与mobile的url都使用该字段
      #match_type => 匹配方式 string类型
      #quality_score => 关键词质量度
      #status => 关键词mysql中的状态
      #se_status => 关键词在搜引擎段的状态
      attr_accessor :source_id,:keyword,:se_id,:adgroup_se_id,:price,:url
      attr_accessor :match_type,:quality_score,:status,:se_status,:exist_se_ids

      #match_type_enum keyword upload api will use it
      #不同搜索引擎match_type对应的枚举值不一样 需特别注意下
      def baidu_match_type_enum
        return 1 if self.match_type.nil? || self.match_type == "exact"
        return 2 if self.match_type == "phrase"
        return 3 if self.match_type == "wide"
      end
      def qihu_match_type_enum
        return 1 if self.match_type.nil? || self.match_type == "exact"
        return 2 if self.match_type == "phrase"
        return 3 if self.match_type == "wide"
      end
      def sogou_match_type_enum
        return 0 if self.match_type.nil? || self.match_type == "exact"
        return 2 if self.match_type == "phrase"
        return 1 if self.match_type == "wide"
      end
    end
  end
end
