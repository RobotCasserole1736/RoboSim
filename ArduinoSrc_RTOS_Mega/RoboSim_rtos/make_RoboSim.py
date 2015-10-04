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
##
##  Change History:
##      Chris Gerth - 204Oct2015 - Created
#######################################################################################################################


import serial.tools.list_ports #You'll need PySerial! https://pypi.python.org/pypi/pyserial
import os,sys
import shutil,glob, subprocess

#Config params
temp_folder_name = "./temp_sketch_dir/"
sketch_name = "RoboSim_rtos" #name of sketch to assemble. Must match the filename of your top-level .ino file.
code_search_specs = ["./*/*.c", "./*/*.cpp", "./*/*.h", "./*/*.ino"]
#todo - parse this info out of the serial port reads.
board_param = "arduino:avr:mega:cpu=atmega2560" #for standard arduino mega. See https://github.com/arduino/Arduino/blob/ide-1.5.x/build/shared/manpage.adoc for help with other boards.

# Scan for available ports with arduinos on them.
arduino_serial_port = []
ports = list(serial.tools.list_ports.comports()) #super fancy function that lists descriptions of the ports! 
for p in ports:
    print(p)
    if "Arduino" in p[1] or "arduino" in p[1]: #Detects normal arduinos
        arduino_serial_port = str(p[0])
        print("Arduino found on port " + arduino_serial_port)
    if "FTDI" in p[2]: #detects the FTDI chip on older arduinos (but other things use FTDI too, so this isn't horribly robust.)
        arduino_serial_port = str(p[0])
        print("Found an FTDI on " + arduino_serial_port + ". No idea if this is what you want, but I'll try anyway.") 

if arduino_serial_port == []:
    print("Schnazzle! No Arduino was found on any ports! Is it plugged in? Are you using an official Arduino board? (it must enumerate to USB as 'arduino')")
    sys.exit(-1)

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
    print("Schnazzle! Arduino executable not found! Be sure to install the arduino IDE, version 1.5.0 or later.")
    sys.exit(-1);


file_copy_list = []


#Main fun starts here!!
print("Starting build of "+ sketch_name)
#Clean - remove the temp sketch if it existed
if os.path.isdir(temp_folder_name):
    print("Cleaning " + temp_folder_name)
    shutil.rmtree(temp_folder_name)

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
    
#Build - call arduino executables on the temp sketch
cmd = [arduino_cmd, "--upload", os.path.abspath(os.path.join(sketch_location, sketch_name + ".ino")).replace("/","\\"), "--board", board_param, "--port", arduino_serial_port, "--verbose-build", "--preserve-temp-files"]
print("Running arduino build!")
print(" ".join(cmd))
ret_code = subprocess.call(cmd)
if(ret_code):
    print("Arduino Build Failed!")
else:
    print("Arduino Build Completed!")
sys.exit(ret_code)






