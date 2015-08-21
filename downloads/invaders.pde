/*
  MeggyJr_Invaders.pde
 
 Example file using the The Meggy Jr Simplified Library (MJSL)
  from the Meggy Jr RGB library for Arduino
   
 A clone of space invaders...sort of.
   
 A few user notes:
 Controls:
  Left & Right - Move the ship
  Button A - Fire the ships cannon

 Due to the smallish screen on the meggy, I made the bad guys go
 back and forth a few times per line.  The left-most 2 AuxLEDs show what
 lap you're on...if nothing is showing there, the bad guys will go down next turn.

 The rest of the LEDs indicate the level that you're on.

 Your bullets will destroy incoming bullets.

 When you hit a bad guy or the ufo, his ship doesn't just disappear, it bursts
 into flame, and then takes a little while to burn itself out.  The ship no 
 longer counts as far as the game is concerned, it's just (I think) pretty.
 
 Version 1.01 - 20/1/09
 Copyright (c) 2009 Ken Corey.  All right reserved.
 http://flippinbits.com
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
#include <math.h>
#ifndef MeggySimulator
#include <avr/pgmspace.h>
#endif

#define screenwidth 8
#define screenheight 8
#define PI 3.1415926

unsigned long gamedelay,keydelay,keyNext;
unsigned long bulletdelay,bulletNext;
unsigned long TimeNow, TimeLast, TimeNext;
unsigned long bulletkeybounce,bulletbounceNext;
unsigned long burndelay,burnNext;
unsigned long BadguyNext;
unsigned long ufoNext, ufoDelay;
unsigned long ufoUpdateNext, ufoUpdateDelay;
uint16_t totalscore;
unsigned long totalticks;
unsigned long bulletticks;
uint16_t gamelevel;
char lives;
unsigned long soundticks;
char ufox;
char ufodir;
char ufostate;
unsigned char maxbadguyy;

char scrollingstring;

char gamestate;

unsigned char shipx,oldshipx;
unsigned char haswon,haslost,numbullets;
double angle, speed, scale, dscale;

typedef struct {
  char x;
  char y;
  char state;
} badguytype;

typedef struct {
  char x;
  char y;
  char dir;
} bullettype;

typedef struct {
  char x;
  char y;
  char str;
} barriertype;

typedef struct
{
  int r;
  int g;
  int b;
} ColorRGB;

//a color with 3 components: h, s and v
typedef struct 
{
  int h;
  int s;
  int v;
} ColorHSV;

typedef struct
{
  byte x1,y1;
  byte x2,y2;
  ColorRGB colour;
} Line;

byte texture[8][8] = {
  {0,0,0,1,1,0,0,0},
  {0,0,1,1,1,1,0,0},
  {0,1,1,1,1,1,1,0},
  {1,1,0,1,1,0,1,1},
  {1,1,1,1,1,1,1,1},
  {0,1,0,0,0,0,1,0},
  {1,0,0,0,0,0,0,1},
  {0,1,0,0,0,0,1,0},
};

badguytype badguys[15];
bullettype bullets[15];
barriertype barriers[8];

unsigned char badguydir;
unsigned char numbadguys;
int badguydelay;
int rowdoublecount,thisrowdouble;

prog_uint32_t PROGMEM matrix[67] = {
  // 0-9  (0-9)
  0x3400056a,0x34000597,0x34000c67,0x34000cce,0x34000379,0x34000f0e,0x3400073f,0x34000e54,
  0x340005ea,0x34000779,
  
  // A-Z  (10-35)
  0x3400057d,0x34000dee,0x34000723,0x34000d6e,0x34000fa7,0x34000f34,
  0x3400072b,0x34000b7d,0x34000e97,0x3400026a,0x34000bad,0x34000927,0x34000bed,0x34000bfd,
  0x34000f6f,0x34000d74,0x34000f7f,0x34000d75,0x3400070e,0x34000e92,0x34000b6f,0x34000b59,
  0x5408d6aa,0x34000aad,0x34000a92,0x34000e57,
  
  // a-z  (36-61)
  0x340000eb,0x340009ae,0x340000e3,0x340002eb,0x340000f3,0x2400006e,
  0x248000f7,0x340009ad,0x1400000b,0x25800117,0x34000975,0x1400000f,0x53006ab5,0x340001ad,
  0x340000aa,0x34800d74,0x34800759,0x2400003a,0x340000d6,0x340005d2,0x3400016f,0x3400016a,
  0x530046aa,0x34000155,0x34800bce,0x340001d7,
  
  // ' '  (62)
  0x11000000,

  // .,;: (63-66)
  0x11000001,0x22800006,0x24800046,0x13000005
};

char buffer[30];

typedef struct {
  boolean active;
  unsigned int offset;
  boolean loop;
  int delay;
  char x;
  char y;
  char w;
  char h;
  char *msg;
  unsigned long next;
} stringscroller;

stringscroller messages;

void
MyDrawPix(byte xin, byte yin, byte color) {
  int a=0,b=0;
  if (xin>=0 && xin<=7 && yin>=0 && yin<=7) {
    DrawPx(xin,yin,color);
  } else {
    a=b;
  }
}


//this is the fixed-point version of the scaling/rotation routine.
//since we want maximum speed while still remaining in C parts of this
//may be hard to read compared to the general rotate/scale routine.
//It is similiar to the mathematical version except it uses 16.16
//fixed-point and computes an initial texture vector then does something
//similiar to a two-level line drawing routine, ok?
//frankly, it's still slow as hell when compared to the full asm version.
//hmm. Is it just C or Borland that is the problem? :)
void FastRotateScale(double scale, double angle)
{

    long sinas=(long)(sin(-angle)*65536L*scale);
    long cosas=(long)(cos(-angle)*65536L*scale);

    long xc=(long)(3.5*65536L - (3.5*(cosas+sinas)));
    long yc=(long)(3.5*65536L - (3.5*(cosas-sinas)));

    uint16_t x,y;

    int16_t tempx,tempy;

    for (y=0;y< screenheight ;y++)
    {
        long xlong=xc,ylong=yc;
        for (x=0;x<screenheight;x++)
        {
            tempx=(uint16_t)(xlong>>16);
            tempy=(uint16_t)(ylong>>16);

            if( (tempx<0) || //clip
                (tempx>=screenwidth) ||
                (tempy<0) ||
                (tempy>= screenheight ) )
                DrawPx((byte)x,(byte)y,Dark);
            else
                DrawPx((byte)x,(byte)y,texture[tempx][tempy]);

            xlong+=cosas;ylong-=sinas;
        }
        xc+=sinas;yc+=cosas;
    }
}

void InitStrings()
{
  messages.active = 0;
  messages.offset = 0;
  messages.loop = 0;
  messages.delay = 0;
  messages.x = 0;
  messages.y = 0;
  messages.w = 0;
  messages.h = 0;
  messages.msg = 0;
  messages.next = 0;
}

int 
GetCharCI(char c) {
  if (c>= '0' && c<='9') {
    return c-'0';
  }
  if (c>= 'A' && c<= 'Z') {
    return c-'A'+10;
  }
  if (c>= 'a' && c<= 'z') {
    return c-'a'+36;
  }
  if (c==' ') {
     return 62;
  }
  if (c=='.') {
     return 63;
  }
  if (c==',') {
     return 64;
  }
  if (c==';') {
     return 65;
  }
  if (c==':') {
     return 66;
  }

  return 0;
}

short 
MyGetCharWidth(char c)
{
  uint16_t CI=GetCharCI(c);

  long buffer=(prog_uint32_t)((prog_uint32_t)pgm_read_dword_near(&matrix[CI]));
  return (uint16_t)(buffer>>28);
}

boolean DrawChar(byte c, int x, byte y, byte w, byte h, int offset) {
  int i,j;
  int fw,fh;
  char CI=GetCharCI(c);
  uint32_t rawdata = (uint32_t)((prog_uint32_t)pgm_read_dword_near(&matrix[CI]));
  unsigned long bits=rawdata & 0x00ffffff;
  short a,b;
  boolean idrew=0;
  boolean desc;

  fw = rawdata >> 28;
  fh = rawdata >> 24 & 0xf;
  desc = rawdata  >> 23 & 1;

  if (!desc) {
    y++;
  }

  for (j=fh;j;j--) {
    for (i=fw;i;i--) {
      a = x+i-1+offset;
      b = fh-j+y;
      if (a >= x && a<= x+w
        && b>= y && b<= y+h) {
        if (bits & 1) {
          MyDrawPix((byte)a,(byte)b,White);
          idrew=1;
        } else {
          MyDrawPix((byte)a,(byte)b,Dark);
          idrew=1;
        }
      }
      bits >>= 1;
    }
  }
  return idrew;
}

// Draw a string, scroll it, return a boolean on whether we drew or not.
boolean DrawString(char *str, int x, byte y, byte w, byte h, int offset) {
  int i, length=0;
  short charw;
  boolean idrew=0;

  i=0;
  while (str[i]) {
    charw = MyGetCharWidth(str[i]);
    if (offset<=x+w || offset+length+charw>=x) {
      if (DrawChar(str[i], x, y, w, h, offset-x+length)) {
        idrew=1;
      }
    }

    length += charw+1;
    i++;
  }

  return idrew;
}

void
CreateString(char *msg, short x, short y, short w, short h, boolean loop) 
{
  short charwidth;

  if (msg) {
    charwidth=MyGetCharWidth(*msg);
    messages.active = 1;
    scrollingstring=1;
    messages.offset = x+w+charwidth-2;
    messages.loop = loop;
    messages.delay = 100;
    messages.x = (char)x;
    messages.y = (char)y;
    messages.w = (char)w;
    messages.h = (char)h;
    messages.msg = msg;
    messages.next = TimeNow+messages.delay;
  }
}

//Bresenham line from (x1,y1) to (x2,y2) with rgb color
//bool drawLine(int x1, int y1, int x2, int y2, const ColorRGB& color)
char 
drawLine(int x1, int y1, int x2, int y2, void *vRGB)
{
  ColorRGB *colorRGB=(ColorRGB *)vRGB;
  int deltax; //The difference between the x's
  int deltay; //The difference between the y's
  int x; //Start x off at the first pixel
  int y; //Start y off at the first pixel
  int xinc1, xinc2, yinc1, yinc2, den, num, numadd, numpixels, curpixel;
  byte color[3];

  if(x1 < 0 || x1 > screenwidth - 1 || x2 < 0 || x2 > screenwidth - 1 || y1 < 0 || y1 > screenheight - 1 || y2 < 0 || y2 > screenheight - 1) return 0;
  
  deltax = abs(x2 - x1); //The difference between the x's
  deltay = abs(y2 - y1); //The difference between the y's
  x = x1; //Start x off at the first pixel
  y = y1; //Start y off at the first pixel
  xinc1, xinc2, yinc1, yinc2, den, num, numadd, numpixels, curpixel;

  if(x2 >= x1) //The x-values are increasing
  {
    xinc1 = 1;
    xinc2 = 1;
  }
  else //The x-values are decreasing
  {
    xinc1 = -1;
    xinc2 = -1;
  }
  if(y2 >= y1) //The y-values are increasing
  {
    yinc1 = 1;
    yinc2 = 1;
  }
  else //The y-values are decreasing
  {
    yinc1 = -1;
    yinc2 = -1;
  }
  if (deltax >= deltay) //There is at least one x-value for every y-value
  {
    xinc1 = 0; //Don't change the x when numerator >= denominator
    yinc2 = 0; //Don't change the y for every iteration
    den = deltax;
    num = deltax / 2;
    numadd = deltay;
    numpixels = deltax; //There are more x-values than y-values
  }
  else //There is at least one y-value for every x-value
  {
    xinc2 = 0; //Don't change the x for every iteration
    yinc1 = 0; //Don't change the y when numerator >= denominator
    den = deltay;
    num = deltay / 2;
    numadd = deltax;
    numpixels = deltay; //There are more y-values than x-values
  }
  for (curpixel = 0; curpixel <= numpixels; curpixel++)
  {
    color[0] = colorRGB->r>>4;
    color[1] = colorRGB->g>>4;
    color[2] = colorRGB->b>>4;
    Meg.SetPxClr(x % screenwidth, y % screenheight, color);  //Draw the current pixel
    //DrawPx(x % screenwidth, y % screenheight, White);  //Draw the current pixel
    num += numadd;  //Increase the numerator by the top of the fraction
    if (num >= den) //Check if numerator >= denominator
    {
      num -= den; //Calculate the new numerator value
      x += xinc1; //Change the x as appropriate
      y += yinc1; //Change the y as appropriate
    }
    x += xinc2; //Change the x as appropriate
    y += yinc2; //Change the y as appropriate
  }

#ifdef MeggySimulator
  SDL_Flip (Meg.screen);     
#endif

  return 1;
}

//Converts an HSV color to RGB color
/*
void HSVtoRGB(void *vRGB, void *vHSV) 
{
  float r, g, b, h, s, v; //this function works with floats between 0 and 1
  float f, p, q, t;
  int i;
  ColorRGB *colorRGB=(ColorRGB *)vRGB;
  ColorHSV *colorHSV=(ColorHSV *)vHSV;

  h = (float)(colorHSV->h / 256.0);
  s = (float)(colorHSV->s / 256.0);
  v = (float)(colorHSV->v / 256.0);

  //if saturation is 0, the color is a shade of grey
  if(s == 0.0) {
    b = v;
    g = b;
    r = g;
  }
  //if saturation > 0, more complex calculations are needed
  else
  {
    h *= 6.0; //to bring hue to a number between 0 and 6, better for the calculations
    i = (int)(floor(h)); //e.g. 2.7 becomes 2 and 3.01 becomes 3 or 4.9999 becomes 4
    f = h - i;//the fractional part of h

    p = (float)(v * (1.0 - s));
    q = (float)(v * (1.0 - (s * f)));
    t = (float)(v * (1.0 - (s * (1.0 - f))));

    switch(i)
    {
      case 0: r=v; g=t; b=p; break;
      case 1: r=q; g=v; b=p; break;
      case 2: r=p; g=v; b=t; break;
      case 3: r=p; g=q; b=v; break;
      case 4: r=t; g=p; b=v; break;
      case 5: r=v; g=p; b=q; break;
      default: r = g = b = 0; break;
    }
  }
  colorRGB->r = (int)(r * 255.0);
  colorRGB->g = (int)(g * 255.0);
  colorRGB->b = (int)(b * 255.0);
}
*/

/*
void
DrawBox(short x, short y, short w, short h, short colour) {
  int i,j;
  while (x+w>7) { w-=1; }
  while (y+h>7) { h-=1; }
  for(i=x;i<=x+w;i++) {
    for(j=y;j<=y+h;j++) {
      DrawPx(i,j,(byte)colour);
    }
  }
}
*/

void
StringOneOffset()
{
/*
int a=0,b=0;


  a=b;
*/
}


void
StringFinished()
{
  scrollingstring = 0;
  messages.active=0;
}

void
Strings_Update() {
  short charwidth;

  if (messages.active && TimeNow > messages.next && messages.msg) {
    // Scroll one pixel to the left.
    messages.offset -= 1;
//    DrawBox(messages.x,messages.y,messages.w,messages.h,Dark);
    ClearSlate();

    if (!DrawString(messages.msg,messages.x,messages.y,messages.w,messages.h,messages.offset)) {
          // Couldn't draw the string, assume over.
      if (messages.loop) {
        charwidth=MyGetCharWidth(*(messages.msg));
        messages.offset=messages.x+messages.w+charwidth-2;
      } else {
        messages.active = 0;
        StringFinished();
      }
    }
    messages.next = millis() + messages.delay;

    StringOneOffset();
  }
}

void
SetupLevel(unsigned long level)
{
  unsigned char i;

  soundticks=0;
  ClearSlate();
  numbadguys=15;
  numbullets=0;
  for (i=0;i<15;i++) {
      badguys[i].x=i%5;
      if (i<5) {
        badguys[i].y=7;
      } else if (i<10) {
        badguys[i].y=6;
      } else {
        badguys[i].y=5;
      }
      badguys[i].state=0;
  }

  maxbadguyy=7;

  rowdoublecount=3-gamelevel/10;
  if (rowdoublecount < 0) {
    rowdoublecount=0;
  }
  thisrowdouble = rowdoublecount;
  badguydir=1;  // start shifting to the right
  badguydelay=800 - 10*gamelevel;
  if (badguydelay<300) {
    badguydelay=300;
  }

  bulletkeybounce=350+(gamelevel<<1);

  for (i=0;i<15;i++) {
    // mark all bullets as not in use.
    bullets[i].x=8;
  }

  barriers[0].x=1;barriers[0].y=1;barriers[0].str=2;
  barriers[1].x=2;barriers[1].y=1;barriers[1].str=2;
  barriers[2].x=5;barriers[2].y=1;barriers[2].str=2;
  barriers[3].x=6;barriers[3].y=1;barriers[3].str=2;
  barriers[4].x=1;barriers[4].y=2;barriers[4].str=2;
  barriers[5].x=2;barriers[5].y=2;barriers[5].str=2;
  barriers[6].x=5;barriers[6].y=2;barriers[6].str=2;
  barriers[7].x=6;barriers[7].y=2;barriers[7].str=2;

  // make the UFO sleep
  ufox = 8;
  ufostate=8;
}

void
SetupGame()
{
  TimeNow = millis();
  gamedelay=17;
  keydelay=100;
  bulletdelay=50;
  bulletkeybounce=350;
  bulletticks=0;
  totalscore=0;
  totalticks=0;
  shipx=4;
  SetAuxLEDs((byte)totalscore);
  haslost=0;
  numbullets=0;
  haswon=0;
  gamelevel=0;
  lives=3;
  ufoUpdateDelay=800;

  gamestate=0;

  angle=0.0;
  scale=(double)1.0000001;
  dscale=(double)0.05;
  speed=(double)48.5;

  ufoDelay=30000;
  ufoNext=millis()+ufoDelay;

  burndelay=35;
  burnNext=millis()+burndelay;

  EditColor(CustomColor0,11,15,14);
  EditColor(CustomColor1,9,9,9);

  // Make sure our buffer has nothing in it.
  buffer[0]=0;

  SetupLevel(gamelevel);
}

void setup()                    // run once, when the sketch starts
{
  MeggyJrSimpleSetup();      // Required code, line 2 of 2.
  
  SetupGame();
  scrollingstring=0;
}

void
FireBullet(unsigned char type, unsigned char x, unsigned char y) {
  unsigned char i=0;

  while(i<15) {
    if (bullets[i].x==8) {
      // found one to use.
      bullets[i].x = x;
      bullets[i].y = y;
      bullets[i].dir = type;

      i=16;
    }
    i++;
  }
}

void
UpdateBadguyspeed()
{
  switch(numbadguys) {
    case 10:
    case 5:
    case 2:
    case 1:
      badguydelay= 7*badguydelay/10;
      break;
    default:
      ;
  }
}

int 
BadGuyColour(int state) {
  int colour;
  switch(state) {
    case 0: 
      colour=White;
      break;
    case 1: 
      colour=Yellow;
      break;
    case 2: 
      colour=Orange;
      break;
    case 3: 
      colour=Red;
      break;
    case 4: 
      colour=DimRed;
      break;
    case 5: 
      colour=DimRed;
      break;
    case 6: 
      colour=Dark;
      break;
    case 7: 
      colour=Dark;
      break;
    default:
      colour=Dark;
      break;
  }
  return colour;
}

void
UpdateBadguyBurning()
{
  int i;

  for(i=0;i<15;i++) {
    if (badguys[i].state>0 && badguys[i].state<8
        && badguys[i].x>=0 && badguys[i].x<8
        && badguys[i].y>=0 && badguys[i].y<8) {
      badguys[i].state++;
      MyDrawPix(badguys[i].x,badguys[i].y,BadGuyColour(badguys[i].state));
    }
  }
  if (ufostate>0 && ufostate<8 && ufox<8) {
    MyDrawPix(ufox,7,BadGuyColour(ufostate));
    ufostate++;
  } else if (ufostate > 0) {
    ufostate=8;
    ufox=8;
  }
}

void
UpdateBullets()
{
  unsigned char i=0,j,drawbullet=0,a=0,b=0;

  while(i<15) {
    if (bullets[i].x<8) {
      if ((bulletticks&1 && bullets[i].dir)|| !bullets[i].dir) {
        // erase current bullet position
        MyDrawPix(bullets[i].x,bullets[i].y,Dark);
        // handle badguy bullets
        if (bullets[i].dir) {
          // Check for badguys, and redraw them if a collision
          for (j=0;j<15;j++) {
            if (badguys[j].state<8
                && badguys[j].x == bullets[i].x
                && badguys[j].y == bullets[i].y) {
                  MyDrawPix(badguys[j].x, badguys[j].y, BadGuyColour(badguys[j].state));
            }
          }
          // Check for collisions with other bullets
          for (j=0;j<15;j++) {
            if (i!=j && bullets[j].dir && bullets[j].x == shipx) {
              a=b;
            }
            if (i!=j
                && bullets[j].dir != bullets[i].dir
                && bullets[j].x<8 && bullets[i].x<8
                && bullets[j].x == bullets[i].x
                && (bullets[j].y == bullets[i].y
                  || bullets[j].y == bullets[i].y+1)) {
                  // bullet collision
                  MyDrawPix(bullets[j].x,bullets[j].y,Dark);
                  MyDrawPix(bullets[i].x,bullets[i].y,Dark);
                  bullets[j].x=8;
                  bullets[i].x=8;
                  numbullets-=1;
            }
          }

          // Check for collisions with barriers
          for (j=0;j<8;j++) {
            if (barriers[j].str
                && bullets[i].x < 8
                && bullets[i].x == barriers[j].x
                && bullets[i].y == barriers[j].y) {
                  // bullet just hit a barrier
                  barriers[j].str-=1;
                  if (!barriers[j].str) {
                    MyDrawPix(barriers[j].x, barriers[j].y, Dark);
                  }
                  bullets[i].x = 8;
            }
          }

          if (bullets[i].x<8) {
            if (bullets[i].x == shipx
              && bullets[i].y == 0) {
                // hit player
                haslost=1;
            }
          }

          if (bullets[i].x<8) {
            bullets[i].y -= 1;
            if (bullets[i].y < 0) {
              // didn't hit anything.
              bullets[i].x=8;
            } else {

              MyDrawPix(bullets[i].x,bullets[i].y,Red);
            }
          }
        } else {
          // ship bullet
          bullets[i].y += 1;
          drawbullet=1;
          if (bullets[i].y>7) {
            // set bullet back to unused
            bullets[i].x=8;
            numbullets--;
            drawbullet=0;
          } else {
            // Collisions with badguys
            for(j=0;j<15;j++) {
              if (badguys[j].state==0
                && badguys[j].x == bullets[i].x
                && badguys[j].y == bullets[i].y) {
                  // Collision!
                  //MyDrawPix(bullets[i].x,bullets[i].y,Orange);
                  // mark badguy as gone
                  badguys[j].state=1;
                  numbadguys-=1;
                  haswon=(numbadguys==0 && ufostate>0);
                  // mark bullet as gone
                  MyDrawPix(bullets[i].x,bullets[i].y,Yellow);
                  bullets[i].x=8;
                  numbullets--;
                  drawbullet=0;
                  UpdateBadguyspeed();
                  totalscore++;
              }
            }
            // Check for collisions with other bullets
            for (j=0;j<15;j++) {
              if (i!=j
                  && bullets[j].dir != bullets[i].dir
                  && bullets[j].x<8 && bullets[i].x<8
                  && bullets[j].x == bullets[i].x
                  && (bullets[j].y == bullets[i].y
                    || bullets[j].y == bullets[i].y+1)) {
                    // bullet collision
                    MyDrawPix(bullets[j].x,bullets[j].y,Dark);
                    MyDrawPix(bullets[i].x,bullets[i].y,Dark);
                    bullets[j].x=8;
                    bullets[i].x=8;
                    numbullets-=1;
                    drawbullet=0;
              }
            }
            // Collisions with barriers
            for(j=0;j<8;j++) {
              if (barriers[j].str 
                && barriers[j].x == bullets[i].x
                && barriers[j].y == bullets[i].y) {
                  // bullet just hit a barrier
                  barriers[j].str-=1;
                  if (!barriers[j].str) {
                    MyDrawPix(barriers[j].x, barriers[j].y, Dark);
                  }
                  bullets[i].x=8;
                  numbullets--;
                  drawbullet=0;
              }
            }
            // Collisions with ufo
            if (ufox<8
              && bullets[i].x==ufox
              && bullets[i].y==7) {
                if (ufostate==0) {
                  // collision with u22222222fo!
                  ufostate=1;
                }
                MyDrawPix(bullets[i].x,7,BadGuyColour(ufostate));
                bullets[i].x=8;
                numbullets--;
                drawbullet=0;
                haswon=(numbadguys==0 && ufostate>0);
                totalscore+=5;
            }
            if (drawbullet) {
              MyDrawPix(bullets[i].x, bullets[i].y, Blue);
            }
          }
        }
      }
    }
    i++;
  }
}

void
HandleKeys()
{
  // I copy the code of CheckButtonsDown and CheckButtonsPress here
  // because I want the diretional keys to be held to move, but the fire to 
  // not be held.
  byte j;
  byte i = Meg.GetButtons();
  j = i & ~(lastButtonState);  // What's changed?

  Button_B  = (j & 1);      
  Button_A = (j & 2);     
  Button_Up = (i & 4);
  Button_Down = (i & 8);
  Button_Left = (i & 16);
  Button_Right = (i & 32);

  lastButtonState=i;

  if (Button_A) {
    if (numbullets<2 && TimeNow> bulletbounceNext) {
      FireBullet(0,shipx,0);
      numbullets++;
      bulletbounceNext = TimeNow+bulletkeybounce;
    }
  }
  if (Button_B) {
  }
  if (Button_Left) {
    if (shipx) {
      shipx-=1;
    }
  }
  if (Button_Down) {
  }
  if (Button_Right) {
    if (shipx<7) {
      shipx+=1;
    }
  }
  //DisplaySlate();
}

void
EndGame() {
  ClearSlate();
  gamelevel=0;
  SetupGame();
}

void
UpdateUfo()
{
  if (ufostate==0 && ufox<8) {
    MyDrawPix(ufox,7,Dark);

    // update ufo
    if (ufostate==0) {
      if (ufodir) {
        // ufo automatically stops when off the screen.
        ufox+=1;
        if (ufox>7) {
          ufostate=8;
        }
      } else {
        if (ufox) {
          ufox-=1;
        } else {
          ufostate=8;
        }
      }
    }
  }
  if (ufostate==0) {
    MyDrawPix(ufox,7,Violet);
  }
}

void 
UpdateBadguys()
{
  unsigned char i, j, maxleft=7, maxright=0,miny,godown=0;
  unsigned int shoot;
  unsigned char leds;


  // Erase ships
  for (i=0;i<15;i++) {
    if (badguys[i].state < 8
      && badguys[i].x>=0 && badguys[i].x<8
      && badguys[i].y>=0 && badguys[i].y<8
      ) {
      MyDrawPix(badguys[i].x,badguys[i].y,Dark);
      //DisplaySlate();
    }
  }

  for (i=0;i<15;i++) {
    shoot = rand() & 127;
    if (badguys[i].state == 0
      && shoot<2+(gamelevel>>1)) {
      FireBullet(1,badguys[i].x, badguys[i].y);
    }
  }

  for (i=0;i<15;i++) {
    if (badguys[i].state < 1) {
      if (badguys[i].x > maxright) {
        maxright = badguys[i].x;
      }
      if (badguys[i].x < maxleft) {
        maxleft = badguys[i].x;
      }
    }
  }

  // Update positions
  // Is it time to go down?
  if ((badguydir && maxright==7) || (!badguydir && maxleft==0)) {
    badguydir = !badguydir;
    if (!thisrowdouble) {
      // find lowest badguy
      miny=7;
      maxbadguyy=0;
      for (i=0;i<15;i++) {
        badguys[i].y-=1;
        if (badguys[i].state < 1 && badguys[i].y < miny) {
          miny = badguys[i].y;
        }
        if (badguys[i].state < 1 && badguys[i].y > maxbadguyy) {
          maxbadguyy = badguys[i].y;
        }
      }
      // check to see if the invaders made it to the ground.
      if (!miny) {
        haslost=1;
      }
      if (miny < 3) {
        // We're likely losing our barriers.
        for (i=0;i<8;i++) {
          if (barriers[i].y == miny) {
            barriers[i].str=0;
          }
        }
      }
      thisrowdouble=rowdoublecount;
      godown=1;
    } else {
      thisrowdouble--;
    }
  }
  leds=thisrowdouble;
  if (lives>0) leds+= 128;
  if (lives>1) leds+= 64;
  if (lives>2) leds+= 32;
  SetAuxLEDs(leds);
  // If we didn't go down, we must be going sideways.
  if (!godown) {
    for (i=0;i<15;i++) {
      if (badguys[i].state <8) {
        if (badguydir) {
          badguys[i].x += 1;
        } else {
          badguys[i].x -= 1;
        }
      }
    }
  }

  // Draw ships
  for (i=0;i<15;i++) {
    if (badguys[i].state < 8) {
      // Collisions only happen when the ship is viable.
      if (badguys[i].state == 0 ) {
        for(j=0;j<15;j++) {
          if (bullets[j].x < 8 
            && bullets[j].dir == 0
            && bullets[j].x == badguys[i].x
            && bullets[j].y == badguys[i].y) {
              // Collision!
              // mark badguy as gone
              badguys[i].state=1;
              numbadguys-=1;
              haswon=(numbadguys==0 && ufostate>0);
              // mark bullet as gone
              MyDrawPix(bullets[j].x,bullets[j].y,Yellow);
              bullets[j].x=8;
              numbullets--;
              UpdateBadguyspeed();
          }
        }
      }
      if (badguys[i].state < 8
        && badguys[i].x>=0 && badguys[i].x<8
        && badguys[i].y>=0 && badguys[i].y<8
        ) {
          if (badguys[i].state == 0) {
            if (soundticks & 1) {
              MyDrawPix(badguys[i].x,badguys[i].y,CustomColor0);
            } else {
              MyDrawPix(badguys[i].x,badguys[i].y,CustomColor1);
            }
          } else {
            MyDrawPix(badguys[i].x,badguys[i].y,BadGuyColour(badguys[i].state));
          }
        //DisplaySlate();
      }
    }
  }
}

void
UpdateShip()
{
    MyDrawPix(oldshipx,0,Dark);
    MyDrawPix(shipx,0,Green);
    oldshipx=shipx;
}

void
DoWin()
{
  Tone_Start(ToneC3,100);
  
  haslost=0;
  haswon=0;

  gamelevel++;
  SetupLevel(gamelevel);
}

void
UpdateBarriers() {
  int i;
  for (i=0;i<8;i++) {
    if (barriers[i].str==2) {
      MyDrawPix(barriers[i].x,barriers[i].y,Yellow);
    } else if (barriers[i].str==1) {
      MyDrawPix(barriers[i].x,barriers[i].y,DimYellow);
    }
  }
}

void
LetScroll(char newstate)
{
  // scroll text now.
  DisplaySlate();
  delay(20);
  if (!scrollingstring) {
    gamestate=newstate;
    ClearSlate();
  }
}

void
ShipHalo(byte shipcol, byte halocol)
{
  MyDrawPix(shipx-1,0,halocol);
  MyDrawPix(shipx-1,1,halocol);
  MyDrawPix(shipx,1,halocol);
  MyDrawPix(shipx+1,1,halocol);
  MyDrawPix(shipx+1,0,halocol);
  MyDrawPix(shipx,0,shipcol);
}

void 
loop()                     // run over and over again
{
  ColorRGB colorrgb;
  char numbuf[10];
  byte buttons = Meg.GetButtons();

  TimeNow = millis();

  Tone_Update();
  Strings_Update();

  if (gamestate<10 && buttons) {
    randomSeed(TimeNow);
    gamestate=6;
  }
  switch(gamestate) {
    case 0:
      if (speed>0) {
        FastRotateScale(scale,angle);
        angle+=speed*(PI/180.0);
        if (angle>2.0*PI) {
          angle=0.0;
        }
        speed-=1;
        DisplaySlate();
        delay(50);
      } else {
        gamestate=1;
      }
      break;
    case 1:
      speed=0.0;
      angle = (90.0*(PI/180.0));
      FastRotateScale(scale,angle);
      DisplaySlate();
      colorrgb.r=255;
      colorrgb.g=255;
      colorrgb.b=255;
      delay(1000);
      gamestate=2;
      break;
    case 2:
      drawLine(0,0,7,7,&colorrgb);
      delay(1000);
      gamestate=3;
      break;
    case 3:
      drawLine(0,7,7,0,&colorrgb);
      delay(1000);
      gamestate=4;
      break;
    case 4:
      if (scale<6.50) {
        speed=0.0;
        angle = 90.0*(PI/180.0);
        FastRotateScale(scale,angle);
        scale+=dscale;
        dscale+=0.01;
      } else {
        gamestate=5;
      }
      DisplaySlate();
      delay(25);
      break;
    case 5:
        ClearSlate();
        DisplaySlate();
        strcpy(buffer,"Invaders are coming...");
        CreateString(buffer,1,1,7,7,0);
        gamestate=6;
      break;
    case 6:
      // scroll text now.
      LetScroll(10);
      break;
    case 10:
      if (TimeNow>keyNext) {
        HandleKeys();  
        keyNext=TimeNow+keydelay;
      }

      if (TimeNow > burnNext) {
        UpdateBadguyBurning();
        burnNext = TimeNow+burndelay;
      }

      if (TimeNow>ufoNext
        && maxbadguyy < 7
        && ufostate == 8) {
        // Start a new ufo...
          ufoNext = TimeNow + ufoDelay;
          ufoUpdateNext = TimeNow + ufoUpdateDelay;
          ufostate=0;
          if (TimeNow & 1) {
            ufox=7;
            ufodir=0;
          } else {
            ufox=0;
            ufodir=1;
          }
          MyDrawPix(ufox,7,Violet); 
      }

      if (TimeNow > ufoUpdateNext) { // Do a ufo tick
        haswon=(numbadguys==0 && ufostate>0);
        UpdateUfo();
        ufoUpdateNext = TimeNow+ufoUpdateDelay;
      }
      if (TimeNow > TimeNext) { // Do a badguy tick
        totalticks++;

        if (TimeNow > bulletNext) {
          bulletticks++;
          UpdateBullets();
          bulletNext = TimeNow + bulletdelay;
        }

        UpdateBarriers();

        if (TimeNow > BadguyNext) {
          if (soundticks & 1) {
            Tone_Start(ToneC3,50);
          } else {
            Tone_Start(ToneG3,50);
          }
          soundticks++;

          // update the position of the badguys, and fire.
          UpdateBadguys();

          BadguyNext = TimeNow + badguydelay;
        }

        if (haslost) {
          gamestate=11;
        } else if (haswon) {
          DoWin();
        } else {
          UpdateShip();
        }

        DisplaySlate();

        TimeNext=TimeNow+gamedelay;
      }  
    break;
    case 11:   //losing a life...and maybe the game
      Tone_Start(ToneC3,100);
      haslost=0;

      MyDrawPix(shipx,0,Yellow);
      delay(50);
      gamestate=12;
      break;
    case 12:
      ShipHalo(Orange,Yellow);
      DisplaySlate();
      delay(50);
      gamestate=13;
      break;
    case 13:
      ShipHalo(Red,Orange);
      DisplaySlate();
      delay(75);
      gamestate=14;
      break;
    case 14:
      ShipHalo(Dark,Red);
      DisplaySlate();
      delay(100);
      gamestate=15;
      break;
    case 15:
      ShipHalo(Dark,Dark);
      DisplaySlate();
      delay(200);
      gamestate=16;
      break;
   case 16:
      DisplaySlate();
      delay(500);
      gamestate=17;
      break;
     case 17:
        ClearSlate();
        DisplaySlate();
        lives-=1;
        if (lives < 1) {
          gamestate=20;
        } else {
          strcpy(buffer,"Ships left: ");
          itoa(lives,numbuf,10);
          strcat(buffer,numbuf);
          CreateString(buffer,0,0,7,7,0);
          gamestate=18;
        }
      break;
    case 18:
      // scroll text now.
      LetScroll(19);
      break;
    case 19:
      SetupLevel(gamelevel);
      gamestate=10;
      break;
    case 20:
      strcpy(buffer,"The Invaders win: HA HA HA...");
      CreateString(buffer,0,0,7,7,0);
      gamestate=21;
      break;
    case 21:
      // scroll text now.
      LetScroll(22);
      break;
    case 22:
      strcpy(buffer,"Score: ");
      itoa(totalscore,numbuf,10);
      strcat(buffer,numbuf);
      CreateString(buffer,0,0,7,7,0);
      gamestate=23;
      break;
    case 23:
      // scroll text now.
      LetScroll(24);
      break;
    case 24:
      EndGame();
      break;
  }

}
