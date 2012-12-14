#include <a_samp>


public OnFilterScriptInit()
{
	print("Object Test script loaded!");
	return 1;
}

new obj[6];


public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/removeland"))
	{
		RemoveLand(playerid);
		return 1;
	}
	if(!strcmp(cmdtext, "/recreate"))
	{
		ReCreateLand();
		return 1;
	}
	if(!strcmp(cmdtext, "/retex"))
	{
		ReTexture();
		return 1;
	}
	

	return 0;
}
RemoveLand(playerid)
{
    RemoveBuildingForPlayer(playerid, 11598, -648.7656, 1299.3906, -2.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 11638, -779.9063, 1535.1719, 28.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 11639, -651.1406, 1526.7891, 35.1953, 0.25);
	RemoveBuildingForPlayer(playerid, 11655, -981.3203, 1473.0625, 29.6563, 0.25);
	RemoveBuildingForPlayer(playerid, 11658, -974.4766, 1596.5000, 3.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 11659, -806.5078, 1310.5313, 7.2188, 0.25);
	RemoveBuildingForPlayer(playerid, 11555, -981.3203, 1473.0625, 29.6563, 0.25);
	RemoveBuildingForPlayer(playerid, 11554, -974.4766, 1596.5000, 3.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 11535, -806.5078, 1310.5313, 7.2188, 0.25);
	RemoveBuildingForPlayer(playerid, 11532, -779.9063, 1535.1719, 28.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 11559, -648.7656, 1299.3906, -2.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 11533, -651.1406, 1526.7891, 35.1953, 0.25);

}
ReCreateLand()
{
	obj[0] = CreateObject(11559, -648.77, 1299.39, -2.95, 0.0, 0.0, 0.0);
	obj[1] = CreateObject(11535, -806.51, 1310.53, 7.22, 0.0, 0.0, 0.0);
	obj[2] = CreateObject(11533, -651.14, 1526.79, 35.20, 0.0, 0.0, 0.0);
	obj[3] = CreateObject(11532, -779.91, 1535.17, 28.40, 0.0, 0.0, 0.0);
	obj[4] = CreateObject(11554, -974.48, 1596.50, 3.90, 0.0, 0.0, 0.0);
	obj[5] = CreateObject(11555, -981.32, 1473.06, 29.66, 0.0, 0.0, 0.0);
}
ReTexture()
{

	SetObjectMaterial(obj[0], 1, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[0], 3, 11559, "des_sw", "desgrassbrn");

	SetObjectMaterial(obj[1], 1, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[1], 4, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[1], 5, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[1], 7, 11559, "des_sw", "desgrassbrn");

	SetObjectMaterial(obj[2], 0, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[2], 1, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[2], 3, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[2], 4, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[2], 5, 11559, "des_sw", "desgrassbrn");

	SetObjectMaterial(obj[3], 0, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[3], 1, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[3], 3, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[3], 4, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[3], 11, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[3], 12, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[3], 13, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[3], 14, 11559, "des_sw", "desgrassbrn");

	SetObjectMaterial(obj[4], 1, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[4], 2, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[4], 5, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[4], 7, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[4], 8, 11559, "des_sw", "desgrassbrn");

	SetObjectMaterial(obj[5], 0, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[5], 1, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[5], 2, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[5], 3, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[5], 4, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[5], 5, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[5], 6, 11559, "des_sw", "desgrassbrn");
	SetObjectMaterial(obj[5], 9, 11559, "des_sw", "desgrassbrn");

}













