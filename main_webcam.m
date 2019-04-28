clc;
clear all;
close all;
warning off
%%
% Delete webcam object if it is already accessing the camera
delete(imaqfind)

% Create the objects for the color and depth sensors.
% Device 1 is the color sensor and Device 2 is the depth sensor.
vid = videoinput('kinect',1);
vid2 = videoinput('kinect',2);

% Get the source properties for the depth device.
srcDepth = getselectedsource(vid2);

% set tracking mode to skeleton
set(srcDepth,'TrackingMode','Skeleton')

% Set the frames per trigger for both devices to 1.
vid.FramesPerTrigger = 1;
vid2.FramesPerTrigger = 1;

% Set the trigger repeat for both devices to 200, in
% order to acquire 201 frames from both the color sensor and the depth sensor.
vid.TriggerRepeat = 5000;
vid2.TriggerRepeat = 5000;

% Configure the camera for manual triggering for both sensors.
triggerconfig([vid vid2],'manual');

% Start both video objects.
start([vid vid2]);

% Initialise empty vector to store right hand x values
Rp = zeros(1,5000);
nf1 = 8;
enablecounter=0;
enableflag = false;

fismat = readfis('fuzzy_fis_new');

count1 = [0 0 0 0];
status1 = [0 0 0 0]; % 0 off, 1 on
Cth = 5;

% Trigger the devices, then get the acquired data.% Trigger 200 times to get the frames.
for i = 1:5000
    
    
    % Trigger both objects.
    trigger([vid vid2])
    
    % Get the acquired frames and metadata.
    [imgColor] = getdata(vid);
    
    [imgDepth, ts_depth, metaData_Depth] = getdata(vid2);
    
    % Find which ID is tracked
    ix = metaData_Depth.IsSkeletonTracked; % Find nonzero terms
    
    % Get x y cordinates according to pixels
    Co = metaData_Depth.JointImageIndices;
    
    % Get x y and z cordinates (normalised)
    Co2 = metaData_Depth.JointWorldCoordinates;
    
    % Get tracked skeleton points
    S = Co(:,:,ix);
    S2 =  Co2(:,:,ix);
    %% Identify nearest person
    % ------------------------------------------------------
    if sum(ix)>1
        % Take all ids
        ix1 = find(ix);
        
        % dist initialisation
        dist1 = zeros(length(ix1));
        
        for ii1 = 1:length(ix1)
        
            % Z dist
            dist1(ii1) = mean(S2(:,3,ii1));
        end
        
        % Find nearest person
        [~,idxmin] = min(dist1);
        
        S2 = S2(:,:,idxmin(1));
        S = S(:,:,idxmin(1));
        ix = ix1(idxmin(1));
    end
    
    % -------------------------------------------------------
    if sum(ix)>0 % IF person is detected
        Hand_right = S2(12,1,1);
        Rp(i) = Hand_right;
        
        % Identify waving of hands
        if i>nf1
            [ampl, Nzc] = identify_gesture_parameter(Rp,i,nf1);
%             ampl
            
            if ampl>=1 && Nzc>=3 && enablecounter<=0 % Threshold change --------------
                enableflag = ~enableflag;
                enablecounter = 15;
            end
            
            if ampl>=1.2 && Nzc>=3 
                continue;
            end
        end
    end
      
     if sum(ix)>0 && enableflag % If person is detected 
        
        %% ----------------------------------------------------------------
        % Get right hand x,y and z
        Rx = S2(12,1,1);
        Ry = S2(12,2,1);
        Rz = S2(12,3,1);
        
        % Get left hand x,y and z
        Lx = S2(8,1,1);
        Ly = S2(8,2,1);
        Lz = S2(8,3,1);
        
        % Get shoulder center x,y and z
        Sx = S2(3,1,1);
        Sy = S2(3,2,1);
        Sz = S2(3,3,1);
        
        % Calculate features
        dxR = Rx-Sx;
        dyR = Ry-Sy;
        dzR = abs(Sz-Rz);
        dxL = Sx-Lx;
        
        % 
        % Evaluate fuzzy interfernce system
        out1 = evalfis([dxR ;dyR; dzR ;dxL],fismat);
        
        if out1>0.2 && out1<=0.4 && enablecounter<5
            % TV sign
            % Increment counter
            count1(1) = count1(1)+1;
            count1(2:3) = 0;
            
            if count1(1)==Cth 
                status1(1) = ~status1(1);
                
                if status1(1) ==1
                    disp('TV on');
                else
                    disp('TV off');
                end
            end
        elseif out1>0.4 && out1<=0.6
            % Fan
            % Increment counter
            count1(2) = count1(2)+1;
            count1([1 3 4]) = 0;
            
            if count1(2)==Cth
                status1(2) = ~status1(2);
                
                if status1(2) ==1
                    disp('Fan on');
                else
                    disp('Fan off');
                end
            end
        elseif out1>0.6 && out1<=0.8
            % Bulb 1
            % Increment counter
            count1(3) = count1(3)+1;
            count1([1 2 4]) = 0;
            
            if count1(3)==Cth
                status1(3) = ~status1(3);
                
                if status1(3) ==1
                    disp('Bulb 1 on');
                else
                    disp('Bulb 1 off');
                end
            end
        elseif out1>0.8
                % Bulb 2
                 % Increment counter
                count1(4) = count1(4)+1;
                count1([1 2 3]) = 0;

                if count1(4)==Cth
                    status1(4) = ~status1(4);

                    if status1(4) ==1
                        disp('Bulb 2 on');
                    else
                        disp('Bulb 2 off');
                    end
                end
        elseif out1<=0.2 % No signal
            count1 = zeros(1,4);
                
        end
        %% -----------------------------------------------------------------
    end
    
    % If enable then gesture recognition
%     if enableflag
%         
%         
%     end
    subplot(121)
    imshow(imgColor)
    title('Color image')
    skeletonViewer(S)
    
    
    subplot(122)
    imshow(imgDepth,[]);
    title('Depth image')
    
    if enableflag
        text(15,15,'Enable','fontsize',14,'color','g')
    else
        text(15,15,'Disable','fontsize',14,'color','r')
    end
    
   enablecounter = enablecounter-1;
%    count1
end