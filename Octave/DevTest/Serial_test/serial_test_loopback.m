pkg load instrument-control


% Opens serial port ttyUSB1 with baudrate of 115200 (config defaults to 8-N-1)
s1 = serial("COM4", 115200); 

set(s1, "parity", "N");    % Changes parity checking 
                          % possible values [E]ven, [O]dd, [N]one.
set(s1, "stopbits", 1);    % Changes stop bits, possible
                          % values 1, 2.
% Flush input and output buffers
srl_flush(s1); 
% Blocking write call, currently only accepts strings
srl_write(s1, "Hello world!");
% Blocking read call, returns uint8 array of exactly 12 bytes read
data = srl_read(s1, 12)  
% Convert uint8 array to string, 
disp(char(data))
% Close serial port
fclose(s1);
