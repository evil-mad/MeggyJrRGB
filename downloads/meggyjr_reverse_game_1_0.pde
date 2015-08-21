/*
meggyjr_reverse_game.pde

===== REVERSE GAME FOR THE MEGGY JR RGB =====
A Meggy Jr implementation of the 4 x 4 reversi-style game that's so popular
with the makers of various Flash escape-the-room games.
Copyright (c) 2009 Luke Gane. All rights reserved.
Version 1.0 - August 2009

=== HOW TO PLAY ===
Move the cursor around with the arrow buttons.
Press B to change the colour of the dot the cursor is over and the four dots above, below, to 
the left, and to the right of it.
Change all the dots from blue to orange to win (this can be done in six moves).
Upon winning, part of the Knight Rider theme is played.

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

// Defined constants
#define reverse_colour 9 // Colour of active dots
#define off_colour 13 // Colour of inactive dots
#define active_cursor 2 // Colour of cursor over active dot
#define inactive_cursor 5 // Colour of cursor over inactive dot
#define border_colour 7 // Colour of the border

// Cursor position (LED coordinates)
byte cursor_x, cursor_y; // Should be constrained between 2 and 5 inclusive.

// To convert from the C array "y axis" (down) to the LED y axis (up) and vice versa
int y_flip[4] = {3, 2, 1, 0};

// 2D array representing the game board
int play_area[4][4] = {off_colour, off_colour, off_colour, off_colour, 
off_colour, off_colour, off_colour, off_colour,
off_colour, off_colour, off_colour, off_colour,
off_colour, off_colour, off_colour, off_colour};

// SETUP

void setup() {
  MeggyJrSimpleSetup();
  
  cursor_x = 2;
  cursor_y = 2;
}

//REVERSE_ONE_PIXEL
// Reverses a pixel (x and y are in terms of the game board, 0-3, not the LED display)

void reverse_one_pixel(int x, int y) {
  if (play_area[y][x] == reverse_colour) {
    play_area[y][x] = off_colour;
  }
  else {
    play_area[y][x] = reverse_colour;
  }
}

// REVERSE_GROUP
// Reverses a group of pixels around the cursor (x and y are game board coordinates)

void reverse_group(byte x, byte y) {
  // Top dot
  if (y > 0) {
    reverse_one_pixel(x, y-1);
  }
  // Bottom dot
  if (y < 3) {
    reverse_one_pixel(x, y+1);
  }
  // Left dot
  if (x > 0) {
    reverse_one_pixel(x-1, y);
  }
  // Right dot
  if (x < 3) {
    reverse_one_pixel(x+1, y);
  }
  // Centre dot
  reverse_one_pixel(x, y);
}

// CHECK_FOR_WIN
// Checks the game area array to see if the end condition (all pixels reversed) has been satisfied

boolean check_for_win() {
  byte i, j;
  
  boolean game_won = true;
  
  for (i = 0; i < 4; i++) {
    for (j = 0; j < 4; j++) {
      if (play_area[i][j] == off_colour) {
        game_won = false;
      }
    }
  }
  
  return game_won;
}

// WIN_DISPLAY
// Lets the player know that they've won

void win_display() {
  //byte i;
  
  int unit = 125;
  
  Tone_Start(ToneG4,2*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneA4,1*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneG4,1*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneD5,4*unit);
  while (MakingSound) {}
  delay(50);
  
  Tone_Start(ToneG5,2*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneA5,1*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneG5,1*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneD5,4*unit);
  while (MakingSound) {}
  delay(50);
  
  Tone_Start(ToneG4,2*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneA4,1*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneG4,1*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneD5,2*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneG5,2*unit);
  while (MakingSound) {}
  delay(25);
  Tone_Start(ToneF5,4*unit);
  while (MakingSound) {}
  delay(50);
  
  /*int notes[8] = {ToneC4,ToneD4,ToneE4,ToneF4,ToneG4,ToneA4,ToneB4,ToneC5};
  
  for (i = 0; i < 8; i++) {
    Tone_Start(notes[i],100);
    while (MakingSound) {
      // Do nothing
    }
  }*/
}

// RESET_GAME
// Resets the game area

void reset_game() {
  byte i, j;
  
  for (i = 0; i < 4; i++) {
    for (j = 0; j < 4; j++) {
      play_area[i][j] = off_colour;
    }
  }
}

// LOOP

void loop() {
  
  ClearSlate();
  
  if (check_for_win()) {
    win_display();
    reset_game();
  }
  
  CheckButtonsPress();
  
  // Cursor Movement
  
  if (Button_Up) {
    if (cursor_y < 5){
      cursor_y++;
    }
    else {
      cursor_y = 2;
    }
    Tone_Start(ToneC5, 50);
  }
  
  if (Button_Down) {
    if (cursor_y > 2){
      cursor_y--;
    }
    else {
      cursor_y = 5;
    }
    Tone_Start(ToneC5, 50);
  }
  
  if (Button_Right) {
    if (cursor_x < 5){
      cursor_x++;
    }
    else {
      cursor_x = 2;
    }
    Tone_Start(ToneC5, 50);
  }
  
  if (Button_Left) {
    if (cursor_x > 2){
      cursor_x--;
    }
    else {
      cursor_x = 5;
    }
    Tone_Start(ToneC5, 50);
  }
  
  // Handle the reversing stuff
  
  if (Button_B) {
    reverse_group(cursor_x-2,y_flip[cursor_y-2]);
    Tone_Start(ToneC7, 50);
  }
  
  // Draw the game board
  
  byte x_i, y_i;
  
  for (y_i = 0; y_i < 4; y_i++) {
    for (x_i = 0; x_i < 4; x_i++) {
      DrawPx(x_i+2, y_flip[y_i]+2, play_area[y_i][x_i]);
    }
  }
  
  // Draw the cursor
  
  if (ReadPx(cursor_x,cursor_y) == reverse_colour){
    DrawPx(cursor_x,cursor_y,active_cursor);
  }
  else {
    DrawPx(cursor_x,cursor_y,inactive_cursor);
  }
  
  // Draw the border around the game area
  DrawPx(1,1,border_colour);
  DrawPx(1,2,border_colour);
  DrawPx(1,3,border_colour);
  DrawPx(1,4,border_colour);
  DrawPx(1,5,border_colour);
  DrawPx(1,6,border_colour);
  DrawPx(2,6,border_colour);
  DrawPx(3,6,border_colour);
  DrawPx(4,6,border_colour);
  DrawPx(5,6,border_colour);
  DrawPx(6,6,border_colour);
  DrawPx(6,5,border_colour);
  DrawPx(6,4,border_colour);
  DrawPx(6,3,border_colour);
  DrawPx(6,2,border_colour);
  DrawPx(6,1,border_colour);
  DrawPx(5,1,border_colour);
  DrawPx(4,1,border_colour);
  DrawPx(3,1,border_colour);
  DrawPx(2,1,border_colour);
  
  // Write everything to the LEDs
  
  DisplaySlate();
}
