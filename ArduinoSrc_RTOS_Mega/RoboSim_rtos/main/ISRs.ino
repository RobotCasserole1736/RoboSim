/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: ISRs.cpp
// Description:  All functions for executing Interrupt-based Encoder emulation
//               
//
// Note: Shares a .h with the hardwareInterface functions
//
// Change History
//    Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/
//#define ISR_DEBUG_PRINT

/******************************************************************************/
/** HEADER INCLUDES                                                          **/
/******************************************************************************/
#include "hardwareInterface.h"

/******************************************************************************/
/** DATA DEFINITIONS                                                         **/
/******************************************************************************/

/******************************************************************************/
/** FUNCTIONS                                                                **/
/******************************************************************************/

////////////////////////////////////////////////////////////////////////////////
// void encoderInit() 
// Description: Initalizes encoder emulation data structures and pins. Starts
//              up a timer and attaches the encoderISR function to that timer
//
// Input Arguments: None
// Returns: None
////////////////////////////////////////////////////////////////////////////////
void encoderInit()
{
  
  int i;
  
  //set all encoder globals to init values
  for(i = 0; i < NUM_ENCODER_OUTPUTS; i++)
  {
    encoder_states[i] = ENCODER_DISABLED;
    encoder_periods[i] = 0; //Just initalize to zero for now, I guess...
    encoder_state_timers[i] = 0;
    pinMode(encoder_output_pin_numbers[i*2],OUTPUT); //setup encoder output pins as actual outputs
    pinMode(encoder_output_pin_numbers[i*2+1],OUTPUT);
    digitalWriteFast(encoder_output_pin_numbers[i*2], LOW); //start with everything at low voltage
    digitalWriteFast(encoder_output_pin_numbers[i*2+1], LOW);
    #ifdef ISR_DEBUG_PRINT
    Serial.println("Finished init of encoder!");
    #endif
  }
  
  // Timer1 is used by the RTOS, so don't use that one!
  // Set up arduino internal HW timer2 at the right period. 
  // Set up interrupts to be triggered on timer rollover
  // set up encoderISR to be called on each interrupt trigger
  FlexiTimer2::set((unsigned long)((double)ENCODER_INT_PERIOD_MS*10.0),0.0001, encoderISR); 
  // Actually kick off the timer running.
  FlexiTimer2::start();
   
}



////////////////////////////////////////////////////////////////////////////////
// void encoderISR() 
// Description: Function to be called each time Timer2 fires off.
//              Moves through a four-state state machine to emulate the 
//              quadrature encoder data outputs
//
// Input Arguments: None
// Returns: None
// Globals Read: Encoder tick periods
// Globals Written: Encoder output pin voltages
////////////////////////////////////////////////////////////////////////////////
void encoderISR()
{
  int i = 0;
  
  //next state variable
  unsigned char encoder_next_state = 0;
  
  //State machine implemented for each encoder
  for(i = 0; i < NUM_ENCODER_OUTPUTS; i++)
  {
    if(encoder_enabled[i] == false) //always disable encoder if requested
    {
      encoder_next_state = ENCODER_DISABLED;  
    }
    else if((encoder_state_timers[i] < encoder_periods[i]))
    {
      encoder_state_timers[i] = encoder_state_timers[i] + 1;
      encoder_next_state = encoder_states[i];
    }
    
    else //otherwise, move through states
    {
      encoder_state_timers[i] = 0;
      switch(encoder_states[i])
      {
        case ENCODER_DISABLED: //decide if to move out of disabled or not.
          if(encoder_enabled[i] == true)
            encoder_next_state = ENCODER_STATE_1;
          else
            encoder_next_state = ENCODER_DISABLED;
            
          digitalWriteFast(encoder_output_pin_numbers[i*2], LOW); //might be able to make this double-write faster
          digitalWriteFast(encoder_output_pin_numbers[i*2+1], LOW);
        break;
        
        case ENCODER_STATE_1:
          if(encoder_directions[i] == ENCODER_DIR_FWD)
            encoder_next_state = ENCODER_STATE_2;
          else
            encoder_next_state = ENCODER_STATE_4;
            
          digitalWriteFast(encoder_output_pin_numbers[i*2], LOW); //might be able to make this double-write faster
          digitalWriteFast(encoder_output_pin_numbers[i*2+1], LOW);

        break;
        
        case ENCODER_STATE_2:
          if(encoder_directions[i] == ENCODER_DIR_FWD)
            encoder_next_state = ENCODER_STATE_3;
          else
            encoder_next_state = ENCODER_STATE_1;
            
          digitalWriteFast(encoder_output_pin_numbers[i*2], LOW); //might be able to make this double-write faster
          digitalWriteFast(encoder_output_pin_numbers[i*2+1], HIGH);
  
        break;
        
        case ENCODER_STATE_3:
          if(encoder_directions[i] == ENCODER_DIR_FWD)
            encoder_next_state = ENCODER_STATE_4;
          else
            encoder_next_state = ENCODER_STATE_2;
            
          digitalWriteFast(encoder_output_pin_numbers[i*2], HIGH); //might be able to make this double-write faster
          digitalWriteFast(encoder_output_pin_numbers[i*2+1], HIGH);
        break;
        
        
        case ENCODER_STATE_4:
          if(encoder_directions[i] == ENCODER_DIR_FWD)
            encoder_next_state = ENCODER_STATE_1;
          else
            encoder_next_state = ENCODER_STATE_3;
            
          digitalWriteFast(encoder_output_pin_numbers[i*2], HIGH); //might be able to make this double-write faster
          digitalWriteFast(encoder_output_pin_numbers[i*2+1], LOW);
        break;
        
        default:
          encoder_next_state = ENCODER_DISABLED; //not sure if this is the right action? how do we error recovery????
        
        break;  
      }
    }
    
    encoder_states[i] = encoder_next_state;
   
  }
}
