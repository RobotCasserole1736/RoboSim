/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: RoboSim.ino
// Description:  - Main entry functions for Arduino
//               - Performs all setup actions and contains main control loop
//
//  Change History:
//      Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/
#include "TimerOne.h"
#include "hardwareInterface.h"
#include "plant.h"


////////////////////////////////////////////////////////////////////////////////
// void setup() 
// Description: Initalize function required by arduino.
//
// Input Arguments: None
// Output: None
// Globals Read: None
// Globals Written: None
////////////////////////////////////////////////////////////////////////////////
void setup()
{
  //open serial port for pc comm's
  Serial.begin(9600);
  
  //start up encoders
  encoderInit();
  
}



////////////////////////////////////////////////////////////////////////////////
// void loop() 
// Description: Main control loop function required by arduino.
//
// Input Arguments: None
// Output: None
// Globals Read: None
// Globals Written: None
////////////////////////////////////////////////////////////////////////////////
void loop()
{
  
  
  
}

