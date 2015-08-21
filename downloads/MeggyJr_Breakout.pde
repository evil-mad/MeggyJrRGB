
/*
  MeggyJr_Breakout.pde
 
  Using the The Meggy Jr Simplified Library (MJSL)
  from the Meggy Jr RGB library for Arduino
   
  Simple breakout clone
  Version 1.00 - 04/8/2009
  Copyright (c) 2009 Edward Hutchins

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

#include <MeggyJrSimple.h>    // Meggy Jr simple library.  Required.

static const byte WIDTH = 8;
static const byte HEIGHT = 8;
static const byte PADDLE_CEILING = 3;
static const byte BRICK_ROWS = 3;
static const byte FRAME_TIME = 30;

byte px, py;                   // paddle location in pixels
byte pw;                       // paddle width in pixels

char bx, by;                   // ball position in s4.3 format (signed with 3 fraction bits, 1.0 is B00001000)
char dbx, dby;                 // ball velocity in s4.3 format
byte ball_delay;               // 0 == ball in play, non-zero == waiting for next ball
byte balls_left;               // number of balls left to play

byte bricks[BRICK_ROWS];       // rows of 8 bricks
byte brick_color[BRICK_ROWS];  // color of each row
byte bricks_left;              // number of bricks left to get
byte level;                    // difficulty level

// note durations
typedef enum
{
	NoteEnd = 0,
	Note16th,
	Note8th,
	NoteQtr,
	NoteHalf,
	NoteWhole
} NoteDuration;

// note description
struct Note
{
	unsigned int tone;		   // Tone value
	NoteDuration duration;	   // how long to play
};

Note *song = 0;				   // currently playing song
byte tempo = 1;				   // refreshes for a 16th note
byte note;					   // current note in song
char next_note = 0;			   // refreshes till next note

// charge theme for starting the game
Note song_charge[] = 
{
	{ ToneC4, Note8th },
	{ ToneF5, Note8th },
	{ ToneA5, Note8th },
	{ ToneC6, NoteQtr },
	{ ToneA5, Note8th },
	{ ToneC6, NoteHalf },
	{ 0, NoteEnd }
};

// theme for getting a new ball
Note song_newball[] = 
{
	{ ToneD7, Note16th },
	{ ToneB7, Note16th },
	{ ToneD7, Note16th },
	{ ToneB7, Note16th },
	{ ToneD7, Note16th },
	{ 0, NoteEnd }
};

// theme for next level
Note song_nextlevel[] = 
{
	{ ToneG6, Note8th },
	{ ToneA7, Note8th },
	{ ToneB7, Note8th },
	{ ToneA7, Note8th },
	{ ToneG6, Note8th },
	{ 0, NoteEnd }
};

//
// clampS4_3 - clamp a s4.3 fractional number such that abs(x) < 1.0
//

static inline char clampS4_3( char x )
{
	if (x < -7) x = -7;
	else if (x > 7) x = 7;
	return( x );
}

//
// play_song - start a specified song playing in the background
//

void play_song( struct Note *song_to_play )
{
	song = song_to_play;
	note = 0;
	next_note = 0;
}

//
// new_ball - setup a random start position for the ball and start the delay
//

void new_ball()
{
	// ball delay is a bitmask that shifts one bit at a time till the mask is zero
	ball_delay = 0xff;
	SetAuxLEDs( ball_delay );

	bx = random( 8 ) * 8 + 4;
	by = 4 * 8 + 4;
	// pick a random side-to-side direction
	dbx = clampS4_3( random( 5 + 2 * level ) - (2 + level) );
	// always start the ball moving downwards
	// harder levels make the ball potentially faster
	dby = clampS4_3( -(random( 1 + level ) + 1) );
}

//
// next_level - reset the bricks and advance to the next level
//

void next_level()
{
	++level;

	bricks_left = 0;
	for (byte i = 0; i < BRICK_ROWS; ++i)
	{
		bricks[i] = 0xff;
		bricks_left += 8;
		brick_color[i] = Red + (level & 1) + 2 * i;
	}

	// start the level with a new ball location
	new_ball();
}

//
// new_game - start a new game up
//

void new_game()
{
	pw = 3;
	px = (WIDTH - pw) / 2;
	py = 0;

	level = 0;
	balls_left = 3;
	next_level();
	
	play_song( song_charge );
}

//
// setup - main entrypoint to initialize everything
//

void setup()
{
	// Required code.  initialized meggy's business.
	MeggyJrSimpleSetup();

	// setup the random number generator
	randomSeed( 0xaced );

	// start a new game
	new_game();
}

//
// loop - main loop, handle all events and draw things
//

void loop()
{
	//
	// play background songs
	//

	if (song && (--next_note <= 0))
	{
		if (song[note].duration == NoteEnd)
		{
			song = 0;
		}
		else // play the note
		{
			next_note = tempo << song[note].duration;
			Tone_Start( song[note].tone, FRAME_TIME * (next_note - 1) );
			++note;
		}
	}

	//
	// check the buttons and move the paddle
	//

	CheckButtonsDown();

	char dpx = 0;
	char dpy = 0;

	if (Button_Left)	dpx -= (px > 0);
	if (Button_Right)	dpx += ((px + pw) < WIDTH);
	if (Button_Down)	dpy -= (py > 0);
	if (Button_Up)		dpy += (py < PADDLE_CEILING);

	if (Button_A)
	{
		//Tone_Start( ToneD4, FRAME_TIME );
	}

	if (Button_B)
	{
		//Tone_Start( ToneC4, FRAME_TIME );
	}

	// move the paddle position
	px += dpx;
	py += dpy;

	//
	// move the ball and check for collisions
	//

	if (ball_delay)
	{
		ball_delay >>= 1;
		SetAuxLEDs( ball_delay ? ball_delay : (1 << balls_left) - 1 );
		//Tone_Start( ToneD3 + int(ball_delay) * 50, FRAME_TIME );
	}
	else if (next_note > 0)
	{
		// freeze the game while a song is playing
	}
	else // ball is in play
	{
		// move the ball and check for the edges of the screen
		bx += dbx;
		if ((bx < 0) || (bx >= WIDTH << 3))
		{
			dbx = -dbx;
			bx += dbx;
			Tone_Start( ToneD5, FRAME_TIME );
		}

		by += dby;
		if (by >= HEIGHT << 3)
		{
			dby = -dby;
			by += dby;
			Tone_Start( ToneD5, FRAME_TIME );
		}
		else if (by < 0)
		{
			// off the bottom, lose a ball!
			if (--balls_left <= 0)
			{
				new_game();
			}
			else
			{
				new_ball();
				play_song( song_newball );
			}
		}

		// convert paddle coordinates into ball coordinates (S4.3)
		char px0 = px << 3;
		char px1 = (px + pw) << 3;
		char pym = (py << 3) + 4;
		// figure out the vertical footprint, accounting for maximum ball and paddle velocity
		char adby = (dby > 0) ? dby : -dby;
		char py0 = pym - adby + ((dpy < 0) ? (dpy << 3) : 0);
		char py1 = pym + adby + ((dpy > 0) ? (dpy << 3) : 0);

		// is the ball inside the paddle?
		if ((bx >= px0) && (bx < px1) && (by >= py0) && (by < py1))
		{
			// add some "english" based on paddle movement, and a little randomness
			dby = clampS4_3( dby + dpy );
			dbx = clampS4_3( dbx + dpx + random( 3 ) - 1 );

			// avoid the boring "y velocity == 0" case
			if (dby == 0)
			{
				dby = (by >= pym) ? 1 : -1;
			}
			else if (((by >= pym) && (dby < 0)) || (dby > 0))
			{
				// make sure we bounce away from the middle of the paddle
				dby = -dby;
				Tone_Start( ToneG5, FRAME_TIME );
			}
		}

		// is the ball inside a block?
		if (by >= ((HEIGHT - BRICK_ROWS) << 3))
		{
			char row = (HEIGHT - 1) - (by >> 3);
			char col = bx >> 3;
			if ((bricks[row] >> col) & 1)
			{
				dby = -dby;
				bricks[row] &= ~(1 << col);
				if (--bricks_left <= 0)
				{
					next_level();
					// bonus, get an extra ball!
					++balls_left;
					play_song( song_nextlevel );
				}
				else Tone_Start( ToneF5, FRAME_TIME );
			}
		}
	}

	//
	// redraw everything
	//

	ClearSlate();

	// draw the ball anti-aliased
	// (i.e. shade in 4 LEDs based on the area of the ball over the LED)
	// compute the 4 LED coordinates centered on the fractional location
	char bx0 = (bx - 4) >> 3;
	char by0 = (by - 4) >> 3;
	char bx1 = bx0 + 1;
	char by1 = by0 + 1;
	// compute the fraction of each LED covered by the ball in x and y
	byte bxf1 = (bx - 4) & 7;
	byte byf1 = (by - 4) & 7;
	byte bxf0 = bxf1 ^ 7;
	byte byf0 = byf1 ^ 7;

	// light up each LED by computing the area (7 * 7 == max 49) and scaling (49 * 5 >> 4 == 15)
	if ((bx0 >= 0) && (by0 >= 0))
	{
		byte c = (bxf0 * byf0 * 5) >> 4;
		EditColor( CustomColor0, c, c, c );
		DrawPx( bx0, by0, CustomColor0 );
	}
	if ((bx1 < WIDTH) && (by0 >= 0))
	{
		byte c = (bxf1 * byf0 * 5) >> 4;
		EditColor( CustomColor1, c, c, c );
		DrawPx( bx1, by0, CustomColor1 );
	}
	if ((bx0 >= 0) && (by1 < HEIGHT))
	{
		byte c = (bxf0 * byf1 * 5) >> 4;
		EditColor( CustomColor2, c, c, c );
		DrawPx( bx0, by1, CustomColor2 );
	}
	if ((bx1 < WIDTH) && (by1 < HEIGHT))
	{
		byte c = (bxf1 * byf1 * 5) >> 4;
		EditColor( CustomColor3, c, c, c );
		DrawPx( bx1, by1, CustomColor3 );
	}

	// draw the bricks
	for (byte i = 0; i < BRICK_ROWS; ++i)
	{
		for (byte x = 0; x < 8; ++x)
		{
			if ((bricks[i] >> x) & 1)
			DrawPx( x, HEIGHT - (1 + i), brick_color[i] );
		}
	}

	// draw the paddle
	for (byte x = px; x < px + pw; ++x)
		DrawPx( x, py, Green );                                                                                                                                                  

	DisplaySlate();

	delay( FRAME_TIME );
}
