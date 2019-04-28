clc;
clear;
close all;
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

% Configure the camera for manual triggering for both sensors.
triggerconfig([vid vid2],'manual');

% Set the frames per trigger for both devices to 1.
vid.FramesPerTrigger = 1;
vid2.FramesPerTrigger = 1;

% Set the trigger repeat for both devices to 200, in
% order to acquire 201 frames from both the color sensor and the depth sensor.
vid.TriggerRepeat = 5000;
vid2.TriggerRepeat = 5000;

% Start both video objects.
start([vid vid2]);

% Window size for hand segmentation
Wsize = 15;

% Trigger both objects.
trigger([vid vid2])

% Get the acquired frames and metadata.
[imgColor, ts_color, metaData_Color] = getdata(vid);
[imgDepth, ts_depth, metaData_Depth] = getdata(vid2);

% Get Size of image
[nr, nc,k] = size(imgDepth);

% Show output
figure;
imshow(imgColor)
title('color image')

figure;
imshow(imgDepth)
title('Depth image')