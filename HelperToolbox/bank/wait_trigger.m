function [VP kb] = wait_trigger(display,kb,VP)

Screen('SelectStereoDrawbuffer', VP.window, 0);
Screen('DrawTexture', VP.window, VP.bg(VP.curBg));
Screen('DrawText', VP.window, 'Waiting for trigger...',VP.Rect(3)./2+VP.centerX-95,VP.Rect(4)/2,[VP.whiteValue VP.whiteValue VP.whiteValue]);

Screen('SelectStereoDrawbuffer', VP.window, 1);
Screen('DrawTexture', VP.window, VP.bg(VP.curBg));
Screen('DrawText', VP.window, 'Waiting for trigger...',VP.Rect(3)./2+VP.centerX-95,VP.Rect(4)/2,[VP.whiteValue VP.whiteValue VP.whiteValue]);

VP.vbl = Screen('Flip', VP.window, [], 0);


%waiting for trigger
switch display
    case 1 %nyuad
        Datapixx('RegWrRd');
        triggerStart = dec2bin(Datapixx('GetDinValues'));
        kb.keyIsDown = 0;
        while ~kb.keyIsDown
            if VP.debugTrigger == 0
                [kb,~] = CheckTrigger_MRI(kb,triggerStart); % if response with response button MRI
            else
                [kb,~] = CheckTrigger_MRI(kb,triggerStart); % by scanner
                [kb,~] = CheckKeyboard(kb); % by hand
            end
            
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