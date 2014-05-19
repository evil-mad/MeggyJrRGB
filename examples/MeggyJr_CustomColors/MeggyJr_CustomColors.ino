/*
  MeggyJr_CustomColors.pde
 
 Example file using the The Meggy Jr Simplified Library (MJSL)
 from the Meggy Jr RGB library for Arduino
 
 This program demonstrates how to set up and use the MJSL to
 draw some colored dots on the screen, where the color of the dots
 is defined by the user.  The top half of this file
 is documentation, the lower half is a very short example program.
  
 
 
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
 
   
    DrawPx(2,2,White);           // Draw a dot at x=2, y=2, in color White.
    DrawPx(3,2,White);           // Draw a dot at x=3, y=2, in color White.
    DrawPx(4,2,White);           // Draw a dot at x=4, y=2, in color White.
    DrawPx(5,2,White);           // Draw a dot at x=5, y=2, in color White. 
    
    DrawPx(2,5,White);           // Draw a dot at x=2, y=5, in color White.
    DrawPx(3,5,White);           // Draw a dot at x=3, y=5, in color White.
    DrawPx(4,5,White);           // Draw a dot at x=4, y=5, in color White.
    DrawPx(5,5,White);           // Draw a dot at x=5, y=5, in color White. 
  
    DrawPx(2,3,White);           // Draw a dot at x=2, y=3, in color White.  
    DrawPx(2,4,White);           // Draw a dot at x=2, y=4, in color White.    
    
    DrawPx(5,3,White);           // Draw a dot at x=5, y=3, in color White.  
    DrawPx(5,4,White);           // Draw a dot at x=5, y=4, in color White.   

  DrawPx(3,3,CustomColor0);           // Draw a dot at x=3, y=3, in color CustomColor0.
  DrawPx(4,4,CustomColor0);           // Draw a dot at x=4, y=4, in color CustomColor0. 
  DrawPx(4,3,CustomColor7);           // Draw a dot at x=4, y=3, in color CustomColor7.
  DrawPx(3,4,CustomColor7);           // Draw a dot at x=#, y=4, in color CustomColor7. 

   }


void loop()                     // run over and over again
{
 
  
  byte i,j;
   
  i = 0;
  while (i < 16)
  {
    j = 16 - i;
    
    EditColor(CustomColor0, i, 0, j); 
    EditColor(CustomColor7, j, 0, i);
    delay(100);                  // wait 100 milliseconds

    DisplaySlate();                  // Write the drawing to the screen. 
    
    i++;
  }

    delay(500);                  // wait 500 milliseconds
    
  while (i > 0)
  {
    j = 16 - i;
    
    EditColor(CustomColor0, i, 0, j); 
    EditColor(CustomColor7, j, 0, i);
    delay(100);                  // wait 100 milliseconds

    DisplaySlate();                  // Write the drawing to the screen. 
    
    i--;
  }

    delay(500);                  // wait 500 milliseconds


}


