%{
# 
-> behavior_old.TowersSession
---
subject_delta_data=null     : blob                          # num of right - num of left, x ticks for data
subject_pright_data=null    : blob                          # percentage went right for each delta bin for data
subject_delta_error=null    : blob                          # num of right - num of left, x ticks for data confidence interval
subject_pright_error=null   : blob                          # confidence interval for precentage went right of data
subject_delta_fit=null      : blob                          # num of right - num of left, x ticks for fitting results
subject_pright_fit=null     : blob                          # fitting results for percent went right
%}


classdef TowersSubjectCumulativePsych < dj.Computed
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


