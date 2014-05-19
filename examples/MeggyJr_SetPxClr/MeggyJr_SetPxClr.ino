/*
  MeggyJr_SetPxClr - Meggy Jr RGB library for Arduino
  Version 1.0 - 11/01/2008       http://www.evilmadscientist.com/
  Copyright (c) 2008 Windell H. Oskay.  All right reserved.

    This library is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this library.  If not, see <http://www.gnu.org/licenses/>.
	 	
*/

/*

This example illustrates the SetPxClr routine, which directly writes to the
Meggy Jr video buffer, setting the color of an individual dot in the RGB matrix

It's a fairly low level function; beginners should probably start with the 
EasyDrawDots example instead.

You call this function as follows: 
   SetPxClr( x, y, rgb[3]),
where x and y are 8-bit unsigned integers (positions in the range 0 and 7),
and rgb[3] specifies the color.  The type definition "uint8_t" can be used
to ensure 8-bit unsigned ints.

rgb[3] is an array of three uint8_t's that specifies the color.  

Example:

    uint8_t Indigo[3] = {1,0,1};     // Define a new color
    Meg.SetPxClr(4, 0, Indigo );  
   
   This turns on pixel (7,0), in the color defined as (r,g,b) = {1,0,1}.  
   Given the color response of this a dark indigo.
   
   Please see other examples in the code below.
   
 */
 
 
#include <MeggyJr.h>      // Required

/*
The following colors are predefined in the MeggyJr library:
each of these is just a list of numbers, but it can be used to make arrays.
#define MeggyDark     0,  0,   0
#define MeggyRed      7,  0,   0
#define MeggyOrange  12,  5,   0
#define MeggyYellow   7,  10,  0
#define MeggyGreen    0,  15,  0
#define MeggyBlue     0,   0,  6
#define MeggyViolet   8,   0,  4
#define MeggyWhite    3,  15,  2 
*/

// Make a Color look-up table:

uint8_t CT[9][3] = 
     {{MeggyDark},  
      {MeggyRed},
      {MeggyOrange},
      {MeggyYellow},
      {MeggyGreen},
      {MeggyBlue},
      {MeggyViolet},
      {MeggyWhite},
      {1,5,1}};        // define a new color here too.
     
enum colors {Dark, Red, Orange, Yellow, Green, Blue, Violet, White, Lavender};      
//We can now call colors by name! 
 
  
MeggyJr Meg;              // Required.

void setup()          
{
    Meg = MeggyJr();    // Required.  
}  
  

void loop()    
{
  
   Meg.AuxLEDs = 159;    // Set auxiliary LEDs to a value in the range (0,255), to 
   
   uint8_t AquaColor[3] = {0,15,1};     // Define a new color
   uint8_t Indigo[3] = {1,0,1};     // Define a new color

      
   Meg.SetPxClr(0, 0, CT[White]);
   Meg.SetPxClr(1, 1, CT[Red]);      // CT[Red] is the same as CT[1].
   Meg.SetPxClr(2, 2, CT[2]);      
   Meg.SetPxClr(3, 3, CT[Yellow]);
   Meg.SetPxClr(4, 4, CT[Green]);
   Meg.SetPxClr(5, 5, CT[Blue]);
   Meg.SetPxClr(6, 6, CT[Violet]); 
   Meg.SetPxClr(7, 7, CT[White]);
   
// A couple of new colors:   
   Meg.SetPxClr(0, 7, CT[Lavender]);
   Meg.SetPxClr(7, 0, AquaColor);  
   
   
   Indigo[1] = 15;     // Screw with indigo! -- Add lots of green.
   Meg.SetPxClr(4, 7, Indigo );  
   
}
