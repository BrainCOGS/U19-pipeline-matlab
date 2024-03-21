%{
# Information of a pupillometry session
model_id:           int(11) AUTO_INCREMENT
---
model_description:  varchar(255)   # Description for each model ready to use for processing
model_path:         varchar(255)   # Model directory location
%}

classdef PupillometryModels < dj.Manual
    
end
