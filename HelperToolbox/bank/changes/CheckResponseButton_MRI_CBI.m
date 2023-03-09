function [kb,stop] = CheckResponseButton_MRI_CBI(kb)

% poll the response button (MRI) for a response 
stop = 0;
% Datapixx('RegWrRd');
% kbchk = dec2bin(Datapixx('GetDinValues'));
[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1); % for checking escape %(kb.ID)

% check the response button
% % scanner
if kb.keyCode(kb.threeKey) % - green button or away / far
    kb.resp = 2;
    kb.keyIsDown = 1;
elseif kb.keyCode(kb.fourKey) %  - red button or towards / near
    kb.resp = 1;
    kb.keyIsDown = 1;
elseif kb.keyCode(kb.escKey) || kb.keyCode(kb.qKey) % esc/q key, quit
    stop =1;
else
end
end