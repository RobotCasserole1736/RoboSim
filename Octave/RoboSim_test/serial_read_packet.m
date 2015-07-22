function [read_packet, ret_status] = serial_read_packet(s_fp)

  try
    % read single characters until packet start character read
    header_char = srl_read(s_fp, 1);
    if(header_char == '~')
        %Once we have the packet start, the next characters are the packet
        packet = srl_read(s_fp, 11); 
    end
    read_packet(0) = header_char;
    read_packet(1:11) = packet;
    ret_status = 0;
    return;
  catch err
    disp("Warning: issue while getting serial packet:");
    disp(lasterr);
    read_packet = [0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF];
    ret_status = -1;
    return;
  end
    

end