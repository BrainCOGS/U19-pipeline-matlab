function resubmit_failed_jobs(subject_fullname)

% Resubmit failed jobs for a given subject
if nargin < 1 || isempty(subject_fullname)
    error('subject_fullname must be provided');
end

query_sub.subject_fullname = subject_fullname;
query_sub.status_processing_id = -1;

conn = dj.conn();

query_sub.subject_fullname='jk8386_jk71';
query_sub.status_processing_id=-1;
ta = fetch(recording_process.Processing * ...
    recording.Recording * ...
    recording.RecordingBehaviorSession * ...
    proj(subject.Subject) ...
    & query_sub);

try
    conn.startTransaction();

    for job = [ta.job_id]
        query_job.job_id = job;

        log_status_record.job_id = job;
        log_status_record.status_processing_id_old = -1;
        log_status_record.status_processing_id_new = 0;
        log_status_record.status_timestamp = datestr(now, 'yyyy-mm-dd hh:MM:ss');
        log_status_record.error_message = 'Rerun of job has started';

        update(recording_process.Processing & query_job, 'status_processing_id', 0);
        insert(recording_process.LogStatus, log_status_record);

    end

    conn.commitTransaction


catch err
    conn.cancelTransaction
        %error(err.message);

end