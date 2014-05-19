/*
  MeggyJr_RemoteDraw.ino
 
 Example file using the The Meggy Jr Simplified Library (MJSL)
 from the Meggy Jr RGB library for Arduino
 
 Overlays basic serial communication, to accept communication from the matching
 Processing sketch MeggyRemoteDraw.pde.
 
 To run this program:  First download this code onto Meggy Jr RGB as per usual,
 using the FTDI USB-TTL cable.  If it's working properly, you'll see one blinking 
 LED while it waits for a host computer to establish serial communication.  
 
 Next, open up the Processing sketch MeggyRemoteDraw.pde from within the 
 Processing environment.  With the USB-TTL cable still hooked up, press the 
 "Run" button at the upper left hand corner of the Processing window.
 
 When the Processing sketch runs, it will tell Meggy Jr RGB to draw colored dots
 at different locations.
 
 
 
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

void WaitForContact() {
  while (Serial.available() <= 0) {


    DrawPx(3,4,Yellow);           // Draw a dot at x=3, y=4, in yellow.
    DisplaySlate();                  // Write the drawing to the screen.
    delay(150);

    if (Serial.available() > 0)
      break;

    ClearSlate();                 // Erase drawing
    DisplaySlate();                  // Write the (now empty) drawing to the screen.

    delay(150);        

  }
  ClearSlate();                 // Erase drawing
}

byte inByte;
unsigned long time;

#define DrawPtTimeout 8192      

void getSerialChar(byte &theChar, byte &timedOut){ 
  if (timedOut == 0)
  {
    unsigned int i = 0;
    byte WaitForData = 1;  

    while (WaitForData)   // give up if we don't get data in a certain amount of time
    {
      if (Serial.available() > 0)
      {
        WaitForData = 0; 
        theChar = Serial.read();
      } 
      else if (++i > DrawPtTimeout)
      {
        WaitForData = 0;  
        timedOut = 1;
      }
    }   // end "while (WaitForData)" 
  }
  return; 
}




void setup()                    // run once, when the sketch starts
{

  MeggyJrSimpleSetup();      // Required code, line 2 of 2.
  // start serial port:
  Serial.begin(9600);
  WaitForContact();  // Establish contact until Processing responds 

  ClearSlate();
  DisplaySlate();      // Write the updated game buffer to the screen.

}  // End setup()

void loop()                     // run over and over again
{   
  unsigned int i;
  byte inByte1, inByte2, inByte3;
  byte timeout, SyntaxOK;
  byte WaitForData;

  if (Serial.available() > 0) {
    inByte = Serial.read();


    if (inByte == 'h')
    {
      Serial.write(255);  //Reply to Hello signal
    }
    else if (inByte == 'd')
    {
      timeout = 0; 

      inByte1 = 255;
      inByte2 = 255;
      inByte3 = 255;

      getSerialChar(inByte1, timeout);
      getSerialChar(inByte2, timeout);
      getSerialChar(inByte3, timeout);
      getSerialChar(inByte, timeout);

      // Now check the 3 numbers for sanity:

      byte SyntaxOK = 1;
      if (inByte1 > 7)
        SyntaxOK = 0;
      if (inByte2 > 7)
        SyntaxOK = 0;      
      if (inByte3 > 15)
        SyntaxOK = 0;     


      if ( SyntaxOK == 0)
        Serial.print('B');     // Report error
      else if (timeout)
        Serial.print('T');     // Report error
      else if (inByte == 'D')
      {
        DrawPx(inByte1,inByte2,inByte3);  
        DisplaySlate(); // Auto update
      }

    }      // End " if (inByte == 'd')"

    else if (inByte == 'a')
    {
      timeout = 0;

      getSerialChar(inByte1, timeout);
      getSerialChar(inByte, timeout);


      if (timeout == 0)  // i.e., if we did not time out.... 
        if (inByte == 'A')
        {
          SetAuxLEDs(inByte1);  
        }


    }      // End "if (inByte == 'a')"
    else
    {
      // Command received but not understood-- send #2; indicating syntax error.
      Serial.print('X');     
    }

  }  // End if (Serial.available() > 0)



}   // End loop()



