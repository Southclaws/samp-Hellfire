#include <YSI\y_hooks>

new ItemType:item_Beer = INVALID_ITEM_TYPE;

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Beer)
	{
		ApplyAnimation(playerid, "BEER", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 0, 1);
		SetPlayerDrunkLevel(playerid, GetPlayerDrunkLevel(playerid) + 400);
	}
    return CallLocalFunction("ber_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem ber_OnPlayerUseItem
forward ber_OnPlayerUseItem(playerid, itemid);

