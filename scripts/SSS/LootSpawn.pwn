CreateLootSpawn(Float:x, Float:y, Float:z, amount, spawnchance, low, med, high)
{
	new ItemType:itemtype;

	for(new l; l < amount; l++)
	{
		if(random(100) > spawnchance)
			continue;

		new
			loottype,
			ItemType:tmpitem,
			itemid;

		if(random(100) < low)
			loottype = LOOT_TYPE_LOW;

		else if(random(100) < med)
			loottype = LOOT_TYPE_MEDIUM;

		else if(random(100) < high)
			loottype = LOOT_TYPE_HIGH;

		tmpitem = GenerateLoot(loottype);

		if(tmpitem == itemtype)
			continue;

		itemtype = tmpitem;

		itemid = CreateItem(tmpitem, x + floatsin((360/amount) * l, degrees), y + floatcos((360/amount) * l, degrees), z, .zoffset = 0.7);

		if(0 < _:itemtype <= WEAPON_PARACHUTE)
			SetItemExtraData(itemid, (WepData[_:itemtype][MagSize] * (random(3))) + random(WepData[_:itemtype][MagSize]));

		if(itemtype == item_Satchel || itemtype == item_Backpack)
		{
			if(random(100) < low)
				loottype = LOOT_TYPE_LOW;

			else if(random(100) < med)
				loottype = LOOT_TYPE_MEDIUM;

			else if(random(100) < high)
				loottype = LOOT_TYPE_HIGH;

			tmpitem = GenerateLoot(loottype);

			itemid = CreateItem(tmpitem, 0.0, 0.0, 0.0);

			AddItemToContainer(GetItemExtraData(itemid), itemid);
		}
	}
}