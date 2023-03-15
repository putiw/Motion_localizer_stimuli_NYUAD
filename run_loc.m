function [VP, pa] = run_loc(whichLoc)

PsychDefaultSetup(2);
display = 1; % 1-AD % 2-laptop % 3-NY
if nargin < 1 || isempty(whichLoc) % pick left mt by default given empty
     whichLoc = 'mt'; 
elseif strcmp(whichLoc, 'mst') % pick left mst by default given mst
     whichLoc = 'mstL';
end

addpath(genpath('HelperToolbox'));
filename = get_info(whichLoc);
%% Setup parameters and viewing geometry
data = [];
global GL; % GL data structure needed for all OpenGL demos
backGroundColor = [0 0 0]; %[0.5 0.5 0.5].*255; % Gray-scale - calibrate for display so white and black dots have same contrast with background
skipSync = 1; % skip Sync to deal with sync issues (should be for debugging only)
VP = SetupDisplay_loc(skipSync, backGroundColor, display,whichLoc);
if VP.stereoMode == 8 && display ~=2
    Datapixx('SetPropixxDlpSequenceProgram',1); % 1 is for RB3D mode, 3 for setting up to 480Hz, 5 for 1440Hz
    Datapixx('RegWr');    
    Datapixx('SetPropixx3DCrosstalkLR', 0); % minimize the crosstalk
    Datapixx('SetPropixx3DCrosstalkRL', 0); % minimize the crosstalk
end

VP.backGroundColor = backGroundColor;
priorityLevel=MaxPriority(VP.window);
Priority(priorityLevel);

pa = SetupParameters_loc(VP);
if strcmp(whichLoc, 'mstR') || strcmp(whichLoc, 'mstL') 
    pa = UpdatePa_mst(VP,pa,whichLoc); % need to update parameters for mst
end

pa.response = zeros(pa.numberOfTrials,1);
kb = SetupKeyboard();
pa.trialNumber = 0;
fn = 1; %Frame 1
dontClear = 0;

kb = SetupKeyboard();
VP = MakeTextures(pa,VP);

%% Generate new dot matrices for quick drawing rather than doing the calculations between frames

Screen('SelectStereoDrawbuffer', VP.window, 0);
Screen('DrawText', VP.window, 'Preparing Experiment...',VP.Rect(3)/2-130,VP.Rect(4)/2);
Screen('SelectStereoDrawbuffer', VP.window, 1);
Screen('DrawText', VP.window, 'Preparing Experiment...',VP.Rect(3)/2-130,VP.Rect(4)/2);
VP.vbl = Screen('Flip', VP.window, [], dontClear);

create_stim_loc(VP,pa,whichLoc);
load('DotBank.mat')
pa.current_stimulus = dotMatrix.(char(whichLoc));

StateID = 0;
OnGoing = 1;
skip = 0;
GetSecs; KbCheck;
kbIdx = GetKeyboardIndices;

whichFn = 1;
positions   = allcomb(d2r(pa.thetaDirs), pa.rDirs.*VP.pixelsPerDegree );
[centerX, centerY]     = pol2cart(positions(:,1), positions(:,2));
%% Experiment Starts
while ~kb.keyCode(kb.escKey) && OnGoing
    
    %% States control the experimental flow (e.g., inter trial interval, stimulus, response periods)
    switch StateID
        case 0
            
            % waiting for trigger
            
            [VP kb] = wait_trigger(display,kb,VP)
            
            fn = 1;
            StateID = 1; % send to fixation point
            
        case 1 % Begin drawing stimulus
            
            
            
            %%
         
             
            %%
            colors = pa.current_stimulus(:,5:7,fn);
            
            for view = 0:1 %VP.stereoViews
                Screen('SelectStereoDrawbuffer', VP.window, view);
                pa.dotPosition = [pa.current_stimulus(:,view+1,fn), pa.current_stimulus(:,3,fn)].*VP.pixelsPerMm;
                Screen('DrawDots',VP.window, pa.dotPosition', pa.current_stimulus(:,4,fn), colors', [VP.Rect(3)/2, VP.Rect(4)/2], 2);
                Screen('DrawTexture', VP.window, VP.bg(VP.curBg));
                
                
                if pa.timeStamps(whichFn,3) == 1
                    Screen('DrawText', VP.window,'o',VP.Rect(3)./2+centerX-7.1,VP.Rect(4)/2-7);
                else
                    Screen('DrawText', VP.window,'+',VP.Rect(3)./2+centerX-7.1,VP.Rect(4)/2-7);
                end
                
                
            end
            
            VP.vbl = Screen('Flip', VP.window, [], dontClear); % Draw frame
            
            if fn == 1 && skip == 0 % get time of very first frame and use this as an absolute reference 
                pa.firstFrame = VP.vbl;
                skip = 1;
                pa.timeStamps(whichFn,1) = GetSecs - pa.firstFrame; % time so far
            else
                pa.timeStamps(whichFn,1) = GetSecs - pa.firstFrame;
                fn = round(pa.timeStamps(whichFn,1)/(1/VP.frameRate)); % which frame should it be now
                pa.fn(whichFn,1) = fn;
            end
            
            % end experiment if time so far is longer than what it's supposed to be           
            if (pa.timeStamps(whichFn,1)>=size(pa.current_stimulus,3)*(1/pa.numFlips))||fn>=size(pa.current_stimulus,3)
                pause(pa.endDur)
                OnGoing = 0; % End experiment
                break;
            end
            
            whichFn = whichFn +1;
            
    end
    
    % record response 
    [pa, kb, OnGoing] = check_resp(OnGoing,fn,pa,display,kb);
    
end

%% Save your data

save(filename,'pa','VP');

%% Clean up
RestrictKeysForKbCheck([]); % Reenable all keys for KbCheck:
ListenChar; % Start listening to GUI keystrokes again
ShowCursor;
clear moglmorpher;
Screen('CloseAll');%sca;
clear moglmorpher;
Priority(0);
if VP.stereoMode == 8 && display ~=2
    Datapixx('SetPropixxDlpSequenceProgram',0);
    Datapixx('RegWrRd');
end
Datapixx('Close');

end