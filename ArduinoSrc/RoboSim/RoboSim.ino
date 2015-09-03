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


////////////////////////////////////////////////////////////////////////////////
// Loop() global variables
////////////////////////////////////////////////////////////////////////////////
int i;
int plant_running_led_counter = 0;
boolean plant_running_led_state = false;
//processor load calculation vars
unsigned long prev_loop_start_time_us = 0; 
unsigned long prev_loop_end_time_us = 0; 
  


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
  
  //set up io cards
  init_io_card();
    
  //initalize processor load calculation vars
  prev_loop_start_time_us = micros(); //keeps the result of Millis() call before a loop starts
  prev_loop_end_time_us = micros(); //keeps the result of Millis() call as a loop ends
  
  
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

  //Calculate processor load and hold to ensure a loop time of MAIN_LOOP_TS_MS
  prev_loop_end_time_us = micros();
  while(micros() < (prev_loop_start_time_us + MAIN_LOOP_TS_MS*1000UL)); //Hold here to ensure proper sample time
  ProcessorLoad = 100.0*((double)prev_loop_end_time_us-(double)prev_loop_start_time_us)/((double)MAIN_LOOP_TS_MS*1000.0); //fixed overhead of calculating processor Load is not included in processor load calculation. BWAAAAAAA....
  prev_loop_start_time_us = micros();
  
  //Toggle LED status light every HW_STATUS_FLASH_RATE_LOOPS
  if(plant_running_led_counter++ >= HW_STATUS_FLASH_RATE_LOOPS)
  {
    plant_running_led_counter = 0;
    plant_running_led_state = !plant_running_led_state;
    //need to actually use this data somehow...
  }
 
  
  //recieve packet (blocking)
  while(get_packet_from_pc() == -1);

  //Acquire input & output
  sample_motor_values();
  io_card_exchange_data();

  //run plant model (if any)
  plant_periodic_loop();
  
  //send packet back to PC
  send_packet_to_pc();

}

