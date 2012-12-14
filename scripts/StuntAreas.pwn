#define StuntParkIndex		"Stuntparks/index.ini"
#define StuntParkFile		"Stuntparks/%s.ini"


enum StuntAreaEnum
{
	AreaName[32],
	PerimPoints,
	Float:PerimX[20],
	Float:PerimY[20]
}

new
	StuntAreas[1][StuntAreaEnum];

LoadStuntParks()
{
	print("- Loading Stunt Parks...");
	new
		File:idxFile=fopen(StuntParkIndex, io_read),
		idxLine[40],
		ParkFile[40],
		str[5],
		ParkID,
		line[60];
	while(fread(idxFile, idxLine))
	{
	    format(ParkFile, 40, StuntParkFile, idxLine);
		file_Open(ParkFile);

		StuntAreas[ParkID][PerimPoints]=file_GetVal("PerimPoints");
		for(new i;i<StuntAreas[ParkID][PerimPoints];i++)
		{
			format(str, 5, "pt%d", i);
			format(line, 60, file_GetStr(str));
		    sscanf(line, "p<,>ff", StuntAreas[ParkID][PerimX][i], StuntAreas[ParkID][PerimY][i]);
		}

		file_Close();
		ParkID++;
	}
}

IsPlayerInPark(playerid, ParkID)
{
	new Float:x, Float:y, Float:z, result;
	GetPlayerPos(playerid, x, y, z);
	result=IsPointInPolygon(x, y,
	StuntAreas[ParkID][PerimX][0],StuntAreas[ParkID][PerimY][0],
	StuntAreas[ParkID][PerimX][1],StuntAreas[ParkID][PerimY][1],
	StuntAreas[ParkID][PerimX][2],StuntAreas[ParkID][PerimY][2],
	StuntAreas[ParkID][PerimX][3],StuntAreas[ParkID][PerimY][3],
	StuntAreas[ParkID][PerimX][4],StuntAreas[ParkID][PerimY][4],
	StuntAreas[ParkID][PerimX][5],StuntAreas[ParkID][PerimY][5],
	StuntAreas[ParkID][PerimX][6],StuntAreas[ParkID][PerimY][6],
	StuntAreas[ParkID][PerimX][7],StuntAreas[ParkID][PerimY][7],
	StuntAreas[ParkID][PerimX][8],StuntAreas[ParkID][PerimY][8],
	StuntAreas[ParkID][PerimX][9],StuntAreas[ParkID][PerimY][9],
	StuntAreas[ParkID][PerimX][10],StuntAreas[ParkID][PerimY][10],
	StuntAreas[ParkID][PerimX][11],StuntAreas[ParkID][PerimY][11],
	StuntAreas[ParkID][PerimX][12],StuntAreas[ParkID][PerimY][12],
	StuntAreas[ParkID][PerimX][13],StuntAreas[ParkID][PerimY][13],
	StuntAreas[ParkID][PerimX][14],StuntAreas[ParkID][PerimY][14],
	StuntAreas[ParkID][PerimX][15],StuntAreas[ParkID][PerimY][15],
	StuntAreas[ParkID][PerimX][16],StuntAreas[ParkID][PerimY][16],
	StuntAreas[ParkID][PerimX][17],StuntAreas[ParkID][PerimY][17],
	StuntAreas[ParkID][PerimX][18],StuntAreas[ParkID][PerimY][18],
	StuntAreas[ParkID][PerimX][19],StuntAreas[ParkID][PerimY][19]
	);
	return result;
}
