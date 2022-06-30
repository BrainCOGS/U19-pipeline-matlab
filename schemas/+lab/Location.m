%{
# The physical location at which an session is performed or appliances
location                    : varchar(32)                   # 
---
system_type=null            : varchar(32)                   # 
ip_address=null             : varchar(15)                   # 
system_user=null            : varchar(32)                   # 
-> lab.AcquisitionType
location_description        : varchar(255)                  # 
bucket_default_path=null    : varchar(255)                  # 
imaging_bucket_default_path=null: varchar(255)              # 
ephys_bucket_default_path=null: varchar(255)                # 
%}

classdef Location < dj.Lookup
    properties
    end
end
