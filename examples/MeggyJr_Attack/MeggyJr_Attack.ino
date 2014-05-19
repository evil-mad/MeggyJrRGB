/*
  MeggyJr_Attack  -- Attack of the Cherry Tomatoes for Meggy Jr RGB
 Version 2.0 - 11/2008      http://www.evilmadscientist.com/
 Copyright (c) 2008 Chris Brookfield.  All right reserved.
  
 
 This program is free software: you can redistribute it and/or modify
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






//MeggyJr_Attack8:: Default Meggy Jr Firmware 11/21/2008

/*

Attack of the Cherry Tomatoes
(The game that comes on the Meggy Jr RGB).  Move your fighter up and down and 
fire at the ever advancing army of cherry tomatoes.    Stop them--at all costs-- 
before they splat against your wall.     You have an infinite number of 
Blueberry Bullets ('A' button), and a limited number of bombs and laser shots.    
You start out the game with five bombs (Left arrow) and six laser shots ('B' button).
Lasers are super bullets that destroy everything in your line of fire.   
Bombs destroy all the Cherry Tomatoes presently on the screen.    If you use all
of your laser shots, you can take take the power cells out of a remaining bomb to 
power five more shots.   The  Cherry Tomatoes come at you in waves of 75, 
increasing in speed and density.  For each wave you survive you get an extra 
bomb (up to 8 max), and the number of bombs is always shown on the auxiliary 
LED display at the top of the screen.  If things get dull, you can boost yourself 
forward (right arrow). When things get tight, you can zoom up and down between 
shots by holding the up or down arrow buttons.

*/


#include <MeggyJr.h>      //Note: This file does not use the MJSL.


#define NumBadGuys 75

uint8_t CT[14][3] = 
     {{MeggyDark},  
      {MeggyRed},
      {MeggyOrange},
      {MeggyYellow},
      {MeggyGreen},
      {MeggyBlue},
      {MeggyViolet},
      {MeggyWhite},
      {0,0,1},     
      {0,1,0},      
      {1,0,0},
      {1,1,0},
      {0,3,1},
      {2,0,1}};       
     
enum colors {Dark, Red, Orange, Yellow, Green, Blue, Violet, White, 
         dimBlue, dimGreen, dimRed, dimYellow, dimAqua, dimViolet };

uint8_t redMatrix[9];
uint8_t grnMatrix[9];
uint8_t bluMatrix[9];

unsigned long lasttime;
unsigned long longTemp;

void delayShort(void)
{
  unsigned int delayvar;
  delayvar = 0; 
  while (delayvar <=  200U)		
  { 
    asm("nop");  
    delayvar++;
  } 
}



unsigned short getpoint(unsigned int xin, unsigned int yin)
{

  // for color input 0 = dark, 1 = red, 2 = green, 3 = orange, 4 = blue...   
  unsigned short color = 0;


  if (redMatrix[xin] & 128 >> yin)
  {// red
    color += 1;
  }

  if (grnMatrix[xin] & 128 >> yin)
  {// green
    color += 2;
  }

  if (grnMatrix[xin] & 128 >> yin)
  {// green
    color += 4;

  }
  return color;
}


void drawpoint(unsigned short xin, unsigned short yin, unsigned short color)
{

  // for color input 0 = dark, 1 = red, 2 = green, 3 = orange    

  if (color & 1)
  {// red
    redMatrix[xin] |= 128 >> yin;
  }

  if (color & 2)
  {// green
    grnMatrix[xin] |= 128 >> yin;
  }

  if (color & 4)
  {// blue
    bluMatrix[xin] |= 128 >> yin;
  }

}



void eraseall(void)
{
  unsigned short i=0;

  while (i < 9) {

    redMatrix[i] = 0;
    grnMatrix[i] = 0;
    bluMatrix[i] = 0;

    i++;

  }
}

void EraseAllButWalls(void)
{
  unsigned short i=0;

  while (i < 8) {

    redMatrix[i] = 129;
    grnMatrix[i] = 129;
    bluMatrix[i] = 129;

    i++;


  }
}

void walls(void)
{
  drawpoint(0,0,6);
  drawpoint(1,0,6);
  drawpoint(2,0,6);
  drawpoint(3,0,6);
  drawpoint(4,0,6);
  drawpoint(5,0,6);
  drawpoint(6,0,6);
  drawpoint(7,0,6);

  drawpoint(0,7,6);
  drawpoint(1,7,6);
  drawpoint(2,7,6);
  drawpoint(3,7,6);
  drawpoint(4,7,6);
  drawpoint(5,7,6);
  drawpoint(6,7,6);
  drawpoint(7,7,6);
}


void lose(void) // 'you lose' display
{
  uint8_t s;

  while (s < 8)
  {
    redMatrix[s] = 255;
    s++;
  } 
} 


void blubomb(void) // 'bomb' display
{
  bluMatrix[0] = 0;
  bluMatrix[1] = 0;
  bluMatrix[2] = 0;
  bluMatrix[3] = 24;
  bluMatrix[4] = 24;
  bluMatrix[5] = 0;
  bluMatrix[6] = 0;
  bluMatrix[7] = 0;
  walls();

  unsigned int blah;
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }

  bluMatrix[0] = 0;
  bluMatrix[1] = 0;
  bluMatrix[2] = 24;
  bluMatrix[3] = 36;
  bluMatrix[4] = 36;
  bluMatrix[5] = 24;
  bluMatrix[6] = 0;
  bluMatrix[7] = 0;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
  bluMatrix[0] = 0;
  bluMatrix[1] = 24;
  bluMatrix[2] = 36;
  bluMatrix[3] = 66;
  bluMatrix[4] = 66;
  bluMatrix[5] = 36;
  bluMatrix[6] = 24;
  bluMatrix[7] = 0;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
  bluMatrix[0] = 24;
  bluMatrix[1] = 36;
  bluMatrix[2] = 66;
  bluMatrix[3] = 129;
  bluMatrix[4] = 129;
  bluMatrix[5] = 66;
  bluMatrix[6] = 36;
  bluMatrix[7] = 24;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
  bluMatrix[0] = 36;
  bluMatrix[1] = 66;
  bluMatrix[2] = 129;
  bluMatrix[3] = 0;
  bluMatrix[4] = 0;
  bluMatrix[5] = 129;
  bluMatrix[6] = 66;
  bluMatrix[7] = 36;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
  bluMatrix[0] = 66;
  bluMatrix[1] = 129;
  bluMatrix[2] = 0;
  bluMatrix[3] = 0;
  bluMatrix[4] = 0;
  bluMatrix[5] = 0;
  bluMatrix[6] = 129;
  bluMatrix[7] = 66;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
  bluMatrix[0] = 129;
  bluMatrix[1] = 0;
  bluMatrix[2] = 0;
  bluMatrix[3] = 0;
  bluMatrix[4] = 0;
  bluMatrix[5] = 0;
  bluMatrix[6] = 0;
  bluMatrix[7] = 129;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
}

 
 
 
void grnbomb(void) // 'bomb' display
{
  grnMatrix[0] = 0;
  grnMatrix[1] = 0;
  grnMatrix[2] = 0;
  grnMatrix[3] = 24;
  grnMatrix[4] = 24;
  grnMatrix[5] = 0;
  grnMatrix[6] = 0;
  grnMatrix[7] = 0;
  walls();

  unsigned int blah;
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }


  grnMatrix[0] = 0;
  grnMatrix[1] = 0;
  grnMatrix[2] = 24;
  grnMatrix[3] = 36;
  grnMatrix[4] = 36;
  grnMatrix[5] = 24;
  grnMatrix[6] = 0;
  grnMatrix[7] = 0;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
  grnMatrix[0] = 0;
  grnMatrix[1] = 24;
  grnMatrix[2] = 36;
  grnMatrix[3] = 66;
  grnMatrix[4] = 66;
  grnMatrix[5] = 36;
  grnMatrix[6] = 24;
  grnMatrix[7] = 0;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
  grnMatrix[0] = 24;
  grnMatrix[1] = 36;
  grnMatrix[2] = 66;
  grnMatrix[3] = 129;
  grnMatrix[4] = 129;
  grnMatrix[5] = 66;
  grnMatrix[6] = 36;
  grnMatrix[7] = 24;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
  grnMatrix[0] = 36;
  grnMatrix[1] = 66;
  grnMatrix[2] = 129;
  grnMatrix[3] = 0;
  grnMatrix[4] = 0;
  grnMatrix[5] = 129;
  grnMatrix[6] = 66;
  grnMatrix[7] = 36;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
  grnMatrix[0] = 66;
  grnMatrix[1] = 129;
  grnMatrix[2] = 0;
  grnMatrix[3] = 0;
  grnMatrix[4] = 0;
  grnMatrix[5] = 0;
  grnMatrix[6] = 129;
  grnMatrix[7] = 66;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }
  grnMatrix[0] = 129;
  grnMatrix[1] = 0;
  grnMatrix[2] = 0;
  grnMatrix[3] = 0;
  grnMatrix[4] = 0;
  grnMatrix[5] = 0;
  grnMatrix[6] = 0;
  grnMatrix[7] = 129;
  walls();
  blah = 0;
  while (blah < 50)
  {
    display();
    blah++;
  }

}

struct badguystruct
{    
  unsigned short xpos;
  unsigned short ypos;
  short color;
};

unsigned int zoomup;
unsigned short zup;
unsigned int waitup; 

unsigned short zdown;

unsigned short xc;
unsigned short yc;
unsigned short ra;
unsigned short la;
unsigned short ua;
unsigned short da;
unsigned short pcolor;
unsigned short ca;

unsigned int waiter;
unsigned int waiter2;
unsigned int waiter3;

unsigned short gen;
unsigned int j, k;
uint8_t lasercount;
unsigned int buttons;
unsigned int loser;
int speed; 

 int length;
uint8_t stop;
unsigned int notechange;
unsigned short note;
unsigned short firenote;
unsigned int firenotechange;
unsigned short pause;
unsigned short pvar;
unsigned short lives;
unsigned int auxbuttons;
unsigned int level;
unsigned short r;
uint8_t bombcount;

unsigned int waitdown;
unsigned int zoom;
#define db  20   // bullet time delay
unsigned int rcount;
unsigned char sounds;
unsigned char advance; 

struct badguystruct bga[NumBadGuys];

void movertest(void)
{
  if ((PINC & 4) == 0) // nw, switch 1
  {
    buttons |= 1;// set bit 1
    if (zup < 2)
      zup = 1;
  }
  else
  {

    if (buttons & 1)
    {
      zup = 0;
      buttons |= 16;// set bit 5
    }
    buttons &= ~(1);// clear bit 1
  }

  if ((PINC & 8) == 0) // sw, switch 2
  { 
    buttons |= 2;// set bit 2
    if (zdown < 2)
      zdown = 1;
  }

  else
  {

    if (buttons & 2)
    {
      buttons |= 32;// set bit 6
      zdown = 0;
    }
    buttons &= ~(2);// clear bit 2
  }
   
   
  
  
}



#include <MeggyJr.h>

MeggyJr Meg;

void setup()                    // run once, when the sketch starts
{
  Meg = MeggyJr();    // Required initialization.
  
  
  
  // Show-off splash screen:  Not required, and no effect on game play.
  
uint8_t i, j, k, phase, row;
uint8_t rgb[3];

unsigned long ms = millis();
  
phase = 0;
k = 0;
row = 0;
while (k < 4)
{
  i = 0;
  while (i < 8)
  {
    j = 0;
    while (j < 8)
    {
			row = j;
			if (j == 0) row = 1;
      if (phase)
      {
        rgb[0] = 2*row;
				rgb[1] = 2*i;
		    rgb[2] = 0;
      }
      else
      {
				rgb[0] = 2*i;
        rgb[1] = 0;
        rgb[2] = row;
      }
	
      while (( millis() - ms) < 7) 
        Meg.SetPxClr(i,j,rgb);
      ms = millis() ;

      j++;
    }
    i++;
  }

	if (phase == 0)
	   phase = 1;
	else
	  phase = 0;
	  k++;
}
  
  // Get variables ready for game play::
   
  GameSetup();  
  loser = 0;
   
}  // End setup()




void GameSetup(void)
{

  eraseall();
 
  xc = 0;
  yc = 3;
  ra = 0;
  la = 0;
  ua = 0;
  da = 0;
  ca = 0;
  waiter = 0;

  waiter2 = 0;
  gen = 0;
  buttons = 0;
  waiter3 = 0;
 
  stop = 0;
  notechange = 0;
  note = 0;
  firenote = 0;
  firenotechange = 0;
  zup = 0;
  zdown = 0;
  waitup = 0;
  waitdown = 0;
  zoom = 0;
  zoomup = 0;
 // db = 30;
  rcount = 0;
  sounds = 1;
  pause = 1;
  pvar = 0;
  auxbuttons = 0;
  level = 0;
  r = 0;
  advance = 0; 


#define InitialBombs 5     // this is the number of bombs you start out with
#define InitialLasers 6    // this determines how many lasers you start out with


  bombcount = InitialBombs;

  lasercount = InitialLasers;
  
  lives = 3;// this determines how many lives you start out with

  pcolor = 2;// this determines the player's color. 1 = red, 2 = green, 3 = yellow
 
  speed = 1500;// this determines how fast the badguys move  (ms delay before they move!)

  length = 100;// this determines how dense the enemy waves are; lower = more dense and higer = less dense
 
 
  j = 0;
  while (j < NumBadGuys)// position badguys
  {
    bga[j].xpos = (rand() % length) + 7;
    bga[j].ypos = (rand() % 6) + 1;
    bga[j].color = 1;
    j++;
  }

  eraseall();

LevelUpNoise();

  j = 0;
  while (j < 1)
  {
    blubomb();
    grnbomb();
    grnbomb();
    j++;
  }
    
  
    Meg.AuxLEDs =   255 >> (8 - bombcount); 
 
  

 lasttime = millis(); // initialize millisecond counter.
 Meg.SoundState(1);    // Enable sound
}

void lasernoise(void)
{
  unsigned int freqs[12] = {4048,4291,4545,4813,
                            5102,5405,5730,6069,
                            6340,6814,7220,7648};
  uint8_t i = 0;                          
  unsigned long ms = millis();
  
  Meg.SoundState(1); 
  while (i < 12)
  {
  OCR1A = freqs[i];  // Sounds good with >> 2 as well!
  
  while (( millis() - ms) < 5)
        movertest();
        
    ms = millis();    
  i++;
  }
  Meg.SoundState(0); 
            
}


void bombNoise(void)
{
  unsigned int freqs[12] = {4048,4291,4545,4813,
                            5102,5405,5730,6069,
                            6340,6814,7220,7648};
  uint8_t i = 0;                          
  unsigned long ms = millis();
  
  Meg.SoundState(1); 
  while (i < 12)
  {
  OCR1A = freqs[i];
  
  while (( millis() - ms) < 20)
        movertest();
        
    ms = millis();    
  i++;
  }
  Meg.SoundState(0); 
            
}


void LevelUpNoise(void)
{
  unsigned int freqs[5] = {7648,0,5730, 0,4048};
  uint8_t i = 0;                          
  unsigned long ms = millis();
  
  Meg.SoundState(1); 
  while (i < 5)
  {
  
  if (freqs[i] > 0)
  {
     Meg.SoundState(1); 
        OCR1A = freqs[i];
  }
  else
      Meg.SoundState(0); 
  
  while (( millis() - ms) < 50)
        movertest();
        
    ms = millis();    
  i++;
  }
  Meg.SoundState(0); 
            
}


void advancenoise(void)
{ 
  
  uint8_t i = 0;                          
  unsigned long ms = millis();
  
  Meg.SoundState(1);  
  OCR1A = 7848; 
  
  while (( millis() - ms) < 10)
        movertest();
    
  Meg.SoundState(0); 
            
}



void AdvanceTomatoes(void)

{ 
     uint8_t j = 0;
      while (j < NumBadGuys)
      {
        bga[j].xpos--;
        if (bga[j].xpos < 0)
            bga[j].color = 0;
        j++;
      }
       
advancenoise();
      waiter3 ++;
}
      
      

 
void display (void) { 
  /* This display() routine converts from simple r,g,b buffers
   to fill the full-color Meggy data array, with some color correction. 
   
   It is certainly not necessary to build a program this way-- it just (1) demonstrates a
   simplified matrix to store the game data sorted by color and (2) was the easiest way to
   get an existing game working with the new MeggyJr Arduino library.  This sort of converter
   routine could be used to make other existing code for other hardware work on the Meggy Jr
   as well.
   
   See The Meggy Jr Simplified Library (MJSL) for easier ways to control the Meggy Jr. :)
   
   */

  uint8_t rm,gm,bm,j,i, mask; 
  uint8_t PixelPtr;
  uint8_t rgbColor[3];

  j = 0; 
  while (j < 8) 
  {
    
    rm = redMatrix[j];
    gm = grnMatrix[j];
    bm = bluMatrix[j];



// The upper and lower "walls" of the display are always either white or dark.

    if (redMatrix[0] > 0)
    { 
       Meg.SetPxClr(j, 7, CT[White]);    
       Meg.SetPxClr(j, 0, CT[White]);   
    }
    else
    {    
       Meg.SetPxClr(j, 7, CT[Dark]);   
       Meg.SetPxClr(j, 0, CT[Dark]);     
    }
    
    i = 6;
    while (i > 0)
    {
    
      mask = 1 << i; 
    
    // Write *directly* to Meggy Jr video buffer:
    
    PixelPtr =  24*j + i;
    Meg.MeggyFrame[PixelPtr] =  15*((bm & mask) != 0); 
    PixelPtr += 8;
    Meg.MeggyFrame[PixelPtr] =  15*((gm & mask) != 0);
    PixelPtr += 8;
    Meg.MeggyFrame[PixelPtr] =  15*((rm & mask) != 0);
    
    i--;
    }
     
    j++; 
  }  	 
} 
 
void loop()        // run over and over again
{

Meg.SoundState(0);
OCR1A = 0;
 
 
 

// Check for up/down buttons being held down for zoom up/zoom down.

#define ZoomWaitTime 250

  if (zup == 1)
  {
    waitup++;
    if (waitup == ZoomWaitTime)
    {
      zup = 2;
      waitup = 0;
    }
  }
  if (zup == 0)
  {
    zoomup = 0;
    waitup = 0;
  }

  if (zdown == 0)
  {
    waitdown = 0;
    zoom = 0;
  }


  if (zdown == 1)
  {
    waitdown++;
    if (waitdown == ZoomWaitTime)
    {
      zdown = 2;
      waitdown = 0;
    }
  }

 

  if (zup == 2) //zip up
  {
    zoomup++;
  }

  if (zdown == 2) // zip down
  {
    zoom ++;
  }    

  if (zoomup == 60)
  {
    if (yc > 1)
      yc--;
    else
      yc = 1;
    zoomup = 0;
  }


  if (zoom == 60)
  {
    zoom = 0;
    if (yc < 6)
      yc++;
    else
      yc = 6;
  }

  
  notechange ++;

  waiter++;
  waiter2++;
  rcount++;

  if (rcount == 50)
  { 
    EraseAllButWalls();
    drawpoint(xc,yc,pcolor);//draw player
    
    rcount = 0;

    j = 0;
    while (j < NumBadGuys)
    {
      if (bga[j].xpos < 8)
          drawpoint(bga[j].xpos,bga[j].ypos,bga[j].color);
      j++;
    }
  }

  drawpoint(xc,yc,pcolor);//draw player

    display();    








  // Check buttons!

  if ((PINC & 4) == 0) // nw, switch 1
  {
    buttons |= 1;// set bit 1
    if (zup < 2)
      zup = 1;
  }
  else
  {
    if (buttons & 1)
    {
      zup = 0;
      buttons |= 16;// set bit 5
    }
    buttons &= ~(1);// clear bit 1
  }


  if ((PINC & 8) == 0) // sw, switch 2
  { 
    buttons |= 2;// set bit 2
    if (zdown < 2)
      zdown = 1;
  }

  else
  {

    if (buttons & 2)
    {
      buttons |= 32;// set bit 6
      zdown = 0;
    }
    buttons &= ~(2);// clear bit 2
  }
 


  if ((PINC & 2) == 0) // se, switch 3
    buttons |= 4;// set bit 3
  else
  {

    if (buttons & 4)
      buttons |= 64;// set bit 7
    buttons &= ~(4);// clear bit 3
  }





  if ((PINC & 16) == 0) // ne, switch 4
    buttons |= 8;// set bit 4
  else
  {

    if (buttons & 8)
      buttons |= 128;// set bit 8
    buttons &= ~(8);// clear bit 4
  }

  if ((PINC & 1) == 0)
    auxbuttons |= 1;
  else
  {
    if (auxbuttons & 1)
    {
      if (lasercount > 0)      
      { 
  
          //SOUND:  LaserNoise!
          
          lasernoise();
  
                        firenote = 0; 
          
        j = 0;
        while (j < 8)
        { 
          r = getpoint(j,yc);
          if (r & 1)
          {
            bluMatrix[j] = 128 >> (yc);
            grnMatrix[j] = 128 >> (yc);
          }
          else
          {
            redMatrix[j] = 128 >> (yc);
            grnMatrix[j] = 128 >> (yc);
          }
          r = 0;
          j++;
        } 

        display();   

        j = 0;
        while (j < 40)
        {
          display();
          j++;
        }


        walls();

        lasercount --;    



        j = 0;
        while (j < NumBadGuys)
        {


          if (bga[j].color == 1)
          {
            if (bga[j].ypos == yc)
            {
              if (bga[j].xpos < 8)
              {
                bga[j].color = 0;

              }
            }
          }

          j++;
        }
      }    // End if lasercount > 0.
      else if ( bombcount > 0)      // Borrow bombs to make lasers.  :)
        {
          bombcount--;
          lasercount = InitialLasers - 1;

          Meg.AuxLEDs = 255 >> (8 - bombcount); 
 
   
            
              //Clear the badguys from the screen, then show the bomb animation.

               lasernoise();
 
        
              firenote = 0; 
               
            j = 0;
            while (j < 8)
            { 
              r = getpoint(j,yc);
              if (r & 1)
                bluMatrix[j] = 128 >> (yc);
              else
              {
                redMatrix[j] = 128 >> (yc);
                grnMatrix[j] = 128 >> (yc);
              }
              r = 0;
              j++;
            } 

            display();   

            j = 0;
            while (j < 40)
            {
              display();
              j++;
            }


            walls();

            lasercount --;    

            j = 0;
            while (j < NumBadGuys)
            {


              if (bga[j].color == 1)
              {
                if (bga[j].ypos == yc)
                {
                  if (bga[j].xpos < 8)
                  {
                    bga[j].color = 0;   // Bad Guy Has Died!
                    
                	

                  }
                }
              }

              j++;
            }
          }
        }

      auxbuttons = 0;

    }




  if ((PINC & 32) == 0)
  {
  //  auxbuttons |= 2;
    advance = 1;
  }
  else if (advance)
    {
 
      AdvanceTomatoes();
        
 
       advance = 0;  
      auxbuttons = 0;

    } 

  // END TEST BUTTONS    


  if (waiter == 10)  // Was 25        
  { 

    EraseAllButWalls();
    drawpoint(xc,yc,pcolor);

    j = 0;
    while (j < NumBadGuys)
    {
      if (bga[j].xpos < 8)
        drawpoint(bga[j].xpos,bga[j].ypos,bga[j].color);
      j++;
    }

    display();


    if (pvar & 2)
    {
      if (pause = 1)
        pause = 0;
      if (pause = 0)
        pause = 1;
      pvar & ~ (2);
    }


    if (buttons & 16) // up
    {
      if (yc > 1)
        yc--;
      else
        yc = 1;
      buttons &= ~(16);
    }
 
    if (buttons & 32) // down
    {
      if (yc < 6)
        yc++;
      else
        yc = 6;
      buttons &= ~(32);
    }

    if (buttons & 64) // fire main bullets!
    {

      buttons &= ~(64);
   
          firenote = 0;  

          while (firenote < 10)   //          while (firenote < 14)
          {

            firenotechange++;

            if (firenotechange == 10) 
            {

             movertest();
 
              firenote++;
              firenotechange = 0;
            }
            
            Meg.SoundState(1); 
            OCR1A = (2048 + 256*firenote) ; 
            display();  
          }
          
          firenote = 0;
          Meg.SoundState(0);   

 
 
movertest(); 

while (k < 9)
{
if (stop == 0)    
      {
        j = 0;
        while (j < db)
        {
          movertest();
          display();
          j++;
        }

        bluMatrix[k] = 128 >> (yc);
        bluMatrix[k - 1] = 0;
        walls();


        j = 0;
        while (j < NumBadGuys)
        {


          if (bga[j].color ==1)
          {
            if (bga[j].ypos == yc)
            {
              if (bga[j].xpos == k)
              {
                bga[j].color = 0;
               display();
               bluMatrix[k] = 0;               
               grnMatrix[k] = 128 >> (yc);
               redMatrix[k] = 128 >> (yc); 
                stop++;
              }
            }
          }
          j++;
        }
      }
  
k++;  
}
k = 1;
      stop = 0;
      drawpoint(xc,yc,pcolor);//draw player
      j = 0;
      while (j < NumBadGuys)
      {
        if (bga[j].xpos < 8)
          drawpoint(bga[j].xpos,bga[j].ypos,bga[j].color);
        j++;
      }
      display();

    }

/*

*/


    if (buttons & 128)   // Bomb
    {
      
      if (bombcount > 0)
      {
        
        bombcount--;
        Meg.AuxLEDs = 255 >> (8 - bombcount);      
        
        
        j = 0;
        while (j < NumBadGuys)
        {
          if (bga[j].xpos < 8)
              bga[j].color = 0;
          j++;
        }
  

          
           //Meg.SoundState(1);
          //Clear the badguys from the screen, then show the bomb animation.



   bombNoise();

        grnbomb();
        grnbomb();
        grnbomb();
        EraseAllButWalls();
      }

      buttons &= ~(128);

    }



    //See if you lose:
    j = 0;
    while (j < NumBadGuys)
    {




      if (bga[j].xpos < 8)
        drawpoint(bga[j].xpos,bga[j].ypos,bga[j].color);


      j++;

      if (bga[j].xpos == xc)
      {

        if (bga[j].color == 1)
        {
          OCR1A = 0;    
      //     Meg.SoundState(0);
          
          
         Meg.SoundState(1);        
          while (loser < 600)
          {
            lose();
            display();
             
            OCR1A = rand();      // Noise!!!
            
            loser++;
          }
          loser = 0;
            Meg.SoundState(0);
          while (loser < 800)
          {
            eraseall();
            display();
            OCR1A = 0;

            loser++;
          }
          loser = 0;

        Meg.SoundState(1);
          while (loser < 1000)
          {
            lose();
            display();

            OCR1A = rand();
               
            loser++;
          }
          loser = 0;
         Meg.SoundState(0);
          while (loser < 1200)
          {
            eraseall();
            display();
            
OCR1A = 0;
               
            loser++;
          }
          
          Meg.SoundState(1);
          loser = 0;
          while (loser < 2500)
          {
            lose();
            display();

            OCR1A = rand();
               
            loser++;
          }
          loser = 0;

          while (loser < 1000)
          {
            Meg.AuxLEDs = 0;
            eraseall();
            display();
            OCR1A = 0;
            loser++;
          }

          loser = 0;
          OCR1A = 0;
           Meg.SoundState(0);
          
          loser = 0;

          j = 0;
          waiter = 0;

          while (loser < 1)
          { 

            if ((PINC & 2) == 0) // switch 3
              buttons |= 4;// set bit 3
            else
            {
              
              
              // Game over:  Scanning LED display to remind you that
              // the power is still on... save drained batteries!
              
              if (j++ > 5000)
              {
                waiter++;
                j = 0;
              }
              if (waiter > 13)
                waiter = 0;
                
               if (waiter > 7)
                  Meg.AuxLEDs = (1 << (14 - waiter));   
               else   
                  Meg.AuxLEDs = (1 << waiter);
 
              if (buttons & 4)
                buttons |= 64;// set bit 7
              buttons &= ~(4);// clear bit 3
            }    

            if (buttons & 64) // fire button triggers restart
            {
              loser++;
              GameSetup();
              //waiter3 = 0;
               
    
            }    
          }
        }    
      }
    }     
    waiter = 0;

  }



 longTemp = millis();

  if (longTemp >= (lasttime + speed))    // move badguys 
  {
    
    lasttime = longTemp;
    
    walls();
    drawpoint(xc,yc,pcolor);//draw player
    display();
 

AdvanceTomatoes();
 
    waiter2 = 0;
 
  }

  if (waiter3 == length + 7)   //next level
  {
    waiter3 = 0;
    speed -= (speed >> 2);
    length -= 5; 
   
  if (++bombcount > 8)
        bombcount = 8;  
  
   Meg.AuxLEDs = 255 >> (8 - bombcount); 
   
    level += 1;


    if (length < 30) 
        length = 30;     // Approx 1 in 3 dots is a bad guy at this limit.
  
    if (speed < 40)
        speed = 40;    // Limit advancement to 25 ticks per second! 
 
    loser = 0;
    
    
   LevelUpNoise();
    while (loser < 3)
    {
      blubomb();
      blubomb();
      blubomb();
      display();

      loser++;
    }
 
   


    j = 0;
    while (j < NumBadGuys)
    {

      bga[j].xpos = (rand() % length) + 7;
      bga[j].ypos = (rand() % 6) + 1;
      bga[j].color = 1;

      j++;
    }
  }


}
