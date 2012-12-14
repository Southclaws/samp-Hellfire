#include <a_samp>
#include <sscanf2>

#define INPUT_FILE	"MAPORIGINAL.txt"
#define OUTPUT_FILE	"MAPNEW.txt"


public OnFilterScriptInit()
{
	new
		File:file1 = fopen(INPUT_FILE, io_read),
		File:file2 = fopen(OUTPUT_FILE, io_write);

	new
		str[256];

	new
		model,
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz;


	while(fread(file1, str))
	{

		sscanf(str, "p<(>{s[20]} p<,>dfffffp<)>f {s[4]}", model, x, y, z, rx, ry, rz);
		
		format(str, 256, "CreateObject(%d, %f, %f, %f, %f, %f, %f);\r\n",
			model, x+(-2310.572), y+(-1640.4411), z+(491.6885), rx, ry, rz);

		fwrite(file2, str);

	}

	fclose(file1);
	fclose(file2);

}


