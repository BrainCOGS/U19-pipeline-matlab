%{
subtask:                   varchar(32)
---
subtask_description='':    varchar(512)
%}

classdef Subtask < dj.Lookup
    properties
        contents = {
            'Standard',               '(no extra fields in DB)'
            'DoorStop',               'Extra Doorstop task fields for behavior'
            }
    end
end
