/*
  MeggyJr_BinaryClock.pde

 Binary Clock Application.  Originally adapted from the example
 sketch in the Arduino Software Date Time library (DateTime.h),
 along with the TimeSerial example from the Arduino Time library (Time.h)

 Requires:
The Arduino Time library, http://www.arduino.cc/playground/Code/Time

If you want to use automatic time setting,
also requires: USB-TTL cable (or other suitable serial interface)
and Processing 1.0.  (from processing.org)

Use the SyncArduinoClock example included with the Time library.
(You may need to adjust the serial port name that SyncArduinoClock uses.)


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



 Version 1.4 - 4/28/2016
 Copyright (c) 2016 Windell H. Oskay.  All right reserved.
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
#include <Time.h>       // The Arduino Time library, http://www.arduino.cc/playground/Code/Time

byte inByte;
unsigned long time;


#define TIME_HEADER  "T"   // Header tag for serial time sync message
#define TIME_REQUEST  7    // ASCII bell character requests a time sync message 


byte MonthColor = Red;
byte DayColor = Green;
byte HourColor = Orange;
byte MinuteColor = White;
byte SecondColor = CustomColor0;

byte EditMode = 0;
byte EditPosition = 5;

unsigned long  prevtime;

static  byte monthDays[] = {
  31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
};

unsigned long ButtonStartTime[] = {
  0, 0, 0, 0, 0, 0
};


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
  Serial.begin(9600);
  setSyncProvider( requestSync);  //set function to call when sync required
  Serial.println("Waiting for sync message");

  prevtime = now();

}  // End setup()


void processSyncMessage() {
  unsigned long pctime;
  const unsigned long DEFAULT_TIME = 1357041600; // Jan 1 2013

  if (Serial.find(TIME_HEADER)) {
    pctime = Serial.parseInt();
    if ( pctime >= DEFAULT_TIME) { // check the integer is a valid time (greater than Jan 1 2013)
      setTime(pctime); // Sync Arduino clock to the time received on the serial port
    }
  }
}

time_t requestSync()
{
  Serial.write(TIME_REQUEST);
  return 0; // the time will be sent later in response to serial mesg
}

void loop()                     // run over and over again
{
  if (Serial.available()) {
    processSyncMessage();
  }

  CheckButtons();



  time_t timeTemp = now();


  if (Button_B)       // Enter edit mode?
  {

    if (EditMode)
      EditMode = 0;
    else
      EditMode = 1;

    prevtime = now();
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

    prevtime = now();
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

    prevtime = now();

  }

  if (Button_Up)       // Move Cursor Up
  {
    if (EditMode)
    {
      if (EditPosition == 1)
      {
        if (month() < 11  )
          setTime(now() + monthDays[month()] * 86400UL);

      }
      if (EditPosition == 2)
      {
        if (day() < monthDays[month()])
          setTime( now() + 86400UL);
      }
      if (EditPosition == 3)
        setTime( now() + 3600UL);

      if (EditPosition == 4)
        setTime( now() + 60);

      if (EditPosition == 5)
        setTime( now() + 1);

      prevtime = now();
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
        if (month() > 0)
          setTime( now() - monthDays[month() - 1] * 86400UL);
      }

    if (EditPosition == 2)
    {
      if (day() > 1)
        setTime( now() - 86400UL);
    }

    if (EditPosition == 3)
      if ( now() > 3600UL)
        setTime( now() - 3600UL);

    if (EditPosition == 4)
      if ( now() > 60)
        setTime( now() - 60);

    if (EditPosition == 5)
      if ( now() > 0)
        setTime( now() - 1);

    prevtime = now();
  }

  digitalClockDisplay( );   // update digital clock


}   // End loop()


void digitalClockDisplay() {
  byte i, ones, tens;

  // digital clock display of current date and time
  Serial.print(hour(), DEC);
  printDigits(minute());
  printDigits(second());
  Serial.print(" ");
  Serial.print(dayStr(weekday()));
  Serial.print(" ");
  Serial.print(monthStr(month()));
  Serial.print(" ");
  Serial.println(day(), DEC);


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

  ones = second();
  tens = 0;
  while (ones >= 10)
  {
    ones -= 10;
    tens++;
  }

  if (ones & 1)
    DrawPx(7, 0, SecondColor);
  if (ones & 2)
    DrawPx(7, 1, SecondColor);
  if (ones & 4)
    DrawPx(7, 2, SecondColor);
  if (ones & 8)
    DrawPx(7, 3, SecondColor);

  if (tens & 1)
    DrawPx(6, 0, SecondColor);
  if (tens & 2)
    DrawPx(6, 1, SecondColor);
  if (tens & 4)
    DrawPx(6, 2, SecondColor);


  ones = minute();
  tens = 0;
  while (ones >= 10)
  {
    ones -= 10;
    tens++;
  }

  if (ones & 1)
    DrawPx(5, 0, MinuteColor);
  if (ones & 2)
    DrawPx(5, 1, MinuteColor);
  if (ones & 4)
    DrawPx(5, 2, MinuteColor);
  if (ones & 8)
    DrawPx(5, 3, MinuteColor);

  if (tens & 1)
    DrawPx(4, 0, MinuteColor);
  if (tens & 2)
    DrawPx(4, 1, MinuteColor);
  if (tens & 4)
    DrawPx(4, 2, MinuteColor);

  ones = hour();
  tens = 0;
  while (ones >= 10)
  {
    ones -= 10;
    tens++;
  }

  if (ones & 1)
    DrawPx(3, 0, HourColor);
  if (ones & 2)
    DrawPx(3, 1, HourColor);

  if (ones & 4)
    DrawPx(3, 2, HourColor);

  if (ones & 8)
    DrawPx(3, 3, HourColor);

  if (tens & 1)
    DrawPx(2, 0, HourColor);
  if (tens & 2)
    DrawPx(2, 1, HourColor);

  ones = day();

  if (ones & 1)
    DrawPx(1, 0, DayColor);
  if (ones & 2)
    DrawPx(1, 1, DayColor);
  if (ones & 4)
    DrawPx(1, 2, DayColor);
  if (ones & 8)
    DrawPx(1, 3, DayColor);
  if (ones & 16)
    DrawPx(1, 4, DayColor);

  ones = month();

  if (ones & 1)
    DrawPx(0, 0, MonthColor);
  if (ones & 2)
    DrawPx(0, 1, MonthColor);
  if (ones & 4)
    DrawPx(0, 2, MonthColor);
  if (ones & 8)
    DrawPx(0, 3, MonthColor);

  DisplaySlate();      // Write the updated game buffer to the screen.
}

void printDigits(byte digits) {
  // utility function for digital clock display: prints preceding colon and leading 0
  Serial.print(":");
  if (digits < 10)
    Serial.print('0');
  Serial.print(digits, DEC);
}
