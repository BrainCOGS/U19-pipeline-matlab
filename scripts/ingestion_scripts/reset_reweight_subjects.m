function reset_reweight_subjects()

reset_reweight_subjects_query = 'update u19_subject.subject set need_reweight=0';
curr_conn = dj.conn();
curr_conn.query(reset_reweight_subjects_query);

end

