/*

NP: Changed colours to RED and YELLOW players, added sound.

MeggyFour --
Version: 0.01
Author: Justin Shaw wyojustin@gmail.com
http://WyoInnovation.blogspot.com

Object: get four checkers in a row by dropping checkers down shoots.

Controls
Left/Right -- Move piece left and right
B          -- Change level (0-5) indicated by aux leds
A          -- Start over

TODO:
 Improve computer moves
 Add Sound?

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

#define MAX_SCORE     4096

// Create global variables & constants:
byte xc, yc;             // Define two 8-bit unsigned variables for cursor position ('xc' and 'yc').
unsigned long loop_counter = 0;
boolean player, player_start, sound;
byte depth = 0, n_move;
byte player_colors[] = {
  Red, Yellow, Dark};        // NP: Changed colour, added 3rd item for flash at game over
boolean game_over;
byte cols[7], rows[7];

int tune_win[]  = {ToneG4,ToneA5,ToneB5,ToneA5,ToneC6,ToneD6,0};
int tune_lose[] = {ToneG4,ToneE4,ToneF4,ToneE4,ToneD4,ToneC4,ToneC4,0};  
byte tune_note; // Which note of the tune is currently being played

void setup(){
  MeggyJrSimpleSetup();

  ClearSlate();              // Erase the screen
  Serial.begin(19200);
  Serial.println("MeggyFour: Debug");
  randomSeed(analogRead(0));

  xc = 7;                    // Set initial cursor position to 7, 6.
  yc = 6;                    // yc is always 6 for this game
  player_start = 0;          // either 0 or 1, 0 goes first
  player = player_start;
  draw_splash();             
  draw_board();
  game_over = false;
  depth = 4;
  n_move = 1;                // Number of moves, increments each time next_player() is called
  tune_note = 0;
  sound = true;
  update_auxleds();
}

void loop(){   
  CheckButtonsPress();
  if(Button_A){              // New game
    player_start = !player_start; // toggle who starts for each new game
    player = player_start;
    game_over = false;
    clear_board();           // NP: Clear the screen line by line
    draw_board();            // Setup a new board
  }
  if (Button_Up)             // Toggle sound on/off
  {    
    sound = !sound;
    if (sound) { Tone_Start(ToneC5, 30); }  // NP
    update_auxleds();
  }


  if(game_over){
    DrawPx(xc, yc, Dark);    // Clear the cursor
    flash_four();            // Continues until user presses A button
    if (player == 1) {       // Human wins
      if (sound && tune_win[tune_note] != 0) {
        Tone_Start(tune_win[tune_note], 100);
        tune_note++;
      }
    }
    else {
      if (sound && tune_lose[tune_note] != 0) {
        Tone_Start(tune_lose[tune_note], 100);
        tune_note++;
      }
    }  
  }
  else if(player == 0){
    player_move();
  }
  else{
    computer_move();
  }
  loop_counter++;
}

void blink_player(){
  // Blink the player off and on

  if(loop_counter % (1000) < 700){  // on 70% of the time
    DrawPx(xc, yc, player_colors[player]);
  }
  else{
    DrawPx(xc, yc, Dark);
  }
}

void draw_splash(void){
  int i, j, d;
  d = 45;
  for(j = 0; j < 8; j++){
    d = d - 5;
    for(i = 0; i < 8; i++){
      DrawPx(i, j, player_colors[0]);
      DrawPx(7 - i, 7 - j, player_colors[1]);
      DisplaySlate();
      delay(d);
    }
  }
  delay(500);
  flashscreen(4, 100);
}

void flashscreen(int n, int ms){
  /* 
  Flash the screen on and off
  n -- number of times to flash
  ms -- millis to delay betwen flasheds
  */
  byte save_screen[64];
  byte count, i, j;

  for(count = 0; count < n; count ++){
    for(j = 0; j < 8; j++){
      for(i = 0; i < 8; i++){
        save_screen[8 * j + i] = ReadPx(i, j);
        DrawPx(i, j, Dark);
      }
    }
    DisplaySlate();      
    delay(ms);
    for(j = 0; j < 8; j++){
      for(i = 0; i < 8; i++){
        DrawPx(i, j, save_screen[8 * j + i]);
      }
    }
    DisplaySlate();
    delay(ms);
  }
}


void clear_board(){
  /*
  Slowly clear the board line by line when starting a new game
  */
  int wait = 50;
  byte i, j;
  for(j = 7; j > 0; j--){
    for(i = 0; i < 8; i++){
      DrawPx(i, j, Dark);
    }
    if (sound) {
      Tone_Start( ToneF5 + (((ToneA5-ToneF5)/7)*j), 30); // NP range of tones as it clears the screen
    }

    DisplaySlate();
    delay(wait);
  }
}

void draw_board(){
  /*
  Draw white line along left and top.
  The actual board is 7 checkers long by 6 high.  
  You need an additional row to move a piece around.
  */
  byte i;
  byte board[64];
  for(i = 0; i < 64; i++){
    board[i] = Dark;
  }
  for(i = 0; i < 8; i++){
    board[8 * 7 + i] = White;
    board[8 * i] = White;
  }
  swipe_image(board);
}

void swipe_image(byte* new_image){
  /*
  Swipe a new image over the old.
  */
  int wait = 25;
  byte i, j;
  for(j = 0; j < 8; j++){
    for(i = 0; i < 8; i++){
      DrawPx(i, j, new_image[8 * j + i]);
    }
    DisplaySlate();
    delay(wait);
  }
}

void heavy(){
  /*
  Drop a piece of the current color down the xc column.
  */
  int row, wait = 50;

  row = yc;
  // check to see if col is full
  if(ReadPx(xc, 5) == Dark){
    for(row = 5; ((ReadPx(xc, row) == Dark) && (row >= 0)); row--){  // NP: added "&& (row > 0)"
      DrawPx(xc, row + 1, Dark);
      DrawPx(xc, row, player_colors[player]);
      DisplaySlate();
      delay(wait);
    }
    row++;
    game_over = check_four(xc, row);

    if (game_over) {
      tune_note = 0;                          // reset the music
      Serial.print("Game Over: Player = ");
      Serial.println((int) player);
    }

    next_player();
  }
}

void next_player(){
  /*
  Toggle players
  */
  n_move++;
  if(player == 0){
    player = 1;
  }
  else{
    player = 0;
  }
}

boolean check_four(byte i, byte j){
  /*
  Check to see if the piece at col i, row j is part of a connect four.
  Fill in global vars cols[4] and rows[4] so that they can be flashed on and off.
  -- See flash_four()
  */
  byte in_a_row;  // number of pieces in a row in a given direction
  byte  color = ReadPx(i, j);
  boolean out = false;
  int row, col;

  if(out == false){
    // check collumn
    cols[0] = i;
    rows[0] = j;
    in_a_row = 1;
    for(row = j - 1; row >= 0; row--){
      if(ReadPx(i, row) == color){
        cols[in_a_row] = i;
        rows[in_a_row] = row;
        in_a_row++;
      }
      else{
        break;
      }
    }
    if(in_a_row > 3){
      out = true;
    }
  }

  if(out == false){
    // check row
    cols[0] = i;
    rows[0] = j;
    in_a_row = 1;
    for(col = i - 1; col >= 0; col--){
      if(ReadPx(col, j) == color){
        cols[in_a_row] = col;
        rows[in_a_row] = j;
        in_a_row++;
      }
      else{
        break;
      }
    }
    for(col = i + 1; col <  8; col++){
      if(ReadPx(col, j) == color){
        cols[in_a_row] = col;
        rows[in_a_row] = j;
        in_a_row++;
      }
      else{
        break;
      }
    }
    if(in_a_row > 3){
      out = true;
    }
  }

  if(out == false){
    cols[0] = i;
    rows[0] = j;
    in_a_row = 1;
    // lower left to upper right
    for(col = i - 1, row = j - 1; col >= 1 && row >= 0; col--, row--){
      if(ReadPx(col, row) == color){
        cols[in_a_row] = col;
        rows[in_a_row] = row;
        in_a_row++;
      }
      else{
        break;
      }
    }
    for(col = i + 1, row = j + 1; col <= 7 && row <= 6; col++, row++){
      if(ReadPx(col, row) == color){
        cols[in_a_row] = col;
        rows[in_a_row] = row;
        in_a_row++;
      }
      else{
        break;
      }

    }
    if(in_a_row > 3){
      out = true;
    }    
  }
  if(out == false){
    cols[0] = i;
    rows[0] = j;
    in_a_row = 1;
    // lower right to upper left
    for(col = i - 1, row = j + 1; col >= 1 && row <= 6; col--, row++){
      if(ReadPx(col, row) == color){
        cols[in_a_row] = col;
        rows[in_a_row] = row;
        in_a_row++;
      }
      else{
        break;
      }
    }
    for(col = i + 1, row = j - 1; col <= 7 && row >= 0; col++, row--){
      if(ReadPx(col, row) == color){
        cols[in_a_row] = col;
        rows[in_a_row] = row;
        in_a_row++;
      }
      else{
        break;
      }
    }
    if(in_a_row > 3){
      out = true;
    }    
  }

  return out;
}

void flash_four(){
  /*
  Flash four pieces spaces give by global vars cols[4] and rows[4]
  */
  byte save[4];
  byte i;

  for(i = 0; i < 4; i++){
    save[i] = ReadPx(cols[i], rows[i]);
    DrawPx(cols[i], rows[i], player_colors[2]);
  }
  DisplaySlate();
  delay(100);

  for(i = 0; i < 4; i++){
    DrawPx(cols[i], rows[i], save[i]);
  }
  DisplaySlate();
  delay(100);
}

void player_move(){
  /*
  Respond to user input:
  -- check of right/left and down button presses
  */
  if (Button_B) // Increase difficulty level
  { 
    depth++;
    if(depth == 6){
      depth = 0;
    }
    update_auxleds();

    if (sound) {
      Tone_Start( ToneF5 + (((ToneA5-ToneF5)/6)*depth), 50); // NP play a higher tone for higher levels
    }
  }

  if (Button_Down)       // Move Cursor Down
  {
    heavy();    
    if (sound) {
      Tone_Start(ToneD5, 20);  // NP
    }
  }

  if (Button_Right)       // Move Cursor Right
  {
    if(xc < 7){
      DrawPx(xc,yc,Dark);      // Write "real" color to current pixel in the game buffer.
      xc = (xc + 1) % 8;
      if (sound) { Tone_Start(ToneC5, 20); }  // NP
    }
  }

  if (Button_Left)       // Move Cursor Left 
  {    
    if(xc > 1){    
      DrawPx(xc,yc, Dark);
      xc = (xc - 1) % 8;
      if (sound) { Tone_Start(ToneC5, 20); }  // NP
    }
  }
  blink_player();
  DisplaySlate();      // Write the updated game buffer to the screen.
}

void computer_move(void){
  /*
  Find a good move for computer player.  Needs work, some more randomness.
  */
  byte col;
  int scores[8];
  int max_score;

  Serial.println("computer_move()");

  if(n_move < 1){             // If first move perform the following animation before dropping at a random location
    Serial.println(" - First move (n_move < 1)");
    col = random(1, 8);
    for(; xc > 1; xc--){      // Move counter to the left
      DrawPx(xc, yc, Dark);
      DrawPx(xc - 1, yc, player_colors[player]);
      DisplaySlate();
      delay(100);
    }
    for(; xc != col; xc++){  // Then move to the right to random position
      DrawPx(xc, yc, Dark);
      DrawPx(xc + 1, yc, player_colors[player]);
      DisplaySlate();
      delay(100);
    }
  }
  else
  {
    // Move to left column animation
    for(; xc > 1; xc--){
      DrawPx(xc, yc, Dark);
      DrawPx(xc - 1, yc, player_colors[player]);
      DisplaySlate();
      delay(100);
    }

    // Move to the right and get scores at each point
    Serial.print(" - Scores L2R: ");
    max_score = -1;
    for(; xc < 8; xc++){
      scores[xc] = getScore(xc, depth); // returns -1 if invalid, hence will not be selected later
      if (scores[xc] > -1) {
        scores[xc] += 4 - abs(4 - xc); // load an array with the score at each column
      }  
      Serial.print((int) scores[xc]);
      Serial.print(" ");
      if(scores[xc] > max_score){
        max_score = scores[xc];                            // update max score
        if(max_score == MAX_SCORE + 4 - abs(4 - xc)){      // decision to break early based on weighting for center column
          Serial.println(" - (break) computer found winning location");
          break;
        }
      }
      DrawPx(xc, yc, Dark);
      DrawPx(xc + 1, yc, player_colors[player]);
      DisplaySlate();
    }
    DrawPx(xc, yc, player_colors[player]);

    Serial.print(" - End move right. max_score = ");
    Serial.println((int) max_score);

    // move left to highest scoring column
    for(; xc > 0; xc--){
      if(scores[xc] == max_score){
        break;
      }
      DrawPx(xc, yc, Dark);
      DrawPx(xc - 1, yc, player_colors[player]);
      DisplaySlate();
      delay(50);
    }
  }
  
  // drop the piece.
  heavy();
}

int getScore(byte col, byte depth){
  /*
  Score column, higher is better, neg -> illegal
  Needs work.
  */
  int score = 0, opp_scores[8], opp_max_score, r, c;
  byte row, low_row, opp_col, in_a_row;

  // check of legal move
  if(ReadPx(col, 5) != Dark){
    score = -1;
  }
  else
  {
    // find lowest empty row for this column
    for(row = 0; row <= 6; row++){
      if(ReadPx(col, row) == Dark){
        break;
      }
    }

    // check for winning move
    // temp set px to current player color
    // but don't display it (test score for this column)
    DrawPx(col, row, player_colors[player]);

    // If 4 in a row then set to max_score
    if(check_four(col, row)){
      score = MAX_SCORE;
    }

    // Fix up game board (clear the test pixel)
    DrawPx(col, row, Dark);

    if(score < MAX_SCORE){
      if(depth == 0){ // Easiest level
        // add up same color in the area
        score = 0;
        for(r = row - 1; r <= row + 1; r++){
          for(c = col - 1; c <= col + 1; c++){
            if(c > 0 && c < 8){
              if(r >= 0 && r < 6){
                score += ReadPx(r, c);
              }
            }
          }
        } 
      }
      else{
        // Check opponents max score if we play here
        DrawPx(col, row, player_colors[player]);
        player = !player;

        opp_max_score = -MAX_SCORE;
        for(opp_col = 1; opp_col < 8; opp_col++){
          opp_scores[opp_col] = getScore(opp_col, depth - 1); // note recursive!!
          if(opp_scores[opp_col] > opp_max_score){
            opp_max_score = opp_scores[opp_col];
            if(opp_max_score == MAX_SCORE){
              break;
            }
          }
        }

        // fix up game board
        DrawPx(col, row, Dark);
        player = !player;
        score = (MAX_SCORE - opp_max_score)/2;
      }
    }
  }
  return score;
}

void update_auxleds() {
  Meg.AuxLEDs = 1 << depth;      // level indicator
  if (sound) Meg.AuxLEDs += 128; // set D7 if sound enabled
}

