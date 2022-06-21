%{
# Clustering Procedure
-> pipeline_ephys_element.ClusteringTask
---
clustering_time             : datetime                      # time of generation of this set of clustering results
package_version             : varchar(16)                   # 
%}


classdef Clustering < dj.Imported
	methods(Access=protected)
		function makeTuples(self, key)
		end
	end

end


