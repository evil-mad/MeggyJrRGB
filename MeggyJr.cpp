/*
  MeggyJr.cpp - Meggy Jr RGB library for Arduino
 Version 1.5 - 12/31/2011
 Copyright (c) 2011 Windell H. Oskay.  All right reserved.
 
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
	
	Thanks to Arthur J. Dahm III and Jay Clegg for code written for the Peggy 2.0,
	which was adapted to make this library.  
	
*/

/******************************************************************************
 * Includes
 ******************************************************************************/
 
#include "MeggyJr.h" 

byte MeggyJr::MeggyFrame[DISP_BUFFER_SIZE];

static volatile byte MeggyJr::AuxLEDs;
byte MeggyJr::SoundAllowed;	 
byte MeggyJr::SoundEnabled;	

byte MeggyJr::currentCol;
byte MeggyJr::currentBrightness;
byte* MeggyJr::currentColPtr;
		 
//unsigned long MeggyJr::SoundStopTime;	

unsigned int MeggyJr::ToneTimeRemaining;

#ifdef timingtest
unsigned int MeggyJr::testTime;
#endif
	
/******************************************************************************
 * Constructor
 ******************************************************************************/

MeggyJr::MeggyJr(void)			
{
// Initialization routine for Meggy Jr RGB hardware

	AuxLEDs = 0;
	currentColPtr = MeggyFrame;
	currentCol=0;
	currentBrightness=0;
	
PORTC = 255U;	// Pull-ups on Port C  (for detecting button presses)
DDRC = 0;		//All inputs
  
DDRD = 254U;		// All D Output except for Rx
PORTD = 254U;	
		
DDRB = 63U;	
PORTB = 255;		

//If a button is pressed at startup, turn sound off.
 if ((PINC & 63) != 63)
{
  SoundAllowed = 0;
} 
else
{
  SoundAllowed = 1;
} 
   
   SoundEnabled = 0;
   
MeggyJr::ToneTimeRemaining = 0;
   
//Turn display off:
PORTD |= 252U;
PORTB |= 17U;

ClearMeggy();
  	 
SPSR = (1<<SPI2X); 
/*
//ENABLE SPI, MASTER, CLOCK RATE fck/4:	
SPCR = 80;// i.e., (1 << SPE) | ( 1 << MSTR ); 
 
SPDR = 0;
 while (!(SPSR & (1<<SPIF)))  { } // wait for last bitshift to complete
SPDR = 0;
 while (!(SPSR & (1<<SPIF)))  { } // wait for last bitshift to complete
SPDR = 0;
 while (!(SPSR & (1<<SPIF)))  { } // wait for last bitshift to complete
SPDR = 0;
 while (!(SPSR & (1<<SPIF)))  { } // wait for last bitshift to complete
 
PORTB |= 4;		//Latch Pulse    
PORTB &= 251;
*/
SPCR = 0; //turn off spi

// setup the interrupt.
TCCR2A = (1<<WGM21); // clear timer on compare match
TCCR2B = (1<<CS21); // timer uses main system clock with 1/8 prescale
OCR2A  = (F_CPU >> 3) / 8 / 15 / FPS; // Frames per second * 15 passes for brightness * 8 rows
TIMSK2 = (1<<OCIE2A);	// call interrupt on output compare match

sei( );    // Enable interrupts
	
	#ifdef timingtest
MeggyJr::testTime = 0;
#endif
	
	
}

/******************************************************************************
 * User API
 ******************************************************************************/
 
// Painfully Slow!  Don't use this, if you can avoid it:
void MeggyJr::ClearMeggy (void)
{
	for (byte i = 0; i < DISP_BUFFER_SIZE; i++)
	{ 
	    MeggyFrame[i]= 0;
	}
}
 
//Set Pixel Color:  use an RGB array to specify the color.
// Very convenient for using color look-up tables.
void MeggyJr::SetPxClr(byte x, byte y, byte *rgb)
{
  byte PixelPtr =  24*x + y;
  MeggyFrame[PixelPtr] = rgb[2];   
  PixelPtr += 8;
  MeggyFrame[PixelPtr] = rgb[1];
  PixelPtr += 8;
  MeggyFrame[PixelPtr] = rgb[0]; 
}
  
 
  
/* 
void MeggyJr::SoundCheck(void)   
  { 
 // Obsolete with current version of library; sounds stop automatically.
 // If your program contains "SoundCheck();" somewhere, please remove it.
}
*/  
   

// Begin sound 
void  MeggyJr::StartTone(unsigned int Tone, unsigned int duration)   
  {
  OCR1A = Tone;
  SoundState(1);
  MeggyJr::ToneTimeRemaining = duration;  
  }
    	
 
byte MeggyJr::GetPixelR(byte x, byte y)
{
  return MeggyFrame[24*x + y + 16]; 
}

byte MeggyJr::GetPixelG(byte x, byte y)
{
  return MeggyFrame[24*x + y + 8]; 
}

byte MeggyJr::GetPixelB(byte x, byte y)
{
  return MeggyFrame[24*x + y]; 
}

// Clear a single pixel.  Not much better than writing "dark" to the pixel.
void MeggyJr::ClearPixel(byte x, byte y)
{
byte PixelPtr =  24*x + y;
MeggyFrame[PixelPtr] = 0;   
PixelPtr += 8;
MeggyFrame[PixelPtr] = 0;
PixelPtr += 8;
MeggyFrame[PixelPtr] = 0; 
}

 
// GetButtons returns a byte with a bit set for 
// each of the buttons that is currently pressed.

byte MeggyJr::GetButtons(void)
{
  return (~(PINC) & 63U); 
}



// Set sound ON or OFF by calling
// SoundState(0) or SoundState(1).

void MeggyJr::SoundState(byte t)
{

if ((t) && (SoundAllowed))
	{ 
    
 		TCCR1A = 65;	// 0100 0001 
		//COM1A10 = 01 :  Toggle output OC1A on compare match.
		//WGM11,10: 01

		TCCR1B = 17;	// 0001 0001  	// CS12..10 = 001: No clock prescaling. 
		// WGM13,12: 10
		// CS12,CS11,CS10: 001.  Count at CLKI/O/1 (no prescaling)

		//WGM: 1001, phase+frequency correct PWM
		// with top at OCR1A and update OCR1A at bottom.
		
        SoundEnabled = 1;
		DDRB |= 2; 
	}
else
	{
	    SoundEnabled = 0;
		TCCR1A = 0;	

	if (t)
	    TCCR1B = 128;		// Harmless; can use (TCCR1B == 0) to check if sound is done.
	else
		TCCR1B = 0; 	 
		DDRB &= 253;
		PORTB |= 2;
	}
}
  

SIGNAL(TIMER2_COMPA_vect)
{			
	// there are 15 passes through this interrupt for each row per frame.
	// ( 15 * 8) = 120 times per frame.
	// during those 15 passes, a led can be on or off.
	// if it is off the entire time, the perceived brightness is 0/15
	// if it is on the entire time, the perceived brightness is 15/15
	// giving a total of 16 average brightness levels from fully off to fully on.
	// currentBrightness is a comparison variable, used to determine if a certain
	// pixel is on or off during one of those 15 cycles.   
	//
	// At 120 Hz refresh, this executes 15*8*120 = 14,400 times per second.
	// Full routine takes about 340 cycles, 21 us. 
	//
	// 14400*340/16000000 = ~0.3; so about 1/3 of the processor time is spent in 
	// this interrupt routine.

#ifdef timingtest
unsigned int soundTemp = OCR1A;
OCR1A = 65500;
TCNT1 = 0;
#endif

	if (++MeggyJr::currentBrightness >= MAX_BRIGHTNESS)  
	{
		MeggyJr::currentBrightness = 0;
		if (++MeggyJr::currentCol > 7)
		{
			MeggyJr::currentCol = 0; 
			MeggyJr::currentColPtr = MeggyJr::MeggyFrame;
		}
		else
			MeggyJr::currentColPtr += 24;
			 
		if (MeggyJr::ToneTimeRemaining >  0)
			{ 
				if (--MeggyJr::ToneTimeRemaining == 0)
					{
						TCCR1A = 0;	  
						DDRB &= 253;
						PORTB |= 2;
						TCCR1B = 0;  // High bit flags that the sound is done.
					} 
			} 
	}
		
	////////////////////  Parse a row of data and write out the bits via spi
  
	byte *ptr = MeggyJr::currentColPtr + 23;  // it is more convenient to work from right to left
	byte p;
	byte cb =  MeggyJr::currentBrightness; 
	// Optimization: interleave waiting for SPI with other code, so the CPU can do something useful
	// when waiting for each SPI transmission to complete

//Turn display off:
PORTD |= 252U;
PORTB |= 17U;
 
SPCR = 80;// i.e., (1 << SPE) | ( 1 << MSTR );   

// First SPI word:  Aux LED drive.  Zero, except once per full screen redraw.	 
  
if ((cb + MeggyJr::currentCol ) == 0)
	SPDR = MeggyJr::AuxLEDs;
else
    SPDR = 0; 
        
	byte bits=0; 
 
	p = *ptr--;
	if (p > cb)  			
          bits |= 128;
	p = *ptr--;
	if (p > cb)  			
          bits |= 64;
	p = *ptr--;
	if (p > cb)  			
          bits |= 32;
	p = *ptr--;
	if (p > cb)  				
          bits |= 16;
	p = *ptr--;
	if (p > cb)  				
          bits |= 8;
	p = *ptr--;
	if (p > cb)  				
          bits |= 4;
	p = *ptr--;
	if (p > cb)  				
          bits |= 2;
	p = *ptr--;
	if (p > cb)  				
          bits |= 1;
		    
//	while (!(SPSR & (1<<SPIF)))  { } // wait for prior bitshift to complete
	SPDR = bits;
	
	bits=0;
	p = *ptr--;
	if (p > cb)  				
          bits |= 128;
	p = *ptr--;
	if (p > cb)  				
          bits |= 64;
	p = *ptr--;
	if (p > cb)  				
          bits |= 32;
	p = *ptr--;
	if (p > cb)  				
          bits |= 16;
	p = *ptr--;
	if (p > cb)  				
          bits |= 8;
	p = *ptr--;
	if (p > cb)  				
          bits |= 4;
	p = *ptr--;
	if (p > cb)  				
          bits |= 2;
	p = *ptr--;
	if (p > cb)  				
          bits |= 1;

//	while (!(SPSR & (1<<SPIF)))  { } // wait for prior bitshift to complete
	SPDR = bits;
		
	bits=0;
	p = *ptr--;
	if (p > cb)  				
          bits |= 128;
	p = *ptr--;
	if (p > cb)  				
          bits |= 64;
	p = *ptr--;
	if (p > cb)  				
          bits |= 32;
	p = *ptr--;
	if (p > cb)  				
          bits |= 16;
	p = *ptr--;
	if (p > cb)  				
          bits |= 8;
	p = *ptr--;
	if (p > cb)  				
          bits |= 4;
	p = *ptr--;
	if (p > cb)  				
          bits |= 2;
	p = *ptr--;
	if (p > cb)  				
          bits |= 1;

//asm("nop");	// short delay


	while (!(SPSR & (1<<SPIF)))  { } // wait for prior bitshift to complete
	SPDR = bits;
	
	////////////////////  Now set the row and latch the bits
	byte portbTemp = 0;	
	byte portdTemp = 0;

	if (MeggyJr::currentCol == 0)
		 portbTemp = 239U;
	else if (MeggyJr::currentCol == 1)
		 portbTemp = 254U;
	else
		 portdTemp = ~(1 << (9 - MeggyJr::currentCol));
   
	while (!(SPSR & (1<<SPIF)))  { } // wait for last bitshift to complete
 
PORTB |= 4;		//Latch Pulse    

    if (MeggyJr::currentCol > 1)
       PORTD &= portdTemp;
    else
       PORTB &= portbTemp;

       PORTB &= 251;           //End Latch Pulse
       SPCR = 0; //turn off spi 
	    
#ifdef timingtest

if (TCNT1 > MeggyJr::testTime)
   MeggyJr::testTime = TCNT1;
   
   OCR1A =  soundTemp;    
#endif
	
}

