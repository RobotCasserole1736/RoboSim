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
#define HWIO_DEBUG_PRINT

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
  memset(motor_input_readings, 0, sizeof(motor_input_readings));
  
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
  unsigned char bytes_to_tx[NUM_IO_CARDS*4];
  unsigned char bytes_rxed[NUM_IO_CARDS*4];
  unsigned char bit_iter;
  unsigned char temp_byte;

  //Assume clock starts low, ready to shift at next rising edge.
  
  //Pulse the sync pin low before the data transfer.
  //This will load data into the input shift registers (occurs whenever sync is low)
  //It will also reload the data into the output shift registers. This is fine because
  //no shift has occurred since the last data transfer, so the shift registers and storage
  //registers on the 74HC595's are already the same.
  digitalWriteFast(IO_SER_SYNC_PIN, LOW);
  delayMicroseconds(IO_SYNC_PULSE_TIME_US);
  digitalWriteFast(IO_SER_SYNC_PIN, HIGH);
  delayMicroseconds(IO_SYNC_PULSE_TIME_US);
  
  //Assemble bytes we need to TX to the IO card chain.
  //These are all the bits which control the outputs of the cards.
  //The format of each element of the tx or rx byte arrays are:
  //   3    2   1   0
  // 0x XX  XX  00  XX
  //    |   |   |   |
  //    |   |   |   Eight bits for digital outputs
  //    |   |   Placeholder zeros where digital inputs will end up
  //    |   Analog output 2 eight-bit representation
  //    Analog output 1 eight-bit representation
  //
  // Bit order is MSB transmitted first on the serial bus.
  
  for(io_card_iter = 0; io_card_iter < NUM_IO_CARDS; io_card_iter++)
  {
    //calculate bits for output analog 1 
    if(analog_outputs[io_card_iter*2] > 5)
      temp_byte = 0xFF;
    else if(analog_outputs[io_card_iter*2] < 0)
      temp_byte = 0x00;
    else
      temp_byte = round(analog_outputs[io_card_iter*2]*255.0/5.0);
    
    bytes_to_tx[io_card_iter+3] = temp_byte;
    
        //calculate bits for output analog 1 
    if(analog_outputs[io_card_iter*2+1] > 5)
      temp_byte = 0xFF;
    else if(analog_outputs[io_card_iter*2+1] < 0)
      temp_byte = 0x00;
    else
      temp_byte = round(analog_outputs[io_card_iter*2+1]*255.0/5.0);
    
    bytes_to_tx[io_card_iter+2] = temp_byte;
    
    //drop an all-zeros placeholder for where the inputs will be shifted in.
    bytes_to_tx[io_card_iter+1] = 0x00;
    
    //generate byte for digital outputs
    temp_byte = 0;
    for(bit_iter = 0; bit_iter < 8; bit_iter++)
      temp_byte = temp_byte | ((unsigned char)digital_outputs[io_card_iter * 8 + bit_iter] << bit_iter);
    
    bytes_to_tx[io_card_iter+0] = temp_byte;
  }
  
  //Tx bits have been assembled into the bytes_to_tx[] array. Cycle them through
  //the IO card chain. Additionally, this process will return an array which contains
  //the current contents of all registers, from which we can extract the digital inputs.
  io_card_tx_and_rx_byte_arrays(NUM_IO_CARDS, bytes_to_tx, bytes_rxed);
  
  #ifdef HWIO_DEBUG_PRINT
  Serial.print("TX: ");
  for(io_card_iter = 0; io_card_iter < NUM_IO_CARDS; io_card_iter++)
  {
    Serial.print(" x");
    Serial.print(bytes_to_tx[io_card_iter+0],HEX);
    Serial.print(" x");
    Serial.print(bytes_to_tx[io_card_iter+1],HEX);
    Serial.print(" x");
    Serial.print(bytes_to_tx[io_card_iter+2],HEX);
    Serial.print(" x");
    Serial.print(bytes_to_tx[io_card_iter+3],HEX);
  }
  Serial.print("  ||  RX: ");
  for(io_card_iter = 0; io_card_iter < NUM_IO_CARDS; io_card_iter++)
  {
    Serial.print(" x");
    Serial.print(bytes_rxed[io_card_iter+0],HEX);
    Serial.print(" x");
    Serial.print(bytes_rxed[io_card_iter+1],HEX);
    Serial.print(" x");
    Serial.print(bytes_rxed[io_card_iter+2],HEX);
    Serial.print(" x");
    Serial.println(bytes_rxed[io_card_iter+3],HEX);
  }
  #endif
  
  //bytes_rxed now contains all the latest digital inputs, plus last control loop's outputs.
  //we could possibly do some error checking on that, but for now just extract the
  //digital inputs.
  
  for(io_card_iter = 0; io_card_iter < NUM_IO_CARDS; io_card_iter++)
  {
    for(bit_iter = 0; bit_iter < 8; bit_iter++)
    {
      digital_inputs[io_card_iter * 8 + bit_iter] = (bool)(bytes_rxed[io_card_iter + 1] & (0x01 << bit_iter));
    }
  }
  
  //Pulse the sync pin low again. On the rising edge of the pulse, data shifted into
  //the 74HC595's shift registers will latch into their storage registers.
  //It will also load the 74HC165 with data, but that will be overwritten on
  //the next call to exchange data. So that's ok.
  //Technically, this second pulse isn't needed. However, eliminating either
  //the first or second pulse will cause input and output data to be out of
  //phase by one loop. This might be ok, and could be attempted if faster data
  //exchange rates are needed.
  delayMicroseconds(IO_SYNC_PULSE_TIME_US);
  digitalWriteFast(IO_SER_SYNC_PIN, LOW);
  delayMicroseconds(IO_SYNC_PULSE_TIME_US);
  digitalWriteFast(IO_SER_SYNC_PIN, HIGH);
  
  
}

////////////////////////////////////////////////////////////////////////////////
// void io_card_tx_and_rx_byte_arrays
// Description: Get current readings for digital inputs, and set digital and 
//              analog outputs
//
// Input Arguments: 
//     num_cards - number of IO cards to shift data through
//     tx_bytes - array of bytes to send to the IO cards
//     rx_bytes - array of bytes read back from the cards
//
// Note: For both tx_bytes inputs, format is such that the MSB of the last
//       byte gets sent first, and ends up in the furthest shift register
//       spot from the arduino's data output pin. Same thing for rx_bytes - 
//       the MSB of its last byte represents the register furthest from the
//       arduino's output pin (but closest to its input pin).
//                  
// Output: nothing returned, rx_bytes populated with data
// Globals Read: none
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////

void io_card_tx_and_rx_byte_arrays(unsigned int num_cards, unsigned char * tx_bytes, unsigned char * rx_bytes)
{
   int num_bytes = num_cards * 4;
   char byte_iter = 0;
   char bit_iter = 0;
   bool bit_to_tx = 0;
   bool rx_bit = 0;
   
   for(byte_iter = num_bytes-1; byte_iter >= 0; byte_iter --)
   {
     rx_bytes[byte_iter] = 0;
     for(bit_iter = 7; bit_iter >= 0; bit_iter--)
     {
        //calcualte the bit
        bit_to_tx = (bool)((0x01 << bit_iter) & (tx_bytes[byte_iter]));
        //assume clock starts high, cycle clock low,
        //set bit on output, and read input bit.
        digitalWriteFast(IO_SER_CLK_PIN, IO_CLK_LOW); 
        digitalWriteFast(IO_SER_OUT_PIN, bit_to_tx);
        rx_bit = digitalRead(IO_SER_IN_PIN);
        delayMicroseconds(IO_CLK_HALF_CYCLE_US);
        //cycle clock low-high (rising edge) to shift data
        digitalWriteFast(IO_SER_CLK_PIN, IO_CLK_HIGH);
        delayMicroseconds(IO_CLK_HALF_CYCLE_US);
        rx_bytes[byte_iter] = rx_bytes[byte_iter] | ((unsigned char)(rx_bit & 0x01) << bit_iter); 
     }
   }
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
  digitalWriteFast(IO_SER_OUT_PIN, LOW);
  digitalWriteFast(IO_SER_SYNC_PIN, HIGH); //sync stays high except for data transfer.
  digitalWriteFast(IO_SER_CLK_PIN, IO_CLK_HIGH); //clock stays high while idle.
  
  memset(digital_inputs, '0', sizeof(digital_inputs)); 
  memset(digital_outputs, '0', sizeof(digital_outputs));
  memset(analog_outputs, 0.0, sizeof(analog_outputs));
  
}
