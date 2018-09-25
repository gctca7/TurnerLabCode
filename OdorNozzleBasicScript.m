serial_port = 'COM8' ;              % I CHECKED WHICH PORT TO USE JUST BY UNPLUGGING THE DEVICE
dev = ModularClient(serial_port) ;  % CREATES A CLIENT OBJECT
dev.open()

% MOTOR DOES 360 DEGRESS IN 256*6 = 1536 STEPS
dev.moveBy((45/360)*1536) ; 