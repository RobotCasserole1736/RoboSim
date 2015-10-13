/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: five_point_map.h
// Description:  - re-scale map for analog inputs
//
//  Change History:
//      Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/

#ifndef FIVE_PT_MAP_h
#define FIVE_PT_MAP_h

double five_point_map(uint16_t input, const uint16_t * input_map_pts, const double * output_map_pts);

#endif
