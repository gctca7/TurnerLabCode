function SimpleOdor(OdorOnset, OdorDuration, InterTrialInterval, NumTrials, varargin)
%%
% varagin: Odors to be delivered.  Variable length input so 1 or 1,2 or 1,2,3 etc
% OdorOnset: Time when valves open in SECONDS
% OdorDuration: In SECONDS
% InterTrialInterval: SECONDS between Trial starts
% NumTrials: Number of odor presentation repeats.  
%     NOTE: Odors delivered in blocks
%%
if (nargin < 5 | nargin > 8)
    error('I can only deliver between 1 and 4 odors')
end
if InterTrialInterval < OdorDuration+OdorOnset
    error('Your Inter Trial Interval too short')
end

NumberOdors = nargin - 4 ;
disp(['Presenting ' num2str(NumberOdors) ' odors'])

% ESTABLISH COMMUNICATION WITH ARDUINO
% getAvailableComPorts()
serial_port = 'COM5' ;              % I CHECKED WHICH PORT TO USE JUST BY UNPLUGGING THE DEVICE
dev = ModularClient(serial_port) ;  % CREATES A CLIENT OBJECT
dev.open()

% CHANNEL CONFIGURATIONS:
% Odor A: valve1/Op v2/cl v3/cl v4/cl
% Odor B: valve1/Op v2/cl v3/Op v4/cl
% Odor C: valve1/Op v2/Op v3/cl v4/cl
% Odor D: valve1/Op v2/Op v3/cl v4/Op

% INDICES FOR WHICH VALVES TO OPEN FOR EACH ODOR PORT:
OdorA = [0] ;
OdorB = [0 2] ;
OdorC = [0 1] ;
OdorD = [0 1 3] ;
ValveConfigs = {OdorA OdorB OdorC OdorD} ;

ctr = 1 ; 
for OdorIdx = 1:NumberOdors
    for n = 1:NumTrials
        pause(OdorOnset) ;
        dev.setChannelsOn(ValveConfigs(OdorIdx)) ;  % MAY NOT BE THE RIGHT SYNTAX        
        pause(OdorDuration)
        dev.setAllChannelsOff() ;
        pause(InterTrialInterval - OdorDuration)
        disp(['Trial ' num2str(ctr) ' of ' num2str(NumberOdors*NumTrials)]) ; 
        ctr = ctr + 1 ;
    end
end

% CLOSE COMMUNICATION WITH ARDUINO
dev.close()                      % close serial connection
delete(dev)                      % deletes the client

