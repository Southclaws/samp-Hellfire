new ItemType:item_HandCuffs = INVALID_ITEM_TYPE;

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_HandCuffs)
	{
		foreach(new i : Character)
		{
			if(i == playerid)
				continue;

			new
				Float:px,
				Float:py,
				Float:pz,
				Float:tx,
				Float:ty,
				Float:tz;

			GetPlayerPos(playerid, px, py, pz);
			GetPlayerPos(i, tx, ty, tz);

			if(Distance(px, py, pz, tx, ty, tz) < 2.0)
			{
				if(GetPlayerItem(i) == INVALID_ITEM_ID && GetPlayerWeapon(i) == 0)
				{
					ApplyAnimation(playerid, "CASINO", "DEALONE", 4.0, 1, 0, 0, 0, 0); // cuff
					defer ApplyHandcuffs(playerid, i, itemid);
					return 1;
				}
			}
		}
	}
	return CallLocalFunction("cuff_OnPlayerUseItem", "dd", playerid, itemid);
}
#if defined _ALS_OnPlayerUseItem
	#undef OnPlayerUseItem
#else
	#define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem cuff_OnPlayerUseItem
forward cuff_OnPlayerUseItem(playerid, itemid);


timer ApplyHandcuffs[1000](playerid, targetid, itemid)
{
	SetPlayerCuffs(targetid, true);
	DestroyItem(itemid);
	ClearAnimations(playerid);
}