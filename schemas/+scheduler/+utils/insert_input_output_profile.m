function insert_input_output_profile(iop1, iopl1)


%Insert the corresponding records
conn = dj.conn;
conn.startTransaction()
try
     insert(scheduler.InputOutputProfile, iop1);
     insert(scheduler.InputOutputProfileList, iopl1);
     conn.commitTransaction
catch err
    conn.cancelTransaction
    disp(err);
end
pause(1);