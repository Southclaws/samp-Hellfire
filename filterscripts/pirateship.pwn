//
// Used for testing interpolated rotations with MoveObject
// Also used to test AttachObjectToObject
// A pirate ship goes around and visits some route points
//
// SA-MP 0.3d and above
//
// - Kye 2011
//

#include <a_samp>
#include "../include/gl_common.inc" // for PlaySoundForPlayersInRange()

#define NUM_SHIP_ROUTE_POINTS   25
#define SHIP_OBJECT_ID          8493 // pirate ship
#define SHIP_SKULL_ATTACH       3524
#define SHIP_RAILS_ATTACH       9159
#define SHIP_LINES_ATTACH       8981
#define SHIP_MOVE_SPEED         10.0
#define SHIP_DRAW_DISTANCE      300.0

// Pirate ship route points (position/rotation)
new Float:gShipRoutePoints[NUM_SHIP_ROUTE_POINTS][6] = {
{-2389.81, 1434.84, 13.51,   0.00, 0.0, -87.36},
{-2319.54, 1450.75, 13.91,   1.0, 0.0, -71.70},
{-2245.87, 1479.80, 14.21,   5.00, 0.0, -63.84},
{-2168.53, 1535.31, 15.73,   1.00, 0.0, -50.76},
{-2096.43, 1634.13, 15.73,   0.00, 0.0, -36.60},
{-2036.11, 1734.57, 15.27,   -1.00, 0.0, -20.22},
{-2018.20, 1841.61, 15.27,   -5.00, 0.00, -4.86},
{-2043.70, 1936.95, 15.27,   -1.00, 0.00, 25.32},
{-2104.07, 2023.54, 12.78,   0.00, 0.00, 49.14},
{-2206.40, 2065.64, 16.76,   1.00, 0.00, 73.32},
{-2298.24, 2070.62, 14.59,   5.00, 0.00, 91.62},
{-2412.24, 2067.55, 14.59,   1.00, 0.00, 91.62},
{-2528.28, 2057.22, 12.30,   0.00, 0.00, 99.78},
{-2626.64, 2032.14, 17.04,   -1.00, 0.00, 106.98},
{-2727.60, 1996.95, 15.36,   -5.00, 0.00, 106.98},
{-2808.88, 1953.08, 15.36,   -1.00, 0.00, 121.62},
{-2886.19, 1876.19, 16.68,   0.00, 0.00, 143.16},
{-2911.09, 1782.21, 16.68,   -1.00, 0.00, 173.34},
{-2898.36, 1678.83, 14.88,   0.00, 0.00, 194.58},
{-2851.29, 1601.46, 16.13,   1.00, 0.00, 228.42},
{-2760.72, 1557.18, 16.13,   0.00, 0.00, 257.52},
{-2665.41, 1535.22, 16.13,   -1.00, 0.00, 257.52},
{-2589.06, 1509.08, 16.13,   0.00, 0.00, 239.88},
{-2517.74, 1463.39, 14.59,   1.00, 0.00, 243.78},
{-2456.12, 1441.11, 14.59,   0.00, 0.00, 254.76}
};


new gShipCurrentPoint = 1; // current route point the ship is at

// SA-MP objects
new gMainShipObjectId;
new gShipSkullAttachment[4];
new gShipRailsAttachment;
new gShipLinesAttachment;

forward StartMovingTimer();

//-------------------------------------------------

public StartMovingTimer()
{
	MoveObject(gMainShipObjectId,gShipRoutePoints[gShipCurrentPoint][0],
	                           gShipRoutePoints[gShipCurrentPoint][1],
							   gShipRoutePoints[gShipCurrentPoint][2],
							   SHIP_MOVE_SPEED / 4.0, // bit slower for the first point
							   gShipRoutePoints[gShipCurrentPoint][3],
							   gShipRoutePoints[gShipCurrentPoint][4],
							   gShipRoutePoints[gShipCurrentPoint][5]);
}

//-------------------------------------------------

public OnFilterScriptInit()
{
	gMainShipObjectId = CreateObject(SHIP_OBJECT_ID, gShipRoutePoints[0][0], gShipRoutePoints[0][1], gShipRoutePoints[0][2],
									gShipRoutePoints[0][3], gShipRoutePoints[0][4], gShipRoutePoints[0][5], SHIP_DRAW_DISTANCE);

	gShipSkullAttachment[0] = CreateObject(SHIP_SKULL_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SHIP_DRAW_DISTANCE);
	AttachObjectToObject(gShipSkullAttachment[0], gMainShipObjectId, 4.11, -5.53, -9.78, 0.0, 0.0, 90.0);

	gShipSkullAttachment[1] = CreateObject(SHIP_SKULL_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SHIP_DRAW_DISTANCE);
	AttachObjectToObject(gShipSkullAttachment[1], gMainShipObjectId, -4.11, -5.53, -9.78, 0.0, 0.0, -90.0);
	
	gShipSkullAttachment[2] = CreateObject(SHIP_SKULL_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SHIP_DRAW_DISTANCE);
	AttachObjectToObject(gShipSkullAttachment[2], gMainShipObjectId, -4.3378, -15.2887, -9.7863, 0.0, 0.0, -90.0);
	
	gShipSkullAttachment[3] = CreateObject(SHIP_SKULL_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SHIP_DRAW_DISTANCE);
	AttachObjectToObject(gShipSkullAttachment[3], gMainShipObjectId, 4.3378, -15.2887, -9.7863, 0.0, 0.0, 90.0);
	
	gShipRailsAttachment = CreateObject(SHIP_RAILS_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SHIP_DRAW_DISTANCE);
	AttachObjectToObject(gShipRailsAttachment, gMainShipObjectId, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	
	gShipLinesAttachment = CreateObject(SHIP_LINES_ATTACH, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SHIP_DRAW_DISTANCE);
	AttachObjectToObject(gShipLinesAttachment, gMainShipObjectId, -0.5468, -6.1875, -0.4375, 0.0, 0.0, 0.0);

	SetTimer("StartMovingTimer",30*1000,0); // pause at route 0 for 30 seconds

	return 1;
}

//-------------------------------------------------

public OnFilterScriptExit()
{
	new x=0;
	
    DestroyObject(gMainShipObjectId);

	x=0;
	while(x != 4) {
	    DestroyObject(gShipSkullAttachment[x]);
		x++;
	}
	
	DestroyObject(gShipRailsAttachment);
	DestroyObject(gShipLinesAttachment);
	
	return 1;
}

//-------------------------------------------------

public OnObjectMoved(objectid)
{
    if(objectid != gMainShipObjectId) return 0;
    
	if(gShipCurrentPoint > 0 && gShipCurrentPoint % 3) {
	    // play some seagulls audio every 3 points
		PlaySoundForPlayersInRange(6200, 100.0, gShipRoutePoints[gShipCurrentPoint][0],
						gShipRoutePoints[gShipCurrentPoint][1],
						gShipRoutePoints[gShipCurrentPoint][2]);
	}
						
    gShipCurrentPoint++;
    
    if(gShipCurrentPoint == NUM_SHIP_ROUTE_POINTS) {
		gShipCurrentPoint = 0;

   		MoveObject(gMainShipObjectId,gShipRoutePoints[gShipCurrentPoint][0],
	                           gShipRoutePoints[gShipCurrentPoint][1],
							   gShipRoutePoints[gShipCurrentPoint][2],
							   SHIP_MOVE_SPEED / 4.0, // slower for the last route
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


