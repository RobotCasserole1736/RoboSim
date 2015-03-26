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
double motor_speeds[NUM_MOTOR_INPUTS] = {0,0,0,0,0,0};
double motor_zero_points[NUM_MOTOR_INPUTS] = {0.5,0.5,0.5,0.5,0.5,0.5};




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


