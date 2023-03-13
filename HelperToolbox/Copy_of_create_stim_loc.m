function create_stim_loc(VP,pa,whichLoc)
 begin = GetSecs;
% Goal: Create a more efficient stimulus generation by identifying the
% primary constraints in the process.

% We find a vector traveling towards the cyclopean eye that is centered at
% some u,v on the screen, or is parallel to this vector and within some arbitrary
% screen aperture:
% vec = [u, v, viewing_dist]

% This screen aperture should be defined by some circle with aperture center
% x0,y0:
% (x - x0)^2 + (y - y0)^2 = r^2

% Now, technically the front of all possible volumes are defined by our
% chosen disparity constraints, creating a disparity sphere/cylinder

% We need to determine where the screen aperture, which projects along a
% vector towards the cyclopean eye, intersects with this disparity cylinder.

% At this intersection point, the left and right eye projetions must be
% within the aperture.
% ---------------------------
% This defines all vectors we can use to create dots.
clear dotMatrix


            

               [VP.dstCenter(1), VP.dstCenter(2)] = pol2cart(d2r(pa.allPositions(1,1)), tand(pa.allPositions(1,2))*VP.screenDistance);

         ap =1;
        c = 1;   
                whichCon = repelem(repmat([1;2],pa.nRepBlock,1),pa.blockDuration*VP.frameRate);
        tme = 1/VP.frameRate:1/VP.frameRate:pa.blockDuration*2*pa.nRepBlock;
        switch whichLoc
    case 'mt'
  

        tmp = [];
        
        %
        for nn = 1:pa.blockDuration*VP.frameRate*2*pa.nRepBlock
            if whichCon(nn) == 1
                [x y] = pol2cart(pa.theta, pa.r'+pa.amp.*sin(ones(1,pa.numberOfDots).*pa.tf.*tme(nn)+pa.phi));
            else
                x = x;
                y = y;
            end
            tmp(ap,c,:,:,nn,1) = [x'+VP.dstCenter(1), x'+VP.dstCenter(1), y'+VP.dstCenter(2), repelem(pa.dotDiameter,size(x',1),1), repelem(pa.dotColor(1,:),size(x',1),1)];
        end
        dotMatrix.mt = squeeze(tmp(1,1,:,:,:));
        %dotMatrix.(char(whichLoc))=squeeze(tmp(1,1,:,:,:));
    case 'mst'
        %% MST

        tmp = [];
        
        %
        for nn = 1:pa.blockDuration*VP.frameRate*2*pa.nRepBlock
            if whichCon(nn) == 1
                [x y] = pol2cart(pa.theta, pa.r'+pa.amp.*sin(ones(1,pa.numberOfDots).*pa.tf.*tme(nn)+pa.phi));
            else
                x = x;
                y = y;
            end
            tmp(ap,c,:,:,nn,1) = [x'+VP.dstCenter(1), x'+VP.dstCenter(1), y'+VP.dstCenter(2), repelem(pa.dotDiameter,size(x',1),1), repelem(pa.dotColor(1,:),size(x',1),1)];
        end
        dotMatrix.mst = squeeze(tmp(1,1,:,:,:));
        
        
    otherwise
               
        
        pa.nOD = round(pa.numberOfDots/2);
        for dir = 1:2
            num_vecs = 10000;
            % Do this for each aperture if there are multiple defined
            for ap = 1:size(pa.allPositions,1)
                % Let's get a pool of 10,0000 vectors within our aperture
                
                [VP.dstCenter(1), VP.dstCenter(2)] = pol2cart(d2r(pa.allPositions(ap,1)), tand(pa.allPositions(ap,2))*VP.screenDistance);
                
                % Get dot x,y
                theta = 2*pi*rand(num_vecs,1); % Random thetas
                %theta = [2*pi*rand(num_vecs/2,1)/4;2*pi*rand(num_vecs/2,1)/4+0.5]; % Random thetas
                r = sqrt(rand(num_vecs,1))*tand(pa.screenAperture)*VP.screenDistance; % Random radii
                dots(:,1) = r.*cos(theta);
                dots(:,2) = r.*sin(theta);
                dots(:,3) = VP.screenDistance;
                % Now all of these dots have vectors that are offset by stimulus
                % location (VP.dstCenter)
                dots(:,1:2) = dots(:,1:2) + VP.dstCenter;
                
                % Do the same for the cd4cular condition since this will be different
                leftStereoX = tand(atand((dots(:,1) + VP.IOD/2)./VP.screenDistance)+(pa.disparityLimit/2)).*VP.screenDistance - VP.IOD/2;
                rightStereoX = tand(atand((dots(:,1) - VP.IOD/2)./VP.screenDistance)-(pa.disparityLimit/2)).*VP.screenDistance + VP.IOD/2;
                stereoY = dots(:,2);
                dL = sqrt((VP.dstCenter(1)-leftStereoX).^2 + (VP.dstCenter(2)-stereoY).^2); % distance from aperture center
                dR = sqrt((VP.dstCenter(1)-rightStereoX).^2 + (VP.dstCenter(2)-stereoY).^2); % distance from aperture center
                % grab the surviving dots
                % surviving_dots = find(~(dL > tand(pa.screenAperture)*VP.screenDistance | dR > tand(pa.screenAperture)*VP.screenDistance));
                surviving_dots = find(~(dL < tand(pa.centerPatch)*VP.screenDistance | dR < tand(pa.centerPatch)*VP.screenDistance | dL > tand(pa.screenAperture)*VP.screenDistance | dR > tand(pa.screenAperture)*VP.screenDistance));
                
                cd4_viable_dot_starts = dots(surviving_dots,:);
                
                %cd4_viable_dot_starts(cd4_viable_dot_starts(:,1)<2|cd4_viable_dot_starts(:,2)<2,:)=[];
                
                % Now we have a bank of viable dot starting positions. If these dots don't
                % exit at the front portion of the volume, then they will never exit the
                % aperture! Creat a huge matrix of all our different stimuli.
                
                % If we are using reverse phi, half need to be white and half black
                if pa.reversePhi == 1
                    pa.dotColor = [ones(ceil(pa.nOD/2),3); zeros(floor(pa.nOD/2),3)].*255;
                    pa.dotColor(:,4) = 255;
                else
                    pa.dotColor = [ones(ceil(pa.nOD),3)].*255;
                    pa.dotColor(:,4) = 255;
                end
                idxhalf = zeros(size(cd4_viable_dot_starts,1),2);
                idxhalf(:,1) = (cd4_viable_dot_starts(:,1)>0&cd4_viable_dot_starts(:,2)>0)|(cd4_viable_dot_starts(:,1)<0&cd4_viable_dot_starts(:,2)<0);
                idxhalf(:,2) = (cd4_viable_dot_starts(:,1)<0&cd4_viable_dot_starts(:,2)>0)|(cd4_viable_dot_starts(:,1)>0&cd4_viable_dot_starts(:,2)<0);
                cd4_viable_dot_starts(logical(idxhalf(:,dir)),:)=[];
                %% Use these valid starting positions to generate stimuli
                
                %% FST
                
               
                for c = 1:length(pa.coherence) % for each coherence
                    noise_dots = [];
                    signal_dots = [];
                    loopers = [];
                    pa.dots = [];
                    o= [];
                    for s = 1:pa.numberOfRepeats % create a stimulus for each block
                        % Get new dots for this stimulus
                        
                        newDots = datasample(cd4_viable_dot_starts,pa.nOD);
                        
                        pa.dots(:,1:3) = newDots;
                        pa.dots(:,4) = ones(pa.nOD,1); % just pick the direction (aribitrary since delta disp determines direction when making stimuli)
                        temp_disp = linspace(-pa.disparityLimit, pa.disparityLimit, pa.nOD+1);
                        temp_disp(end) = []; % remove last one
                        temp_disp = temp_disp + mean(diff(temp_disp))/2 + pa.deltaDisp; % center at 0, then account for the "first step" you'll take
                        
                        pa.dots(:,6) = temp_disp;
                        pa.dots(:,6) =ones(size(temp_disp))*0.3; % make it a plane 2/24
                        
                        
                        for nn = 1:pa.numFlips  % Loop through all the frames for this trial
                            
                            newDots = datasample(cd4_viable_dot_starts,pa.nOD);
                            pa.dots(:,1:3) = newDots;
                            
                            numCoherentDots = round((pa.coherence(c)*pa.nOD)); %get the number of coherent dots for this trial
                            pa.coherentDots = datasample([1:pa.nOD],numCoherentDots,'Replace',false); %pick which dots are signal dots
                            %Give signal dots a 5th index equal to 1, noise dots equal to 0
                            pa.dots(:,5) = 0;
                            pa.dots(pa.coherentDots,5) = 1;
                            
                            noise_dots = find(pa.dots(:,5) == 0);
                            signal_dots = find(pa.dots(:,5) == 1);
                            
                            % Update the disparity values and check for looping dots
                            pa.dots(:,6) = pa.dots(:,6) - pa.deltaDisp;
                            % are you looping?
                            loopers = find(abs(pa.dots(:,6)) > pa.disparityLimit);
                            
                            if ~isempty(loopers)
                                if pa.reversePhi == 1
                                    colors = pa.dotColor(loopers,1); % should be 0 or 1 now.
                                    b_colors = colors/255;
                                    colors = abs(b_colors -1).*255; % reverses the color
                                    pa.dotColor(loopers,1:3) = repmat(colors,1,3);
                                end
                                newDots = datasample(cd4_viable_dot_starts,length(loopers));
                                
                                pa.dots(loopers,1:3) = newDots;
                                residual = abs(pa.dots(loopers,6)) - pa.disparityLimit;
                                pa.dots(loopers,6) = pa.disparityLimit - residual; % place you on the edge + remaining distance
                            end
                            
                            if ~isempty(noise_dots)
                                % Grab new dots for the noise dots -- changes every frame
                                newDots = datasample(cd4_viable_dot_starts,length(noise_dots));
                                
                                pa.dots(noise_dots,1:3) = newDots;
                                pa.dots(noise_dots,6) = pa.disparityLimit*2*rand(length(noise_dots),1) - pa.disparityLimit; % give a random disparity to these dots
                            end
                            
                            pa.dots(:,3) = VP.screenDistance;
                            leftStereoX = tand(atand((pa.dots(:,1) + VP.IOD/2)./VP.screenDistance)+pa.dots(:,6)./2).*VP.screenDistance - VP.IOD/2;
                            rightStereoX = tand(atand((pa.dots(:,1) - VP.IOD/2)./VP.screenDistance)-pa.dots(:,6)./2).*VP.screenDistance + VP.IOD/2;
                            stereoY = pa.dots(:,2);
                            pa.dotDistance = pa.dots(:,3);
                            dotPixelSize = pa.dotDiameter.* VP.screenDistance./pa.dots(:,3); %include monocular size cue
                            
                            dot_mat = [leftStereoX,rightStereoX, stereoY, dotPixelSize, pa.dotColor];
                            % We have the dots for this frame, now we just need to save them.
                            dotMatrix.cd4(ap,c,:,:,nn,s) = dot_mat;
                            
                        end
                        
                    end
                end
                
                
                
            end
            
            
            if dir ==1
                tmp=dotMatrix;
            else
                
                dotMatrix.cd1 = cat(3,tmp.cd4,dotMatrix.cd4);
                dotMatrix.cd4 = flip(dotMatrix.cd4,5);
                dotMatrix.cd4 = cat(3,tmp.cd4,dotMatrix.cd4);
                
            end
            
            dotMatrix.cd0 = dotMatrix.cd4;
            dotMatrix.cd0 = dotMatrix.cd0(:,:,:,:,randperm(size(dotMatrix.cd0, 5)),:);
            
        end
        
        %% FST
        condition = {'cd1','cd4'};
        for iCon = 1:2
            stim = [];
            for ii = 1:size(pa.design,1)
                pa.trial = pa.design(ii,:); % Get this trial's parameters
                rand_stim = randi([1,pa.numberOfRepeats]);
                if pa.trial(5) ==1
                    pa.current_condition = char(condition(iCon));
                else
                    pa.current_condition = 'cd0';
                end
                tmp = squeeze(dotMatrix.(char(pa.current_condition))(pa.trial(1),pa.trial(4),:,:,:,rand_stim));
                if pa.trial(3) == 1
                    tmp = flip(tmp,3);
                end
                stim = cat(3,stim,tmp);
            end
            dotMatrix.(char(condition(iCon))) = stim;
        end
end


%%

save('DotBank.mat','dotMatrix','-v7.3');
gen_time = GetSecs - begin;

end
