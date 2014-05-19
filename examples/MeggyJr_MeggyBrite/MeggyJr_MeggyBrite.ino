/*
  MeggyJr_MeggyBrite.pde
 
 Example file using the The Meggy Jr Simplified Library (MJSL)
  from the Meggy Jr RGB library for Arduino
   
 Move your cursor around the screen, switch colors, and draw your points.
 There's also an eraser mode and a cursor-off display mode.
 
 Also, it's a bit musical-- the six buttons make different tones.
 
   
   
  Version 1.35 - 1/3/2009    -- Revised for library version 1.3.
  
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

// Create global variables & constants:

byte xc,yc;             // Define two 8-bit unsigned variables for cursor position ('xc' and 'yc').
byte CurrentPxColor;    // Backup variable to store a color in.
byte PenColor;    

byte CursorPhase;       // Storage for state of cursor.

unsigned long LastTime;          // long variable for millisecond counter storage

#define DelayTime_ms  40        // define a delay time between cursor on/off

void setup()                    // run once, when the sketch starts
{

  MeggyJrSimpleSetup();      // Required code, line 2 of 2.


  // Set up gameplay:  Erase screen, initialize variables.

  ClearSlate();              // Erase the screen
  xc = 4;        // Set initial cursor position to 4,4.
  yc = 4;
  CurrentPxColor = 0;
  PenColor = 1;

  CursorPhase = 0;

  SetAuxLEDs(1 << PenColor);    

  LastTime = millis();        // Returns millisecond counter values (Arduino function).

}  // End setup()




void loop()                     // run over and over again
{   

  byte CursorColor;




  CheckButtonsPress();   //Check to see for buttons that have been pressed since last we checked.


  if (Button_A)       // Set the pixel color
  {    
    // We actually write the color to CurrentPxColor, because we're blinking the
    // cursor on and off all the time.

    if (PenColor <= White)      // Do not draw if pen color > white.

      if( CurrentPxColor != PenColor)  // i.e., if CurrentPxColor is not equal to pen color
      {
        CurrentPxColor = PenColor;  
      }
      else
      {
        CurrentPxColor = Dark;  
      }      

  Tone_Start(ToneC3, 50);


  }

  if (Button_B)       // Advance pen color
  {    
    PenColor++;      // increase pen color by 1. Shorthand for "PenColor = PenColor + 1"
    if (PenColor > (White + 1))
      PenColor = Dark;         // Note: PenColor = (White + 1) is there to turn the cursor *off*

    if (PenColor == (White + 1))
      SetAuxLEDs(0);
    else    
      SetAuxLEDs(1 << PenColor);    
      
   Tone_Start(ToneD3, 50);     
  }


  if (Button_Up)       // Move Cursor Up
  {    
    DrawPx(xc,yc,CurrentPxColor);      // Write "real" color to current pixel in the game buffer.

    if (yc < 7)
      yc++;
    else
      yc = 0;     // Wrap around at edges   

    CurrentPxColor = ReadPx(xc,yc);    // Store "real" value of new current pixel.
    
      Tone_Start(ToneE3, 50);
    
  }

  if (Button_Down)       // Move Cursor Down
  {    
    DrawPx(xc,yc,CurrentPxColor);      // Write "real" color to current pixel in the game buffer.
    if (yc > 0)
      yc--;
    else
      yc = 7;      // Wrap around at edges   
    CurrentPxColor = ReadPx(xc,yc);    // Store "real" value of new current pixel.
    
      Tone_Start(ToneFs3, 50);
  }


  if (Button_Right)       // Move Cursor Right
  {    
    DrawPx(xc,yc,CurrentPxColor);      // Write "real" color to current pixel in the game buffer.
    if (xc < 7)
      xc++;
    else
      xc = 0;      // Wrap around at edges   
    CurrentPxColor = ReadPx(xc,yc);    // Store "real" value of new current pixel.
    
      Tone_Start(ToneA3, 50);
  }

  if (Button_Left)       // Move Cursor Right 
  {    
    DrawPx(xc,yc,CurrentPxColor);      // Write "real" color to current pixel in the game buffer.
    if (xc > 0)
      xc--;
    else
      xc = 7;      // Wrap around at edges   
    CurrentPxColor = ReadPx(xc,yc);    // Store "real" value of new current pixel.
      Tone_Start(ToneB3, 50);
  }







// Manage cursor blinking
 


  if (CurrentPxColor == PenColor)
    CursorColor = Dark;
  else   
    CursorColor = PenColor;

  // Two special cases:
  if (PenColor > White)        // i.e., cursor is *invisible*
    CursorColor = CurrentPxColor;

  if (PenColor == Dark)      
    CursorColor = FullOn;


  if ((millis() - LastTime) > DelayTime_ms)    // Check for time elapsed to blink cursor.
  {

    CursorPhase++;
    if (CursorPhase > 2)
    {
      DrawPx(xc,yc,CursorColor);
      CursorPhase = 0;
    }
    else
      DrawPx(xc,yc,CurrentPxColor);
      
    LastTime = millis();
  }


 

  DisplaySlate();      // Write the updated game buffer to the screen.

}   // End loop()
