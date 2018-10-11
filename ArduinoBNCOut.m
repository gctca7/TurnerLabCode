getAvailableComPorts()
serial_port = 'COM5' ;              % I CHECKED WHICH PORT TO USE JUST BY UNPLUGGING THE DEVICE
dev = ModularClient(serial_port) ;  % CREATES A CLIENT OBJECT
dev.open()
dev.setPinMode('bnc_b', 'PULSE_RISING') ; 
dev.setPinValue('bnc_b', 1) ;
pause(1)
dev.setPinMode('bnc_b', 'PULSE_FALLING') ; 
dev.setPinValue('bnc_b', 0) ;
pause(1)