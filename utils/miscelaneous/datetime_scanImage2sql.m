function date_out = datetime_scanImage2sql(date_in)

% date_out = datetime_scanImage2sql(date_in)
% converts to SQL datetime format from scan image header

fullLength = numel(date_in);
spaces     = [0 regexp(date_in,' ') fullLength];

% sometimes there are two consecutive spaces
isConsec = [0 diff(spaces)];
if any(isConsec == 1)
  idx        = spaces(isConsec==1);
  for iSpace = 1:numel(idx)
    date_in  = [date_in(1:idx(iSpace)-1) date_in(idx(iSpace)+1:end)];
    idx      = idx -1;
  end       
  fullLength = numel(date_in);
  spaces     = [0 regexp(date_in,' ') fullLength];
end

date_out   = '';
  
for iEntry = 1:numel(spaces)-1
  if iEntry < 3
    date_out = [date_out date_in(spaces(iEntry)+1:spaces(iEntry+1)-1) '-'];
  elseif iEntry == 3
    date_out = [date_out date_in(spaces(iEntry)+1:spaces(iEntry+1)-1) ' '];
  elseif iEntry == numel(spaces)-1
    date_out = [date_out date_in(spaces(iEntry)+1:spaces(iEntry+1)-1)];
  else
    date_out = [date_out date_in(spaces(iEntry)+1:spaces(iEntry+1)-1) ':'];
  end
end