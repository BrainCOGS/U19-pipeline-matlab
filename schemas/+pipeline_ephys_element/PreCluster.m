%{
# 
-> pipeline_ephys_element.PreClusterTask
---
precluster_time             : datetime                      # time of generation of this set of pre-clustering results
package_version             : varchar(16)                   # 
%}


classdef PreCluster < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


