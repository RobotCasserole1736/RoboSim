/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: hardwareInterface.cpp
// Description:  - Interface functions relevant to the interfacing of
//                 the arduino to the hardware inside the sim box.
//
//  Change History:
//      Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/

#include "hardwareInterface.h"

////////////////////////////////////////////////////////////////////////////////
//  Global variables
////////////////////////////////////////////////////////////////////////////////
volatile unsigned long encoder_periods[NUM_ENCODER_OUTPUTS];
volatile unsigned long encoder_state_timers[NUM_ENCODER_OUTPUTS];
volatile char encoder_states[NUM_ENCODER_OUTPUTS];
volatile char encoder_directions[NUM_ENCODER_OUTPUTS];
volatile char encoder_enabled[NUM_ENCODER_OUTPUTS];
int motor_input_readings[NUM_MOTOR_INPUTS] = {0,0,0,0,0,0};
double motor_zero_points[NUM_MOTOR_INPUTS] = {512,512,512,512,512,512};
double motor_conversion_factor[NUM_MOTOR_INPUTS] = {0.001953125,0.001953125,0.001953125,0.001953125,0.001953125,0.001953125}; // 1/512




////////////////////////////////////////////////////////////////////////////////
// void set_encoder_RPM() 
// Description: Takes an RPM and sets the encoder outputs
//
// Input Arguments: double - speed to set to encoder outputs in RPM
//                  char - encoder number to change output of
// Output: None
// Globals Read: None
// Globals Written: Encoder globals
////////////////////////////////////////////////////////////////////////////////
void set_encoder_RPM( double encoder_RPM_in, char encoder_num)
{
  double cycles_per_interrupt_state_delay = 0;
  
  if(encoder_RPM_in > 0)
  {
    encoder_directions[encoder_num] = ENCODER_DIR_FWD;
    cycles_per_interrupt_state_delay = encoder_RPM_in/60.0 * 4 * (double)encoder_ticks_per_revolution[encoder_num] * ((double)ENCODER_INT_PERIOD_MS/1000.0);
  }
  else
  {
    encoder_directions[encoder_num] = ENCODER_DIR_BKD;
    cycles_per_interrupt_state_delay = -encoder_RPM_in/60.0 * 4 * (double)encoder_ticks_per_revolution[encoder_num] * ((double)ENCODER_INT_PERIOD_MS/1000.0);
  }
  
  if(cycles_per_interrupt_state_delay > 0)
  {
    encoder_periods[encoder_num] = (unsigned long)round(1.0/cycles_per_interrupt_state_delay);
    encoder_enabled[encoder_num] = true;
  }
  else
  {
    encoder_periods[encoder_num] = 0;
    encoder_enabled[encoder_num] = false;
  }
  
}


////////////////////////////////////////////////////////////////////////////////
// double get_motor_in_voltage
// Description: Takes a motor number, and returns the most recent voltage read
//
// Input Arguments: char - motor number to get input from
//                  
// Output: Motor voltage
// Globals Read: motor_input_readings
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////
double get_motor_in_voltage(char motor_num)
{
  //Scale and offset the analog value.
  //negative is hard-coded because input filter circuit has an inverting amplifier
  return -((double)motor_input_readings[motor_num] - motor_zero_points[motor_num])*motor_conversion_factor[motor_num] ;
}


////////////////////////////////////////////////////////////////////////////////
// void sample_motor_values
// Description: Reads and saves analog port values for motor voltages
//
// Input Arguments: none
//                  
// Output: none
// Globals Read: none
// Globals Written: motor_input_readings
////////////////////////////////////////////////////////////////////////////////
void sample_motor_values()
{
  int i;
  for(i = 0; i<NUM_MOTOR_INPUTS; i++)
  {
    motor_input_readings[i] = analogRead(motor_int_pin_numbers[i]);
  }
  
}

////////////////////////////////////////////////////////////////////////////////
// void init_motor_inputs
// Description: Sets up motor analog pins as inputs. Currently, no action is
//              actually required.
//
// Input Arguments: none
//                  
// Output: none
// Globals Read: none
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////
void init_motor_inputs()
{
  
  
}

////////////////////////////////////////////////////////////////////////////////
// void sample_digital_inputs
// Description: Get current readings for digital inputs
//
// Input Arguments: none
//                  
// Output: none
// Globals Read: none
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////
void sample_digital_inputs()
{
  
  
}

////////////////////////////////////////////////////////////////////////////////
// void init_digital_inputs
// Description: Set up digital inputs to recieve voltages
//
// Input Arguments: none
//                  
// Output: none
// Globals Read: none
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////
void init_digital_inputs()
{
  
  
}
