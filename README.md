# RoboSim
Arduino-based hardware-in-the-loop simulation of FRC robot hardware.

## Purpose
RoboSim is a set of hardware and software designed to enable simulation of 
hardware on a robot designed for the First Robotics Competition. The goal is to enable mentors and students to design a sufficently functional plant mode for their robot, connect a fully-constructed electrical board with software, and observe the effects of control inputs on their simulated robot platform. This allows the electrical, software, and mechanical teams to work more in parallel.

## High level design.
RoboSim is build around an Arduino Uno. There are two perripherial boards which expand the arduino's IO capiability. The Arduino sends state information to a desktop PC running a plant model, and recieves return data which it can feed back to the simulated robot's electrical board. The plant model on the PC is run using GNU Octave (a free malab alternative). The Octave Plant model simulates the robot hardware (taking only motor and solenoid voltages as inputs). Serial data is transfered between the arduino and Octave for IO with the electrical board.

## Project Status
RoboSim is currently in development. This section will be updated once the first release candidate is completed.

## Repository Contents
- arduino_src - source code for the embedded arduino controller inside of RoboSim
- Octave - source code for the Octave-run plant model and GUI
- Eagle - electrical schematics for RoboSim peripheral boards
- PSPICE - electrical simulations for RoboSim peripheral boards
- docs - an increasing collection of documentation.

## Required software:
- Arduino IDE
  - https://www.arduino.cc/en/Main/Software
- Python 3.2 (32bit)- other versions may work but are untested
  - https://www.python.org/download/releases/3.2.5/
- PySerial 2.7 win32 py3k
  -https://pypi.python.org/pypi/pyserial
- GNU Octave + instrument-control package
  - http://www.gnu.org/software/octave/download.html
  - Once installed, run "pkg install -forge instrument-control" at the Octave command window
- Eagle PCB design
  - http://www.cadsoftusa.com/download-eagle/
- LtSpice circuit simulator
  - http://www.linear.com/designtools/software/


