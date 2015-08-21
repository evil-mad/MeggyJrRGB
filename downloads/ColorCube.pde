/*
ColorCube - Displays all colors in the RGB cube
Version 1.0 - 12/27/2008
Copyright (c) 2008 Nicolas and Alexandre Ganivet. All rights reserved.

This programs visualizes the RGB color cube on the Meggy Jr display.
It initially displays the Red/Green face of the cube, with the A/B buttons
controlling the depth on the Blue axis. You can therefore visualize all
possible colors that can be displayed on the Meggy Jr display.

For an additional twist, the directional buttons do rotate the cube, allowing
you to visualize all other faces of the color cube. It takes a little effort
to make sense of it though!

This program uses the SetPxClr routine, which directly writes to the
Meggy Jr video buffer, setting the color of an individual dot in the RGB matrix

*/

#include <MeggyJrSimple.h> // Required

int XAxis, YAxis, ZAxis; // MUST be of type 'int' since will store negative values
byte Depth;

#define Red 1;
#define Green 2;
#define Blue 3;

void setup() 
{
MeggyJrSimpleSetup(); // Initialize MeggyJr library

// Initial orientation and depth of cube
XAxis = Red; 
YAxis = Green; 
ZAxis = Blue;
Depth = 0;
} 


void loop() 
{
uint8_t Color[3];
byte x, y, xind, yind, zind;
int t; // MUST be of type 'int' since will store negative values

/******************************************/
/* Check for button presses and act on it */
/******************************************/
CheckButtonsPress();

// Manage depth change (Z axis, A/B buttons)
if (Button_A && (Depth<7)) {
Depth++; 
}
if (Button_B && (Depth>0)) {
Depth--;
}

// Manage cube rotations (directional buttons)
if (Button_Up) {
t = ZAxis; 
ZAxis = -YAxis; 
YAxis = t;
}
if (Button_Down) {
t = ZAxis; 
ZAxis = YAxis; 
YAxis =-t;
}
if (Button_Left) {
t = ZAxis; 
ZAxis = -XAxis; 
XAxis = t;
}
if (Button_Right) {
t = ZAxis; 
ZAxis = XAxis; 
XAxis = -t;
}

/****************************************/
/* Refresh main display with color cube */
/****************************************/
// Display depth on Aux LEDs
Meg.AuxLEDs = 1 << Depth;

// Initialize axis indexes
xind = abs(XAxis)-1;
yind = abs(YAxis)-1;
zind = abs(ZAxis)-1;

// Loop over main display
Color[zind] = (ZAxis<0 ? 7-Depth : Depth )*2;
Color[xind] = (XAxis<0 ?14:0);
for (x=0; x<8; x++) {
Color[yind] = (YAxis<0?14:0);
for (y=0; y<8; y++) {
Meg.SetPxClr(x, y, Color);
Color[yind] += (YAxis<0?-2:2);
}
Color[xind] += (XAxis<0?-2:2);
}

// End of main loop
}
