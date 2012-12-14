/*
 *	Cinematic Camera Node Editor v2.6
 *		Added in CameraMover version 2!
 *		Allows server devs to easily edit camera nodes.
 *      Now has a full project editor.
 *
 *	~Southclaw
 */
#include <a_samp>
#include <sscanf2>
#include "../scripts/Releases/CameraMover.pwn"

#define INDEX_FILE		"Cameras/index.txt"
#define strcpy(%0,%1)	strcat((%0[0] = '\0', %0), %1)

// Set up your camera speed defaults here
#define CAM_SPEED       (10.0)	// Standard speed
#define CAM_HI_SPEED    (40.0)	// When pressing SPRINT (Space default)
#define CAM_LO_SPEED    (3.0)	// When pressing WALK (Alt default)

new
    SelectedCamera[MAX_PLAYERS],
	bool:gPlayerEditing[MAX_PLAYERS],
	bool:gPlayerEditingNode[MAX_PLAYERS],
	freeCamUsed[MAX_PLAYERS],
	freeCamObj[MAX_PLAYERS],

	indexData[MAX_CAMERAS][MAX_CAMFILE_LEN];

forward editor_OnCamMove(playerid, node, bool:cont);


#define DIALOG_OFFSET 1000
enum
{
	d_MainMenu = DIALOG_OFFSET,
	d_NewCamName,
	d_ProjectOptions,
	d_ExportDialog,

	d_NodeID,
	d_MoveTime,
	d_WaitTime,
	d_MoveType,

	d_confirmNodeCommit,

	d_ConfirmQuit
}

new
	PlayerText:cam_buttonBack,
	PlayerText:cam_boxBackground,
	PlayerText:cam_arrowLeft,
	PlayerText:cam_arrowRight,

	PlayerText:cam_row1,
	PlayerText:cam_row2,
	PlayerText:cam_row3,
	PlayerText:cam_row4,

	PlayerText:cam_row1Data,
	PlayerText:cam_row2Data,
	PlayerText:cam_row3Data,
	PlayerText:cam_row4Data,

	PlayerText:cam_buttonEdit,
	PlayerText:cam_buttonSave,
	PlayerText:cam_buttonDelt,
	PlayerText:cam_buttonPrev,
	PlayerText:cam_buttonAddN;


stock FormatMainMenu(playerid)
{
	print("FormatMainMenu initiated");
	new
		File:idxFile,
		line[64],
		idx,
		strTitle[32],
		strList[MAX_CAMERAS*(MAX_CAMFILE_LEN+1)];

	strList = "New Camera...\n";
	print("Variables declared and assigned");

	if(!fexist(INDEX_FILE))
	{
		print("INDEX_FILE does not exist, creating new one...");
		idxFile = fopen(INDEX_FILE, io_write); // If the file doesn't exist, create it now in case it's used later
		fclose(idxFile);
		print("New INDEX_FILE created.");
	}
	else // But if it does, read each line and add that to the list
	{
		print("Opening file");
		idxFile = fopen(INDEX_FILE, io_read);
		while(fread(idxFile, line))
		{
			printf("Reading line: %d", idx);
		    strcat(strList, line);
		    line[strlen(line)-2] = EOS; // Remove the "\n" this would need to be "-1" if using linux
		    strcpy(indexData[idx], line);
		    idx++;
		}
		print("File action complete, closing file");
		fclose(idxFile);
		print("Finished");
	}
	print("Formatting title...");
	format(strTitle, 32, "Total Camera Projects: %d", idx);
	ShowPlayerDialog(playerid, d_MainMenu, DIALOG_STYLE_LIST, strTitle, strList, "Accept", "Close");
	print("Function Complete");
}

CreateCameraMover(playerid, camname[])
{
	new
		File:idxFile,
		File:camFile,
		tmpStr[MAX_CAMFILE_LEN+2],
		newData[128],
		iLoop,

		Float:camX, Float:camY, Float:camZ,
		Float:vecX, Float:vecY, Float:vecZ;

	if(!fexist(INDEX_FILE))idxFile = fopen(INDEX_FILE, io_write);
	else idxFile = fopen(INDEX_FILE, io_append);

	strcat(tmpStr, camname);
	strcat(tmpStr, "\r\n");

	while(strlen(indexData[iLoop][0]))iLoop++;
	strcpy(indexData[iLoop], camname);
	fwrite(idxFile, tmpStr);
	fclose(idxFile);


	GetPlayerCameraPos(playerid, camX, camY, camZ);
	GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);
	vecX+=camX;
	vecY+=camY;
	vecZ+=camZ;

	format(tmpStr, MAX_CAMFILE_LEN+2, CAMERA_FILE, camname);
	camFile = fopen(tmpStr, io_write);

	format(newData, 128, "%f, %f, %f, %f, %f, %f, %d, %d, %d", camX, camY, camZ, vecX, vecY, vecZ, DEFAULT_MOVETIME, DEFAULT_WAITTIME, DEFAULT_MOVETYPE);
	fwrite(camFile, newData);
	fclose(camFile);
}

stock EditCameraMover(playerid, camera)
{
	gPlayerCamData[playerid][p_CamID] = camera;
	gPlayerEditing[playerid]=true;

    camera_LoadTextDraws(playerid); // Need a check to see if the player has textdraws loaded (Maybe checking if the first ID is an invalid textdraw ID)
	SelectTextDraw(playerid, YELLOW);
	ToggleEditGUI(playerid, true);
	JumpToNode(playerid, 0);
}
stock ExitEditing(playerid)
{
	gPlayerCamData[playerid][p_CamID] = -1;
    gPlayerEditing[playerid] = false;
	CancelSelectTextDraw(playerid);
    SetCameraBehindPlayer(playerid);
	ToggleEditGUI(playerid, false);
	TogglePlayerControllable(playerid, true);
}

public editor_OnCamMove(playerid, node, bool:cont)
{
	gPlayerCamData[playerid][p_Node]++;
	UpdateGUI(playerid);
}

SaveCameraMover(playerid, exportmode=0)
{
	new
		tmpCam = gPlayerCamData[playerid][p_CamID],
		tmpNode,
		File:camFile_Main = fopen(camFilename[tmpCam], io_read),
		File:camFile_Backup,
		tmpFilename[64],
		tmpLine[256],
		tmpData[3];

	// Create the backup file, then write everything from the main one into the new one
	format(tmpFilename, 64, "%s.bak", camFilename[tmpCam]);
	camFile_Backup=fopen(tmpFilename, io_write);
	while(fread(camFile_Main, tmpLine))fwrite(camFile_Backup, tmpLine);
	fclose(camFile_Backup);
	fclose(camFile_Main);

	// Now, close that backup file, write all the variable data into the main file

	camFile_Main = fopen(camFilename[tmpCam], io_write);
	while (tmpNode <= camMaxNodes[tmpCam])
	{
		if(!exportmode)
		{
		    if (camData[tmpCam][tmpNode][cam_moveTime] == tmpData[0] &&
		    	camData[tmpCam][tmpNode][cam_waitTime] == tmpData[1] &&
		    	camData[tmpCam][tmpNode][cam_moveType] == tmpData[2] )
		    { // All the data is the same as the last one, ignore it and leave optionals blank
				format(tmpLine, 256, "%f, %f, %f, %f, %f, %f\r\n",
				    camData[tmpCam][tmpNode][cam_cPosX],
				    camData[tmpCam][tmpNode][cam_cPosY],
				    camData[tmpCam][tmpNode][cam_cPosZ],
				    camData[tmpCam][tmpNode][cam_lPosX],
				    camData[tmpCam][tmpNode][cam_lPosY],
				    camData[tmpCam][tmpNode][cam_lPosZ] );
	    	}
	    	else
			{ // Data is different, write the new data to the line
				format(tmpLine, 256, "%f, %f, %f, %f, %f, %f, %d, %d, %d\r\n",
				    camData[tmpCam][tmpNode][cam_cPosX],
				    camData[tmpCam][tmpNode][cam_cPosY],
				    camData[tmpCam][tmpNode][cam_cPosZ],
				    camData[tmpCam][tmpNode][cam_lPosX],
				    camData[tmpCam][tmpNode][cam_lPosY],
				    camData[tmpCam][tmpNode][cam_lPosZ],
				    camData[tmpCam][tmpNode][cam_moveTime],
				    camData[tmpCam][tmpNode][cam_waitTime],
				    camData[tmpCam][tmpNode][cam_moveType] );

				tmpData[0] = camData[tmpCam][tmpNode][cam_moveTime];
				tmpData[1] = camData[tmpCam][tmpNode][cam_waitTime];
				tmpData[2] = camData[tmpCam][tmpNode][cam_moveType];
			}
		}
		else
		{
			if(tmpNode == camMaxNodes[tmpCam])strcpy(tmpLine, "\r\n");
			else
			{
				format(tmpLine, 256,
					"InterpolateCameraPos(playerid, %f, %f, %f, %f, %f, %f, %d, %d);\r\n\
					InterpolateCameraLookAt(playerid, %f, %f, %f, %f, %f, %f, %d, %d);\r\n",

				    camData[tmpCam][tmpNode][cam_cPosX],
				    camData[tmpCam][tmpNode][cam_cPosY],
				    camData[tmpCam][tmpNode][cam_cPosZ],
				    camData[tmpCam][tmpNode+1][cam_cPosX],
				    camData[tmpCam][tmpNode+1][cam_cPosY],
				    camData[tmpCam][tmpNode+1][cam_cPosZ],
				    camData[tmpCam][tmpNode][cam_moveTime],
				    camData[tmpCam][tmpNode][cam_moveType],

				    camData[tmpCam][tmpNode][cam_lPosX],
				    camData[tmpCam][tmpNode][cam_lPosY],
				    camData[tmpCam][tmpNode][cam_lPosZ],
				    camData[tmpCam][tmpNode+1][cam_lPosX],
				    camData[tmpCam][tmpNode+1][cam_lPosY],
				    camData[tmpCam][tmpNode+1][cam_lPosZ],
				    camData[tmpCam][tmpNode][cam_moveTime],
				    camData[tmpCam][tmpNode][cam_moveType] );
			}
		}
		fwrite(camFile_Main, tmpLine);
		tmpNode++;
	}
	fclose(camFile_Main);
}
ToggleEditGUI(playerid, toggle)
{
	if(toggle)
	{
	    PlayerTextDrawShow(playerid, cam_buttonBack);
		PlayerTextDrawShow(playerid, cam_boxBackground);
		PlayerTextDrawShow(playerid, cam_arrowLeft);
		PlayerTextDrawShow(playerid, cam_arrowRight);

		PlayerTextDrawShow(playerid, cam_row1);
		PlayerTextDrawShow(playerid, cam_row2);
		PlayerTextDrawShow(playerid, cam_row3);
		PlayerTextDrawShow(playerid, cam_row4);

		PlayerTextDrawShow(playerid, cam_row1Data);
		PlayerTextDrawShow(playerid, cam_row2Data);
		PlayerTextDrawShow(playerid, cam_row3Data);
		PlayerTextDrawShow(playerid, cam_row4Data);

		PlayerTextDrawShow(playerid, cam_buttonEdit);
		PlayerTextDrawShow(playerid, cam_buttonSave);
		PlayerTextDrawShow(playerid, cam_buttonDelt);
		PlayerTextDrawShow(playerid, cam_buttonPrev);
		PlayerTextDrawShow(playerid, cam_buttonAddN);
	}
	else
	{
	    PlayerTextDrawHide(playerid, cam_buttonBack);
		PlayerTextDrawHide(playerid, cam_boxBackground);
		PlayerTextDrawHide(playerid, cam_arrowLeft);
		PlayerTextDrawHide(playerid, cam_arrowRight);

		PlayerTextDrawHide(playerid, cam_row1);
		PlayerTextDrawHide(playerid, cam_row2);
		PlayerTextDrawHide(playerid, cam_row3);
		PlayerTextDrawHide(playerid, cam_row4);

		PlayerTextDrawHide(playerid, cam_row1Data);
		PlayerTextDrawHide(playerid, cam_row2Data);
		PlayerTextDrawHide(playerid, cam_row3Data);
		PlayerTextDrawHide(playerid, cam_row4Data);

		PlayerTextDrawHide(playerid, cam_buttonEdit);
		PlayerTextDrawHide(playerid, cam_buttonSave);
		PlayerTextDrawHide(playerid, cam_buttonDelt);
		PlayerTextDrawHide(playerid, cam_buttonPrev);
		PlayerTextDrawHide(playerid, cam_buttonAddN);
	}
}
UpdateGUI(playerid)
{
	new
		tmpCam = gPlayerCamData[playerid][p_CamID],
		tmpNode = gPlayerCamData[playerid][p_Node],
		dataStr[16],
		MoveTypeName[3][5]={"NONE", "MOVE", "CUT"};

	format(dataStr, 16, "%d/%d", tmpNode, camMaxNodes[tmpCam]);
	PlayerTextDrawSetString(playerid, cam_row1Data, dataStr);
	PlayerTextDrawShow(playerid, cam_row1Data);

	format(dataStr, 16, "%d", camData[tmpCam][tmpNode][cam_moveTime]);
	PlayerTextDrawSetString(playerid, cam_row2Data, dataStr);
	PlayerTextDrawShow(playerid, cam_row2Data);

	format(dataStr, 16, "%d", camData[tmpCam][tmpNode][cam_waitTime]);
	PlayerTextDrawSetString(playerid, cam_row3Data, dataStr);
	PlayerTextDrawShow(playerid, cam_row3Data);

	format(dataStr, 16, "%s(%d)", MoveTypeName[ _:camData[tmpCam][tmpNode][cam_moveType] ], camData[tmpCam][tmpNode][cam_moveType]);
	PlayerTextDrawSetString(playerid, cam_row4Data, dataStr);
	PlayerTextDrawShow(playerid, cam_row4Data);
}
JumpToNode(playerid, node)
{
	new
		camera = gPlayerCamData[playerid][p_CamID];

	SetPlayerCameraPos(playerid, camData[camera][node][cam_cPosX], camData[camera][node][cam_cPosY], camData[camera][node][cam_cPosZ]);
	SetPlayerCameraLookAt(playerid,	camData[camera][node][cam_lPosX], camData[camera][node][cam_lPosY], camData[camera][node][cam_lPosZ]);

	gPlayerCamData[playerid][p_Node] = node;
	UpdateGUI(playerid);
}

EditCurrentNode(playerid)
{
	gPlayerEditingNode[playerid] = true;
	EnterFreeCam(playerid);
}
CommitCurrentNode(playerid)
{
	new
		tmpCam = gPlayerCamData[playerid][p_CamID],
		tmpNode = gPlayerCamData[playerid][p_Node],
		Float:vecX, Float:vecY, Float:vecZ;

	GetPlayerCameraPos(playerid, camData[tmpCam][tmpNode][cam_cPosX], camData[tmpCam][tmpNode][cam_cPosY], camData[tmpCam][tmpNode][cam_cPosZ]);
	GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

	camData[tmpCam][tmpNode][cam_lPosX] = camData[tmpCam][tmpNode][cam_cPosX]+(vecX*4); // x4 just to give the LookAt node a little distance, I didn't know if this would affect anything
	camData[tmpCam][tmpNode][cam_lPosY] = camData[tmpCam][tmpNode][cam_cPosY]+(vecY*4);
	camData[tmpCam][tmpNode][cam_lPosZ] = camData[tmpCam][tmpNode][cam_cPosZ]+(vecZ*4);

	gPlayerEditingNode[playerid] = false;
	ExitFreeCam(playerid);
	UpdateGUI(playerid);
}
CancelCurrentNodeEdit(playerid)
{
	JumpToNode(playerid, gPlayerCamData[playerid][p_Node]);

	gPlayerEditingNode[playerid] = false;
	ExitFreeCam(playerid);
}

EnterFreeCam(playerid)
{
	new
		tmpCam = gPlayerCamData[playerid][p_CamID],
		tmpNode = gPlayerCamData[playerid][p_Node];

    freeCamUsed[playerid] = true;
	TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 1.0, 0, 0, 0, 1, 0);
	CancelSelectTextDraw(playerid);
	ToggleEditGUI(playerid, false);

	freeCamObj[playerid] = CreateObject(19300, camData[tmpCam][tmpNode][cam_cPosX], camData[tmpCam][tmpNode][cam_cPosY], camData[tmpCam][tmpNode][cam_cPosZ], 0.0, 0.0, 0.0);
	AttachCameraToObject(playerid, freeCamObj[playerid]);
}
ExitFreeCam(playerid)
{
	JumpToNode(playerid, gPlayerCamData[playerid][p_Node]);

    freeCamUsed[playerid] = false;
	DestroyObject(freeCamObj[playerid]);
	ToggleEditGUI(playerid, true);
	SelectTextDraw(playerid, YELLOW);
}


EditNewNode(playerid)
{
	new
		tmpCam = gPlayerCamData[playerid][p_CamID],
		tmpNode = gPlayerCamData[playerid][p_Node];

	ShiftNodeArray(tmpCam, tmpNode);
	EditCurrentNode(playerid);
	gPlayerCamData[playerid][p_Node]++;
}
DeleteCurrentNode(playerid)
{
	new
		tmpCam = gPlayerCamData[playerid][p_CamID],
		tmpNode = gPlayerCamData[playerid][p_Node];

	ShiftNodeArray(tmpCam, tmpNode, 1);
	JumpToNode(playerid, tmpNode);
}
ShiftNodeArray(camera, startnode, direction=0)
{
	if(direction == 0)
	{
		new iLoop = camMaxNodes[camera]++; // Assign the value then increment it because we are adding another cell
		while(iLoop>=startnode) // Loop from the last node to the startnode
		{
		    for(new e;e<MAX_CAMDATA;e++) // Shift all the data to the next node cell
		    {
				camData[camera][iLoop+1][CAM_DATA_ENUM:e] = camData[camera][iLoop][CAM_DATA_ENUM:e];
			}
		    iLoop--;
		}
	}
	else
	{
		new iLoop = startnode;
		while(iLoop<=camMaxNodes[camera]) // Loop from the startnode to the last node
		{
		    for(new e;e<MAX_CAMDATA;e++)
				camData[camera][iLoop][CAM_DATA_ENUM:e] = camData[camera][iLoop+1][CAM_DATA_ENUM:e];

		    iLoop++;
		}
		for(new e;e<MAX_CAMDATA;e++)camData[camera][camMaxNodes[camera]][CAM_DATA_ENUM:e] = 0;
		// I didn't want to have to call two loops
		// But I'm not sure how do to it otherwise!
		// I'll try a backwards loop when I'm more awake!
		// A backwards loop would be able to blank the last cell easier
		camMaxNodes[camera]--; // Decrement the max value, we just removed a cell
	}
}
/* Debugging!
	I used it to test the above function to ensure it
	was shifting the right data without deleting stuff!

PRINTALLNODE(c)
{
	new n;
	while(n<MAX_CAMNODE)
	{
	    printf("%02d: %d, %d, %d", n, camData[c][n][cam_moveTime], camData[c][n][cam_waitTime], camData[c][n][cam_moveType]);
	    n++;
	}
}
*/

public OnPlayerUpdate(playerid)
{
	new
		k,
		ud,
		lr,
		Float:camX,
		Float:camY,
		Float:camZ,
		Float:vecX,
		Float:vecY,
		Float:vecZ,

		Float:angR,
		Float:angE,

		Float:speed = CAM_SPEED;

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerCameraPos(playerid, camX, camY, camZ);
	GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

	angR = 90-(atan2(vecY, vecX));
	if(angR<0.0)angR=360.0+angR;
	angE = -(floatabs(atan2(floatsqroot(floatpower(vecX, 2.0) + floatpower(vecY, 2.0)), vecZ))-90.0);

	if(k==KEY_JUMP)
	{
	    speed = CAM_HI_SPEED;
	}
	if(k==KEY_WALK)
	{
	    speed = CAM_LO_SPEED;
	}

	if(ud==KEY_UP)
	{
		GetXYZFromAngle(camX, camY, camZ, angR, angE, 50.0);
		MoveObject(freeCamObj[playerid], camX, camY, camZ, speed);
	}
	if(ud==KEY_DOWN)
	{
		GetXYZFromAngle(camX, camY, camZ, angR, angE, -50.0);
		MoveObject(freeCamObj[playerid], camX, camY, camZ, speed);
	}
	if(lr==KEY_LEFT)
	{
		GetXYFromAngle(camX, camY, -angR+90.0, 50.0);
		MoveObject(freeCamObj[playerid], camX, camY, camZ, speed);
	}
	if(lr==KEY_RIGHT)
	{
		GetXYFromAngle(camX, camY, -angR+90.0, -50.0);
		MoveObject(freeCamObj[playerid], camX, camY, camZ, speed);
	}
	if(k==KEY_SPRINT)
	{
		MoveObject(freeCamObj[playerid], camX, camY, camZ+50.0, speed);
	}
	if(k==KEY_CROUCH)
	{
		MoveObject(freeCamObj[playerid], camX, camY, camZ-50.0, speed);
	}
	if(ud!=KEY_UP && ud!=KEY_DOWN && lr!=KEY_LEFT && lr!=KEY_RIGHT && k!=KEY_SPRINT && k!=KEY_CROUCH)StopObject(freeCamObj[playerid]);
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(gPlayerEditingNode[playerid])
	{
		if(newkeys & KEY_FIRE)
		{
			new strInfo[64];
			format(strInfo, 64, "Apply changes to node %d?", gPlayerCamData[playerid][p_Node]);
			ShowPlayerDialog(playerid, d_confirmNodeCommit, DIALOG_STYLE_MSGBOX, "Confirm changes?", strInfo, "Apply", "Reset");
		}
		if(newkeys & 16)CancelCurrentNodeEdit(playerid);
	}
}
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == cam_buttonBack)ShowPlayerDialog(playerid, d_ConfirmQuit, DIALOG_STYLE_MSGBOX, "Exit Editing", "Are you sure you want to quit? All unsaved data will be lost!", "Ok", "Cancel");

	if(playertextid == cam_buttonEdit)EditCurrentNode(playerid);
	if(playertextid == cam_buttonSave)ShowPlayerDialog(playerid, d_ExportDialog, DIALOG_STYLE_LIST, "Export Camera As...", "Sequencer Data File\nInterpolate Functions", "Accept", "Cancel");
	if(playertextid == cam_buttonDelt)DeleteCurrentNode(playerid);
	if(playertextid == cam_buttonPrev)MoveCameraToNextNode(playerid, true);
	if(playertextid == cam_buttonAddN)
	{
	    if(GetCameraMaxNodes(gPlayerCamData[playerid][p_CamID]) < MAX_CAMNODE-1)EditNewNode(playerid);
	    else Msg(playerid, RED, "Node limit reached, increase constant <MAX_CAMNODE> in script.");
	}

	if(playertextid == cam_arrowLeft)
	{
	    new
	        tmpCam = gPlayerCamData[playerid][p_CamID],
			tmpNode = gPlayerCamData[playerid][p_Node] - 1;

	    if(tmpNode < 0)tmpNode = camMaxNodes[tmpCam];
		JumpToNode(playerid, tmpNode);
	}
	if(playertextid == cam_arrowRight)
	{
	    new
	        tmpCam = gPlayerCamData[playerid][p_CamID],
			tmpNode = gPlayerCamData[playerid][p_Node] + 1;

	    if(tmpNode > camMaxNodes[tmpCam])tmpNode = 0;
		JumpToNode(playerid, tmpNode);
	}
	if(playertextid == cam_row1Data)ShowPlayerDialog(playerid, d_NodeID, DIALOG_STYLE_INPUT, "Node ID", "Type a node ID to jump to", "Back", "Accept");
	if(playertextid == cam_row2Data)ShowPlayerDialog(playerid, d_MoveTime, DIALOG_STYLE_INPUT, "Move Time", "Time to move to next node (in milliseconds)", "Back", "Accept");
	if(playertextid == cam_row3Data)ShowPlayerDialog(playerid, d_WaitTime, DIALOG_STYLE_INPUT, "Wait Time", "Time to wait before moving to next node (in milliseconds)", "Back", "Accept");
	if(playertextid == cam_row4Data)ShowPlayerDialog(playerid, d_MoveType, DIALOG_STYLE_MSGBOX, "Cut Type", "Select a Camera Cut Type\nMove: Smoothly moves to the next node.\nJump: Jumps to the next node.", "Move", "Jump");
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == d_MainMenu)
	{
	    if(response)
	    {
	        if(listitem==0)ShowPlayerDialog(playerid, d_NewCamName, DIALOG_STYLE_INPUT, "New Camera", "Enter the new camera name below.\nDo not use spaces.", "Accept", "Back");
	        else
			{
			    SelectedCamera[playerid] = listitem-1;
				ShowPlayerDialog(playerid, d_ProjectOptions, DIALOG_STYLE_LIST, "Options", "Edit Camera\nPreview Camera", "Accept", "Back");
			}
	    }
	}
	if(dialogid == d_NewCamName)
	{
	    if(response)
	    {
	        if(strfind(inputtext, " ") == -1)
			{
				CreateCameraMover(playerid, inputtext);
				FormatMainMenu(playerid);
			}
	        else ShowPlayerDialog(playerid, d_NewCamName, DIALOG_STYLE_INPUT, "New Camera", "Enter the new camera name below.\n{FF0000}Do not use spaces.", "Accept", "Back");
	    }
	    else FormatMainMenu(playerid);
	}
	if(dialogid == d_ProjectOptions)
	{
		if(response)
		{
			if(listitem == 0)EditCameraMover(playerid, LoadCameraMover(indexData[SelectedCamera[playerid]]));
			if(listitem == 1)PlayCameraMover(playerid, LoadCameraMover(indexData[SelectedCamera[playerid]]));
		}
		else FormatMainMenu(playerid);
	}
	if(dialogid == d_ExportDialog)
	{
	    if(response)
	    {
			SaveCameraMover(playerid, listitem);
			Msg(playerid, YELLOW, "Camera saved!");
	    }
	}

	if(dialogid == d_NodeID)
	{
	    new
	        tmpCam = gPlayerCamData[playerid][p_CamID],
			nextNode = strval(inputtext);
	    if(0 <= nextNode < camMaxNodes[tmpCam])JumpToNode(playerid, nextNode);
	    else
	    {
			SendClientMessage(playerid, 0xFF1100FF, "Invalid value entered");
			ShowPlayerDialog(playerid, d_NodeID, DIALOG_STYLE_INPUT, "Node ID", "Type a node ID to jump to", "Back", "Accept");
	    }
	}
	if(dialogid == d_MoveTime)
	{
	    new
	        tmpCam = gPlayerCamData[playerid][p_CamID],
	        tmpNode = gPlayerCamData[playerid][p_Node],
			tmpMoveTime = strval(inputtext);

		if(tmpMoveTime > 0)
		{
			camData[tmpCam][tmpNode][cam_moveTime] = tmpMoveTime;
			UpdateGUI(playerid);
		}
		else
		{
			SendClientMessage(playerid, 0xFF1100FF, "Invalid value entered");
			ShowPlayerDialog(playerid, d_MoveTime, DIALOG_STYLE_INPUT, "Move Time", "Time to move to next node (in milliseconds)", "Back", "Accept");
		}
	}
	if(dialogid == d_WaitTime)
	{
	    new
	        tmpCam = gPlayerCamData[playerid][p_CamID],
	        tmpNode = gPlayerCamData[playerid][p_Node],
			tmpWaitTime = strval(inputtext);

		if(tmpWaitTime > 0)
		{
			camData[tmpCam][tmpNode][cam_waitTime] = tmpWaitTime;
			UpdateGUI(playerid);
		}
		else
		{
			SendClientMessage(playerid, 0xFF1100FF, "Invalid value entered");
			ShowPlayerDialog(playerid, d_WaitTime, DIALOG_STYLE_INPUT, "Wait Time", "Time to wait before moving to next node (in milliseconds)", "Back", "Accept");
		}
	}
	if(dialogid == d_MoveType)
	{
	    new
	        tmpCam = gPlayerCamData[playerid][p_CamID],
	        tmpNode = gPlayerCamData[playerid][p_Node];

		if(!response)
		{
			camData[tmpCam][tmpNode][cam_moveType] = CAMERA_MOVE;
			UpdateGUI(playerid);
		}
		else
		{
			camData[tmpCam][tmpNode][cam_moveType] = CAMERA_CUT;
			UpdateGUI(playerid);
		}
	}

	if(dialogid == d_confirmNodeCommit)
	{
	    new
	        tmpCam = gPlayerCamData[playerid][p_CamID],
	        tmpNode = gPlayerCamData[playerid][p_Node];

		if(response)CommitCurrentNode(playerid);
		else
		{
		    SetObjectPos(freeCamObj[playerid],
				camData[tmpCam][tmpNode][cam_cPosX],
				camData[tmpCam][tmpNode][cam_cPosY],
				camData[tmpCam][tmpNode][cam_cPosZ]);
		}
	}

	if(dialogid == d_ConfirmQuit)
	{
	    if(response)
	    {
			ExitEditing(playerid);
			FormatMainMenu(playerid);
		}
	}
}

public OnPlayerConnect(playerid)
{
	camera_LoadTextDraws(playerid);
	return 1;
}
camera_LoadTextDraws(playerid)
{
	// Background

	cam_boxBackground = CreatePlayerTextDraw(playerid, 320.000000, 320.000000, "~n~~n~~n~~n~");
	PlayerTextDrawAlignment(playerid, cam_boxBackground, 2);
	PlayerTextDrawBackgroundColor(playerid, cam_boxBackground, 255);
	PlayerTextDrawFont(playerid, cam_boxBackground, 1);
	PlayerTextDrawLetterSize(playerid, cam_boxBackground, 0.500000, 2.200000);
	PlayerTextDrawColor(playerid, cam_boxBackground, -1);
	PlayerTextDrawSetOutline(playerid, cam_boxBackground, 0);
	PlayerTextDrawSetProportional(playerid, cam_boxBackground, 1);
	PlayerTextDrawSetShadow(playerid, cam_boxBackground, 1);
	PlayerTextDrawUseBox(playerid, cam_boxBackground, 1);
	PlayerTextDrawBoxColor(playerid, cam_boxBackground, 128);
	PlayerTextDrawTextSize(playerid, cam_boxBackground, 380.000000, 300.000000);


	// Node Switch

	cam_arrowLeft = CreatePlayerTextDraw(playerid, 174.000000, 339.000000, "~<~");
	PlayerTextDrawBackgroundColor(playerid, cam_arrowLeft, 255);
	PlayerTextDrawFont(playerid, cam_arrowLeft, 1);
	PlayerTextDrawLetterSize(playerid, cam_arrowLeft, 0.000000, 4.800001);
	PlayerTextDrawColor(playerid, cam_arrowLeft, -1);
	PlayerTextDrawSetOutline(playerid, cam_arrowLeft, 0);
	PlayerTextDrawSetProportional(playerid, cam_arrowLeft, 1);
	PlayerTextDrawSetShadow(playerid, cam_arrowLeft, 1);
	PlayerTextDrawUseBox(playerid, cam_arrowLeft, 1);
	PlayerTextDrawBoxColor(playerid, cam_arrowLeft, 6618980);
	PlayerTextDrawTextSize(playerid, cam_arrowLeft, 210.000000, 58.000000);
	PlayerTextDrawSetSelectable(playerid, cam_arrowLeft, true);

	cam_arrowRight = CreatePlayerTextDraw(playerid, 432.000000, 339.000000, "~>~");
	PlayerTextDrawBackgroundColor(playerid, cam_arrowRight, 255);
	PlayerTextDrawFont(playerid, cam_arrowRight, 1);
	PlayerTextDrawLetterSize(playerid, cam_arrowRight, 0.000000, 4.800001);
	PlayerTextDrawColor(playerid, cam_arrowRight, -1);
	PlayerTextDrawSetOutline(playerid, cam_arrowRight, 0);
	PlayerTextDrawSetProportional(playerid, cam_arrowRight, 1);
	PlayerTextDrawSetShadow(playerid, cam_arrowRight, 1);
	PlayerTextDrawUseBox(playerid, cam_arrowRight, 1);
	PlayerTextDrawBoxColor(playerid, cam_arrowRight, 6618980);
	PlayerTextDrawTextSize(playerid, cam_arrowRight, 466.000000, 58.000000);
	PlayerTextDrawSetSelectable(playerid, cam_arrowRight, true);


	// Info

	cam_row1 = CreatePlayerTextDraw(playerid, 240.000000, 325.000000, "Node:");
	PlayerTextDrawBackgroundColor(playerid, cam_row1, 255);
	PlayerTextDrawFont(playerid, cam_row1, 1);
	PlayerTextDrawLetterSize(playerid, cam_row1, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, cam_row1, -1);
	PlayerTextDrawSetOutline(playerid, cam_row1, 0);
	PlayerTextDrawSetProportional(playerid, cam_row1, 1);
	PlayerTextDrawSetShadow(playerid, cam_row1, 1);
	PlayerTextDrawUseBox(playerid, cam_row1, 1);
	PlayerTextDrawBoxColor(playerid, cam_row1, 3955300);
	PlayerTextDrawTextSize(playerid, cam_row1, 400.000000, 0.000000);

	cam_row2 = CreatePlayerTextDraw(playerid, 240.000000, 342.000000, "Move Time (ms):");
	PlayerTextDrawBackgroundColor(playerid, cam_row2, 255);
	PlayerTextDrawFont(playerid, cam_row2, 1);
	PlayerTextDrawLetterSize(playerid, cam_row2, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, cam_row2, -1);
	PlayerTextDrawSetOutline(playerid, cam_row2, 0);
	PlayerTextDrawSetProportional(playerid, cam_row2, 1);
	PlayerTextDrawSetShadow(playerid, cam_row2, 1);
	PlayerTextDrawUseBox(playerid, cam_row2, 1);
	PlayerTextDrawBoxColor(playerid, cam_row2, 3955300);
	PlayerTextDrawTextSize(playerid, cam_row2, 400.000000, 0.000000);

	cam_row3 = CreatePlayerTextDraw(playerid, 240.000000, 360.000000, "Wait Time (ms):");
	PlayerTextDrawBackgroundColor(playerid, cam_row3, 255);
	PlayerTextDrawFont(playerid, cam_row3, 1);
	PlayerTextDrawLetterSize(playerid, cam_row3, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, cam_row3, -1);
	PlayerTextDrawSetOutline(playerid, cam_row3, 0);
	PlayerTextDrawSetProportional(playerid, cam_row3, 1);
	PlayerTextDrawSetShadow(playerid, cam_row3, 1);
	PlayerTextDrawUseBox(playerid, cam_row3, 1);
	PlayerTextDrawBoxColor(playerid, cam_row3, 3955300);
	PlayerTextDrawTextSize(playerid, cam_row3, 400.000000, 0.000000);

	cam_row4 = CreatePlayerTextDraw(playerid, 240.000000, 378.000000, "Cut Type:");
	PlayerTextDrawBackgroundColor(playerid, cam_row4, 255);
	PlayerTextDrawFont(playerid, cam_row4, 1);
	PlayerTextDrawLetterSize(playerid, cam_row4, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, cam_row4, -1);
	PlayerTextDrawSetOutline(playerid, cam_row4, 0);
	PlayerTextDrawSetProportional(playerid, cam_row4, 1);
	PlayerTextDrawSetShadow(playerid, cam_row4, 1);
	PlayerTextDrawUseBox(playerid, cam_row4, 1);
	PlayerTextDrawBoxColor(playerid, cam_row4, 3955300);
	PlayerTextDrawTextSize(playerid, cam_row4, 400.000000, 0.000000);


	// Data fields

	cam_row1Data = CreatePlayerTextDraw(playerid, 335.000000, 325.000000, "00");
	PlayerTextDrawBackgroundColor(playerid, cam_row1Data, 255);
	PlayerTextDrawFont(playerid, cam_row1Data, 1);
	PlayerTextDrawLetterSize(playerid, cam_row1Data, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, cam_row1Data, -1);
	PlayerTextDrawSetOutline(playerid, cam_row1Data, 0);
	PlayerTextDrawSetProportional(playerid, cam_row1Data, 1);
	PlayerTextDrawSetShadow(playerid, cam_row1Data, 1);
	PlayerTextDrawUseBox(playerid, cam_row1Data, 1);
	PlayerTextDrawBoxColor(playerid, cam_row1Data, 3955300);
	PlayerTextDrawTextSize(playerid, cam_row1Data, 400.000000, 14.000000);
	PlayerTextDrawSetSelectable(playerid, cam_row1Data, true);

	cam_row2Data = CreatePlayerTextDraw(playerid, 335.000000, 342.000000, "00000");
	PlayerTextDrawBackgroundColor(playerid, cam_row2Data, 255);
	PlayerTextDrawFont(playerid, cam_row2Data, 1);
	PlayerTextDrawLetterSize(playerid, cam_row2Data, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, cam_row2Data, -1);
	PlayerTextDrawSetOutline(playerid, cam_row2Data, 0);
	PlayerTextDrawSetProportional(playerid, cam_row2Data, 1);
	PlayerTextDrawSetShadow(playerid, cam_row2Data, 1);
	PlayerTextDrawUseBox(playerid, cam_row2Data, 1);
	PlayerTextDrawBoxColor(playerid, cam_row2Data, 3955300);
	PlayerTextDrawTextSize(playerid, cam_row2Data, 400.000000, 14.000000);
	PlayerTextDrawSetSelectable(playerid, cam_row2Data, true);

	cam_row3Data = CreatePlayerTextDraw(playerid, 335.000000, 360.000000, "00000");
	PlayerTextDrawBackgroundColor(playerid, cam_row3Data, 255);
	PlayerTextDrawFont(playerid, cam_row3Data, 1);
	PlayerTextDrawLetterSize(playerid, cam_row3Data, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, cam_row3Data, -1);
	PlayerTextDrawSetOutline(playerid, cam_row3Data, 0);
	PlayerTextDrawSetProportional(playerid, cam_row3Data, 1);
	PlayerTextDrawSetShadow(playerid, cam_row3Data, 1);
	PlayerTextDrawUseBox(playerid, cam_row3Data, 1);
	PlayerTextDrawBoxColor(playerid, cam_row3Data, 3955300);
	PlayerTextDrawTextSize(playerid, cam_row3Data, 400.000000, 14.000000);
	PlayerTextDrawSetSelectable(playerid, cam_row3Data, true);

	cam_row4Data = CreatePlayerTextDraw(playerid, 335.000000, 378.000000, "MOVE");
	PlayerTextDrawBackgroundColor(playerid, cam_row4Data, 255);
	PlayerTextDrawFont(playerid,cam_row4Data, 1);
	PlayerTextDrawLetterSize(playerid, cam_row4Data, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, cam_row4Data, 16777215);
	PlayerTextDrawSetOutline(playerid, cam_row4Data, 0);
	PlayerTextDrawSetProportional(playerid, cam_row4Data, 1);
	PlayerTextDrawSetShadow(playerid, cam_row4Data, 1);
	PlayerTextDrawUseBox(playerid, cam_row4Data, 1);
	PlayerTextDrawBoxColor(playerid, cam_row4Data, 3955300);
	PlayerTextDrawTextSize(playerid, cam_row4Data, 400.000000, 14.000000);
	PlayerTextDrawSetSelectable(playerid, cam_row4Data, true);


	// Edit Controls

	cam_buttonEdit = CreatePlayerTextDraw(playerid, 250.000000, 290.000000, "E");
	PlayerTextDrawBackgroundColor(playerid, cam_buttonEdit, 255);
	PlayerTextDrawFont(playerid, cam_buttonEdit, 1);
	PlayerTextDrawLetterSize(playerid, cam_buttonEdit, 1.000000, 2.499999);
	PlayerTextDrawColor(playerid, cam_buttonEdit, -1);
	PlayerTextDrawSetOutline(playerid, cam_buttonEdit, 0);
	PlayerTextDrawSetProportional(playerid, cam_buttonEdit, 1);
	PlayerTextDrawSetShadow(playerid, cam_buttonEdit, 1);
	PlayerTextDrawUseBox(playerid, cam_buttonEdit, 1);
	PlayerTextDrawBoxColor(playerid, cam_buttonEdit, 100);
	PlayerTextDrawTextSize(playerid, cam_buttonEdit, 270.000000, 14.0);
	PlayerTextDrawSetSelectable(playerid, cam_buttonEdit, true);

	cam_buttonSave = CreatePlayerTextDraw(playerid, 280.000000, 290.000000, "S");
	PlayerTextDrawBackgroundColor(playerid, cam_buttonSave, 255);
	PlayerTextDrawFont(playerid, cam_buttonSave, 1);
	PlayerTextDrawLetterSize(playerid, cam_buttonSave, 0.829999, 2.499999);
	PlayerTextDrawColor(playerid, cam_buttonSave, -1);
	PlayerTextDrawSetOutline(playerid, cam_buttonSave, 0);
	PlayerTextDrawSetProportional(playerid, cam_buttonSave, 1);
	PlayerTextDrawSetShadow(playerid, cam_buttonSave, 1);
	PlayerTextDrawUseBox(playerid, cam_buttonSave, 1);
	PlayerTextDrawBoxColor(playerid, cam_buttonSave, 100);
	PlayerTextDrawTextSize(playerid, cam_buttonSave, 300.000000, 14.0);
	PlayerTextDrawSetSelectable(playerid, cam_buttonSave, true);

	cam_buttonDelt = CreatePlayerTextDraw(playerid, 310.000000, 290.000000, "X");
	PlayerTextDrawBackgroundColor(playerid, cam_buttonDelt, 255);
	PlayerTextDrawFont(playerid, cam_buttonDelt, 1);
	PlayerTextDrawLetterSize(playerid, cam_buttonDelt, 0.890000, 2.499999);
	PlayerTextDrawColor(playerid, cam_buttonDelt, -1);
	PlayerTextDrawSetOutline(playerid, cam_buttonDelt, 0);
	PlayerTextDrawSetProportional(playerid, cam_buttonDelt, 1);
	PlayerTextDrawSetShadow(playerid, cam_buttonDelt, 1);
	PlayerTextDrawUseBox(playerid, cam_buttonDelt, 1);
	PlayerTextDrawBoxColor(playerid, cam_buttonDelt, 100);
	PlayerTextDrawTextSize(playerid, cam_buttonDelt, 330.000000, 14.0);
	PlayerTextDrawSetSelectable(playerid, cam_buttonDelt, true);

	cam_buttonPrev = CreatePlayerTextDraw(playerid, 340.000000, 290.000000, ">>");
	PlayerTextDrawBackgroundColor(playerid, cam_buttonPrev, 255);
	PlayerTextDrawFont(playerid, cam_buttonPrev, 1);
	PlayerTextDrawLetterSize(playerid, cam_buttonPrev, 0.389999, 2.499999);
	PlayerTextDrawColor(playerid, cam_buttonPrev, -1);
	PlayerTextDrawSetOutline(playerid, cam_buttonPrev, 0);
	PlayerTextDrawSetProportional(playerid, cam_buttonPrev, 1);
	PlayerTextDrawSetShadow(playerid, cam_buttonPrev, 1);
	PlayerTextDrawUseBox(playerid, cam_buttonPrev, 1);
	PlayerTextDrawBoxColor(playerid, cam_buttonPrev, 100);
	PlayerTextDrawTextSize(playerid, cam_buttonPrev, 360.000000, 14.0);
	PlayerTextDrawSetSelectable(playerid, cam_buttonPrev, true);

	cam_buttonAddN = CreatePlayerTextDraw(playerid, 370.000000, 290.000000, "+");
	PlayerTextDrawBackgroundColor(playerid, cam_buttonAddN, 255);
	PlayerTextDrawFont(playerid, cam_buttonAddN, 1);
	PlayerTextDrawLetterSize(playerid, cam_buttonAddN, 0.860000, 2.499999);
	PlayerTextDrawColor(playerid, cam_buttonAddN, -1);
	PlayerTextDrawSetOutline(playerid, cam_buttonAddN, 0);
	PlayerTextDrawSetProportional(playerid, cam_buttonAddN, 1);
	PlayerTextDrawSetShadow(playerid, cam_buttonAddN, 1);
	PlayerTextDrawUseBox(playerid, cam_buttonAddN, 1);
	PlayerTextDrawBoxColor(playerid, cam_buttonAddN, 100);
	PlayerTextDrawTextSize(playerid, cam_buttonAddN, 390.000000, 14.0);
	PlayerTextDrawSetSelectable(playerid, cam_buttonAddN, true);

	cam_buttonBack = CreatePlayerTextDraw(playerid, 500.000000, 110.000000, "Back");
	PlayerTextDrawBackgroundColor(playerid, cam_buttonBack, 255);
	PlayerTextDrawFont(playerid, cam_buttonBack, 1);
	PlayerTextDrawLetterSize(playerid, cam_buttonBack, 0.759999, 2.499999);
	PlayerTextDrawColor(playerid, cam_buttonBack, -16776961);
	PlayerTextDrawSetOutline(playerid, cam_buttonBack, 1);
	PlayerTextDrawSetProportional(playerid, cam_buttonBack, 1);
	PlayerTextDrawUseBox(playerid, cam_buttonBack, 1);
	PlayerTextDrawBoxColor(playerid, cam_buttonBack, 100);
	PlayerTextDrawTextSize(playerid, cam_buttonBack, 560.000000, 14.000000);
	PlayerTextDrawSetSelectable(playerid, cam_buttonBack, true);
}



// Separate functions that are used
stock GetXYFromAngle(&Float:x, &Float:y, Float:a, Float:distance)
	x+=(distance*floatsin(-a,degrees)),y+=(distance*floatcos(-a,degrees));

stock GetXYZFromAngle(&Float:x, &Float:y, &Float:z, Float:angle, Float:elevation, Float:distance)
    x += ( distance*floatsin(angle,degrees)*floatcos(elevation,degrees) ),y += ( distance*floatcos(angle,degrees)*floatcos(elevation,degrees) ),z += ( distance*floatsin(elevation,degrees) );




// Debugging Commands

new temp_camid;
public OnPlayerCommandText(playerid, cmdtext[])
{
	new
		cmd[30],
		params[98];
	sscanf(cmdtext, "s[30]s[98]", cmd, params);

	if(!strcmp(cmd, "/cameras"))
	{
		FormatMainMenu(playerid);
		return 1;
	}
	if(!strcmp(cmd, "/mouse")) // Just in case you exit mouse mode by accident!
	{
		SelectTextDraw(playerid, YELLOW);
		return 1;
	}

	// Some debug commands - Not really needed now the editor is here, but they might come in useful if it glitches.

	if(!strcmp(cmd, "/loadcam"))
	{
		temp_camid = LoadCameraMover(params);
		return 1;
	}
	if(!strcmp(cmd, "/playcam"))
	{
		PlayCameraMover(playerid, temp_camid);
		return 1;
	}
	if(!strcmp(cmd, "/editcam"))
	{
		EditCameraMover(playerid, temp_camid);
		return 1;
	}
	if(!strcmp(cmd, "/exitediting"))
	{
		ExitEditing(playerid);
		return 1;
	}
	if(!strcmp(cmd, "/loadtds")) // In case the textdraws bug up (Although this shouldn't happen now, textdraws now load every time you enter edit mode)
	{
		camera_LoadTextDraws(playerid);
		Msg(playerid, YELLOW, "Textdraws Loaded!");
		return 1;
	}
	return 0;
}
