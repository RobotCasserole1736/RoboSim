%switchyard for all gui callbacks. Use source to determine what to actually do.
function gui_callbacks(source, callbackdata)
    %global vars for handles
    global a1_sld
    global a2_sld
    global btn_DO0
    global btn_DO1
    global btn_DO2
    global btn_DO3
    global btn_DO4
    global btn_DO5
    global btn_DO6
    global btn_DO7

    %global vars for output states
    global digital_outputs
    global analog_outputs

    %global vars for input states
    global digital_inputs

  if(source == a1_sld)
    a1_sld_callback(source,callbackdata);
  elseif(source == a2_sld)
    a2_sld_callback(source,callbackdata);
  elseif(source == btn_DO0)
    btn_DO0_callback(source,callbackdata);
  elseif(source == btn_DO1)
    btn_DO1_callback(source,callbackdata);
  elseif(source == btn_DO2)
    btn_DO2_callback(source,callbackdata);
  elseif(source == btn_DO3)
    btn_DO3_callback(source,callbackdata);
  elseif(source == btn_DO4)
    btn_DO4_callback(source,callbackdata);
  elseif(source == btn_DO5)
    btn_DO5_callback(source,callbackdata);
  elseif(source == btn_DO60)
    btn_DO6_callback(source,callbackdata);
  elseif(source == btn_DO7)
    btn_DO7_callback(source,callbackdata);
  end

end


%Actual GUI callbacks
function a1_sld_callback(source,callbackdata)
  disp('called A1 callback')
  fflush(stdout);
end

function a2_sld_callback(source,callbackdata)
  disp('called A2 callback')
  fflush(stdout);
end

function btn_DO0_callback(source, callbackdata)
  disp('called DO 0 callback')
  fflush(stdout);
end

function btn_DO1_callback(source, callbackdata)
  disp('called DO 1 callback')
  fflush(stdout);
end

function btn_DO2_callback(source, callbackdata)
  disp('called DO 2 callback')
  fflush(stdout);
end

function btn_DO3_callback(source, callbackdata)
  disp('called DO 3 callback')
  fflush(stdout);
end

function btn_DO4_callback(source, callbackdata)
  disp('called DO 4 callback')
  fflush(stdout);
end

function btn_DO5_callback(source, callbackdata)
  disp('called DO 5 callback')
  fflush(stdout);
end

function btn_DO6_callback(source, callbackdata)
  disp('called DO 6 callback')
  fflush(stdout);
end

function btn_DO7_callback(source, callbackdata)
  disp('called DO 7 callback')
  fflush(stdout);
end
