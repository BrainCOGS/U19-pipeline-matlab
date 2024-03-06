

% Ingest missing PupillometrySessionModel (with default model)
keys = fetch((pupillometry.PupillometrySession - pupillometry.PupillometrySessionModel()), 'ORDER BY session_date DESC');


%Ingest max 20 sessions to process for PupillometrySessionModel
psm = pupillometry.PupillometrySessionModel();
for i=1:length(keys)
    
    if i> 20
        break
    end
        psm.insertDefaultSessionModel(keys(i))
end
%Ingest max 20 sessions to process for PupillometrySessionModelData (to start processing)
 for i=1:length(keys)
     
     if i> 20
         break
     end
 populate(pupillometry.PupillometrySessionModelData, keys(i))
 end