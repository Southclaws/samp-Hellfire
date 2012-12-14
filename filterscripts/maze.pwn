#include <a_samp>
#include <YSI\y_va>
#include <formatex>
#include "../scripts/System/PlayerFunctions.pwn"
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define MAZ_ORIGIN_X	(0.0)
#define MAZ_ORIGIN_Y	(0.0)
#define MAZ_ORIGIN_Z	(50.0)

#define MAZ_LEVEL_MODEL	(3095)
#define MAZ_START_MODEL (19134)
#define MAZ_END_MODEL	(19130)
#define MAZ_OFFSET_X	(9.0)
#define MAZ_OFFSET_Y	(9.0)
#define MAZ_SIZE_X		(8)
#define MAZ_SIZE_Y		(8)
#define MAZ_WALL_Z      (4.5)

#define MAZ_N_WALL		(0b1000)
#define MAZ_E_WALL		(0b0100)
#define MAZ_S_WALL		(0b0010)
#define MAZ_W_WALL		(0b0001)

#define MAZ_EDIT_UP		(0)
#define MAZ_EDIT_DOWN	(1)
#define MAZ_EDIT_LEFT	(2)
#define MAZ_EDIT_RIGHT	(3)

new const Float:maz_Offsets[4][3]=
{
	{0.00, 4.5,  270.0},
	{4.5, 0.00,  180.0},
	{0.0, -4.5,  90.0},
	{-4.5, 0.0,  0.0}
},
//19353, "all_walls"
maz_Materials[32][20]=
{
	"officewallsnew1",
	"stormdrain3_nt",
	"wall6",
	"711_walltemp",
	"ab_clubloungewall",
	"ab_corwallupr",
	"ah_utilbor1",
	"bow_abpave_gen",
	"carp11s",
	"cj_lightwood",
	"cj_white_wall2",
	"cl_of_wltemp",
	"concretenewb256",
	"copbtm_brown",
	"des_dirt1",
	"desgreengrass",
	"gym_floor5",
	"kb_kit_wal1",
	"la_carp3",
	"motel_wall3",
	"mp_burn_ceiling",
	"mp_carter_bwall",
	"mp_diner_woodwall",
	"mp_furn_floor",
	"mp_gs_libwall",
	"mp_motel_bluew",
	"mp_motel_carpet",
	"mp_motel_carpet1",
	"mp_motel_pinkw",
	"mp_motel_whitewall",
	"mp_shop_floor2",
	"vgsn_scrollsgn256"
};

new
	maz_FloorObj[MAZ_SIZE_X * MAZ_SIZE_Y],
	maz_WallsObj[MAZ_SIZE_X * MAZ_SIZE_Y][4],
	maz_StartObj,
	maz_EndObj,
	maz_WallData[MAZ_SIZE_X * MAZ_SIZE_Y char],
	maz_LevelData[1 char];

new
	gPlayerCurrentSq[MAX_PLAYERS];

new
	PlayerText:maz_TdMoveU,
	PlayerText:maz_TdMoveD,
	PlayerText:maz_TdMoveL,
	PlayerText:maz_TdMoveR,

	PlayerText:maz_TdWallN,
	PlayerText:maz_TdWallS,
	PlayerText:maz_TdWallE,
	PlayerText:maz_TdWallW;

public OnFilterScriptInit()
{
    maz_LevelData{0} = 0;
    maz_LevelData{1} = (MAZ_SIZE_X * MAZ_SIZE_Y) - 1;
    maz_Delete();
	maz_Build();
	for(new i;i<MAX_PLAYERS;i++)gPlayerCurrentSq[i] = -1;
	return 1;
}

new
	edit;

maz_LoadData()
{
	new
		File:idxFile,
		File:datFile,
		line[128],
		file[48],
		data[128];

	if(!fexist(MAZ_INDEX_FILE))print("ERROR: Maze index file not found");
	else idxFile = fopen(MAZ_INDEX_FILE, io_read);
	
	while(fread(idxFile, line))
	{
	    format(file, 48, MAZ_DAT_FILE, line);
	    datFile = fopen(file, io_read);
	    while(fread(datFile, data))
	    {
	    }
	    fclose(datFile);
	}
	
	fclose(idxFile);
}

maz_Build()
{
	new
		xLoop,
		yLoop,
		idx;

	while(yLoop < MAZ_SIZE_Y)
	{
	    // Make a wall around the edge by checking if the current X/Y is either.
	    // At 0 (X far left, Y bottom) or MAZ_SIZE_*-1 (X far right, Y top).
	    // Then setting the right bits for the correct walls.
	    // For instance, the south (Y = 0) has all south side walls.
	    if(yLoop == 0)maz_WallData{idx} |= MAZ_S_WALL;
	    if(yLoop == MAZ_SIZE_Y-1)maz_WallData{idx} |= MAZ_N_WALL;
	    if(xLoop == 0)maz_WallData{idx} |= MAZ_W_WALL;
	    if(xLoop == MAZ_SIZE_X-1)maz_WallData{idx} |= MAZ_E_WALL;

		// Create the floor plates in a grid formation based on the size.
	    if(!IsValidDynamicObject(maz_FloorObj[idx]))
	    {
			maz_FloorObj[idx] = CreateDynamicObject(MAZ_LEVEL_MODEL,
				MAZ_ORIGIN_X + (xLoop*MAZ_OFFSET_X),
				MAZ_ORIGIN_Y + (yLoop*MAZ_OFFSET_Y),
				MAZ_ORIGIN_Z, 0.0, 0.0, 0.0);

			// TEMP
			SetDynamicObjectMaterial(maz_FloorObj[idx], 0, 19353, "all_walls", maz_Materials[27]);
		}
		
		// If the current floor square index is a start point, create it
		if(idx == maz_LevelData{0})
		{
		    if(IsValidDynamicObject(maz_StartObj))DestroyDynamicObject(maz_StartObj);
		    maz_StartObj = CreateDynamicObject(MAZ_START_MODEL,
				MAZ_ORIGIN_X + (xLoop*MAZ_OFFSET_X),
				MAZ_ORIGIN_Y + (yLoop*MAZ_OFFSET_Y),
				MAZ_ORIGIN_Z+1.0, 0.0, 0.0, 0.0);
		}
		// If the current floor square index is an end point, create it
		if(idx == maz_LevelData{1})
		{
		    if(IsValidDynamicObject(maz_EndObj))DestroyDynamicObject(maz_EndObj);
		    maz_EndObj = CreateDynamicObject(MAZ_END_MODEL,
				MAZ_ORIGIN_X + (xLoop*MAZ_OFFSET_X),
				MAZ_ORIGIN_Y + (yLoop*MAZ_OFFSET_Y),
				MAZ_ORIGIN_Z+1.0, 0.0, 0.0, 0.0);
		}

		// The following four if statements check the bits of the wall data
		// If a bit is set, a wall is created, each floor square has 4 bits
		// of wall data (north, east, south, west)
		if(maz_WallData{idx} & MAZ_N_WALL)
		{
		    if(!IsValidDynamicObject(maz_WallsObj[idx][0]))
		    {
			    maz_WallsObj[idx][0] = CreateDynamicObject(MAZ_LEVEL_MODEL,
					MAZ_ORIGIN_X + (xLoop*MAZ_OFFSET_X) + maz_Offsets[0][0],
					MAZ_ORIGIN_Y + (yLoop*MAZ_OFFSET_Y) + maz_Offsets[0][1],
					MAZ_ORIGIN_Z + MAZ_WALL_Z, 90.0, 90.0, maz_Offsets[0][2]);
			}
		}
		else
		{
			if(IsValidDynamicObject(maz_WallsObj[idx][0]))DestroyDynamicObject(maz_WallsObj[idx][0]);
		}

		if(maz_WallData{idx} & MAZ_E_WALL)
		{
		    if(!IsValidDynamicObject(maz_WallsObj[idx][1]))
		    {
			    maz_WallsObj[idx][1] = CreateDynamicObject(MAZ_LEVEL_MODEL,
					MAZ_ORIGIN_X + (xLoop*MAZ_OFFSET_X) + maz_Offsets[1][0],
					MAZ_ORIGIN_Y + (yLoop*MAZ_OFFSET_Y) + maz_Offsets[1][1],
					MAZ_ORIGIN_Z + MAZ_WALL_Z, 90.0, 90.0, maz_Offsets[1][2]);
			}
		}
		else
		{
			if(IsValidDynamicObject(maz_WallsObj[idx][1]))DestroyDynamicObject(maz_WallsObj[idx][1]);
		}

		if(maz_WallData{idx} & MAZ_S_WALL)
		{
		    if(!IsValidDynamicObject(maz_WallsObj[idx][2]))
		    {
			    maz_WallsObj[idx][2] = CreateDynamicObject(MAZ_LEVEL_MODEL,
					MAZ_ORIGIN_X + (xLoop*MAZ_OFFSET_X) + maz_Offsets[2][0],
					MAZ_ORIGIN_Y + (yLoop*MAZ_OFFSET_Y) + maz_Offsets[2][1],
					MAZ_ORIGIN_Z + MAZ_WALL_Z, 90.0, 90.0, maz_Offsets[2][2]);
			}
		}
		else
		{
			if(IsValidDynamicObject(maz_WallsObj[idx][2]))DestroyDynamicObject(maz_WallsObj[idx][2]);
		}

		if(maz_WallData{idx} & MAZ_W_WALL)
		{
		    if(!IsValidDynamicObject(maz_WallsObj[idx][3]))
		    {
				maz_WallsObj[idx][3] = CreateDynamicObject(MAZ_LEVEL_MODEL,
					MAZ_ORIGIN_X + (xLoop*MAZ_OFFSET_X) + maz_Offsets[3][0],
					MAZ_ORIGIN_Y + (yLoop*MAZ_OFFSET_Y) + maz_Offsets[3][1],
					MAZ_ORIGIN_Z + MAZ_WALL_Z, 90.0, 90.0, maz_Offsets[3][2]);
			}
		}
		else
		{
			if(IsValidDynamicObject(maz_WallsObj[idx][3]))DestroyDynamicObject(maz_WallsObj[idx][3]);
		}


		// TEMP
		for(new i;i<4;i++)SetDynamicObjectMaterial(maz_WallsObj[idx][i], 0, 19353, "all_walls", maz_Materials[4]);

		xLoop++;
		idx++;

		// If the X reaches the edge, set it back to 0 and increase the Y.
		if(xLoop == MAZ_SIZE_X)
		{
		    xLoop = 0;
			yLoop++;
		}
	}
}
maz_Delete()
{
	new idx;
	while(idx < MAZ_SIZE_X * MAZ_SIZE_Y)
	{
	    if(IsValidDynamicObject(maz_FloorObj[idx]))DestroyDynamicObject(maz_FloorObj[idx]);
		for(new w;w<4;w++)if(IsValidDynamicObject(maz_WallsObj[idx][w]))DestroyDynamicObject(maz_WallsObj[idx][w]);
	    idx++;
	}
}

maz_EnterEditMode(playerid)
{
    gPlayerCurrentSq[playerid] = 0;
	new
	    Float:x,
	    Float:y,
	    Float:z;

	GetDynamicObjectPos(maz_FloorObj[ 0 ], x, y, z);
	SetPlayerPos(playerid, x, y, z+1.5);
	TogglePlayerControllable(playerid, false);
	maz_UpdateEditCamera(playerid);
	SelectTextDraw(playerid, YELLOW);
	
	maz_LoadPlayerTextDraws(playerid);
	maz_ShowEditControls(playerid);
}
maz_ExitEditMode(playerid)
{
	gPlayerCurrentSq[playerid] = -1;
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
	CancelSelectTextDraw(playerid);

	maz_UnloadPlayerTextDraws(playerid);
	maz_HideEditControls(playerid);
}
maz_UpdateEditCamera(playerid)
{
	new
	    Float:x,
	    Float:y,
	    Float:z;

	GetDynamicObjectPos(maz_FloorObj[ gPlayerCurrentSq[playerid] ], x, y, z);

	SetPlayerPos(playerid, x, y, z+1.5);
	SetPlayerCameraPos(playerid, x, y-0.1, z+30.0);
	SetPlayerCameraLookAt(playerid, x, y, z);

}
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == maz_TdMoveU)maz_MoveEditor(playerid, MAZ_EDIT_UP);
	if(playertextid == maz_TdMoveD)maz_MoveEditor(playerid, MAZ_EDIT_DOWN);
	if(playertextid == maz_TdMoveL)maz_MoveEditor(playerid, MAZ_EDIT_LEFT);
	if(playertextid == maz_TdMoveR)maz_MoveEditor(playerid, MAZ_EDIT_RIGHT);
	
    new idx = gPlayerCurrentSq[playerid];

	if(playertextid == maz_TdWallN)
	{
		if(maz_WallData{idx} & MAZ_N_WALL)
		{
			maz_WallData{idx} &=~ MAZ_N_WALL;
			maz_Build();
			PlayerTextDrawColor(playerid, maz_TdWallN, -176);
		}
		else
		{
			maz_WallData{idx} |= MAZ_N_WALL;
			maz_Build();
			PlayerTextDrawColor(playerid, maz_TdWallN, -1);
		}
		maz_ShowEditControls(playerid);
		Streamer_Update(playerid);
	}
	if(playertextid == maz_TdWallS)
	{
		if(maz_WallData{idx} & MAZ_S_WALL)
		{
			maz_WallData{idx} &=~ MAZ_S_WALL;
			maz_Build();
			PlayerTextDrawColor(playerid, maz_TdWallS, -176);
		}
		else
		{
			maz_WallData{idx} |= MAZ_S_WALL;
			maz_Build();
			PlayerTextDrawColor(playerid, maz_TdWallS, -1);
		}
		maz_ShowEditControls(playerid);
		Streamer_Update(playerid);
	}
	if(playertextid == maz_TdWallE)
	{
		if(maz_WallData{idx} & MAZ_E_WALL)
		{
			maz_WallData{idx} &=~ MAZ_E_WALL;
			maz_Build();
			PlayerTextDrawColor(playerid, maz_TdWallE, -176);
		}
		else
		{
			maz_WallData{idx} |= MAZ_E_WALL;
			maz_Build();
			PlayerTextDrawColor(playerid, maz_TdWallE, -1);
		}
		maz_ShowEditControls(playerid);
		Streamer_Update(playerid);
	}
	if(playertextid == maz_TdWallW)
	{
		if(maz_WallData{idx} & MAZ_W_WALL)
		{
			maz_WallData{idx} &=~ MAZ_W_WALL;
			maz_Build();
			PlayerTextDrawColor(playerid, maz_TdWallW, -176);
		}
		else
		{
			maz_WallData{idx} |= MAZ_W_WALL;
			maz_Build();
			PlayerTextDrawColor(playerid, maz_TdWallW, -1);
		}
		maz_ShowEditControls(playerid);
		Streamer_Update(playerid);
	}
}
maz_MoveEditor(playerid, direction)
{
	if(direction == MAZ_EDIT_UP)
	{
	    if(gPlayerCurrentSq[playerid] + MAZ_SIZE_X < MAZ_SIZE_X*MAZ_SIZE_Y)
	    {
	    	gPlayerCurrentSq[playerid] += MAZ_SIZE_X;
			maz_UpdateEditCamera(playerid);
		}
		else
		{
	    	gPlayerCurrentSq[playerid] -= (MAZ_SIZE_X * MAZ_SIZE_Y) - MAZ_SIZE_X;
			maz_UpdateEditCamera(playerid);
		}
	}
	else if(direction == MAZ_EDIT_DOWN)
	{
	    if(gPlayerCurrentSq[playerid] - MAZ_SIZE_X >= 0)
	    {
	    	gPlayerCurrentSq[playerid] -= MAZ_SIZE_X;
			maz_UpdateEditCamera(playerid);
		}
		else
		{
	    	gPlayerCurrentSq[playerid] += (MAZ_SIZE_X * MAZ_SIZE_Y) - MAZ_SIZE_X;
			maz_UpdateEditCamera(playerid);
		}
	}
	else if(direction == MAZ_EDIT_LEFT)
	{
	    if(gPlayerCurrentSq[playerid] % MAZ_SIZE_X == 0)
		{
	    	gPlayerCurrentSq[playerid] += MAZ_SIZE_X-1;
			maz_UpdateEditCamera(playerid);
		}
	    else
	    {
		    gPlayerCurrentSq[playerid] -= 1;
			maz_UpdateEditCamera(playerid);
		}
	}
	else if(direction == MAZ_EDIT_RIGHT)
	{
	    if((gPlayerCurrentSq[playerid]+1) % MAZ_SIZE_X == 0)
	    {
	    	gPlayerCurrentSq[playerid] -= MAZ_SIZE_X-1;
			maz_UpdateEditCamera(playerid);
		}
		else
		{
		    gPlayerCurrentSq[playerid] += 1;
			maz_UpdateEditCamera(playerid);
		}
	}
	maz_UpdateWallTD(playerid);
	return 1;
}
maz_UpdateWallTD(playerid)
{
    new idx = gPlayerCurrentSq[playerid];

	if(maz_WallData{idx} & MAZ_N_WALL)PlayerTextDrawColor(playerid, maz_TdWallN, -1);
	else if(!(maz_WallData{idx} & MAZ_N_WALL))PlayerTextDrawColor(playerid, maz_TdWallN, -176);

	if(maz_WallData{idx} & MAZ_E_WALL)PlayerTextDrawColor(playerid, maz_TdWallE, -1);
	else if(!(maz_WallData{idx} & MAZ_E_WALL))PlayerTextDrawColor(playerid, maz_TdWallE, -176);

	if(maz_WallData{idx} & MAZ_S_WALL)PlayerTextDrawColor(playerid, maz_TdWallS, -1);
	else if(!(maz_WallData{idx} & MAZ_S_WALL))PlayerTextDrawColor(playerid, maz_TdWallS, -176);

	if(maz_WallData{idx} & MAZ_W_WALL)PlayerTextDrawColor(playerid, maz_TdWallW, -1);
	else if(!(maz_WallData{idx} & MAZ_W_WALL))PlayerTextDrawColor(playerid, maz_TdWallW, -176);

	maz_ShowEditControls(playerid);
}

CMD:edit(playerid, params[])
{
	maz_EnterEditMode(playerid);
	return 1;
}
CMD:exitedit(playerid, params[])
{
	maz_ExitEditMode(playerid);
	return 1;
}

CMD:walls(playerid, params[])
{
	new walls;
	if(sscanf(params, "b", walls))return msg(playerid, -1, "walls: bData");
	
	maz_WallData{edit} = walls;
	
	maz_Build();

	return 1;
}

CMD:setstart(playerid, params[])
{
	maz_LevelData{0} = strval(params);
	maz_Build();
	return 1;
}
CMD:setend(playerid, params[])
{
	maz_LevelData{1} = strval(params);
	maz_Build();
	return 1;
}

maz_ShowEditControls(playerid)
{
	PlayerTextDrawShow(playerid, maz_TdMoveU);
	PlayerTextDrawShow(playerid, maz_TdMoveD);
	PlayerTextDrawShow(playerid, maz_TdMoveL);
	PlayerTextDrawShow(playerid, maz_TdMoveR);
	PlayerTextDrawShow(playerid, maz_TdWallN);
	PlayerTextDrawShow(playerid, maz_TdWallS);
	PlayerTextDrawShow(playerid, maz_TdWallE);
	PlayerTextDrawShow(playerid, maz_TdWallW);
}
maz_HideEditControls(playerid)
{
	PlayerTextDrawHide(playerid, maz_TdMoveU);
	PlayerTextDrawHide(playerid, maz_TdMoveD);
	PlayerTextDrawHide(playerid, maz_TdMoveL);
	PlayerTextDrawHide(playerid, maz_TdMoveR);
	PlayerTextDrawHide(playerid, maz_TdWallN);
	PlayerTextDrawHide(playerid, maz_TdWallS);
	PlayerTextDrawHide(playerid, maz_TdWallE);
	PlayerTextDrawHide(playerid, maz_TdWallW);
}
maz_LoadPlayerTextDraws(playerid)
{
	maz_TdMoveU						=CreatePlayerTextDraw(playerid, 60.000000, 240.000000, "~u~");
	PlayerTextDrawBackgroundColor	(playerid, maz_TdMoveU, 255);
	PlayerTextDrawFont				(playerid, maz_TdMoveU, 1);
	PlayerTextDrawLetterSize		(playerid, maz_TdMoveU, 1.000000, 3.000000);
	PlayerTextDrawColor				(playerid, maz_TdMoveU, -1);
	PlayerTextDrawSetOutline		(playerid, maz_TdMoveU, 0);
	PlayerTextDrawSetProportional	(playerid, maz_TdMoveU, 1);
	PlayerTextDrawSetShadow			(playerid, maz_TdMoveU, 1);
	PlayerTextDrawTextSize			(playerid, maz_TdMoveU, 80.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, maz_TdMoveU, true);

	maz_TdMoveD						=CreatePlayerTextDraw(playerid, 60.000000, 290.000000, "~d~");
	PlayerTextDrawBackgroundColor	(playerid, maz_TdMoveD, 255);
	PlayerTextDrawFont				(playerid, maz_TdMoveD, 1);
	PlayerTextDrawLetterSize		(playerid, maz_TdMoveD, 1.000000, 3.000000);
	PlayerTextDrawColor				(playerid, maz_TdMoveD, -1);
	PlayerTextDrawSetOutline		(playerid, maz_TdMoveD, 0);
	PlayerTextDrawSetProportional	(playerid, maz_TdMoveD, 1);
	PlayerTextDrawSetShadow			(playerid, maz_TdMoveD, 1);
	PlayerTextDrawTextSize			(playerid, maz_TdMoveD, 80.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, maz_TdMoveD, true);

	maz_TdMoveL						=CreatePlayerTextDraw(playerid, 40.000000, 265.000000, "~<~");
	PlayerTextDrawBackgroundColor	(playerid, maz_TdMoveL, 255);
	PlayerTextDrawFont				(playerid, maz_TdMoveL, 1);
	PlayerTextDrawLetterSize		(playerid, maz_TdMoveL, 1.000000, 3.000000);
	PlayerTextDrawColor				(playerid, maz_TdMoveL, -1);
	PlayerTextDrawSetOutline		(playerid, maz_TdMoveL, 0);
	PlayerTextDrawSetProportional	(playerid, maz_TdMoveL, 1);
	PlayerTextDrawSetShadow			(playerid, maz_TdMoveL, 1);
	PlayerTextDrawTextSize			(playerid, maz_TdMoveL, 60.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, maz_TdMoveL, true);

	maz_TdMoveR						=CreatePlayerTextDraw(playerid, 80.000000, 265.000000, "~>~");
	PlayerTextDrawBackgroundColor	(playerid, maz_TdMoveR, 255);
	PlayerTextDrawFont				(playerid, maz_TdMoveR, 1);
	PlayerTextDrawLetterSize		(playerid, maz_TdMoveR, 1.000000, 3.000000);
	PlayerTextDrawColor				(playerid, maz_TdMoveR, -1);
	PlayerTextDrawSetOutline		(playerid, maz_TdMoveR, 0);
	PlayerTextDrawSetProportional	(playerid, maz_TdMoveR, 1);
	PlayerTextDrawSetShadow			(playerid, maz_TdMoveR, 1);
	PlayerTextDrawTextSize			(playerid, maz_TdMoveR, 100.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, maz_TdMoveR, true);



	maz_TdWallN						=CreatePlayerTextDraw(playerid, 130.000000, 240.000000, "-");
	PlayerTextDrawBackgroundColor	(playerid, maz_TdWallN, 255);
	PlayerTextDrawFont				(playerid, maz_TdWallN, 1);
	PlayerTextDrawLetterSize		(playerid, maz_TdWallN, 1.400000, 3.000000);
	PlayerTextDrawColor				(playerid, maz_TdWallN, -176);
	PlayerTextDrawSetOutline		(playerid, maz_TdWallN, 1);
	PlayerTextDrawSetProportional	(playerid, maz_TdWallN, 1);
	PlayerTextDrawTextSize			(playerid, maz_TdWallN, 150.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, maz_TdWallN, true);

	maz_TdWallS						=CreatePlayerTextDraw(playerid, 130.000000, 286.000000, "-");
	PlayerTextDrawBackgroundColor	(playerid, maz_TdWallS, 255);
	PlayerTextDrawFont				(playerid, maz_TdWallS, 1);
	PlayerTextDrawLetterSize		(playerid, maz_TdWallS, 1.400000, 3.000000);
	PlayerTextDrawColor				(playerid, maz_TdWallS, -176);
	PlayerTextDrawSetOutline		(playerid, maz_TdWallS, 1);
	PlayerTextDrawSetProportional	(playerid, maz_TdWallS, 1);
	PlayerTextDrawTextSize			(playerid, maz_TdWallS, 150.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, maz_TdWallS, true);

	maz_TdWallE						=CreatePlayerTextDraw(playerid, 157.000000, 266.000000, "l");
	PlayerTextDrawBackgroundColor	(playerid, maz_TdWallE, 255);
	PlayerTextDrawFont				(playerid, maz_TdWallE, 1);
	PlayerTextDrawLetterSize		(playerid, maz_TdWallE, 0.679999, 3.000000);
	PlayerTextDrawColor				(playerid, maz_TdWallE, -176);
	PlayerTextDrawSetOutline		(playerid, maz_TdWallE, 1);
	PlayerTextDrawSetProportional	(playerid, maz_TdWallE, 1);
	PlayerTextDrawTextSize			(playerid, maz_TdWallE, 163.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, maz_TdWallE, true);

	maz_TdWallW						=CreatePlayerTextDraw(playerid, 117.000000, 266.000000, "l");
	PlayerTextDrawBackgroundColor	(playerid, maz_TdWallW, 255);
	PlayerTextDrawFont				(playerid, maz_TdWallW, 1);
	PlayerTextDrawLetterSize		(playerid, maz_TdWallW, 0.679999, 3.000000);
	PlayerTextDrawColor				(playerid, maz_TdWallW, -176);
	PlayerTextDrawSetOutline		(playerid, maz_TdWallW, 1);
	PlayerTextDrawSetProportional	(playerid, maz_TdWallW, 1);
	PlayerTextDrawTextSize			(playerid, maz_TdWallW, 123.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, maz_TdWallW, true);
}

maz_UnloadPlayerTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid, maz_TdMoveU);
	PlayerTextDrawDestroy(playerid, maz_TdMoveD);
	PlayerTextDrawDestroy(playerid, maz_TdMoveL);
	PlayerTextDrawDestroy(playerid, maz_TdMoveR);
	PlayerTextDrawDestroy(playerid, maz_TdWallN);
	PlayerTextDrawDestroy(playerid, maz_TdWallS);
	PlayerTextDrawDestroy(playerid, maz_TdWallE);
	PlayerTextDrawDestroy(playerid, maz_TdWallW);
}
