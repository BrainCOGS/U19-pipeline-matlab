

psm = pupillometry.PupillometrySessionModel();
keys = fetch((pupillometry.PupillometrySession - pupillometry.PupillometrySessionModel()), 'ORDER BY session_date DESC');

for i=1:length(keys)
    
    if i> 20
        break
    end
        psm.insertDefaultSessionModel(keys(i))
end
%populate(pupillometry.PupillometrySessionModelData)
 for i=1:length(keys)
     
     if i> 20
         break
     end
 populate(pupillometry.PupillometrySessionModelData, keys(i))
 end