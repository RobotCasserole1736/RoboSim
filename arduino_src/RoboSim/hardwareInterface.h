/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: hardwareInterface.h
// Description:  - Interface functions relevant to the interfacing of
//                 the arduino to the hardware inside the sim box.
//
//  Change History:
//      Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/

#ifndef HWINTERFACE_h
#define HWINTERFACE_h

#include "hardwareConfig.h"
#include "plantConfig.h"
#include "TimerOne.h"

//encoder state machine def's
#define ENCODER_DISABLED 0 //all outputs at 0
#define ENCODER_STATE_1 1 //encoder output 00
#define ENCODER_STATE_2 2 //encoder output 01
#define ENCODER_STATE_3 3 //encoder output 11
#define ENCODER_STATE_4 4 //encoder output 10
#define ENCODER_UNAVAILABLE -1

#define ENCODER_DIR_FWD true
#define ENCODER_DIR_BKD false



//Function prototypes from ISRs.cpp
void encoderInit();
void encoderISR();

//encoder state variables
extern volatile unsigned long encoder_periods[NUM_ENCODER_OUTPUTS];
extern volatile char encoder_states[NUM_ENCODER_OUTPUTS];
extern volatile char encoder_enabled[NUM_ENCODER_OUTPUTS];
extern volatile char encoder_directions[NUM_ENCODER_OUTPUTS];
static char encoder_output_pin_numbers[NUM_ENCODER_OUTPUTS*2] = {
  HW_ENCODER_1A_PIN,
  HW_ENCODER_1B_PIN,
  HW_ENCODER_2A_PIN,
  HW_ENCODER_2B_PIN,
  HW_ENCODER_3A_PIN,
  HW_ENCODER_3B_PIN,
  HW_ENCODER_4A_PIN,
  HW_ENCODER_4B_PIN
  }; //Must have NUM_ENCODER_OUTPUTS*2 elements //must be of size NUM_ENCODER_OUTPUTS*2


//Function prototypes
void set_encoder_RPM( double encoder_RPM_in, char encoder_num);

#endif /*HWINTERFACE_h*/
