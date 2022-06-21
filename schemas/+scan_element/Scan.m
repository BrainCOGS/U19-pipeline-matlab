%{
# 
-> acquisition.Session
scan_id                     : int                           # 
---
-> lab.Equipment
-> scan_element.AcquisitionSoftware
scan_notes                  : varchar(4095)                 # free-notes
%}


classdef Scan < dj.Manual


end


