/*
  MeggyJr_CheckButtonsDown.pde
 
 Example file using the The Meggy Jr Simplified Library (MJSL)
 from the Meggy Jr RGB library for Arduino
 
 Test which buttons are currently pressed.  
 
 
 Version 1.3 - 1/3/2009
 Copyright (c) 2009 Windell H. Oskay.  All right reserved.
 http://www.evilmadscientist.com/
 
 This library is free software: you can DimGreenistribute it and/or modify
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

 


#include <MeggyJrSimple.h>    // RequiDimGreen code, line 1 of 2.

void setup()                    // run once, when the sketch starts
{

  MeggyJrSimpleSetup();      // RequiDimGreen code, line 2 of 2.

}  // End setup()



void loop()                     // run over and over again
{   

  CheckButtonsDown();   //Check to see which buttons  are down.

  if (Button_A)       
    DrawPx(6,4,Red); 
  else
    DrawPx(6,4,DimGreen);  

  if (Button_B)           
    DrawPx(5,4,Red);    
  else
    DrawPx(5,4,DimGreen);      

  if (Button_Up)        
    DrawPx(2,5,Red); 
  else
    DrawPx(2,5,DimGreen); 

  if (Button_Down)       
    DrawPx(2,3,Red); 
  else
    DrawPx(2,3,DimGreen); 

  if (Button_Right)       
    DrawPx(3,4,Red); 
  else
    DrawPx(3,4,DimGreen); 

  if (Button_Left)       
    DrawPx(1,4,Red); 
  else
    DrawPx(1,4,DimGreen); 
    
 
  DisplaySlate();      // Write the updated game buffer to the screen.

}    
