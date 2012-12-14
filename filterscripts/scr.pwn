#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <md-sort>

#undef MAX_PLAYERS
#define MAX_PLAYERS 32

#define ORIGIN_X 140.0
#define ORIGIN_Y 140.0

#define COLUMN_SCORE_OFFSET 110.0
#define COLUMN_RATIO_OFFSET 145.0
#define COLUMN_END_OFFSET   30.0


public OnFilterScriptExit()
{
	for(new i;i<MAX_PLAYERS;i++)
	{
		for(new r;r<MAX_PLAYERS/2;r++)
		{
		    ScoreBoardDeleteRow(i, 0, r);
		    ScoreBoardDeleteRow(i, 1, r);
			UnloadTD(i);
		}
	}
}


new
	PlayerText:scb_BackGround,
	PlayerText:scb_colName1,
	PlayerText:scb_colScore1,
	PlayerText:scb_colRatio1,
	PlayerText:scb_colName2,
	PlayerText:scb_colScore2,
	PlayerText:scb_colRatio2,
	PlayerText:scb_rowName[2][MAX_PLAYERS/2],
	PlayerText:scb_rowScore[2][MAX_PLAYERS/2],
	PlayerText:scb_rowRatio[2][MAX_PLAYERS/2];
	

LoadTD(playerid)
{
	scb_BackGround					=CreatePlayerTextDraw(playerid, ORIGIN_X, ORIGIN_Y, "_");
	PlayerTextDrawBackgroundColor	(playerid, scb_BackGround, 255);
	PlayerTextDrawFont				(playerid, scb_BackGround, 1);
	PlayerTextDrawLetterSize		(playerid, scb_BackGround, 0.400000, 1.6+((MAX_PLAYERS/2)*1.7));
	PlayerTextDrawColor				(playerid, scb_BackGround, -1);
	PlayerTextDrawSetOutline		(playerid, scb_BackGround, 0);
	PlayerTextDrawSetProportional	(playerid, scb_BackGround, 1);
	PlayerTextDrawSetShadow			(playerid, scb_BackGround, 1);
	PlayerTextDrawUseBox			(playerid, scb_BackGround, 1);
	PlayerTextDrawBoxColor			(playerid, scb_BackGround, 100);
	PlayerTextDrawTextSize			(playerid, scb_BackGround, ORIGIN_X+355.0, 0.000000);



	scb_colName1					=CreatePlayerTextDraw(playerid, ORIGIN_X, ORIGIN_Y, "Name");
	PlayerTextDrawBackgroundColor	(playerid, scb_colName1, 255);
	PlayerTextDrawFont				(playerid, scb_colName1, 1);
	PlayerTextDrawLetterSize		(playerid, scb_colName1, 0.300000, 1.000000);
	PlayerTextDrawColor				(playerid, scb_colName1, -1);
	PlayerTextDrawSetOutline		(playerid, scb_colName1, 0);
	PlayerTextDrawSetProportional	(playerid, scb_colName1, 1);
	PlayerTextDrawSetShadow			(playerid, scb_colName1, 1);
	PlayerTextDrawUseBox			(playerid, scb_colName1, 1);
	PlayerTextDrawBoxColor			(playerid, scb_colName1, 65535);
	PlayerTextDrawTextSize			(playerid, scb_colName1, ORIGIN_X+(COLUMN_SCORE_OFFSET-5), 14.000000);

	scb_colScore1					=CreatePlayerTextDraw(playerid, ORIGIN_X+(COLUMN_SCORE_OFFSET), ORIGIN_Y, "Score");
	PlayerTextDrawBackgroundColor	(playerid, scb_colScore1, 255);
	PlayerTextDrawFont				(playerid, scb_colScore1, 1);
	PlayerTextDrawLetterSize		(playerid, scb_colScore1, 0.300000, 1.000000);
	PlayerTextDrawColor				(playerid, scb_colScore1, -1);
	PlayerTextDrawSetOutline		(playerid, scb_colScore1, 0);
	PlayerTextDrawSetProportional	(playerid, scb_colScore1, 1);
	PlayerTextDrawSetShadow			(playerid, scb_colScore1, 1);
	PlayerTextDrawUseBox			(playerid, scb_colScore1, 1);
	PlayerTextDrawBoxColor			(playerid, scb_colScore1, 65535);
	PlayerTextDrawTextSize			(playerid, scb_colScore1, ORIGIN_X+(COLUMN_RATIO_OFFSET-5), 14.000000);

	scb_colRatio1					=CreatePlayerTextDraw(playerid, ORIGIN_X+(COLUMN_RATIO_OFFSET), ORIGIN_Y, "K/D");
	PlayerTextDrawBackgroundColor	(playerid, scb_colRatio1, 255);
	PlayerTextDrawFont				(playerid, scb_colRatio1, 1);
	PlayerTextDrawLetterSize		(playerid, scb_colRatio1, 0.300000, 1.000000);
	PlayerTextDrawColor				(playerid, scb_colRatio1, -1);
	PlayerTextDrawSetOutline		(playerid, scb_colRatio1, 0);
	PlayerTextDrawSetProportional	(playerid, scb_colRatio1, 1);
	PlayerTextDrawSetShadow			(playerid, scb_colRatio1, 1);
	PlayerTextDrawUseBox			(playerid, scb_colRatio1, 1);
	PlayerTextDrawBoxColor			(playerid, scb_colRatio1, 65535);
	PlayerTextDrawTextSize			(playerid, scb_colRatio1, ORIGIN_X+COLUMN_RATIO_OFFSET+COLUMN_END_OFFSET, 14.000000);



	scb_colName2					=CreatePlayerTextDraw(playerid, ORIGIN_X+180.0, ORIGIN_Y, "Name");
	PlayerTextDrawBackgroundColor	(playerid, scb_colName2, 255);
	PlayerTextDrawFont				(playerid, scb_colName2, 1);
	PlayerTextDrawLetterSize		(playerid, scb_colName2, 0.300000, 1.000000);
	PlayerTextDrawColor				(playerid, scb_colName2, -1);
	PlayerTextDrawSetOutline		(playerid, scb_colName2, 0);
	PlayerTextDrawSetProportional	(playerid, scb_colName2, 1);
	PlayerTextDrawSetShadow			(playerid, scb_colName2, 1);
	PlayerTextDrawUseBox			(playerid, scb_colName2, 1);
	PlayerTextDrawBoxColor			(playerid, scb_colName2, -16776961);
	PlayerTextDrawTextSize			(playerid, scb_colName2, ORIGIN_X+(COLUMN_SCORE_OFFSET-5)+180.0, 14.000000);

	scb_colScore2					=CreatePlayerTextDraw(playerid, ORIGIN_X+(COLUMN_SCORE_OFFSET)+180.0, ORIGIN_Y, "Score");
	PlayerTextDrawBackgroundColor	(playerid, scb_colScore2, 255);
	PlayerTextDrawFont				(playerid, scb_colScore2, 1);
	PlayerTextDrawLetterSize		(playerid, scb_colScore2, 0.300000, 1.000000);
	PlayerTextDrawColor				(playerid, scb_colScore2, -1);
	PlayerTextDrawSetOutline		(playerid, scb_colScore2, 0);
	PlayerTextDrawSetProportional	(playerid, scb_colScore2, 1);
	PlayerTextDrawSetShadow			(playerid, scb_colScore2, 1);
	PlayerTextDrawUseBox			(playerid, scb_colScore2, 1);
	PlayerTextDrawBoxColor			(playerid, scb_colScore2, -16776961);
	PlayerTextDrawTextSize			(playerid, scb_colScore2, ORIGIN_X+(COLUMN_RATIO_OFFSET-5)+180.0, 14.000000);

	scb_colRatio2					=CreatePlayerTextDraw(playerid, ORIGIN_X+(COLUMN_RATIO_OFFSET)+180.0, ORIGIN_Y, "K/D");
	PlayerTextDrawBackgroundColor	(playerid, scb_colRatio2, 255);
	PlayerTextDrawFont				(playerid, scb_colRatio2, 1);
	PlayerTextDrawLetterSize		(playerid, scb_colRatio2, 0.300000, 1.000000);
	PlayerTextDrawColor				(playerid, scb_colRatio2, -1);
	PlayerTextDrawSetOutline		(playerid, scb_colRatio2, 0);
	PlayerTextDrawSetProportional	(playerid, scb_colRatio2, 1);
	PlayerTextDrawSetShadow			(playerid, scb_colRatio2, 1);
	PlayerTextDrawUseBox			(playerid, scb_colRatio2, 1);
	PlayerTextDrawBoxColor			(playerid, scb_colRatio2, -16776961);
	PlayerTextDrawTextSize			(playerid, scb_colRatio2, ORIGIN_X+COLUMN_RATIO_OFFSET+COLUMN_END_OFFSET+180.0, 14.000000);
}
UnloadTD(playerid)
{
	PlayerTextDrawDestroy(playerid, scb_BackGround);
	PlayerTextDrawDestroy(playerid, scb_colName1);
	PlayerTextDrawDestroy(playerid, scb_colScore1);
	PlayerTextDrawDestroy(playerid, scb_colRatio1);
	PlayerTextDrawDestroy(playerid, scb_colName2);
	PlayerTextDrawDestroy(playerid, scb_colScore2);
	PlayerTextDrawDestroy(playerid, scb_colRatio2);
}

CMD:loadtd(playerid, params[])
{
	LoadTD(playerid);
	return 1;
}
CMD:score(playerid, params[])
{
	ShowPlayerScoreBoard(playerid);
	return 1;
}
CMD:scoreoff(playerid, params[])
{
	HidePlayerScoreBoard(playerid);
	return 1;
}
CMD:addrow(playerid, params[])
{
	new
		t,
		r,
		name[24];

	sscanf(params, "d d s[24]", t, r, name);
    ScoreBoardAddRow(playerid, t, r, name, random(10000), random(100), random(100));
    return 1;
}
CMD:deleterow(playerid, params[])
{
	new t, r;
	sscanf(params, "dd", t, r);
    ScoreBoardDeleteRow(playerid, t, r);
    return 1;
}
ShowPlayerScoreBoard(playerid)
{
	PlayerTextDrawShow(playerid, scb_BackGround);
	PlayerTextDrawShow(playerid, scb_colName1);
	PlayerTextDrawShow(playerid, scb_colScore1);
	PlayerTextDrawShow(playerid, scb_colRatio1);
	PlayerTextDrawShow(playerid, scb_colName2);
	PlayerTextDrawShow(playerid, scb_colScore2);
	PlayerTextDrawShow(playerid, scb_colRatio2);
}
HidePlayerScoreBoard(playerid)
{
	PlayerTextDrawHide(playerid, scb_BackGround);
	PlayerTextDrawHide(playerid, scb_colName1);
	PlayerTextDrawHide(playerid, scb_colScore1);
	PlayerTextDrawHide(playerid, scb_colRatio1);
	PlayerTextDrawHide(playerid, scb_colName2);
	PlayerTextDrawHide(playerid, scb_colScore2);
	PlayerTextDrawHide(playerid, scb_colRatio2);
}

CMD:fullscore(playerid, params[])
{
	LoadTD(playerid);
	ShowPlayerScoreBoard(playerid);
	for(new i;i<MAX_PLAYERS/2;i++)
	{
	    ScoreBoardAddRow(playerid, 0, i, "TestPlayerBlueTeam1", random(10000), random(999), random(999));
	    ScoreBoardAddRow(playerid, 1, i, "TestPlayerRedTeam1", random(10000), random(999), random(999));
    }
	return 1;
}

CMD:seth(playerid, params[])
{
	PlayerTextDrawLetterSize(playerid, scb_BackGround, 0.400000, 1.6+floatstr(params));
	PlayerTextDrawShow(playerid, scb_BackGround);
	return 1;
}

ScoreBoardAddRow(playerid, team, row, name[], score, kills, deaths)
{
	new
		Float:columnOffset = 0.0,
		tmpStr[8];

	if(team)columnOffset=180.0;
	if(team>1)return 0;

	scb_rowName[team][row]			=CreatePlayerTextDraw(playerid, ORIGIN_X+columnOffset, 160.0+(15*row), name);
	PlayerTextDrawBackgroundColor	(playerid, scb_rowName[team][row], 255);
	PlayerTextDrawFont				(playerid, scb_rowName[team][row], 1);
	PlayerTextDrawLetterSize		(playerid, scb_rowName[team][row], 0.250000, 1.000000);
	PlayerTextDrawColor				(playerid, scb_rowName[team][row], -1);
	PlayerTextDrawSetOutline		(playerid, scb_rowName[team][row], 0);
	PlayerTextDrawSetProportional	(playerid, scb_rowName[team][row], 1);
	PlayerTextDrawSetShadow			(playerid, scb_rowName[team][row], 1);
	PlayerTextDrawUseBox			(playerid, scb_rowName[team][row], 1);
	PlayerTextDrawBoxColor			(playerid, scb_rowName[team][row], 50);
	PlayerTextDrawTextSize			(playerid, scb_rowName[team][row], ORIGIN_X+(COLUMN_SCORE_OFFSET-5)+columnOffset, 14.000000);

	valstr(tmpStr, score);
	scb_rowScore[team][row]			=CreatePlayerTextDraw(playerid, ORIGIN_X+COLUMN_SCORE_OFFSET+columnOffset, 160.0+(15*row), tmpStr);
	PlayerTextDrawBackgroundColor	(playerid, scb_rowScore[team][row], 255);
	PlayerTextDrawFont				(playerid, scb_rowScore[team][row], 1);
	PlayerTextDrawLetterSize		(playerid, scb_rowScore[team][row], 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid, scb_rowScore[team][row], -1);
	PlayerTextDrawSetOutline		(playerid, scb_rowScore[team][row], 0);
	PlayerTextDrawSetProportional	(playerid, scb_rowScore[team][row], 1);
	PlayerTextDrawSetShadow			(playerid, scb_rowScore[team][row], 1);
	PlayerTextDrawUseBox			(playerid, scb_rowScore[team][row], 1);
	PlayerTextDrawBoxColor			(playerid, scb_rowScore[team][row], 50);
	PlayerTextDrawTextSize			(playerid, scb_rowScore[team][row], ORIGIN_X+(COLUMN_RATIO_OFFSET-5)+columnOffset, 14.000000);

	format(tmpStr, 8, "%d/%d", kills, deaths);
	scb_rowRatio[team][row]			=CreatePlayerTextDraw(playerid, ORIGIN_X+COLUMN_RATIO_OFFSET+columnOffset, 160.0+(15*row), tmpStr);
	PlayerTextDrawBackgroundColor	(playerid, scb_rowRatio[team][row], 255);
	PlayerTextDrawFont				(playerid, scb_rowRatio[team][row], 1);
	PlayerTextDrawLetterSize		(playerid, scb_rowRatio[team][row], 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid, scb_rowRatio[team][row], -1);
	PlayerTextDrawSetOutline		(playerid, scb_rowRatio[team][row], 0);
	PlayerTextDrawSetProportional	(playerid, scb_rowRatio[team][row], 1);
	PlayerTextDrawSetShadow			(playerid, scb_rowRatio[team][row], 1);
	PlayerTextDrawUseBox			(playerid, scb_rowRatio[team][row], 1);
	PlayerTextDrawBoxColor			(playerid, scb_rowRatio[team][row], 50);
	PlayerTextDrawTextSize			(playerid, scb_rowRatio[team][row], ORIGIN_X+COLUMN_RATIO_OFFSET+COLUMN_END_OFFSET+columnOffset, 14.000000);

	PlayerTextDrawShow(playerid, scb_rowName[team][row]);
	PlayerTextDrawShow(playerid, scb_rowScore[team][row]);
	PlayerTextDrawShow(playerid, scb_rowRatio[team][row]);
	
	return 1;
}
ScoreBoardDeleteRow(playerid, team, row)
{
	PlayerTextDrawHide(playerid, scb_rowName[team][row]);
	PlayerTextDrawHide(playerid, scb_rowScore[team][row]);
	PlayerTextDrawHide(playerid, scb_rowRatio[team][row]);
	PlayerTextDrawDestroy(playerid, scb_rowName[team][row]);
	PlayerTextDrawDestroy(playerid, scb_rowScore[team][row]);
	PlayerTextDrawDestroy(playerid, scb_rowRatio[team][row]);
}

