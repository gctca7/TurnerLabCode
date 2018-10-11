
serial_port = 'COM9' ;              % I CHECKED WHICH PORT TO USE JUST BY UNPLUGGING THE DEVICE
dev = ModularClient(serial_port) ;  % CREATES A CLIENT OBJECT
dev.open()
dev.getDeviceId()
dev.getMethods()                 % get device methods

% MORE DETAILED HELP
method_info = dev.startPwm('?')
parameter_info = dev.setChannelsOn('channels','?')

% DETAILED HELP FOR MOTOR DRIVER:
method_info = dev.moveStageTo('?')
parameter_info = dev.moveStageTo('stage_position','?')
method_info = dev.homeNozzle('?')
method_info = dev.moveBy('?')
method_info = dev.homeNozzle('?')

method_info = dev.setChannelsOn('?')
parameter_info = dev.setChannelsOn('channels','?')



% CLOSE EVERYTHING WHEN FINISHING
dev.close()                      % close serial connection
delete(dev)                      % deletes the client


