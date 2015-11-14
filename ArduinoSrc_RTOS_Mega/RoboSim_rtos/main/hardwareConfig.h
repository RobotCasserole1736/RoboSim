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

/******************************************************************************/
/** HEADER INCLUDES                                                          **/
/******************************************************************************/

/******************************************************************************/
/** DATA DEFINITIONS                                                         **/
/******************************************************************************/

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
#define IO_SER_OUT_PIN 24
#define IO_SER_IN_PIN 12
#define IO_SER_SYNC_PIN 11
#define IO_SER_CLK_PIN 10

//Display pins
// I2C display will use the I2C SCL/SDA lines which are
// fixed to certain pin number, board dependent. The Reset pin must be a general
// GPIO Pin
#define OLED_RESET_PIN 22

//Define number of hardware IO's
//These are constrained by the HW IO capiabilities of the Arduino board you are working with
#define NUM_ENCODER_OUTPUTS 4
#define NUM_MOTOR_INPUTS 6

//period between evaluating the encoder ISR function
//which triggers (possibly) state transitions
// 100us has seemed to work pretty well. Smaller numbers 
// improve resolution (especially at high motor speeds), but 
// increase processor load. I'd strongly suggest not touching this.
#define ENCODER_INT_PERIOD_MS 0.1

//Limit for longest supported encoder pulse period
//30 seconds is the longest interrupt period we support. longer periods will map to "stop" (infinitely long period)
#define MAX_PWM_PERIOD_MS 30000 

//Define the fundamental sample rate of the system.
//50ms is a good tradeoff between accuracy, plant model performance,
//serial datalink performance, and arduino hardware limitations.
//If this is changed, the Octave simulations must also be changed
//to expect to Tx/Rx data at the corresponding rate.
#define MAIN_LOOP_PLANT_RATE_S 0.05

//RTOS Task rates. 
//Fundamental sample and transmit data tasks are set to the 
// system 50ms sample time. The packet RX task is run at twice the
// speed to catch the PC's packet as soon as possible. It's ok because
// if a full packet isn't ready, the RX task is non-blocking and very 
// lightweight.
// Display is updated slower to ease processor load.
#define SERIAL_TX_TASK_RATES_S MAIN_LOOP_PLANT_RATE_S
#define SERIAL_RX_TASK_RATES_S MAIN_LOOP_PLANT_RATE_S/2.0
#define HW_IO_SAMPLE_TASK_RATES_S MAIN_LOOP_PLANT_RATE_S
#define PLANT_LOOP_TASK_RATES_S MAIN_LOOP_PLANT_RATE_S
#define DISPLAY_UPDATE_TASK_RATES_S 0.2

//RTOS Task Enables. Set to 1 to enable the task,
//set to 0 to not run the task
#define SERIAL_TX_TASK_ENABLE 1
#define SERIAL_RX_TASK_ENABLE 1
#define HW_IO_SAMPLE_TASK_ENABLE 1
#define PLANT_LOOP_TASK_ENABLE 0 //onboard plant not used currently
#define DISPLAY_UPDATE_TASK_ENABLE 1

//PC Communication Tuning Values
//number of reads w/o a full packet before we say there's no more PC Connected
#define DISCONNECT_DBNC_TIME 30 

//Calibration values for analog input boards
//Should be adjusted based on skew in the analog input board 
// behavior due to component tolerances
const uint16_t input_map_m1[5]  = {892,717,563,354,174};  //brd 1, ch 1
const uint16_t input_map_m2[5]  = {896,719,536,357,175};  //brd 1, ch 2
const uint16_t input_map_m3[5]  = {894,720,538,352,177};  //brd 2, ch 1
const uint16_t input_map_m4[5]  = {894,719,537,356,181};  //brd 2, ch 2
const uint16_t input_map_m5[5]  = {890,712,535,357,172};  //brd 3, ch 1
const uint16_t input_map_m6[5]  = {896,714,536,357,174};  //brd 3, ch 2
const uint16_t * input_map[6]  = {input_map_m1,input_map_m2,input_map_m3,input_map_m4,input_map_m5,input_map_m6};
const double output_map[5] = {-12.0,-6.0,0.0,6.0,12.0}; //same for all

//IO Card constants - Adjust depending on how your IO cards are constructed, what pin states are needed for different actions, etc.
#define NUM_IO_CARDS 1
#define IO_SYNC_LOCKED 0 //lockced state - outputs are latched and will not change as data is shifted. Inputs are latched at the unlocked->locked transition so changes during shifting do not affect shifted bits
#define IO_SYNC_UNLOCKED 1 //unlocked means exchanging data with the outside world, locked means exchanging data with the arduino.
#define IO_CLK_LOW 0 //use these to invert clock if needed
#define IO_CLK_HIGH 1

//all timings on the 74HC165 and 595 datasheets are in the ns range, so just need to set this long enough to allow
//arduino pin voltages to swing sufficently for stable operation.
//Turns out these can be really tiny (1 us each, yeilding up to a 38kHz IO clock speed == 0.86ms data exchange time per io card)
//but if instablilty sets in, one potential solution is to slow down the IO speed by cranking these up.
#define IO_CLK_HALF_CYCLE_US 1
#define IO_SYNC_PULSE_TIME_US 1


/******************************************************************************/
/** PUBLIC FUNCTION HEADERS                                                  **/
/******************************************************************************/

#endif /*HWCONFIG_H*/
