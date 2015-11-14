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


/******************************************************************************/
/** HEADER INCLUDES                                                          **/
/******************************************************************************/

#include "hardwareConfig.h"
#include "plantConfig.h"
#include "FlexiTimer2.h"
#include "digitalWriteFast.h"
#include "five_point_map.h"

/******************************************************************************/
/** DATA DEFINITIONS                                                         **/
/******************************************************************************/

//encoder state machine def's
#define ENCODER_DISABLED 0 //all outputs at 0
#define ENCODER_STATE_1 1  //encoder output 00
#define ENCODER_STATE_2 2  //encoder output 01
#define ENCODER_STATE_3 3  //encoder output 11
#define ENCODER_STATE_4 4  //encoder output 10
#define ENCODER_UNAVAILABLE -1
#define ENCODER_DIR_FWD true
#define ENCODER_DIR_BKD false

//PC Communication Constants
#define PACKET_START_BYTE (byte)'~'


//encoder state variables
extern volatile unsigned long encoder_periods[NUM_ENCODER_OUTPUTS];
extern volatile unsigned long encoder_state_timers[NUM_ENCODER_OUTPUTS];
extern volatile char encoder_states[NUM_ENCODER_OUTPUTS];
extern volatile char encoder_enabled[NUM_ENCODER_OUTPUTS];
extern volatile char encoder_directions[NUM_ENCODER_OUTPUTS];
const char encoder_output_pin_numbers[NUM_ENCODER_OUTPUTS*2] = {
  HW_ENCODER_1A_PIN,
  HW_ENCODER_1B_PIN,
  HW_ENCODER_2A_PIN,
  HW_ENCODER_2B_PIN,
  HW_ENCODER_3A_PIN,
  HW_ENCODER_3B_PIN,
  HW_ENCODER_4A_PIN,
  HW_ENCODER_4B_PIN
  }; //Must have NUM_ENCODER_OUTPUTS*2 elements //must be of size NUM_ENCODER_OUTPUTS*2


//Motor inputs
extern int motor_input_readings[NUM_MOTOR_INPUTS]; 
const char motor_int_pin_numbers[NUM_MOTOR_INPUTS] = { // array of numbers for pins used for analog input
  HW_MOTOR_0_INPUT_PIN,
  HW_MOTOR_1_INPUT_PIN,
  HW_MOTOR_2_INPUT_PIN,
  HW_MOTOR_3_INPUT_PIN,
  HW_MOTOR_4_INPUT_PIN,
  HW_MOTOR_5_INPUT_PIN
};

//digital input values
extern bool digital_inputs[NUM_IO_CARDS*8];

//digital output values
extern bool digital_outputs[NUM_IO_CARDS*8];

//analog output values
extern double analog_outputs[NUM_IO_CARDS*2];

//host pc & coms status
extern bool pc_connected;
extern long rx_packet_count;
extern long tx_packet_count;


/******************************************************************************/
/** FUNCTION HEADERS                                                         **/
/******************************************************************************/
//Function prototypes from ISRs.ino
void encoderInit();
void encoderISR();


//Function prototypes from hardwareInterface.ino
void set_encoder_period_ms( double encoder_period_ms_in, char encoder_num);
double get_motor_in_voltage(char motor_num);
void sample_motor_values();
void init_motor_inputs();
unsigned char io_card_rx_byte();
unsigned char io_card_tx_byte();
int send_packet_to_pc();
int get_packet_from_pc();

#endif /*HWINTERFACE_h*/
