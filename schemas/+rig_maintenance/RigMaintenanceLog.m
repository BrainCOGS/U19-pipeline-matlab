%{
# Specific actions performed for maintenance on each rig
-> rig_maintenance.RigMaintenanceAction
maintenance_time            : datetime                      # 
---
 (maintenance_person) -> lab.User
maintenance_params          : longtext                      # Json with parameters specific for maintenance action
%}

classdef RigMaintenanceLog < dj.Manual
end
