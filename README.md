# RoboSim
Arduino-based hardware-in-the-loop simulation of FRC robot hardware.

## Purpose
RoboSim is a set of hardware and software designed to enable simulation of 
mechanical hardware on a robot designed for the First Robotics Competition. 
The goal is to enable mentors and students to design a sufficiently functional plant mode for their robot, 
connect a fully-constructed electrical board with software, and observe the effects of control inputs on 
their simulated robot platform. This allows the electrical, software, and mechanical teams to work more in parallel.

## High level design.
RoboSim is build around an Arduino Mega. There are two sets of peripheral boards which 
expand the arduino's IO capability. The Arduino sends state information to a desktop PC 
running a plant model, and receives return data which it can feed back to the simulated 
robot's electrical board. The plant model on the PC is run using GNU Octave (a free Malab 
alternative). The Octave Plant model simulates the robot hardware (taking only motor and 
solenoid voltages as inputs). Serial data is transfered between the arduino and Octave for 
IO with the electrical board.

## Project Status
RoboSim is currently in development. All releases as of now are tested, but considered "alpha". 

## Screen-shots
[![Screenshot](/docs/sample_screenshots/motors.jpg)](docs/sample_screenshots/)
[![Screenshot](/docs/sample_screenshots/electrical.jpg)](docs/sample_screenshots/)
[![Screenshot](/docs/sample_screenshots/Robot_Physical.jpg)](docs/sample_screenshots/)
[![Screenshot](/docs/sample_screenshots/Robot_Figure.jpg)](docs/sample_screenshots/)
[![Screenshot](/docs/sample_screenshots/wall_bounce_animation.gif)](docs/sample_screenshots/)

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
- Other Tools
  - Eagle PCB design
    - http://www.cadsoftusa.com/download-eagle/
  - LtSpice circuit simulator
    - http://www.linear.com/designtools/software/
  - Autodesk Inventor

