function SimpleOdor(OdorOnset, OdorDuration, InterTrialInterval, NumTrials, varargin)
%%
% varagin: OdorChoices - odors to be delivered.  In string form: 'a', 'b'
% etc.  NOT case sensitive.
% OdorOnset: Time when valves open in SECONDS
% OdorDuration: In SECONDS
% InterTrialInterval: SECONDS between Trial starts
% NumTrials: Number of odor presentation repeats.

% NOTE: Odors currently delivered in blocks.  Order is a>b>c>d even if
% varagin entered in a different order
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

% RETURN INDICES OF ODORS YOU WANT TO DELIVER i.e. OdorChoices
OdorChoices = varargin ;
OdorList = ["a","b","c","d"] ;
TF = contains(OdorList,OdorChoices,'IgnoreCase',true) ;
OdorIdx = find(TF) ;

% CHANNEL CONFIGURATIONS
% THIS DESCRIBES WHICH OPEN/CLOSED STATE OF THE FOUR VALVES FOR EACH OF THE FOUR DIFFERENT ODORS
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

ctr = 1 ;
for Ods = 1:NumberOdors
    for n = 1:NumTrials
        pause(OdorOnset) ;
        disp(['Trial ' num2str(ctr) ' of ' num2str(NumberOdors * NumTrials)]) ;
        dev.setChannelsOn(ValveConfigs{OdorIdx(Ods)}) ;  %(ValveConfigs{OdorIdx}) MAY NOT BE THE RIGHT SYNTAX
        pause(OdorDuration)
        dev.setAllChannelsOff() ;
        pause(InterTrialInterval - OdorDuration)
        ctr = ctr + 1 ;
    end
end

% CLOSE COMMUNICATION WITH ARDUINO
dev.close()                      % CLOSE SERIAL CONNECTION
delete(dev)                      % DELETE THE CLIENT

