#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#include <streamer>
#include <zcmd>
//#include <foreach>

#include "../scripts/Releases/Button/Button.pwn"




#define MAX_DOOR				(8)
#define MAX_BUTTONS_PER_DOOR	(4)


enum E_DOOR_DATA
{
	dr_objectid,
	dr_buttonArray[MAX_BUTTONS_PER_DOOR],
	dr_buttonCount,

	Float:dr_posX,
	Float:dr_posY,
	Float:dr_posZ,
	Float:dr_rotX,
	Float:dr_rotY,
	Float:dr_rotZ,

	Float:dr_posMoveX,
	Float:dr_posMoveY,
	Float:dr_posMoveZ,
	Float:dr_rotMoveX,
	Float:dr_rotMoveY,
	Float:dr_rotMoveZ
}

new
	dr_Data[MAX_DOOR][E_DOOR_DATA],
	Iterator:dr_Index<MAX_DOOR>;

CreateDoor(model, buttonids[],
	Float:px,  Float:py,  Float:pz,  Float:rx,  Float:ry,  Float:rz,
	Float:mpx, Float:mpy, Float:mpz, Float:mrx, Float:mry, Float:mrz, maxbuttons = sizeof(buttonids))
{
	new id = Iter_Free(dr_Index);

    dr_Data[id][dr_objectid] = CreateDynamicObject(model, px, py, pz, rx, ry, rz);
    dr_Data[id][dr_buttonCount] = maxbuttons;
	for(new i;i<maxbuttons;i++)dr_Data[id][dr_buttonArray][i] = buttonids[i];

    dr_Data[id][dr_posX] = px;
    dr_Data[id][dr_posY] = py;
    dr_Data[id][dr_posZ] = pz;
    dr_Data[id][dr_rotX] = rx;
    dr_Data[id][dr_rotY] = ry;
    dr_Data[id][dr_rotZ] = rz;

    dr_Data[id][dr_posMoveX] = mpx;
    dr_Data[id][dr_posMoveY] = mpy;
    dr_Data[id][dr_posMoveZ] = mpz;
    dr_Data[id][dr_rotMoveX] = mrx;
    dr_Data[id][dr_rotMoveY] = mry;
    dr_Data[id][dr_rotMoveZ] = mrz;
    
	Iter_Add(dr_Index, id);
    dr_Index[id] = true;
	return id;
}

public OnFilterScriptInit()
{
	new buttonid[2];

	buttonid[0] = CreateButton(210.2342, 1877.4778, 13.1406, "Press to activate door");
	buttonid[1] = CreateButton(209.5598, 1874.3828, 13.1469, "Press to activate door");

	CreateDoor(2927, buttonid,
		215.9915, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		219.8936, 1875.2880, 13.9389, 0.0, 0.0, 0.0);

	CreateDoor(2929, buttonid,
		211.8555, 1875.2880, 13.9389, 0.0, 0.0, 0.0,
		207.8556, 1875.2880, 13.9389, 0.0, 0.0, 0.0);
}

OnButtonPress(playerid, buttonid)
{
	for(new i;i<MAX_DOOR;i++)
	{
		for(new j;j<dr_Data[i][dr_buttonCount];j++)
		{
			if(buttonid == dr_Data[i][dr_buttonArray][j])
			{
				MoveDynamicObject(dr_Data[i][dr_objectid],
					dr_Data[i][dr_posMoveX], dr_Data[i][dr_posMoveY], dr_Data[i][dr_posMoveZ], 1.0,
					dr_Data[i][dr_rotMoveX], dr_Data[i][dr_rotMoveY], dr_Data[i][dr_rotMoveZ]);

				PlayerPlaySound(playerid, 6000, 0.0, 0.0, 0.0);
			}
		}
	}
}
