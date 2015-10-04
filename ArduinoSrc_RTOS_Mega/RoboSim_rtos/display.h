/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: display.h
// Description:  - Header for code which interfaces with the onboard display
//
//  Change History:
//      Chris Gerth - 04Oct2015 - Created
//
/******************************************************************************/

#ifndef DISPLAY_H
#define DISPLAY_H

#include "Adafruit_GFX.h"
#include "Adafruit_SSD1306.h"
#include "hardwareInterface.h"
#include "memory_monitor.h"

#define OLED_RESET_PIN 22
Adafruit_SSD1306 display(OLED_RESET_PIN);

#define NUMFLAKES 10
#define XPOS 0
#define YPOS 1
#define DELTAY 2

#define LOGO16_GLCD_HEIGHT 16 
#define LOGO16_GLCD_WIDTH  16 

#if (SSD1306_LCDHEIGHT != 32)
#error("Height incorrect, please fix Adafruit_SSD1306.h!");
#endif

static const unsigned char PROGMEM chef_hat_logo_bmp[] =
{ B00000111, B11110000,
  B00011001, B00001100,
  B01110010, B00000011,
  B11000010, B00000101,
  B01110000, B00001001,
  B11001000, B00000001,
  B10000100, B00000011,
  B01100000, B00000010,
  B00111100, B00000010,
  B01000010, B00100110,
  B01100000, B01001100,
  B00111000, B01001000,
  B00001110, B01001000,
  B00000011, B11111000,
  B00000001, B10000100,
  B00000000, B11111100 };
  

//Function Headers
extern void display_init();
extern void display_boot_screen();
extern void display_update();
extern void display_disp_msg(char *);

#endif //ifndef DISPLAY_H