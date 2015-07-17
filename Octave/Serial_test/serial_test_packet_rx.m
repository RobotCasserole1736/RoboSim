pkg load instrument-control


% Opens serial port ttyUSB1 with baudrate of 115200 (config defaults to 8-N-1)

disp("opening serial port...")

s1 = serial("COM4", 115200);
disp("done")

try
	exit = 0;
	while(~exit)
        % read single characters until packet start character read
		disp("Starting Reading")
        data = srl_read(s1, 1);
		disp(data);
        if(data == '~')
            %Once we have the packet start, the next three characters are the packet
			disp("Got Packet")
            packet = srl_read(s1, 3); 
            disp(packet) %print the data
        end
		fflush(stdout);
		usleep(100);
		if(kbhit(1) == 'q')
			exit = 1;
		end
	end

catch err
    disp("exiting...");
	disp(err)
 end
 
fclose(s1);% Close serial port
