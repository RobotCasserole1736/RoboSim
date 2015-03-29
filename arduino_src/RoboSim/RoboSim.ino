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
double ProcessorLoad; //actual time to run loop/desired loop time * 100

///////////////////////////////////////////////////////////////////p/////////////
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
  //Open Serial port
  Serial.begin(115200);
  
  //start up encoders
  encoderInit();
  
  //start up motor inputs
  init_motor_inputs();
  
  //set StatusLED as output
  pinMode(HW_STATUS_LED_PIN, OUTPUT);
  
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
  
  //processor load calculation vars
  unsigned long prev_loop_start_time_ms = millis(); //keeps the result of Millis() call before a loop starts
  unsigned long prev_loop_end_time_ms = millis(); //keeps the result of Millis() call as a loop ends
  
  int i = 0;
  int plant_running_led_counter = 0;
  boolean plant_running_led_state = false;

  while(1)//Redundant, but allows us to define truly local but persistant variables for the loop function
  {
    //Calculate processor load and hold to ensure a loop time of MAIN_LOOP_TS_MS
    prev_loop_end_time_ms = millis();
    while(millis() < (prev_loop_start_time_ms + MAIN_LOOP_TS_MS)); //Hold here to ensure proper sample time
    ProcessorLoad = 100.0*((double)prev_loop_end_time_ms-(double)prev_loop_start_time_ms)/(double)MAIN_LOOP_TS_MS; //fixed overhead of calculating processor Load is not included in processor load calculation. BWAAAAAAA....
    prev_loop_start_time_ms = millis();
    
    //Toggle LED status light every HW_STATUS_FLASH_RATE_LOOPS
    if(plant_running_led_counter++ >= HW_STATUS_FLASH_RATE_LOOPS)
    {
      plant_running_led_counter = 0;
      plant_running_led_state = !plant_running_led_state;
      digitalWrite(HW_STATUS_LED_PIN, plant_running_led_state);
    }
    
    //Acquire input
    sample_motor_values();
    sample_digital_inputs();
    
    //Update output
    
    
    //run plant model
    plant_periodic_loop();
    
    
  


    Serial.println(ProcessorLoad);
  }
  
  
}

