/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: memory_monitor.h
// Description:  - header for functions to calculate arduino runtime memory usage
//
//  Change History:
//      Chris Gerth - 04Oct2015 - Created
//
/******************************************************************************/

//function prototypes
#ifndef	MEMORY_FREE_H
#define MEMORY_FREE_H

#ifdef __cplusplus
extern "C" {
#endif

int freeMemory();
double calc_memory_usage_pct();

#ifdef  __cplusplus
}
#endif

//total ram in arduino (MEGA)

#define TOTAL_RAM 8192 //in bytes

#endif
