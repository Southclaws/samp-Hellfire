//
// Used for testing interpolated rotations with MoveObject
// Also used to test AttachObjectToObject
// A cargo ship goes around and visits some route points
//
// SA-MP 0.3d and above
//
// - Kye 2011
//

#include <a_samp>
#include <zcmd>

#define NUM_SHIP_ROUTE_POINTS   22
#define SHIP_HULL_ID          	9585 // massive cargo ship's hull. This is used as the main object
#define SHIP_MOVE_SPEED         10.0
#define SHIP_DRAW_DISTANCE      300.0

#define NUM_SHIP_ATTACHMENTS 10

new Float:gShipHullOrigin[3] =
{ -2409.8438, 1544.9453, 7.0000 }; // so we can convert world space to model space for attachment positions

new gShipAttachmentModelIds[NUM_SHIP_ATTACHMENTS] = {
9586, // Ship main platform
9761, // Ship rails
9584, // Bridge exterior
9698, // Bridge interior
9821, // Bridge interior doors
9818, // Bridge radio desk
9819, // Captain's desk
9822, // Captain's seat
9820, // Bridge ducts and lights
9590  // Cargo bay area
};

new Float:gShipAttachmentPos[NUM_SHIP_ATTACHMENTS][3] = {
// these are world space positions used on the original cargo ship in the game
// they will be converted to model space before attaching
{-2412.1250, 1544.9453, 17.0469},
{-2411.3906, 1544.9453, 27.0781},
{-2485.0781, 1544.9453, 26.1953},
{-2473.5859, 1543.7734, 29.0781},
{-2474.3594, 1547.2422, 24.7500},
{-2470.2656, 1544.9609, 33.8672},
{-2470.4531, 1551.1172, 33.1406},
{-2470.9375, 1550.7500, 32.9063},
{-2474.6250, 1545.0859, 33.0625},
{-2403.5078, 1544.9453, 8.7188}
};

// Pirate ship route points (position/rotation)
new Float:gShipRoutePoints[NUM_SHIP_ROUTE_POINTS][6] =
{
	{87.51, -2898.94, -0.07,   0.00, 0.00, -150.18},
	{-587.32, -3057.62, -0.07,   0.00, 0.00, -177.48},
	{-1468.38, -3068.98, -0.07,   0.00, 0.00, -183.30},
	{-2194.30, -3041.70, -0.07,   0.00, 0.00, -182.28},
	{-2921.34, -2937.29, -0.07,   0.00, 0.00, -213.30},
	{-3236.77, -2573.79, -0.07,   0.00, 0.00, -236.22},
	{-3543.45, -2101.92, -0.07,   0.00, 0.00, -224.10},
	{-4199.55, -1895.84, -0.07,   0.00, 0.00, -186.48},
	{-4765.33, -2050.00, -0.07,   0.00, 0.00, -149.16},
	{-5122.41, -2391.46, -0.07,   0.00, 0.00, -124.14},
	{-5302.43, -3264.70, -0.07,   0.00, 0.00, -84.06},
	{-4743.05, -4126.96, -0.07,   0.00, 0.00, -41.22},
	{-5302.43, -3264.70, -0.07,   0.00, 0.00, -84.06},
	{-4014.75, -4363.47, -0.07,   0.00, 0.00, 349.56},
	{-2855.32, -4420.35, -0.21,   0.00, 0.00, 0.00},
	{-879.22, -4431.21, -0.14,   0.00, 0.00, 0.00},
	{1272.56, -4416.63, -0.63,   0.00, 0.00, 8.52},
	{1664.85, -4261.75, -0.63,   0.00, 0.00, 31.62},
	{1984.35, -3769.63, -0.63,   0.00, 0.00, 91.80},
	{1661.40, -3186.24, -0.63,   0.00, 0.00, 147.60},
	{1114.92, -2796.60, -0.63,   0.00, 0.00, 148.80},
	{608.54, -2678.01, -0.63,   0.00, 0.00, 182.10}

};


new gShipCurrentPoint = 1; // current route point the ship is at. We start at route 1
new gShipSinkingPoint = -1;
new Float:gShipSinkingSpeed;
new Float:gShipSinkingRoll;
new Float:gShipSinkingPitch;
new Float:gShipSinkingZ;

// SA-MP objects
new gMainShipObjectId;
new gShipsAttachments[NUM_SHIP_ROUTE_POINTS];

forward StartMovingTimer();

//-------------------------------------------------

public StartMovingTimer()
{
	MoveObject(gMainShipObjectId,gShipRoutePoints[gShipCurrentPoint][0],
	                           gShipRoutePoints[gShipCurrentPoint][1],
							   gShipRoutePoints[gShipCurrentPoint][2],
							   SHIP_MOVE_SPEED / 2.0, // slower for the first route
							   gShipRoutePoints[gShipCurrentPoint][3],
							   gShipRoutePoints[gShipCurrentPoint][4],
							   gShipRoutePoints[gShipCurrentPoint][5]);
}

//-------------------------------------------------

public OnFilterScriptInit()
{
	gMainShipObjectId = CreateObject(SHIP_HULL_ID, gShipRoutePoints[0][0], gShipRoutePoints[0][1], gShipRoutePoints[0][2],
									gShipRoutePoints[0][3], gShipRoutePoints[0][4], gShipRoutePoints[0][5], SHIP_DRAW_DISTANCE);

	new x=0;
	while(x != NUM_SHIP_ATTACHMENTS) {
	    gShipsAttachments[x] = CreateObject(gShipAttachmentModelIds[x], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SHIP_DRAW_DISTANCE);
		AttachObjectToObject(gShipsAttachments[x], gMainShipObjectId,
					gShipAttachmentPos[x][0] - gShipHullOrigin[0],
					gShipAttachmentPos[x][1] - gShipHullOrigin[1],
					gShipAttachmentPos[x][2] - gShipHullOrigin[2],
					0.0, 0.0, 0.0);
		x++;
	}

  	SetTimer("StartMovingTimer",30*1000,0); // pause at route 0 for 30 seconds

	return 1;
}

//-------------------------------------------------

public OnFilterScriptExit()
{
    DestroyObject(gMainShipObjectId);
    new x=0;
	while(x != NUM_SHIP_ATTACHMENTS) {
	    DestroyObject(gShipsAttachments[x]);
		x++;
	}
	return 1;
}

//-------------------------------------------------

public OnObjectMoved(objectid)
{
	if(objectid != gMainShipObjectId) return 0;
	
	if(gShipCurrentPoint > 0 && gShipCurrentPoint % 5)
	{
	    for(new i;i<MAX_PLAYERS;i++)
	    {
	        if(IsPlayerInRangeOfPoint(i, 200.0, gShipRoutePoints[gShipCurrentPoint][0], gShipRoutePoints[gShipCurrentPoint][1], gShipRoutePoints[gShipCurrentPoint][2]))
				PlayerPlaySound(i, 6200, gShipRoutePoints[gShipCurrentPoint][0],
								gShipRoutePoints[gShipCurrentPoint][1],
								gShipRoutePoints[gShipCurrentPoint][2]);
		}
	}
						
    gShipCurrentPoint++;
    
    if(gShipCurrentPoint == NUM_SHIP_ROUTE_POINTS) {
		gShipCurrentPoint = 0;

   		MoveObject(gMainShipObjectId,gShipRoutePoints[gShipCurrentPoint][0],
	                           gShipRoutePoints[gShipCurrentPoint][1],
							   gShipRoutePoints[gShipCurrentPoint][2],
							   SHIP_MOVE_SPEED / 2.0, // slower for the last route
							   gShipRoutePoints[gShipCurrentPoint][3],
							   gShipRoutePoints[gShipCurrentPoint][4],
							   gShipRoutePoints[gShipCurrentPoint][5]);
        return 1;
	}
	if(gShipSinkingPoint != -1 && gShipCurrentPoint >= gShipSinkingPoint)
	{
	    if(gShipCurrentPoint - gShipSinkingPoint < 8)
	    {
	        gShipSinkingZ -= 5.0;
	        gShipSinkingRoll += 10.0;
	        gShipSinkingPitch += 1.0;
		    gShipSinkingSpeed *= 0.7;


		    gShipRoutePoints[gShipCurrentPoint][2] = gShipSinkingZ;
		    gShipRoutePoints[gShipCurrentPoint][3] = gShipSinkingRoll;
		    gShipRoutePoints[gShipCurrentPoint][4] = gShipSinkingPitch;

		    MoveObject(gMainShipObjectId,gShipRoutePoints[gShipCurrentPoint][0],
			                           gShipRoutePoints[gShipCurrentPoint][1],
									   gShipRoutePoints[gShipCurrentPoint][2],
									   gShipSinkingSpeed,
									   gShipRoutePoints[gShipCurrentPoint][3],
									   gShipRoutePoints[gShipCurrentPoint][4],
									   gShipRoutePoints[gShipCurrentPoint][5]);
	    }
	    else StopObject(gMainShipObjectId);
	}
	else
	{
	    MoveObject(gMainShipObjectId,gShipRoutePoints[gShipCurrentPoint][0],
		                           gShipRoutePoints[gShipCurrentPoint][1],
								   gShipRoutePoints[gShipCurrentPoint][2],
								   SHIP_MOVE_SPEED,
								   gShipRoutePoints[gShipCurrentPoint][3],
								   gShipRoutePoints[gShipCurrentPoint][4],
								   gShipRoutePoints[gShipCurrentPoint][5]);
	}

	
	if(gShipCurrentPoint == 1) {
	    // Before heading to the first route we should wait a bit
	    SetTimer("StartMovingTimer",30*1000,0); // pause at route 0 for 30 seconds
		return 1;
	}

	/*
    new tempdebug[256+1];
    format(tempdebug,256,"The ship is at route: %d", gShipCurrentPoint);
    SendClientMessageToAll(0xFFFFFFFF,tempdebug);*/
    

 	return 1;
}


CMD:sinkship(playerid, params[])
{
    gShipRoutePoints[gShipCurrentPoint+2][2] -= 10.0;
    gShipRoutePoints[gShipCurrentPoint+2][3] = 15.0;
    gShipSinkingPoint = gShipCurrentPoint+2;

    gShipSinkingSpeed = SHIP_MOVE_SPEED;
	return 1;
}
