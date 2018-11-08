function get_samples_v3(nframes)

% If you run this function in a loop, the output files will be stored in
% different directories
persistent dirname
persistent count
if isempty(count)
    count = 1;
else
    count = count + 1;
end
dirname = ['output_' num2str(count)];

mkdir(dirname);
% Clean Up
delete(imaqfind)

% Create Video Object
vi1 = videoinput('winvideo');

% Initialize Counter
vi1.UserData = 1; 
fpf = 15;

% Set Parameters
set(vi1,'FramesAcquiredFcn',{@FrameSave,dirname},'FramesAcquiredFcnCount',fpf);
set(vi1,'FramesPerTrigger',nframes,'LoggingMode','memory');
set(vi1,'Timeout',fpf);

% Trigger Device
start(vi1);
wait(vi1);


% Callback Every fpf Frames
function FrameSave(vi1,event,dirname)
disp(vi1.FramesAcquired);
data = getdata(vi1,vi1.FramesAcquiredFcnCount);
filename = ['file',num2str(vi1.UserData),'.mat'];

% -v6 option speeds up save process to help prevent the buffer from filling
% during file write operation
filename
save([pwd '\' dirname '\' filename],'data','-v6');
vi1.UserData = vi1.UserData + 1;