function [VP kb] = wait_trigger(display,kb,VP)

Screen('SelectStereoDrawbuffer', VP.window, 0);
Screen('DrawTexture', VP.window, VP.bg(VP.curBg));
Screen('DrawText', VP.window, 'Waiting for trigger...',VP.Rect(3)/2-95,VP.Rect(4)/2);

Screen('SelectStereoDrawbuffer', VP.window, 1);
Screen('DrawTexture', VP.window, VP.bg(VP.curBg));
Screen('DrawText', VP.window, 'Waiting for trigger...',VP.Rect(3)/2-95,VP.Rect(4)/2);

VP.vbl = Screen('Flip', VP.window, [], 0);


%waiting for trigger
switch display
    case 1 %nyuad
        kb.keyIsDown = 0;
        while ~kb.keyIsDown
            [kb,~] = CheckTrigger_MRI(kb); % if response with response button MRI
            [kb,~] = CheckKeyboard(kb); % if response with keyboard
            
        end
    case 2 %puti laptop
        kb.keyIsDown = 0;
        pause(0.3)
        while kb.keyIsDown == 0;
            [kb,~] = CheckKeyboard(kb); % if response with keyboard
        end
    case 3 %cbi
        kb.keyIsDown = 0;
        pause(0.5)
        while ~kb.keyIsDown
            [kb,~] = CheckTrigger_MRI_CBI(kb); % if response with response button MRI
            [kb,~] = CheckKeyboard(kb); % if response with keyboard
            fprintf('>>>>>>>>>>> waiting for the trigger from the scanner.... \n')
        end
        fprintf('>>>>>>>>>>> trigger detected \n')
end



end