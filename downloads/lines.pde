/*
  lines.c
 
 Draw lines on meggy's screen.  

 Controls:
  A - start a new set of lines
  Left - toggle color cyclign on/off
  Up - slow down game
  Down - speed up game
 Version 0.01 - 17/1/2009
 Copyright (c) 2009 Ken Corey.  All rights reserved.
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
#include <Math.h>

#define screenwidth 8
#define screenheight 8

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
  int16_t x1,y1;
  int16_t x2,y2;
  byte colorindex;
  byte v;
} Line;

unsigned char radarcolours[6][3]={
  {0x00,0x00,0x00},
  {0x00,0x1f,0x05},
  {0x00,0x3f,0x0a},
  {0x00,0x5f,0x0f},
  {0x00,0xbf,0x1e},
  {0x00,0xdf,0x23}
};

#define maxlines 16
Line lines[16];
byte head, next, tail;
int16_t dx1, dx2, dy1, dy2;
byte colorindex;
uint16_t gamedelay;
byte cycling;
uint32_t TimeNow, keyNext, keyDelay;
int16_t state;

byte colorindexes[16];
byte brightnesses[16];

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


//Bresenham line from (x1,y1) to (x2,y2) with rgb color
//bool drawLine(int x1, int y1, int x2, int y2, const ColorRGB& color)
char 
drawLineRaw(int x1, int y1, int x2, int y2, void *vRGB, byte colorindex)
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
    num = deltax>>1;
    numadd = deltay;
    numpixels = deltax; //There are more x-values than y-values
  }
  else //There is at least one y-value for every x-value
  {
    xinc2 = 0; //Don't change the x for every iteration
    yinc1 = 0; //Don't change the y when numerator >= denominator
    den = deltay;
    num = deltay>>1;
    numadd = deltax;
    numpixels = deltay; //There are more y-values than x-values
  }
  for (curpixel = 0; curpixel <= numpixels; curpixel++)
  {
    if (!vRGB) {
      DrawPx(x % screenwidth, y % screenheight, colorindex);  //Draw the current pixel
    } else {
      color[0] = colorRGB->r>>4;
      color[1] = colorRGB->g>>4;
      color[2] = colorRGB->b>>4;
      Meg.SetPxClr(x % screenwidth, y % screenheight, color);  //Draw the current pixel
    }
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

//Bresenham line from (x1,y1) to (x2,y2) with indexes into the colour table
//and drawn by DrawPx
char drawLinePx(int x1, int y1, int x2, int y2, byte index)
{
  return drawLineRaw(x1,y1,x2,y2,0,index);
}

//Bresenham line from (x1,y1) to (x2,y2) with rgb color
//and drawn by SetPxClr
char 
drawLineClr(int x1, int y1, int x2, int y2, void *vRGB)
{
  return drawLineRaw(x1,y1,x2,y2,vRGB,0);
}

//Converts an HSV color to RGB color
/* pants */void HSVtoRGB(void *vRGB, void *vHSV) 
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

void
setupLines()
{
  int i;

  for(i=0;i<maxlines;i++) {
    lines[i].x1=0;
    lines[i].y1=0;
    lines[i].x2=0;
    lines[i].y2=0;
    lines[i].colorindex=0;
    lines[i].v=0;
  }

  colorindex=0;
  head=0;
  tail=0;

  lines[head].x1 = (rand()&7)<<8;
  lines[head].y1 = (rand()&7)<<8;
  lines[head].x2 = (rand()&7)<<8;
  lines[head].y2 = (rand()&7)<<8;

  dx1=(rand()&127);
  if (dx1<64) dx1 -= 128;
  dx2=(rand()&127);
  if (dx2<64) dx2 -= 128;
  dy1=(rand()&127);
  if (dy1<64) dy1 -= 128;
  dy2=(rand()&127);
  if (dy2<64) dy2 -= 128;

  colorindex=0;
  lines[head].colorindex=0;
  lines[head].v=255;

  // Our erase colour
  EditColor(25,0,0,0);
}


void
HandleKeys()
{
  
  CheckButtonsPress();
  
  if (Button_A) {
    DisplaySlate();
    setupLines();
  }
  if (Button_B) {
  }
  if (Button_Left) {
    cycling ^= 1;
  }
  if (Button_Down) {
    if (gamedelay) {
      if (gamedelay<=10) {
        gamedelay-=1;
      } else {
        gamedelay-=5;
      }
    }
  }
  if (Button_Up) {
    gamedelay+=5;
    gamedelay%=1000;
  }
  if (Button_Right) {
  }
}

// This turns all pixels with colour 'index' to colour 25, erasing them.
void
setPixels(byte index)
{
  int i,j;

  for(i=0;i<screenwidth;i++) {
    for(j=0;j<screenwidth;j++) {
      if (ReadPx(i,j)==index) {
        DrawPx(i,j,25);
      }
    }
  }

}

void setup()                    // run once, when the sketch starts
{
  MeggyJrSimpleSetup();      // Required code, line 2 of 2.
  state=0;
  gamedelay=15;
  cycling=1;
  keyDelay=200;
  keyNext=millis();

  setupLines();
}

void loop()                     // run over and over again
{
  ColorHSV colorhsv;
  ColorRGB colorrgb;
  int i;

  TimeNow=millis();

  if (TimeNow>keyNext) {
    HandleKeys();
    keyNext+=keyDelay;
  }

  switch (state) {
    case 0:
      if (!cycling) {
        // Here, color cycling is done by redrawing the pixels of 
        // previous lines in darker colours.
        i = tail;
        while (i!=head) {
          colorhsv.h=lines[i].colorindex;
          colorhsv.s=255;
          lines[i].v-=17;
          colorhsv.v=lines[i].v;
          HSVtoRGB(&colorrgb,&colorhsv);
          drawLineClr(lines[i].x1>>8, lines[i].y1>>8, lines[i].x2>>8, lines[i].y2>>8, &colorrgb);
          if (i==maxlines) {
            i=0;
          } else {
            i++;
            if (i==maxlines) {
              i=0;
            }
          }
        }
      } else {
        i = tail;
        while (i!=head) {
          colorhsv.h=colorindexes[i];
          colorhsv.s=255;
          brightnesses[i] -= 17;
          colorhsv.v=brightnesses[i];
          HSVtoRGB(&colorrgb,&colorhsv);
          EditColor(i,colorrgb.r>>4,colorrgb.g>>4,colorrgb.b>>4);
          if (colorrgb.r>>4==0 &&
            colorrgb.g>>4==0 &&
            colorrgb.b>>4==0) {
              // we've got to "erase" this colour
              // we do it by setting all the pixels with this colour to dark.
              setPixels(i);
          }
          if (i==maxlines) {
            i=0;
          } else {
            i++;
            if (i==maxlines) {
              i=0;
            }
          }
        }
      }
      if (!cycling) {
        colorhsv.h=lines[head].colorindex;
        colorhsv.v=lines[head].v;
      } else {
        colorhsv.h=colorindexes[head];
        colorhsv.v=brightnesses[head];
      }

      colorhsv.s=255;
      HSVtoRGB(&colorrgb,&colorhsv);
      EditColor(head,colorrgb.r>>4,colorrgb.g>>4,colorrgb.b>>4);
      if (!cycling) {
        drawLineClr(lines[head].x1>>8, lines[head].y1>>8, lines[head].x2>>8, lines[head].y2>>8, &colorrgb);
      } else {
        drawLinePx(lines[head].x1>>8, lines[head].y1>>8, lines[head].x2>>8, lines[head].y2>>8, head);
      }

      next = head+1;
      if (next==maxlines) {
        next=0;
      }
      lines[next].x1 = lines[head].x1 + dx1;
      i = lines[next].x1>>8;
      if (i < 0 || i>7) { dx1=-dx1; }
      lines[next].y1 = lines[head].y1 + dy1;
      i = lines[next].y1>>8;
      if (i < 0 || i>7) { dy1=-dy1; }
      lines[next].x2 = lines[head].x2 + dx2;
      i = lines[next].x2>>8;
      if (i < 0 || i>7) { dx2=-dx2; }
      lines[next].y2 = lines[head].y2 + dy2;
      i = lines[next].y2>>8;
      if (i < 0 || i>7) { dy2=-dy2; }

      lines[next].colorindex=colorindex++;
      colorindexes[next] = lines[next].colorindex;
      lines[next].v=255;
      brightnesses[next] = lines[next].v;

      head=next;

      if (head==tail) {
        tail += 1;
        if (tail==maxlines) {
          tail=0;
        }
      }

      if (cycling) {
        DisplaySlate();
      }
      break;
  }
  delay(gamedelay);                  // waits for a second  
}


