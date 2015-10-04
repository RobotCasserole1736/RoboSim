/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: memory_monitor.ino
// Description:  - functions to calculate arduino runtime memory usage
//
//  Change History:
//      Chris Gerth - 04Oct2015 - Created
//
/******************************************************************************/
extern unsigned int __bss_end;
extern unsigned int __heap_start;
extern void *__brkval;


#include "memory_monitor.h"


int freeMemory() {
  int free_memory;

  if((int)__brkval == 0)
     free_memory = ((int)&free_memory) - ((int)&__bss_end);
  else
    free_memory = ((int)&free_memory) - ((int)__brkval);

  return free_memory;
}

double calc_memory_usage_pct()
{
    return ((double)(TOTAL_RAM-freeMemory()))/((double)TOTAL_RAM) * 100.0; //Doesn't seem to actually work right now...
}