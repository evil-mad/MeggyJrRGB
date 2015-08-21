/*
Meggy_Mind.pde
  A code breaking game similar to "Master Mind" for
  the MeggyJr game platform.
  http://www.evilmadscientist.com/
  
  
 Version 1.0 - 5/3/2009
 Copyright (c) 2009 T.E.C. Jones
 
 OBJECT OF GAME:
 Match the secret code sequence of 4 colors in 8 or fewer guesses and get
 points and another chance to play!
 
 GAME CONTROLS:
 <LEFT> Moves cursor left.
 <RIGHT> Moves cursor right.
 <UP> cycles up through colors.
 <DOWN> cycles down through colors.
 
 <Button_A> Submits guess for evaluation.
 <Button_B> Starts next game. Resets if you lost.
 
 Push A & B Together to reset. 
 
 GAME PLAY:
 Move blinking cursor with left and right buttons to select pixel to change.
 Use up and down buttons to cycle through colors. Push Button "A" to have Meggy
 evaluate your guess. 
 
 DimGreen pixels mean position and color are both correct.
 White pixels mean a color is correct, but it is in the wrong position.
 
 The DimGreen and White pixels DO NOT indicate which of the guess colors are correct,
 you must figure that out for yourself!
 
 WINNING THE GAME:
 Match the secret code sequence of four colors correctly and you will get four blinking DimGreen
 evaluation pixels. Press "B" to update your score, displayed in reverse binary on the AuxLEDs.
 The fewer the guesses, the higher the score.
 
 If you don't guess the secret code in eight tries, the secret code will be displayed in the
 evaluation area and pressing the "B" button will reset the game and your score.
 
 
 ////////////////////////////////////////////////////////////////////////////////////
 
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
 	  
 */


//PROGRAM BEGINS HERE


#include <MeggyJrSimple.h>    // Required code, line 1 of 2.
/*
Set the Colors to play with.  White (7), DimGreen (11) and FullOn (15) are reserved and 
should not be included in color range. Change minColor to 0 (Dark) to easily add a seventh
color. Or you could use the custom color range for a total customized Meggy_Mind Experience!
*/
#define maxColor 6 // highest numbered color in range
#define minColor 1 //lowest number color in range
byte prevColor, score, cursorX,guessY,colorChoice,secretCode[4],guessCode[4];
boolean reset;

void setup()                    // run once, when the sketch starts
{

  MeggyJrSimpleSetup();   // Required code, line 2 of 2.
  score=0;
  } // End setup()

void blinkCursor(){
  prevColor=ReadPx(cursorX,guessY);
  DrawPx(cursorX,guessY,FullOn);
  DisplaySlate();
  delay(9);
  DrawPx(cursorX,guessY,prevColor);
  DisplaySlate();
  delay(180);
}

void setGuessCode(){  //initialize guessCode array
 if (guessY == 0) {   //if first row set to minColor
  for (int i=0;i<4;i++){
    guessCode[i]=minColor;
    DrawPx(i,guessY,minColor);
  }
 }
 else {
   for (int i=0;i<4;i++) { //copy previous guess for subsequent rows
     guessCode[i]=ReadPx(i,guessY-1);
     DrawPx(i,guessY,guessCode[i]);
   }
   DisplaySlate();
 }
}
  

void loop()                     // run over and over again
{  
 //Set our initial conditions 
  ClearSlate();
  SetAuxLEDs(score);
  cursorX=0; //cursor x-axis position
  guessY=0; //cursor y-axis position increments with each player guess
  colorChoice=1;
  for (int i=0;i<4;i++){ //generate a pseudo random secret code
    secretCode[i]=random(minColor,maxColor+1);
  }
  setGuessCode(); //set guessCode array to appropriate condition
  DisplaySlate();
  reset = false;  
  while (!reset) { 

    CheckButtonsPress();   //Check to see which buttons are down that weren't before.

    if(Button_A&&Button_B){ //reset the game
      reset=true;
      }
    

    // Evaluate the player's guess
    if (Button_A)  { 
      byte correct = 0;
      byte correctColorOnly = 0;
      byte position = 4;
      boolean secretCodeMatched[4],guessCodeMatched[4];
      for (int i=0;i<4;i++){ //initialize code matched arrays
        guessCodeMatched[i]=false;
        secretCodeMatched[i]=false;
      }
      for(int i=0; i<4; i++){ 
        guessCode[i]=ReadPx(i,guessY);//read the Player's guess into an array
      }
      for (int i=0; i<4; i++){ //Count guesses that are correct in color and position
        if (guessCode[i]==secretCode[i]){
          secretCodeMatched[i]=true;
          guessCodeMatched[i]=true;  //so we don't count them again
          correct++;
        }
      }
      for (int i=0; i<4; i++){ //Count guesses that are correct colors in wrong positions
          if (!guessCodeMatched[i]){
            for (int j=0; j<4; j++){
              if (!secretCodeMatched[j]){
                if(guessCode[i]==secretCode[j]){
                   secretCodeMatched[j]=true;
                   correctColorOnly++;
                   break; //so we count matches only once
                  }
                }
            }
          }
          
      }
      if (correct>0){ 
        for (int i=0; i<correct;i++){
          DrawPx(position,guessY,DimGreen);
          position++;
        }
       DisplaySlate();
      }
     if (correct==4){ //Player Wins!!!
       while (!Button_B){
        CheckButtonsDown();
        for (int i=4;i<8;i++){
          DrawPx(i,guessY,FullOn);
        }
        DisplaySlate();
        delay(20);
        for (int i=4;i<8;i++){
          DrawPx(i,guessY,DimGreen);
        }
        DisplaySlate();
        delay(200);
       }
       score=score+8-guessY; //reap your reward!
       reset=true;
      }
     else {
      if (guessY == 7) { //Player Loses!!!!
        for (int i=4;i<8;i++){
          DrawPx(i,guessY,secretCode[i-4]); //Show what the secret code was
        }
        DisplaySlate();
        while (!Button_B){
          CheckButtonsDown();
        }
        score=0;
        reset=true;
      }
      if (correctColorOnly>0){
        for (int i=0; i<correctColorOnly;i++){
          DrawPx(position,guessY,White);
          position++;
        }
        
      } 
      
      guessY++; //move up a row for the next guess
      setGuessCode();
      cursorX=0;
      DisplaySlate(); 
     }
    }
    if (Button_Left){
      if (cursorX == 0) {
        cursorX=3;
      }
      else {
        cursorX--;
      }
      DisplaySlate();
    }
    if (Button_Right){
      if (cursorX == 3) {
        cursorX = 0;
      }
      else {
        cursorX++;
      }
      DisplaySlate();
    }
    if (Button_Up) {
      colorChoice=ReadPx(cursorX,guessY);
      if (colorChoice == maxColor) {
        DrawPx(cursorX,guessY,minColor);
      }
      else {
        colorChoice++;
        DrawPx(cursorX,guessY,colorChoice);
      }
      DisplaySlate();

    }
    if (Button_Down) {
      colorChoice=ReadPx(cursorX,guessY);
      if (colorChoice == minColor) {
        DrawPx(cursorX,guessY,maxColor);
      }
      else {
        colorChoice--;
        DrawPx(cursorX,guessY,colorChoice);
      }
      DisplaySlate();

    }
    blinkCursor();
  }  
}
