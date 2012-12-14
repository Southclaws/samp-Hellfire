#include <a_samp>


#include "../scripts/resources/WeaponResources.pwn"

public OnFilterScriptInit()
{
	new
		File:wFile = fopen("wepdata.txt", io_write),
		str[128];
		
	for(new i = 22; i<39; i++)
	{
	    format(str, 128, "wepData[%d] = [ '%s',\t\t%f,\t%f,\t%f,\t%f,\t%f,\t%f];\r\n",
			i-22,
			WepData[i][WepName],
			WepData[i][MinDis],
			WepData[i][MaxDis],
			WepData[i][MinDam],
			WepData[i][MaxDam],
			WepData[i][FireRate],
			WepData[i][MaxRange]);

		fwrite(wFile, str);
	}
	fclose(wFile);
	return 1;
}

