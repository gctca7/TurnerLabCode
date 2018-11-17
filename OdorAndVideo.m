function OdorAndVideo(ExperimenterInitials, OdorOnset, OdorDuration, InterTrialInterval, NumTrials, varargin)
%%
% varagin: Odors to be delivered.  Variable length input so 1 or 1,2 or 1,2,3 etc
% ExperimenterInitials: XX ENTERED AS A STRING
% OdorOnset: Time when valves open in SECONDS
% OdorDuration: In SECONDS
% InterTrialInterval: SECONDS between Trial starts
% NumTrials: Number of odor presentation repeats.
%     NOTE: Odors delivered in blocks
% SAVES ALL DATA IN A FOLDER TOGETHER
%%
close all ;
if (nargin < 5 | nargin > 8)
    error('I can only deliver between 1 and 4 odors')
end
if InterTrialInterval < OdorDuration+OdorOnset
    error('Your Inter Trial Interval too short')
end

NumberOdors = nargin - 5 ;
disp(['Presenting ' num2str(NumberOdors) ' odors'])

% ESTABLISH COMMUNICATION WITH ARDUINO
% getAvailableComPorts()
serial_port = 'COM5' ;              % I CHECKED WHICH PORT TO USE JUST BY UNPLUGGING THE DEVICE
dev = ModularClient(serial_port) ;  % CREATES A CLIENT OBJECT
dev.open()

% RETURN INDICES OF ODORS YOU WANT TO DELIVER i.e. OdorChoices
OdorChoices = varargin ;
OdorList = ["a","b","c","d"] ;
TF = contains(OdorList,OdorChoices,'IgnoreCase',true) ;
OdorIdx = find(TF) ;

% CHANNEL CONFIGURATIONS:
% Odor A: valve1/Op v2/cl v3/cl v4/cl
% Odor B: valve1/Op v2/cl v3/Op v4/cl
% Odor C: valve1/Op v2/Op v3/cl v4/cl
% Odor D: valve1/Op v2/Op v3/cl v4/Op

% INDICES FOR WHICH VALVES TO OPEN FOR EACH ODOR PORT:
OdorA = {0} ;
OdorB = {0 2} ;
OdorC = {0 1} ;
OdorD = {0 1 3} ;
ValveConfigs = {OdorA OdorB OdorC OdorD} ;

%%
% SET UP THE VIDEO ACQUISITION
% imaqhwinfo ; %RETURNS INFO ABOUT IMAGE ACQUISITION HARDWARE
% info = imaqhwinfo('pointgrey') ; %RETURNS INFO ABOUT POINT GREY CAMERA
disp('this one')
% IS THERE A BETTER VIDEO FORMAT THAT'S MORE COMPRESSED?  WHAT DOES FICTRAC USE?
% vid = videoinput('pointgrey', 1, 'F7_Mono8_1040x776_Mode1');  % WAS F7_Mono8_640x512_Mode1  THIS MAY HAVE TO MATCH WHAT YOU SET UP IN FLYCAPTURE SOFTWARE
vid = videoinput('pointgrey', 1, 'F7_Mono8_1040x776_Mode1');  % WAS F7_Mono8_640x512_Mode1  THIS MAY HAVE TO MATCH WHAT YOU SET UP IN FLYCAPTURE SOFTWARE
preview(vid) ;
pause(10)
% THIS MAY BE PROBLEMATIC - I AM TRUNCATING THE VIDEO 1SEC BEFORE THE ODOR
% TRIAL IS OVER.  THIS IS NOT AN ELEGANT WAY TO TIME THINGS.
DurationInSec = InterTrialInterval - 1 ;
FrameRate = 25 ;
DurationInFrames = FrameRate * DurationInSec ;
% SET TriggerMode
% triggerinfo(vid) %RETURNS DIFFERENT WAYS OF TRIGGERING THE CAMERA
triggerconfig(vid, 'hardware', 'fallingEdge', 'externalTriggerMode0-Source0') ;
vid.FramesPerTrigger = DurationInFrames ;
%%
% SET THE FILE AND PATH WHERE YOU WANT TO SAVE THE VIDEO
DirString = ['C:\Data_', ExperimenterInitials] ;
cd(DirString) ;

% LOOP THAT CONTROLS THE ODOR DELIVERY.  ODOR IS DELIVERED IN BLOCKS - 5 TRIALS ODOR A THEN 5 TRIALS B ETC
% EACH LOOP STARTS A NEW RUN OF THE VIDEO ACQUISITION
% LOOP FLOW:
% INITIALIZE CAMERA ACQUISITION
% TRIGGER ACQUISITION BY A PULSE FROM THE ARDUINO BNC
% PAUSE THEN OPEN ODOR VALVES
% PAUSE THEN SHUT ODOR VALVES
% PAUSE TO FINISH ODOR TRIAL
ctr = 1 ;
for Ods = 1:NumberOdors
    for n = 1:NumTrials
        % THIS WILL GIVE EACH MOVIE A UNIQUE NAME
        SaveName = ['C:\Data_', ExperimenterInitials, '\', datestr(now,'yyyymmdd_HHMMSS'), '_Tr', num2str(ctr) '.mp4'] ;
        diskLogger = VideoWriter(SaveName, 'MPEG-4') ;
        % SET FrameRate
        diskLogger.FrameRate = FrameRate ;
        vid.DiskLogger = diskLogger ; %WHAT DOES THIS DO?
        vid.LoggingMode = 'disk&memory' ;
        start(vid); %STARTS VIDEO STREAMING BUT LOGGING ONLY OCCURS WHEN TRIGGER RECEIVED
        
        % SEND AN OUTPUT SIGNAL FROM THE ARDUINO TO TRIGGER VIDEO ACQUISITION ON THE CAMERA
        % CURRENT VERSION IS OVERKILL - I WASN'T SURE IF CAMERA TRIGGERS ON RISE OR FALL
        dev.setPinMode('bnc_b', 'PULSE_RISING') ;
        dev.setPinValue('bnc_b', 1) ;
        dev.setPinMode('bnc_b', 'PULSE_FALLING') ;
        dev.setPinValue('bnc_b', 0) ;
        
        pause(OdorOnset) ;
        disp(['Trial ' num2str(ctr) ' of ' num2str(NumberOdors * NumTrials)]) ;
        dev.setChannelsOn(ValveConfigs{OdorIdx(Ods)}) ;  
        pause(OdorDuration)
        dev.setAllChannelsOff() ;
        pause(InterTrialInterval - OdorDuration)
        ctr = ctr + 1 ;
        
        while (vid.FramesAcquired ~= DurationInFrames)
            pause(0.1)
        end
        % I'M NOT SURE STOPPING IS NECESSARY AT THIS POINT IN THE LOOP
        % THIS COULD PROBABLY BE OUTSIDE THE FOR LOOPS
        stop(vid) ;
    end
end

% SAVE DATA AND OTHER PARAMETERS & TELL THE USER
DataSaveName = [datestr(now,'yyyymmdd_HHMMSS'), '_', ExperimenterInitials] ;
save(DataSaveName, 'OdorOnset', 'OdorDuration', 'InterTrialInterval', 'NumTrials', 'varargin') ;
disp(['Saving ' DataSaveName ' in ' DirString])

% SWITCH BACK TO MAIN DIRECTORY
cd('C:\Users\labadmin\Documents\MATLAB')

% CLOSE COMMUNICATION WITH CAMERA
delete(vid)
clear vid

% CLOSE COMMUNICATION WITH ARDUINO
dev.close()
delete(dev)

