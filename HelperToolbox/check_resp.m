function [pa, kb, OnGoing] = check_resp(OnGoing,fn,pa,display,kb)

switch display
    case 1
        [kb,stop] = CheckResponseButton_MRI(kb); % if response with response button MRI
        % pa.response(pa.trialNumber,:) = kb.resp;
        pa.timeStamps(fn,4)= kb.resp;
    case 2
        
        [kb,stop] = CheckKeyboard(kb);
        pa.timeStamps(fn,4)= kb.resp;
    case 3
        [kb,stop] = CheckResponseButton_MRI_CBI(kb); % if response with response button MRI
        pa.timeStamps(fn,4)= kb.resp;
        %  pa.response(pa.trialNumber,:) = kb.resp;
        
end

if stop == 1
    OnGoing = 0;
end


end