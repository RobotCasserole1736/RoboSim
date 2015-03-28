/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: ISRs.cpp
// Description:  - Main entry function for Arduino
//               - Performs all setup actions and contains main control loop
//
// Note: Shares a .h with the hardwareInterface functions
//
// Change History
//    Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/

#include "hardwareInterface.h"


////////////////////////////////////////////////////////////////////////////////
// void encoderInit() 
// Description: Initalizes encoder emulation module
//
// Input Arguments: None
// Output: None
// Globals Read: None?
// Globals Written: None?
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
    digitalWrite(encoder_output_pin_numbers[i*2], LOW); //start with everything at low voltage
    digitalWrite(encoder_output_pin_numbers[i*2+1], LOW);
    Serial.println("Finished init of encoder!");
  }
  
  Timer1.initialize(ENCODER_INT_PERIOD_MS*1000); // kick off timer1 at the right period
  Timer1.detachInterrupt();
  Timer1.attachInterrupt(encoderISR); //fire off the function at the right intervals
   
}



////////////////////////////////////////////////////////////////////////////////
// void encoderISR() 
// Description: Function to be called each time Timer1 fires off.
//              Moves through a four-state state machine to emulate the 
//              quadrature encoder data outputs
//
// Input Arguments: None
// Output: None
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
            
          digitalWrite(encoder_output_pin_numbers[i*2], LOW);
          digitalWrite(encoder_output_pin_numbers[i*2+1], LOW);
        break;
        
        case ENCODER_STATE_1:
          if(encoder_directions[i] == ENCODER_DIR_FWD)
            encoder_next_state = ENCODER_STATE_2;
          else
            encoder_next_state = ENCODER_STATE_4;
            
          digitalWrite(encoder_output_pin_numbers[i*2], LOW); //might be able to make this double-write faster
          digitalWrite(encoder_output_pin_numbers[i*2+1], LOW);

        break;
        
        case ENCODER_STATE_2:
          if(encoder_directions[i] == ENCODER_DIR_FWD)
            encoder_next_state = ENCODER_STATE_3;
          else
            encoder_next_state = ENCODER_STATE_1;
            
          digitalWrite(encoder_output_pin_numbers[i*2], LOW); //might be able to make this double-write faster
          digitalWrite(encoder_output_pin_numbers[i*2+1], HIGH);
  
        break;
        
        case ENCODER_STATE_3:
          if(encoder_directions[i] == ENCODER_DIR_FWD)
            encoder_next_state = ENCODER_STATE_4;
          else
            encoder_next_state = ENCODER_STATE_2;
            
          digitalWrite(encoder_output_pin_numbers[i*2], HIGH); //might be able to make this double-write faster
          digitalWrite(encoder_output_pin_numbers[i*2+1], HIGH);
        break;
        
        
        case ENCODER_STATE_4:
          if(encoder_directions[i] == ENCODER_DIR_FWD)
            encoder_next_state = ENCODER_STATE_1;
          else
            encoder_next_state = ENCODER_STATE_3;
            
          digitalWrite(encoder_output_pin_numbers[i*2], HIGH); //might be able to make this double-write faster
          digitalWrite(encoder_output_pin_numbers[i*2+1], LOW);
        break;
        
        default:
          encoder_next_state = ENCODER_DISABLED; //not sure if this is the right action? how do we error recovery????
        
        break;  
      }
    }
    
    encoder_states[i] = encoder_next_state;

    
  }
  
  
  
}
