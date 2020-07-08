%{
-> behavior.TowersBlockTrialVideo
---
video:                      longblob # frame by frame video for trial
%}

classdef TowersBlockTrialVideo < dj.Part
    properties(SetAccess=protected)
        master = behavior.TowersBlockTrial
    end
    methods
        function make(self, key)
            self.insert(key);
        end
    end
end