#define FILTERSCRIPT

#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS (32)

#include <streamer>
#include <sscanf2>
#include <zcmd>
#include <foreach>
#include <colours>
#include <FileManager>
#define msg SendClientMessage

#define MAX_MATERIAL_SIZE	14
#define MAX_MATERIAL_LEN	8

#define MAX_DATA_OBJ		(16)
#define OBJ_EVENT_MOV		(0)
#define OBJ_EVENT_CRT		(1)
#define OBJ_EVENT_DEL		(2)

#define MAX_MAPS			(100)				// Total amount of map files that can be loaded to cache
#define INDEX_FILE			"Maps/mapindex.txt"	// Index file location (This doesn't affect the map file location)

#define strcpy(%0,%1)		strcat((%0[0] = '\0', %0), %1)

//#include "../scripts/Releases/Button/Button.pwn"

forward CloseDoor(objectid, playerid);
forward togcont(playerid);

enum E_MOV_DATA
{
	Float:mov_posX,
	Float:mov_posY,
	Float:mov_posZ,
	Float:mov_Speed,
	mov_Time,
	Float:mov_rotX,
	Float:mov_rotY,
	Float:mov_rotZ
}
enum E_BTN_DATA
{
    btn_ID,
    btn_valid,
	btn_objID,
	btn_dataID,
	Float:btn_posX,
	Float:btn_posY,
	Float:btn_posZ,
	btn_msg[128]
}
enum E_ZON_DATA
{
	zon_ID,
	zon_valid,
	zon_objID,
	zon_dataID,
	Float:zon_maxX,
	Float:zon_minX,
	Float:zon_maxY,
	Float:zon_minY,
	zon_Msg[128]
}
/*
new
	objEventType[MAX_DATA_OBJ],
	// Events
	tmpMovIdx,
	objMovData[MAX_DATA_OBJ][E_MOV_DATA],
	// Triggers
	trgBtnIdx,
	trgBtnData[MAX_DATA_OBJ][E_BTN_DATA],
	trgZonIdx,
	trgZonData[MAX_DATA_OBJ][E_ZON_DATA];
*/

new
	lv_HouseGate,
	lv_CastleGates[10],
	sf_LoadingBayDoor,
	des_WhShutter[5],
	des_FenceGate,
	
	obj_GlobalID;


stock Float:Distance(Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2)return floatpower((floatpower((x1-x2),2)+floatpower((y1-y2),2)+floatpower((z1-z2),2)), 0.5);
// Load an individual map file (used to load each map in index)
LoadMap(mapfile[])
{
	new filename[100];
	format(filename, 100, "Maps/%s", mapfile);

	new
		File:F=fopen(filename, io_read),
		loadedmeta,
		str[192],
		
		world,
		interior,
		streamdist,

		modelid,
		Float:data[6],
		line,
		
		tmpObjID,
		tmpObjIdx,
		tmpObjMod,
		tmpObjTxd[32],
		tmpObjTex[32],
		tmpObjMatCol,

		tmpObjText[128],
		tmpObjResName[32],
		tmpObjRes,
		tmpObjFont[32],
		tmpObjFontSize,
		tmpObjBold,
		tmpObjFontCol,
		tmpObjBackCol,
		tmpObjAlign,

		matSizeTable[MAX_MATERIAL_SIZE][MAX_MATERIAL_LEN] =
	    {
			"32x32",
			"64x32",
			"64x64",
			"128x32",
			"128x64",
			"128x128",
			"256x32",
			"256x64",
			"256x128",
			"256x256",
			"512x64",
			"512x128",
			"512x256",
			"512x512"
	    };

	if(!fexist(filename))return printf("ERROR: file: \"%s\" NOT FOUND", filename);

	while(fread(F, str))
	{
		line++;
		if(!loadedmeta)
		{
			if(!sscanf(str, "p<,>ddd", world, interior, streamdist))
				loadedmeta = true;

			if(line > 1)
			{
				printf("ERROR: Map file '%s' metadata must be defined on first line", filename);
				break;
			}
		}
		if(!sscanf(str, "p<(>{s[20]}p<,>dfffffp<)>f{s[4]}",
			modelid, data[0], data[1], data[2], data[3], data[4], data[5]))
		{
			//For finding missing objects
			/*
		    */
		    new Float:d=Distance(data[0], data[1], data[2], -260.7864, 1192.7984, 19.7559);
		    if(d<=50)printf("obj found in '%s' id: %d", filename, modelid);

			tmpObjID = CreateDynamicObject(modelid, data[0], data[1], data[2], data[3], data[4], data[5], world, interior, _, streamdist);
			obj_GlobalID++;
		}
		else if(!sscanf(str, "'objtxt(' p<\">{s[1]}s[32]p<,>{s[1]} ds[32]p<\">{s[1]}s[32]p<,>{s[1]}ddddp<)>d",
			tmpObjText, tmpObjIdx, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign))
		{
		    new len = strlen(tmpObjText);

			for(new i;i<sizeof matSizeTable;i++)
				if(strfind(tmpObjResName, matSizeTable[i]) != -1)
					tmpObjRes = (i + 1) * 10;

			for(new c;c<len;c++)
			{ // The end bit on this statement prevents invalid memory access, for instance if this loop reaches the last cell and tries to access c+1
			    if(tmpObjText[c] == '\\' && c != len-1)
				{
				    if(tmpObjText[c+1] == 'n')
				    {
						strdel(tmpObjText, c, c+1);
						tmpObjText[c] = '\n';
				    }
				    // I will add more if needed, like the \t or any others that people suggest!
			    }
			}

			SetDynamicObjectMaterialText(tmpObjID, tmpObjIdx, tmpObjText, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
		}
		else if(!sscanf(str, "'objmat('p<,>dd p<\">{s[1]}s[32]p<,>{s[1]} p<\">{s[1]}s[32]p<,>{s[1]} p<)>d",
								tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol))
		{
			SetDynamicObjectMaterial(tmpObjID, tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol);
		}
	}
	fclose(F);

/*
	I think this is a means of converting
	new File:tmpF = fopen(INDEX_FILE, io_append), tmpStr[100];
	format(tmpStr, 100, "%s, %d, %d, %f\r\n", mapfile, world, interior, dist);
	fwrite(tmpF, tmpStr);
	fclose(tmpF);
*/

	return line;
}
// Load maps from index
LoadAllMaps()
{
	new
		dir:dHandle1 = dir_open("./scriptfiles/Maps/"),
		dir:dHandle2,
		item1[40],
		item2[40],
		type,
		tmpdir[128],
		tmpfilename[128];

	while(dir_list(dHandle1, item1, type))
	{
		if(type == FM_DIR && strcmp(item1, "..") && strcmp(item1, ".") && strcmp(item1, "_"))
		{
			tmpdir = "./scriptfiles/Maps/";
			strcat(tmpdir, item1);
			strcat(tmpdir, "/");

			dHandle2 = dir_open(tmpdir);

			while(dir_list(dHandle2, item2, type))
			{
				if(type == FM_FILE)
				{
				    tmpfilename[0] = EOS;
					strcat(tmpfilename, item1);
					strcat(tmpfilename, "/");
					strcat(tmpfilename, item2);
					LoadMap(tmpfilename);
				}
			}

			dir_close(dHandle2);
		}
	}

	dir_close(dHandle1);
}

#define FREEROAM_WORLD		(0)
#define DEATHMATCH_WORLD	(1)
#define RACE_WORLD			(2)
#define ABD_WORLD			(3)


public OnFilterScriptInit()
{
	print("\n---------------------------");
	print(" Object Placement Script Loaded");

    LoadAllMaps();

	// These load all the little extras like objects with key IDs (for use with MoveDynamicObject etc)
	LoadObjects();


	print("  ----  Object Data  ----  ");
	printf("   %d\t- Total Objects", CountDynamicObjects());
	print("---------------------------\n");

	for(new i;i<MAX_PLAYERS;i++)RemoveObjects(i);

	return 1;
}

public OnPlayerSpawn(playerid)
{
	RemoveObjects(playerid);
}

public togcont(playerid)TogglePlayerControllable(playerid, 1);
#define Cmd(%1) if(!strcmp(cmd,%1,true,strlen(%1))&&cmd[strlen(%1)+1]==EOS)


new
	Boxes[1000][1000],
	Float:BOX_OFFSET = 1.4,
	MAX_BOXES = 20;


public OnPlayerCommandText(playerid, cmdtext[])
{
	new cmd[30], params[100];
	sscanf(cmdtext, "s[30]s[100]", cmd, params);
	

	Cmd("/makeboxes")
	{
		for(new x;x<MAX_BOXES;x++)
		{
			for(new y;y<MAX_BOXES;y++)
			{
				Boxes[x][y] = CreateDynamicObject(1224, (x*BOX_OFFSET), (y*BOX_OFFSET), 10.00,   0.00, 0.00, 0.00, .streamdistance = 1000.0);
			}
		}
		return 1;
	}
	Cmd("/resetboxes")
	{
		for(new x;x<MAX_BOXES;x++)
		{
			for(new y;y<MAX_BOXES;y++)
			{
				SetDynamicObjectPos(Boxes[x][y], (x*BOX_OFFSET), (y*BOX_OFFSET), 10.00);
			}
		}
	}
	Cmd("/destroyboxes")
	{
		for(new x;x<MAX_BOXES;x++)
		{
			for(new y;y<MAX_BOXES;y++)
			{
				DestroyDynamicObject(Boxes[x][y]);
			}
		}
		return 1;
	}
	Cmd("/setoffset")
	{
	    BOX_OFFSET = floatstr(params);
		for(new x;x<MAX_BOXES;x++)
		{
			for(new y;y<MAX_BOXES;y++)
			{
				SetDynamicObjectPos(Boxes[x][y], (x*BOX_OFFSET), (y*BOX_OFFSET), 10.00);
			}
		}
	    return 1;
	}
	Cmd("/setmaxbox")
	{
	    MAX_BOXES = strval(params);
	    return 1;
	}

	Cmd("/camtest1")
	{
	    SetPlayerPos(playerid, 2523.975, -1749.962, 57.202);
	    TogglePlayerControllable(playerid, false);
	    InterpolateCameraPos(playerid, 2523.975, -1749.962, 57.202, 2277.878, -1313.666, 57.202, 40000, CAMERA_MOVE);
		InterpolateCameraLookAt(playerid, 2523.755, -1749.572, 56.3075, 2277.658, -1313.276, 56.3075, 40000, CAMERA_MOVE);
		return 1;
	}
	Cmd("/camtest2")
	{
	    SetPlayerPos(playerid, 2523.975, -1749.962, 57.202);
	    TogglePlayerControllable(playerid, false);
	    InterpolateCameraPos(playerid, 2523.9, -1749.9, 57.2, 2277.8, -1313.6, 57.2, 40000, CAMERA_MOVE);
		InterpolateCameraLookAt(playerid, 2523.7, -1749.5, 56.3, 2277.6, -1313.2, 56.3, 40000, CAMERA_MOVE);
		return 1;
	}

// Debug CMDs
	Cmd("/visob")		{printf("objects: %d", Streamer_CountVisibleItems(playerid, 0));return 1;}
	Cmd("/reob")		{Streamer_Update(playerid);return 1;}
	Cmd("/deadtown")	{SetPlayerPos(playerid, 1391.92, -1343.16, 352.33);return 1;}
	Cmd("/oilrig")		{SetPlayerPos(playerid, -1151.0, 117.0, 2571.0);return 1;}
	Cmd("/dmap")		{SetPlayerPos(playerid,1211.0, -2706.0, 1183.0);return 1;}
	Cmd("/rmap")		{SetPlayerPos(playerid, -521.0, -3643.0, 7.0);return 1;}
	Cmd("/wtf")			{SetPlayerPos(playerid, 2590.675781, 1210.633057, 864.794373);return 1;}
	Cmd("/skything")	{SetPlayerPos(playerid, 1766.1723632813, -2223.7202148438, 2897.2895507813);return 1;}
	

	//Warehouse des_WhShutters
    Cmd("/shutup")
	{
        MoveDynamicObject(des_WhShutter[0], -1481.880737, 2611.466553, 58.833641, 5.0);
        MoveDynamicObject(des_WhShutter[1], -1485.840820, 2615.600098, 58.983650, 5.0);
        MoveDynamicObject(des_WhShutter[2], -1485.797974, 2623.722412, 58.916321, 5.0);
        MoveDynamicObject(des_WhShutter[3], -1485.812622, 2631.457275, 58.908646, 5.0);
        MoveDynamicObject(des_WhShutter[4], -1485.790649, 2639.139404, 58.833641, 5.0);
        return 1;
    }
    Cmd("/shutdn")
	{
        MoveDynamicObject(des_WhShutter[0], -1481.880737, 2611.466553, 55.0, 5.0);
        MoveDynamicObject(des_WhShutter[1], -1485.840820, 2615.600098, 55.0, 5.0);
        MoveDynamicObject(des_WhShutter[2], -1485.797974, 2623.722412, 55.0, 5.0);
        MoveDynamicObject(des_WhShutter[3], -1485.812622, 2631.457275, 55.0, 5.0);
        MoveDynamicObject(des_WhShutter[4], -1485.790649, 2639.139404, 55.0, 5.0);
        return 1;
    }
	Cmd("/shutter")
	{
	    new dir, sht;
	    if(sscanf(params, "dd", dir, sht))return msg(playerid, YELLOW, "/shutter [up/down-1/0] [des_WhShutter]");
		if(sht==1)
		{
        	if(dir)MoveDynamicObject(des_WhShutter[0], -1481.880737, 2611.466553, 58.833641, 5.0);
        	else MoveDynamicObject(des_WhShutter[0], -1481.880737, 2611.466553, 55.0, 5.0);
		}
		else if(sht==2)
		{
		    if(dir)MoveDynamicObject(des_WhShutter[1], -1485.840820, 2615.600098, 58.983650, 5.0);
		    else MoveDynamicObject(des_WhShutter[1], -1485.840820, 2615.600098, 55.0, 5.0);
		}
		else if(sht==3)
		{
		    if(dir)MoveDynamicObject(des_WhShutter[2], -1485.797974, 2623.722412, 58.916321, 5.0);
		    else MoveDynamicObject(des_WhShutter[2], -1485.797974, 2623.722412, 55.0, 5.0);
		}
		else if(sht==4)
		{
		    if(dir)MoveDynamicObject(des_WhShutter[3], -1485.812622, 2631.457275, 58.908646, 5.0);
		    else MoveDynamicObject(des_WhShutter[3], -1485.812622, 2631.457275, 55.0, 5.0);
		}
		else if(sht==5)
		{
		    if(dir)MoveDynamicObject(des_WhShutter[4], -1485.790649, 2639.139404, 58.833641, 5.0);
		    else MoveDynamicObject(des_WhShutter[4], -1485.790649, 2639.139404, 55.0, 5.0);
		}
		return 1;
    }
    return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if( ( (newkeys & KEY_CROUCH) && (IsPlayerInAnyVehicle(playerid)) ) || ( (newkeys == 16) && (!IsPlayerInAnyVehicle(playerid))) )
	{
	    if(IsPlayerInRangeOfPoint(playerid, 5.0, 2737.464600, 1188.553833, 6.932312) && IsPlayerAdmin(playerid))
	    {
            MoveDynamicObject(lv_HouseGate, 2740.464600, 1193.553833, 6.932312, 3.5);
            SetTimerEx("CloseDoor", 5000, false, "dd", lv_HouseGate, playerid);
	    }
	    if(IsPlayerInRangeOfPoint(playerid, 5.0, -1979.001953, 500.077972, 30.033659))
	    {
            MoveDynamicObject(sf_LoadingBayDoor, -1979.001953, 500.077972, 22.033659, 5);
            SetTimerEx("CloseDoor", 5000, false, "dd", sf_LoadingBayDoor);
		}
	    if(IsPlayerInRangeOfPoint(playerid, 30.0, 2105.195557, 1156.502930, 10) && IsPlayerAdmin(playerid))
	    {
			for(new i;i<10;i++)MoveDynamicObject(lv_CastleGates[i], 2089.163330, 1164.322021, 0.0, 3.5);
            SetTimerEx("CloseDoor", 5000, false, "dd", lv_CastleGates[0]);
		}
	    if(IsPlayerInRangeOfPoint(playerid, 15.0, -29.601196289063, 2514.2014160156, 9.0))
	    {
			MoveDynamicObject(des_FenceGate, -29.601196289063, 2514.2014160156, 10.0, 3.0);
			SetTimerEx("CloseDoor", 5000, false, "dd", des_FenceGate, playerid);
		}
	}
}
/*
OnButtonPress(playerid, buttonid)
{
	for(new b;b<MAX_DATA_OBJ;b++)
	{
		if(buttonid == trgBtnData[b][btn_ID] && trgBtnData[b][btn_valid])
		{
		    new
				tmpDataID = trgBtnData[b][btn_dataID];

		    if(objEventType[tmpDataID] == OBJ_EVENT_MOV)
		    {
		        MoveDynamicObject(trgBtnData[b][btn_objID],
					objMovData[tmpDataID][mov_posX], objMovData[tmpDataID][mov_posY], objMovData[tmpDataID][mov_posZ],
					objMovData[tmpDataID][mov_Speed]);
		    }
		    if(objEventType[tmpDataID] == OBJ_EVENT_DEL)
		    {
		        DestroyDynamicObject(trgBtnData[b][btn_objID]);
		    }

		    break;
		}
	}
}
*/
public CloseDoor(objectid, playerid)
{
	if(objectid==lv_CastleGates[0])for(new i;i<10;i++)MoveDynamicObject(lv_CastleGates[i], 2089.163330, 1164.322021, 12.270172, 3.5);
	if(objectid==lv_HouseGate)MoveDynamicObject(lv_HouseGate, 2737.464600, 1188.553833, 6.932312, 3.5);
	if(objectid==sf_LoadingBayDoor)MoveDynamicObject(sf_LoadingBayDoor,-1979.022339, 500.082306, 30.091356, 5);
	if(objectid==des_FenceGate)MoveDynamicObject(des_FenceGate,-29.601196289063, 2514.2014160156, 18.257766723633, 3.0);
}

CMD:removeobjects(playerid, params[])
{
    RemoveObjects(playerid);
    return 1;
}
RemoveObjects(playerid)
{
//	Mall
    
	RemoveBuildingForPlayer(playerid, 6130, 1117.5859, -1490.0078, 32.7188, 10.0); // Mall
	RemoveBuildingForPlayer(playerid, 6255, 1117.5859, -1490.0078, 32.7188, 10.0); // LOD
	RemoveBuildingForPlayer(playerid, 762, 1175.3594, -1420.1875, 19.8828, 0.25); // Tree
	RemoveBuildingForPlayer(playerid, 615, 1166.3516, -1417.6953, 13.9531, 0.25); // Tree
	RemoveBuildingForPlayer(playerid, 712, 1134.0781, -1500.3750, 22.2813, 0.25); // Oversized col tree
	RemoveBuildingForPlayer(playerid, 712, 1123.2500, -1500.5313, 22.2813, 0.25); // Oversized col tree
	RemoveBuildingForPlayer(playerid, 712, 1124.3672, -1476.9844, 22.2813, 0.25); // Oversized col tree
	RemoveBuildingForPlayer(playerid, 712, 1133.2266, -1476.2266, 22.2813, 0.25); // Oversized col tree

// Area 51
	RemoveBuildingForPlayer(playerid, 16094, 191.1406, 1870.0391, 21.4766, 0.25);

// Billboard in LS (Parkour route)
	RemoveBuildingForPlayer(playerid, 1261, 498.2578, -1363.0625, 30.0547, 0.25);
	RemoveBuildingForPlayer(playerid, 6353, 488.0156, -1382.4531, 36.1016, 0.25);
	RemoveBuildingForPlayer(playerid, 1267, 498.2578, -1363.0625, 30.0547, 0.25);

// Houses (Los Santos)
    RemoveBuildingForPlayer(playerid, 3589, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3592, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    RemoveBuildingForPlayer(playerid, 3648, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3647, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    RemoveBuildingForPlayer(playerid, 3646, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3706, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    RemoveBuildingForPlayer(playerid, 3642, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3720, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    RemoveBuildingForPlayer(playerid, 3555, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3563, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    RemoveBuildingForPlayer(playerid, 5626, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 5664, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    RemoveBuildingForPlayer(playerid, 3590, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3591, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    RemoveBuildingForPlayer(playerid, 3649, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3654, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    RemoveBuildingForPlayer(playerid, 5416, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 5672, 0.0, 0.0, 0.0, 10000.0); // LS house LOD

// Houses (San Fierro)
    RemoveBuildingForPlayer(playerid, 3821, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3832, 0.0, 0.0, 0.0, 10000.0); // SF house LOD
    RemoveBuildingForPlayer(playerid, 3824, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3835, 0.0, 0.0, 0.0, 10000.0); // SF house LOD
    RemoveBuildingForPlayer(playerid, 3827, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3838, 0.0, 0.0, 0.0, 10000.0); // SF house LOD
    RemoveBuildingForPlayer(playerid, 3825, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3841, 0.0, 0.0, 0.0, 10000.0); // SF house LOD
    RemoveBuildingForPlayer(playerid, 3826, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3840, 0.0, 0.0, 0.0, 10000.0); // SF house LOD
    RemoveBuildingForPlayer(playerid, 3822, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3833, 0.0, 0.0, 0.0, 10000.0); // SF house LOD
    RemoveBuildingForPlayer(playerid, 3844, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3848, 0.0, 0.0, 0.0, 10000.0); // SF house LOD
    RemoveBuildingForPlayer(playerid, 3830, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3836, 0.0, 0.0, 0.0, 10000.0); // SF house LOD

// Houses (Las Venturas)
    RemoveBuildingForPlayer(playerid, 3464, 0.0, 0.0, 0.0, 10000.0); // LV house
    RemoveBuildingForPlayer(playerid, 3536, 0.0, 0.0, 0.0, 10000.0); // LV house LOD
    RemoveBuildingForPlayer(playerid, 3445, 0.0, 0.0, 0.0, 10000.0); // LV house
    RemoveBuildingForPlayer(playerid, 3546, 0.0, 0.0, 0.0, 10000.0); // LV house LOD
    RemoveBuildingForPlayer(playerid, 3446, 0.0, 0.0, 0.0, 10000.0); // LV house
    RemoveBuildingForPlayer(playerid, 3547, 0.0, 0.0, 0.0, 10000.0); // LV house LOD
    RemoveBuildingForPlayer(playerid, 3443, 0.0, 0.0, 0.0, 10000.0); // LV house
    RemoveBuildingForPlayer(playerid, 3548, 0.0, 0.0, 0.0, 10000.0); // LV house LOD
}
LoadObjects()
{
//====================================================================San Fierro
    sf_LoadingBayDoor=CreateDynamicObject(16773, -1979.022339, 500.082306, 30.091356, 0.0000, 0.0000, 179.6223);

//==========================================================Las Venturas Hangout
    lv_CastleGates[0]=CreateDynamicObject(9625, 2089.163330, 1164.322021, 12.270172, 0.0000, 0.0000, 332.2660);
    lv_CastleGates[1]=CreateDynamicObject(5856, 2099.919922, 1168.348755, 12.653652, 0.0000, 0.0000, 62.3434);
    lv_CastleGates[2]=CreateDynamicObject(5856, 2103.648682, 1166.409912, 12.661411, 0.0000, 0.0000, 62.3434);
    lv_CastleGates[3]=CreateDynamicObject(5856, 2091.960449, 1152.877808, 12.653029, 0.0000, 0.0000, 62.3434);
    lv_CastleGates[4]=CreateDynamicObject(5856, 2095.686768, 1150.917358, 12.654610, 0.0000, 0.0000, 62.3434);
    lv_CastleGates[5]=CreateDynamicObject(5856, 2091.583984, 1169.010376, 11.826485, 0.0000, 0.0000, 333.2028);
    lv_CastleGates[6]=CreateDynamicObject(5856, 2086.585938, 1159.357056, 11.826485, 0.0000, 0.0000, 333.2028);
    lv_CastleGates[7]=CreateDynamicObject(5856, 2103.661865, 1153.614502, 12.652547, 0.0000, 0.0000, 331.4839);
    lv_CastleGates[8]=CreateDynamicObject(5856, 2106.245361, 1158.361206, 12.653348, 0.0000, 0.0000, 331.4839);
    lv_CastleGates[9]=CreateDynamicObject(5856, 2105.195557, 1156.502930, 12.617244, 0.0000, 0.0000, 331.4839);

//==================================================================El Quebrados
    des_WhShutter[0]=CreateDynamicObject(974, -1481.880737, 2611.466553, 58.833641, 0.0000, 0.0000, 0.0000);
    des_WhShutter[1]=CreateDynamicObject(974, -1485.840820, 2615.600098, 58.983650, 0.0000, 0.0000, 90.2408);
    des_WhShutter[2]=CreateDynamicObject(974, -1485.797974, 2623.722412, 58.916321, 0.0000, 0.0000, 90.2408);
    des_WhShutter[3]=CreateDynamicObject(974, -1485.812622, 2631.457275, 58.908646, 0.0000, 0.0000, 90.2408);
    des_WhShutter[4]=CreateDynamicObject(974, -1485.790649, 2639.139404, 58.833641, 0.0000, 0.0000, 90.2408);

	CreateDynamicObject(19312, 191.14, 1870.04, 21.48,   0.00, 0.00, 0.00); // A51 fence

//==================================================================Miscelaneous
	//carpark
    CreateDynamicObject(1523, 2272.010254, 1515.215820, 41.803089, 0.0000, 0.0000, 91.1003);
    CreateDynamicObject(1634, 2345.872070, 1685.359985, 19.194153, 0.0000, 0.0000, 0.0000);
    CreateDynamicObject(1634, 2349.341064, 1750.759766, 19.587948, 0.0000, 0.0000, 0.0000);
    CreateDynamicObject(1633, 2343.739990, 1548.405029, 36.781563, 0.0000, 0.0000, 177.0440);
    CreateDynamicObject(979, 2277.393066, 1518.464844, 42.435520, 0.0000, 0.0000, 269.7591);
    CreateDynamicObject(3458, 2299.685059, 1423.145630, 43.341843, 0.0000, 0.0000, 269.7591);
    CreateDynamicObject(1503, 2299.534424, 1450.143066, 42.214432, 0.0000, 0.0000, 181.3413);
    CreateDynamicObject(1503, 2301.102295, 1450.268555, 42.189430, 0.0000, 0.0000, 181.3413);
    CreateDynamicObject(12978, 2351.704834, 1504.643799, 42.211891, 0.0000, 0.0000, 0.0000);
    CreateDynamicObject(13027, 2351.771484, 1504.643433, 45.035313, 0.0000, 0.0000, 179.6223);
    CreateDynamicObject(11292, 2270.467773, 1518.181641, 43.279629, 0.0000, 0.0000, 89.3814);
    CreateDynamicObject(1633, 2348.532227, 1598.486816, 36.856567, 0.0000, 0.0000, 0.0000);
	//plane
    CreateDynamicObject(14548, 2590.675781, 1210.633057, 864.794373, 0.0000, 0.0000, 0.0000);
    CreateDynamicObject(14553, 2590.717041, 1206.893188, 865.002930, 0.0000, 0.0000, 0.0000);

	des_FenceGate=CreateDynamicObject(980, -29.6011, 2514.2014, 18.2577, 0, 0, 270.6756, ABD_WORLD);

	// Main mall mesh, interior areas
	CreateDynamicObject(19322, 1117.580, -1490.01, 32.72,   0.00, 0.00, 0.00);
	CreateDynamicObject(19323, 1117.580, -1490.01, 32.72,   0.00, 0.00, 0.00);
	// Mall windows
    CreateDynamicObject(19325, 1155.40, -1434.89, 16.49,   0.00, 0.00, 0.30);
	CreateDynamicObject(19325, 1155.37, -1445.41, 16.31,   0.00, 0.00, 0.00);
	CreateDynamicObject(19325, 1155.29, -1452.38, 16.31,   0.00, 0.00, 0.00);
	CreateDynamicObject(19325, 1157.36, -1468.35, 16.31,   0.00, 0.00, 18.66);
	CreateDynamicObject(19325, 1160.64, -1478.37, 16.31,   0.00, 0.00, 17.76);
	CreateDynamicObject(19325, 1159.84, -1502.06, 16.31,   0.00, 0.00, -19.92);
	CreateDynamicObject(19325, 1139.28, -1523.71, 16.31,   0.00, 0.00, -69.36);
	CreateDynamicObject(19325, 1117.06, -1523.43, 16.51,   0.00, 0.00, -109.44);
	CreateDynamicObject(19325, 1097.18, -1502.43, 16.51,   0.00, 0.00, -158.58);
	CreateDynamicObject(19325, 1096.47, -1478.29, 16.51,   0.00, 0.00, -197.94);
	CreateDynamicObject(19325, 1099.70, -1468.27, 16.51,   0.00, 0.00, -197.94);
	CreateDynamicObject(19325, 1101.81, -1445.45, 16.22,   0.00, 0.00, -180.24);
	CreateDynamicObject(19325, 1101.76, -1452.47, 16.22,   0.00, 0.00, -181.62);
	CreateDynamicObject(19325, 1101.77, -1434.88, 16.22,   0.00, 0.00, -180.24);
	CreateDynamicObject(19325, 1094.31, -1444.92, 23.47,   0.00, 0.00, -180.24);
	CreateDynamicObject(19325, 1094.37, -1458.37, 23.47,   0.00, 0.00, -179.46);
	CreateDynamicObject(19325, 1093.01, -1517.44, 23.44,   0.00, 0.00, -138.72);
	CreateDynamicObject(19325, 1101.08, -1526.64, 23.42,   0.00, 0.00, -137.34);
	CreateDynamicObject(19325, 1155.12, -1526.38, 23.46,   0.00, 0.00, -42.12);
	CreateDynamicObject(19325, 1163.09, -1517.25, 23.46,   0.00, 0.00, -40.74);
	CreateDynamicObject(19325, 1163.04, -1442.06, 23.40,   0.00, 0.00, -0.12);
	CreateDynamicObject(19325, 1163.09, -1428.47, 23.50,   0.00, 0.00, 0.54);

	// This is an example 24/7. Normally you'd want to stream these
	// interior objects in your streamer.

	// signs
	CreateDynamicObject(19326, 1155.34, -1446.73, 16.38,   0.00, 0.00, -89.82);
	CreateDynamicObject(19326, 1155.25, -1443.85, 16.36,   0.00, 0.00, -89.82);
	CreateDynamicObject(19326, 1155.37, -1436.32, 16.36,   0.00, 0.00, -89.82);
	CreateDynamicObject(19326, 1155.35, -1433.51, 16.36,   0.00, 0.00, -89.70);
	CreateDynamicObject(19329, 1155.18, -1440.22, 18.70,   0.00, 0.00, 89.04);
	CreateDynamicObject(19329, 1161.59, -1431.50, 17.93,   0.00, 0.00, 0.00);
	CreateDynamicObject(19329, 1160.40, -1448.79, 17.96,   0.00, 0.00, 0.00);

	// 24/7 food aisles
	CreateDynamicObject(2543, 1168.18, -1436.39, 14.79,   0.00, 0.00, 0.30);
	CreateDynamicObject(2535, 1182.74, -1448.30, 14.70,   0.00, 0.00, -90.96);
	CreateDynamicObject(2543, 1167.10, -1436.40, 14.79,   0.00, 0.00, 0.31);
	CreateDynamicObject(2538, 1172.31, -1435.32, 14.79,   0.00, 0.00, 180.34);
	CreateDynamicObject(2539, 1171.38, -1435.31, 14.79,   0.00, 0.00, 180.19);
	CreateDynamicObject(2540, 1169.56, -1435.36, 14.79,   0.00, 0.00, 180.17);
	CreateDynamicObject(1984, 1157.37, -1442.59, 14.79,   0.00, 0.00, -450.06);
	CreateDynamicObject(2012, 1163.25, -1448.31, 14.75,   0.00, 0.00, -179.16);
	CreateDynamicObject(2012, 1169.29, -1431.92, 14.75,   0.00, 0.00, 359.80);
	CreateDynamicObject(1987, 1163.13, -1436.34, 14.79,   0.00, 0.00, 361.06);
	CreateDynamicObject(1988, 1164.13, -1436.33, 14.79,   0.00, 0.00, 360.80);
	CreateDynamicObject(2871, 1164.79, -1443.96, 14.79,   0.00, 0.00, 177.73);
	CreateDynamicObject(2871, 1164.70, -1444.98, 14.79,   0.00, 0.00, 358.07);
	CreateDynamicObject(2942, 1155.52, -1464.68, 15.43,   0.00, 0.00, -71.22);
	CreateDynamicObject(1987, 1164.12, -1435.32, 14.77,   0.00, 0.00, 180.96);
	CreateDynamicObject(2530, 1171.13, -1443.79, 14.79,   0.00, 0.00, -182.16);
	CreateDynamicObject(1991, 1173.75, -1439.56, 14.79,   0.00, 0.00, 179.47);
	CreateDynamicObject(1996, 1169.82, -1439.50, 14.79,   0.00, 0.00, 179.10);
	CreateDynamicObject(1996, 1174.24, -1435.38, 14.79,   0.00, 0.00, 179.24);
	CreateDynamicObject(1991, 1175.23, -1435.39, 14.79,   0.00, 0.00, 179.57);
	CreateDynamicObject(1995, 1182.65, -1435.10, 14.79,   0.00, 0.00, 90.00);
	CreateDynamicObject(1994, 1182.66, -1438.07, 14.79,   0.00, 0.00, 90.00);
	CreateDynamicObject(1993, 1182.66, -1437.08, 14.79,   0.00, 0.00, 90.00);
	CreateDynamicObject(2542, 1163.78, -1443.92, 14.76,   0.00, 0.00, 178.77);
	CreateDynamicObject(2536, 1166.88, -1445.07, 14.70,   0.00, 0.00, -0.42);
	CreateDynamicObject(2542, 1163.70, -1444.93, 14.78,   0.00, 0.00, -1.74);
	CreateDynamicObject(1984, 1157.34, -1435.71, 14.79,   0.00, 0.00, -450.06);
	CreateDynamicObject(2012, 1166.31, -1448.28, 14.75,   0.00, 0.00, -180.12);
	CreateDynamicObject(2530, 1172.14, -1443.83, 14.79,   0.00, 0.00, -181.38);
	CreateDynamicObject(2530, 1173.14, -1443.85, 14.79,   0.00, 0.00, -180.96);
	CreateDynamicObject(2530, 1174.13, -1443.88, 14.79,   0.00, 0.00, -181.50);
	CreateDynamicObject(1981, 1170.76, -1439.52, 14.79,   0.00, 0.00, -181.74);
	CreateDynamicObject(1981, 1171.76, -1439.54, 14.79,   0.00, 0.00, -180.80);
	CreateDynamicObject(1981, 1172.75, -1439.55, 14.79,   0.00, 0.00, -180.84);
	CreateDynamicObject(2535, 1182.75, -1447.28, 14.70,   0.00, 0.00, -90.78);
	CreateDynamicObject(2535, 1182.74, -1446.28, 14.70,   0.00, 0.00, -90.78);
	CreateDynamicObject(2535, 1182.74, -1445.26, 14.70,   0.00, 0.00, -90.00);
	CreateDynamicObject(2541, 1182.75, -1444.22, 14.79,   0.00, 0.00, -90.06);
	CreateDynamicObject(2541, 1182.75, -1443.20, 14.79,   0.00, 0.00, -90.06);
	CreateDynamicObject(2541, 1182.74, -1442.16, 14.79,   0.00, 0.00, -90.06);
	CreateDynamicObject(2543, 1182.76, -1441.18, 14.79,   0.00, 0.00, -90.84);
	CreateDynamicObject(2541, 1182.79, -1440.17, 14.79,   0.00, 0.00, -90.06);
	CreateDynamicObject(2543, 1182.72, -1439.15, 14.79,   0.00, 0.00, -90.84);
	CreateDynamicObject(1990, 1182.66, -1431.67, 14.79,   0.00, 0.00, 3.30);
	CreateDynamicObject(1990, 1181.63, -1431.73, 14.79,   0.00, 0.00, 3.30);
	CreateDynamicObject(1990, 1180.61, -1431.81, 14.79,   0.00, 0.00, 3.30);
	CreateDynamicObject(1990, 1179.61, -1431.83, 14.79,   0.00, 0.00, 3.30);
	CreateDynamicObject(1990, 1178.61, -1431.89, 14.79,   0.00, 0.00, 3.30);
	CreateDynamicObject(1990, 1177.59, -1431.86, 14.79,   0.00, 0.00, 3.30);
	CreateDynamicObject(1993, 1182.66, -1436.09, 14.79,   0.00, 0.00, 90.00);
	CreateDynamicObject(2012, 1175.50, -1431.82, 14.75,   0.00, 0.00, 361.17);
	CreateDynamicObject(2012, 1172.42, -1431.87, 14.75,   0.00, 0.00, 359.93);
	CreateDynamicObject(2012, 1160.10, -1448.35, 14.75,   0.00, 0.00, -179.94);
	CreateDynamicObject(2539, 1170.45, -1435.33, 14.79,   0.00, 0.00, 181.26);
	CreateDynamicObject(2545, 1161.82, -1431.84, 14.91,   0.00, 0.00, -90.54);
	CreateDynamicObject(2545, 1160.82, -1431.83, 14.91,   0.00, 0.00, -90.54);
	CreateDynamicObject(2545, 1159.81, -1431.86, 14.91,   0.00, 0.00, -90.54);
	CreateDynamicObject(2545, 1162.82, -1431.87, 14.91,   0.00, 0.00, -90.54);
	CreateDynamicObject(1988, 1163.13, -1435.34, 14.79,   0.00, 0.00, 541.46);
	CreateDynamicObject(1988, 1166.07, -1436.32, 14.79,   0.00, 0.00, 360.80);
	CreateDynamicObject(1987, 1165.07, -1436.33, 14.79,   0.00, 0.00, 361.06);
	CreateDynamicObject(1987, 1166.11, -1435.30, 14.77,   0.00, 0.00, 180.96);
	CreateDynamicObject(1988, 1165.07, -1435.31, 14.79,   0.00, 0.00, 540.44);
	CreateDynamicObject(2536, 1165.79, -1445.07, 14.70,   0.00, 0.00, -1.20);
	CreateDynamicObject(2536, 1167.83, -1445.07, 14.70,   0.00, 0.00, -0.06);
	CreateDynamicObject(2871, 1165.79, -1444.00, 14.79,   0.00, 0.00, 178.27);
	CreateDynamicObject(2871, 1166.81, -1444.03, 14.79,   0.00, 0.00, 179.35);
	CreateDynamicObject(2871, 1167.79, -1444.04, 14.79,   0.00, 0.00, 179.89);
	CreateDynamicObject(2543, 1168.13, -1435.36, 14.79,   0.00, 0.00, 180.05);
	CreateDynamicObject(2543, 1167.10, -1435.37, 14.79,   0.00, 0.00, 180.35);
	CreateDynamicObject(2012, 1170.63, -1440.67, 14.75,   0.00, 0.00, 359.50);
	CreateDynamicObject(2012, 1173.77, -1440.72, 14.75,   0.00, 0.00, 359.82);
	CreateDynamicObject(2012, 1177.30, -1445.31, 14.75,   0.00, 0.00, 359.93);
	CreateDynamicObject(1996, 1173.36, -1448.30, 14.79,   0.00, 0.00, 179.10);
	CreateDynamicObject(1981, 1174.33, -1448.32, 14.79,   0.00, 0.00, -181.74);
	CreateDynamicObject(1981, 1175.32, -1448.35, 14.79,   0.00, 0.00, -180.84);
	CreateDynamicObject(1981, 1176.30, -1448.37, 14.79,   0.00, 0.00, -180.84);
	CreateDynamicObject(1991, 1177.28, -1448.37, 14.79,   0.00, 0.00, 179.47);
	CreateDynamicObject(1996, 1178.33, -1448.36, 14.79,   0.00, 0.00, 179.24);
	CreateDynamicObject(1991, 1179.33, -1448.37, 14.79,   0.00, 0.00, 179.57);
	CreateDynamicObject(1994, 1176.82, -1444.16, 14.79,   0.00, 0.00, -0.84);
	CreateDynamicObject(1995, 1178.81, -1444.20, 14.79,   0.00, 0.00, -1.26);
	CreateDynamicObject(2543, 1168.89, -1444.06, 14.79,   0.00, 0.00, 178.97);
	CreateDynamicObject(2543, 1169.91, -1444.07, 14.79,   0.00, 0.00, 179.69);
	CreateDynamicObject(2543, 1169.87, -1445.12, 14.79,   0.00, 0.00, -0.06);
	CreateDynamicObject(2543, 1168.86, -1445.11, 14.79,   0.00, 0.00, 0.31);
	CreateDynamicObject(2538, 1167.02, -1431.87, 14.79,   0.00, 0.00, 0.42);
	CreateDynamicObject(2539, 1166.03, -1431.89, 14.79,   0.00, 0.00, 0.70);
	CreateDynamicObject(2540, 1164.04, -1431.91, 14.79,   0.00, 0.00, 0.60);
	CreateDynamicObject(2539, 1165.03, -1431.91, 14.79,   0.00, 0.00, 1.02);
	CreateDynamicObject(2538, 1176.17, -1436.38, 14.79,   0.00, 0.00, 0.24);
	CreateDynamicObject(2539, 1174.22, -1436.37, 14.79,   0.00, 0.00, -0.06);
	CreateDynamicObject(2540, 1173.22, -1436.36, 14.79,   0.00, 0.00, 0.18);
	CreateDynamicObject(2539, 1175.20, -1436.38, 14.79,   0.00, 0.00, -2.06);
	CreateDynamicObject(2540, 1173.26, -1435.31, 14.79,   0.00, 0.00, 180.17);
	CreateDynamicObject(1991, 1175.74, -1439.58, 14.79,   0.00, 0.00, 179.57);
	CreateDynamicObject(1996, 1174.74, -1439.57, 14.79,   0.00, 0.00, 179.24);
	CreateDynamicObject(1996, 1176.17, -1435.37, 14.79,   0.00, 0.00, 179.24);
	CreateDynamicObject(1991, 1177.16, -1435.38, 14.79,   0.00, 0.00, 179.57);
	CreateDynamicObject(2540, 1169.44, -1436.35, 14.79,   0.00, 0.00, 0.18);
	CreateDynamicObject(2539, 1170.43, -1436.35, 14.79,   0.00, 0.00, 0.90);
	CreateDynamicObject(2539, 1171.34, -1436.33, 14.79,   0.00, 0.00, 0.58);
	CreateDynamicObject(2538, 1172.22, -1436.32, 14.79,   0.00, 0.00, 0.30);
	CreateDynamicObject(2871, 1163.40, -1440.68, 14.79,   0.00, 0.00, 360.41);
	CreateDynamicObject(2536, 1164.49, -1440.73, 14.70,   0.00, 0.00, -1.20);
	CreateDynamicObject(2536, 1165.49, -1440.75, 14.70,   0.00, 0.00, -0.42);
	CreateDynamicObject(2536, 1166.50, -1440.75, 14.70,   0.00, 0.00, -0.06);
	CreateDynamicObject(2543, 1167.61, -1440.64, 14.79,   0.00, 0.00, 0.31);
	CreateDynamicObject(2543, 1168.62, -1440.64, 14.79,   0.00, 0.00, 0.30);
	CreateDynamicObject(2543, 1168.64, -1439.60, 14.79,   0.00, 0.00, 180.05);
	CreateDynamicObject(2543, 1167.67, -1439.61, 14.79,   0.00, 0.00, 180.35);
	CreateDynamicObject(2871, 1163.65, -1439.67, 14.79,   0.00, 0.00, 180.61);
	CreateDynamicObject(2871, 1164.68, -1439.67, 14.79,   0.00, 0.00, 179.77);
	CreateDynamicObject(2871, 1165.68, -1439.68, 14.79,   0.00, 0.00, 180.61);
	CreateDynamicObject(2871, 1166.68, -1439.66, 14.79,   0.00, 0.00, 180.61);
	CreateDynamicObject(1990, 1175.09, -1444.97, 14.79,   0.00, 0.00, -2.46);
	CreateDynamicObject(1990, 1181.63, -1431.73, 14.79,   0.00, 0.00, 3.30);
	CreateDynamicObject(1990, 1174.07, -1444.94, 14.79,   0.00, 0.00, 0.48);
	CreateDynamicObject(1990, 1173.09, -1444.94, 14.79,   0.00, 0.00, -1.20);
	CreateDynamicObject(1990, 1172.11, -1444.92, 14.79,   0.00, 0.00, -1.14);
	CreateDynamicObject(1990, 1171.12, -1444.91, 14.79,   0.00, 0.00, -0.72);
	CreateDynamicObject(2530, 1168.54, -1448.31, 14.79,   0.00, 0.00, -178.98);
	CreateDynamicObject(2530, 1169.60, -1448.29, 14.79,   0.00, 0.00, -178.98);
	CreateDynamicObject(2530, 1170.67, -1448.30, 14.79,   0.00, 0.00, -178.98);
	CreateDynamicObject(2530, 1171.72, -1448.32, 14.79,   0.00, 0.00, -181.50);
	CreateDynamicObject(2530, 1175.13, -1443.91, 14.79,   0.00, 0.00, -181.50);
	CreateDynamicObject(2012, 1176.82, -1440.75, 14.75,   0.00, 0.00, 359.93);
	CreateDynamicObject(1995, 1177.71, -1439.63, 14.79,   0.00, 0.00, 0.00);
	CreateDynamicObject(1994, 1176.73, -1439.63, 14.79,   0.00, 0.00, 0.06);
	CreateDynamicObject(1993, 1177.83, -1444.15, 14.79,   0.00, 0.00, 179.46);


	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1126.344726, 2814.151318, 117.255874, 0.000000, 0.000000, 150.196517),
		0, 3942, "bistro", "mp_snow", 0);

	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1124.963623, 2816.560986, 117.255874, 0.000000, 0.000000, 150.196517),
		0, 3942, "bistro", "mp_snow", 0);

	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1123.582519, 2818.990654, 117.255874, 0.000000, 0.000000, 150.176528),
		0, 3942, "bistro", "mp_snow", 0);

	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1122.200683, 2821.390322, 117.255874, 0.000000, 0.000000, 150.166534),
		0, 3942, "bistro", "mp_snow", 0);



	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1126.344726, 2814.151318, 118.656173, 0.000000, 0.000000, 150.196517),
		0, 3942, "bistro", "mp_snow", 0);

	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1124.963623, 2816.560986, 118.656173, 0.000000, 0.000000, 150.196517),
		0, 3942, "bistro", "mp_snow", 0);

	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1123.582519, 2818.990654, 118.656173, 0.000000, 0.000000, 150.176528),
		0, 3942, "bistro", "mp_snow", 0);

	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1122.200683, 2821.30322, 118.656173, 0.000000, 0.000000, 150.166534),
		0, 3942, "bistro", "mp_snow", 0);



	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1126.344726, 2814.151318, 119.856430, 0.000000, 0.000000, 150.196517),
		0, 3942, "bistro", "mp_snow", 0);
	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1124.963623, 2816.560986, 119.856430, 0.000000, 0.000000, 150.196517),
		0, 3942, "bistro", "mp_snow", 0);
	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1123.582519, 2818.990654, 119.856430, 0.000000, 0.000000, 150.176528),
		0, 3942, "bistro", "mp_snow", 0);
	
	SetDynamicObjectMaterial(
		CreateDynamicObject(19477, -1122.200683, 2821.390322, 119.856430, 0.000000, 0.000000, 150.166534),
		0, 3942, "bistro", "mp_snow", 0);


	SetDynamicObjectMaterialText(
		CreateDynamicObject(19479, -1124.256469, 2817.783935, 118.796203, 0.000000, 0.000000, 330.226501),
		0, "DERELICT", OBJECT_MATERIAL_SIZE_512x256, "Tahoma", 72, 1, -16777216, 0, 1);

}

