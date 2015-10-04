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

import serial #You'll need PySerial! https://pypi.python.org/pypi/pyserial
import os,sys
import shutil,glob, subprocess

#Config params
temp_folder_name = "./temp/"
sketch_name = "RoboSim_rtos" #name of sketch to assemble. Must match the filename of your top-level .ino file.
code_search_specs = ["./*/*.c", "./*/*.cpp", "./*/*.h", "./*/*.ino"]
board_param = "arduino:avr:mega:cpu=atmega2560" #for standard arduino mega. See https://github.com/arduino/Arduino/blob/ide-1.5.x/build/shared/manpage.adoc for help with other boards.

#TODO - autodetect this from as many possible locations as we can think of!
arduino_bin_path = "B:\Program Files (x86)\Arduino"
arduino_exe = "arduino_debug.exe"
arduino_cmd = os.path.abspath(os.path.join(arduino_bin_path, arduino_exe))

#TODO - autodetect this using the PySerial library!
arduino_serial_port = "COM4"

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
    print("Copying " + file + " to temp sketch location")
    shutil.copy2(file, sketch_location)
    
#Build - call arduino executables on the temp sketch
cmd = [arduino_cmd.replace("/","\\"), "--upload", os.path.abspath(os.path.join(sketch_location, sketch_name + ".ino")).replace("/","\\"), "--board", board_param, "--port", arduino_serial_port, "--verbose-build", "--preserve-temp-files"]
print("Running arduino build!")
print(" ".join(cmd))
ret_code = subprocess.call(cmd)
if(ret_code):
    print("Arduino Build Failed!")
else:
    print("Arduino Build Completed!")
sys.exit(ret_code)






