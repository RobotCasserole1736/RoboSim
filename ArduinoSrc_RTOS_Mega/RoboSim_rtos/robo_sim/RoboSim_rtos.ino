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
#include "hardwareInterface.h"
#include "plant.h"
#include "display.h"
#include "FreeRTOS_AVR.h"

//#define ENABLE_TASK_DEBUG_PRINT

////////////////////////////////////////////////////////////////////////////////
// Top-Level Global Data
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Loop() global variables
////////////////////////////////////////////////////////////////////////////////
int plant_running_led_counter = 0;
boolean plant_running_led_state = false;


static void vPCSerialTx(void *pvParameters) {
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = (TickType_t)round(0.1 * ((double)configTICK_RATE_HZ)); //calculate number of RTOS scheduler ticks to wait 
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

static void vPCSerialRx(void *pvParameters) {
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = (TickType_t)round(0.08 * ((double)configTICK_RATE_HZ)); //calculate number of RTOS scheduler ticks to wait 
  xLastWakeTime = xTaskGetTickCount();
  
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("Done Initalizing RX Task");
  Serial.flush();
  #endif 
  
  for(;;)
  {
    vTaskDelayUntil( &xLastWakeTime, xFrequency );
    //recieve packet (blocking, but let RTOS run in background)
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

static void vHWIOSample(void *pvParameters) {
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = (TickType_t)round(0.1 * ((double)configTICK_RATE_HZ)); //calculate number of RTOS scheduler ticks to wait   
  xLastWakeTime = xTaskGetTickCount();
  
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("done initializing hwiosample");
  Serial.flush();
  #endif
  
  for(;;)
  {
    vTaskDelayUntil( &xLastWakeTime, xFrequency );
    //Acquire input & output
    sample_motor_values();
    io_card_exchange_data();
    #ifdef ENABLE_TASK_DEBUG_PRINT
    Serial.println("Finished loop of HWIO sample");
    Serial.flush();
    #endif
  }
}

static void vPlantRunLoop(void *pvParameters) {
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = (TickType_t)round(0.1 * ((double)configTICK_RATE_HZ)); //calculate number of RTOS scheduler ticks to wait   
  xLastWakeTime = xTaskGetTickCount();
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("done initalizing plant task");
  Serial.flush();
  #endif 
  for(;;)
  {
    vTaskDelayUntil( &xLastWakeTime, xFrequency );
    //run plant model (if any)
    plant_periodic_loop();
  }
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("Finished loop of Plant");
  Serial.flush();
  #endif 
}

static void vDisplayUpdate(void *pvParameters) {
  TickType_t xLastWakeTime;
  const TickType_t xFrequency = (TickType_t)round(0.2 * ((double)configTICK_RATE_HZ)); //calculate number of RTOS scheduler ticks to wait   
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
// Description: Initalize function required by arduino.
//
// Input Arguments: None
// Output: None
// Globals Read: None
// Globals Written: None
////////////////////////////////////////////////////////////////////////////////
void setup()
{
  //init display
  display_init();
  display_boot_screen();
    
  //Open Serial port
  Serial.begin(115200, SERIAL_8E2); //config to 8 data bits, even parity, 2 stop bits
  //ensure it will actually run
  
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
  
  //set up rtos tasks
  //Priorities go from tskIdle_Priority to configMAX_PRIORITIES (0 to 4)
  //empirically determined stack sizes seems to be the minimum stack size usable
  xTaskCreate(vHWIOSample, "HWIO", 350 , NULL, tskIDLE_PRIORITY + 10, NULL);
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("created HWIOSample task");
  Serial.flush();
  #endif
  xTaskCreate(vPCSerialTx, "SerTx", 300, NULL, tskIDLE_PRIORITY + 8, NULL);
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("created tx task");
  Serial.flush();
  #endif
  xTaskCreate(vPCSerialRx, "SerRx", 300, NULL, tskIDLE_PRIORITY + 6, NULL);
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("created rx task");
  Serial.flush();
  #endif
  xTaskCreate(vDisplayUpdate, "DispUpd", 500, NULL, tskIDLE_PRIORITY + 2, NULL);
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("created display update task");
  Serial.flush();
  #endif
  
  
  
  // start RTOS
  #ifdef ENABLE_TASK_DEBUG_PRINT
  Serial.println("Starting Scheduler");
  Serial.flush();
  #endif
  vTaskStartScheduler();

  // should never return
  Serial.println(F("Die"));
  while(1);
  
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

