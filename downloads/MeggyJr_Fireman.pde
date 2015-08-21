/*
 MeggyJr_Fireman.pde 

 Version 1.2  1-17-2009
 Mark White, MD  mark@codefun.com  www.codefun.com
 Special thanks to Ken Corey.

 This is a fabulous cover of the 80s classic, Fireman Fireman.  It was an LCD "game/watch," one 
 of Nintendo's first attempts to make a home video game.  The game is simple: babies  drop from 
 a burning building while you direct a two-man team that bounces the babies into a waiting
 ambulance.  Drop three babies and you're fired!
 
 There is a menu to allow selection of four game options.  The Up or Down arrows enter the menu.
 The direction buttons navigate the menu.  The A button toggles each selection.  The B button
 exits the menu.
 
 The four menu game options are:
 
 1. Sound (not too obnoxious)
 2. Fire (slightly distracting)
 3. Animate the babies as they bounce (definitely distracting)
 4. Show background graphics (extremely distracting)
  
 Game Buttons:
 Button A or Right Button - Moves the crew to the right
 Button B or Left Button - Moves the crew to the left
 Up Button - Enters menu
 Down Button - Enters menu
 
 Aux LEDs - Display current score in left to right binary

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

#include <MeggyJrSimple.h>

byte Path[59][6]={// creates the path for the babies to bounce across the screen + the animation sequence for each babie
  {0,7,0,7,1,7}, {0,7,0,7,1,7}, {0,7,0,7,1,7}, {0,7,0,7,1,7}, {0,6,0,7,1,6}, {0,6,0,7,1,6}, {0,6,0,7,1,6}, {0,5,0,6,1,5},//0-7
  {0,5,0,6,1,5}, {0,4,0,5,1,4}, {0,4,0,5,1,4}, {0,3,0,4,1,3}, {0,3,0,4,1,3}, {0,2,0,3,1,2}, {0,2,0,3,1,2}, {0,1,0,2,1,1},//8-15
  {1,2,0,1,2,3}, {1,3,1,2,2,3}, {1,3,2,2,2,4}, {1,4,2,4,1,5}, {1,4,2,5,0,5}, {1,5,1,6,0,5}, {1,5,0,6,0,4}, {1,5,0,5,1,4},//16-23
  {2,6,1,5,1,6}, {2,6,2,5,1,5}, {2,6,3,5,2,5}, {2,6,3,6,3,5}, {3,5,4,6,3,6}, {3,5,3,6,2,6}, {3,5,2,6,2,5}, {3,4,2,4,2,3},//24-31
  {3,4,2,3,4,2}, {3,3,3,2,4,3}, {3,3,4,2,4,4}, {3,2,4,2,3,3}, {3,2,4,3,2,3}, {3,1,3,2,2,1}, {4,2,3,1,5,3}, {4,3,3,3,5,2},//32-39
  {4,3,3,4,4,2}, {4,4,4,5,3,4}, {4,4,5,5,4,5}, {4,4,5,4,5,5}, {5,5,6,4,5,6}, {5,5,5,4,5,6}, {5,5,4,4,6,6}, {5,5,4,5,6,5},//40-47
  {6,4,5,5,7,4}, {6,4,6,5,7,4}, {6,4,7,5,7,3}, {6,3,7,3,6,2}, {6,3,7,2,5,2}, {6,2,6,1,5,2}, {6,2,5,1,5,3}, {6,1,5,1,6,2},//48-55
  {7,2,6,1,7,3}, {7,2,7,2,7,3}, {0,0,0,0,0,0}, //56-58
};


unsigned long TimeNow, HoldTime, WaitTime, FireTime, WaitFire;
int Score = 0;
int ThisMenu = 0;
byte TickCount;
byte WaitKey;
byte ClockTick = 0;
byte DoThis = 0;
byte BirthControl = 0;
byte HandsUp = 0;
byte SpinBaby = 0;
byte BurnBaby = 0;
byte DrawBack = 0;
byte TheseButtons = 0;
byte OldButton = 0;
byte NewButton = 0;
int PlayButton = 0;
byte ThisBaby = 0;
byte BabyNum = 1;
byte BabySplat = 0;
byte SplatShow = 0;
byte DeadBabies = 0;
byte Baby[16][3];
int ManSpot = 1;
byte ThisFire = 0;
byte SkewRight = 0;
byte ManX[4] = {0,0,3,6};
byte Fire[11] = {DimRed, Red, DimRed, Yellow, Dark, Dark, Red, Dark, Orange, Orange, Red};

void setup() // Set initial values
{
  MeggyJrSimpleSetup();
  EditColor(CustomColor0,15,15,15);// Baby Blanket
  EditColor(CustomColor1,2,2,1);// Ambulance
  EditColor(CustomColor2,3,5,1);// Baby Face
  EditColor(CustomColor3,2,0,0);// Fireman Legs
  EditColor(CustomColor4,1,1,1);// Stretcher
  EditColor(CustomColor5,5,8,1);// Fireman Face
  EditColor(CustomColor6,2,0,0);// Cross
  EditColor(CustomColor7,1,0,15);// Baby Lives
  EditColor(CustomColor8,15,1,0);// Fireman Arms
}  // End setup

void IntroScreen()// displays "FIRE" until a button is pushed
{
  byte i,j,k,l;
  ClockTick = 0;
  ThisFire++; if (ThisFire==11) {ThisFire=0;}
  i=ThisFire; j=(i+1)%11; k=(i+2)%11; l=(i+3)%11;
  ClearSlate();
  if (Fire[i] != Dark){DrawPx(5,5,Fire[i]);DrawPx(5,4,Fire[i]);DrawPx(5,3,Fire[i]);DrawPx(5,2,Fire[i]);DrawPx(5,1,Fire[i]);DrawPx(6,5,Fire[i]);DrawPx(7,5,Fire[i]);DrawPx(6,3,Fire[i]);DrawPx(7,3,Fire[i]);DrawPx(6,1,Fire[i]);DrawPx(7,1,Fire[i]);}
  if (Fire[j] != Dark){DrawPx(3,4,Fire[j]);DrawPx(4,4,Fire[j]);DrawPx(5,4,Fire[j]);DrawPx(3,3,Fire[j]);DrawPx(3,2,Fire[j]);DrawPx(3,1,Fire[j]);DrawPx(3,0,Fire[j]);DrawPx(4,2,Fire[j]);DrawPx(5,3,Fire[j]);DrawPx(5,1,Fire[j]);DrawPx(6,0,Fire[j]);}
  if (Fire[k] != Dark){DrawPx(1,6,Fire[k]);DrawPx(2,6,Fire[k]);DrawPx(3,6,Fire[k]);DrawPx(2,5,Fire[k]);DrawPx(2,4,Fire[k]);DrawPx(2,3,Fire[k]);DrawPx(1,2,Fire[k]);DrawPx(2,2,Fire[k]);DrawPx(3,2,Fire[k]);}
  if (Fire[l] != Dark){DrawPx(0,7,Fire[l]);DrawPx(0,6,Fire[l]);DrawPx(0,5,Fire[l]);DrawPx(0,4,Fire[l]);DrawPx(0,3,Fire[l]);DrawPx(1,7,Fire[l]);DrawPx(2,7,Fire[l]);DrawPx(1,5,Fire[l]);DrawPx(2,5,Fire[l]);}
  DisplaySlate();
}// end IntroScreen

void DrawBabies()
{
  byte i;
  for (i=1;i<=BabyNum;i++){
    if (SpinBaby) {
      DrawPx(Path[Baby[i][0]][2],Path[Baby[i][0]][3],DimBlue);
      DrawPx(Path[Baby[i][0]][4],Path[Baby[i][0]][5],CustomColor2);
    }//end spinbaby
    DrawPx(Path[Baby[i][0]][0],Path[Baby[i][0]][1],CustomColor0);
  }//End_for
}//end DrawBabies

void DrawFire()
{
  if (!BurnBaby) {return;}
  byte i,j,k,l,ii,jj,kk,ll;
  ThisFire++; if (ThisFire==11) {ThisFire=0;}
  i=ThisFire; j=(i+1)%11; k=(i+2)%11; l=(i+3)%11;
  DrawPx(0,7,Fire[l]); DrawPx(0,6,Fire[k]); DrawPx(1,7,Fire[k]);  DrawPx(0,5,Fire[j]); DrawPx(1,6,Fire[l]); DrawPx(2,7,Fire[j]); DrawPx(3,7,Fire[i]);
  ii = random(0,3); jj = random(0,3); kk = random(0,5); ll = random(0,5);
  DrawPx(ii,7-jj,Fire[l]); DrawPx(kk,7,Fire[k]);// DrawPx(ll,7-ii,Fire[j]); DrawPx(jj,7-kk,Fire[i]);
}//end DrawFire

void DrawBackground()
{
  if (!DrawBack) {return;}
  byte i,j,k;  
  j=random(2,8); k=random(2,8);
  //Ambulance
  DrawPx(4,4,CustomColor1);DrawPx(4,3,CustomColor1);DrawPx(4,2,CustomColor1);DrawPx(4,1,CustomColor1);
  DrawPx(5,4,CustomColor1);DrawPx(5,3,CustomColor1);DrawPx(5,2,CustomColor6);DrawPx(5,1,CustomColor1);
  DrawPx(6,4,CustomColor1);DrawPx(6,3,CustomColor6);DrawPx(6,2,CustomColor6);DrawPx(6,1,CustomColor6);
  DrawPx(7,4,CustomColor1);DrawPx(7,3,CustomColor1);DrawPx(7,2,CustomColor6);DrawPx(7,1,CustomColor1);
  //Building
  for (i=1;i<8;i++) {DrawPx(0,i,CustomColor1); DrawPx(1,i,CustomColor1);}
  //Grass
  for (i=0;i<8;i++) {DrawPx(i,0,Green);}
  DrawPx(j,0,DimGreen); DrawPx(k,0,Yellow);
}//end DrawBackground

void DrawFiremen()
{
  if (HandsUp){
    if (ManSpot>1) {
      DrawPx(ManX[ManSpot]-2,2,CustomColor5);
      DrawPx(ManX[ManSpot]-2,1,CustomColor8); DrawPx(ManX[ManSpot]-1,1,CustomColor8);
      DrawPx(ManX[ManSpot]-2,0,CustomColor3); DrawPx(ManX[ManSpot]-1,0,CustomColor4);
    }
    if (ManSpot<3) {
      DrawPx(ManX[ManSpot]+2,2,CustomColor5);
      DrawPx(ManX[ManSpot]+2,1,CustomColor8);
      DrawPx(ManX[ManSpot]+2,0,CustomColor3);
    }
      DrawPx(ManX[ManSpot],1,CustomColor4);
      DrawPx(ManX[ManSpot]+1,1,CustomColor8); DrawPx(ManX[ManSpot]+1,0,CustomColor4);
  }//end Hands Up
  else{//Hands Down
    if (ManSpot>1) {
      DrawPx(ManX[ManSpot]-2,2,CustomColor5);
      DrawPx(ManX[ManSpot]-2,1,CustomColor8); DrawPx(ManX[ManSpot]-1,1,CustomColor3);
      DrawPx(ManX[ManSpot]-2,0,CustomColor3); DrawPx(ManX[ManSpot]-1,0,CustomColor8);
    }
    if (ManSpot<3) {
      DrawPx(ManX[ManSpot]+2,2,CustomColor5);
      DrawPx(ManX[ManSpot]+2,1,CustomColor8);
      DrawPx(ManX[ManSpot]+2,0,CustomColor3);
    }
      DrawPx(ManX[ManSpot],0,CustomColor1);
      DrawPx(ManX[ManSpot]+1,0,CustomColor8); DrawPx(ManX[ManSpot]+1,1,CustomColor3);
  }//end Hands Down
}//end DrawFiremen

void DrawScore()
{
  byte i;
  DrawPx(5,7,CustomColor7);DrawPx(6,7,CustomColor7);DrawPx(7,7,CustomColor7);
  for (i=0;i<DeadBabies;i++){DrawPx((7-i),7,DimBlue);}
  SetAuxLEDs(Score);
}//End DrawScore

void DrawGame()
{
  ClearSlate();
  DrawBackground();
  DrawFire();
  DrawBabies();
  DrawFiremen();
  DrawScore();
  DisplaySlate();
}//end DrawGame

void SetBaby()
{
  byte i;
  BabyNum = 1;
  for (i=0;i<17;i++){
    Baby[i][0]=0;
    Baby[i][1]=0;
  }
}//End SetBaby

void CheckBabies()
{
  int i;
  byte j;
  BirthControl = 0;
  BabySplat = 0;
  HandsUp = 1;
  SkewRight = 0;
      
  for(i=BabyNum;i>0;i--){
    SkewRight += Baby[i][0];
    if (Baby[i][0] < 3) {BirthControl = 1;}// don't drop a baby if there is no chance to catch it    
    if ((Baby[i][0] < 26) && (Baby[i][0] > 14)) {BirthControl = 1;}    
    if ((Baby[i][0] < 44) && (Baby[i][0] > 36)) {BirthControl = 1;}    
    switch (Baby[i][0]) {
      //First Fall  
      case 12: Baby[i][1] = 1; break;
      case 13: if (ManSpot==1) {Baby[i][1] = 0; Tone_Start(10800,10);} break;
      case 14: if (ManSpot==1) {Baby[i][1] = 0; Tone_Start(10400,20);} break;
      case 15: if (ManSpot==1) {Baby[i][1] = 0; Tone_Start(10000,30); HandsUp = 0;} break;
      case 16: if (Baby[i][1] == 1) {BabySplat = 1; DoThis = 5; Baby[i][0]--;} break;
      //Second Fall  
      case 34: Baby[i][1] = 1; break;
      case 35: if (ManSpot==2) {Baby[i][1] = 0; Tone_Start(9800,10);} break;
      case 36: if (ManSpot==2) {Baby[i][1] = 0; Tone_Start(9400,20);} break;
      case 37: if (ManSpot==2) {Baby[i][1] = 0; Tone_Start(9000,30); HandsUp = 0;} break;
      case 38: if (Baby[i][1] == 1) {BabySplat = 2; DoThis = 5; Baby[i][0]--;} break;
      //Third Fall  
      case 52: Baby[i][1] = 1; break;
      case 53: if (ManSpot==3) {Baby[i][1] = 0; Tone_Start(8800,10);} break;
      case 54: if (ManSpot==3) {Baby[i][1] = 0; Tone_Start(8400,20);} break;
      case 55: if (ManSpot==3) {Baby[i][1] = 0; Tone_Start(8000,30); HandsUp = 0;} break;
      case 56: if (Baby[i][1] == 1) {BabySplat = 3; DoThis = 5; Baby[i][0]--;} break;
      case 57:
        Score++;
        for(j=1;j<=BabyNum;j++){
          Baby[j][0]=Baby[j+1][0];
          Baby[j][1]=Baby[j+1][1];
        }//end for
        BabyNum--;
        if (BabyNum < 1) {BabyNum = 1;}
        break;
      default:
        break;
    }//end switch
  }// end for
}// End CheckBabies

void LaborCheck()// make new babies
{
  byte NewBaby = 0;
  long Fertility, OneNightStand;
  
  OneNightStand = random(0,1000);
  Fertility = (1000 - SkewRight) - (Score * abs((10-BabyNum)));
  
  if (BabyNum==0) {NewBaby=1;}
  if (!BirthControl && (OneNightStand > Fertility)) {NewBaby=1;}
  if (NewBaby) {
    BabyNum++;
    Baby[BabyNum][0]=0;
    Baby[BabyNum][1]=0;
  }
}// end LaborCheck

void DeadBaby()//oops
{
  byte i;
  ClearSlate();
  DrawScore();
  DrawBackground();
  DrawFire();
  DrawFiremen();
  for (i=1;i<=BabyNum;i++){
    Baby[i][2]--;
    if (Baby[i][2]<1){
      if(Baby[i][1]>0){
        Baby[i][1]--;
      }
      else {
      }
      Baby[i][2] = Baby[i][1];
    }//end if
    DrawPx(Baby[i][0], Baby[i][1], CustomColor0);
  }//end for
  SplatShow++;
  DrawPx(ManX[BabySplat], 0, Dark);
  if (SplatShow > 4){DrawPx(ManX[BabySplat], 0, Violet); Tone_Start(12000+(SplatShow * 200),60); if (SplatShow > 10){SplatShow = 0;}}
  DisplaySlate();
}// End DeadBabies (here here!)

void DrawMenu()
{
  byte i,j,k,l;
  static byte MenuButton, HoldButton;
  static byte ThisSound;
  byte MenuSound[7] = {Dark, Dark, DimGreen, DimGreen, DimGreen, Green, FullOn};
  
  ClearSlate();
  if (TheseButtons != HoldButton){
    HoldButton = TheseButtons;
    MenuButton = TheseButtons;
  }
  if (ThisMenu>3) {ThisMenu = 0;}
  if (ThisMenu<0) {ThisMenu = 3;}
  for (i=0;i<8;i++){DrawPx(i,3,DimViolet); DrawPx(i,4,DimViolet); DrawPx(3,i,DimViolet); DrawPx(4,i,DimViolet);}
  switch(ThisMenu){
    case 0:// animate babies
      for (i=0;i<4;i++){DrawPx(i,4,Violet); DrawPx(3,i+4,Violet);}
      if ((MenuButton == 1) || (MenuButton == 2)) {SpinBaby = !SpinBaby;} 
      break;
    case 1:// fire
      for (i=0;i<4;i++){DrawPx(i+4,4,Violet); DrawPx(4,i+4,Violet);}
      if ((MenuButton == 1) || (MenuButton == 2)) {BurnBaby = !BurnBaby;} 
      break;
    case 2:// sound
      for (i=0;i<4;i++){DrawPx(i+4,3,Violet); DrawPx(4,i,Violet);}
      if ((MenuButton == 1) || (MenuButton == 2)) {Meg.SoundAllowed = !Meg.SoundAllowed;} 
      break;
    case 3:// background
      for (i=0;i<4;i++){DrawPx(i,3,Violet); DrawPx(3,i,Violet);}
      if ((MenuButton == 1) || (MenuButton == 2)) {DrawBack = !DrawBack;} 
      break;
  }//end switch ThisMenu
  DrawPx(1,6,CustomColor0);// menu animations
  if (SpinBaby) {DrawPx(1,7,DimBlue); DrawPx(2,6,CustomColor2);}
  if (BurnBaby) {
    ThisFire++; if (ThisFire==11) {ThisFire=0;}
    i=ThisFire; j=(i+1)%11; k=(i+2)%11; l=(i+3)%11;
    DrawPx(5,7,Fire[l]); DrawPx(6,7,Fire[l]);
    DrawPx(5,6,Fire[k]); DrawPx(6,6,Fire[k]); DrawPx(7,7,Fire[k]);
    DrawPx(5,5,Fire[j]); DrawPx(6,5,Fire[j]); DrawPx(7,6,Fire[j]);
    DrawPx(7,5,Fire[i]);
  }//end BurnBaby
  if (Meg.SoundAllowed) {
    ThisSound++; if (ThisSound>3) {ThisSound=0;}
    i=ThisSound; j=(i+1)%7; k=(i+2)%7; l=(i+3)%7;
    DrawPx(5,2,MenuSound[i]);
    DrawPx(6,2,MenuSound[j]); DrawPx(5,1,MenuSound[j]); DrawPx(6,1,MenuSound[j]);
    DrawPx(7,2,MenuSound[k]); DrawPx(7,1,MenuSound[k]); DrawPx(7,0,MenuSound[k]); DrawPx(5,0,MenuSound[k]); DrawPx(6,0,MenuSound[k]);
  }//end BurnBaby
  if (DrawBack) {DrawPx(0,0,Green); DrawPx(1,0,Green); DrawPx(2,0,Green); DrawPx(0,1,CustomColor1); DrawPx(1,1,CustomColor1); DrawPx(0,2,CustomColor1); DrawPx(1,2,CustomColor1);}
  MenuButton = 0;
  DisplaySlate();
}

void loop()  // Run main loop
{
  byte i,j,k;
  
  TimeNow = millis();
  if ((TimeNow - HoldTime)>WaitTime){
    ClockTick = 1;
    HoldTime = TimeNow;
  }// end of time
  
  TheseButtons = Meg.GetButtons(); 
  if (TheseButtons == OldButton) {NewButton=0;} else {NewButton=1;}
  switch (TheseButtons){
    case 0: //no buttons
      break;
    case 1: //B
      if (DoThis == 7){
        if (DeadBabies>2){
          DoThis = 0; Score=0;
        }
        else {DoThis = 2;}
      }
      PlayButton = NewButton * -1;
      break;
    case 2: //A
      PlayButton = NewButton * 1;   
      break;
    case 4: //Up
      TickCount = 0; WaitKey = 1; DoThis = 7;
      ThisMenu += NewButton;
      break;
    case 8: //Down
      TickCount = 0; WaitKey = 1; DoThis = 7;
      ThisMenu -= NewButton;
      break;
    case 16: //Left
      PlayButton = NewButton * -1;
      ThisMenu -= NewButton;
      break;
    case 32: //Right
      PlayButton = NewButton * 1;    
      ThisMenu += NewButton;
      break;
    default: //multiple buttons
      break;
  }// end switch thesebuttons
  
  switch (DoThis){
    case 0: //new game
      WaitTime = 75;
      WaitFire = 40;
      DeadBabies = 0;
      TickCount = 0;
      WaitKey = 1;
      SetBaby();
      DoThis = 1;
      break;
    case 1: // splash screen
      if (ClockTick){
        TickCount++; if (TickCount>10) {WaitKey = 0;}
        IntroScreen();
      }//end ClockTick
      if (NewButton && (WaitKey == 0)){
        Score=0;
        DoThis = 2;
        randomSeed(millis());
      }//
      break;
    case 2: //Standard loop
      if (PlayButton) { 
        ManSpot += PlayButton;
        if (ManSpot<1){ManSpot=1;}
        if (ManSpot>3){ManSpot=3;}
        DoThis = 3;
      }// end playbutton
      if (ClockTick){
        for (i=1;i<=BabyNum;i++){Baby[i][0]++;}
        DoThis = 3;
        ClockTick = 0;
      }//end clocktick
      if ((TimeNow-FireTime)>WaitFire){
        FireTime = TimeNow;
        DrawFire();
        DrawBabies();
        DisplaySlate();
      }//end firetime
      break;
    case 3: //update game
      DoThis = 2;
      CheckBabies();
      DrawGame();
      LaborCheck();
      break;
    case 5: //dropped baby
      DeadBabies++;
      DrawScore();
      for (i=1;i<=BabyNum;i++){
        j = Path[Baby[i][0]][0];
        k = Path[Baby[i][0]][1];
        Baby[i][0] = j;
        Baby[i][1] = k;
        Baby[i][2] = 5 + j + k;
      }//end for
      TickCount = 0;
      WaitKey = 1;
      DoThis = 6;
      break;
    case 6://funeral
      if (ClockTick) {
        ClockTick = 0;
        DeadBaby();
        TickCount++; if (TickCount>10) {WaitKey = 0;}
      }//end ClockTick
      if (NewButton && (WaitKey == 0)){
        if (DeadBabies>2) {DoThis = 0;} else {DoThis = 2;}
        SetBaby();
        BabySplat = 0;
      }//end NewButton
      break;
    case 7: //Menu Setup
      if (ClockTick) {
        ClockTick = 0;
        DrawMenu();
        TickCount++; if (TickCount>5) {WaitKey = 0;}
      }//end ClockTick
      break;
    default: //just because
      break;
  }//end switch DoThis
  OldButton = TheseButtons;
}  // End Main Loop
