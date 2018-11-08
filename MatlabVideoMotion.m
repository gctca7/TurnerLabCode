% ArenaTracker

% COULD YOU AVERAGE SEVERAL FRAMES AND THEN SUBTRACT - PERHAPS THIS WAY OPNLY LARGE DIFFERENCES WOULD BE APPARENT AND IT WOULD BE EASY TO DETECT THEM


% Create video input object. 
vid = videoinput('dcam',1,'Y8_1024x768')

% Set video input object properties for this application.
vid.TriggerRepeat = 100;
vid.FrameGrabInterval = 5;

% Set value of a video source object property.
vid_src = getselectedsource(vid);
vid_src.Tag = 'motion detection setup';

% Create a figure window.
figure; 

% Start acquiring frames.
start(vid)

% Calculate difference image and display it.
while(vid.FramesAvailable >= 2)
    data = getdata(vid,2); 
    diff_im = imabsdiff(data(:,:,:,1),data(:,:,:,2));
    imshow(diff_im);
    drawnow     % update figure window
end

stop(vid)