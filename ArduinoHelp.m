% THIS IS BASIC CODE TO COMMUNICATE WITH THE PowerSwitchController VIA THE SERIAL PORT.  

serial_port = 'COM8' ;              % I CHECKED WHICH WAS THE RIGHT COM PORT JUST BY UNPLUGGING THE DEVICE AND SEEING WHAT WENT AWAY
dev = ModularClient(serial_port) ;  % CREATES A CLIENT OBJECT THAT ALLOWS YOU TO TALK TO THE DEVICE
dev.open()
dev.getDeviceId()
dev.getMethods()                    % RETURNS THE DEVICE METHODS

% IF YOU WANT MORE DETAILED HELP ON THE METHOD ITSELF
method_info = dev.startPwm('?')
% IF YOU WANT MORE UNDERSTANDING OF THE INPUT PARAMETERS:
parameter_info = dev.setChannelsOn('channels','?')

% DETAILED HELP FOR MOTOR DRIVER:
method_info = dev.moveStageTo('?')
parameter_info = dev.moveStageTo('stage_position','?')
method_info = dev.homeNozzle('?')
method_info = dev.moveBy('?')
method_info = dev.homeNozzle('?')

% CLOSE EVERYTHING WHEN FINISHING
dev.close()                      % CLOSE SERIAL CONNECTION
delete(dev)                      % DELETE THE CLIENT