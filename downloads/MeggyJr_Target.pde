
/*
  MeggyJr_Target.pde
 
 Using the The Meggy Jr Simplified Library (MJSL)
  from the Meggy Jr RGB library for Arduino
   
 Bounce a damned target.
   
   
 
 Version 1.00 - 04/8/2009
 Copyright (c) 2009 Zachariah Attoun Bauermeister.  All right reserved.
 http://www.bucketon.com/
 
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

#include <MeggyJrSimple.h>    // Meggy Jr simple library.  Required.

//OMGlobals

byte xpos;//crosshairs position
byte ypos;

byte EnemyX;//Target current position
byte EnemyY;
byte xspeed;//target direction(x, y) 1 = forward, 2 = backward, 0 = none.
byte yspeed;
byte tspeed;//target current speed (lower is faster)

byte shots;//shots remaining, displayed on auxleds.


byte Score[8];//what you got for each shot.
byte column;//a variable that's used later to scroll stuff.
byte stop;//a variable that's used later to make it stop scrolling stuff.

byte wide;//obvious
byte high;
/*byte grid[64] = {00,00,00,00,00,00,00,00,//the background.  not currently in use, but can make the game trippy.
                   00,00,00,00,00,00,00,00,
                   00,00,00,00,00,00,00,00,
                   00,00,00,00,00,00,00,00,
                   00,00,00,00,00,00,00,00,
                   00,00,00,00,00,00,00,00,
                   00,00,00,00,00,00,00,00,
                   00,00,00,00,00,00,00,00};*/

                 
int counter;//a counter that is used to synchronize things and slow things down.

void setup()                    // run once, when the sketch starts
{
  MeggyJrSimpleSetup();      // Required code.  initialized meggy's business.
  
  shots = 8;//shots remaining, displayed on auxleds.
  byte LEDnum = 1;//this whole block initializes the auxleds.  Why didn't I just set them to 255?  Idk.
  for(byte i = 0; i < shots; i++){
    LEDnum *= 2;
  }
  SetAuxLEDs(LEDnum -1);
  
  xpos = 3;//crosshairs position
  ypos = 3;

  EnemyX = 4;//Target current position
  EnemyY = 4;
  xspeed = 1;//target direction(x, y) 1 = forward, 2 = backward, 0 = none.
  yspeed = 1;
  tspeed = 8;//target current speed (lower is faster)

  for(byte f = 0; f < 8; f++){
    Score[f] = 0;//what you got for each shot.
  }
  column = 0;//a variable that's used later to scroll stuff.
  stop = 0;//a variable that's used later to make it stop scrolling stuff.

  wide = 8;//obvious
  high = 8;
  
  counter = 0;
}

void loop()                     // main game loop.
{
  if(counter < 255){
    counter++;//obvious
  }else{
    counter = 0;
  }
  
  if(shots > 0){//MAIN GAME LOOP
    
    /*for(byte i = 0; i < wide; i++){//HARD MODE
      for(byte e = 0; e < high; e++){
        grid[e + wide*i] = rand()%15;
      }
    }*/
    
  CheckButtonsPress();//check to see which buttons have been triggered

  if (Button_A){//shooting code in here.
    
    for(byte i = 0; i < wide; i++){//screen flash
      for(byte e = 0; e < high; e++){
        DrawPx(i, e, White);
      }
    }
    DisplaySlate();
    delay(10);
    
    xspeed = (rand() % 3);//random direction
    if(xspeed == 0){//make sure that it doesn't stand still
      yspeed = (rand() % 2) + 1;
    }else{
      yspeed = (rand() % 3);
    }
    
    if((xpos == EnemyX) && (ypos == EnemyY)){//bullseye collision
      tspeed--;
      Tone_Start(ToneD4, 30);
      delay(30);
      Tone_Start(ToneD5, 70); 
      Score[8 - shots] = 2;//score
    }else if(((xpos == EnemyX) || (xpos == (EnemyX + 1)) || (xpos == (EnemyX - 1))) && ((ypos == EnemyY) || (ypos == (EnemyY + 1)) || (ypos == (EnemyY - 1)))){//white ring collision
      tspeed--;
      Tone_Start(ToneD4, 50); 
      Score[8 - shots] = 1; //score
    }else{//miss
      Tone_Start(ToneD3, 500);  
      Score[8 - shots] = 0;
    }
    
    EnemyX = (rand() % 6) + 1;//new target position
    EnemyY = (rand() % 6) + 1;
    
    ClearSlate();//clearscreen
    DisplaySlate();
    
    shots--;//obvious
    
    byte LEDnum = 1;//set auxleds to reflect change in shots
    for(byte j = 0; j < shots; j++){
      LEDnum *= 2;
    }
    SetAuxLEDs(LEDnum -1);
  }
  
  if (Button_B){//nothing in here now
    
  }
  
 /* for(byte i = 0; i < high; i++){ //Draw Background
    for(byte e = 0; e < wide; e++){
        DrawPx(e, i, grid[e + wide*i]);
    }
  }*/
  
  CheckButtonsDown();   //Check to see which buttons are currently down.
  
  if((counter % 2) == 0){//only move cursor every other frame, otherwise it is too difficult to control
    if(Button_Up && ypos < high-1){
      ypos++;
      Tone_Start(ToneD5, 5);   
    }
    if(Button_Down && ypos > 0){
      ypos--;
      Tone_Start(ToneD5, 5); 
    }
    if(Button_Left && xpos > 0){
      xpos--;
      Tone_Start(ToneD5, 5); 
    }
    if(Button_Right && xpos < wide-1){
      xpos++;
      Tone_Start(ToneD5, 5); 
    }
  }
  
  if((counter % tspeed) == 0){//move target
    if(EnemyX > 5){//bounce off of walls
      xspeed = 2;
    }else if(EnemyX < 2){
      xspeed = 1;
    }
    if(EnemyY > 5){
      yspeed = 2;
    }else if(EnemyY < 2){
      yspeed = 1;
    }
    
    if(xspeed == 1 && EnemyX <= 5){//move based on direction variables
      EnemyX++;
    }
    if(xspeed == 2 && EnemyX >= 2){
      EnemyX--;
    }
    
    if(yspeed == 1 && EnemyY <= 5){
      EnemyY++;
    }
    if(yspeed == 2 && EnemyY >= 2){
      EnemyY--;
    }
  }
  
  DrawPx(EnemyX, EnemyY, Red);//draw target
  DrawPx(EnemyX+1, EnemyY, White);
  DrawPx(EnemyX, EnemyY+1, White);
  DrawPx(EnemyX+1, EnemyY+1, White);
  DrawPx(EnemyX-1, EnemyY, White);
  DrawPx(EnemyX+1, EnemyY-1, White);
  DrawPx(EnemyX-1, EnemyY+1, White);
  DrawPx(EnemyX, EnemyY-1, White);
  DrawPx(EnemyX-1, EnemyY-1, White);
  
  for(byte i = 0; i < high; i++){//Draw Crosshairs
    if(i != ypos){
    DrawPx(xpos, i, Blue);
    }
  }
  for(byte i = 0; i < wide; i++){
    if(i != xpos){
    DrawPx(i, ypos, Blue);
    }
  }
  
  DisplaySlate();                  // Write the drawing to the screen.
  
  ClearSlate();                 // Erase drawing
   
  delay(30);
  }
  else
  {//SCORE DISPLAY ZONE
    
    CheckButtonsPress();//check button trigger for reset w/ B
  
    if(stop == 0){//don't do this if stop is set
      for(byte i = 0; i < 8; i++){// for each y value
        if(Score[column] == 2){//red score
          DrawPx(0, i, Red);
        }else if(Score[column] == 1){//white score
          DrawPx(0, i, White);
        }else{//no score
          DrawPx(0, i, Dark);
        }
      }
    }
    
    DisplaySlate();
    
    if(column >= 7){//
      //column = 0;
      stop = 1;
    }
    
    if(stop == 0){
      byte x = 7;//variable for scrolling handling
      while (x > 0)
      {
  
        DrawPx(x,0, ReadPx(x-1,0));
        DrawPx(x,1, ReadPx(x-1,1));
        DrawPx(x,2, ReadPx(x-1,2));
        DrawPx(x,3, ReadPx(x-1,3));
        DrawPx(x,4, ReadPx(x-1,4));
        DrawPx(x,5, ReadPx(x-1,5));
        DrawPx(x,6, ReadPx(x-1,6));
        DrawPx(x,7, ReadPx(x-1,7));

        x--;
      }
    }
    
    column++;
    
    
    delay(100);
    DisplaySlate();
    
    if(Button_B){
      shots = 8;//shots remaining, displayed on auxleds.
      
      byte LEDnum = 1;//this whole block initializes the auxleds.  Why didn't I just set them to 255?  Idk.
      for(byte i = 0; i < shots; i++){
        LEDnum *= 2;
      }
      SetAuxLEDs(LEDnum -1);
    
      EnemyX = (rand()%6) + 1;//Target current position
      EnemyY = (rand()%6) + 1;
      xspeed = (rand() % 3);//random direction
      if(xspeed == 0){//make sure that it doesn't stand still
        yspeed = (rand() % 2) + 1;
      }else{
        yspeed = (rand() % 3);
      }
      tspeed = 8;//target current speed (lower is faster)

      for(byte g = 0; g < 8; g++){
        Score[g] = 0;//what you got for each shot.
      }
      column = 0;//a variable that's used later to scroll stuff.
      stop = 0;//a variable that's used later to make it stop scrolling stuff.

      wide = 8;//obvious
      high = 8;
  
      counter = 0;
    }
    
  }
}


