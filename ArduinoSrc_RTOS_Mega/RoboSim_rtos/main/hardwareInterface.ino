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
//#define HWIO_DEBUG_PRINT

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
double motor_conversion_factor[NUM_MOTOR_INPUTS] = {-0.0234375,-0.0234375,-0.0234375,-0.0234375,-0.0234375,-0.0234375}; // 12/512
bool digital_inputs[NUM_IO_CARDS*8];
bool digital_outputs[NUM_IO_CARDS*8];
double analog_outputs[NUM_IO_CARDS*2];
bool pc_connected = 0;
long rx_packet_count = 0;
long tx_packet_count = 0;



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
// void set_encoder_period_ms() 
// Description: Takes a period length in ms and and sets the encoder outputs
//
// Input Arguments: double - period of the pwm wave in ms
//                  bool - direction of the encoder's travel. ENCODER_DIR_FWD or ENCODER_DIR_BKD.
//                  char - encoder number to change output of
// Output: None
// Globals Read: None
// Globals Written: Encoder globals
////////////////////////////////////////////////////////////////////////////////
void set_encoder_period_ms( double encoder_period_ms_in, char encoder_num)
{ 
  //case, encoder stopped
  if(encoder_period_ms_in > MAX_PWM_PERIOD_MS | encoder_period_ms_in < -MAX_PWM_PERIOD_MS)
  {
    encoder_periods[encoder_num] = 0;
    encoder_enabled[encoder_num] = false;
  }
  //case, encoder running forward
  else if(encoder_period_ms_in > 0)
  {
    encoder_periods[encoder_num] = (unsigned long)round(encoder_period_ms_in / 4.0 / (double)ENCODER_INT_PERIOD_MS);
    encoder_enabled[encoder_num] = true;
    encoder_directions[encoder_num] = ENCODER_DIR_FWD;
  }
  //case, encoder running backward
  else
  {
    encoder_periods[encoder_num] = (unsigned long)round(-encoder_period_ms_in / 4.0 / (double)ENCODER_INT_PERIOD_MS);
    encoder_enabled[encoder_num] = true;
    encoder_directions[encoder_num] = ENCODER_DIR_BKD;
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
  //run motor value through five point map
  return five_point_map(motor_input_readings[motor_num],input_map[motor_num],output_map);
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

////////////////////////////////////////////////////////////////////////////////
// int send_packet_to_pc()
// Description: Sends a single packet of serial data to the PC. Serial port must
//              be opened already. Pulls from global variables.
//
// Input Arguments: none
//                  
// Output: 0 on successful send, -1 on failures
// Globals Read: none
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////
int send_packet_to_pc()
{
  /* serial arduino->PC packet format: (must be synced with PC side)
      % byte (0 txed first, n rxed last)
      % 0 - start of packet marker - always '~'
      % 1 - bit-packed digital inputs
      % 2 - motor 1 voltage - signed int8, 0.094488 V/bit
      % 3 - motor 2 voltage - signed int8, 0.094488 V/bit
      % 4 - motor 3 voltage - signed int8, 0.094488 V/bit
      % 5 - motor 4 voltage - signed int8, 0.094488 V/bit
      % 6 - motor 5 voltage - signed int8, 0.094488 V/bit
      % 7 - motor 6 voltage - signed int8, 0.094488 V/bit
      % 8 - checksum (bitwise xor of all other bytes)
  */
  byte tx_buffer[9]  = {PACKET_START_BYTE,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
  int i;
  
  //note throughout this funciton we have hardcoded many array lengths. This
  //is because the math and data movement contained herein is dependant on the
  //packet definition, not the hardware configuration of RoboSim. For that reason,
  //All of the packet-dependant variables are hardcoded to this function.
  
  //set digital inputs byte
  for(i = 0; i < 8; i++) //iterate over all bits
  {
    if(digital_inputs[i]) //input is true, set the bit
      tx_buffer[1] |= 0x01 << i;
    else //input is false, clear the bit
      tx_buffer[1] &= ~(0x01 << i);
  }
  
  //set motor voltages
  for(i = 2; i < 8; i++)
  {
    tx_buffer[i] = (unsigned char)((int8_t)(round(get_motor_in_voltage(i - 2) / 0.094488)));
  }
    
  //temp - debug tx buffer
  //tx_buffer[1] = 0x01;
  //tx_buffer[2] = 0x02;
  //tx_buffer[3] = 0x03;
  //tx_buffer[4] = 0xF1;
  //tx_buffer[5] = 0xE1;
  //tx_buffer[6] = 0xC1;
  //tx_buffer[7] = 0xA1;
  
  // Calculate Checksum
  tx_buffer[8] = tx_buffer[0] ^ tx_buffer[1] ^ tx_buffer[2] ^ tx_buffer[3] ^ tx_buffer[4] ^ tx_buffer[5] ^ tx_buffer[6] ^ tx_buffer[7];
  
  //Transmit byte (assuming serial port has been opened)
  //return proper error code
  
  if(Serial.write(tx_buffer, sizeof(tx_buffer)) == sizeof(tx_buffer))
  {
    tx_packet_count++;
    return 0;
  }
  else
    return -1;
  
}

////////////////////////////////////////////////////////////////////////////////
// int get_packet_from_pc()
// Description: pulls a single packet from the PC. Writes to global variables
//              per those packet's demands. Non-blocking.
//
// Input Arguments: None.
//                  
// Output: 0 on successful read, -1 on no packet available
// Globals Read: none
// Globals Written: none
////////////////////////////////////////////////////////////////////////////////
int get_packet_from_pc()
{
  uint8_t i;
  static uint8_t disconnect_dbnc_timer = 0;
  bool full_packet_rxed = false;
  /* serial PC->arduino packet format: (must be synced with PC side)
      % byte (0 rxed first, n rxed last)
      % 0 - start of packet marker - always '~'
      % 1 - bit-packed digital outputs
      % 2 - analog output 1 - 0.019607 volts/bit (0-5V range)
      % 3 - analog output 2 - 0.019607 volts/bit (0-5V range)
      % 4 - Quad Encoder 1 output MSB (1ms/bit)
      % 5 - Quad Encoder 1 output LSB
      % 6 - Quad Encoder 2 output MSB (1ms/bit)
      % 7 - Quad Encoder 2 output LSB
      % 8 - Quad Encoder 3 output MSB (1ms/bit)
      % 9 - Quad Encoder 3 output LSB
      % 10 - Quad Encoder 4 output MSB (1ms/bit)
      % 11 - Quad Encoder 4 output LSB
  */
  
  byte rx_buffer[12] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
  full_packet_rxed = false; //init the packet rxed flag
  if(Serial.available() >= 12) // if there's enough serial data available to make a packet...
  {
    rx_buffer[0] = Serial.read(); //read first byte
    if(rx_buffer[0] == PACKET_START_BYTE)//if the rxed byte corresponds to an actual packet...
    {
      for(i = 1; i < 12; i ++) //read in the full packet
        rx_buffer[i] = Serial.read();
      full_packet_rxed = true; //a packet! woo!
    }
    else //if first byte doesn't look like the start of a packet, it's not a full packet
    {
      full_packet_rxed = false;
    }
  }
  else //if we don't have enough bytes available, it wasn't a full packet
  {
    full_packet_rxed = false;
  }
  //calculate debounce 
  if(full_packet_rxed)
  {
      pc_connected = true;
      disconnect_dbnc_timer = 0;
  }
  else
  {
      if(disconnect_dbnc_timer > DISCONNECT_DBNC_TIME)
      {
          pc_connected = false;
          disconnect_dbnc_timer = 0;
      }
      else
      {
        disconnect_dbnc_timer++;
      }
      return -1;
  }
  
  //by this point, we have a good packet!
  rx_packet_count++;
  //set digital output values
  for(i = 0; i < 8; i++)
    digital_outputs[i] = (bool)((rx_buffer[1] >> i) & 0x01);
    
  //set analog outputs
  analog_outputs[0] = (double)rx_buffer[2] * 0.019607;
  analog_outputs[1] = (double)rx_buffer[3] * 0.019607;
  
  //set encoder outputs 
  set_encoder_period_ms((double)((int16_t)((((uint16_t)rx_buffer[4])<<8)|(((uint16_t)rx_buffer[5])&0x00FF))),0);
  set_encoder_period_ms((double)((int16_t)((((uint16_t)rx_buffer[6])<<8)|(((uint16_t)rx_buffer[7])&0x00FF))),1);
  set_encoder_period_ms((double)((int16_t)((((uint16_t)rx_buffer[8])<<8)|(((uint16_t)rx_buffer[9])&0x00FF))),2);
  set_encoder_period_ms((double)((int16_t)((((uint16_t)rx_buffer[10])<<8)|(((uint16_t)rx_buffer[11])&0x00FF))),3);
  return 0;
  
}

