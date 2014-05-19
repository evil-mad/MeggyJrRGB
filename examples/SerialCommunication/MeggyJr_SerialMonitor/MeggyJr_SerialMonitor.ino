/*
  MeggyJr_SerialMonitor.ino 
 
 Example file using the The Meggy Jr Simplified Library (MJSL)
 from the Meggy Jr RGB library for Arduino
 
 Test which buttons have been pressed, since last we checked,
 using the CheckButtonsPress() routine.
 
 
 To see the serial output on your computer, click the "Serial Monitor" 
 button in the Arduino environment; it's the one next to the "Upload to I/O board"
 button. Also, make sure that you have the correct baud rate selected-- 19200.
 The baud rate selection should be visible once you have the serial monitor on. 
 
 
 Version 1.5 - 12/31/2011
 Copyright (c) 2011 Windell H. Oskay.  All right reserved.
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


  // start serial port:
  Serial.begin(19200);
  Meg.SoundState(0); 
  Serial.println("hello, world.");
}  // End setup()

void loop()                     // run over and over again
{   

  ClearSlate();
  CheckButtonsPress();   //Check to see which buttons are down that weren't before.

  if (Button_A)      
  {
    DrawPx(6,4,Blue);    
    Serial.println("Button A was pressed.");
  }

  if (Button_B)     
  {  
    DrawPx(5,4,Blue); 
    Serial.println("Button B was pressed.");  
  }
  if (Button_Up)     
  { 
    DrawPx(2,5,Blue);  
    Serial.println("Button Up was pressed."); 
  }
  if (Button_Down)   
  {

    Serial.println("Button Down was pressed.");
    DrawPx(2,3,Blue);   
  }


  if (Button_Right)      
  {
    DrawPx(3,4,Blue);    

    Serial.println("Button Right was pressed.");

  }

  if (Button_Left)        
  {

    Serial.println("Button Left was pressed.");
    DrawPx(1,4,Blue);   
  }


  DisplaySlate();      // Write the updated game buffer to the screen.
  delay(30);          // Wait 30 ms
}    
