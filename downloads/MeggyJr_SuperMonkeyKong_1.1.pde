/*

 MeggyJr_SuperMonkeyKong
 Super Monkey Kong: a game for Meggy Jr RGB
 Version 1.0 - 1/21/2009
 Copyright (c) 2009 Steve Or Steven Read.  All rights reserved.
 
 Steve Or Steven Read
 ssread@gmail.com
 http://www.stevenread.com
 http://www.miniarcade.com

 The world's first LED "Donkey Kong" game! All thanks to Evil Mad Scientist(s) and
 the Meggy Jr RGB LED handheld. The game is fairly straightforward if you've played
 Donkey Kong before. First climb up 5 screens to where Super Monkey Kong has your
 lady (or man, or whatever you're into). Then get directly under Kong and jump + press UP
 and you will score a hit on him. 5 such hits and the ladder will take you to your
 special lady friend. But Kong will snatch her up and you must brave 5 more screens
 to whip his booty again. Then you will finally defeat him and win back the love of your life.
 Then of course he somehow steals her away again and you must climb the skyscraper once more
 to save her. The game gets faster as you progress.

 1.1 Version Changes:
 Overall I made the game a little easier to play. Changed the rhythm of barrel generation
 and jumping. Increased the 'hammer time'. On the Kong screen the barrels will no longer
 fall down the final ladder, making it a bit more fair. Made some small tweaks to
 sounds and animations. Lastly I added a text scroller for the title and end of game.
 
 TODO:
 The code now also contains scoring, but haven't found a way yet to display the
 score to the player. (ran out of memory space)
 

 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this library.  If not, see http://www.gnu.org/licenses
 	 
*/


#include <MeggyJrSimple.h>
#include <math.h>
#include <avr/pgmspace.h> 

// stuff
#define INCREMENTS 40
#define BARRELMAX 18
#define DEBUGGING 0
#define ToneAs2		65535 // not really as2 but close (lowest value possible)


// FONT AND STRING DEFINITIONS  
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

//const char String0[] PROGMEM = "SCORE -- ";
const char String0[] PROGMEM = "GAME OVER  ;";
const char String1[] PROGMEM = "SUPER MONKEY KONG  ;";
PGM_P StringSet[] PROGMEM = {String0, String1};
char buf[22];
//char bufScore[7];
	
//char bufTitleMsg[20] = 
//{'S','U','P','E','R',' ','M','O','N','K','E','Y',' ','K','O','N','G',';','\0'};
//char bufPreScore[10] = 
//{'S','C','O','R','E',' ','-','-',' ','\0'};

byte TextScroll(byte msgType, byte color, byte textDelay_ms, byte AllowBreak)
{
	ClearSlate();
	DisplaySlate();
	
	PGM_P p;
	byte StringPosition = 0;  
	char StringChar, FontChar;
	byte CharWidth, SubCharPos, SubCharWord, x, escape;
	unsigned long LastTime = millis();
	memcpy_P(&p, &StringSet[msgType], sizeof(PGM_P));
	strcpy_P(buf, p);	
	escape = 0;
	
	//char bufScoreMsg[22];
  //bufScoreMsg[0] = '\0'; // for concat
	
/*
	if (msgType == 0)
	{
		// show score
		//sprintf(bufScore, "%i", inScore);
		itoa(inScore, bufScore, 10);
		//strcat(bufScoreMsg, bufPreScore);
		strcat(buf, bufScore);
		strcat(buf, ";");
	}	
*/
	
	while(buf[StringPosition] != ';')	
  { 
    StringChar = buf[StringPosition];
 
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
				DrawPx(7,0,color); 
			else
				DrawPx(7,0,Dark);  

			if (SubCharWord & 2)
				DrawPx(7,1,color); 
			else
				DrawPx(7,1,Dark);  

			if (SubCharWord & 4)
				DrawPx(7,2,color); 
			else
				DrawPx(7,2,Dark);  

			if (SubCharWord & 8)
				DrawPx(7,3,color); 
			else
				DrawPx(7,3,Dark);  

			if (SubCharWord & 16)
				DrawPx(7,4,color); 
			else
				DrawPx(7,4,Dark);  

			if (SubCharWord & 32)
				DrawPx(7,5,color); 
			else
				DrawPx(7,5,Dark);  

			if (SubCharWord & 64)
				DrawPx(7,6,color); 
			else
				DrawPx(7,6,Dark);  

			if (SubCharWord & 128)
				DrawPx(7,7,color); 
			else
				DrawPx(7,7,Dark);  
	 
			DisplaySlate();
				
			while (( millis() - LastTime) < textDelay_ms)
			{  
				 if (AllowBreak)
				 {
					CheckButtonsPress();
					if (Button_A || Button_B)
						 escape = 1;
				 }
			} 
			if ((escape) && (textDelay_ms > 2))
				//textDelay_ms >>= 1;
				break;
					
			LastTime = millis();
			SubCharPos++;
		} 
		StringPosition++;	
  } 
  
  return escape;
  
  //return 1;
}

void splashscreen(void){

	// title screen
	while (TextScroll(1, Red, 100, 1) == 0) {}

/*
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
		
        while ((millis() - ms) < 7 */ /*(phase == 1 ? 200 : 7) )
          Meg.SetPxClr(i,j,rgb);
        ms = millis();

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
*/	
}


byte lives;
byte restart;
byte die; 
byte getBad;
byte i, k;
byte jumpMoved; // has moved during jump flag
byte jumpScored; // has scored during jump flag
byte xpos;
byte ypos;
byte startX; // xpos player screen start
byte pause;
byte jumping;
byte speed;
byte clrGirder;
byte clrLadder;
byte clrHeart, clrHeartIn;
byte rndHeart1, rndHeart2, rndHeart3;
byte clrKong;
byte clrGirl;
byte girder1, girder2;
byte ladder1, ladder2, ladder3;
byte hammerX, hammerY;
byte hammerUsed;
byte hammer;
byte hammerSoundLast;
byte moveSoundLast;
byte barrel1SoundHold;
byte screenNbr;  // 1-based, how high can you climb?
byte screenScroll; // screen transition frame flag/counter
byte screenScrollWait; // screen transition counter
byte playing;
byte animating1, animating2;
byte animating2Switch;
byte animating2Sound;
byte legs;
byte armLeft;
byte armRight;
byte kongColor;
byte kongBeat;
byte kongBeatProb;
byte kongLevel;
byte screenNbrCount;
byte kongHitCount;
byte barrelBlink;
byte barrelSoundPlayed;
byte playIntro;
byte playDieSound;
byte barrelStartWait;
byte barrelYesCount;
byte barrelNoCount;
unsigned long lasttime;
unsigned int score;
unsigned int timerSpeed;
unsigned int timerStatic;
unsigned int timerEval;
unsigned int jumpWait;
unsigned int barrelSpeed;
unsigned int barrelGenWait;
unsigned int barrelGenSpeed;
unsigned int barrelGenProb;
unsigned int barrelBlinkWait;
unsigned int legsWait;
unsigned int armLeftWait;
unsigned int armRightWait;
unsigned int kongColorWait;
unsigned int kongBeatWait;
unsigned int animating2Wait;
unsigned int animating2SoundWait;
unsigned int hammerWait;

byte frqScroll[8] = 
{
	55,49,42,35,28,21,14,7 // played backwards
  //ToneF7,ToneB6,ToneE6,ToneA5,ToneD5,ToneG4,ToneC4,ToneF3
};

unsigned int allFreqs[78] = 
{
	ToneAs2,ToneB2, // 1 = index
	ToneC3,ToneCs3,ToneD3,ToneDs3,ToneE3,ToneF3, 	// 7
	ToneFs3,ToneG3,ToneGs3,ToneA3,ToneAs3,ToneB3, // 13
	ToneC4,ToneCs4,ToneD4,ToneDs4,ToneE4,ToneF4, 	// 19
	ToneFs4,ToneG4,ToneGs4,ToneA4,ToneAs4,ToneB4, // 25
	ToneC5,ToneCs5,ToneD5,ToneDs5,ToneE5,ToneF5,	// 31
	ToneFs5,ToneG5,ToneGs5,ToneA5,ToneAs5,ToneB5, // 37
	ToneC6,ToneCs6,ToneD6,ToneDs6,ToneE6,ToneF6, 	// 43
	ToneFs6,ToneG6,ToneGs6,ToneA6,ToneAs6,ToneB6, // 49
	ToneC7,ToneCs7,ToneD7,ToneDs7,ToneE7,ToneF7,	// 55
	ToneFs7,ToneG7,ToneGs7,ToneA7,ToneAs7,ToneB7, // 61
	ToneC8,ToneCs8,ToneD8,ToneDs8,ToneE8,ToneF8,	// 67
	ToneFs8,ToneG8,ToneGs8,ToneA8,ToneAs8,ToneB8, // 73
	ToneC9,ToneCs9,ToneD9,ToneDs9 // 77
};

/*
unsigned int introFreqs[30] = 
{
  ToneB2,ToneDs3,ToneG3,ToneC4,ToneDs4,ToneG4,
  ToneC5,ToneDs5,ToneG5,ToneC6,ToneDs6,ToneG6,
  ToneC7,ToneDs7,ToneG7,ToneC8,ToneG7,ToneDs7,
  ToneC7,ToneG6,ToneDs6,ToneC6,ToneG5,ToneDs5,
  ToneC5,ToneG4,ToneDs4,ToneC4,ToneG3,ToneDs3,
};
*/
byte introFreqs[30] =
{
	1,5,9,14,17,21,
	26,29,33,38,41,45,
	50,53,57,62,57,53,
	50,45,41,38,33,29,
	26,21,17,14,9,5
};

unsigned int jumpFreqs[5] = 
{
	ToneA4,ToneA5,ToneC7,ToneC6,ToneA5
};

unsigned int dieFreqs[32] = 
{
	ToneB6,ToneA7,ToneAs6,ToneGs7,ToneA6,ToneG7,ToneGs6,ToneFs7,
	ToneG6,ToneF7,ToneFs6,ToneE7,ToneF6,ToneDs7,ToneE6,ToneD7,
	ToneDs6,ToneCs7,ToneD6,ToneC7,ToneCs6,ToneB6,ToneC6,ToneAs6,
	ToneB5,ToneA6,ToneAs5,ToneGs6,ToneA5,ToneG6,ToneGs5,ToneFs6
};

struct objBarrel
{    
  byte x;
  byte y;
	byte falling;
	unsigned int timer;
	unsigned int wait;
	byte active;
	byte color;
	byte type;
};
struct objBarrel barrels[BARRELMAX];

void NewBarrel(byte type)
{
	for (i = 0; i < BARRELMAX; i++)
	{
		if (barrels[i].active == 0)
		{
			ResetBarrel(i);

			// defaults
		  barrels[i].wait = 0;  
		  barrels[i].falling = 0;
		  barrels[i].y = 6;
		  barrels[i].timer = barrelSpeed;
			barrels[i].type = 0;
		
			// manage screen-based starting coordinates
			if (screenNbr % 2 == 0)
			{
				barrels[i].x = 0;
			}
			else if (screenNbr == screenNbrCount)
			{
				barrels[i].x = 2;
			}
			else
			{
				barrels[i].x = 7;
			}
		
			// manage type
			if (type == 1)
			{
				barrels[i].type = type;
				barrels[i].timer = 500;
		  	barrels[i].falling = 1;
		  	// manage type 1 coordinate
		  	if (screenNbr < screenNbrCount)
		  	{
					barrels[i].x = (rand()/(RAND_MAX/6+1))+1;
		  		barrels[i].y = 7;
		  	}
		  	else
		  	{
					barrels[i].x = 4;
				  barrels[i].y = 5;
		  	}
		  }
			else if (type == 2)
			{
				// starting 2nd barrel
				barrels[i].type = 0; // type was hacked just for this fxn
	
				barrels[i].x = (rand()/(RAND_MAX/5+1))+((screenNbr%2!=0)?0:3);
				if ((rand()/(RAND_MAX/3+1)) == 0)
				{
					// don't let barrel1 start too close to far edge
					barrels[i].y = 3;
				}
				else
				{
					// don't let barrel1 start too close to barrel0
					barrels[i].y = 6;
				}
			}
			else
			{
			  barrels[i].timer = barrelSpeed;
			}
			
		  barrels[i].wait = 0;
			barrels[i].color = Red;		
			barrels[i].active = 1;
			
			break;
		}
	}
}

void ResetBarrel(byte idx)
{  
  barrels[idx].wait = 0;
  barrels[idx].falling = 0;
	barrels[idx].x = 0;
  barrels[idx].y = 0;
	barrels[idx].type = 0;
  barrels[idx].timer = barrelSpeed;
  barrels[idx].active = 0;
	barrels[idx].color = Red;
}

void ClearBarrels(byte start2)
{
	byte i;
	barrelStartWait = 0;
	barrelYesCount = 0;
	barrelNoCount = 0;
	
	for (i = 0; i < BARRELMAX; i++)
	{
		ResetBarrel(i);
	}
	// start one right off
	NewBarrel(0);

	// start 2nd barrel
	if (screenNbr > 1 && screenNbr < screenNbrCount && start2 == 1)
	{
		NewBarrel(2);
	}
}

void sndKong(void)
{
  Tone_Start(ToneDs4, 100);
}

void sndKongHit(void)
{
	byte i = 0;  
  unsigned int freqs[10] = 
	{
    ToneD3,ToneF3,ToneC6,ToneA7,ToneB5,ToneG4,ToneE3,ToneD3
	};

  while (i < 10)
  {
    Tone_Start(freqs[i], 40); while (MakingSound) {}
    i++;
  }
}

void sndKongFall(byte idx)
{
	if (animating2 == 0 || idx > 77) return;
	if (idx == 0)
	{
    Tone_Start(allFreqs[0], 25); while (MakingSound) {}
    Tone_Start(allFreqs[13], 25); while (MakingSound) {}
    Tone_Start(allFreqs[4], 33); while (MakingSound) {}
    Tone_Start(allFreqs[6], 50); while (MakingSound) {}
    Tone_Start(allFreqs[20], 20); while (MakingSound) {}
    Tone_Start(allFreqs[9], 66); while (MakingSound) {}
    Tone_Start(allFreqs[59], 15); while (MakingSound) {}
    Tone_Start(allFreqs[22], 20); while (MakingSound) {}
    Tone_Start(allFreqs[70], 20); while (MakingSound) {}
    Tone_Start(allFreqs[2], 75); while (MakingSound) {}
    Tone_Start(allFreqs[5], 75); while (MakingSound) {}
    Tone_Start(allFreqs[0], 75); while (MakingSound) {}
}
	else
	{
	  Tone_Start(allFreqs[77-idx], 15); while (MakingSound) {}
	}
}

void sndBarrel1(void)
{
	if (screenNbr == screenNbrCount || hammer > 0) return;
  if (barrel1SoundHold > 150)
	{
		Tone_Start(ToneC6, 5);
  	barrel1SoundHold = 0;
	}
	else
	{
 		barrel1SoundHold++;
 	}
}

void sndHammer(void)
{
	// hacking barrel sound timing/blinking for hammer
	if (hammer == 0) return;
	
  if (barrel1SoundHold > 50)
	{
		if (hammerSoundLast == 0)
		{
			Tone_Start(ToneF4, 10); while (MakingSound) {}
			Tone_Start(ToneF7, 10); while (MakingSound) {}
	  	hammerSoundLast++;
	  }
	  else
		{
			Tone_Start(ToneF7, 10); while (MakingSound) {}
			Tone_Start(ToneF4, 10); while (MakingSound) {}
	  	hammerSoundLast = 0;
		}

  	barrel1SoundHold = 0;
	}
	else
	{
 		barrel1SoundHold++;
 	}
}

void sndScroll(byte idx)
{
  Tone_Start(allFreqs[frqScroll[idx]], 30);
}

void sndMove()
{
	if (moveSoundLast == 0)
	{
 		Tone_Start(ToneF3, 25);
  	moveSoundLast++;
  }
  else
	{
 		Tone_Start(ToneF4, 25);
  	moveSoundLast = 0;
	}
}

void sndGirl(void)
{
// 	Tone_Start(ToneCs9, 666); while (MakingSound) {}
// 	Tone_Start(0, 333); while (MakingSound) {}
}

void sndLeg(void)
{
 	Tone_Start(ToneAs2, 133);
}

void sndWin(byte count)
{
 	Tone_Start(ToneC5, 100); while (MakingSound) {}
    
 	Tone_Start(ToneD5, 100); while (MakingSound) {}
  
 	Tone_Start(ToneE5, 200); while (MakingSound) {}
  
  Tone_Start(0, 10); while (MakingSound) {}
  
 	Tone_Start(ToneC5, 200); while (MakingSound) {}
 	
 	if (count > 0)
 	{
	  Tone_Start(0, 200); while (MakingSound) {}
	  
	 	Tone_Start(ToneC5, 100); while (MakingSound) {}
	  
	 	Tone_Start(ToneD5, 100); while (MakingSound) {}
	  
	 	Tone_Start(ToneE5, 200); while (MakingSound) {}
	  
	  Tone_Start(0, 10); while (MakingSound) {}
	  
	 	Tone_Start(ToneC5, 200); while (MakingSound) {}
	  
	  Tone_Start(0, 500); while (MakingSound) {}
 	}
 	else
 	{
	  Tone_Start(0, 1500); while (MakingSound) {}
		//sndGirl();
		//sndGirl();		
 	}
}

void sndLadder(void)
{
	sndMove();
}

void sndJump(void)
{
 	byte i = 0;
  while (i < 5)
  {
    Tone_Start(jumpFreqs[i], 20); while (MakingSound) {}
    //Tone_Start(0, 5);  while (MakingSound) {}
    i++;
  }
}

void sndIntro(void)
{
	playIntro = 0;
	if (DEBUGGING == 1) return;

	byte i = 0;

  Tone_Start(ToneC3, 1000); while (MakingSound) {}

  Tone_Start(0, 20); while (MakingSound) {}

  Tone_Start(ToneCs3, 350); while (MakingSound) {}

  Tone_Start(0, 20); while (MakingSound) {}

  Tone_Start(ToneD3, 700); while (MakingSound) {}

  Tone_Start(0, 20); while (MakingSound) {}

  Tone_Start(ToneC3, 700); while (MakingSound) {}

  Tone_Start(0, 50); while (MakingSound) {}

  while (i < 30)
  {
    Tone_Start(allFreqs[introFreqs[i]], 50); while (MakingSound) {}
    i++;
  }

  Tone_Start(0, 15); while (MakingSound) {} 

  Tone_Start(ToneB2, 50); while (MakingSound) {} 
  Tone_Start(ToneC4, 350);  while (MakingSound) {}

  Tone_Start(0, 350); while (MakingSound) {}
}

void sndDie(void)
{
 	byte i = 0;
 	playDieSound = 0;

  while (i < 32)
  {
  	if (i%2 == 0)
  	{
	    Tone_Start(dieFreqs[i], 40); while (MakingSound) {}
		  Tone_Start(0, 5); while (MakingSound) {}
	    DrawPx(xpos ,ypos, Blue);
	    DisplaySlate();
  	}
  	else
  	{
	    Tone_Start(dieFreqs[i], 60); while (MakingSound) {}
		  Tone_Start(0, 10); while (MakingSound) {}
	    DrawPx(xpos ,ypos, Red);
	    DisplaySlate();
  	}
  	
    i++;
  }

  Tone_Start(0, 10); while (MakingSound) {}

  Tone_Start(ToneA4, 150); while (MakingSound) {}
  Tone_Start(0, 5); while (MakingSound) {}
  DrawPx(xpos ,ypos, Blue);
  DisplaySlate();

  Tone_Start(ToneE5, 350); while (MakingSound) {}
  Tone_Start(0, 30); while (MakingSound) {}
  DrawPx(xpos ,ypos, Red);
  DisplaySlate();

  Tone_Start(ToneA3, 350); while (MakingSound) {}
  Tone_Start(0, 30); while (MakingSound) {}
  DrawPx(xpos ,ypos, Blue);
  DisplaySlate();
  
  Tone_Start(ToneA4, 666); while (MakingSound) {}
  Tone_Start(0, 10); while (MakingSound) {}
  DrawPx(xpos ,ypos, Red);
  DisplaySlate();

  Tone_Start(0, 100); while (MakingSound) {}
}

void DieScreen(void)
{
  unsigned long TempTime;

/*
  byte i = 0;

  while (i < 7)
  {
    TempTime = millis();
    //ClearSlate();
    DrawPx(xpos ,ypos, Red);
    DisplaySlate();
    while (millis() - TempTime < 133) { }

    TempTime = millis();
    //ClearSlate();
    DrawPx(xpos,ypos,Blue);
    DisplaySlate();
    while (millis() - TempTime < 133) { }

    i++;
  }
*/

	if (playDieSound > 0)
	{
		sndDie();
		if (lives == 0)
		{
			while (TextScroll(0, Red, 100, 1) == 0) {}
		}
	}

  ClearSlate(); 
  DisplaySlate();
  TempTime = millis();
  while (millis() - TempTime < 1000) { }


}

void ProcessJump(void)
{
	// process jump
	if (jumping == 0 && (ypos == 6 || 
			ypos == 3|| ypos == 0))
	{
		ypos++;
		jumping = 1;
		sndJump();
	}
}

void ScreenTrans(void)
{
	if (screenScroll > 0 || playing == 0) return;

	// start screen transition
	SwitchScreen(0);
	playing = 0;
	screenScroll = 8;
	screenScrollWait = 0;
}

void StartGame(void)
{
	// init vars
	restart = 0;
	k = 0;
	score = 0;
  jumping = 0; 
  jumpWait = 0;
  jumpMoved = 0;
	jumpScored = 0;
  legs = 0;
  armLeft = 0;
  armRight = 0;
  legsWait = 0;
  armLeftWait = 0;
  armRightWait = 0;
  hammer = 0;
  hammerUsed = 0;
  hammerWait = 0;
  kongBeat = 0;
  kongBeatProb = 7;
  kongColor = 0;
  kongColorWait = 0;
  kongHitCount = 0;
  //if (DEBUGGING == 0)
  	kongLevel = 0;
  //else
  //	kongLevel = 1;
  	
  xpos = 0;
  ypos = 0;
  lasttime = millis();
  getBad = Dark;
  die = 0;
  pause = 0;
  speed = 0;
  girder1 = 2;
  girder2 = 5;
	ladder1 = 6;
	ladder2 = 1;
	ladder3 = 5;
  moveSoundLast = 0;
  hammerSoundLast = 0;
	barrel1SoundHold = 0;
	barrelSpeed = 600;
	barrelGenSpeed = 1900;
	barrelGenProb = 3;
	barrelBlinkWait = 0;
	screenScroll = 0;
	screenScrollWait = 0;
	animating1 = 0;
	animating2 = 0;
	animating2Wait = 0;
	animating2Sound = 0;
	playing = 0;
	lives = 3;
	SwitchScreen(1);
	startX = 0;


	// begin!
	ClearSlate();
  DisplaySlate();
	//sndIntro();
	playIntro = 1;
	ClearBarrels(0);
	playing = 1;
}

byte ScreenLights()
{
	byte ret = 1;
	if (screenNbr == 1) {
		ret = 1;
	}
	else if (screenNbr == 2) {
		ret = 3;
	}
	else if (screenNbr == 3) {
		ret = 7;
	}
	else if (screenNbr == 4) {
		ret = 15;
	}
	else if (screenNbr == screenNbrCount) {
		ret = 31;
	}
	else {
		ret = 0;
	}
	
	return ret;
}

void SwitchScreen(byte reset)
{
	if (reset == 1)
	{
		screenNbr = 1;
		if (DEBUGGING == 1) screenNbr = screenNbrCount;
	}
	else
	{
		screenNbr++;
		if (screenNbr > screenNbrCount) screenNbr = 1;
	}
	
	// set ladders and stuff
	if (screenNbr == 1)
	{
		ladder1 = 6; ladder2 = 1; ladder3 = 5;
		if ((rand()/(RAND_MAX/2+1)) == 0)
		{
			hammerX = 0;
			hammerY = 1;
		}
		else
		{
			hammerX = 7;
			hammerY = 4;
		}

		// reset stuff
		barrelGenSpeed = 1900;
		barrelGenProb = 3;
/*
		if (speed <= 1)
			barrelGenProb = 3;
		else if (speed <= 4)
			barrelGenProb = 4;
		else
			barrelGenProb = 5;
*/
			
	}
	else if (screenNbr == 2)
	{
		ladder1 = 1; ladder2 = 6; ladder3 = 1;
		if ((rand()/(RAND_MAX/2+1)) == 0)
		{
			hammerX = 0;
			hammerY = 4;
		}
		else
		{
			hammerX = 7;
			hammerY = 1;
		}
	}
	else if (screenNbr == 3)
	{
		ladder1 = 6; ladder2 = 2; ladder3 = 6;
		if ((rand()/(RAND_MAX/2+1)) == 0)
		{
			hammerX = 0;
			hammerY = 1;
		}
		else
		{
			hammerX = 7;
			hammerY = 4;
		}
	}
	else if (screenNbr == 4)
	{
		ladder1 = 1; ladder2 = 6; ladder3 = 1;
		hammerX = 0;
		hammerY = 4;
	}
	else
	{
		ladder1 = 6; ladder2 = 1; ladder3 = 1;
		hammerX = 0;
		hammerY = 1;

		barrelGenSpeed = 2300;
		barrelGenProb = 3; // was 4
/*
		if (speed <= 1)
			barrelGenProb = 5;
		else if (speed <= 4)
			barrelGenProb = 6;
		else
			barrelGenProb = 7;
*/
		
		kongHitCount = 0;
	}
	
	hammerUsed = 0;
	SetAuxLEDs(((255 >> (8-lives)) << (8-lives)) + ScreenLights());
	
}

void StartScreen(void)
{
	//ClearSlate();
	//DisplaySlate();
	
  ypos = 0;	
	screenScroll = 0;
	ClearBarrels(1);
	playing = 1;
}

// run once, when the sketch starts
void setup()
{

  MeggyJrSimpleSetup(); // Required code, line 2 of 2.

	// colors
  clrGirder = Orange;
  EditColor(CustomColor0, 2, 7, 1); // 2,7,1 decent gray
  clrLadder = CustomColor0;
  EditColor(CustomColor1, 7, 1, 0);
  EditColor(CustomColor2, 8, 0, 1);
  EditColor(CustomColor3, 0, 10, 0);
	clrKong = CustomColor2;
	clrGirl = Yellow;
	clrHeart = Red;
	clrHeartIn = CustomColor2;
	
	// stuff
	screenNbrCount = 5;
	animating2Switch = 11;
	
  splashscreen();
	StartGame();
	
}



void loop()
{   

  unsigned long TempTime;
  byte i, j;
  int delayTemp;

  CheckButtonsPress();

	
  if (restart == 1)
  {
		StartGame();
  }
  else if ((Button_B || Button_A) && playing == 1)
  {
		ProcessJump();
  }

	// can't move while jumping
	if (jumping == 0 && playing == 1)
	{
	  if (Button_Up)
	  {
	    if ((ReadPx(xpos, ypos==7 ? ypos-1 : ypos+1) == clrLadder) ||
	  			(ReadPx(xpos-1,ypos) == clrGirder) ||
	  			(ReadPx(xpos+1,ypos) == clrGirder))
	  	{
		    if (ypos < 7)
		    {
					// ascend ladder
		      if (hammer == 0)
		      {
		      	ypos++;
			      sndLadder();
		      }
		    }
				else
				{
					// screen up
					ScreenTrans();
				}
	  	}
	  	else if (screenNbr == screenNbrCount && (ReadPx(xpos, ypos+1) == clrGirl))
	  	{
	  		// THE DOOD SAVES THE GIRL!
	  		sndWin(kongLevel);
	  		playing = 0;
	  		kongBeat = 0;
	  		kongColor = 0;
	  		if (kongLevel == 0)
	  		{
	  			// first win animation
					score += 250;
		  		kongLevel++;
		  		animating1 = 1;
	  		}
	  		else
	  		{
	  			// final win animation
					score += 1000;
	  			kongLevel = 0;
	  			animating2 = 1;
	  			animating2Sound = 1;
	  		}
	  	}
		}
		
	  if (Button_Down)
	  {
	  	if (ReadPx(xpos,ypos-1) == clrLadder)
	  	{
	  	  if (ypos > 0)
		    {
					// descend ladder
		      ypos--; 
		      sndLadder();
		    }
			}
		}
		
	  if (Button_Left)
	  {
	  	if (ypos == 0 ||
	  			ypos == girder1+1 ||
	  			ypos == girder2+1)
	  	{
		    if (xpos > 0)
		    { 
		      xpos--;
		      sndMove();
		    }
		  }
	  } 
	  
	  if (Button_Right)
	  {
	  	if (ypos == 0 ||
	  			ypos == girder1+1 ||
	  			ypos == girder2+1)
	  	{
		    if (xpos < 7)
		    { 
		      xpos++;
		      sndMove();
		    }
		  }
	  }
	   
	}
	else if (playing == 1)
	{
		// dood is jumping during gameplay
		if (Button_Right && jumpMoved == 0 && xpos < 7)
		{
			xpos++;
			jumpMoved = 1;
		}
		else if (Button_Left && jumpMoved == 0 && xpos > 0)
		{
			xpos--;
			jumpMoved = 1;
		}
		else if (Button_Up && screenNbr == screenNbrCount && 
							xpos == 4 && ypos == 4 && kongBeat == 0 && 
							kongColor == 0 && jumpMoved == 0 && kongHitCount < 5)
		{
			// a hit on kong
			score += 10;
			kongHitCount++;
			sndKongHit();
			kongColorWait = 0;
			kongColor = 3;
			jumpMoved = 1; // hacking the byte so only 1 hit per jump
		}
		
		// barrel jump scoring
		if (ReadPx(xpos,ypos-1) == Red && jumpScored == 0)
		{
			jumpScored = 1;
			score += 10;			
		}
		
	} // end if jumping or not

  TempTime = millis();
  delayTemp = 125;//250;


  if (die == 0)
  {
    if  ((TempTime - lasttime) > 75) //redraw screen every 75 ms
    {
			if (screenScroll > 0)
			{
				// screen transition handling
				if (screenScrollWait == 0)
				{
					// draw bottom 7 rows
					for (j = 0; j < 7; j++)
					{
						for (i = 0; i <= 7; i++)
						{
							DrawPx(i, j, ReadPx(i,j+1));
						}
					}
					// draw top row
					if (screenScroll == 8)
					{
						// draw a 'fake' girder
						for (i = 0; i <= 7; i++)
						{
							DrawPx(i, 7, clrGirder);
						}
						// move dood to fake girder
						DrawPx(xpos, ypos, Blue);
						DrawPx(xpos, ypos-1, clrLadder);
						startX = xpos;
					}
					else
					{
						j = 7 - screenScroll; // y of next screen
						for (i = 0; i <=7; i++)
						{
							// girders
							if (j == girder1 || j == girder2)
							{
								DrawPx(i, 7, clrGirder);
							}
							else
							{
								DrawPx(i, 7, Dark);
							}
							// ladders
							if (j >=0 && j < 3 && i == ladder1) DrawPx(i, 7, clrLadder);
							if (j >=3 && j < 6 && i == ladder2) DrawPx(i, 7, clrLadder);
							if (j >=6 && j < 7 && i == ladder3) DrawPx(i, 7, clrLadder);
							
						}
					}
					
					screenScroll--;
					sndScroll(screenScroll);
					if (screenScroll == 0) StartScreen();
					
				}
				screenScrollWait++;

			}
			else
			{
				// normal frame handling
				ClearSlate();

				// draw background
				if (screenNbr < screenNbrCount)
				{
					// girders
					DrawPx(0,girder1,clrGirder);
					DrawPx(1,girder1,clrGirder);
					DrawPx(2,girder1,clrGirder);
					DrawPx(3,girder1,clrGirder);
					DrawPx(4,girder1,clrGirder);
					DrawPx(5,girder1,clrGirder);
					DrawPx(6,girder1,clrGirder);
					DrawPx(7,girder1,clrGirder);
					DrawPx(0,girder2,clrGirder);
					DrawPx(1,girder2,clrGirder);
					DrawPx(2,girder2,clrGirder);
					DrawPx(3,girder2,clrGirder);
					DrawPx(4,girder2,clrGirder);
					DrawPx(5,girder2,clrGirder);
					DrawPx(6,girder2,clrGirder);
					DrawPx(7,girder2,clrGirder);
					// ladders
					DrawPx(ladder1,0,clrLadder);
					DrawPx(ladder1,1,clrLadder);
					DrawPx(ladder1,2,clrLadder);
					DrawPx(ladder2,3,clrLadder);
					DrawPx(ladder2,4,clrLadder);
					DrawPx(ladder2,5,clrLadder);
					DrawPx(ladder3,6,clrLadder);
					DrawPx(ladder3,7,clrLadder);
					// hammer
					if (hammerUsed == 0) DrawPx(hammerX,hammerY,CustomColor3);
				}
				else
				{
					// KONG screen
					if (animating2 == 0)
					{
						// girders
						DrawPx(0,girder1,clrGirder);
						DrawPx(1,girder1,clrGirder);
						DrawPx(2,girder1,clrGirder);
						DrawPx(3,girder1,clrGirder);
						DrawPx(4,girder1,clrGirder);
						DrawPx(5,girder1,clrGirder);
						DrawPx(6,girder1,clrGirder);
						DrawPx(7,girder1,clrGirder);
						// ladders
						DrawPx(ladder1,0,clrLadder);
						DrawPx(ladder1,1,clrLadder);
						DrawPx(ladder1,2,clrLadder);
						DrawPx(ladder2,3,clrLadder);
						DrawPx(ladder2,4,clrLadder);
						if (kongHitCount >= 5)
							DrawPx(ladder2,5,clrLadder);
						DrawPx(ladder2,6,clrLadder);
						if (animating1 == 0) DrawPx(ladder2,7,clrLadder);
						// hammer
						if (hammerUsed == 0 && animating1 == 0) DrawPx(hammerX,hammerY,CustomColor3);
						
					}
					// kong
					if (kongBeat == 0)
						if (kongColor >= 3)
							clrKong = Red;
						else
							clrKong = CustomColor2;
					else
					{
						if (kongColor == 0)
							clrKong = CustomColor1;
						else if (kongColor == 1)
							clrKong = CustomColor2;
						else
							clrKong = Red;
					}
					// kong
					if (animating1 == 0 && animating2 == 0)
					{
						// in-game kong
						// head and body
						DrawPx(4,7,clrKong);
						DrawPx(3,6,clrKong);
						DrawPx(4,6,clrKong);
						DrawPx(5,6,clrKong);
						DrawPx(3,5,clrKong);
						DrawPx(4,5,clrKong);
						DrawPx(5,5,clrKong);
						// arms and legs
						if (armLeft == 0)
							DrawPx(2,7,clrKong);
						else
							DrawPx(2,6,clrKong);
							
						if (armRight == 0)
							DrawPx(6,7,clrKong);
						
						if (legs == 0)
						{
							DrawPx(2,5,clrKong);
							DrawPx(2,4,clrKong);
							DrawPx(5,4,clrKong);
							DrawPx(5,3,clrKong);
						}
						else
						{
							DrawPx(3,4,clrKong);
							DrawPx(3,3,clrKong);
							DrawPx(6,5,clrKong);
							DrawPx(6,4,clrKong);
						}
						// girl
						DrawPx(1,7,clrGirl);
						
					}
					else if (animating1 > 0)
					{
						// animate kong climbing away
						animating1--; // animation hack so first frame he don't move up

						// head and body
						if (7+animating1<=7) DrawPx(4,7+animating1,clrKong);
						if (6+animating1<=7)
						{
							DrawPx(3,6+animating1,clrKong);
							DrawPx(4,6+animating1,clrKong);
							DrawPx(5,6+animating1,clrKong);
						}
						if (5+animating1<=7)
						{
							DrawPx(3,5+animating1,clrKong);
							DrawPx(4,5+animating1,clrKong);
							DrawPx(5,5+animating1,clrKong);
						}
						// arms and legs
						if (armLeft == 0 && 7+animating1<=7) DrawPx(2,7+animating1,clrKong);
						if (armLeft == 1 && 6+animating1<=7) DrawPx(2,6+animating1,clrKong);
							
						if (armRight == 0 && 7+animating1<=7) DrawPx(6,7+animating1,clrKong);
							
						if (legs == 0)
						{
							if (5+animating1<=7) DrawPx(2,5+animating1,clrKong);
							if (4+animating1<=7) DrawPx(2,4+animating1,clrKong);
							if (4+animating1<=7) DrawPx(5,4+animating1,clrKong);
							if (3+animating1<=7) DrawPx(5,3+animating1,clrKong);
						}
						else
						{
							if (4+animating1<=7) DrawPx(3,4+animating1,clrKong);
							if (3+animating1<=7) DrawPx(3,3+animating1,clrKong);
							if (5+animating1<=7) DrawPx(6,5+animating1,clrKong);
							if (4+animating1<=7) DrawPx(6,4+animating1,clrKong);
						}
						animating1++; // animating1 hack so first frame he won't move up
					}
					else if (animating2 > 0)
					{
						if (3-animating2>=0)
						{
							DrawPx(4,3-animating2,clrKong);
							DrawPx(2,3-animating2,clrKong);
							DrawPx(6,3-animating2,clrKong);
						}

						if (4-animating2>=0)
						{
							DrawPx(3,4-animating2,clrKong);
							DrawPx(4,4-animating2,clrKong);
							DrawPx(5,4-animating2,clrKong);
						}
						
						if (5-animating2>=0)
						{
							DrawPx(3,5-animating2,clrKong);
							DrawPx(4,5-animating2,clrKong);
							DrawPx(5,5-animating2,clrKong);
						}
						
						if (6-animating2>=0)
						{
							DrawPx(3,6-animating2,clrKong);
							DrawPx(5,6-animating2,clrKong);
						}
						
						if (7-animating2>=0)
						{
							DrawPx(3,7-animating2,clrKong);
							DrawPx(5,7-animating2,clrKong);
						}

						// girl and heart
						if (animating2 < animating2Switch)
							DrawPx(1,7,clrGirl);
						else
						{
							// girl (dood is set below after death check)
							DrawPx(4,0,clrGirl);
							// heart outside
							DrawPx(3,2,clrHeart);
							DrawPx(4,2,clrHeart);
							DrawPx(2,3,clrHeart);
							DrawPx(5,3,clrHeart);
							DrawPx(1,4,clrHeart);
							DrawPx(6,4,clrHeart);
							DrawPx(0,5,clrHeart);
							DrawPx(7,5,clrHeart);
							DrawPx(1,6,clrHeart);
							DrawPx(6,6,clrHeart);
							DrawPx(2,7,clrHeart);
							DrawPx(5,7,clrHeart);
							DrawPx(3,6,clrHeart);
							DrawPx(4,6,clrHeart);
							// heart inside
							rndHeart1 = (rand()/(RAND_MAX/14+1));
							rndHeart2 = (rand()/(RAND_MAX/14+1));
							rndHeart3 = (rand()/(RAND_MAX/14+1));
							if (rndHeart1==0||rndHeart2==0||rndHeart3==0) DrawPx(3,3,clrHeartIn);
							if (rndHeart1==1||rndHeart2==1||rndHeart3==1) DrawPx(4,3,clrHeartIn);
							if (rndHeart1==2||rndHeart2==2||rndHeart3==2) DrawPx(2,4,clrHeartIn);
							if (rndHeart1==3||rndHeart2==3||rndHeart3==3) DrawPx(5,4,clrHeartIn);
							if (rndHeart1==4||rndHeart2==4||rndHeart3==4) DrawPx(3,4,clrHeartIn);
							if (rndHeart1==5||rndHeart2==5||rndHeart3==5) DrawPx(4,4,clrHeartIn);
							if (rndHeart1==6||rndHeart2==6||rndHeart3==6) DrawPx(1,5,clrHeartIn);
							if (rndHeart1==7||rndHeart2==7||rndHeart3==7) DrawPx(6,5,clrHeartIn);
							if (rndHeart1==8||rndHeart2==8||rndHeart3==8) DrawPx(2,5,clrHeartIn);
							if (rndHeart1==9||rndHeart2==9||rndHeart3==9) DrawPx(5,5,clrHeartIn);
							if (rndHeart1==10||rndHeart2==10||rndHeart3==10) DrawPx(3,5,clrHeartIn);
							if (rndHeart1==11||rndHeart2==11||rndHeart3==11) DrawPx(4,5,clrHeartIn);
							if (rndHeart1==12||rndHeart2==12||rndHeart3==12) DrawPx(2,6,clrHeartIn);
							if (rndHeart1==13||rndHeart2==13||rndHeart3==13) DrawPx(5,6,clrHeartIn);
							
						}
						
						
					} // end animation type handling
															
				} // end screen type handling
				
				
				// draw barrels
				if (animating1 == 0 && animating2 == 0)
				{
					barrelSoundPlayed = 0;
					for (i = 0; i < BARRELMAX; i++)
					{
						if (barrels[i].active > 0)
						{
							if (barrels[i].type == 0)
							{
								DrawPx(barrels[i].x, barrels[i].y, barrels[i].color);
							}
							else
							{
								if (barrelBlink == 0)
								{
									DrawPx(barrels[i].x, barrels[i].y, CustomColor1);								
								}
								else if (barrelBlink == 1)
								{
									DrawPx(barrels[i].x, barrels[i].y, CustomColor2);
									if (barrelSoundPlayed == 0)
									{
										sndBarrel1();
										barrelSoundPlayed = 1;
									}
								}
								else
									DrawPx(barrels[i].x, barrels[i].y, barrels[i].color);
							}
						} // end barrel active
					} // end barrel loop
				} // end if not animating
				
				getBad = ReadPx(xpos,ypos);

				if ((getBad == Red || getBad == clrKong) && playing == 1 && 
						animating1 == 0 && animating2 == 0 && hammer == 0)
				{
					die = 1;
				}
				if (getBad == CustomColor3)
				{
					// picked up hammer
					hammerUsed = 1;
					hammerWait = 0;
					hammer = 1;
				}

				// you are dead
				if (die == 1)
				{
					//ClearSlate();

					if (lives > 0)
					{
						playing = 0;
						//sndDie();
						playDieSound = 1;
						DieScreen();
						
						lives--;
						die = 0;
						xpos = startX;
						ypos = 0;
						jumping = 0;
						jumpWait = 0;
						kongHitCount = 0;
						hammer = 0;
						//hammerUsed = 0;

						// setup barrels
						ClearBarrels(0);

						SetAuxLEDs(((255 >> (8-lives)) << (8-lives)) + ScreenLights());
						playing = 1;

					}  
					else
					{
						// game over
						SetAuxLEDs(0);
						playing = 0;
						//sndDie(); 
						playDieSound = 1;
						DieScreen(); // wait here
						restart = 1;
					}
						
				} // end if dead

				// move dood around for win animations
				if (animating2 > 0)
				{
					if (animating2 < animating2Switch)
					{
						xpos = 0;
						ypos = 7;
					}
					else
					{
						xpos = 3;
						ypos = 0;
					}
				}
				
				// draw dood
				if (hammer > 0 && barrelBlink == 1)
				{
					DrawPx(xpos,ypos,CustomColor3);
					sndHammer();
				}
				else
					DrawPx(xpos,ypos,Blue);

				// increment barrels
				barrelGenWait++;
				for (i = 0; i < BARRELMAX; i++)
				{
					if (barrels[i].active > 0)
						barrels[i].wait++;
				}

				// increment things
				if (jumping == 1) jumpWait++;
				if (screenNbr == screenNbrCount)
				{
					legsWait++;
					armLeftWait++;
					armRightWait++;
					kongColorWait++;
					kongBeatWait++;
					if (animating2 > 0)
					{
						animating2Wait++;
						animating2SoundWait++;
					}
				}
				hammerWait++;
				barrelBlinkWait++;
				
			} // end normal frame handling
			
			// write display
			DisplaySlate();
			
			// sounds
			if (playIntro == 1) sndIntro();
			
    } // end refresh handling
		
  }
  else
  {
		// ur dead - end display loop
		// TODO: need this?
		/*
    ClearSlate();
    DrawPx(xpos,ypos,DimRed);

    if (ypos == 0)
    {
      die = 0;
			lives = 2;
			SetAuxLEDs(192); 
    }
    
    DisplaySlate();
		*/
    ClearSlate();
    //DrawPx(xpos,ypos,DimRed);
    DisplaySlate();

  } // end if not dead


  // manage timers
  timerSpeed = speed*INCREMENTS;
  timerStatic = 0; // doesn't change with speed // TODO: more elegance :)
  
	if (playing > 0)
	{

		// jump timer
		if (timerSpeed < 1300) // was 1100
			timerEval = 1300 - timerSpeed;
		else
			timerEval = 5;

		if (jumpWait >= timerEval)
		{
			// the jump is over
			jumping = 0;
			jumpWait = 0;
			jumpMoved = 0;
			jumpScored = 0;
			ypos--;
		}
	

		// kong screen timers
		if (screenNbr == screenNbrCount)
		{
			//kong color
			if (timerStatic < 50)
				timerEval = 50 - timerStatic;
			else
				timerEval = 5;
	
			if (kongColorWait >= timerEval)
			{
				kongColorWait = 0;
				if (kongBeat == 0 && kongColor >= 3)
				{
					// kong was hit recently
					kongColor++;
					if (kongColor > 7) kongColor = 0;
				}
				if (kongBeat > 0)
				{
					kongColor++;
					if (kongColor > 2) kongColor = 0;
				}
				
			}

			// kong 'beating' and poop barrel
			if (timerStatic < 2300)
				timerEval = 2300 - timerStatic;
			else
				timerEval = 5;
					
			if (kongBeatWait >= timerEval)
			{
				if (kongBeat == 0)
				{
					if ((rand()/(RAND_MAX/kongBeatProb+1)) == 0)
					{
						// randomly start
						kongBeat++;
					}
				}
				else if (kongBeat == 1)
				{
					kongBeat++;
				}
				else
				{
					// start barrel
					sndKong();
					kongBeat++;
					NewBarrel(1);
					kongBeat = 0;
					kongColor = 0;
				}
				kongBeatWait = 0;				
			}

			//arms
			if (armLeft > 0)
			{
				if (timerStatic < 750)
					timerEval = 750 - timerStatic;
				else
					timerEval = 5;

				if (armLeftWait >= timerEval)
				{
					armLeftWait = 0;
					armLeft = 0;
					if ((rand()/(RAND_MAX/7+1)) == 0)
					{
						// girl screams every now and then?
						//sndGirl();
					}					
				}
			}
			if (timerStatic < 2500)
				timerEval = 2500 - timerStatic;
			else
				timerEval = 5;
	
			if (armRightWait >= timerEval)
			{
				armRight++;
				if (armRight > 3)
					armRight = 0;

				armRightWait = 0;
				
			}
			
		} // end screennbr final

		// generate barrels
		if (timerStatic < barrelGenSpeed)
			timerEval = barrelGenSpeed - timerStatic;
		else
			timerEval = 5;
		
		if (barrelGenWait >= timerEval)
		{
			if (barrelStartWait < 3) barrelStartWait++;
			// don't make one too soon and not more than 2 in a row
			// and not too long of a gap without one
			if (((rand()/(RAND_MAX/barrelGenProb+1)) == 0 && barrelStartWait >= 3 &&
					barrelYesCount < 3) || barrelNoCount > 6)
			{
				barrelYesCount++;
				barrelNoCount = 0;
				
				// new barrel
				NewBarrel(0);
				
				// process arms
				if (screenNbr == screenNbrCount)
				{
					armLeft = 1;
					armLeftWait = 0;
				}
			}
			else
			{
				barrelNoCount++;
				barrelYesCount = 0;
				
				if (screenNbr < screenNbrCount)
				{
					// type 1 barrel
					if ((rand()/(RAND_MAX/6+1)) == 0 && ypos < 5)
					{
						NewBarrel(1);
					}
				}				
			}
			barrelGenWait = 0;
		}
		
		// hammer
		if (timerSpeed < barrelSpeed)
			timerEval = barrelSpeed - timerSpeed;
		else
			timerEval = 5;

		if (hammerWait >= timerEval)
		{
			if (hammer > 0)
			{
				hammer++;
				if (hammer > 11)
				{
					hammer = 0;
				}
			}
			hammerWait = 0;
		}

		// process barrel movement
		for (i = 0; i < BARRELMAX; i++)
		{
			if (timerSpeed < barrels[i].timer)
				timerEval = barrels[i].timer - timerSpeed;
			else
				timerEval = 5;

			if (barrels[i].active > 0)
			{
				// process barrel movement
				if (barrels[i].wait >= timerEval)
				{
					if (barrels[i].falling == 0)
					{
						if (barrels[i].type == 0)
						{
							// move barrel horizontal
							if (((screenNbr % 2 != 0) && (barrels[i].y == 6 || barrels[i].y == 0)) ||
									((screenNbr % 2 == 0) && (barrels[i].y == 3)))
							{
								// moving to the left
								if (ReadPx(barrels[i].x, barrels[i].y-1) == clrLadder ||
										ReadPx(barrels[i].x, barrels[i].y-1) == Blue)
								{
									// randomly fall down ladder
									if (rand()/(RAND_MAX/3+1) == 0 && !(screenNbr == screenNbrCount && barrels[i].y>4)) // N = number of modes, 0 to N-1
									{
										barrels[i].y--;
										barrels[i].falling = 1;
										barrels[i].timer = 300;
									}
									else
									{
										barrels[i].x--; 
									}
								}
								else if (barrels[i].x == 0 && barrels[i].y == 0)
								{
									// inactivate barrel
									ResetBarrel(i);
								}
								else if (barrels[i].x == 0)
								{
									// start barrel fall off side
									barrels[i].y--;
									barrels[i].falling = 1;
									barrels[i].timer = 300;
								}
								else
								{
									barrels[i].x--;
								}
							}
							else
							{
								// moving to the right
								if (ReadPx(barrels[i].x, barrels[i].y-1) == clrLadder ||
										ReadPx(barrels[i].x, barrels[i].y-1) == Blue)
								{
									// randomly fall down ladder
									if ((rand()/(RAND_MAX/3+1)) == 0) // N = number of choices, 0 to N-1
									{
										barrels[i].y--;
										barrels[i].falling = 1;
										barrels[i].timer = 300;
									}
									else
									{
										barrels[i].x++; 
									}
								
								}
								else if (barrels[i].x == 7 && barrels[i].y == 0)
								{
									// inactivate barrel
									ResetBarrel(i);
								}
								else if (barrels[i].x == 7)
								{
									// start barrel fall off side
									barrels[i].y--;
									barrels[i].falling = 1;
									barrels[i].timer = 300;
								}
								else
								{
									barrels[i].x++;
								}
							}
						} // end type 0
					}
					else // barrel is falling down
					{
						if (barrels[i].type == 1)
						{
								// type 1 barrel
								if (barrels[i].y == 0)
								{
									// inactivate barrel
									ResetBarrel(i);
								}
								else
								{
									barrels[i].y--;
								}
						}
						else
						{
							// move barrel vertical
							barrels[i].falling++;
							if (barrels[i].falling > 2)
							{
								barrels[i].falling = 0;
								barrels[i].timer = barrelSpeed;
							}
					
							barrels[i].y--;
							
						} // end falling barrel type
					} // end falling or not
					
					barrels[i].wait = 0;

				} // end timer
			} // end barrel active
		} // end barrel processing loop
	}
	else // if not playing
	{
		// transition timer
		if (timerStatic < 600)
			timerEval = 600 - timerStatic;
		else
			timerEval = 5;

		if (screenScrollWait >= timerEval)
		{
			screenScrollWait = 0;
		}

		if (screenNbr == screenNbrCount)
		{
			if (timerStatic < 800)
				timerEval = 800 - timerStatic;
			else
				timerEval = 5;
				
			if (animating2 > 0 && animating2Wait >= timerEval)
			{
				animating2++;
				if (animating2 > animating2Switch + 7) // + a few extra beats show heart blinking
				{
					// end animation and begin again
					animating2 = 0;
					animating2Sound = 0;
					// TODO: show score
				  //while (TextScroll(0, Red, 100, 1) == 0) {}
		  		speed++;
		  		xpos = 0;
		  		playing = 1;
		  		ScreenTrans();
				}
				animating2Wait = 0;
			}
		
			if (timerStatic < 100)
				timerEval = 100 - timerStatic;
			else
				timerEval = 5;

			if (animating2Sound > 0 && animating2SoundWait >= timerEval)
			{
				animating2Sound++;
				if (animating2Sound > 77)
				{
					animating2Sound = 0;
					sndKongFall(0);
				}
				else
				{
					sndKongFall(animating2Sound);
				}
				animating2SoundWait = 0;
			}
		}

	} // end if playing
	
	
	// barrel blink (similar to kong color blink)
	if (timerStatic < 50)
		timerEval = 50 - timerStatic;
	else
		timerEval = 5;

	if (barrelBlinkWait >= timerEval)
	{
		barrelBlinkWait = 0;
		barrelBlink++;
		if (barrelBlink > 2) barrelBlink = 0;
	}

	// kong screen timers
	if (screenNbr == screenNbrCount)
	{
		//legs and animating1
		if (timerStatic < 1100)
			timerEval = 1100 - timerStatic;
		else
			timerEval = 5;

		if (legsWait >= timerEval*2 && animating1 == 0)
		{
			legs++;
			if (animating2 == 0) sndLeg();
			if (legs > 1) legs = 0;
			legsWait = 0;
		}
		else if (legsWait >= timerEval && animating1 > 0)
		{
			legs++;
			if (animating2 == 0) sndLeg();
			if (legs > 1) legs = 0;
			animating1++;
			if (animating1 > 10)
			{
				// end animation and begin again
				animating1 = 0;
	  		speed++;
	  		playing = 1;
	  		ScreenTrans();
			}
			legsWait = 0;
		}
	}

	
}
