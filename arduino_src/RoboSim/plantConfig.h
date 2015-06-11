/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: pllantConfig.h
// Description:  - Configuration paramaters relevant to the behavior of the
//                 robot's plant model
//
//  Change History:
//      Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/
/******************************************************************************/
#ifndef PLANTCONFIG_h
#define PLANTCONFIG_h

//Test - output sine and cosine on analog
//frequency (HZ)
double freq = 2;
unsigned long i = 0;

////////////////////////////////////////////////////////////////////////////////
//THINGS WHICH MUST ALWAYS BE DEFINED DUE TO HARDWARE CONSTRAINTS
//YOU CAN CHANGE THEIR VALUES, BUT DO NOT REMOVE THEM!!!
////////////////////////////////////////////////////////////////////////////////
const int encoder_ticks_per_revolution[NUM_ENCODER_OUTPUTS] = {16,16,16,16};



#endif /*PLANTCONFIG_h*/
