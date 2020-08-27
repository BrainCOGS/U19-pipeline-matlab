function isSpock = is_this_spock()

if ((~contains(pwd,'smb')           || ...
    ~contains(pwd,'usr/people')     || ...
    ~contains(pwd,'jukebox'))          ...
    && ~ispc && ~ismac ) 
    
  isSpock = true;
  
else
  
  isSpock = false;
  
end
