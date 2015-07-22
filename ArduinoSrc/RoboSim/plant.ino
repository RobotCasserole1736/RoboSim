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
  analog_outputs[0] = 1.14;
  analog_outputs[1] = 2.14;
  digital_outputs[0] = true;
  digital_outputs[1] = false;
  digital_outputs[2] = true;
  digital_outputs[3] = false;
  digital_outputs[4] = true;
  digital_outputs[5] = false;
  digital_outputs[6] = true;
  digital_outputs[7] = false;

}
