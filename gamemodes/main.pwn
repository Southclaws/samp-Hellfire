#include <a_samp>

#define size (4)
main()
{
	func("h3i");
}

func(arr[size])
{
	print(arr);
}


#endinput 


#define TESTS 1000000
#define AVE_TESTS 10


main()
{
	new
		tick,
		tmptick,
		total;

	new str[32];
	
	str = "hello, this is a long string";

	for(new a;a<AVE_TESTS;a++)
	{
		tick=tickcount();
		for(new i;i<TESTS;i++)
		{
		    strfind(str, "hello, this is a long string");
		}
		tmptick = tickcount()-tick;
		printf("Test 1: Run %d times, took %dms", TESTS, tmptick);
		total += tmptick;
	}
	printf("Average Per "#TESTS" tests: %d", total / AVE_TESTS);
	
	total = 0;

	for(new a;a<AVE_TESTS;a++)
	{
		tick=tickcount();
		for(new i;i<TESTS;i++)
		{
		    strcmp(str, "hello, this is a long string");
		}
		tmptick = tickcount()-tick;
		printf("Test 2: Run %d times, took %dms", TESTS, tmptick);
		total += tmptick;
	}
	printf("Average Per "#TESTS" tests: %d", total / AVE_TESTS);
}


#endinput

#include <a_samp>



main()
{

	new
		string[55],
		iPos1,
		iPos2;
	
	string="this part will be {FF0000}red the dist needs checking";

	iPos1 = strfind(string, "{");
	iPos2 = strfind(string, "}");
	
	printf("Pos1: %d, pos2: %d difference: %d", iPos1, iPos2, (iPos2-iPos1));


}

stock returnCapitalizedName(szName[])
{
    new
        iUnderscorePos;

    iUnderscorePos= strfind(szName, "_");

    szName[0] = toupper(szName[0]);
    szName[iUnderscorePos+1] = toupper(szName[iUnderscorePos+1]);
}

#endinput

#define TESTS 10000000

#define RandomEx_macro(%0,%1) \
(random((%1) - (%0)) + (%0))
stock RandomEx_func(const iMin, const iMax)
{
    return random(iMax - iMin) + iMin;
}
main()
{
	new tick;

	tick=GetTickCount();
	for(new i;i<TESTS;i++)func(RandomEx_func(1, 1000));
	printf("Function: %d", GetTickCount()-tick);


	tick=GetTickCount();
	for(new i;i<TESTS;i++)func(RandomEx_macro(1, 1000));
	printf("Function: %d", GetTickCount()-tick);

	
}

func(num)
{
	return num;
}

#endinput





/*
	#define TESTS 10000
	new tickCheck,tickCheckIncrement,tickCheckAssign[TESTS];
	new tickCheckTotal, Float:tickCheckAve;

	new tick=GetTickCount();
	for(new i;i<TESTS;i++)
	{
	    PlayerUpdate(0);
	}
	for(new c;c<TESTS;c++)tickCheckTotal+=tickCheckAssign[c];
	tickCheckAve=floatdiv(tickCheckTotal, TESTS);
	printf("final count: %d",GetTickCount()-tick);
	printf("total: %d", tickCheckTotal);
	printf("avearge: %f", tickCheckAve);
	printf("predicted: %d", floatround(floatmul(tickCheckAve, TESTS)));

    tickCheck=GetTickCount(); top of func

	tickCheckAssign[tickCheckIncrement]=(GetTickCount()-tickCheck); bottom of func
	tickCheckIncrement++;


--put in function to test

top
    tickCheck=GetTickCount();

bottom
	tickCheckAssign[tickCheckIncrement]=(GetTickCount()-tickCheck);
	tickCheckIncrement++;

--for the average speed etc
*/





#define MAX 100

some funky shit
{
	new a=1, str[MAX], strvar, direction=1;
	while(a==1)
	{
	    for(new x;x<strvar;x++)str[x]='-';
		str[strvar]='|';
		str[strvar+1]=EOS;
	    print(str);
	    if(strvar==MAX-2)direction=-1;
	    if(strvar==0)direction=1;
	    strvar+=direction;

	}

}




#endinput




#define LEN_YEAR 365

new DaysInMonth[12]={31,28,31,30,31,30,31,31,30,31,30,31};

main()
{
	GetDaysBetween(1994, 12, 4, 2011, 6, 14);
}

GetDaysBetween(i_year, i_month, i_day, f_year, f_month, f_day)
{
	printf("total years: %d, months: %d, days: %d", (f_year-i_year), (f_month-i_month), (f_day-i_day));

	if(i_day>DaysInMonth[i_month])printf("month: %d has %d days in, the parameter for days is %d, this is invalid", i_month, DaysInMonth[i_month], i_day);
	if(f_day>DaysInMonth[f_month])printf("month: %d has %d days in, the parameter for days is %d, this is invalid", f_month, DaysInMonth[f_month], f_day);

	new
		t_year,
		t_days;

	t_year=f_year-i_year;
	if(t_year>0)t_days+=(365*t_year);
	
	if((f_month-i_month)>0)
	{
		for(new m = i_month; m < f_month;m++)
		{
		    printf("month: %d has %d days in, adding to total", m, DaysInMonth[m]);
		    t_days+=DaysInMonth[m];
		}
	}
	
	printf("initial day: %d final day: %d adding (%d) to %d", i_day, f_day, (f_day-i_day), t_days);
	
	t_days+=(f_day-i_day);
	
	printf("total days between %d.%d.%d and %d.%d.%d is %d", i_day, i_month, i_year, f_day, f_month, f_year, t_days);
}


#endinput


/*
	new c[4], str[4];
	str="@[3";
	for(new i1=32;i1<128;i1++)
		for(new i2=32;i2<128;i2++)
			for(new i3=32;i3<128;i3++)
			{
	    		c[0]=i1,c[1]=i2,c[2]=i3;
				if(!strcmp(c, str))
				{
					printf("Found: %s = %s", c, str);
					break;
				}
			}


	new c[50], r;
	c[0]='|';
	for(;;)
	{
		if(strlen(c)==sizeof(c))r=1, c[strlen(c)-1]=random(4000);
		if(strlen(c)==1)r=0, c[strlen(c)-1]=random(4000);
	    if(r==0)
		{
			strins(c, "-", 0);
		}
		if(r==1)
		{
		    strdel(c, 0, 1);
		}
	    print(c);
	}
}
*/


















#endinput






/*
	new str[11];

	str = "0x33CCFF00";

	new var[4];

	var[0] = floatround( (hexchar(str[2])*floatpower(16,1)) + (hexchar(str[3])*floatpower(16,0)) );
	var[1] = floatround( (hexchar(str[4])*floatpower(16,1)) + (hexchar(str[5])*floatpower(16,0)) );
	var[2] = floatround( (hexchar(str[6])*floatpower(16,1)) + (hexchar(str[7])*floatpower(16,0)) );
	var[3] = floatround( (hexchar(str[8])*floatpower(16,1)) + (hexchar(str[9])*floatpower(16,0)) );

	printf("%d %d %d %d", var[0], var[1], var[2], var[3]);

	printf("%d\n", 0x33CCFF00);

//	printf("%d",
*/


stock hexchar(ch[])
{
	new base16[16]={'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
	for(new x;x<16;x++)if(ch[0]==base16[x])return x;
	return -1;
}





























#endinput
LoadVehiclesFromFile(mapfile[])
{
	new filename[50];
	format(filename, 50, "%s", mapfile);
	new
		File:F=fopen(filename, io_read),
		str[256],
		modelid,
		Float:data[4],
		data2[3],
		FuncType[50],
		line;
	if(!fexist(filename))return printf("ERROR- file: \"%s\" NOT FOUND", mapfile);
	while(fread(F, str))
	{
		line++;
		if(!sscanf(str, "p<(>s[50]p<,>dffffddp<)>d", FuncType, modelid, data[0], data[1], data[2], data[3], data2[0], data2[1], data2[2]))
		CreateVehicle(modelid, data[0], data[1], data[2], data[3], data2[0], data2[1], data2[2]);
		else printf("ERROR- file: \"%s\", line: %d", mapfile, line);
	}
	return line;
}




#endinput


//For converting height data of camera positions in deathmatch data files
{
	new Float:MapHeight[24]=
	{400.0,500.0,0.0,0.0,
	0.0,0.0,0.0,0.0,
	800.0,0.0,0.0,0.0,
	800.0,800.0,0.0,0.0,
	1400.0,0.0,0.0,0.0,
	0.0,0.0,800.0,0.0};

	new dmFile[50], Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2;
	for(new d;d<sizeof(MapNames);d++)
	{
	    format(dmFile, 50, dmDataFile, d, MapNames[d]);
	    printf("\n%s", dmFile);
		Fini_OpenFile(dmFile);
		{
			new line[256];
			line = Fini_GetStr("GEN_CamPos");
			sscanf(line, "p<,>ffffff", x, y, z, x2, y2, z2);
			printf("- %f, %f", z, z2);
			z-=MapHeight[d],
			z2-=MapHeight[d];
			printf("- %f, %f", z, z2);

			format(line, 256, "%f, %f, %f, %f, %f, %f", x, y, z, x2, y2, z2);

			printf("%s\n", line);
			Fini_SetStr("GEN_CamPos", line);
			Fini_SaveFile();
		}
		Fini_CloseFile();
	}
}

PutDMDataInFiles()
{
	for(new x;x<sizeof(MapNames);x++)
	{
	    printf("\n******* LOADING '%d' *******", x);
	    new n[128];
	    format(n, 128, "Deathmatch\\%d-%s.ini", x, MapNames[x]);
		Fini_Create(n);
		Fini_OpenFile(n);

		for(new m;m<5;m++)
		{
			DMmap=x;
			DMmode=m;
			Vehicles=false;

			printf("ValidMapMode(%d, %d)", x, m);
			if(ValidMapMode(x, m))
			{
				printf("-- 3 MAP %d, MODE %d", x, m);
				DMInit();

				new str[128];

				format(str, 128, "%f, %f, %f, %f, %f, %f", DMCamPos[x][0], DMCamPos[x][1], DMCamPos[x][2], DMCamPos[x][3], DMCamPos[x][4], DMCamPos[x][5]);
				Fini_SetStr("GEN_CamPos=", str);
				format(str, 128, "%d", DMweather);
				Fini_SetStr("GEN_Weather=", str);
				format(str, 128, "%d, %d", DMtime_H, DMtime_M);
				Fini_SetStr("GEN_Time=", str);
				format(str, 128, "%s", MapAuthors[x]);
				Fini_SetStr("GEN_Author=", str);
				format(str, 128, "%f, %f, %f", SpawnPositions[x][0][0], SpawnPositions[x][0][1], SpawnPositions[x][0][2]);
				Fini_SetStr("GEN_spawn1=", str);
				format(str, 128, "%f, %f, %f", SpawnPositions[x][1][0], SpawnPositions[x][1][1], SpawnPositions[x][1][2]);
				Fini_SetStr("GEN_spawn2=", str);

				if(m==1)
				{
				    format(str, 128, "%f, %f, %f", CapturePoint[0][0], CapturePoint[0][1], CapturePoint[0][2]);
					Fini_SetStr("AD_CapturePoint1", str);
					if(CapturePoint[1][0]!=0)
					{
					    format(str, 128, "%f, %f, %f", CapturePoint[1][0], CapturePoint[1][1], CapturePoint[1][2]);
						Fini_SetStr("AD_CapturePoint2", str);
					    format(str, 128, "%f, %f, %f", CapturePoint[2][0], CapturePoint[2][1], CapturePoint[2][2]);
						Fini_SetStr("AD_CapturePoint3", str);
					}
				    format(str, 128, "%d", DefendingTeam);
					Fini_SetStr("AD_DefendingTeam", str);
				}
				if(m==3)
				{
				    format(str, 128, "%f, %f, %f", Rflagpoint[0], Rflagpoint[1], Rflagpoint[2]);
					Fini_SetStr("CTF_Rflagpoint", str);

				    format(str, 128, "%f, %f, %f", Vflagpoint[0], Vflagpoint[1], Vflagpoint[2]);
					Fini_SetStr("CTF_Vflagpoint", str);

				    format(str, 128, "%f, %f, %f", Rdroppoint[0], Rdroppoint[1], Rdroppoint[2]);
					Fini_SetStr("CTF_Rdroppoint", str);

				    format(str, 128, "%f, %f, %f", Vdroppoint[0], Vdroppoint[1], Vdroppoint[2]);
					Fini_SetStr("CTF_Vdroppoint", str);
				}
				if(m==4)
				{
				    format(str, 128, "%d", CPmap);
					Fini_SetStr("CQS_id", str);
				    format(str, 128, "%f, %f, %f", CPpoint[0][0], CPpoint[0][1], CPpoint[0][2]);
					Fini_SetStr("CQS_point1", str);
				    format(str, 128, "%f, %f, %f", CPpoint[1][0], CPpoint[1][1], CPpoint[1][2]);
					Fini_SetStr("CQS_point2", str);
				    format(str, 128, "%f, %f, %f", CPpoint[2][0], CPpoint[2][1], CPpoint[2][2]);
					Fini_SetStr("CQS_point3", str);
				    format(str, 128, "%f, %f, %f", CPpoint[3][0], CPpoint[3][1], CPpoint[3][2]);
					Fini_SetStr("CQS_point4", str);


				    format(str, 128, "%f, %f, %f", CPOfSet[0][0], CPOfSet[0][1], CPOfSet[0][2]);
					Fini_SetStr("CQS_CPOfSet1", str);
				    format(str, 128, "%f, %f, %f", CPOfSet[1][0], CPOfSet[1][1], CPOfSet[1][2]);
					Fini_SetStr("CQS_CPOfSet2", str);
				    format(str, 128, "%f, %f, %f", CPOfSet[2][0], CPOfSet[2][1], CPOfSet[2][2]);
					Fini_SetStr("CQS_CPOfSet3", str);
				    format(str, 128, "%f, %f, %f", CPOfSet[3][0], CPOfSet[3][1], CPOfSet[3][2]);
					Fini_SetStr("CQS_CPOfSet4", str);


				    format(str, 128, "%d", CPowner[0]);
					Fini_SetStr("CQS_owner1", str);
				    format(str, 128, "%d", CPowner[1]);
					Fini_SetStr("CQS_owner2", str);
				    format(str, 128, "%d", CPowner[2]);
					Fini_SetStr("CQS_owner3", str);
				    format(str, 128, "%d", CPowner[3]);
					Fini_SetStr("CQS_owner4", str);

				}
				EndDM();
			}
		}
	    printf("******* COMPLETED '%d' *******\n", x);
		Fini_SaveFile();
		Fini_CloseFile();
	}
}

stock StringHexToVal(str[])
{
	new
		len=(strlen(str)-1),
		var,
		varold;
	for(new i = len, x = 0; i >= 0 && x <= len; i--, x++)
	{
		var = floatround(hexchar(str[x])*floatpower(2, i) + varold);
		varold=var;
	}
	return var;
}

stock hexchar(ch[])
{
	new base16[16]={'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
	for(new x;x<16;x++)
	{
	    if(toupper(ch[0])==base16[x])return x;
	}
	return -1;
}


stock StringBinToVal(str[])
{
	new
		len=(strlen(str)-1),
		var,
		varold;
	for(new i = len, x = 0; i >= 0 && x <= len; i--, x++)
	{
		var = floatround(((str[x]-48)*floatpower(2, i)) + varold);
		varold=var;
	}
	return var;
}












#endinput
ConvertObjectsForAttach()
//converts a group of CreatObject lines to ones ready to attach to a vehicle
{
	new File:F1=fopen("steam roller.pwn", io_read);
	new File:F2=fopen("steam roller new.pwn", io_write);
	new line[128];
	new write[128];
	new s[20], m, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, i;
	while(fread(F1, line))
	{
	    sscanf(line, "p<(>s[20]p<,>dfffffp<)>f", s, m, x, y, z, rx, ry, rz);
	    format(write, 128, "ac[%d]=CreateObject(%d, %f, %f, %f, %f, %f, %f);\r\n", i, m, x, y, z, rx, ry, rz);
	    fwrite(F2, write);
	    format(write, 128, "AttachObjectToVehicle(ac[%d], playerveh, %f, %f, %f, %f, %f, %f);\r\n", i, x, y, z, rx, ry, rz);
	    fwrite(F2, write);
	    i++;
	}
	fclose(F1);
	fclose(F2);
}
MapConvertForEditor()
//converts the standard deathmatch map files for use in the editor
{
	new
		File:F1=fopen("map.pwn", io_read),
		File:F2=fopen("map2.pwn", io_write),
		str1[256],
		str2[256];
	while(fread(F1, str1))
	{
	    strdel(str1, (strlen(str1)-3), strlen(str1));
	    format(str2, 256, "CreateObject(%s);\n", str1);
	    fwrite(F2, str2);
	}
	fclose(F1);
	fclose(F2);
}
RelocateMapZ()
{
	new MapNames[24][13]=
	{"Derelict","Orick","Area 69","Sandy","Carson","Station",
	"Frieght","Barrancas","Backlot","Island","Lagoon","Isles",
	"Rusty","Trainyard","Peninsula","Desert",
	"Desolate","Hideout","Bunker","Woodlands",
	"Leafy Hollow","Bridge","Outskirts","Sewers"},
	Float:MapHeight[24]=
	{400.0,500.0,0.0,0.0,
	0.0,0.0,0.0,0.0,
	800.0,0.0,0.0,0.0,
	800.0,800.0,0.0,0.0,
	1400.0,0.0,0.0,0.0,
	0.0,0.0,800.0,0.0};
    new File:file, File:wfile, fname[30], wname[30], line[128], write[128],
	modelid, Float:px, Float:py, Float:pz, Float:rx, Float:ry, Float:rz;
	for(new mapid;mapid<24;mapid++)
	{
	    print("===========================================");

	    format(fname, 30, "dmMaps/%d-%s.map", mapid, MapNames[mapid]);
	    format(wname, 30, "dmMaps2/%d-%s.map", mapid, MapNames[mapid]);

	    printf("id: %d - name: %s - file: %s - new file: %s", mapid, MapNames[mapid], fname, wname);

	    file=fopen(fname, io_read);
	    print("3");
	    wfile=fopen(wname, io_write);
	    print("4");

	    while(fread(file, line))
	    {
	        print("scan");
	        sscanf(line, "p<,>dffffff", modelid, px, py, pz, rx, ry, rz);
	        print("format");
			format(write, 256, "%d, %f, %f, %f, %f, %f, %f\r\n", modelid, px, py, (pz-MapHeight[mapid]), rx, ry, rz);
	        print("write");
			fwrite(wfile, write);
	        print("complete");
	    }

	    fclose(file);
	    fclose(wfile);
	    print("===========================================");
	}
	return 1;
}
ConvertHandlingData()
//convert regular gta sa handling data to a format usable as an array in script.
{
	new
		File:F1=fopen("handling.cfg", io_read),
		File:F2=fopen("handlingoutput.txt", io_write),
		line[400],
		str[400],
		fstr[120]={"{%s,%f,%f,%f,%f,%f,%f,%d,%f,%f,%f,%f,%d,%f,%f,%f,%d,%s,%f,%f,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%d,%d,%d,%d,%d,%d},\n"},
		s[2][14],
		f[25],
		d[10];
	while(fread(F1, line))
	{
	    sscanf(line, "s[14]ffffffdffffdfffds[1]ffdffffffffffdddddd",
	    s[0],f[0],f[1],f[2],f[3],f[4],f[5],d[0],f[6],f[7],f[8],f[9],d[1],
	    f[10],f[11],f[12],d[2],s[1],f[13],f[14],d[3],f[15],f[16],f[17],
		f[18],f[19],f[20],f[21],f[22],f[23],f[24],d[4],d[5],d[6],d[7],d[8],d[9]);
		format(str, 400, fstr,
	    s[0],f[0],f[1],f[2],f[3],f[4],f[5],d[0],f[6],f[7],f[8],f[9],d[1],
	    f[10],f[11],f[12],d[2],s[1],f[13],f[14],d[3],f[15],f[16],f[17],
		f[18],f[19],f[20],f[21],f[22],f[23],f[24],d[4],d[5],d[6],d[7],d[8],d[9]);
		fwrite(F2, str);
	}
/*
	enum enumdata
	{
				s_id[14],		//A
		Float:	f_mass,			//B
		Float:	f_tmass,		//C
		Float:	f_dragmult,		//D
		Float:	f_na,			//E
		Float:	f_comx,			//F
		Float:	f_comy,			//G
				d_comz,			//H
		Float:	f_psub,			//I
		Float:	f_tracmul,		//J
		Float:	f_traclos,		//K
		Float:	f_tracbias,		//L
				d_numgear,		//M
		Float:	f_maxvel,		//N
		Float:	f_accel,		//O
		Float:	f_inert,		//P
				d_drivtype,		//Q
				s_engtype[1],	//R
		Float:	f_brkdecel,		//S
		Float:	f_brkbias,		//T
				d_abs,			//U
		Float:	f_strlock,		//V
		Float:	f_susfrc,		//a
		Float:	f_susdmp,		//b
		Float:	f_sushscd,		//c
		Float:	f_susulim,		//d
		Float:	f_susllim,		//e
		Float:	f_susbias,		//f
		Float:	f_antdrvm,		//g
		Float:	f_stoffst,		//aa
		Float:	f_colmult,		//ab
				d_monval,       //ac
				d_modflag,		//af
				d_hanflag,		//ag
				d_flts,			//ah
				d_rlts,			//ai
				d_animgrp		//aj
	}
*/
}

#define TESTS 10
new tickCheck,tickCheckIncrement,tickCheckAssign[TESTS];
SpeedTest()
{
	new tickCheckTotal, Float:tickCheckAve;

	new tick=GetTickCount();
	for(new i;i<TESTS;i++)
	{
	    OnPlayerCommandText(0, "/testcommandation");
	}
	for(new c;c<TESTS;c++)tickCheckTotal+=tickCheckAssign[c];
	tickCheckAve=floatdiv(tickCheckTotal, TESTS);
	printf("final count: %d",GetTickCount()-tick);
	printf("total: %d", tickCheckTotal);
	printf("avearge: %f", tickCheckAve);
	printf("predicted: %d", floatround(floatmul(tickCheckAve, TESTS)));

//--globals: new tickCheck,tickCheckIncrement,tickCheckAssign[100];
/*
--put in function to test

    tickCheck=GetTickCount();
	tickCheckAssign[tickCheckIncrement]=(GetTickCount()-tickCheck);
	tickCheckIncrement++;

--for the average speed etc
*/



}



// failed filesystem

stock split(const strsrc[], strdest[][], delimiter)
{
    new i, li;
    new aNum;
    new len;
    while(i <= strlen(strsrc))
    {
        if(strsrc[i]==delimiter || i==strlen(strsrc))
        {
            len = strmid(strdest[aNum], strsrc, li, i, 128);
            strdest[aNum][len] = 0;
            li = i+1;
            aNum++;
        }
        i++;
    }
    return 1;
}

stock aquirePlayerData()
{
	print("::File Data Aquisition Initiated::");
	new
		File:F=fopen(jFile),
		File:nF=fopen("database.txt"),
		line[40],
		str[40],
		dlim[2][128],
		save[11][70],
		saveline[260],
		times;
	while(fread(F, line))
	{
	    split(line, dlim, '=');
	    format(str, 40, "Player/%s.txt", dlim[0]);
		if(fexist(str))
		{
//		    printf("--Currently Reading File: %s--", str);
			new
				File:pF=fopen(str),
		    	pline[110],
				data[2][70];
		    while(fread(pF, pline))
		    {
				split(pline, data, '=');
				if(!strcmp(data[0], "password"))	format(save[1], 70, "%s", base64_encode(data[1]));
				if(!strcmp(data[0], "ip"))			save[2]=data[1];
				if(!strcmp(data[0], "admin"))		save[4]=data[1];
				if(!strcmp(data[0], "cash"))		save[5]=data[1];
				if(!strcmp(data[0], "colour"))		save[6]=data[1];
				if(!strcmp(data[0], "kills"))		save[7]=data[1];
				if(!strcmp(data[0], "deaths"))		save[8]=data[1];
				if(!strcmp(data[0], "xp"))			save[9]=data[1];
				if(!strcmp(data[0], "rank"))		save[10]=data[1];
			}
			for(new c;c<sizeof(save);c++)if(c!=0&&c!=3)strdel(save[c], strlen(save[c])-2, strlen(save[c]));
			format(save[0], 70, "%s", dlim[0]);
			save[3]=randEmail(dlim[0]);
			format(saveline, 260, "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\r\n", save[0], save[1], save[2], save[3], save[4], save[5], save[6], save[7], save[8], save[9], save[10]);
//			print(saveline);
			fwrite(nF, saveline);
		}
	    if(times==50)break;
		times++;
	}
	fclose(F);
	fclose(nF);
	print("::File Data Aquisition Completed::");
}
stock randEmail(name[])
{
	new str[70], email[40], n[128],
	r_addons[9][3]=
	{
	    "_",
	    ".",
	    "-",
	    "..",
	    "~",
	    "!",
	    "$",
	    "^^",
	    "*"
	},
	r_nums[16][10]=
	{
	    "001",
	    "2004",
	    "1995",
	    "jj",
	    "pwned",
	    "lol",
	    "rofl",
	    "the.man",
	    "ojs",
	    "nhs",
	    "ooo",
	    "037",
	    "1994",
	    "1970",
	    "736",
	    "666"
	},
	r_domain[16][17]=
	{
	    "gmail.com",
	    "googlemail.co.uk",
	    "hotmail.com",
	    "hotmail.co.uk",
	    "live.com",
	    "live.co.uk",
	    "live.au",
	    "live.ru",
	    "live.fr",
	    "live.es",
	    "ymail.com",
	    "yahoomail.com",
	    "mail.com",
	    "aolmail.com",
	    "talktalk.com",
	    "tiscali.com"
	};
	n=strtolower(name);
	new start=strfind(n, "["), end=strfind(n, "]");
	if(start!=-1&&end!=-1)strdel(n, start, end+1);
	format(email, 40, "%s%s%s%d", n, r_addons[random(9)], r_nums[random(16)], random(9));
	format(str, 70, "%s@%s", email, r_domain[random(16)]);
	return str;
}
stock convertPlayerData()
{
	print("::File Data Conversion Initiated::");
	new
		File:F=fopen("database.txt"),
		File:nF=fopen("database information.txt"),
		line[110],
		str[256],
		save[11][70];
	while(fread(F, line))
	{
	    sscanf(line, "p<,>s[70]s[70]s[70]s[70]s[70]s[70]s[70]s[70]s[70]s[70]s[70]", save[0], save[1], save[2], save[3], save[4], save[5], save[6], save[7], save[8], save[9], save[10]);
	    format(str, 256, "name: %s, password: %s, IP: %s, email: %s, admin: %s, cash: %s, colour: %s, kills: %s, deaths: %s, xp: %s, rank: %s\n\n\r", save[0], save[1], save[2], save[3], save[4], save[5], save[6], save[7], save[8], save[9], save[10]);
	    print(str);
	    fwrite(nF, str);
	}
	fclose(F);
	fclose(nF);
	print("::File Data Conversion Completed::");
	return 1;
}

