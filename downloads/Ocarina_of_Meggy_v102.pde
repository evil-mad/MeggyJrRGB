/*

This progtram is designed to allow you to play your Meggy Jr
in the same fashion that you, as Link, played the Ocarina of Time.
It also includes more controle over the notes you play.
!!!Disclaimer!!!
No magic events or time travel will occure as a result of playing your
Ocarina of Meggy.

Controles:
-Without B pressed
  A - plays D
  Down - plays F
  Right - plays A
  Left - plays B
  Up - plays D
-With B pressed
  A - plays C
  Down - plays E
  Right - plays G
  Left - plays C
  Up - plays E
  
As far as musical consept it may take a little practic. The idea of the B button
changing the notes played is similler to the consept behind the harmonica
and is an attempt the mimic the joysticks function while playing on the 64.

Future ideas for improvement:
-Better graphics
-Differant keys/ranges of ocarina
-More graphic options
-Animation with playing

*/

#include <MeggyJrSimple.h>



void setup()
{
  MeggyJrSimpleSetup();
  DrawPx(0,7,5);            //Draw the ocarina graphic
  DrawPx(1,7,5);
  DrawPx(2,7,5);
  DrawPx(0,6,5);
  DrawPx(1,6,5);
  DrawPx(2,6,5);
  DrawPx(3,6,5);
  DrawPx(7,6,5);
  DrawPx(1,5,5);
  DrawPx(2,5,5);
  DrawPx(3,5,5);
  DrawPx(4,5,5);
  DrawPx(6,5,5);
  DrawPx(2,4,5);
  DrawPx(3,4,5);
  DrawPx(4,4,5);
  DrawPx(5,4,5);
  DrawPx(2,3,5);
  DrawPx(3,3,5);
  DrawPx(4,3,5);
  DrawPx(5,3,5);
  DrawPx(6,3,5);
  DrawPx(3,2,5);
  DrawPx(4,2,5);
  DrawPx(5,2,5);
  DrawPx(6,2,5);
  DrawPx(7,2,5);
  DrawPx(4,1,5);
  DrawPx(5,1,5);
  DrawPx(6,1,5);
  DrawPx(7,1,5);
  DrawPx(5,0,5);
  DrawPx(6,0,5);
  DisplaySlate();
}

void loop()
{
  CheckButtonsDown();
  if (Button_B)
  {
    if (Button_Up)       
      Tone_Start(ToneE6,2);
      else
    if (Button_Left)       
      Tone_Start(ToneC6,2);
      else
    if (Button_Right)       
      Tone_Start(ToneG5,2);
      else
    if (Button_Down)       
      Tone_Start(ToneE5,2);
      else
    if (Button_A)       
      Tone_Start(ToneC5,2);
  }
  else
  if (Button_Up)       
    Tone_Start(ToneD6,2);
    else
  if (Button_Left)       
    Tone_Start(ToneB5,2);
    else
  if (Button_Right)       
    Tone_Start(ToneA5,2);
    else
  if (Button_Down)       
    Tone_Start(ToneF5,2);
    else
  if (Button_A)       
    Tone_Start(ToneD5,2);
}
