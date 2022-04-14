function data = get_recording_processing_info(recording_process_list)

string_rec_process = string(recording_process_list);
string_rec_process = char(strjoin(string_rec_process, ", "));

query = ['recording_process_id in (' string_rec_process ')'];

rec_schema = recording.getSchema;
data = fetch(rec_schema.v.Recording * rec_schema.v.RecordingProcess & query,'*');