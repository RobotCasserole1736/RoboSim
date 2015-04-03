/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: hardwareConfig.h
// Description:  - Configuration paramaters relevant to the interfacing of
//                 the arduino to the hardware inside the sim box.
//
//  Change History:
//      Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/

#ifndef HWCONFIG_h
#define HWCONFIG_h

/*Arduino pin mappings*/

//analog pins
#define HW_MOTOR_0_INPUT_PIN 0
#define HW_MOTOR_1_INPUT_PIN 1
#define HW_MOTOR_2_INPUT_PIN 2
#define HW_MOTOR_3_INPUT_PIN 3
#define HW_MOTOR_4_INPUT_PIN 4
#define HW_MOTOR_5_INPUT_PIN 5

//digital out pins
#define HW_ENCODER_1A_PIN 2
#define HW_ENCODER_1B_PIN 3
#define HW_ENCODER_2A_PIN 4
#define HW_ENCODER_2B_PIN 5
#define HW_ENCODER_3A_PIN 6
#define HW_ENCODER_3B_PIN 7
#define HW_ENCODER_4A_PIN 8
#define HW_ENCODER_4B_PIN 9

//serial IO card pins
#define IO_SER_IN_PIN 10
#define IO_SER_OUT_PIN 11
#define IO_SER_CLK_PIN 12
#define IO_SER_SYNC_PIN 13

//Define number of hardware IO's
#define NUM_ENCODER_OUTPUTS 4
#define NUM_MOTOR_INPUTS 6

//period between evaluating the encoder isr function
//which triggers (possibly) state transitions
#define ENCODER_INT_PERIOD_MS 0.1

//Sample time for main simulation loop
#define MAIN_LOOP_TS_MS 100 

//flash rate of plant active LED in loops
#define HW_STATUS_FLASH_RATE_LOOPS 3


//IO Card constants
#define NUM_IO_CARDS 1
#define IO_SYNC_ACTIVE 0
#define IO_SYNC_LATCH 1
#define IO_CLOCK_LOW 0 //use these to invert clock if needed
#define IO_CLOCK_HIGH 1




#endif /*HWCONFIG_H*/
