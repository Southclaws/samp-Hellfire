#include <a_samp>
#include <streamer>
#include <sscanf2>
#include <zcmd>

public OnFilterScriptInit()
{
	new
		File:f = fopen("BulkSavedPositions.txt"),
		line[128],
		Float:x,
		Float:y,
		Float:z,
		count;

	while(fread(f, line))
	{
		if(!sscanf(line, "p<,>fff{F(0)}", x, y, z))
		{
			CreateDynamicMapIconEx(x, y, z, 0, 0xFFCC11FF, MAPICON_GLOBAL, 10000.0);
			count++;
		}
	}
	fclose(f);
	
	printf("loaded %d icons", count);

	return 1;
}

