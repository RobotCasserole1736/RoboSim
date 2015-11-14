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

/******************************************************************************/
/** HEADER INCLUDES                                                          **/
/******************************************************************************/
#include <SPI.h>
#include <Wire.h>
#include "display.h"
#include <math.h>

/******************************************************************************/
/** DATA DEFINITIONS                                                         **/
/******************************************************************************/
unsigned char display_screen_index; //which status screen should be shown?


/******************************************************************************/
/** FUNCTIONS                                                                **/
/******************************************************************************/

////////////////////////////////////////////////////////////////////////////////
// void display_init()
// Description: Initalize function for the OLED display. Sets up internal
//              data structures, transmits the initial setup i2c commands
//              to the screen, resets the internal display buffer, and sets
//              the screen to display the now-blank buffer
//
// Input Arguments: None
// Returns:
////////////////////////////////////////////////////////////////////////////////
void display_init()
{

  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);  // initialize with the I2C addr 0x3C (for the 128x32)
  // init done
  
  // Clear the buffer.
  display.clearDisplay();
  display.display();
    
}

///////////////////////////////////////////////////////////////////////////////
// void display_boot_screen()
// Description: Writes a booting splash screen to the display buffer, sets
//              the screen to display it, then waits for 1 second to ensure the
//              user sees it.
//         Note: the use of the delay function is not process-safe. This 
//         function should only be called during initilization, not during
//         any OS-managed process.
//
// Input Arguments: None
// Returns: None
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
// Description: Draws textual info onto the screen. What info is drawn depends 
//              on the value of display_screen_index.
//
// Input Arguments: None
// Returns: None
////////////////////////////////////////////////////////////////////////////////
void display_update()
{
  int i = 0;  
    
  display.clearDisplay();
  
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0,0);
  
  //Always draw a line to indicate the status of the PC connection
  if(pc_connected)
    display.println("PC Host Connected");
  else
    display.println("PC Host Disconnected");
      
  //Draw different content on the remaining 3 lines depending on the 
  // value of display_screen_index. Each case defines a different
  // "page" to display.
  
  switch (display_screen_index){
      case 0: //Packet counter
        display.println("~~Packet Counts");
        display.print("RX: ");
        display.println(rx_packet_count);
        display.print("TX: ");
        display.println(tx_packet_count);
      break;
      
      case 1: //Motor voltages pg 1
        display.print("~~Motor Voltages");
        display.setCursor(0,16);
        display.print("M1:");
        display.print(get_motor_in_voltage(0), 2);
        display.setCursor(0,24);
        display.print("M3:");
        display.println(get_motor_in_voltage(2), 2);
        display.setCursor(64,16);
        display.print("M2:");
        display.print(get_motor_in_voltage(1), 2);
        display.setCursor(64,24);
        display.print("M4:");
        display.print(get_motor_in_voltage(3), 2);
      break;
      
      case 2: //Motor Voltages pg 2
        display.print("~~Motor Voltages");
        display.setCursor(0,16);
        display.print("M5:");
        display.print(get_motor_in_voltage(4), 2);
        display.setCursor(0,24);
        display.print("M7:");
        display.println("N/A"); //M7 not currently an input
        display.setCursor(64,16);
        display.print("M6:");
        display.print(get_motor_in_voltage(5), 2);
        display.setCursor(64,24);
        display.print("M8:");
        display.print("N/A"); //M8 not currently an input
      break;
      
      case 3: //Digital Solenoid input statuses
        display.println("~~Solenoid Inputs");
        display.println("0 1 2 3 4 5 6 7");
        for(i = 0;i < NUM_IO_CARDS*8; i++)
        {
            display.print(digital_inputs[i]);
            display.print(" ");
        }
      break;
      
      case 4: //Analog output voltages
        display.println("~~Analog Outputs");
        display.print("AO1: ");
        display.print(analog_outputs[0], 2);
        display.println("V");
        display.print("AO2: ");
        display.print(analog_outputs[1], 2);
        display.println("V");
      break;
      
      case 5: //Digital 0-5V output statuses
        display.println("~~Digital Outputs");
        display.println("0 1 2 3 4 5 6 7");
        for(i = 0;i < NUM_IO_CARDS*8; i++)
        {
            display.print(digital_outputs[i]);
            display.print(" ");
        }
      break;
      
      case 6: //Encoder Periods pg 1
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
      
      case 7: //Encoder Periods pg 2
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
      
     case 8: //Screensaver
        display_screensaver_update();
      break;
      
      case 245: //System status setup. TODO: make these sections work
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

      default: //Default: Error message
          display.println("ERR: Unknown display page requested");
      break;
  }

  
  display.display(); //actually write the text defined above to the screen
    
    
}

////////////////////////////////////////////////////////////////////////////////
// void display_calc_screen_index()
// Description: Calculates the next screen index. Currently just cycles through
//              most of the available pages. Future functionality is to tie
//              screen switching to a user input control
//
// Input Arguments: None
// Returns: None
////////////////////////////////////////////////////////////////////////////////
void display_calc_screen_index()
{
    const int delay_loops = 10; //Number of loops to display each page for
    const int max_display_screen_index = 8; //Iterate from page 0 up to this page #
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
    
    
}////////////////////////////////////////////////////////////////////////////////
// void display_disp_msg()
// Description: Print a messasge to screen. Useful for program reporting info.
//
// Input Arguments: msg - ascii text string to print
// Returns: None
////////////////////////////////////////////////////////////////////////////////
void display_disp_msg(char * msg)
{
  display.clearDisplay();
  
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0,0);
  display.println(msg);
  
  display.display();
    
    
}////////////////////////////////////////////////////////////////////////////////
// void display_screensaver_update()
// Description: update and display bouncing hats for a "screensaver". There are 
//              lots of fudge parameters to get this simulation of 2d motion 
//              and colissions of spherical objects to look nice. 
//
//              Warning to beginner programmers: This function was written as
//              a fun weekend project only. It has no real value within RoboSim.
//              There's lots of code which appears arbitrary unless you know the
//              underlying physics, and even then...yah... If I were you I wouldn't
//              even bother looking at this funciton. Save yourself the confusion, 
//              Move along, nothing to see here. This is not the function you 
//              are looking for.
//              
//
// Input Arguments: none
// Returns: None
////////////////////////////////////////////////////////////////////////////////
void display_screensaver_update(void)
{
  //Consider each hat as a ball of radius 'hat_radius'
  const int hat_radius = 8;
  
  //Fudge-factor to get the speed looking nice
  const double speed_scale = 0.5;
  
  //Mass of each hat. Only difference between masses for
  //the hats matters, as this is only used to calculate
  //the conservation-of-momentum equations
  const double hat_1_mass = 2;
  const double hat_2_mass = 2;
  
  //define physical boundaries to constrain the hats
  const int top_wall_limit = 0;
  const int bottom_wall_limit = 31;
  const int left_wall_limit = 0;
  const int right_wall_limit = 127;
  
  //Initial positions and veloctieis of each hat.
  static double hat_1_pos_x = 30;
  static double hat_1_pos_y = 8;
  static double hat_1_vel_x = 3;
  static double hat_1_vel_y = 1;
  
  static double hat_2_pos_x = 100;
  static double hat_2_pos_y = 13;
  static double hat_2_vel_x = -2;
  static double hat_2_vel_y = 3;
  
  //State variables
  static char prev_hats_in_contact = 0;
  char hats_in_contact = 0;
  char hat_collision_occurred = 0;
  double A = 0; //angle of collision
  
  display.clearDisplay();
  
  //The following is a textbook impelementation of two spherical
  //objects undergoing elastic collisions with walls and eachother.
  
  //wall collisions are simpler - just invert the velocity.
  //Hat 1:
  if(hat_1_pos_y - hat_radius < top_wall_limit)
  {
      hat_1_vel_y = -hat_1_vel_y;
      hat_1_pos_y = top_wall_limit + hat_radius;
  }
  else if(hat_1_pos_y + hat_radius > bottom_wall_limit)
  {
      hat_1_vel_y = -hat_1_vel_y;
      hat_1_pos_y = bottom_wall_limit - hat_radius;
  }
  if(hat_1_pos_x - hat_radius < left_wall_limit)
  {
      hat_1_vel_x = -hat_1_vel_x;
      hat_1_pos_x = left_wall_limit + hat_radius;
  }
  else if(hat_1_pos_x + hat_radius > right_wall_limit)
  {
      hat_1_vel_x = -hat_1_vel_x;
      hat_1_pos_x = right_wall_limit - hat_radius;
  }
  
  //Hat 2:
  if(hat_2_pos_y - hat_radius < top_wall_limit)
  {
      hat_2_vel_y = -hat_2_vel_y;
      hat_2_pos_y = top_wall_limit + hat_radius;
  }
  else if(hat_2_pos_y + hat_radius > bottom_wall_limit)
  {
      hat_2_vel_y = -hat_2_vel_y;
      hat_2_pos_y = bottom_wall_limit - hat_radius;
  }
  if(hat_2_pos_x - hat_radius < left_wall_limit)
  {
      hat_2_vel_x = -hat_2_vel_x;
      hat_2_pos_x = left_wall_limit + hat_radius;
  }
  else if(hat_2_pos_x + hat_radius > right_wall_limit)
  {
      hat_2_vel_x = -hat_2_vel_x;
      hat_2_pos_x = right_wall_limit - hat_radius;
  }
  
  //Determine if hats are colliding with eachother
  if(sqrt(pow((hat_1_pos_x - hat_2_pos_x),2) + pow((hat_1_pos_y - hat_2_pos_y),2)) < 2*hat_radius)
      hats_in_contact = 1;
  else
      hats_in_contact = 0;

  if(hats_in_contact == 1 & prev_hats_in_contact == 0)
      hat_collision_occurred = 1;
  else
      hat_collision_occurred = 0;
  
  prev_hats_in_contact = hats_in_contact;
  
  //handle hat collision
  if(hat_collision_occurred)
  {
    //Note new variables are added here only if a collision has happened.
    //This should reduce average memory usage, but cause noticeable spikes
    //during collisions. If the OS crashes while running the screensaver, 
    //when hats collide, this is likely the reason.
    double magnitude_1;
    double magnitude_2;
    double direction_1;
    double direction_2;
    
    double new_xspeed_1;
    double new_yspeed_1;
    double new_xspeed_2;
    double new_yspeed_2;
    
    double final_xspeed_1;
    double final_xspeed_2;
    double final_yspeed_1;
    double final_yspeed_2;
    
    double dx;
    double dy;
    
    // something something physics something something
    dx = hat_1_pos_x-hat_2_pos_x;
    dy = hat_1_pos_y-hat_2_pos_y;
    A = atan2(dy, dx);
    magnitude_1 = sqrt(hat_1_vel_x*hat_1_vel_x+hat_1_vel_y*hat_1_vel_y);
    magnitude_2 = sqrt(hat_2_vel_x*hat_2_vel_x+hat_2_vel_y*hat_2_vel_y);
    direction_1 = atan2(hat_1_vel_y, hat_1_vel_x);
    direction_2 = atan2(hat_2_vel_y, hat_2_vel_x);
    new_xspeed_1 = magnitude_1*cos(direction_1-A);
    new_yspeed_1 = magnitude_1*sin(direction_1-A);
    new_xspeed_2 = magnitude_2*cos(direction_2-A);
    new_yspeed_2 = magnitude_2*sin(direction_2-A);
    final_xspeed_1 = ((hat_1_mass-hat_2_mass)*new_xspeed_1+(hat_2_mass+hat_2_mass)*new_xspeed_2)/(hat_1_mass+hat_2_mass);
    final_xspeed_2 = ((hat_1_mass+hat_1_mass)*new_xspeed_1+(hat_2_mass-hat_1_mass)*new_xspeed_2)/(hat_1_mass+hat_2_mass);
    final_yspeed_1 = new_yspeed_1;
    final_yspeed_2 = new_yspeed_2;
    hat_1_vel_x = cos(A)*final_xspeed_1+cos(A+3.14159/2)*final_yspeed_1;
    hat_1_vel_y = sin(A)*final_xspeed_1+sin(A+3.14159/2)*final_yspeed_1;
    hat_2_vel_x = cos(A)*final_xspeed_2+cos(A+3.14159/2)*final_yspeed_2;
    hat_2_vel_y = sin(A)*final_xspeed_2+sin(A+3.14159/2)*final_yspeed_2;
  }
  

  
  //update Position
  hat_1_pos_x += hat_1_vel_x * speed_scale;
  hat_1_pos_y += hat_1_vel_y * speed_scale;
  hat_2_pos_x += hat_2_vel_x * speed_scale;
  hat_2_pos_y += hat_2_vel_y * speed_scale;
  
  //draw hats
  display.drawBitmap(hat_1_pos_x-hat_radius, hat_1_pos_y-hat_radius, chef_hat_logo_bmp, 16, 16, 1);
  display.drawBitmap(hat_2_pos_x-hat_radius, hat_2_pos_y-hat_radius, chef_hat_logo_bmp, 16, 16, 1);
  display.display();
    
    
}
