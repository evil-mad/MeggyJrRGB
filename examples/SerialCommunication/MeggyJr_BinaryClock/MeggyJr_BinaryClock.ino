/*
  MeggyJr_BinaryClock.pde
 
 Binary Clock Application.  Adapted from the DateTime.pde
 example sketch in the Arduino Software Date Time library (DateTime.h).
 
 Requires:
Arduino DateTime library:   http://www.arduino.cc/playground/Code/DateTime
 
If you want to use automatic time setting, 
also requires: USB-TTL cable (or other suitable serial interface)
and Processing 1.0.  (from processing.org)
  
 
 Also uses the The Meggy Jr Simplified Library (MJSL)
 from the Meggy Jr RGB library for Arduino.
 
 *************** HOW TO READ THE CLOCK ***************
 
There are 8 columns, left to right:
 
 M: D: HH: MM: SS
 Month, Day, Hour (24 hour style, not AM/PM), Minute, second.
 
 Month and day are true binary numbers.  HH, MM, SS are binary-coded decimal. 
 

 *************** MANUAL ADJUSTMENT ***************
 
 When you first upload the program and reset Meggy Jr RGB, it 
 will display Jan 1, 00:00:01, i.e., one second after midnight.
 
 To enter edit mode, press the 'B' button.  This will highlight one of the columns,
 which you can then adjust up and down with the arrow keys, or change columns with the
 arrow keys.  Hold a button to advance more quickly.
 
 Exit edit mode by pressing 'B' again.
 
 
  *************** AUTOMATIC TIME SETTING  ***************
 
 Run the separate Processing sketch SetArduinoClock.pde to set the initial time.
 
 To run this program:  First download *this code* onto Meggy Jr RGB as per usual,
 using the FTDI USB-TTL cable.  
 
 Next, open up the Processing sketch SetArduinoClock.pde from within the 
 Processing environment.  With the USB-TTL cable still hooked up, press the 
 "Run" button at the upper left hand corner of the Processing window.
 
 When the Processing sketch runs, it will tell present a window that you can click
 to set the Meggy Jr RGB time to the current computer time.  
 
 When the time is set over the serial port, it informs the computer what year it is; 
 necessary for computing leap years.  If you do not use the serial port to set the 
 time, Meggy Jr will not know what year it is, and may not account correctly for leap years.
 (You can press the 'B' Button to enter edit mode.)
 
 
 
 
 
 
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

#include <MeggyJrSimple.h>    // Required code, line 1 of 2.

byte inByte;
unsigned long time;


#include <DateTime.h>
#include <DateTimeStrings.h>

#define TIME_MSG_LEN  11   // time sync to PC is HEADER followed by unix time_t as ten ascii digits
#define TIME_HEADER  255   // Header tag for serial time sync message


byte MonthColor = Red;  
byte DayColor = Green;          
byte HourColor = Orange;  
byte MinuteColor = White;  
byte SecondColor = CustomColor0;   

byte EditMode = 0;
byte EditPosition = 5;

unsigned long  prevtime;

static  byte monthDays[]={
  31,28,31,30,31,30,31,31,30,31,30,31};

unsigned long ButtonStartTime[] = {
  0,0,0,0,0,0};


void CheckButtons()
{
  byte j;
  unsigned long timeNow;

  byte i = Meg.GetButtons();


  Button_B  = 0;      
  Button_A = 0;    
  Button_Up = 0;
  Button_Down = 0;
  Button_Left = 0;
  Button_Right = 0;


  if (i)  // if any buttons are currently down
  {
    timeNow = millis();

    j = i & ~(lastButtonState);  // What's changed?


    if (i & 1)    // if Button 'B' is down.
    {
      if ( (j & 1)  || (timeNow - ButtonStartTime[0] > 250UL))
      {
        Button_B = 1;
        ButtonStartTime[0] = timeNow;
      }
    }

    if (i & 2)    // if Button 'A' is down.
    {
      if ((j & 2)  || (timeNow - ButtonStartTime[1] > 250UL))
      {
        Button_A = 1;
        ButtonStartTime[1] = timeNow;
      }
    }

    if (i & 4)   
    {
      if ((j & 4)  || (timeNow - ButtonStartTime[2] > 250UL))
      {
        Button_Up = 1;
        ButtonStartTime[2] = timeNow;
      }
    }

    if (i & 8)   
    {
      if ((j & 8)  || (timeNow - ButtonStartTime[3] > 250UL))
      {
        Button_Down = 1;
        ButtonStartTime[3] = timeNow;
      }
    }  
 
    if (i & 16)   
    {
      if ((j & 16)  || (timeNow - ButtonStartTime[4] > 250UL))
      {
        Button_Left = 1;
        ButtonStartTime[4] = timeNow;
      }
    }  

    if (i & 32)   
    {
      if ((j & 32)  || (timeNow - ButtonStartTime[5] > 250UL))
      {
        Button_Right = 1;
        ButtonStartTime[5] = timeNow;
      }
    }  


  }

  lastButtonState = i;
}







void setup()                    // run once, when the sketch starts
{
  EditColor(CustomColor0, 0, 0, 2);

  MeggyJrSimpleSetup();      // Required code, line 2 of 2.
  // start serial port:
  Serial.begin(19200);
  DateTime.sync(0); 

  prevtime = DateTime.now();

}  // End setup()

void loop()                     // run over and over again
{   

  if( getPCtime()) {  // try to get time sync from pc
    Serial.print("Clock synced at: ");
    Serial.println(DateTime.now(),DEC);
  }

  if(DateTime.available()) { // update clocks if time has been synced

    if ( prevtime != DateTime.now() )
    {
      DateTime.available(); //refresh the Date and time properties

      digitalClockDisplay( );   // update digital clock
      prevtime = DateTime.now();

      Serial.print( TIME_HEADER,BYTE); // this is the header for the current time
      Serial.println(DateTime.now()); 

    }
  }


//  CheckButtonsPress();   //Check to see for buttons that have been pressed since last we checked.
CheckButtons();




  if (Button_B)       // Enter edit mode?
  {  

    if (EditMode) 
      EditMode = 0; 
    else 
      EditMode = 1;

    DateTime.available(); //refresh the Date and time properties
    digitalClockDisplay( );   // update digital clock
    prevtime = DateTime.now();


  }




  if (Button_Right)      
  {
    if (EditMode)
    {
      if (EditPosition < 5)
        EditPosition++;
      else
        EditPosition = 1;  
    }

    DateTime.available(); //refresh the Date and time properties
    digitalClockDisplay( );   // update digital clock
    prevtime = DateTime.now();
  }   

  if (Button_Left)       
  {
    if (EditMode)
    {
      if (EditPosition > 1)
        EditPosition--;
      else
        EditPosition = 5;   
    }



    DateTime.available(); //refresh the Date and time properties
    digitalClockDisplay( );   // update digital clock
    prevtime = DateTime.now();

  } 



  if (Button_Up)       // Move Cursor Up
  {  
    if (EditMode)
    {
      if (EditPosition == 1)  
      {  
        if (DateTime.Month < 11  )
          DateTime.sync( DateTime.now()+monthDays[DateTime.Month]*86400UL);  
      }
    if (EditPosition == 2)
    {
      if (DateTime.Day < monthDays[DateTime.Month])
        DateTime.sync( DateTime.now()+86400UL);  
    } 
    if (EditPosition == 3)
      DateTime.sync( DateTime.now()+3600UL); 
    if (EditPosition == 4)
      DateTime.sync( DateTime.now()+60); 
    if (EditPosition == 5)
      DateTime.sync( DateTime.now()+1); 

    DateTime.available(); //refresh the Date and time properties
    digitalClockDisplay( );   // update digital clock
    prevtime = DateTime.now();
    }
  }


  if (Button_A)      
  {
    // Add alarm function?

  }  


  if (Button_Down)    
  {

    if (EditMode)
      if (EditPosition == 1)  
      {  
        if (DateTime.Month > 0)
          DateTime.sync( DateTime.now() - monthDays[DateTime.Month - 1]*86400UL);  
      }

    if (EditPosition == 2) 
    {
      if (DateTime.Day > 1)
        DateTime.sync( DateTime.now()-86400UL);  
    } 

    if (EditPosition == 3) 
      if ( DateTime.now() > 3600UL)
        DateTime.sync( DateTime.now()- 3600UL); 

    if (EditPosition == 4) 
      if ( DateTime.now() > 60)
        DateTime.sync( DateTime.now()- 60); 

    if (EditPosition == 5)
      if ( DateTime.now() > 0)
        DateTime.sync( DateTime.now()-1); 

    DateTime.available(); //refresh the Date and time properties
    digitalClockDisplay( );   // update digital clock
    prevtime = DateTime.now();
  } 





}   // End loop()






boolean getPCtime() {
  // if time sync available from serial port, update time and return true
  while(Serial.available() >=  TIME_MSG_LEN ){  // time message consists of a header and ten ascii digits
    if( Serial.read() == TIME_HEADER ) {        
      time_t pctime = 0;
      for(int i=0; i < TIME_MSG_LEN -1; i++){   
        char c= Serial.read();          
        if( c >= '0' && c <= '9'){   
          pctime = (10 * pctime) + (c - '0') ; // convert digits to a number    
        }
      }   
      DateTime.sync(pctime);   // Sync Arduino clock to the time received on the serial port
      return true;   // return true if time message received on the serial port
    }  
  }
  return false;  //if no message return false
}

void digitalClockDisplay(){
  byte i, ones,tens;

  // digital clock display of current date and time
  Serial.print(DateTime.Hour,DEC);
  printDigits(DateTime.Minute);
  printDigits(DateTime.Second);
  Serial.print(" ");
  Serial.print(DateTimeStrings.dayStr(DateTime.DayofWeek));
  Serial.print(" ");
  Serial.print(DateTimeStrings.monthStr(DateTime.Month));
  Serial.print(" ");
  Serial.println(DateTime.Day,DEC); 


  ClearSlate();

  MonthColor = Red;  
  DayColor = Green;          
  HourColor = Orange;  
  MinuteColor = White;  
  SecondColor = CustomColor0;   

  if (EditMode)
  {

    if (EditPosition == 1)
      MonthColor =  FullOn;
    if (EditPosition == 2)
      DayColor =  FullOn;
    if (EditPosition == 3)
      HourColor =  FullOn;
    if (EditPosition == 4)
      MinuteColor =  FullOn;
    if (EditPosition == 5)
      SecondColor =  FullOn;
  }




  ones = DateTime.Second;
  tens = 0;
  while (ones >= 10)
  {
    ones -= 10;
    tens++;     
  }

  if(ones & 1)
    DrawPx(7,0,SecondColor);      
  if(ones & 2)
    DrawPx(7,1,SecondColor);       
  if(ones & 4)
    DrawPx(7,2,SecondColor);      
  if(ones & 8)
    DrawPx(7,3,SecondColor);    

  if(tens & 1)
    DrawPx(6,0,SecondColor);    
  if(tens & 2)
    DrawPx(6,1,SecondColor);      
  if(tens & 4)
    DrawPx(6,2,SecondColor);      


  ones = DateTime.Minute;
  tens = 0;
  while (ones >= 10)
  {
    ones -= 10;
    tens++;     
  }

  if(ones & 1)
    DrawPx(5,0,MinuteColor);     
  if(ones & 2)
    DrawPx(5,1,MinuteColor);    
  if(ones & 4)
    DrawPx(5,2,MinuteColor);     
  if(ones & 8)
    DrawPx(5,3,MinuteColor);   

  if(tens & 1)
    DrawPx(4,0,MinuteColor);  
  if(tens & 2)
    DrawPx(4,1,MinuteColor);   
  if(tens & 4)
    DrawPx(4,2,MinuteColor);   



  ones = DateTime.Hour;
  tens = 0;
  while (ones >= 10)
  {
    ones -= 10;
    tens++;     
  }

  if(ones & 1)
    DrawPx(3,0,HourColor);  
  if(ones & 2)
    DrawPx(3,1,HourColor);   

  if(ones & 4)
    DrawPx(3,2,HourColor);  

  if(ones & 8)
    DrawPx(3,3,HourColor);  

  if(tens & 1)
    DrawPx(2,0,HourColor);    
  if(tens & 2)
    DrawPx(2,1,HourColor);   

  ones = DateTime.Day;  


  if(ones & 1)
    DrawPx(1,0,DayColor);  
  if(ones & 2)
    DrawPx(1,1,DayColor);   
  if(ones & 4)
    DrawPx(1,2,DayColor);  
  if(ones & 8)
    DrawPx(1,3,DayColor);  
  if(ones & 16)
    DrawPx(1,4,DayColor);     



  ones = DateTime.Month + 1;

  if(ones & 1)
    DrawPx(0,0,MonthColor);    
  if(ones & 2)
    DrawPx(0,1,MonthColor);        
  if(ones & 4)
    DrawPx(0,2,MonthColor);    
  if(ones & 8)
    DrawPx(0,3,MonthColor);    

  DisplaySlate();      // Write the updated game buffer to the screen.
}

void printDigits(byte digits){
  // utility function for digital clock display: prints preceding colon and leading 0
  Serial.print(":");
  if(digits < 10)
    Serial.print('0');
  Serial.print(digits,DEC);
}


