% Be careful using this script.
% It should only be used for animals so old, that the mouse db is incomplete


%% connect to the database
setenv('DJ_HOST', '127.0.0.1')
setenv('DJ_USER', '')
setenv('DJ_PASS', '')
dj.conn()

%% construct a new subject and add to the database
key_subject.subject_id = 'E22';
key_subject.sex = 'Unknown';
key_subject.user_id = 'edward';  %This has to be a user in the database!
key_subject.location = 'valhalla'
key_subject.protocol = '1910';

% if needed: 
% del(subject.Subject & ['subject_id = "', key_subject.subject_id, '"'])

insert(subject.Subject, key_subject);

%% snippet to recursively navigate through code.
base_dir = '/Volumes/braininit/RigData/training/';
pattern = key_subject.subject_id;
list1 = RecFindFiles(base_dir, pattern, {}, 7);
base_dir2 = '/Volumes/braininit/RigData/scope/bay3/';
list2 = RecFindFiles(base_dir2, pattern, {}, 7);
listfile_final = [list1, list2];

%% Find all sessions already in the database
session_date = fetchn(acquisition.Session & ['subject_id = "', pattern, '"'], 'session_date')';
missing_sessions = {};
counter_allfiles = 0;
counter_knownfiles = 0;
for fi = listfile_final
    file = string(fi{1});
    if length(strfind(file,".fig")) == 0        % If not a .fig file
        if length(strfind(file,"trash")) == 0   % If not "trash"   WHAT ABOUT NpHR?
            if length(strfind(file,"NpHR")) == 0% No inhibition experiments
                unknown_flag = true;
                for sd = session_date
                    if strfind(file, regexprep(sd,'-',''))
                        unknown_flag = false;
                        counter_knownfiles = counter_knownfiles + 1;
                    end
                end
                if unknown_flag 
                    disp(file)
                    missing_sessions{end+1} = file;
                end
                counter_allfiles = counter_allfiles + 1;
            end
        end
    end
end
if (counter_allfiles - counter_knownfiles) ~= length(missing_sessions)
    error("Something is missing")
end


%% go through all session, rearrange into struct, and insert into database
for fil = missing_sessions
    load (string(fil))

    key_session = fetch(subject.Subject & ['subject_id = "', pattern, '"']);
    key_session.session_date = sprintf('%d-%02d-%02d', log.session.start(1), log.session.start(2), log.session.start(3));
    key_session.session_start_time = sprintf('%d-%02d-%02d %2d:%2d:00', log.session.start(1), log.session.start(2), log.session.start(3), log.session.start(4), log.session.start(5))
    key_session.session_end_time = sprintf('%d-%02d-%02d %2d:%2d:00', log.session.end(1), log.session.end(2), log.session.end(3), log.session.end(4), log.session.end(5))
    key_session.level = log.block.mainMazeID;
    key_session.stimulus_bank = log.block.stimulusBank;
    key_session.stimulus_set = log.block.stimulusSet;
    key_session.task = 'Towers';
    key_session.location = log.version.rig.rig;
    correct_number = 0;
    counter = 0;
    for block_idx = 1:length(log.block)
        trialstruct = log.block(block_idx);
        for itrial = 1:length(trialstruct.trial)
            trial = trialstruct.trial(itrial);
            correct_number = correct_number + strcmp(trial.trialType.char, trial.choice.char);
            counter = counter + 1;
        end
    end
    key_session.session_performance = correct_number / counter;
    key_session.set_id = 1;
    key_session.ball_squal = NaN;

    %and insert this session:
    inserti(acquisition.Session, key_session)
end


%% pump into database and populate
% 
[keys_dir, errors_dir] = populate(acquisition.DataDirectory);
[keys_block, errors_block] = populate(acquisition.TowersBlock);



