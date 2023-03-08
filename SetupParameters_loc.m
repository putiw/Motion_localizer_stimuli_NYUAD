function pa = SetupParameters_loc(VP)

% 10/25/2022 less dots, no fixation during stimulus, check disparity

rng('shuffle'); % shuffle the random number generator seeds so you don't repeat!
%rng('default');
%% Stimulus Parameters
% These are the locations of the stimuli
thetas = 45;    %,180,270                                                       % Polar angle(s) of stimulus
pa.thetaDirs = thetas;                                                           % Polar angle(s) of circle
pa.rDirs = 0;                                                              % Eccentricity of circle
radius_stim = 0;                                                            % Eccentricity of stimulus
pa.stimX_deg = radius_stim*cosd(thetas);                                 
pa.stimY_deg = radius_stim*sind(thetas);
pa.screenAperture = 4.5;                                              % stimulus size radius
pa.borderPatch = 5;                                                  % aperture size radius
pa.centerPatch = 0.25;                                               % fixation aperture size radius
pa.numberOfDots = 100;     %22                                                 % number of dots

pa.numberOfRepeats = 5;                                             % number of blocks to complete
pa.nRepBlock = 15;                                                       % number of repeats per block
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


% MT params
pa.tf = 4; % temporal frequency
pa.amp = 0.15*VP.pixelsPerDegree; % determines speed
pa.phi = 2*pi*rand(1,pa.numberOfDots); % random phi 
pa.angle = 360*pi/180; % in radians
rmin = tand(pa.centerPatch*3)*VP.screenDistance+pa.amp; 
rmax = tand(pa.screenAperture)*VP.screenDistance-pa.amp;
pa.theta = (pa.angle .* rand(1,pa.numberOfDots))';
pa.r = (((rmax - rmin) .* (rand(1,pa.numberOfDots))) + rmin)';
pa.phi = 2*pi*rand(1,pa.numberOfDots);

%% Dot Parameterss
pa.fixationRadius   = 0.6; %0.7;    (in ???)
pa.fixationDotSize  = 7; %4;                    % fixation dot size (in pixels)
pa.saccadeDotSize = 12; %in pixels
pa.fixationDotColor  = [0 0 0]; % red
pa.dotDiameterinDeg = 0.15; %0.2
pa.dotDiameter = pa.dotDiameterinDeg * VP.pixelsPerDegree;
pa.dotColor = [255, 255, 255, 255]; % white
pa.dotSpacing = (pa.dotDiameterinDeg*1.5)/VP.degreesPerMm;  % in mm since dots are in mm

%% Initial dot motion calculations
% What is the rate at which the disparity must change?
pa.deltaDisp = pa.disparityLimit*2*pa.loops/(pa.trialDuration*VP.frameRate);%pa.disparityLimit*2*pa.loops/(VP.frameRate/2);  %pa.disparityLimit*2*pa.loops/(pa.trialDuration*VP.frameRate/2);
% Maximum depth extent (to calc the rear radius and max dot size)
xLocFixationPoint = 0;
ConvergenceAngleFixation = atand(((VP.IOD/2)+xLocFixationPoint)/VP.screenDistance) + atand(((VP.IOD/2)-xLocFixationPoint)/VP.screenDistance); %left eye + right eye
f = @(xDepth) abs(((atand((VP.IOD/2)/(xDepth)) + atand((VP.IOD/2)/(xDepth))) - ConvergenceAngleFixation)-pa.disparityLimit);
[X,FVAL] = fminsearch(@(xDepth) f(xDepth), VP.screenDistance);%, ops); % Finds a minimum of the anonymous function evaluated at xDepth and near the screen
pa.RetrievedDepth(1) = X; % Relative to the screen, which is Z = 0;
f = @(xDepth) abs(((atand((VP.IOD/2)/(xDepth)) + atand((VP.IOD/2)/(xDepth))) - ConvergenceAngleFixation)-(-pa.disparityLimit));
[X,FVAL] = fminsearch(@(xDepth) f(xDepth), VP.screenDistance);%, ops); % Finds a minimum of the anonymous function evaluated at xDepth and near the screen
pa.RetrievedDepth(2) = X; % Relative to the sscreen, which is Z = 0;
pa.depthExtent = abs(pa.RetrievedDepth(2) - pa.RetrievedDepth(1));
pa.dz = pa.depthExtent*pa.loops/(pa.trialDuration*VP.frameRate); %.*pa.modeConstant); % (in mm)

%% Design Structure
pa.exp_mat = [size(pa.allPositions,1) 1 length(pa.directions) length(pa.coherence) length(pa.conditionNames)]; % last index is for stimulation. 1 = no. 2 = yes
pa.repeat_design = fullfact(pa.exp_mat); 
% Remove the extra 0's if we have 0% coherence
if ismember(0,pa.coherence)
    extraZeroEntries = find(~(pa.repeat_design(:,4) == 1 & pa.repeat_design(:,3) == 2));
    pa.repeat_design = pa.repeat_design(extraZeroEntries,:);
end

% Repeat the trial structure with random permutations in each block
pa.design = [];
    for iCue = 1:length(pa.conditionNames)
        for r = 1:pa.numberOfRepeats
            pa.temp_design = pa.repeat_design(iCue*2-1:2*iCue,:);
            %pa.temp_design = pa.repeat_design(randperm(size(pa.repeat_design,1)),:);
            pa.design = [pa.design; pa.temp_design];
        end
    end
pa.design = repmat(pa.design,pa.nRepBlock,1);

pa.repeats_completed = 0;
pa.numberOfTrials = size(pa.design,1);

pa.totalFrames = size(pa.design,1)* (pa.ITI+pa.trialDuration)*VP.frameRate;
pa.fn = [];

% time, block, task resp,response
pa.timeStamps = [zeros(1,pa.totalFrames); repelem(repmat([1;2],pa.nRepBlock,1),pa.blockDuration*pa.numFlips,1)'; ...
    zeros(1,pa.totalFrames);nan(1,pa.totalFrames)]';


min_num = 5*pa.numFlips;
max_num = pa.totalFrames-5*pa.numFlips;

% Generate a random permutation of the indices in the range
idx = randperm(max_num-min_num+1) + min_num - 1;

% Select the first 5 indices that are at least 300 apart from each other
selected_numbers = idx(diff([0 idx]) >= 300);
pa.selected_numbers = selected_numbers(1:5);

rand_nums = rand(1, 10)*(800-200) + 200;

repetition_counts = round(rand_nums / sum(rand_nums) * pa.totalFrames);
original_vector = repmat([1;0],5,1);
new_vector = [];
% Loop through each element of the original vector and repeat it
for i = 1:length(original_vector)
    % Repeat the current element according to the corresponding repetition count
    new_elements = repmat(original_vector(i), 1, repetition_counts(i));
    % Append the new elements to the new vector
    new_vector = [new_vector; new_elements'];
end

pa.timeStamps(1:numel(new_vector),3)=new_vector;


%% Savefile parameters
pa.subjectName = 'Jim';
pa.movie = 0;
pa.screenDump = 0; % Get Image?
pa.baseDir = pwd;



