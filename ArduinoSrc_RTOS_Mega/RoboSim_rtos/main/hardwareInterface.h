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
#include "FlexiTimer2.h"
#include "digitalWriteFast.h"
#include "five_point_map.h"

//encoder state machine def's
#define ENCODER_DISABLED 0 //all outputs at 0
#define ENCODER_STATE_1 1 //encoder output 00
#define ENCODER_STATE_2 2 //encoder output 01
#define ENCODER_STATE_3 3 //encoder output 11
#define ENCODER_STATE_4 4 //encoder output 10
#define ENCODER_UNAVAILABLE -1
#define ENCODER_DIR_FWD true
#define ENCODER_DIR_BKD false

#define PACKET_START_BYTE (byte)'~'

#define DISCONNECT_DBNC_TIME 30 //number of reads w/o a full packet before we say there's no more PC

//Calibration values for analog input boards
const uint16_t input_map[][] PROGMEM = {{892,717,563,354,174},  //brd 1, ch 1
                                        {896,719,536,357,175},  //brd 1, ch 2
                                        {894,720,538,352,177},  //brd 2, ch 1
                                        {894,719,537,356,181},  //brd 2, ch 2
                                        {890,712,535,357,172},  //brd 3, ch 1
                                        {896,714,536,357,174}}; //brd 3, ch 2
const double output_map[] PROGMEM = {-12.0,-6.0,0.0,6.0,12.0}; //same for all


//Function prototypes from ISRs.cpp
void encoderInit();
void encoderISR();

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


//Motor input values
extern double motor_speeds[NUM_MOTOR_INPUTS]; //speed, normalized to range [-1, 1]
extern double motor_zero_points[NUM_MOTOR_INPUTS]; //full-stop of normalized reading from ADC (in range [0, 2^12]
extern double motor_conversion_factor[NUM_MOTOR_INPUTS]; //conversion from analog bits to -1 -> 1 range
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



//Function prototypes
void set_encoder_RPM( double encoder_RPM_in, char encoder_num);
double get_motor_in_voltage(char motor_num);
void sample_motor_values();
void init_motor_inputs();
unsigned char io_card_rx_byte();
unsigned char io_card_tx_byte();
int send_packet_to_pc();
int get_packet_from_pc();

#endif /*HWINTERFACE_h*/
