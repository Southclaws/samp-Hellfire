#include <a_samp>
#include <sscanf2>
#include <streamer>

#define MAX_HOUSE (153)

new
    gLS,
    gSF,
    gLV,
    gModel,
    Float:gX,
    Float:gY,
    Float:gZ,
    Float:gF[7];

enum E_DATA
{
	model,
	Float:posX,
	Float:posY,
	Float:posZ,
	Float:rotX,
	Float:rotY,
	Float:rotZ
}

new
	data[MAX_HOUSE][E_DATA],
	total;

public OnFilterScriptInit()
{
    new
        line[64],
        File:file;
    file = fopen("DATA\\index.ini", io_read);
    if (file)
    {
        while (fread(file, line))
        {
            format(line, 64, "%.*s", strlen(line) - 2, line);
            LoadFile(line);
        }
        fclose(file);
        printf("Houses replaced in LS: %d", gLS);
        printf("Houses replaced in SF: %d", gSF);
        printf("Houses replaced in LV: %d", gLV);
        printf("Total houses replaced: %d", gLS + gSF + gLV);
    }
    // Millie's house
    //save(19503, 2036.8125, 2719.3984, 12.6875, 0.0000, 0.0000, 180.0000, .streamdistance = 300.0);
    //save(19504, 2036.8125, 2719.3984, 12.6875, 0.0000, 0.0000, 180.0000, .streamdistance = 300.0);
}

public OnPlayerConnect(playerid)
{
    // Los Santos
    // LOD 3592 (0.3e object: 19509 + 19510)
    RemoveBuildingForPlayer(playerid, 3589, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3592, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    // LOD 3647 (0.3e object: 19507 + 19508)
    RemoveBuildingForPlayer(playerid, 3648, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3647, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    // LOD 3706 (0.3e object: 19505 + 19506)
    RemoveBuildingForPlayer(playerid, 3646, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3706, 0.0, 0.0, 0.0, 10000.0); // LS house LOD
    // LOD 3720 (0.3e object: 19511 + 19512)
    RemoveBuildingForPlayer(playerid, 3642, 0.0, 0.0, 0.0, 10000.0); // LS house
    RemoveBuildingForPlayer(playerid, 3720, 0.0, 0.0, 0.0, 10000.0); // LS house LOD

    // San Fierro
    // LOD 3832 (0.3e object: 19491 + 19492)
    RemoveBuildingForPlayer(playerid, 3821, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3832, 0.0, 0.0, 0.0, 10000.0); // SF house LOD
    // LOD 3835 (0.3e object: 19489 + 19490)
    RemoveBuildingForPlayer(playerid, 3824, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3835, 0.0, 0.0, 0.0, 10000.0); // SF house LOD
    // LOD 3838 (0.3e object: 19495 + 19496)
    RemoveBuildingForPlayer(playerid, 3827, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3838, 0.0, 0.0, 0.0, 10000.0); // SF house LOD
    // LOD 3841 (0.3e object: 19493 + 19494)
    RemoveBuildingForPlayer(playerid, 3825, 0.0, 0.0, 0.0, 10000.0); // SF house
    RemoveBuildingForPlayer(playerid, 3841, 0.0, 0.0, 0.0, 10000.0); // SF house LOD

    // Las Venturas
    // LOD 3536 (0.3e object: 19497 + 19498)
    RemoveBuildingForPlayer(playerid, 3464, 0.0, 0.0, 0.0, 10000.0); // LV house
    RemoveBuildingForPlayer(playerid, 3536, 0.0, 0.0, 0.0, 10000.0); // LV house LOD
    // LOD 3546 (0.3e object: 19501 + 19502)
    RemoveBuildingForPlayer(playerid, 3445, 0.0, 0.0, 0.0, 10000.0); // LV house
    RemoveBuildingForPlayer(playerid, 3546, 0.0, 0.0, 0.0, 10000.0); // LV house LOD
    // LOD 3547 (0.3e object: 19499 + 19500)
    RemoveBuildingForPlayer(playerid, 3446, 0.0, 0.0, 0.0, 10000.0); // LV house
    RemoveBuildingForPlayer(playerid, 3547, 0.0, 0.0, 0.0, 10000.0); // LV house LOD
    // LOD 3548 (0.3e object: 19503 + 19503)
    RemoveBuildingForPlayer(playerid, 3443, 0.0, 0.0, 0.0, 10000.0); // LV house
    RemoveBuildingForPlayer(playerid, 3548, 0.0, 0.0, 0.0, 10000.0); // LV house LOD
    // Millie's house
    //RemoveBuildingForPlayer(playerid, 7940, 0.0, 0.0, 0.0, 10000.0); // LV house
    //RemoveBuildingForPlayer(playerid, 7941, 0.0, 0.0, 0.0, 10000.0); // LV house LOD
    return 1;
}

LoadFile(const path[])
{
    new
        line[128],
        File:file;
    file = fopen(path, io_read);

	while (fread(file, line))
	{
		if (sscanf(line, "p<,>i{s[32]i}a<f>[7]{i}", gModel, gF))
		{
			continue;
		}
		CreateHouse();
	}
	fclose(file);
}

CreateHouse()
{
    // Los Santos
    if (gModel == 3592 || gModel == 3647 || gModel == 3706 || gModel == 3720)
    {
        QuatToEulerZXY(gF[3], gF[4], gF[5], gF[6], gX, gY, gZ);
		printf("%f, %f, %f,  %f, %f, %f", gF[0], gF[1], gF[2], gX, gY, gZ);
        switch (gModel)
        {
            case 3592:
            {
                save(19509, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19510, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
            case 3647:
            {
                save(19507, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19508, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
            case 3706:
            {
                save(19505, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19506, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
            case 3720:
            {
                save(19511, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19512, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
        }
        ++gLS;
        return;
    }
    // San Fierro
    if (gModel == 3832 || gModel == 3835 || gModel == 3838 || gModel == 3841)
    {
        QuatToEulerZXY(gF[3], gF[4], gF[5], gF[6], gX, gY, gZ);
		printf("%f, %f, %f,  %f, %f, %f", gF[0], gF[1], gF[2], gX, gY, gZ);
        switch (gModel)
        {
            case 3832:
            {
                save(19491, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19492, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
            case 3835:
            {
                save(19489, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19490, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
            case 3838:
            {
                save(19495, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19496, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
            case 3841:
            {
                save(19493, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19494, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
        }
        ++gSF;
        return;
    }
    // Las Venturas
    if (gModel == 3536 || gModel == 3546 || gModel == 3547 || gModel == 3548)
    {
        QuatToEulerZXY(gF[3], gF[4], gF[5], gF[6], gX, gY, gZ);
		printf("%f, %f, %f,  %f, %f, %f", gF[0], gF[1], gF[2], gX, gY, gZ);
        switch (gModel)
        {
            case 3536:
            {
                save(19497, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19498, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
            case 3546:
            {
                save(19501, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19502, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
            case 3547:
            {
                save(19499, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19500, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
            case 3548:
            {
                save(19503, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
                save(19504, gF[0], gF[1], gF[2], gX, gY, gZ, .streamdistance = 300.0);
            }
        }
        ++gLV;
        return;
    }
    return;
}

save(m, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:streamdistance)
{

	data[total][model] = m;
	data[total][posX] = x;
	data[total][posY] = y;
	data[total][posZ] = z;
	data[total][rotX] = rx;
	data[total][rotY] = ry;
	data[total][rotZ] = rz;
    total++;

	printf("%d,  %f,%f,%f,  %f,%f,%f,  %f", m, x, y, z, rx, ry, rz, streamdistance);
}

QuatToEulerZXY(Float:quat_x, Float:quat_y, Float:quat_z, Float:quat_w, &Float:x, &Float:y, &Float:z)
{
    x = -asin(2 * ((quat_x * quat_z) + (quat_w * quat_y)));
    y = atan2(2 * ((quat_y * quat_z) + (quat_w * quat_x)), (quat_w * quat_w) - (quat_x * quat_x) - (quat_y * quat_y) + (quat_z * quat_z));
    z = -atan2(2 * ((quat_x * quat_y) + (quat_w * quat_z)), (quat_w * quat_w) + (quat_x * quat_x) - (quat_y * quat_y) - (quat_z * quat_z));
    return 1;
}
