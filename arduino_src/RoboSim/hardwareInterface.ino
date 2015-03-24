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
volatile char encoder_states[NUM_ENCODER_OUTPUTS];
volatile char encoder_directions[NUM_ENCODER_OUTPUTS];
volatile char encoder_enabled[NUM_ENCODER_OUTPUTS];



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
  double period_calculated = 0;
  
  //Period = rpm desired * ticks per revolution * 0.000016666666 minutes per millisecond *  
  period_calculated = encoder_RPM_in * encoder_ticks_per_revolution[encoder_num] * 60 
  
}


