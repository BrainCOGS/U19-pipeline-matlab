%{
# 
brain_area                  : varchar(16)                   # 
---
area_full_name              : varchar(128)                  # 
%}


classdef BrainArea < dj.Lookup
    properties
        contents = {
            'Hippocampus', ''
            'Striatum', ''
            'PPC', 'Posterior Parietal Cortex' 
            'EC', 'Entorhinal Cortex'
        }
        
    end
end
