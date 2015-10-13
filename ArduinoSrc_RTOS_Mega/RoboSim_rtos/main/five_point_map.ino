/******************************************************************************/
/******************************************************************************/
/**   COPYRIGHT (C) FRC TEAM 1736 ROBOT CASSEROLE 2015 ALL RIGHTS RESERVED   **/
/******************************************************************************/
/******************************************************************************/
// RoboSim - an Arduino-based, Hardware-in-the-loop Robot simulation platform
//
// File: five_point_map.ino
// Description:  - re-scale map for analog inputs
//
//  Change History:
//      Chris Gerth - 20Mar2015 - Created
//
/******************************************************************************/
//#define HWIO_DEBUG_PRINT

#include "five_point_map.h"

////////////////////////////////////////////////////////////////////////////////
// double five_point_map() 
// Description: map input value to output value. saturate outside the output range, 
//              linearly interpolate between points. 
//
// Input Arguments: int input - input value to remap
//                  input_map_pts - pointer to 5-length array of input cutoff points
//                  output_map_pts - pointer to 5-length array of output values
// Output: double - remapped
// Globals Read: None
// Globals Written: NOne
////////////////////////////////////////////////////////////////////////////////

double five_point_map(uint16_t input, const uint16_t * input_map_pts, const double * output_map_pts)
{
    if(input <= input_map_pts[0])
        return output_map_pts[0]; //saturate
    else if(input > input_map_pts[0] &input <= input_map_pts[1]) //internal - use a modified point slope formula for the line (y = m(x-x1) + y1)
        return (output_map_pts[1] - output_map_pts[0])/((double)(input_map_pts[1]-input_map_pts[0])) * (double)(input - input_map_pts[0]) + output_map_pts[0]; 
    else if(input > input_map_pts[1] &input <= input_map_pts[2]) //internal - use a modified point slope formula for the line (y = m(x-x1) + y1)
        return (output_map_pts[2] - output_map_pts[1])/((double)(input_map_pts[2]-input_map_pts[1])) * (double)(input - input_map_pts[1]) + output_map_pts[1]; 
    else if(input > input_map_pts[2] &input <= input_map_pts[3]) //internal - use a modified point slope formula for the line (y = m(x-x1) + y1)
        return (output_map_pts[3] - output_map_pts[2])/((double)(input_map_pts[3]-input_map_pts[2])) * (double)(input - input_map_pts[2]) + output_map_pts[2]; 
    else if(input > input_map_pts[3] &input <= input_map_pts[4]) //internal - use a modified point slope formula for the line (y = m(x-x1) + y1)
        return (output_map_pts[4] - output_map_pts[3])/((double)(input_map_pts[4]-input_map_pts[3])) * (double)(input - input_map_pts[3]) + output_map_pts[3]; 
    else if(input > input_map_pts[4])
        return output_map_pts[4]; //saturate  
}
