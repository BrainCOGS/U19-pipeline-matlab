%{
# 
protocol                          : varchar(64)                      # Protocol Name 
---
levels                            : int                              # How many levels in protocol
sublevels=null                    : varchar(512)                     # Sublevel info for each level (if present)
%}


classdef ProtocolLevel < dj.Manual


end


