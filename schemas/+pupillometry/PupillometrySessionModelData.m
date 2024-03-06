%{
# # Table for pupillometry data (pupil diameter)
->pupillometry.PupillometrySessionModel
---
pupillometry_job_id=null:    int               # SLurm Job id for this processing
pupil_diameter+null:         longblob          # array with pupil diameter for each video frame
%}

classdef PupillometrySessionModelData < dj.Imported
    
    methods(Access=protected)
        
        function makeTuples(self, key)

        insert(self, key)

        end
    
    end
    
    methods
 
     function restart_pupillometry_failed_job(self, key)
         % Restart session pupillometry processing
         
        current_job_id = fetch1(self & key, 'pupillometry_job_id');
        
        if current_job_id == -1
            % Restart job id to NULL
            update(self & key, 'pupillometry_job_id')
            % Set NULL blob of pupil diameter
            update(self & key, 'pupil_diameter')
        end
            
     end
     
     function pupillometry_jobs = check_status_pupillometry_jobs(self, key)
         % Fetch status for sessions queried by key (all if no key is provided)
         
        keys_fetch = self.primaryKey;
        keys_fetch{end+1} = 'pupillometry_job_id';
         
        if nargin < 2
            pupillometry_jobs = fetch(self, keys_fetch{:});
        else
            pupillometry_jobs = fetch(self & key, keys_fetch{:});
        end
        
        pupillometry_jobs = struct2table(pupillometry_jobs,  'AsArray', true);
        
        pupillometry_jobs.STATUS = repmat({'FAILED'},size(pupillometry_jobs,1),1);
        
        idx = isnan(pupillometry_jobs.pupillometry_job_id);
        pupillometry_jobs.STATUS(idx) = {'NOT STARTED'};
        
        idx = (pupillometry_jobs.pupillometry_job_id > 0);
        pupillometry_jobs.STATUS(idx) = {'RUNNING/FINISHED'};

     end
     
     function pupillometry_finished_jobs = get_finished_jobs_pupillometry(self)
          % Get all sessions that successfully were processed
         
      query = "pupillometry_job_id > 0 and pupil_diameter is not null";
          
      keys_fetch = self.primaryKey;
         
      pupillometry_finished_jobs = fetch(self & query , keys_fetch{:});
        

     end
     
            
    end
    
end

