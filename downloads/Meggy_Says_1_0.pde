/*
Meggy_Says v. 1.0
A "Simon" like game.
Written for Meggy Jr RGB by Greg Prevost Copyright 2008.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

Instructions:

Hold down A or B until you hear the start tone to begin the game.
Repeat the sequence you see by using the arrow keys.  Each round the
sequence will increase by 1.  Keep going until you make a mistake.  
Hold down A or B to start again.

Your score is displayed using the auxillary LEDs in binary.  

Future versions to include differen difficulty levels which will change
the speed of the sequence playback and add a timer function which will
end you game if input is not recieved soon enough.

*/

#include <MeggyJrSimple.h> //required code line 1 of 2

byte sequence[256], playerSequence[256], i, j, k, score, nextLight, nextNum;
boolean correct, cont, start, repeat;

void setup()
{
 
  MeggyJrSimpleSetup();  //required code line 2 of 2
  start = true;
  repeat = false;
  correct = false;
  cont = false;
  score = 0;
  i=0;
}

//displays red x (used when player makes a mistake).
void redX()
{
  
  DrawPx(0,0,Red);
  DrawPx(0,1,Red);
  DrawPx(1,1,Red);
  DrawPx(1,0,Red);
  DrawPx(6,0,Red);
  DrawPx(7,0,Red);
  DrawPx(7,1,Red);
  DrawPx(6,1,Red);
  DrawPx(2,2,Red);
  DrawPx(5,2,Red);
  DrawPx(3,3,Red);
  DrawPx(4,3,Red);
  DrawPx(3,4,Red);
  DrawPx(4,4,Red);
  DrawPx(2,5,Red);
  DrawPx(5,5,Red);
  DrawPx(0,6,Red);
  DrawPx(1,6,Red);
  DrawPx(6,6,Red);
  DrawPx(7,6,Red);
  DrawPx(0,7,Red);
  DrawPx(1,7,Red);
  DrawPx(6,7,Red);
  DrawPx(7,7,Red);
  DisplaySlate();
  
}

//lights yellow without tone
void blinkYellow()
{
  
  DrawPx(0,4,Yellow);
  DrawPx(0,3,Yellow);
  DrawPx(0,2,Yellow);
  DrawPx(1,2,Yellow);
  DrawPx(1,5,Yellow);
  DrawPx(0,5,Yellow);
  DrawPx(1,4,Yellow);  
  DrawPx(1,3,Yellow);
  DrawPx(2,4,Yellow);
  DrawPx(2,3,Yellow);
  DisplaySlate();
  
}

//lights red without tone
void blinkRed()
{
  
  DrawPx(6,4,Red);  
  DrawPx(6,3,Red);
  DrawPx(5,4,Red);
  DrawPx(5,3,Red);
  DrawPx(7,2,Red);
  DrawPx(7,3,Red);
  DrawPx(7,4,Red);
  DrawPx(7,5,Red);
  DrawPx(6,2,Red);
  DrawPx(6,5,Red);
  DisplaySlate();
  
}

//lights green without tone
void blinkGreen()
{
  
  DrawPx(3,1,Green);  
  DrawPx(3,2,Green);
  DrawPx(4,1,Green);
  DrawPx(4,2,Green);
  DrawPx(2,0,Green);
  DrawPx(3,0,Green);
  DrawPx(4,0,Green);
  DrawPx(5,0,Green);
  DrawPx(2,1,Green);
  DrawPx(5,1,Green);
  DisplaySlate();
  
}

//lights blue without tone
void blinkBlue()
{
  
  DrawPx(3,6,Blue);  
  DrawPx(3,5,Blue);
  DrawPx(4,6,Blue);
  DrawPx(4,5,Blue);
  DrawPx(2,7,Blue);
  DrawPx(3,7,Blue);
  DrawPx(4,7,Blue);
  DrawPx(5,7,Blue);
  DrawPx(2,6,Blue);
  DrawPx(5,6,Blue);
  DisplaySlate();
  
}

//lights yellow and plays tone
void lightYellow()
{
  DrawPx(0,4,Yellow);//left
  DrawPx(0,3,Yellow);
  DrawPx(0,2,Yellow);
  DrawPx(1,2,Yellow);
  DrawPx(1,5,Yellow);
  DrawPx(0,5,Yellow);
  DrawPx(1,4,Yellow);  
  DrawPx(1,3,Yellow);
  DrawPx(2,4,Yellow);
  DrawPx(2,3,Yellow);
    
  Tone_Start(ToneD5, 200);
  DisplaySlate();
  delay(205);
  Tone_Update();
}

//lights red and plays tone
void lightRed()
{
  DrawPx(6,4,Red);  //right
  DrawPx(6,3,Red);
  DrawPx(5,4,Red);
  DrawPx(5,3,Red);
  DrawPx(7,2,Red);
  DrawPx(7,3,Red);
  DrawPx(7,4,Red);
  DrawPx(7,5,Red);
  DrawPx(6,2,Red);
  DrawPx(6,5,Red);
  
  Tone_Start(ToneE5, 200);
  DisplaySlate();
  delay(205);
  Tone_Update();
}

//lights blue and plays tone
void lightBlue()
{
  DrawPx(3,6,Blue);  //up
  DrawPx(3,5,Blue);
  DrawPx(4,6,Blue);
  DrawPx(4,5,Blue);
  DrawPx(2,7,Blue);
  DrawPx(3,7,Blue);
  DrawPx(4,7,Blue);
  DrawPx(5,7,Blue);
  DrawPx(2,6,Blue);
  DrawPx(5,6,Blue);
   
  Tone_Start(ToneF5, 200);
  DisplaySlate();
  delay(205);
  Tone_Update();
}

//lights green and plays tone
void lightGreen()
{
  DrawPx(3,1,Green);  //down
  DrawPx(3,2,Green);
  DrawPx(4,1,Green);
  DrawPx(4,2,Green);
  DrawPx(2,0,Green);
  DrawPx(3,0,Green);
  DrawPx(4,0,Green);
  DrawPx(5,0,Green);
  DrawPx(2,1,Green);
  DrawPx(5,1,Green);
    
  Tone_Start(ToneC5, 200);
  DisplaySlate();
  delay(205);
  Tone_Update();
}

//displays default game board (all colors dimmed)
void lightNone()
{
  DrawPx(0,4,DimYellow);//left
  DrawPx(0,3,DimYellow);
  DrawPx(0,2,DimYellow);
  DrawPx(1,2,DimYellow);
  DrawPx(1,5,DimYellow);
  DrawPx(0,5,DimYellow);
  DrawPx(1,4,DimYellow);  
  DrawPx(1,3,DimYellow);
  DrawPx(2,4,DimYellow);
  DrawPx(2,3,DimYellow);

  
  DrawPx(6,4,DimRed);  //right
  DrawPx(6,3,DimRed);
  DrawPx(5,4,DimRed);
  DrawPx(5,3,DimRed);
  DrawPx(7,2,DimRed);
  DrawPx(7,3,DimRed);
  DrawPx(7,4,DimRed);
  DrawPx(7,5,DimRed);
  DrawPx(6,2,DimRed);
  DrawPx(6,5,DimRed);
  
  DrawPx(3,6,DimBlue);  //up
  DrawPx(3,5,DimBlue);
  DrawPx(4,6,DimBlue);
  DrawPx(4,5,DimBlue);
  DrawPx(2,7,DimBlue);
  DrawPx(3,7,DimBlue);
  DrawPx(4,7,DimBlue);
  DrawPx(5,7,DimBlue);
  DrawPx(2,6,DimBlue);
  DrawPx(5,6,DimBlue);
  
  DrawPx(3,1,DimGreen);  //down
  DrawPx(3,2,DimGreen);
  DrawPx(4,1,DimGreen);
  DrawPx(4,2,DimGreen);
  DrawPx(2,0,DimGreen);
  DrawPx(3,0,DimGreen);
  DrawPx(4,0,DimGreen);
  DrawPx(5,0,DimGreen);
  DrawPx(2,1,DimGreen);
  DrawPx(5,1,DimGreen);
  
  DisplaySlate();
}

//method accessed when game ends. 
//Displays red x and blinks the "buttons" and aux leds until a or b is pressed
void end()
{
 
  Tone_Start(43243, 1000); //error tone
  ClearSlate();
  redX();
  DisplaySlate();
  delay(1005);
  Tone_Update();
  
  
    while(!correct && !start)
    {
     blinkBlue();
     SetAuxLEDs(0);
     delay(100);
     ClearSlate();
     redX();
     blinkYellow();
     SetAuxLEDs(score + 1);
     delay(100);
     ClearSlate();
     redX();
     blinkGreen();
     SetAuxLEDs(0);
     delay(100);
     ClearSlate();
     redX();
     blinkRed();
     SetAuxLEDs(score + 1);
     delay(100);
     ClearSlate();
     redX();
     CheckButtonsPress();
     
        if (Button_A || Button_B) //reset game
        {
          ClearSlate();
          DisplaySlate();
          repeat = true;
          score = 0;
          start = true; 
        }
        
     }   
     
}

void loop ()
{

while (start)
 
 {
   
   if (!repeat)  //Flashes game board. Only runs on power up. Repeat is set to true during end().
   
   {
     randomSeed(millis());
     lightNone();
     DisplaySlate();
     delay(1000);
     ClearSlate();
     DisplaySlate();
     delay(1000);
     CheckButtonsDown();
   }
   
   
   if (Button_A || Button_B)  //start game
   
   {
     
     Tone_Start(ToneD6, 200);
     delay(205);
     Tone_Update();
     Tone_Start(ToneF6, 200);
     delay(205);
     Tone_Update();
     Tone_Start(ToneG6, 200);
     delay(205);
     Tone_Update();
     
     i=0;
     
     while (i<255)  //creates pseudo random color sequence
     {
      nextNum = random(1,5);
      sequence[i]=nextNum;
      i++;
     }
  
      correct = true;
      cont = true;
      Tone_Update();
      lightNone();
      DisplaySlate();
      delay(1500);
      SetAuxLEDs(score + 1);
      start = false;
  }
  
 }
 
 
  
if (cont && correct)  //plays back sequence until j reaches the current round
{  
  
  j=0;
  
  while (j < score + 1)
  {
    
    delay(100);
    nextLight = sequence[j];
    
    switch (nextLight)
      {
        
        case 1:
        {
        lightYellow();
        delay(100);
        lightNone();
        j++;
        break;
        }
        
        case 2:
        {
        lightRed();
        delay(100);
        lightNone();
        j++;
        break;
        }
        
        case 3:
        {
        lightBlue();
        delay(100);
        lightNone();
        j++;
        break;
        }
        
        case 4:
        {
        lightGreen();
        delay(100);
        lightNone();
        j++;
        break;
        }
        
      }
      
    Tone_Update();
    cont = false;  //sentinel   
 }
 

if(!cont && correct);  //Player uses arrow keys to enter sequence.  If incorrect at any point game ends immediately.
{
  k=0;
 
  while (k < score + 1 && correct )
  {
  
    CheckButtonsDown();
  
    if (Button_Left)
    {
      
     lightYellow();
     lightNone();
     playerSequence[k] = 1;
     
     if (playerSequence[k] == sequence[k])
     {
      correct = true;
      k++;
     }
     
     else
     {
      correct = false;
      end();
     }
     
    }
     
    if (Button_Right)
    {
      
     lightRed();
     lightNone();
     playerSequence[k] = 2;
     
     if (playerSequence[k] == sequence[k])
     {
      correct = true;
      k++;
     }
     
      else
     {
      correct = false;
      end();
    }
    
  }
  
    if (Button_Up)
    {
     lightBlue();
     lightNone();
     playerSequence[k] = 3;
     
    if (playerSequence[k] == sequence[k])
    {
    correct = true;
    k++;
    }
    
    else
    {
     correct = false;
     end();
    }
    
   }
  
  if (Button_Down)
  {
   lightGreen();
   lightNone();
   playerSequence[k] = 4;
   
   if (playerSequence[k] == sequence[k])
    {
     correct = true;
     k++;
    }
    
    else
    {
      correct = false;
      end();
    }
    
  }
  
 }
  
 if (correct)
 {
   cont = true; //sentinel
   score++;    //increase score.  sequence will be 1 unit longer.
   SetAuxLEDs(score + 1);
   delay(500);
 }
   
 }
 
  
    
}
  
DisplaySlate();
Tone_Update();

}
