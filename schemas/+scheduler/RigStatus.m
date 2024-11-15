%{
# Status for each IO module of the rig
-> lab.Location                    
-> scheduler.InputOutputRig       
---
current_status                     : enum("OK", "Not OK")           # if module is working or not  
-> [nullable] scheduler.RigIOTechReport                             # reference to tech report from RigTesterGUI
last_status_update                 : datetime                       # at what time status changed
%}

classdef RigStatus < dj.Manual
    properties
    end


    methods (Static)

        function insertNewRigs_and_IOs()

            rigs = struct2table(fetch(lab.Location & "system_type='rig'"));
            rigs.key = ones(height(rigs),1);
            ios  = struct2table(fetch(scheduler.InputOutputRig));
            ios.key = ones(height(ios),1);
            rigs_ios = outerjoin(rigs,ios,'MergeKeys',true);
            rigs_ios = rigs_ios(:,{'location', 'input_output_name'});
            rigs_ios.current_status = repmat('OK',height(rigs_ios),1);
            rigs_ios.last_status_update = repmat(char(datetime('now','Format','uuuu-MM-dd HH:mm:ss')),height(rigs_ios),1);
            rigs_ios = table2struct(rigs_ios);

            insert(scheduler.RigStatus, rigs_ios, 'IGNORE');

        end






    end


    

end
