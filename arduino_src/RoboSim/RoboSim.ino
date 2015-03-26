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
// Top-Level Global Data
////////////////////////////////////////////////////////////////////////////////
double ProcessorLoad = 0; //actual time to run loop/desired loop time * 100

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
  Serial.begin(115200);
  
  //start up encoders
  encoderInit();
  
  //set StatusLED as output

  
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
  
  unsigned long prev_loop_start_time_ms = millis(); //keeps the result of Millis() call before a loop starts
  unsigned long prev_loop_end_time_ms = millis(); //keeps the result of Millis() call as a loop ends
  int i = 0;

  while(1)//Redundant, but allows us to define truly local but persistant variables for the loop function
  {
    
    prev_loop_end_time_ms = millis();
    while(millis() < (prev_loop_start_time_ms + MAIN_LOOP_TS_MS)); //Hold here to ensure proper sample time
    ProcessorLoad = 100*((double)prev_loop_end_time_ms-(double)prev_loop_start_time_ms)/(double)MAIN_LOOP_TS_MS; //fixed overhead of calculating processor Load is not included in processor load calculation. BWAAAAAAA....
    prev_loop_start_time_ms = millis();
    
    set_encoder_RPM(i, 0);
    
    i = i+ 100;


    Serial.println(ProcessorLoad);
  }
  
  
}

