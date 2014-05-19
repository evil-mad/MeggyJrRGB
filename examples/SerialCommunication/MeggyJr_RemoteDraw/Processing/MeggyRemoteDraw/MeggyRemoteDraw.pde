/*
  MeggyRemoteDraw.pde
  
  A Processing sketch, designed to accompany  MeggyJr_RemoteDraw.pde.
  please read that file for instructions on how to use this.
 
 
 This program remotely draws random dots on a Meggy Jr RGB hooked up
 to this computer with a serial cable.
 
 
  
 Version 1.3 - 12/23/2008
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

/** 
 * Incorporates code from Serial Call-Response 
 * by Tom Igoe. 
 *  
 */

import processing.serial.*;
   color bgColor;
   
boolean SerialEnabled;
boolean  ComEstablished = false;

Serial myPort;                       // The serial port 
byte xpos, ypos, colorNum;	     
int   inByte;

void setup() {
   bgColor = color(70, 70, 200);
   
  size(200, 200);
  smooth();   
    
  textFont(loadFont("Ziggurat.vlw"), 20); 
  

  background(bgColor);
 fill(255);  
 text("Click to Stop", 25, 100); 
 
  // Print a list of the serial ports, for debugging purposes:
  println(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.clear();
  SerialEnabled = true;
    
   serialSendHello(myPort);  
    
}


 
void draw() { 
    
 xpos = byte(floor(random(8)));
 ypos = byte(floor(random(8)));
 colorNum = byte(floor(random(14))); 
 
 serialDrawPixel(myPort,xpos,ypos,colorNum); 
 
 if (colorNum == 0)    // one in every 14 times...
{
 serialSetAuxLEDs(int(floor(random(256)))); 
}

  // Exit gracefully, at the end of the loop function, once the button has been pushed.
  if (SerialEnabled == false)
    exit(); 
}




void serialSetAuxLEDs(int value)
{
 if (SerialEnabled)
  {  
    if (value > 255)
     value = 255;
     
    myPort.write('a');  
    myPort.write(value);    
    myPort.write('A');  
  } 
    return;

}
 

boolean serialDrawPixel(Serial myPort, byte x, byte y, byte colorNumber)
{  
  if (SerialEnabled)
  {  
    myPort.write('d');  
    myPort.write(x);   
    myPort.write(y);  
    myPort.write(colorNumber);  
    myPort.write('D'); 
       
    return true; 
  }
  else
    return false;
} // end serialDrawPixel


  

boolean serialDisplaySlate(Serial myPort)
{  
  if (SerialEnabled)
  {  
    myPort.write('s'); 
      return true; 
  }
  else
    return false;
} // end serialDisplaySlate
 
 
 
void serialSendHello(Serial myPort)
{  
  if (SerialEnabled)
  {
    println("MeggyCom: \tSending Hello to Meggy Jr.");  
    myPort.clear(); 
    myPort.write('h');
  }
    return;
} // end serialSendHello

  

void mousePressed()
{ 
   
 
    SerialEnabled  = false;
    myPort.clear();
    myPort.stop();
    exit();
   

    
}

 






void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  int inByte = myPort.read();
  // if this is the first byte received, and it's an A,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller. 
  // Otherwise, add the incoming byte to the array:
  if (ComEstablished == false) {
    
  //  if (inByte == 255) { // Proper response to Hello char
      myPort.clear();          // clear the serial port buffer
       ComEstablished = true; 
       println("\tMeggy says to say hi to you. :)");
  //  } 
    
  } 
  else {
    
   if (inByte == 'X')
      println("\tMeggy Jr reports: command not understood.");
  else if (inByte == 'B')
      println("\tMeggy Jr reports: Bad input values.");
  else if (inByte == 'T')
      println("\tMeggy Jr reports: Timeout error.");
 
  }
}

  
  boolean overRect(int x, int y, int width, int height) 
  {
    if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
      return true;
    } 
    else {
      return false;
    }
  }


 
