function pa = UpdateParameters_mst(VP,pa,LR)

% 10/25/2022 less dots, no fixation during stimulus, check disparity

rng('shuffle'); % shuffle the random number generator seeds so you don't repeat!
%rng('default');
%% Stimulus Parameters
% These are the locations of the stimuli
thetas = (LR-1)*180;    %,180,270                                                       % Polar angle(s) of stimulus
pa.thetaDirs = thetas;                                                           % Polar angle(s) of circle
pa.rDirs = 7;                                                              % Eccentricity of circle
radius_stim = 7;                                                            % Eccentricity of stimulus
pa.stimX_deg = radius_stim*cosd(thetas);                                 
pa.stimY_deg = radius_stim*sind(thetas);
pa.screenAperture = 20;                                             % stimulus size radius
pa.borderPatch = 20.5;                                                % aperture size radius
pa.centerPatch = 13;                                    % fixation aperture size radius
pa.numberOfDots = 100;     %22                                                 % number of dots

pa.numberOfRepeats = 5;                                             % number of blocks to complete
pa.nRepBlock = 2;                                                       % number of repeats per block
pa.trialDuration = 1;                                                      % duration of stimulus
pa.ITI = 0;                                                                % duration between stimuli
pa.numberOfBlanks = 0; %
pa.blockDuration = pa.numberOfRepeats*pa.trialDuration*2;   
pa.endDur = 21; % blank screen time at the end
pa.fixationAcqDura = 0;                                                    % duration of fixation prior to stimulus
pa.disparityLimit = 0.3;  %1                                               % using the same front and back disparity, what is the limit?
pa.loops = 1;   % 1                                                           % # of times dots travel the volume (determines speed)
pa.reversePhi = 0;                                                         % dots change color on wrapping to reduce apparent motion
pa.directions = [-1 1];                                                    % experiment directions (+1:towards, -1:away)
pa.coherence = 1;                                                          % Motion coherence levels
pa.conditionNames   = {'cd4','cd0'};          % Stimulus conditions
pa.photo_align = 0;
if VP.stereoMode == 1
    pa.numFlips = floor(pa.trialDuration*VP.frameRate/2);                  % every other frame for each eye when in interleaved stereo mode
else
    pa.numFlips = floor(pa.trialDuration*VP.frameRate);                    % each frame to both eyes
end

[pTH,pR] = cart2pol(pa.stimX_deg, pa.stimY_deg);
pTH = -rad2deg(pTH);
if pTH < 0
    pTH = 360 + pTH;
end
pa.allPositions = [pTH; pR]';


% MST params
pa.tf = 4; % temporal frequency
pa.amp = 0.15*VP.pixelsPerDegree; % determines speed
pa.phi = 2*pi*rand(1,pa.numberOfDots); % random phi 
rmin = tand(pa.centerPatch)*VP.screenDistance+pa.amp; 
rmax = tand(pa.borderPatch)*VP.screenDistance-pa.amp;
aa=[0 180]; 
pa.theta = (aa(~ismember(aa,thetas))-60+120*rand(1,pa.numberOfDots))/180*pi;
pa.theta(pa.theta>pi) = pa.theta(pa.theta>pi)-2*pi;
pa.r = (((rmax - rmin) .* (rand(1,pa.numberOfDots))) + rmin)';
pa.phi = 2*pi*rand(1,pa.numberOfDots);


end






