/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: RoboSim.ino
// Description:  - Main entry functions for Arduino
//               - Performs all setup actions and contains main control loop
//
//  Change History:
//      Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/

/******************************************************************************/
/** HEADER INCLUDES                                                          **/
/******************************************************************************/
#include "hardwareInterface.h"
#include "plant.h"
#include "display.h"
#include "FreeRTOS_AVR.h"

//#define ENABLE_TASK_DEBUG_PRINT

/******************************************************************************/
/** DATA DEFINITIONS                                                         **/
/******************************************************************************/


/******************************************************************************/
/** FUNCTIONS                                                                **/
/******************************************************************************/

////////////////////////////////////////////////////////////////////////////////
// static void vPCSerialTx()
// Description: RTOS Task for transmitting serial packets to the PC
//
//
// Input Arguments: pvParameters - not used
// Returns: None
////////////////////////////////////////////////////////////////////////////////
static void vPCSerialTx(void *pvParameters) {
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = (TickType_t)round(SERIAL_TX_TASK_RATES_S * ((double)configTICK_RATE_HZ)); //calculate number of RTOS scheduler ticks to wait 
  xLastWakeTime = xTaskGetTickCount();

  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("Done Initalizing TX Task");
  Serial.flush();
  #endif 
  
  
  for(;;)
  {
    vTaskDelayUntil( &xLastWakeTime, xFrequency );
    //send packet back to PC
    send_packet_to_pc();
    #ifdef ENABLE_TASK_DEBUG_PRINT
    Serial.println("Finished loop of Tx");
    Serial.flush();
    #endif 
  }
}

////////////////////////////////////////////////////////////////////////////////
// static void vPCSerialRx()
// Description: RTOS Task for recieving serial packets from the PC
//
//
// Input Arguments: pvParameters - not used
// Returns: None
////////////////////////////////////////////////////////////////////////////////
static void vPCSerialRx(void *pvParameters) {
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = (TickType_t)round(SERIAL_RX_TASK_RATES_S * ((double)configTICK_RATE_HZ)); //calculate number of RTOS scheduler ticks to wait 
  xLastWakeTime = xTaskGetTickCount();
  
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("Done Initalizing RX Task");
  Serial.flush();
  #endif 
  
  for(;;)
  {
    //recieve packet ("blocking", but let RTOS run in background)
    //TODO: This way of doing it is clunky. This is bad coding practice, because
    // it cannot be statically determined that this while loop will ever exit.
    // Additionally, this yeilding is what the scheduler should be doing, not us.
    // Preferred method would be to just attempt to get the packet, and do nothing if
    // there's not packet available. WIll require testing to ensure that's possible,
    // and doesn't hose up any other functionality.
    vTaskDelayUntil( &xLastWakeTime, xFrequency );
    while(get_packet_from_pc() == -1)
    {
        vTaskDelayUntil( &xLastWakeTime, 1);
    } 
    #ifdef ENABLE_TASK_DEBUG_PRINT
    Serial.println("Finished loop of Rx");
    Serial.flush();
    #endif 
  }
}

////////////////////////////////////////////////////////////////////////////////
// static void vHWIOSample()
// Description: RTOS Task for sampling hardware inputs, and setting 
//              hardware outputs
//
//
// Input Arguments: pvParameters - not used
// Returns: None
////////////////////////////////////////////////////////////////////////////////
static void vHWIOSample(void *pvParameters) {
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = (TickType_t)round(HW_IO_SAMPLE_TASK_RATES_S * ((double)configTICK_RATE_HZ)); //calculate number of RTOS scheduler ticks to wait   
  xLastWakeTime = xTaskGetTickCount();
  
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("done initializing hwiosample");
  Serial.flush();
  #endif
  
  for(;;)
  {
    vTaskDelayUntil( &xLastWakeTime, xFrequency );
    //Acquire input & set output
    //these functions will write values to global variables
    sample_motor_values(); //motor vals - input only
    io_card_exchange_data(); // IO card - input and output
    #ifdef ENABLE_TASK_DEBUG_PRINT
    Serial.println("Finished loop of HWIO sample");
    Serial.flush();
    #endif
  }
}

////////////////////////////////////////////////////////////////////////////////
// static void vPlantRunLoop() 
// Description: RTOS task for executing an on-arduino plant model
//
//
// Input Arguments: pvParameters - not used
// Returns: None
////////////////////////////////////////////////////////////////////////////////
static void vPlantRunLoop(void *pvParameters) {
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = (TickType_t)round(PLANT_LOOP_TASK_RATES_S * ((double)configTICK_RATE_HZ)); //calculate number of RTOS scheduler ticks to wait   
  xLastWakeTime = xTaskGetTickCount();
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("done initalizing plant task");
  Serial.flush();
  #endif 
  for(;;)
  {
    vTaskDelayUntil( &xLastWakeTime, xFrequency );
    //run plant model
    plant_periodic_loop();
  }
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("Finished loop of Plant");
  Serial.flush();
  #endif 
}

////////////////////////////////////////////////////////////////////////////////
// static void vDisplayUpdate()
// Description: RTOS task for updating content displayed on the OLED display
//
//
// Input Arguments: pvParameters - not used
// Returns: None
////////////////////////////////////////////////////////////////////////////////
static void vDisplayUpdate(void *pvParameters) {
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = (TickType_t)round(DISPLAY_UPDATE_TASK_RATES_S * ((double)configTICK_RATE_HZ)); //calculate number of RTOS scheduler ticks to wait   
  xLastWakeTime = xTaskGetTickCount();
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("done initalizing display update task");
  Serial.flush();
  #endif 
  for(;;)
  {
    vTaskDelayUntil( &xLastWakeTime, xFrequency );
    //Update display
    display_calc_screen_index();
    display_update();
  }
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("Finished loop of display update");
  Serial.flush();
  #endif 
}


////////////////////////////////////////////////////////////////////////////////
// void setup() 
// Description: Initalize function required by arduino. Main entry point of the
//              SW after bootloader hands off execution control to user software.
//
// Input Arguments: None
// Returns: None
////////////////////////////////////////////////////////////////////////////////
void setup()
{
    // WHEN POWER IS APPLIED TO THE ARDUINO OR THE RESET BUTTON IS PRESSED,
    // THE SW EXECUTION STARTS RIGHT HERE!!!
    
    //init display
    display_init();
    display_boot_screen();
      
    //Open Serial port
    Serial.begin(115200, SERIAL_8E2); //config to 115200 baud, 8 data bits, even parity, 2 stop bits
    
    //start up encoders
    encoderInit();
    
    //start up motor inputs
    init_motor_inputs();
    
    //set up io cards
    init_io_card();
    
    #ifdef ENABLE_TASK_DEBUG_PRINT
    Serial.println("done with init");
    Serial.flush();
    #endif
    
    //set up rtos tasks (initalize data structures and stacks for them)
    // This will NOT start running them (yet), just defines what they should be.
    //Priorities go from tskIdle_Priority to configMAX_PRIORITIES
    //empirically determined stack sizes seems to be the minimum stack size usable
    //Only create a task if it is enabled.
    if(HW_IO_SAMPLE_TASK_ENABLE)
    {
        xTaskCreate(vHWIOSample, "HWIO", 350 , NULL, tskIDLE_PRIORITY + 10, NULL);
        #ifdef ENABLE_TASK_DEBUG_PRINT
        Serial.println("created HWIOSample task");
        Serial.flush();
        #endif
    }
    if(SERIAL_TX_TASK_ENABLE)
    {
        xTaskCreate(vPCSerialTx, "SerTx", 300, NULL, tskIDLE_PRIORITY + 8, NULL);
        #ifdef ENABLE_TASK_DEBUG_PRINT
        Serial.println("created tx task");
        Serial.flush();
        #endif
    }
    if(SERIAL_RX_TASK_ENABLE)
    {
        xTaskCreate(vPCSerialRx, "SerRx", 300, NULL, tskIDLE_PRIORITY + 6, NULL);
        #ifdef ENABLE_TASK_DEBUG_PRINT
        Serial.println("created rx task");
        Serial.flush();
        #endif
    }
    if(DISPLAY_UPDATE_TASK_ENABLE)
    {
        xTaskCreate(vDisplayUpdate, "DispUpd", 500, NULL, tskIDLE_PRIORITY + 2, NULL);
        #ifdef ENABLE_TASK_DEBUG_PRINT
        Serial.println("created display update task");
        Serial.flush();
        #endif
    }
    if(PLANT_LOOP_TASK_ENABLE)
    {
        xTaskCreate(vPlantRunLoop, "PlantMdl", 500, NULL, tskIDLE_PRIORITY + 7, NULL);
        #ifdef ENABLE_TASK_DEBUG_PRINT
        Serial.println("created plant model update task");
        Serial.flush();
        #endif
    }
    
    
    
    // start RTOS
    #ifdef ENABLE_TASK_DEBUG_PRINT
    Serial.println("Starting Scheduler");
    Serial.flush();
    #endif
    vTaskStartScheduler();
    
    // Above function should never return
    // If it does, just hang out, I guess...
    while(1);
    //TODO: more robust thing could be to reset the system at this point?
    
}



////////////////////////////////////////////////////////////////////////////////
// void loop() 
// Description: minimal idle task loop
// it's got a tiny stack, so don't do anything here!!! :o
//
////////////////////////////////////////////////////////////////////////////////
void loop()
{
  while(1);
}

