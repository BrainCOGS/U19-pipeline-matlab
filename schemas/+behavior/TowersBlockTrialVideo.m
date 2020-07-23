%{
-> behavior.TowersBlockTrial
---
filepath           :  varchar(511)   # the absolute directory created for this video
%}

classdef TowersBlockTrialVideo < dj.Imported
  methods(Access=protected)
    function makeTuples(self, key)
      %self.insert(key)
    end
  end
end