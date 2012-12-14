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

#define NUM_SHIP_ROUTE_POINTS   25
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
new Float:gShipRoutePoints[NUM_SHIP_ROUTE_POINTS][6] = {
{-1982.57, 2052.56, 0.00,   0.00, 0.00, 144.84},
{-2178.63, 2103.67, 0.00,   0.00, 0.00, 189.24},
{-2366.64, 2020.28, 0.00,   0.00, 0.00, 215.22},
{-2539.06, 1892.52, 0.00,   0.00, 0.00, 215.22},
{-2722.79, 1787.85, 0.00,   0.00, 0.00, 205.62},
{-2918.51, 1729.60, 0.00,   0.00, 0.00, 190.50},
{-3124.70, 1758.03, 0.00,   0.00, 0.00, 156.36},
{-3316.51, 1850.08, 0.00,   0.00, 0.00, 153.36},
{-3541.12, 1977.99, 0.00,   0.00, 0.00, 145.74},
{-3772.54, 2140.70, 0.00,   0.00, 0.00, 144.96},
{-4078.78, 2272.93, 0.00,   0.00, 0.00, 167.52},
{-4382.22, 2222.52, 0.00,   0.36, 0.06, 206.70},
{-4578.11, 2013.70, 0.00,   0.36, 0.54, 244.80},
{-4603.54, 1718.89, 0.00,   1.92, -0.36, 283.26},
{-4463.49, 1504.50, 0.00,   0.92, -0.36, 316.32},
{-4228.00, 1380.52, 0.00,   0.92, -0.36, 342.54},
{-3950.14, 1346.96, 0.00,   0.02, -0.06, 359.64},
{-3646.69, 1344.57, 0.00,   0.02, -0.06, 359.64},
{-3350.01, 1410.39, 0.00,   0.02, -0.06, 384.48},
{-2854.63, 1651.56, 0.00,   0.02, -0.06, 378.54},
{-2590.84, 1667.61, 0.00,   0.02, -0.06, 356.28},
{-2345.84, 1633.19, 0.00,   0.02, -0.06, 350.28},
{-2106.14, 1639.23, 0.00,   0.02, -0.06, 378.36},
{-1943.63, 1743.98, 0.00,   0.02, -0.06, 411.42},
{-1891.39, 1907.57, 0.00,   0.02, -0.06, 457.14}
};


new gShipCurrentPoint = 1; // current route point the ship is at. We start at route 1

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
	
	if(gShipCurrentPoint > 0 && gShipCurrentPoint % 5) {
	    // play some seagulls audio every 5 points
		PlaySoundForPlayersInRange(6200, 200.0, gShipRoutePoints[gShipCurrentPoint][0],
						gShipRoutePoints[gShipCurrentPoint][1],
						gShipRoutePoints[gShipCurrentPoint][2]);
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
	
	if(gShipCurrentPoint == 1) {
	    // Before heading to the first route we should wait a bit
	    SetTimer("StartMovingTimer",30*1000,0); // pause at route 0 for 30 seconds
		return 1;
	}

	/*
    new tempdebug[256+1];
    format(tempdebug,256,"The ship is at route: %d", gShipCurrentPoint);
    SendClientMessageToAll(0xFFFFFFFF,tempdebug);*/
    
    MoveObject(gMainShipObjectId,gShipRoutePoints[gShipCurrentPoint][0],
	                           gShipRoutePoints[gShipCurrentPoint][1],
							   gShipRoutePoints[gShipCurrentPoint][2],
							   SHIP_MOVE_SPEED,
							   gShipRoutePoints[gShipCurrentPoint][3],
							   gShipRoutePoints[gShipCurrentPoint][4],
							   gShipRoutePoints[gShipCurrentPoint][5]);

 	return 1;
}

//-------------------------------------------------

public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[256];
	new idx;
	cmd = strtok(cmdtext, idx);
	
	if(strcmp(cmd, "/boardship", true) == 0) {
  	    if(gShipCurrentPoint != 1) {
  	        SendClientMessage(playerid, 0xFFFF0000, "The ship can't be boarded right now");
  	        return 1;
		}
  	    SetPlayerPos(playerid,-1937.7816,2017.7969,16.6640);
	    return 1;
	}
	
	return 0;
}

//-------------------------------------------------


