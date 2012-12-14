/**
 *	Test filterscript for RNPC recordings
 *	@sinve V0.2
 *	Mauzen, 3.7.2012
 */
#include <a_samp>
#include <core>
#include <float>
#include <RNPC>
#include <sscanf2>

new curid;
new gotpos;

public OnPlayerCommandText(playerid, cmdtext[])
{
	new cmd[256];

	// setquats <angle1> <facingangle> <angle3>
	if (!strcmp("/setquats", cmdtext, true, 9)) {
		new Float:a, Float:h, Float:b;
		sscanf(cmdtext, "s[10]fff", cmd, a, h, b);
		RNPC_SetAngleQuats(a, h, b);
		SendClientMessage(playerid, -1, "Quats set.");
		return 1;
	}
	
	// setkeys <keys>
	if (!strcmp("/setkeys", cmdtext, true, 8)) {
		new keys;
		sscanf(cmdtext, "s[9]d", cmd, keys);
		RNPC_SetKeys(keys);
		SendClientMessage(playerid, -1, "Keys set.");
		return 1;
	}
	
	// setlrkeys <keys>
	if (!strcmp("/setlrkeys", cmdtext, true, 10)) {
		new keys;
		sscanf(cmdtext, "s[11]d", cmd, keys);
		RNPC_SetLRKeys(keys);
		SendClientMessage(playerid, -1, "LRKeys set.");
		return 1;
	}
	
	// setudkeys <keys>
	if (!strcmp("/setudkeys", cmdtext, true, 10)) {
		new keys;
		sscanf(cmdtext, "s[11]d", cmd, keys);
		RNPC_SetUDKeys(keys);
		SendClientMessage(playerid, -1, "UDKeys set.");
		return 1;
	}
	
	// setspecialaction <id>
	if (!strcmp("/setspecialaction", cmdtext, true, 10)) {
		new specialaction;
		sscanf(cmdtext, "s[18]d", cmd, specialaction);
		RNPC_SetSpecialAction(specialaction);
		SendClientMessage(playerid, -1, "Specialaction set.");
		return 1;
	}
	
	// setrepeat <1/0>
	if (!strcmp("/setrepeat", cmdtext, true, 10)) {
		new r, a[10];
		sscanf(cmdtext, "s[11]d", cmd, r);
		format(a, 10, "RNPC:%d", 110 + r);
		SendClientMessage(0, -1, a);
		SendClientMessage(playerid, -1, "Repeat set.");
		return 1;
	}
	
	// setweaponid <id>
	if (!strcmp("/setweaponid", cmdtext, true, 11)) {
		new r;
		sscanf(cmdtext, "s[13]d", cmd, r);
		RNPC_SetWeaponID(r);
		SendClientMessage(playerid, -1, "Weapon set.");
		return 1;
	}
	
	// movehere
	if (!strcmp("/movehere", cmdtext, true, 9)) {
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		if (gotpos) {
			RNPC_ConcatMovement(x, y, z, 0.006);
		} else {
			new Float:xx, Float:yy, Float:zz;
			GetPlayerPos(curid, xx, yy, zz);
			RNPC_AddMovement(xx, yy, zz, x, y, z);
			gotpos = 1;
		}
		SendClientMessage(playerid, -1, "Movement added");
		return 1;
	}
	
	// pausehere <time[ms]>
	if (!strcmp("/pausehere", cmdtext, true, 6)) {
		new t;
		sscanf(cmdtext, "s[13]d", cmd, t);
		RNPC_AddPause(t);
		SendClientMessage(playerid, -1, "Pause added");
		return 1;
	}
	
	// createbuild <npcid>
	if (!strcmp("/createbuild", cmdtext, true, 12)) {
		new id;
		sscanf(cmdtext, "s[13]d", cmd, id);
		if (RNPC_CreateBuild(id, PLAYER_RECORDING_TYPE_ONFOOT)) {
			SendClientMessage(playerid, -1, "Build created. Ready for input.");
			curid = id;
			gotpos = 0;
		} else {
			SendClientMessage(playerid, -1, "Creating build failed.");
		}
		return 1;
	}
	
	if (!strcmp("/finishbuild", cmdtext, true, 12)) {
		if (RNPC_FinishBuild()) {
			SendClientMessage(playerid, -1, "Build finished.");
		} else {
			SendClientMessage(playerid, -1, "Finishing build failed.");
		}
		return 1;
	}
	
	if (!strcmp("/playbackbuild", cmdtext, true)) {
		RNPC_StartBuildPlayback(curid);
		SendClientMessage(playerid, -1, "Playback started.");
		return 1;
	}
	
	if (!strcmp("/rnpchelp", cmdtext, true)) {
		ShowPlayerDialog(playerid, 7235, DIALOG_STYLE_MSGBOX, "Testscript commands", "createbuild <npcid>\nfinishbuild\nplaybackbuild\nsetquats <angle1> <facingangle> <angle3>\n"\
		"setkeys <keys>\nsetkeys <keys>\nsetlrkeys <keys>\nsetudkeys <keys>\nsetspecialaction <id>\nsetweaponid <id>\nsetrepeat <1/0>\nmovehere\npausehere <time[ms]>", "Ok", ""); 
		return 1;
	}

	return 0;
}
