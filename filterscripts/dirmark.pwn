#include <a_samp>
#include <formatex>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16


new
	PlayerText:dMarker,
	PlayerText:cMarker,
	dObject,
	Float:g_dX,
	Float:g_dY,
	Float:g_dZ,

	Float:g_OriginX,
	Float:g_OriginY,

	Float:g_tmpZ;


stock Float:GetAngleToPoint(Float:fPointX, Float:fPointY, Float:fDestX, Float:fDestY)
    return 90-(atan2((fDestY - fPointY), (fDestX - fPointX)));


public OnFilterScriptInit()
{
}
public OnFilterScriptExit()
{
}

stock CreateDot(playerid, Float:x, Float:y)
{
	PlayerTextDrawDestroy			(playerid, dMarker);
	PlayerTextDrawDestroy			(playerid, cMarker);

	dMarker							=CreatePlayerTextDraw(playerid, x, y, ".");
	PlayerTextDrawBackgroundColor	(playerid, dMarker, 255);
	PlayerTextDrawFont				(playerid, dMarker, 1);
	PlayerTextDrawLetterSize		(playerid, dMarker, 1.000000, 4.000000);
	PlayerTextDrawColor				(playerid, dMarker, -16776961);
	PlayerTextDrawSetOutline		(playerid, dMarker, 0);
	PlayerTextDrawSetProportional	(playerid, dMarker, 1);
	PlayerTextDrawAlignment			(playerid, dMarker, 1);
	PlayerTextDrawSetShadow			(playerid, dMarker, 0);
	PlayerTextDrawShow				(playerid, dMarker);

	cMarker							=CreatePlayerTextDraw(playerid, 320.0, 240.0, ".");
	PlayerTextDrawBackgroundColor	(playerid, cMarker, 255);
	PlayerTextDrawFont				(playerid, cMarker, 1);
	PlayerTextDrawLetterSize		(playerid, cMarker, 1.000000, 4.000000);
	PlayerTextDrawColor				(playerid, cMarker, 0x0000FFFF);
	PlayerTextDrawSetOutline		(playerid, cMarker, 0);
	PlayerTextDrawSetProportional	(playerid, cMarker, 1);
	PlayerTextDrawAlignment			(playerid, cMarker, 1);
	PlayerTextDrawSetShadow			(playerid, cMarker, 0);
	PlayerTextDrawShow				(playerid, cMarker);
}

CMD:dirmark(playerid, params[])
{
	GetPlayerPos(playerid, g_dX, g_dY, g_dZ);

	CreateDynamicObject(1318, g_dX, g_dY, g_dZ, 0.0, 0.0, 0.0);
	dObject=CreateDynamicObject(1318, g_dX+1.0, g_dY, g_dZ, 0.0, 0.0, 0.0);

	g_OriginX=320.0;
	g_OriginY=240.0;
	

	return 1;
}
public OnPlayerUpdate(playerid)
{
	new
		Float:posX,
		Float:posY,
		Float:Angle1,
		Float:Angle2;

	GetPlayerPos(playerid, posX, posY, g_tmpZ);
	Angle1 = GetAngleToPoint(posX, posY, g_dX, g_dY)+180;

	posX = g_dX + (1.0 * floatsin(Angle1, degrees));
	posY = g_dY + (1.0 * floatcos(Angle1, degrees));

	SetDynamicObjectPos(dObject, posX, posY, g_dZ);
	SetDynamicObjectRot(dObject, 90.0, 0.0, -Angle1);


	GetPlayerPos(playerid, posX, posY, g_tmpZ);
	Angle2 = (GetAngleToPoint(posX, posY, g_dX, g_dY) );

	posX = g_OriginX + (30.0 * floatsin(Angle2, degrees));
	posY = g_OriginY - (30.0 * floatcos(Angle2, degrees));
	
	new str[128];
	format(str, 128, "%f~n~%f", Angle1, Angle2);
	CallRemoteFunction("sffa_msgbox", "dsdd", playerid, str, 0, 180);

	CreateDot(playerid, posX, posY);
}




