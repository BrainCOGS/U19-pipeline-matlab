%{
# 
mobile_carrier              : varchar(16)                   # allowed mobile carries
%}

classdef MobileCarrier < dj.Lookup
    properties
        contents = {'alltel';
                    'att';
                    'boost';
                    'cingular';
                    'cingular2';
                    'cricket';
                    'metropcs';
                    'nextel';
                    'sprint';
                    'tmobile';
                    'tracfone';
                    'uscellular';
                    'verizon';
                    'virgin';
        }
    end
end


