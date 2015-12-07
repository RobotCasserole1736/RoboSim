#######################################################################################################################
## COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED 
#######################################################################################################################
##
## RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
##
## make_RoboSim.py - build utility for RoboSim.
##
## I love the arduino ecosystem of software and hardware, but hate the limitation of the IDE where you may
## only have one folder. As we expanded the number of libraries needed for RoboSim (An RTOS!), it became more and 
## more apparent that folder-organization would be needed. Not liking any solution online, I took matters into my own
## hands and wrote this python utility to allow me to develop in multiple folders and still build with the arduino IDE
##
## The premise is simple: edit all code files with an external text editor (notepad++, perhaps?). When you're ready to
## put code on the arduino, run "make.bat" which will call this script.
##
## This script will then search for your arduino IDE installation, as well as the first arduino on a serial port it can
## find. It will then copy all the code files it can find into one approprately named temp folder, and call arduino
## ide executables on this new code folder to build and upload the source.
##
## Arguments - one optional. String indicating build target.
## 'all' - cleans, builds everything possible, and uploads
## 'sketch' - creates temp sketch but does not build it
## 'clean' - removes temp sketch
## 'verify' - builds the temp sketch but does not attempt upload
## 'ident' - identifys the arduino port but nothing else
## defaults to "all"
##
##
##  Change History:
##      Chris Gerth - 04Oct2015 - Created
#######################################################################################################################

import os,sys
import shutil,glob, subprocess

#Config params
temp_folder_name = "./temp_sketch_dir/"
sketch_name = "RoboSim_rtos" #name of sketch to assemble. Must match the filename of your top-level .ino file.
code_search_specs = ["./*/*.c", "./*/*.cpp", "./*/*.h", "./*/*.ino"]
mega_board_param = "arduino:avr:mega:cpu=atmega2560" #for standard arduino mega. See https://github.com/arduino/Arduino/blob/ide-1.5.x/build/shared/manpage.adoc for help with other boards.
uno_board_param = "arduino:avr:uno" #for standard arduino uno. See https://github.com/arduino/Arduino/blob/ide-1.5.x/build/shared/manpage.adoc for help with other boards.
ftdi_board_param = uno_board_param #Can't detect the board that's on the other end of an FTDI, so assume uno?
default_arduino_serial_port = "COM8"
board_param = mega_board_param #default to mega

def print_help():
    print("")
    print("~~make_Robosim.py - a utility to build and upload the robosim arduino sketch")
    print("=====Valid Targets=====")
    print("  all    :  Build and upload everything")
    print("  sketch :  Create the temporary sketch only")
    print("  clean  :  Remove all temporary files")
    print("  verify :  Create temp sketch and build it, but don't attempt to upload")
    print("  ident  :  Display connected arduinos and exit")
    print("  -h     :  Print this message and exit")
    print("Default behavior builds all")
    

#MAIN FUNCTION BEGINS HERE

# Pull user-specified build target
if(len(sys.argv)>1):
    build_target = sys.argv[1]
else:
    build_target = "all"
    
#validate build target is a known one
if(not(build_target == "all" or build_target == "sketch" or build_target == "clean" or build_target == "verify" or build_target == "ident" or build_target == "-h")):
    print_help()
    print("Error: " + build_target + " is not a recognized build target!")
    sys.exit(-1)
elif(build_target == "-h"):
    print_help()
    sys.exit(0)
else:
    print("Building " + build_target)
    
#Attempt to import the python serial libraries. If they're not there, don't bother searching for an arduino and just use the default port.
try:
    import serial.tools.list_ports #You'll need PySerial! https://pypi.python.org/pypi/pyserial
    find_arduino_automatically = 1;
except:
    print("Warning: could not import serial libraries. Assuming PySerial is not installed and making a wild guess which port the arduino is on. May the odds be ever in your favor!")
    find_arduino_automatically = 0;
    arduino_serial_port = default_arduino_serial_port
    board_param = mega_board_param
    print("Attempting to contuinue assuming arduino is on " + arduino_serial_port)
    
    
# Scan for available ports with arduinos on them.
if(find_arduino_automatically == 1 and (build_target == "all" or build_target == "ident")):
    arduino_serial_port = []
    board_param = []
    ports = list(serial.tools.list_ports.comports()) #super fancy function that lists descriptions of the ports! 
    for p in ports:
        if "Arduino" in p[1] or "arduino" in p[1]: #Detects normal arduinos
            arduino_serial_port = str(p[0])
            if("Uno" or "uno" in p[1]):
                board_param = uno_board_param
                print("Arduino Uno found on port " + arduino_serial_port)
            elif("Mega" or "mega" in p[1]):
                board_param = mega_board_param
                print("Arduino Mega found on port " + arduino_serial_port)
            else:
                print("Error: Found an arduino on " + arduino_serial_port + ", but the board type could not be determined by parsing the recieved USB device info string " + p[1] + ". Don't know what to do, can't go on... Ending now...")
                
        if "FTDI" in p[2]: #detects the FTDI chip on older arduinos (but other things use FTDI too, so this isn't horribly robust.)
            arduino_serial_port = str(p[0])
            board_param = ftdi_board_param
            print("Found an FTDI on " + arduino_serial_port + ". No idea if this is what you want, but I'll try anyway. Using board param " + board_param)            

    if arduino_serial_port == []:
        print("Schnazzle! No Arduino was found on any ports! Is it plugged in? Are you using an official Arduino board? (it must enumerate to USB as 'arduino')")
        sys.exit(-1)
        
#For the ident build target, just print out the serial port (if available) and exit.
if(build_target == "ident" ):
    if(find_arduino_automatically == 1):
        print("Ident: Found arduino on " + arduino_serial_port)
        sys.exit(0)
    else:
        print("Ident: Err: Could not scan for arduinos. Default port is " + arduino_serial_port)
        sys.exit(1)
    


if(build_target == "all" or build_target == "verify"):
    #AutoDetect arduino tool path from a list of possibilities:
    arduino_bin_possible_paths = ["B:\Program Files (x86)\Arduino", "C:\Program Files (x86)\Arduino", "B:\Program Files\Arduino", "C:\Program Files\Arduino", "C:\Arduino", "B:\Arduino", "./"]
    arduino_exe = "arduino_debug.exe"
    arduino_cmd = []
    for path in arduino_bin_possible_paths:
        possible_exe = os.path.abspath(os.path.join(path, arduino_exe)).replace("/","\\")
        if(os.path.isfile(possible_exe)):
            arduino_cmd = possible_exe
            print("Found arduino executable at " + arduino_cmd);
            break;
            
    if(arduino_cmd == []):
        print("Schnazzle! Arduino executable was needed, but not found! Be sure to install the arduino IDE, version 1.5.0 or later.")
        sys.exit(-1);

#Main fun starts here!!

file_copy_list = []

if(build_target == "all" or build_target == "sketch"  or build_target == "verify"):
    print("Starting build of "+ sketch_name)

#Clean - remove the temp sketch if it existed
if os.path.isdir(temp_folder_name):
    print("Removing " + temp_folder_name)
    shutil.rmtree(temp_folder_name)

#if we were only supposed to clean, just exit now.
if(build_target == "clean"):
    print("Build " + build_target + " finished.")
    sys.exit(0)

#Find - get all code files which will be part of this build
for search_spec in code_search_specs:
    print("Searching for source files matching " + search_spec)
    file_copy_list.extend(glob.glob(search_spec))


#Copy - make the new temp sketch for arduino to build
sketch_location = os.path.join(temp_folder_name, sketch_name)
print("Creating temporary sketch at " + sketch_location)
os.makedirs(sketch_location)
for file in file_copy_list:
    shutil.copy2(file, sketch_location)

#if we were only supposed to assemble the sketch, just exit now.
if(build_target == "sketch"):
    print("Build " + build_target + " finished.")
    sys.exit(0)

#Build - call arduino executables on the temp sketch
if(build_target == "verify"):
    cmd = [arduino_cmd, "--verify", os.path.abspath(os.path.join(sketch_location, sketch_name + ".ino")).replace("/","\\"), "--board", board_param, "--verbose-build", "--preserve-temp-files"]
else:
    cmd = [arduino_cmd, "--upload", os.path.abspath(os.path.join(sketch_location, sketch_name + ".ino")).replace("/","\\"), "--board", board_param, "--port", arduino_serial_port, "--verbose-build", "--preserve-temp-files"]
print("Running arduino build!")
print(" ".join(cmd))
ret_code = subprocess.call(cmd)
if(ret_code):
    print("Arduino Build Failed!")
else:
    print("Arduino Build Completed!")
    
print("Build " + build_target + " finished.")
sys.exit(ret_code)






