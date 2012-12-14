#include <a_samp>
#include <sscanf2>
#include <IniFiles>

#define DMIndexFile     	"Deathmatch/index.ini"

main()
{
	file_OS();
	new
		MapFile[64],
		MapDump[64],
		File:idxFile=fopen(DMIndexFile, io_read),
		tmpMapName[32],
		tmpDump[2],
		idx,
		line[30];

	while(fread(idxFile, line))
	{
		if(sscanf(line, "p<,>s[20]bd", tmpMapName, tmpDump[0], tmpDump[1]))print("Error: Deathmatch File Index");
		
		printf("Converting Map: '%s'", tmpMapName);
		
		format(MapFile, 64, "Raw/%d-%s.map", idx, tmpMapName);
		format(MapDump, 64, "Converted/%d-%s.pwn", idx, tmpMapName);
		printf("file: '%s' dump: '%s'", MapFile, MapDump);

    	MapConvertForEditor(MapFile, MapDump);

		idx++;
	}
	fclose(idxFile);
}

MapConvertForEditor(input[], output[])
//converts the standard deathmatch map files for use in the editor
{
	new
		File:F1=fopen(input, io_read),
		File:F2=fopen(output, io_write),
		str1[256],
		str2[256],

		model,
		Float:pos[3],
		Float:rot[3];
	while(fread(F1, str1))
	{
	    strdel(str1, (strlen(str1)-3), strlen(str1));
	    sscanf(str1, "p<,>dffffff", model, pos[0], pos[1], pos[2], rot[0], rot[1], rot[2]);
	    pos[2]+=1000.0;
	    format(str2, 256, "CreateObject(%d, %f, %f, %f, %f, %f, %f);\r\n", model, pos[0], pos[1], pos[2], rot[0], rot[1], rot[2]);
	    fwrite(F2, str2);
	}
	fclose(F1);
	fclose(F2);
}


