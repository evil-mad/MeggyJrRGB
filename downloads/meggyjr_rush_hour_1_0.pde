/*
meggyjr_rush_hour.pde

===== RUSH HOUR FOR THE MEGGY JR RGB =====
A Meggy Jr implementation of ten puzzles from the Rush Hour sliding puzzle game.
(See http://en.wikipedia.org/wiki/Rush_Hour_(board_game) for info about Rush Hour.)
Copyright (c) 2009 Luke Gane. All rights reserved.
Version 1.0 - August 2009

=== HOW TO PLAY ===
Move the cursor around with the arrow buttons. Press B to move pieces.
You can press A if you want, but it doesn't do anything - YET. (Ominous music.)
The objective is to move the red piece all the way to the right and off the screen,
thus escaping the rush hour traffic that is inexplicably facing a variety of
perpendicular directions.
To move a piece, position the cursor over one end of it and press B.
If there's space in the axis of the piece next to the end of the piece that the
cursor is currently over, the piece will move into that space.
It is vital to know that the pieces that occupy two spaces are cars, while
those that occupy three are trucks.

=== EXTENSIBILITY ===
If you want to add, remove, or alter levels, they're stored as 6 x 6 arrays.
The defined constant number_of_levels indicates the number of levels (surprise surprise).
If a level is added, a pointer to its first element should be added to level_list.
Note that the game is only programmed to recognize pieces that are 2 or 3 collinear
elements of a level array (see the existing levels).

=== KNOWN BUGS ===
If a level has a car that's the colour of Truck Q (i.e. the default MJSL "Blue")
in the far-left column, an error will occur if that car is moved to the top-left
and then moved down again. For some reason, this causes the cursor to disappear
(i.e. turn off and stop blinking) and results in botched functionality until the
Meggy Jr is reset. This only occurs for blue cars, and doesn't seem to be linked
to the code. I suspect it's some sort of segmentation fault that's either a bug
with the ATMega168 or a specific issue with my particular Meggy Jr. Luckily, since
no cars have the colour of Truck Q, this bug doesn't affect regular levels, but
it's still rather odd to know it's there.

=== MEGGY JR RGB LIBRARY ===
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

// GLOBAL VARIABLES AND DEFINITIONS

// Definitions
#define cursor_colour 7
#define cursor_blink_delay 250
#define horizontal 1
#define vertical 2
#define space_above 30
#define space_below 31
#define space_left 32
#define space_right 33
#define space_none 34

#define border_colour 7

#define CX 1 //Red
#define CA 16 //CustomColor0
#define CB 2 //Orange
#define CC 17 //CustomColor1
#define CD 18 //CustomColor2
#define CE 19 //CustomColor3
#define CF 4 //Green
#define CG 20 //CustomColor4
#define CH 21 //CustomColor5
#define CI 22 //CustomColor6
#define CJ 23 //CustomColor7
#define CK 24 //CustomColor8
#define TO 3 //Yellow
#define TP 6 //Violet
#define TQ 5 //Blue
#define TR 25 //CustomColor9

#define number_of_levels 10

// Cursor position (LED coordinates)
byte cursor_x, cursor_y; // x: 0-7, y: 1-6

// Cursor on/off variable
boolean cursor_on;

// For cursor blinking
unsigned long cursor_time;

// To convert from the C array "y axis" (down) to the LED y axis (up) and vice versa
byte y_flip[6] = {5, 4, 3, 2, 1, 0};

// 2D array representing the game board
byte game_board[6][6] = {0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0};

// Game levels
byte level_1[6][6] = 
{0, CA, CB, CB, CC, CC,
0, CA, 0, CD, CE, CE,
CX, CX, 0, CD, TO, CF,
TP, TQ, TQ, TQ, TO, CF,
TP, 0, CG, 0, TO, CH,
TP, 0, CG, 0, 0, CH};

byte level_2[6][6] = 
{CA, CA, CB, 0, CC, CC,
CD, CD, CB, 0, 0, TO,
TP, CX, CX, 0, 0, TO,
TP, TQ, TQ, TQ, 0, TO,
TP, 0, 0, CE, CF, CF,
CG, CG, 0, CE, CH, CH};

byte level_3[6][6] = 
{0, 0, CA, CB, CB, 0,
0, 0, CA, 0, CJ, 0,
0, CD, CX, CX, CJ, 0,
0, CD, CE, CE, CF, 0,
0, TO, TO, TO, CF, 0,
0, 0, 0, 0, 0, 0};

byte level_4[6][6] = 
{CA, 0, 0, TO, TO, TO,
CA, CB, CB, CC, 0, 0,
CX, CX, CD, CC, 0, TP,
0, 0, CD, 0, 0, TP,
0, 0, CE, CF, CF, TP,
0, 0, CE, TQ, TQ, TQ};

byte level_5[6][6] = 
{TO, TO, TO, 0, TP, 0,
0, 0, CA, 0, TP, 0,
CX, CX, CA, 0, TP, CB,
CC, CD, CD, CE, CE, CB,
CC, CF, CF, CG, 0, CH,
TR, TR, TR, CG, 0, CH};

byte level_6[6][6] = 
{TO, 0, CA, TP, TP, TP,
TO, 0, CA, CB, 0, 0,
TO, CX, CX, CB, 0, 0,
CC, CC, CD, CD, 0, TQ,
0, 0, 0, 0, 0, TQ,
CE, CE, CF, CF, 0, TQ};

byte level_7[6][6] = 
{0, 0, CA, TO, TO, TO,
0, 0, CA, CB, 0, 0,
CX, CX, CC, CB, 0, TR,
CD, CD, CC, CE, CE, TR,
CF, CG, CH, CH, 0, TR,
CF, CG, CI, CI, 0, 0};

byte level_8[6][6] = 
{TO, CA, CA, 0, CB, 0,
TO, CC, CD, 0, CB, TP,
TO, CC, CD, CX, CX, TP,
TQ, TQ, TQ, CE, 0, TP,
0, 0, CF, CE, CG, CG,
CH, CH, CF, CI, CI, 0};

byte level_9[6][6] = 
{TO, TO, TO, CA, 0, TP,
CB, CC, CC, CA, 0, TP,
CB, 0, TQ, CX, CX, TP,
0, 0, TQ, CD, CE, CE,
0, 0, TQ, CD, 0, 0,
0, CF, CF, CG, CG, 0};

byte level_10[6][6] = 
{CA, CA, CB, 0, CC, CC,
0, 0, CB, 0, CD, CD,
CX, CX, CE, 0, 0, CF,
TO, 0, CE, CG, CG, CF,
TO, CH, CH, CI, 0, CJ,
TO, CK, CK, CI, 0, CJ};

// Array of pointers to the various levels
byte (*level_list[number_of_levels])[6] = {&level_1[0], &level_2[0], &level_3[0], &level_4[0], &level_5[0], &level_6[0], &level_7[0], &level_8[0], &level_9[0], &level_10[0]};

// What level the game is currently on
byte current_level = 1;

// SETUP

void setup() {
  MeggyJrSimpleSetup();
  
  EditColor(CustomColor0,8,15,1); // light green [done]
  EditColor(CustomColor1,9,12,15); // light blue [done]
  EditColor(CustomColor2,15,15,2); // pink [done]
  EditColor(CustomColor3,5,4,2); // purple [done] 10 8 5
  EditColor(CustomColor4,1,0,0); // "black" (i.e. dark grey) [done]
  EditColor(CustomColor5,4,15,1); // beige [done]
  EditColor(CustomColor6,4,4,0); // light yellow [done]
  EditColor(CustomColor7,1,1,0); //brown [done]
  EditColor(CustomColor8,0,3,0); // army green [done]
  EditColor(CustomColor9,0,0,1); // grey-ish blue [done]
  
  cursor_x = 1;
  cursor_y = 4;
  
  cursor_on = true;
  cursor_time = millis();
  
  load_level();
}

// LOOP

void loop() {
  
  ClearSlate();
  
  draw_border();
  
  CheckButtonsPress();
  
  // Cursor movement
  
  if (Button_Up){
    if (cursor_y < 6){
      cursor_y++;
      Tone_Start(ToneC5, 50);
    }
    else{
      Tone_Start(ToneB4, 50);
    }
  }
  
  if (Button_Down){
    if (cursor_y > 1){
      cursor_y--;
      Tone_Start(ToneC5, 50);
    }
    else{
      Tone_Start(ToneB4, 50);
    }
  }
  
  if (Button_Right){
    if (cursor_x < 6){
      cursor_x++;
      Tone_Start(ToneC5, 50);
    }
    else{
      Tone_Start(ToneB4, 50);
    }
  }
  
  if (Button_Left){
    if (cursor_x > 1){
      cursor_x--;
      Tone_Start(ToneC5, 50);
    }
    else{
      Tone_Start(ToneB4, 50);
    }
  }
  
  // Moving pieces
  
  if (Button_B){
    if (cursor_x == 6 && cursor_y == 4 && game_board[2][5] == 1){
      current_level++;
      if (current_level > number_of_levels){
        // User has won the entire game
        win_game();
      }
      else{
        // User has beaten the level
        next_level();
      }
    }
    else{
      move_piece(cursor_x-1, y_flip[cursor_y-1]);
    }
  }
  
  // Draw the game board
  
  byte x_i, y_i;
  
  for (y_i = 0; y_i < 6; y_i++) {
    for (x_i = 0; x_i < 6; x_i++) {
      DrawPx(x_i+1, y_flip[y_i]+1, game_board[y_i][x_i]);
    }
  }
  
  // Draw the cursor and handle blinking
  if ((millis() - cursor_time) > cursor_blink_delay){
    cursor_on = !cursor_on;
    cursor_time = millis();
  }
  if (cursor_on == true){
    DrawPx(cursor_x, cursor_y, cursor_colour);
  }
  
  // Write to the LED matrix
  
  DisplaySlate();
  
}

// NEXT_LEVEL
// Lets the user know they've beaten the current level and loads the next level
void next_level(){
  ClearSlate();
  
  DrawPx(0,2,4);
  DrawPx(0,3,4);
  DrawPx(1,1,4);
  DrawPx(1,2,4);
  DrawPx(2,0,4);
  DrawPx(2,1,4);
  DrawPx(3,1,4);
  DrawPx(3,2,4);
  DrawPx(4,2,4);
  DrawPx(4,3,4);
  DrawPx(5,3,4);
  DrawPx(5,4,4);
  DrawPx(6,4,4);
  DrawPx(6,5,4);
  DrawPx(7,5,4);
  DrawPx(7,6,4);
  
  DisplaySlate();
  
  int unit = 150;
  
  Tone_Start(ToneC5, unit);
  while (MakingSound) {}
  delay(50);
  Tone_Start(ToneC5, unit);
  while (MakingSound) {}
  delay(50);
  Tone_Start(ToneD5, unit);
  while (MakingSound) {}
  delay(50);
  Tone_Start(ToneE5, unit);
  while (MakingSound) {}
  delay(50);
  Tone_Start(ToneF5, 2*unit);
  while (MakingSound) {}
  delay(100);
  
  Tone_Start(ToneDs5, unit);
  while (MakingSound) {}
  delay(50);
  Tone_Start(ToneC5, unit);
  while (MakingSound) {}
  delay(50);
  Tone_Start(ToneDs5, unit);
  while (MakingSound) {}
  delay(50);
  Tone_Start(ToneC5, unit);
  while (MakingSound) {}
  delay(50);
  Tone_Start(ToneDs5, unit);
  while (MakingSound) {}
  delay(50);
  Tone_Start(ToneF5, 2*unit);
  while (MakingSound) {}
  delay(100);
  
  cursor_x = 1;
  cursor_y = 4;
  load_level();
}

// WIN_GAME
// Lets the user know they've beaten all the levels and resets the game
void win_game(){
  current_level = 1;
  
  byte red_to_use = 8;
  byte yellow_to_use = 3;
  
  ClearSlate();
  
  DrawPx(0,0,red_to_use);
  DrawPx(1,0,red_to_use);
  DrawPx(2,0,red_to_use);
  DrawPx(3,0,red_to_use);
  DrawPx(4,0,red_to_use);
  DrawPx(5,0,red_to_use);
  DrawPx(6,0,red_to_use);
  DrawPx(7,0,red_to_use);
  
  DrawPx(0,1,red_to_use);
  DrawPx(1,1,red_to_use);
  DrawPx(2,1,yellow_to_use);
  DrawPx(3,1,yellow_to_use);
  DrawPx(4,1,yellow_to_use);
  DrawPx(5,1,yellow_to_use);
  DrawPx(6,1,red_to_use);
  DrawPx(7,1,red_to_use);
  
  DrawPx(0,2,red_to_use);
  DrawPx(1,2,yellow_to_use);
  DrawPx(2,2,yellow_to_use);
  DrawPx(3,2,7);
  DrawPx(4,2,7);
  DrawPx(5,2,yellow_to_use);
  DrawPx(6,2,yellow_to_use);
  DrawPx(7,2,red_to_use);
  
  DrawPx(0,3,red_to_use);
  DrawPx(1,3,yellow_to_use);
  DrawPx(2,3,7);
  DrawPx(3,3,7);
  DrawPx(4,3,7);
  DrawPx(5,3,7);
  DrawPx(6,3,yellow_to_use);
  DrawPx(7,3,red_to_use);
  
  DrawPx(0,4,red_to_use);
  DrawPx(1,4,yellow_to_use);
  DrawPx(2,4,yellow_to_use);
  DrawPx(3,4,yellow_to_use);
  DrawPx(4,4,yellow_to_use);
  DrawPx(5,4,yellow_to_use);
  DrawPx(6,4,yellow_to_use);
  DrawPx(7,4,red_to_use);
  
  DrawPx(0,5,red_to_use);
  DrawPx(1,5,yellow_to_use);
  DrawPx(2,5,0);
  DrawPx(3,5,yellow_to_use);
  DrawPx(4,5,yellow_to_use);
  DrawPx(5,5,0);
  DrawPx(6,5,yellow_to_use);
  DrawPx(7,5,red_to_use);
  
  DrawPx(0,6,red_to_use);
  DrawPx(1,6,red_to_use);
  DrawPx(2,6,yellow_to_use);
  DrawPx(3,6,yellow_to_use);
  DrawPx(4,6,yellow_to_use);
  DrawPx(5,6,yellow_to_use);
  DrawPx(6,6,red_to_use);
  DrawPx(7,6,red_to_use);
  
  DrawPx(0,7,red_to_use);
  DrawPx(1,7,red_to_use);
  DrawPx(2,7,red_to_use);
  DrawPx(3,7,red_to_use);
  DrawPx(4,7,red_to_use);
  DrawPx(5,7,red_to_use);
  DrawPx(6,7,red_to_use);
  DrawPx(7,7,red_to_use);
  
  DisplaySlate();
  
  int unit = 250;
  
  Tone_Start(ToneC5, 0.75*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneG4, 1.25*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneE4, 0.75*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneD4, 1.25*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneD4, 0.75*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneA4, 1.25*unit);
  while (MakingSound) {};
  delay(100);
  
  Tone_Start(ToneG4, unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneA4, 0.5*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneG4, 1.5*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneF4, 1.5*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneE4, 1.5*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneF4, 0.8*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneG4, 1.5*unit);
  while (MakingSound) {};
  delay(100);
  
  Tone_Start(ToneE5, 1.27*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneD5, 0.43*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneC5, 0.54*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneB4, 0.48*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneC5, 1.21*unit); //0.95
  while (MakingSound) {};
  delay(50); // 0.28
  Tone_Start(ToneC5, 1.21*unit); // 0.95
  while (MakingSound) {};
  delay(50); // 0.28
  Tone_Start(ToneC5, 0.69*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneA4, 1.35*unit);
  while (MakingSound) {};
  delay(100);
  
  Tone_Start(ToneG4, 1.26*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneG4, 1.26*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneD5, 0.77*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneC5, 0.39*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneB4, 0.75*unit);
  while (MakingSound) {};
  delay(50);
  Tone_Start(ToneC5, 2.49*unit);
  while (MakingSound) {};
  delay(100);
  
  cursor_x = 1;
  cursor_y = 4;
  load_level();
}

// LOAD LEVEL
// Loads the level given by value of the "current_level" variable
void load_level(){
  byte x_i, y_i;
  for (y_i = 0; y_i < 6; y_i++) {
    for (x_i = 0; x_i < 6; x_i++) {
      game_board[y_i][x_i] = level_list[current_level-1][y_i][x_i];
    }
  }
}

// FIND_ORIENTATION
// Determines the orientation (horizontal or vertical) of a piece
byte find_orientation(byte x, byte y, byte piece_colour){
  byte orientation;
  boolean left = false;
  boolean right = false;
  boolean above = false;
  boolean below = false;
  
  // Check the left
  if (x > 0){
    if (game_board[y][x-1] == piece_colour){
      left = true;
    }
  }
  
  // Check the right
  if (x < 5){
    if (game_board[y][x+1] == piece_colour){
      right = true;
    }
  }
  
  // Check below
  if (y < 5){
    if (game_board[y+1][x] == piece_colour){
      below = true;
    }
  }
  
  // Check above
  if (y > 0){
    if (game_board[y-1][x] == piece_colour){
      above = true;
    }
  }
  
  if (left || right){
    orientation = horizontal;
  }
  else if (above || below){
    orientation = vertical;
  }
  
  return orientation;
}

// CHECK_SPACE
// Checks that there's a space next to the part of the piece the cursor is over along the
// axis of the piece. This weeds out cases where there's no space, the piece is against a
// wall, or the cursor is in the middle of the piece.
byte check_space(byte x, byte y, byte orientation){
  byte space_available = space_none;
  
  if (orientation == horizontal){
    if (x > 0){
      if (game_board[y][x-1] == 0){
        space_available = space_left;
      }
    }
    if (x < 5){
      if (game_board[y][x+1] == 0){
        space_available = space_right;
      }
    }
  }
  else if (orientation == vertical){
    if (y > 0){
      if (game_board[y-1][x] == 0){
        space_available = space_above;
      }
    }
    if (y < 5){
      if (game_board[y+1][x] == 0){
        space_available = space_below;
      }
    }
  }
  
  return space_available;
  
}

// MOVE_PIECE
// Moves a piece, if the cursor's over one end of the piece and the piece can be moved

// 1. Check orientation
// 2. Check that there's a space along the axis of the piece (given by orientation)
// next to the part of the piece the cursor is over
// 3. Get the position of the end of the piece the cursor isn't over
// 

void move_piece(byte x, byte y){
  byte piece_colour = game_board[y][x];
  if (piece_colour == 0){
    // No piece present
    Tone_Start(ToneC3, 50);
  }
  else{
    byte orientation = find_orientation(x,y,piece_colour);
    byte space = check_space(x,y,orientation);
    if (space == space_none){
      // No spaces or cursor not at the end of a piece
      Tone_Start(ToneE3, 50);
    }
    else{
      // Move the piece (i.e. switch the end of the piece the cursor's not on and the space
      if (space == space_left){
        if (game_board[y][x+2] == piece_colour){
          // It's a truck
          game_board[y][x-1] = piece_colour;
          game_board[y][x+2] = 0;
        }
        else if (game_board[y][x+1] == piece_colour){
          // It's car
          game_board[y][x-1] = piece_colour;
          game_board[y][x+1] = 0;
        }
        cursor_x--;
      }
      else if (space == space_right){
        if (game_board[y][x-2] == piece_colour){
          // It's a truck
          game_board[y][x+1] = piece_colour;
          game_board[y][x-2] = 0;
        }
        else if (game_board[y][x-1] == piece_colour){
          // It's car
          game_board[y][x+1] = piece_colour;
          game_board[y][x-1] = 0;
        }
        cursor_x++;
      }
      else if (space == space_above){
        if (game_board[y+2][x] == piece_colour){
          // It's a truck
          game_board[y-1][x] = piece_colour;
          game_board[y+2][x] = 0;
        }
        else if (game_board[y+1][x] == piece_colour){
          // It's car
          game_board[y-1][x] = piece_colour;
          game_board[y+1][x] = 0;
        }
        cursor_y++;
      }
      else if (space == space_below){
        if (game_board[y-2][x] == piece_colour){
          // It's a truck
          game_board[y+1][x] = piece_colour;
          game_board[y-2][x] = 0;
        }
        else if (game_board[y-1][x] == piece_colour){
          // It's car
          game_board[y+1][x] = piece_colour;
          game_board[y-1][x] = 0;
        }
        cursor_y--;
      }
      Tone_Start(ToneE5, 50);
    }
  }
}

// DRAW_BORDER

void draw_border(){
  byte i;
  for (i=0;i<8;i++){
    DrawPx(i,0,border_colour);
  }
  for (i=0;i<8;i++){
    DrawPx(0,i,border_colour);
  }
  for (i=0;i<8;i++){
    DrawPx(i,7,border_colour);
  }
  for (i=0;i<8;i++){
    DrawPx(7,i,border_colour);
  }
  DrawPx(7,4,0); // Gap for the red car to "exit" through
}
