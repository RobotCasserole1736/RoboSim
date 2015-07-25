function ret_status = serial_write_packet(s_fp, packet_to_write)

  try
    % Blocking write call, currently only accepts strings
    srl_write(s_fp, char(packet_to_write));
    ret_status = 0;
    return;
  catch err
    disp("Warning: issue while sending serial packet:");
    disp(lasterr);
    ret_status = -1;
    return;
  end
        
end