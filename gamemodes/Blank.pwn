#include <a_samp>
#include <YSI\y_iterate>


main()
{

}

public OnGameModeInit()
{
	SetGameModeText("Blank Script");
	AddPlayerClass(0, 0.0, 0.0, 4.8, 90.0, 0, 0, 0, 0, 0, 0);
	return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

