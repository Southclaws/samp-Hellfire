LoadPlayerGUI_AwardMsg(playerid)
{
	AwdMsg_bg = CreatePlayerTextDraw(playerid, 358.000000, 28.000000, "__");
	PlayerTextDrawBackgroundColor(playerid, AwdMsg_bg, 255);
	PlayerTextDrawFont(playerid, AwdMsg_bg, 1);
	PlayerTextDrawLetterSize(playerid, AwdMsg_bg, 0.300000, 2.900000);
	PlayerTextDrawColor(playerid, AwdMsg_bg, -16776961);
	PlayerTextDrawSetOutline(playerid, AwdMsg_bg, 0);
	PlayerTextDrawSetProportional(playerid, AwdMsg_bg, 1);
	PlayerTextDrawSetShadow(playerid, AwdMsg_bg, 0);
	PlayerTextDrawUseBox(playerid, AwdMsg_bg, 1);
	PlayerTextDrawBoxColor(playerid, AwdMsg_bg, 255);
	PlayerTextDrawTextSize(playerid, AwdMsg_bg, 482.000000, 0.000000);

	AwdMsg_lCurve = CreatePlayerTextDraw(playerid, 354.000000, 19.000000, "(");
	PlayerTextDrawBackgroundColor(playerid, AwdMsg_lCurve, 255);
	PlayerTextDrawFont(playerid, AwdMsg_lCurve, 1);
	PlayerTextDrawLetterSize(playerid, AwdMsg_lCurve, 0.300000, 4.000000);
	PlayerTextDrawColor(playerid, AwdMsg_lCurve, 255);
	PlayerTextDrawSetOutline(playerid, AwdMsg_lCurve, 1);
	PlayerTextDrawSetProportional(playerid, AwdMsg_lCurve, 1);

	AwdMsg_rCurve = CreatePlayerTextDraw(playerid, 482.000000, 19.000000, ")");
	PlayerTextDrawBackgroundColor(playerid, AwdMsg_rCurve, 255);
	PlayerTextDrawFont(playerid, AwdMsg_rCurve, 1);
	PlayerTextDrawLetterSize(playerid, AwdMsg_rCurve, 0.290000, 4.000000);
	PlayerTextDrawColor(playerid, AwdMsg_rCurve, 255);
	PlayerTextDrawSetOutline(playerid, AwdMsg_rCurve, 1);
	PlayerTextDrawSetProportional(playerid, AwdMsg_rCurve, 1);

	AwdMsg_iconBox = CreatePlayerTextDraw(playerid, 360.000000, 30.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, AwdMsg_iconBox, 255);
	PlayerTextDrawFont(playerid, AwdMsg_iconBox, 1);
	PlayerTextDrawLetterSize(playerid, AwdMsg_iconBox, 0.500000, 2.399998);
	PlayerTextDrawColor(playerid, AwdMsg_iconBox, -65281);
	PlayerTextDrawSetOutline(playerid, AwdMsg_iconBox, 0);
	PlayerTextDrawSetProportional(playerid, AwdMsg_iconBox, 1);
	PlayerTextDrawSetShadow(playerid, AwdMsg_iconBox, 0);
	PlayerTextDrawUseBox(playerid, AwdMsg_iconBox, 1);
	PlayerTextDrawBoxColor(playerid, AwdMsg_iconBox, -1);
	PlayerTextDrawTextSize(playerid, AwdMsg_iconBox, 377.000000, -110.000000);

	AwdMsg_textBox = CreatePlayerTextDraw(playerid, 380.000000, 30.000000, "Award Unlocked:~n~Close Quarters");
	PlayerTextDrawBackgroundColor(playerid, AwdMsg_textBox, 255);
	PlayerTextDrawFont(playerid, AwdMsg_textBox, 1);
	PlayerTextDrawLetterSize(playerid, AwdMsg_textBox, 0.25, 1.2);
	PlayerTextDrawColor(playerid, AwdMsg_textBox, -65281);
	PlayerTextDrawSetOutline(playerid, AwdMsg_textBox, 0);
	PlayerTextDrawSetProportional(playerid, AwdMsg_textBox, 1);
	PlayerTextDrawSetShadow(playerid, AwdMsg_textBox, 0);
	PlayerTextDrawUseBox(playerid, AwdMsg_textBox, 1);
	PlayerTextDrawBoxColor(playerid, AwdMsg_textBox, -16776961);
	PlayerTextDrawTextSize(playerid, AwdMsg_textBox, 480.000000, -110.000000);

	AwdMsg_iconMain = CreatePlayerTextDraw(playerid, 358.000000, 31.000000, "LD_NONE:ship3");
	PlayerTextDrawBackgroundColor(playerid, AwdMsg_iconMain, 255);
	PlayerTextDrawFont(playerid, AwdMsg_iconMain, 4);
	PlayerTextDrawLetterSize(playerid, AwdMsg_iconMain, 0.300000, 1.200000);
	PlayerTextDrawColor(playerid, AwdMsg_iconMain, -65281);
	PlayerTextDrawSetOutline(playerid, AwdMsg_iconMain, 0);
	PlayerTextDrawSetProportional(playerid, AwdMsg_iconMain, 1);
	PlayerTextDrawSetShadow(playerid, AwdMsg_iconMain, 0);
	PlayerTextDrawUseBox(playerid, AwdMsg_iconMain, 1);
	PlayerTextDrawBoxColor(playerid, AwdMsg_iconMain, -1);
	PlayerTextDrawTextSize(playerid, AwdMsg_iconMain, 20.000000, 20.000000);

}
UnloadPlayerGUI_AwardMsg(playerid)
{
	PlayerTextDrawDestroy(playerid, AwdMsg_bg);
	PlayerTextDrawDestroy(playerid, AwdMsg_lCurve);
	PlayerTextDrawDestroy(playerid, AwdMsg_rCurve);
	PlayerTextDrawDestroy(playerid, AwdMsg_iconBox);
	PlayerTextDrawDestroy(playerid, AwdMsg_textBox);
	PlayerTextDrawDestroy(playerid, AwdMsg_iconMain);
}










LoadPlayerGUI_KillMsg(playerid)
{
	KillMsg_background = CreatePlayerTextDraw(playerid, 200.000000, 340.000000, "~n~~n~~n~~n~");
	PlayerTextDrawBackgroundColor(playerid, KillMsg_background, 255);
	PlayerTextDrawFont(playerid, KillMsg_background, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_background, 0.500000, 2.000000);
	PlayerTextDrawColor(playerid, KillMsg_background, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_background, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_background, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_background, 1);
	PlayerTextDrawUseBox(playerid, KillMsg_background, 1);
	PlayerTextDrawBoxColor(playerid, KillMsg_background, 1677721700);
	PlayerTextDrawTextSize(playerid, KillMsg_background, 440.000000, 0.000000);

	KillMsg_killerIcon = CreatePlayerTextDraw(playerid, 368.000000, 340.000000, "LD_TATT:6clown");
	PlayerTextDrawBackgroundColor(playerid, KillMsg_killerIcon, 255);
	PlayerTextDrawFont(playerid, KillMsg_killerIcon, 4);
	PlayerTextDrawLetterSize(playerid, KillMsg_killerIcon, -1.299999, -2.000000);
	PlayerTextDrawColor(playerid, KillMsg_killerIcon, -16776961);
	PlayerTextDrawSetOutline(playerid, KillMsg_killerIcon, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_killerIcon, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_killerIcon, 1);
	PlayerTextDrawUseBox(playerid, KillMsg_killerIcon, 1);
	PlayerTextDrawBoxColor(playerid, KillMsg_killerIcon, 16711935);
	PlayerTextDrawTextSize(playerid, KillMsg_killerIcon, 72.000000, 72.000000);

	KillMsg_killerName = CreatePlayerTextDraw(playerid, 200.000000, 340.000000, "[SGT](HLF)Southclaw");
	PlayerTextDrawBackgroundColor(playerid, KillMsg_killerName, 255);
	PlayerTextDrawFont(playerid, KillMsg_killerName, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_killerName, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_killerName, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_killerName, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_killerName, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_killerName, 1);


	KillMsg_killerWeap = CreatePlayerTextDraw(playerid, 360.000000, 350.000000, "Sniper Rifle");
	PlayerTextDrawAlignment(playerid, KillMsg_killerWeap, 3);
	PlayerTextDrawBackgroundColor(playerid, KillMsg_killerWeap, 255);
	PlayerTextDrawFont(playerid, KillMsg_killerWeap, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_killerWeap, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_killerWeap, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_killerWeap, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_killerWeap, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_killerWeap, 1);

	KillMsg_killerHlth = CreatePlayerTextDraw(playerid, 360.000000, 360.000000, "78%");
	PlayerTextDrawAlignment(playerid, KillMsg_killerHlth, 3);
	PlayerTextDrawBackgroundColor(playerid, KillMsg_killerHlth, 255);
	PlayerTextDrawFont(playerid, KillMsg_killerHlth, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_killerHlth, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_killerHlth, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_killerHlth, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_killerHlth, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_killerHlth, 1);

	KillMsg_killerScor = CreatePlayerTextDraw(playerid, 360.000000, 370.000000, "4762");
	PlayerTextDrawAlignment(playerid, KillMsg_killerScor, 3);
	PlayerTextDrawBackgroundColor(playerid, KillMsg_killerScor, 255);
	PlayerTextDrawFont(playerid, KillMsg_killerScor, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_killerScor, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_killerScor, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_killerScor, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_killerScor, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_killerScor, 1);

	KillMsg_killerKill = CreatePlayerTextDraw(playerid, 360.000000, 380.000000, "13");
	PlayerTextDrawAlignment(playerid, KillMsg_killerKill, 3);
	PlayerTextDrawBackgroundColor(playerid, KillMsg_killerKill, 255);
	PlayerTextDrawFont(playerid, KillMsg_killerKill, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_killerKill, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_killerKill, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_killerKill, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_killerKill, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_killerKill, 1);

	KillMsg_killerDeat = CreatePlayerTextDraw(playerid, 360.000000, 390.000000, "3");
	PlayerTextDrawAlignment(playerid, KillMsg_killerDeat, 3);
	PlayerTextDrawBackgroundColor(playerid, KillMsg_killerDeat, 255);
	PlayerTextDrawFont(playerid, KillMsg_killerDeat, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_killerDeat, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_killerDeat, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_killerDeat, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_killerDeat, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_killerDeat, 1);

	KillMsg_killerGear = CreatePlayerTextDraw(playerid, 360.000000, 400.000000, "Prox Detector");
	PlayerTextDrawAlignment(playerid, KillMsg_killerGear, 3);
	PlayerTextDrawBackgroundColor(playerid, KillMsg_killerGear, 255);
	PlayerTextDrawFont(playerid, KillMsg_killerGear, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_killerGear, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_killerGear, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_killerGear, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_killerGear, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_killerGear, 1);

	KillMsg_dTitleWeap = CreatePlayerTextDraw(playerid, 200.000000, 350.000000, "Weapon");
	PlayerTextDrawBackgroundColor(playerid, KillMsg_dTitleWeap, 255);
	PlayerTextDrawFont(playerid, KillMsg_dTitleWeap, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_dTitleWeap, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_dTitleWeap, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_dTitleWeap, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_dTitleWeap, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_dTitleWeap, 1);

	KillMsg_dTitleHlth = CreatePlayerTextDraw(playerid, 200.000000, 360.000000, "Health");
	PlayerTextDrawBackgroundColor(playerid, KillMsg_dTitleHlth, 255);
	PlayerTextDrawFont(playerid, KillMsg_dTitleHlth, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_dTitleHlth, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_dTitleHlth, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_dTitleHlth, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_dTitleHlth, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_dTitleHlth, 1);

	KillMsg_dTitleScor = CreatePlayerTextDraw(playerid, 200.000000, 370.000000, "Score");
	PlayerTextDrawBackgroundColor(playerid, KillMsg_dTitleScor, 255);
	PlayerTextDrawFont(playerid, KillMsg_dTitleScor, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_dTitleScor, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_dTitleScor, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_dTitleScor, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_dTitleScor, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_dTitleScor, 1);

	KillMsg_dTitleKill = CreatePlayerTextDraw(playerid, 200.000000, 380.000000, "Kills");
	PlayerTextDrawBackgroundColor(playerid, KillMsg_dTitleKill, 255);
	PlayerTextDrawFont(playerid, KillMsg_dTitleKill, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_dTitleKill, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_dTitleKill, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_dTitleKill, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_dTitleKill, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_dTitleKill, 1);

	KillMsg_dTitleDeat = CreatePlayerTextDraw(playerid, 200.000000, 390.000000, "Deaths");
	PlayerTextDrawBackgroundColor(playerid, KillMsg_dTitleDeat, 255);
	PlayerTextDrawFont(playerid, KillMsg_dTitleDeat, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_dTitleDeat, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_dTitleDeat, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_dTitleDeat, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_dTitleDeat, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_dTitleDeat, 1);

	KillMsg_dTitleGear = CreatePlayerTextDraw(playerid, 200.000000, 400.000000, "Gear Item");
	PlayerTextDrawBackgroundColor(playerid, KillMsg_dTitleGear, 255);
	PlayerTextDrawFont(playerid, KillMsg_dTitleGear, 1);
	PlayerTextDrawLetterSize(playerid, KillMsg_dTitleGear, 0.300000, 1.000000);
	PlayerTextDrawColor(playerid, KillMsg_dTitleGear, -1);
	PlayerTextDrawSetOutline(playerid, KillMsg_dTitleGear, 0);
	PlayerTextDrawSetProportional(playerid, KillMsg_dTitleGear, 1);
	PlayerTextDrawSetShadow(playerid, KillMsg_dTitleGear, 1);
}
UnloadPlayerGUI_KillMsg(playerid)
{
	PlayerTextDrawDestroy(playerid, KillMsg_background);
	PlayerTextDrawDestroy(playerid, KillMsg_killerIcon);
	PlayerTextDrawDestroy(playerid, KillMsg_killerName);
	PlayerTextDrawDestroy(playerid, KillMsg_killerWeap);
	PlayerTextDrawDestroy(playerid, KillMsg_killerHlth);
	PlayerTextDrawDestroy(playerid, KillMsg_killerScor);
	PlayerTextDrawDestroy(playerid, KillMsg_killerKill);
	PlayerTextDrawDestroy(playerid, KillMsg_killerDeat);
	PlayerTextDrawDestroy(playerid, KillMsg_killerGear);
	PlayerTextDrawDestroy(playerid, KillMsg_dTitleWeap);
	PlayerTextDrawDestroy(playerid, KillMsg_dTitleHlth);
	PlayerTextDrawDestroy(playerid, KillMsg_dTitleScor);
	PlayerTextDrawDestroy(playerid, KillMsg_dTitleKill);
	PlayerTextDrawDestroy(playerid, KillMsg_dTitleDeat);
	PlayerTextDrawDestroy(playerid, KillMsg_dTitleGear);
}










LoadPlayerGUI_GraphicMenu(playerid)
{
	dm_GraMenu_Back					=CreatePlayerTextDraw(playerid, 150.000000, 324.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_Back, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_Back, 0);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_Back, 0.000000, 10.200008);
	PlayerTextDrawColor				(playerid, dm_GraMenu_Back, 100);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_Back, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_Back, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_Back, 1);
	PlayerTextDrawUseBox			(playerid, dm_GraMenu_Back, 1);
	PlayerTextDrawBoxColor			(playerid, dm_GraMenu_Back, 100);
	PlayerTextDrawTextSize			(playerid, dm_GraMenu_Back, 490.000000, 0.000000);

	dm_GraMenu_Left					=CreatePlayerTextDraw(playerid, 150.000000, 330.000000, "~<~");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_Left, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_Left, 0);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_Left, 1.300000, 8.000000);
	PlayerTextDrawColor				(playerid, dm_GraMenu_Left, -1);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_Left, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_Left, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_Left, 1);
	PlayerTextDrawSetSelectable		(playerid, dm_GraMenu_Left, true);

	dm_GraMenu_Right				=CreatePlayerTextDraw(playerid, 435.000000, 330.000000, "~>~");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_Right, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_Right, 0);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_Right, 1.299999, 8.000000);
	PlayerTextDrawColor				(playerid, dm_GraMenu_Right, -16776961);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_Right, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_Right, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_Right, 1);
	PlayerTextDrawSetSelectable		(playerid, dm_GraMenu_Right, true);

	dm_GraMenu_LeftOpt				=CreatePlayerTextDraw(playerid, 210.000000, 340.000000, "LD_TATT:8gun");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_LeftOpt, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_LeftOpt, 4);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_LeftOpt, 0.000000, -3.000000);
	PlayerTextDrawColor				(playerid, dm_GraMenu_LeftOpt, -156);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_LeftOpt, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_LeftOpt, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_LeftOpt, 1);
	PlayerTextDrawUseBox			(playerid, dm_GraMenu_LeftOpt, 1);
	PlayerTextDrawBoxColor			(playerid, dm_GraMenu_LeftOpt, 255);
	PlayerTextDrawTextSize			(playerid, dm_GraMenu_LeftOpt, 60.000000, 60.000000);

	dm_GraMenu_MidOpt				=CreatePlayerTextDraw(playerid, 280.000000, 330.000000, "LD_TATT:9gun");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_MidOpt, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_MidOpt, 4);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_MidOpt, 0.000000, -3.000000);
	PlayerTextDrawColor				(playerid, dm_GraMenu_MidOpt, -1);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_MidOpt, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_MidOpt, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_MidOpt, 1);
	PlayerTextDrawUseBox			(playerid, dm_GraMenu_MidOpt, 1);
	PlayerTextDrawBoxColor			(playerid, dm_GraMenu_MidOpt, 255);
	PlayerTextDrawTextSize			(playerid, dm_GraMenu_MidOpt, 80.000000, 80.000000);

	dm_GraMenu_RightOpt				=CreatePlayerTextDraw(playerid, 370.000000, 340.000000, "LD_TATT:7gun");
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_RightOpt, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_RightOpt, 4);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_RightOpt, 0.000000, -3.000000);
	PlayerTextDrawColor				(playerid, dm_GraMenu_RightOpt, -156);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_RightOpt, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_RightOpt, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_RightOpt, 1);
	PlayerTextDrawUseBox			(playerid, dm_GraMenu_RightOpt, 1);
	PlayerTextDrawBoxColor			(playerid, dm_GraMenu_RightOpt, 255);
	PlayerTextDrawTextSize			(playerid, dm_GraMenu_RightOpt, 60.000000, 60.000000);

	dm_GraMenu_Accept				=CreatePlayerTextDraw(playerid, 320.000000, 304.000000, "Accept");
	PlayerTextDrawAlignment			(playerid, dm_GraMenu_Accept, 2);
	PlayerTextDrawBackgroundColor	(playerid, dm_GraMenu_Accept, 255);
	PlayerTextDrawFont				(playerid, dm_GraMenu_Accept, 1);
	PlayerTextDrawLetterSize		(playerid, dm_GraMenu_Accept, 0.400000, 1.600008);
	PlayerTextDrawColor				(playerid, dm_GraMenu_Accept, -1);
	PlayerTextDrawSetOutline		(playerid, dm_GraMenu_Accept, 0);
	PlayerTextDrawSetProportional	(playerid, dm_GraMenu_Accept, 1);
	PlayerTextDrawSetShadow			(playerid, dm_GraMenu_Accept, 1);
	PlayerTextDrawUseBox			(playerid, dm_GraMenu_Accept, 1);
	PlayerTextDrawBoxColor			(playerid, dm_GraMenu_Accept, 100);
	PlayerTextDrawTextSize			(playerid, dm_GraMenu_Accept, 10.000000, 84.000000);
	PlayerTextDrawSetSelectable		(playerid, dm_GraMenu_Accept, true);
}
UnloadPlayerGUI_GraphicMenu(playerid)
{
	PlayerTextDrawDestroy(playerid, dm_GraMenu_Back);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_Left);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_Right);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_LeftOpt);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_MidOpt);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_RightOpt);
	PlayerTextDrawDestroy(playerid, dm_GraMenu_Accept);
}










LoadPlayerGUI_SpectateButtons(playerid)
{
	SpecControl_Name				=CreatePlayerTextDraw(playerid, 320.000000, 350.000000, "LongNameTestLongNameTest");
	PlayerTextDrawAlignment			(playerid, SpecControl_Name, 2);
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_Name, 255);
	PlayerTextDrawFont				(playerid, SpecControl_Name, 1);
	PlayerTextDrawLetterSize		(playerid, SpecControl_Name, 0.400000, 2.000000);
	PlayerTextDrawColor				(playerid, SpecControl_Name, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_Name, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_Name, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_Name, 1);
	PlayerTextDrawUseBox			(playerid, SpecControl_Name, 1);
	PlayerTextDrawBoxColor			(playerid, SpecControl_Name, 0x000000AA);
	PlayerTextDrawTextSize			(playerid, SpecControl_Name, 20.000000, 200.000000);

	SpecControl_Text				=CreatePlayerTextDraw(playerid, 320.000000, 336.000000, "spectating (click for freelook)");
	PlayerTextDrawAlignment			(playerid, SpecControl_Text, 2);
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_Text, 255);
	PlayerTextDrawFont				(playerid, SpecControl_Text, 2);
	PlayerTextDrawLetterSize		(playerid, SpecControl_Text, 0.220000, 1.200000);
	PlayerTextDrawColor				(playerid, SpecControl_Text, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_Text, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_Text, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_Text, 1);
	PlayerTextDrawTextSize			(playerid, SpecControl_Text, 10.0, 200.0);
	PlayerTextDrawSetSelectable		(playerid, SpecControl_Text, true);

	SpecControl_BtnL				=CreatePlayerTextDraw(playerid, 202.000000, 347.000000, "<");
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_BtnL, 255);
	PlayerTextDrawFont				(playerid, SpecControl_BtnL, 1);
	PlayerTextDrawLetterSize		(playerid, SpecControl_BtnL, 0.509999, 2.499999);
	PlayerTextDrawColor				(playerid, SpecControl_BtnL, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_BtnL, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_BtnL, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_BtnL, 1);
	PlayerTextDrawTextSize			(playerid, SpecControl_BtnL, 216.0, 20.0);
	PlayerTextDrawSetSelectable		(playerid, SpecControl_BtnL, true);

	SpecControl_BtnR				=CreatePlayerTextDraw(playerid, 426.000000, 347.000000, ">");
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_BtnR, 255);
	PlayerTextDrawFont				(playerid, SpecControl_BtnR, 1);
	PlayerTextDrawLetterSize		(playerid, SpecControl_BtnR, 0.509999, 2.499999);
	PlayerTextDrawColor				(playerid, SpecControl_BtnR, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_BtnR, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_BtnR, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_BtnR, 1);
	PlayerTextDrawTextSize			(playerid, SpecControl_BtnR, 440.0, 20.0);
	PlayerTextDrawSetSelectable		(playerid, SpecControl_BtnR, true);

	SpecControl_Mode				=CreatePlayerTextDraw(playerid, 535.000000, 347.000000, "Mode: Normal");
	PlayerTextDrawAlignment			(playerid, SpecControl_Mode, 2);
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_Mode, 255);
	PlayerTextDrawFont				(playerid, SpecControl_Mode, 2);
	PlayerTextDrawLetterSize		(playerid, SpecControl_Mode, 0.219999, 1.200000);
	PlayerTextDrawColor				(playerid, SpecControl_Mode, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_Mode, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_Mode, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_Mode, 1);
	PlayerTextDrawTextSize			(playerid, SpecControl_Mode, 9.000000, 80.000000);
	PlayerTextDrawSetSelectable		(playerid, SpecControl_Mode, true);

	SpecControl_Hide				=CreatePlayerTextDraw(playerid, 535.000000, 358.000000, "Hide HUD");
	PlayerTextDrawAlignment			(playerid, SpecControl_Hide, 2);
	PlayerTextDrawBackgroundColor	(playerid, SpecControl_Hide, 255);
	PlayerTextDrawFont				(playerid, SpecControl_Hide, 2);
	PlayerTextDrawLetterSize		(playerid, SpecControl_Hide, 0.219999, 1.200000);
	PlayerTextDrawColor				(playerid, SpecControl_Hide, -1);
	PlayerTextDrawSetOutline		(playerid, SpecControl_Hide, 0);
	PlayerTextDrawSetProportional	(playerid, SpecControl_Hide, 1);
	PlayerTextDrawSetShadow			(playerid, SpecControl_Hide, 1);
	PlayerTextDrawTextSize			(playerid, SpecControl_Hide, 9.000000, 80.000000);
	PlayerTextDrawSetSelectable		(playerid, SpecControl_Hide, true);
}
UnloadPlayerGUI_SpectateButtons(playerid)
{
	PlayerTextDrawDestroy(playerid, SpecControl_Name);
	PlayerTextDrawDestroy(playerid, SpecControl_Text);
	PlayerTextDrawDestroy(playerid, SpecControl_BtnL);
	PlayerTextDrawDestroy(playerid, SpecControl_BtnR);
	PlayerTextDrawDestroy(playerid, SpecControl_Mode);
	PlayerTextDrawDestroy(playerid, SpecControl_Hide);
}

