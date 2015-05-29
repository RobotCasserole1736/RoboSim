/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: plant.cpp
// Description:  - Main plant function for emulating robot functionality
//
//  Change History:
//      Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/

#include "plant.h"

void plant_periodic_loop()
{ 
  i = i + 1;

  analog_outputs[0] = 2.5+2.5*sin(2.0*PI*freq*(double)MAIN_LOOP_TS_MS/1000.0*(double)i);
  analog_outputs[1] = 2.5+2.5*cos(2.0*PI*freq*(double)MAIN_LOOP_TS_MS/1000.0*(double)i);
  Serial.println(ProcessorLoad);
  
}
