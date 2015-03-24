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

////////////////////////////////////////////////////////////////////////////////
//THINGS WHICH MUST ALWAYS BE DEFINED DUE TO HARDWARE CONSTRAINTS
//YOU CAN CHANGE THEIR VALUES, BUT DO NOT REMOVE THEM!!!
////////////////////////////////////////////////////////////////////////////////
static int encoder_ticks_per_revolution[NUM_ENCODER_OUTPUTS] = {64,64,64,64};
