module AgaApiFactory
	module Service
		class KeywordService < BaseService
			def sogou_upload(keywords)
				keyword_service = Sogou::SEM::KeywordService.new(get_auth)
				keyword_types = keywords.map{|keyword| {
					:cpcGrpId => keyword.adgroup_se_id,
					:cpc=>keyword.keyword,
					:matchType => keyword.sogou_match_type_enum,
					:price => keyword.price,
					:visitUrl => keyword.url,
					:mobileVisitUrl => keyword.url
				}}
				response = keyword_service.addCpc({:cpcTypes => keyword_types})
				if response.body.has_key?(:cpc_types)
					keyword_types = [response.body[:cpc_types]].flatten
					keyword_types.each_with_index do |keyword_type,index|
							keywords[index].se_id = keyword_type[:cpc_id]
							keywords[index].se_status = keyword_type[:status]
					end
				end
				if response.failures
					failures = [response.failures].flatten
					failures.each do |failure|
						error_code = failure[:code].to_i
						position = failure[:position].scan(/\[\d*\]/).first.delete("[]").to_i
						case error_code
							when 1020006 then keywords[position].status = 8 #已上传 未获得se_id
							when 1020004 then keywords[position].status = 6 #超长
							when 1020019 then keywords[position].status = 7 #触发了黑名单
							when 1020020 then keywords[position].status = 7 #包含别人的注册商标
							when 1020021 then keywords[position].status = 7 #包含触犯他人权益的词
							when 1020012 then keywords[position].status = 5 #含非法字符
						end
					end
				end
			end
			def sogou_update(keywords)
				keyword_service = Sogou::SEM::KeywordService.new(get_auth)
				keywords.each do |keyword|
					begin
						update_hash = Hash.new
						update_hash[:cpcId] = keyword.se_id
						update_hash[:price] = keyword.price if keyword.price && keyword.price > 0
						update_hash[:visitUrl] = keyword.url if keyword.url && keyword.url.size > 0
						update_hash[:mobileVisitUrl] = keyword.url if keyword.url && keyword.url.size > 0
						response = keyword_service.updateCpc(:cpcTypes => [update_hash])
						raise "keyword update error : " unless keyword.se_id == response.body[:cpc_types][:cpc_id].to_i
						keyword.status = keyword.status % 10
					rescue Exception => ex
						p ex
						p response
						keyword.status += 100
						next 
					end
				end
			end
			def sogou_pause(keywords)
				keyword_service = Sogou::SEM::KeywordService.new(get_auth)
				keywords.each do |keyword|
					begin
						response = keyword_service.updateCpc(:cpcTypes => [{:cpcId => keyword.se_id,:pause => true}])
						raise "keyword pause error : " unless keyword.se_id == response.body[:cpc_types][:cpc_id].to_i
						keyword.status = 2
					rescue Exception => ex
						p ex
						p response
						keyword.status += 100
						next 
					end
				end
			end
			def sogou_enable(keywords)
				keyword_service = Sogou::SEM::KeywordService.new(get_auth)
				keywords.each do |keyword|
					begin
						response = keyword_service.updateCpc(:cpcTypes => [{:cpcId => keyword.se_id,:pause => false}])
						raise "keyword enable error : " unless keyword.se_id == response.body[:cpc_types][:cpc_id].to_i
						keyword.status = 1
					rescue Exception => ex
						p ex
						p response
						keyword.status += 100
						next 
					end
				end
			end
			def sogou_delete(keywords)
				keyword_service = Sogou::SEM::KeywordService.new(get_auth)
				keywords.each do |keyword|
					begin
						response = keyword_service.deleteCpc(:cpcIds => [keyword.se_id],:getTemp => 0)
						keyword.status = 9
					rescue Exception => ex
						p ex
						p response
						keyword.status += 100
						next 
					end
				end
			end
			def sogou_repaire(keywords)
				keyword_service = Sogou::SEM::KeywordService.new(get_auth)
				keywords.each do |keyword|
					begin
						response = keyword_service.getCpcByCpcGrpId(:cpcGrpIds => [keyword.adgroup_se_id])
						cpc_types = response.body[:cpc_grp_cpcs][:cpc_types]
						if cpc_types.class == Array
							cpc_types.each do |cpc|
								next if keyword.keyword != cpc[:cpc]
								keyword.se_id = cpc[:cpc_id].to_i
								keyword.price = cpc[:price].to_f
								keyword.quality_score = cpc[:cpc_quality].to_i
								keyword.status = case cpc[:status].to_i
												when 35 then 1 #有效
												when 32 then 2 #暂停
												when 31 then 4 #审核未通过
												when 33 then 3 #审核中
												when 34 then 5 #搜索无效
												else 0
												end
							end
						else
							cpc = cpc_types
							next if keyword.keyword != cpc[:cpc]
							keyword.se_id = cpc[:cpc_id].to_i
							keyword.price = cpc[:price].to_f
							keyword.quality_score = cpc[:cpc_quality].to_i
							keyword.status = case cpc[:status].to_i
												when 35 then 1 #有效
												when 32 then 2 #暂停
												when 31 then 4 #审核未通过
												when 33 then 3 #审核中
												when 34 then 5 #搜索无效
												else 0
												end
						end
					rescue Exception => ex
						p ex
						p response
						next 
					end
				end
			end
			def sogou_get_info(keywords)
				keyword_service = Sogou::SEM::KeywordService.new(get_auth)
				id_list = keywords.map{|keyword| keyword.se_id}
				#getTemp = 0 只查询生效关键词列表 getTemp = 1 只查询修改未生效列表
				response = keyword_service.getCpcByCpcId(:cpcIds => id_list,:getTemp => 0)
				if response.body[:cpc_types].class == Array
					response.body[:cpc_types].each do |cpc|
						keyword = keywords.select{|item| item.se_id == cpc[:cpc_id].to_i}.first
						next if keyword.nil?
						keyword.quality_score = cpc[:cpc_quality].to_i
						keyword.status = case cpc[:status].to_i
											when 35 then 1 #有效
											when 32 then 2 #暂停
											when 31 then 4 #审核未通过
											when 33 then 3 #审核中
											when 34 then 5 #搜索无效
											else 0
											end
						keyword.price = cpc[:price].to_f
						keyword.url = cpc[:visit_url]
					end
				elsif response.body[:cpc_types].class == Hash
					cpc = response.body[:cpc_types]
					keyword = keywords.select{|item| item.se_id == cpc[:cpc_id].to_i}.first
					if keyword.nil?
						p response
						return
					end
					keyword.quality_score = cpc[:cpc_quality].to_i
					keyword.status = case cpc[:status].to_i
										when 35 then 1 #有效
										when 32 then 2 #暂停
										when 31 then 4 #审核未通过
										when 33 then 3 #审核中
										when 34 then 5 #搜索无效
										else 0
										end
					keyword.price = cpc[:price].to_f						
					keyword.url = cpc[:visit_url]
				else
					p response
				end
			end
		end
	end
end