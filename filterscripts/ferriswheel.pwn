//
// Used for testing interpolated rotations with MoveObject
// Also used to test AttachObjectToObject
// The other ferris wheel (that actually spins!)
// Located on the opposite peer at LS
//
// SA-MP 0.3d and above
//
// - Kye 2011
//

#include <a_samp>
#include "../include/gl_common.inc" // for PlaySoundForPlayersInRange()

#define NUM_FERRIS_CAGES        10
#define FERRIS_WHEEL_ID         18877
#define FERRIS_CAGE_ID          18879
#define FERRIS_BASE_ID          18878
#define FERRIS_DRAW_DISTANCE    300.0
#define FERRIS_WHEEL_SPEED      0.01

#define FERRIS_WHEEL_Z_ANGLE  	-90.0 // This is the heading the entire ferris wheel is at (beware of gimbal lock)

new Float:gFerrisOrigin[3] = {832.8393, -2046.1990, 27.0900};

// Cage offsets for attaching to the main wheel
new Float:gFerrisCageOffsets[NUM_FERRIS_CAGES][3] = {
{0.0699, 0.0600, -11.7500},
{-6.9100, -0.0899, -9.5000},
{11.1600, 0.0000, -3.6300},
{-11.1600, -0.0399, 3.6499},
{-6.9100, -0.0899, 9.4799},
{0.0699, 0.0600, 11.7500},
{6.9599, 0.0100, -9.5000},
{-11.1600, -0.0399, -3.6300},
{11.1600, 0.0000, 3.6499},
{7.0399, -0.0200, 9.3600}
};

// SA-MP objects
new gFerrisWheel;
new gFerrisBase;
new gFerrisCages[NUM_FERRIS_CAGES];

forward RotateWheel();

//-------------------------------------------------

new Float:gCurrentTargetYAngle = 0.0; // Angle of the Y axis of the wheel to rotate to.
new gWheelTransAlternate = 0; // Since MoveObject requires some translation target to intepolate
						    // rotation, the world pos target is alternated by a small amount.
						    
UpdateWheelTarget()
{
    gCurrentTargetYAngle += 36.0; // There are 10 carts, so 360 / 10
    if(gCurrentTargetYAngle >= 360.0) {
		gCurrentTargetYAngle = 0.0;
    }
	if(gWheelTransAlternate) gWheelTransAlternate = 0;
	else gWheelTransAlternate = 1;
}

//-------------------------------------------------

public RotateWheel()
{
    UpdateWheelTarget();
    
    new Float:fModifyWheelZPos = 0.0;
    if(gWheelTransAlternate) fModifyWheelZPos = 0.05;
    
    MoveObject( gFerrisWheel, gFerrisOrigin[0], gFerrisOrigin[1], gFerrisOrigin[2]+fModifyWheelZPos,
				FERRIS_WHEEL_SPEED, 0.0, gCurrentTargetYAngle, FERRIS_WHEEL_Z_ANGLE );
}

//-------------------------------------------------

public OnFilterScriptInit()
{
	gFerrisWheel = CreateObject( FERRIS_WHEEL_ID, gFerrisOrigin[0], gFerrisOrigin[1], gFerrisOrigin[2],
	  							 0.0, 0.0, FERRIS_WHEEL_Z_ANGLE, FERRIS_DRAW_DISTANCE );

    gFerrisBase = CreateObject( FERRIS_BASE_ID, gFerrisOrigin[0], gFerrisOrigin[1], gFerrisOrigin[2],
	  							 0.0, 0.0, FERRIS_WHEEL_Z_ANGLE, FERRIS_DRAW_DISTANCE );
	  							 
	new x=0;
	while(x != NUM_FERRIS_CAGES) {
        gFerrisCages[x] = CreateObject( FERRIS_CAGE_ID, gFerrisOrigin[0], gFerrisOrigin[1], gFerrisOrigin[2],
	  							 0.0, 0.0, FERRIS_WHEEL_Z_ANGLE, FERRIS_DRAW_DISTANCE );
	  							 
        AttachObjectToObject( gFerrisCages[x], gFerrisWheel,
							  gFerrisCageOffsets[x][0],
							  gFerrisCageOffsets[x][1],
	  						  gFerrisCageOffsets[x][2],
							  0.0, 0.0, FERRIS_WHEEL_Z_ANGLE, 0 );
					
		x++;
	}
	
	SetTimer("RotateWheel",3*1000,0);

	return 1;
}

//-------------------------------------------------

public OnFilterScriptExit()
{
	new x=0;
	
    DestroyObject(gFerrisWheel);
    DestroyObject(gFerrisBase);
    
	x=0;
	while(x != NUM_FERRIS_CAGES) {
	    DestroyObject(gFerrisCages[x]);
		x++;
	}

	return 1;
}

//-------------------------------------------------

public OnObjectMoved(objectid)
{
    if(objectid != gFerrisWheel) return 0;
    
    SetTimer("RotateWheel",3*1000,0);
    return 1;
}

//-------------------------------------------------


