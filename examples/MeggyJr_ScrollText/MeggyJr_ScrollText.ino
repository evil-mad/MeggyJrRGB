/*
  MeggyJr_ScrollText.pde
 
 Example file using the The Meggy Jr Simplified Library (MJSL)
 from the Meggy Jr RGB library for Arduino
 
 Text readerboard demo.
 
 The font and structure of this program were borrowed from a
 Evil Mad Scientist Laboratories project:
 the "Scariest Jack-o'-Lantern of 2008"
 http://www.evilmadscientist.com/article.php/stockpumpkin
 
 
 
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


#include <avr/pgmspace.h> 



#define delaytime 100U

// Global vars:	
unsigned char columns[8];	


// BEGIN FONT AND STRING DEFINITIONS  
// Font consists of A-Z, 0-9, +,-, .

const byte font_table[40][5] PROGMEM = 
{
  {
    15,20,20,15,0      }
  ,	//A
  {
    31,21,21,10,0      }
  ,	//B
  {
    14,17,17,10,0      }
  ,	//C
  {
    31,17,17,14,0      }
  ,	//D
  {
    31,21,21,17,0      }
  ,	//E

  {
    31,20,20,16,0      }
  ,	//F
  {
    14,17,21,22,0      }
  , 	//G
  {
    31,4,4,31,0      }
  ,  	//H
  {
    17,31,17,0,0      }
  , 	//I
  {
    2,1,1,30,0      }
  ,   	//J

  {
    31,4,10,17,0      }
  , 	//K
  {
    31,1,1,0,0      }
  ,   	//L
  {
    31,8,4,8,31      }
  ,  	//M
  {
    31,8,4,2,31      }
  ,  	//N
  {
    14,17,17,14,0      }
  ,    //O

  {
    31,20,20,8,0      }
  , 	//P
  {
    14,17,17,18,13      }
  ,	//Q
  {
    31,20,22,9,0      }
  , 	//R
  {
    9,21,21,21,18      }
  , 	//S
  {
    16,16,31,16,16      }
  ,	//T

  {
    30,1,1,30,0      }
  ,  	//U
  {
    28,2,1,2,28      }
  ,  	//V
  {
    31,2,4,2,31      }
  ,  	//W
  {
    17,10,4,10,17      }
  ,		//X
  {
    16,8,7,8,16      }
  ,  	//Y

  {
    17,19,21,25,17      }
  ,	//Z
  {
    14,17,17,14,0      }
  ,	//0
  {
    17,31,1,0,0      }
  ,  	//1
  {
    9,19,21,21,9      }
  ,  	//2
  {
    17,21,21,10,0      }
  ,	//3

  {
    28,4,31,4,0      }
  ,  	//4
  {
    29,21,21,18,0      }
  ,	//5
  {
    14,21,21,2,0      }
  , 	//6
  {
    16,19,20,24,0      }
  , 	//7
  {
    10,21,21,10,0      }
  ,	//8

  {
    8,21,21,14,0      }
  , 	//9
  {
    4,8,31,8,4      }
  ,		// +  (Up arrow used)
  {
    4,2,31,2,4      }
  ,		// -  (down arrow used)
  {
    0,0,0,0,0      }
  ,			//space
  {
    1,0,0,0,0      }	//decimal

}; 


const byte width_table[40] PROGMEM = 
{
  4,	//A
  4,	//B
  4,	//C
  4,	//D
  4,	//E

  4,	//F
  4,	//G
  4,	//H
  3,	//I
  4,	//J

  4,	//K
  3,	//L
  5,	//M
  5,	//N
  4,	//O

  4,	//P
  5,	//Q
  4,	//R
  5,	//S
  5,	//T

  4,	//U
  5,	//V
  5,	//W
  5,	//X
  5,	//Y

  5,	//Z
  4,	//0
  3,	//1
  5,	//2
  4,	//3

  4,	//4
  4,	//5
  4,	//6
  4,	//7
  4,	//8						 	

  4,	//9
  5,	// +
  5,	// -
  3,	//space
  1	//decimal

}; 






//Because the font tables are in program memory, we can actually have a fairly long 
// string here.  (Longer-yet strings can also be stored in program memory if necessary.)

//Strings for font tests:	
//const char String[] = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ;";
//const char String[] = "12345678901234567890.;";

// Stock ticker example:
//const char String[] = "DJI 9065.12 +889.35  INX 940.51 +91.59 AAPL 99.91 +7.82  GOOG 368.75 +39.26  ATML 3.97 +0.45   ;";

const char String[] = "HELLO WORLD    MEGGY JR RGB    LEVEL 1     EXTRA LIFE    GAME OVER    ;";




// Create global variables & constants:
 

byte CurrentColor;
byte DelayTime_ms;       // Delay time

unsigned long LastTime;          // long variable for millisecond counter storage

      
#include <MeggyJrSimple.h>    // Required code, line 1 of 2.
void setup()                    // run once, when the sketch starts
{

  MeggyJrSimpleSetup();      // Required code, line 2 of 2.

  LastTime = millis();        // Returns millisecond counter values (Arduino function).

  CurrentColor = 1;
   DelayTime_ms  =  100;  
}  // End setup()



unsigned int StringPosition = 0; 

void loop()                     // run over and over again
{    
  


  unsigned int i;		// Dummy variable

  byte StringChar;	// Character picked out of string
  unsigned int FontChar = 0;		// Location in the font_table of our character
  unsigned int CharWidth;		// Width of our character in the font table
  unsigned int SubCharPos;	// Position advancing the character into the LED matrix
  byte SubCharWord;	// Single column of a single character
  byte x;

  if( String[StringPosition] == ';' )	
  {
    StringPosition = 0; // repeat string over and over
    
    //  Speed up as we go, just for fun.
    
     if (DelayTime_ms > 10)
        DelayTime_ms -= 10;       
     else
         DelayTime_ms = 100;   
    
    
    // Change the color as we go, just for fun.
    if(++CurrentColor > 7)
        CurrentColor = 1;
        
  }
  StringChar = String[StringPosition];


  if (StringChar >= 'A')	
  {
    FontChar = StringChar - 'A';
  }

  if (StringChar == ' ')
    FontChar = 38;
  if (StringChar == '+')	
    FontChar = 36;
  if (StringChar == '-')	
    FontChar = 37;			
  if (StringChar == '.')	
    FontChar = 39;			

  if ((StringChar >= '0') && (StringChar <= '9'))	
    FontChar = StringChar - '0' + 26;	

  // New character is picked now.  

  CharWidth = (uint8_t)pgm_read_word(&width_table[FontChar]);  


  SubCharPos = 0;

  while (SubCharPos <=  CharWidth)
  {

    if (SubCharPos == CharWidth)
      SubCharWord = 0;   // ending gap
    else	
      SubCharWord = (uint8_t)pgm_read_word(&font_table[FontChar][SubCharPos]); 


    SubCharWord <<= 2;

    // Scrolling part:
    x = 0;
    while (x < 7)
    {

      DrawPx(x,0, ReadPx(x+1,0));
      DrawPx(x,1, ReadPx(x+1,1));
      DrawPx(x,2, ReadPx(x+1,2));
      DrawPx(x,3, ReadPx(x+1,3));
      DrawPx(x,4, ReadPx(x+1,4));
      DrawPx(x,5, ReadPx(x+1,5));
      DrawPx(x,6, ReadPx(x+1,6));
      DrawPx(x,7, ReadPx(x+1,7));

      x++;
    }

    if (SubCharWord & 1)
      DrawPx(7,0,CurrentColor); 
    else
      DrawPx(7,0,Dark);  

    if (SubCharWord & 2)
      DrawPx(7,1,CurrentColor); 
    else
      DrawPx(7,1,Dark);  

    if (SubCharWord & 4)
      DrawPx(7,2,CurrentColor); 
    else
      DrawPx(7,2,Dark);  

    if (SubCharWord & 8)
      DrawPx(7,3,CurrentColor); 
    else
      DrawPx(7,3,Dark);  

    if (SubCharWord & 16)
      DrawPx(7,4,CurrentColor); 
    else
      DrawPx(7,4,Dark);  

    if (SubCharWord & 32)
      DrawPx(7,5,CurrentColor); 
    else
      DrawPx(7,5,Dark);  

    if (SubCharWord & 64)
      DrawPx(7,6,CurrentColor); 
    else
      DrawPx(7,6,Dark);  

    if (SubCharWord & 128)
      DrawPx(7,7,CurrentColor); 
    else
      DrawPx(7,7,Dark);  



    DisplaySlate();      // Write the updated game buffer to the screen.

    while (( millis() - LastTime) < DelayTime_ms)
    { 
    }

    LastTime = millis();


    SubCharPos++;
  }

  StringPosition++;


}   // End loop()
