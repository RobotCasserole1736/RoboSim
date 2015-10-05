/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: display.ino
// Description:  - Code which interfaces with the onboard display
//
//  Change History:
//      Chris Gerth - 04Oct2015 - Created
//
/******************************************************************************/

#include <SPI.h>
#include <Wire.h>
#include "display.h"

//global vars
unsigned char display_screen_index; //which status screen should be shown?

////////////////////////////////////////////////////////////////////////////////
// void display_init()
// Description: Initalize function for the OLED display
//
// Input Arguments: None
// Output: None
// Globals Read: None
// Globals Written: None
////////////////////////////////////////////////////////////////////////////////
void display_init()
{

  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);  // initialize with the I2C addr 0x3C (for the 128x32)
  // init done
  
  // Clear the buffer.
  display.clearDisplay();
  display.display();
    
}

////////////////////////////////////////////////////////////////////////////////
// void display_boot_screen()
// Description: Periodic function to update the contents of the display
//
// Input Arguments: None
// Output: None
// Globals Read: None
// Globals Written: None
////////////////////////////////////////////////////////////////////////////////
void display_boot_screen()
{
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(20,0);
  display.println("1736 RoboSim");
  display.setCursor(24,16);
  display.println("Booting...");
  display.drawBitmap(1, 8, chef_hat_logo_bmp, 16, 16, 1);
  display.display();
  delay(1000);
    
    
}


////////////////////////////////////////////////////////////////////////////////
// void display_update()
// Description: Periodic function to update the contents of the display
//
// Input Arguments: None
// Output: None
// Globals Read: None
// Globals Written: None
////////////////////////////////////////////////////////////////////////////////
void display_update()
{
  int i = 0;  
    
  display.clearDisplay();
  
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0,0);
  if(pc_connected)
    display.println("PC Host Connected");
  else
    display.println("PC Host Disconnected");
      
  display_screen_index = 6; //debug
  switch (display_screen_index){
      case 0:
        display.println("~~Packet Counts");
        display.print("RX: ");
        display.println(rx_packet_count);
        display.print("TX: ");
        display.println(tx_packet_count);
      break;
      
      case 1:
        display.print("~~Motor Voltages");
        display.setCursor(0,16);
        display.print("M1:");
        display.print(get_motor_in_voltage(0), 2);
        display.setCursor(0,24);
        display.print("M3:");
        display.println(get_motor_in_voltage(1), 2);
        display.setCursor(64,16);
        display.print("M2:");
        display.print(get_motor_in_voltage(2), 2);
        display.setCursor(64,24);
        display.print("M4:");
        display.print(get_motor_in_voltage(3), 2);
      break;
      
      case 2:
        display.print("~~Motor Voltages");
        display.setCursor(0,16);
        display.print("M5:");
        display.print(get_motor_in_voltage(4), 2);
        display.setCursor(0,24);
        display.print("M7:");
        display.println("N/A");
        display.setCursor(64,16);
        display.print("M6:");
        display.print(get_motor_in_voltage(5), 2);
        display.setCursor(64,24);
        display.print("M8:");
        display.print("N/A");
      break;
      
      case 3:
        display.println("~~Solenoid Inputs");
        display.println("0 1 2 3 4 5 6 7");
        for(i = 0;i < NUM_IO_CARDS*8; i++)
        {
            display.print(digital_inputs[i]);
            display.print(" ");
        }
      break;
      
      case 4:
        display.println("~~Analog Outputs");
        display.print("AO1: ");
        display.print(analog_outputs[0], 2);
        display.println("V");
        display.print("AO2: ");
        display.print(analog_outputs[1], 2);
        display.println("V");
      break;
      
      case 5:
        display.println("~~Digital Outputs");
        display.println("0 1 2 3 4 5 6 7");
        for(i = 0;i < NUM_IO_CARDS*8; i++)
        {
            display.print(digital_outputs[i]);
            display.print(" ");
        }
      break;
      
      case 6:
        display.println("~~Encoder Periods");
        display.print("E1:");
        if(encoder_enabled[0])
            display.print((double)(encoder_periods[0]*4*ENCODER_INT_PERIOD_MS));
        else
            display.print("inf ");
        display.println("ms");
        display.print("E2:");
        if(encoder_enabled[1])
            display.print((double)(encoder_periods[1]*4*ENCODER_INT_PERIOD_MS));
        else
            display.print("inf ");
        display.println("ms");
      break;
      
      case 7:
        display.println("~~Encoder Periods");
        display.print("E3:");
        if(encoder_enabled[2])
            display.print((double)(encoder_periods[2]*4*ENCODER_INT_PERIOD_MS));
        else
            display.print("inf ");
        display.println("ms");
        display.print("E4:");
        if(encoder_enabled[3])
            display.print((double)(encoder_periods[3]*4*ENCODER_INT_PERIOD_MS));
        else
            display.print("inf ");
        display.println("ms");
      break;
      
      case 8:
        display.println("~~System Status");
        //display.print("Mem Usage: "); //This doesn't seem to be working at the moment...
        //display.print(calc_memory_usage_pct(), 1);
        //display.println("%");
      break;
      
      case 255: //logos everywhere!
        display.clearDisplay();
        display.drawBitmap(1 ,   2, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(18,   2, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(35,   2, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(52,   2, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(69,   2, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(86,   2, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(103,  2, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(1 ,  19, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(18,  19, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(35,  19, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(52,  19, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(69,  19, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(86,  19, chef_hat_logo_bmp, 16, 16, 1);
        display.drawBitmap(103, 19, chef_hat_logo_bmp, 16, 16, 1);
      break;

      default:
          display.println("Test of Display update...");
      break;
  }

  
  display.display(); //actually write the text defined above to the screen
    
    
}

////////////////////////////////////////////////////////////////////////////////
// void display_calc_screen_index()
// Description: Calculates the next screen index
//
// Input Arguments: None
// Output: None
// Globals Read: None
// Globals Written: None
////////////////////////////////////////////////////////////////////////////////
void display_calc_screen_index()
{
    const int delay_loops = 10;
    const int max_display_screen_index = 8;
    static int i = 0;
    
    if(i == delay_loops)
    {
        if(display_screen_index >= max_display_screen_index)
        {
            display_screen_index=0;
        }
        else
        {
            display_screen_index++;
        }
    }
    
    
    if(i >= delay_loops)
    {
        i = 0;
    }
    else
    {
        i++;
    }
    
    
}

////////////////////////////////////////////////////////////////////////////////
// void display_disp_msg()
// Description: Print a messasge to screen. Useful for program reporting info.
//
// Input Arguments: msg - ascii text string to print
// Output: None
// Globals Read: None
// Globals Written: None
////////////////////////////////////////////////////////////////////////////////
void display_disp_msg(char * msg)
{
  display.clearDisplay();
  
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0,0);
  display.println(msg);
  
  display.display();
    
    
}
