/*
  MeggyJr_EasyDrawDots.pde
 
 Example file using the The Meggy Jr Simplified Library (MJSL)
  from the Meggy Jr RGB library for Arduino
   
   This program demonstrates how to set up and use the MJSL to
   draw some colored dots on the screen.  The top half of this file
   is documentation, the lower half is a very short example program.
   
   This example is really minimalist-- just drawing some colored dots by name.
   
   
   
 
 Version 1.25 - 12/2/2008
 Copyright (c) 2008 Windell H. Oskay.  All right reserved.
 http://www.evilmadscientist.com/
 
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

 

#include <MeggyJrSimple.h>    // Required code, line 1 of 2.
 
void setup()                    // run once, when the sketch starts
{

  MeggyJrSimpleSetup();      // Required code, line 2 of 2.

}  // End setup()


void loop()                     // run over and over again
{   
  
  //SetAuxLEDs(B01010101);    // Set auxiliary LEDs to binary value (it's reversed on the Meggy!)
  SetAuxLEDs(85);    // Set auxiliary LEDs to a value in the range (0,255)
  
  
  DrawPx(0,0,White);           
  DrawPx(1,1,Red);
  DrawPx(2,2,Orange);
  DrawPx(3,3,Yellow);
  DrawPx(4,4,Green);
  DrawPx(5,5,Blue);
  DrawPx(6,6,Violet);
  DrawPx(7,7,White); 
  
  DrawPx(2,0,DimBlue); 
  DrawPx(3,0,DimGreen);
  DrawPx(4,0,DimRed);
  DrawPx(5,0,DimYellow); 
  DrawPx(6,0,DimAqua);
  DrawPx(7,0,DimViolet);
  
  DisplaySlate();      // Write the updated game buffer to the screen.

}   // End loop()

