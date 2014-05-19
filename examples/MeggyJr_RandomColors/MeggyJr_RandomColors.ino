/*
  MeggyJr_RandomColors.pde
   

 Example file using the The Meggy Jr Simplified Library (MJSL)
  from the Meggy Jr RGB library for Arduino
   
   This program demonstrates how to set up and use the MJSL to
   draw some colored dots on the screen. This example demonstrates
   a random color field, where you can change the speed and 
   number of colros used.
  
   The top half of this file
   is documentation, the lower half is a short example program.
    
 
 Version 1.3 - 1/3/2009
 Copyright (c) 2009 Windell H. Oskay.  All right reserved.
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

 




///////////////  END OF STORYTELLING, BEGIN PROGRAM BELOW //////////////////

 
 
#include <MeggyJrSimple.h>    // Required code, line 1 of 2.
 
 
 

unsigned long lasttime;
int delayTime;
byte interactive;
byte ButtonsLast;
byte pause;
byte ColorRange; 
 
byte AuxLEDValue; 
 
 
 
 
void setup()                    // run once, when the sketch starts
{

  MeggyJrSimpleSetup();      // Required code, line 2 of 2.
 
  lasttime = millis();
  delayTime = 300;
  interactive = 0;   // No human contact yet.
  pause = 0;

  ColorRange = 14;
  
  
}  // End setup()


void loop()                     // run over and over again
{   
   
  unsigned long TempTime;

  byte i;
  byte j;
  int delayTemp;
 
 CheckButtonsPress(); 
 
 
    if (Button_B)   //"B" button            // Resume automatic speed ramps
      interactive = 1;       

    if (Button_A)   //"A" button            // Pause/unpause
    {interactive = 0; 
      pause = !pause;       
    }
    
    if ((Button_Up) && (delayTime > 0))      // up button: Speed up
     {  delayTime -= 10;
      interactive = 1; 
     }
     
    if ((Button_Down) &&  (delayTime < 1000))  // down button: Slow down
     { delayTime += 10; 
       interactive = 1; 
     }
     
    if ((Button_Left) && (ColorRange > 1))    // left button: reduce # of colors
     {interactive = 1; 
     ColorRange--;
     }
    if ((Button_Right) &&  (ColorRange < 14))  // right button: increase # of colors
      {interactive = 1; 
      ColorRange++; 
      }
      
 
  TempTime = millis();

  delayTemp = delayTime - 50;
  if (delayTemp < 0)
    delayTemp = 0;

  if  ((TempTime - lasttime) > delayTemp)
  {

    i = 0;
    while (i < 8) { 
      j = 0;
      while ( j < 8)
      {
        DrawPx(i,j, rand() % ColorRange);
 
        // Randomly pick colors from the color look up table!
        j++;
      }
      i++;
    }

    if (interactive == 0)
    { 
      if (--delayTime == 0)
          delayTime = 250;
    }

    AuxLEDValue++;
    
 SetAuxLEDs(AuxLEDValue);

    lasttime = TempTime;

    if (pause == 0)
       DisplaySlate();  
  }
  
}   // End loop()
