/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: hardwareInterface.cpp
// Description:  - Interface functions relevant to the interfacing of
//                 the arduino to the hardware inside the sim box.
//
//  Change History:
//      Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/

#include "hardwareInterface.h"

////////////////////////////////////////////////////////////////////////////////
//  Global variables
////////////////////////////////////////////////////////////////////////////////
volatile unsigned long encoder_periods[NUM_ENCODER_OUTPUTS];
volatile unsigned long encoder_state_timers[NUM_ENCODER_OUTPUTS];
volatile char encoder_states[NUM_ENCODER_OUTPUTS];
volatile char encoder_directions[NUM_ENCODER_OUTPUTS];
volatile char encoder_enabled[NUM_ENCODER_OUTPUTS];
int motor_input_readings[NUM_MOTOR_INPUTS];
double motor_zero_points[NUM_MOTOR_INPUTS] = {512,512,512,512,512,512};
double motor_conversion_factor[NUM_MOTOR_INPUTS] = {0.001953125,0.001953125,0.001953125,0.001953125,0.001953125,0.001953125}; // 1/512
bool digital_inputs[NUM_IO_CARDS*8];
bool digital_outputs[NUM_IO_CARDS*8];
double analog_outputs[NUM_IO_CARDS*2];



////////////////////////////////////////////////////////////////////////////////
// void set_encoder_RPM() 
// Description: Takes an RPM and sets the encoder outputs
//
// Input Arguments: double - speed to set to encoder outputs in RPM
//                  char - encoder number to change output of
// Output: None
// Globals Read: None
// Globals Written: Encoder globals
////////////////////////////////////////////////////////////////////////////////
void set_encoder_RPM( double encoder_RPM_in, char encoder_num)
{
  double cycles_per_interrupt_state_delay = 0;
  
  if(encoder_RPM_in > 0)
  {
    encoder_directions[encoder_num] = ENCODER_DIR_FWD;
    cycles_per_interrupt_state_delay = encoder_RPM_in/60.0 * 4 * (double)encoder_ticks_per_revolution[encoder_num] * ((double)ENCODER_INT_PERIOD_MS/1000.0);
  }
  else
  {
    encoder_directions[encoder_num] = ENCODER_DIR_BKD;
    cycles_per_interrupt_state_delay = -encoder_RPM_in/60.0 * 4 * (double)encoder_ticks_per_revolution[encoder_num] * ((double)ENCODER_INT_PERIOD_MS/1000.0);
  }
  
  if(cycles_per_interrupt_state_delay > 0)
  {
    encoder_periods[encoder_num] = (unsigned long)round(1.0/cycles_per_interrupt_state_delay);
    encoder_enabled[encoder_num] = true;
  }
  else
  {
    encoder_periods[encoder_num] = 0;
    encoder_enabled[encoder_num] = false;
  }
  
}


////////////////////////////////////////////////////////////////////////////////
// double get_motor_in_voltage
// Description: Takes a motor number, and returns the most recent voltage read
//
// Input Arguments: char - motor number to get input from
//                  
// Output: Motor voltage
// Globals Read: motor_input_readings
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////
double get_motor_in_voltage(char motor_num)
{
  //Scale and offset the analog value.
  //negative is hard-coded because input filter circuit has an inverting amplifier
  return -((double)motor_input_readings[motor_num] - motor_zero_points[motor_num])*motor_conversion_factor[motor_num] ;
}


////////////////////////////////////////////////////////////////////////////////
// void sample_motor_values
// Description: Reads and saves analog port values for motor voltages
//
// Input Arguments: none
//                  
// Output: none
// Globals Read: none
// Globals Written: motor_input_readings
////////////////////////////////////////////////////////////////////////////////
void sample_motor_values()
{
  int i;
  for(i = 0; i<NUM_MOTOR_INPUTS; i++)
  {
    motor_input_readings[i] = analogRead(motor_int_pin_numbers[i]);
  }
  
}

////////////////////////////////////////////////////////////////////////////////
// void init_motor_inputs
// Description: Sets up motor analog pins as inputs. Currently, no action is
//              actually required.
//
// Input Arguments: none
//                  
// Output: none
// Globals Read: none
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////
void init_motor_inputs()
{
  memset(motor_input_readings, 0, sizeof(motor_input_readings)):
  
}

////////////////////////////////////////////////////////////////////////////////
// void io_card_exchange_data
// Description: Get current readings for digital inputs, and set digital and 
//              analog outputs
//
// Input Arguments: none
//                  
// Output: none
// Globals Read: none
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////
void io_card_exchange_data()
{
  unsigned char io_card_iter;
  unsigned char temp_byte;
  unsigned char byte_rxed;
  unsigned char bit_iter;

  //Assume clock starts low, ready to shift at next rising edge.
  
  //Set the sync pin to latch inputs, and lock outputs
  digitalWrite(IO_SER_SYNC_PIN, IO_SYNC_LOCKED);

  for(io_card_iter = 0; io_card_iter < NUM_IO_CARDS; io_card_iter++)
  {
    //based on io board design, the sequence to shift data per board is:
    //output analog out 1
    //output analog out 2
    //recieve digital inputs
    //output analog inputs
    
    //calculate bits for output analog 1 
    if(analog_outputs[io_card_iter*2] > 5)
      temp_byte = 0xFF;
    else if(analog_outputs[io_card_iter*2] < 0)
      temp_byte = 0x00;
    else
      temp_byte = round(analog_outputs[io_card_iter*2]*255.0/5.0);
    //output analog 1
    io_card_tx_byte(temp_byte);
    
    //calculate bits for output analog 2 
    if(analog_outputs[io_card_iter*2+1] > 5)
      temp_byte = 0xFF;
    else if(analog_outputs[io_card_iter*2+1] < 0)
      temp_byte = 0x00;
    else
      temp_byte = round(analog_outputs[io_card_iter*2+1]*255.0/5.0);
    //output analog 2
    io_card_tx_byte(temp_byte);
    
    //get bits for digital input
    temp_byte = io_card_rx_byte();
    
    
    
      
      

    
   
  } 
  
  
}

void io_card_tx_byte(unsigned char input_byte)
{
  bool bit_to_tx = 0;
  unsigned char bit_iter;
  
  for(bit_iter = 0; bit_iter < 8; bit_iter ++)
  {
    //calcualte the bit
    bit_to_tx = (0x01 << bit_iter) & (input_byte);
    //assume clock starts low, set bit on output
    digitalWrite(IO_SER_OUT_PIN, bit_to_tx);
    //cycle clock high-low to shift data
    delayMicroseconds(IO_CLK_HALF_CYCLE_US);
    digitalWrite(IO_SER_CLK_PIN, IO_CLK_HIGH);
    delayMicroseconds(IO_CLK_HALF_CYCLE_US);
    digitalWrite(IO_SER_CLK_PIN, IO_CLK_LOW);
    
  }
}

unsigned char io_card_rx_byte()
{
  unsigned char rx_byte = 0;
  bool rx_bit = 0;
  unsigned char bit_iter;
  
  for(bit_iter = 0; bit_iter < 8; bit_iter ++)
  {
    //cycle clock high-low to shift data
    delayMicroseconds(IO_CLK_HALF_CYCLE_US);
    digitalWrite(IO_SER_CLK_PIN, IO_CLK_HIGH);
    rx_bit = digitalRead(IO_SER_IN_PIN);
    delayMicroseconds(IO_CLK_HALF_CYCLE_US);
    digitalWrite(IO_SER_CLK_PIN, IO_CLK_LOW);
    rx_byte = rx_byte | ((unsigned char)rx_bit << bit_iter); 
  
}

////////////////////////////////////////////////////////////////////////////////
// void init_io_card
// Description: Set up io card
//
// Input Arguments: none
//                  
// Output: none
// Globals Read: none
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////
void init_io_card()
{
  unsigned char i;
  
  //set proper pin modes
  pinMode(IO_SER_IN_PIN, INPUT);
  pinMode(IO_SER_OUT_PIN, OUTPUT);
  pinMode(IO_SER_SYNC_PIN, OUTPUT);
  pinMode(IO_SER_CLK_PIN, OUTPUT);
  
  //set pin initial states
  digitalWrite(IO_SER_OUT_PIN, LOW);
  digitalWrite(IO_SER_SYNC_PIN, IO_SYNC_UNLOCKED); //set io cards to recieve data.
  digitalWrite(IO_SER_CLK_PIN, IO_CLK_LOW);
  
  memset(digital_inputs, '0', sizeof(digital_inputs)); 
  memset(digital_outputs, '0', sizeof(digital_outputs));
  memset(analog_outputs, 0.0, sizeof(analog_outputs));
  
}
