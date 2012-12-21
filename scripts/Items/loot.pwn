#define ADD_LOOT(%0); LootTable[loot_index++] = %0;


new
	ItemType:LootTable[34],
	loot_index;


public OnLoad()
{
	print("LOADING LOOT");

	ADD_LOOT(item_Medkit);
	ADD_LOOT(item_FireworkBox);
	ADD_LOOT(item_FireLighter);
	ADD_LOOT(item_timer);
	ADD_LOOT(item_explosive);
	ADD_LOOT(item_battery);
	ADD_LOOT(item_fusebox);
	ADD_LOOT(item_Beer);
	ADD_LOOT(item_Sign);
	ADD_LOOT(item_HealthRegen);
	ADD_LOOT(item_ArmourRegen);
	ADD_LOOT(item_FishRod);
	ADD_LOOT(item_Wrench);
	ADD_LOOT(item_Crowbar);
	ADD_LOOT(item_Hammer);
	ADD_LOOT(item_Shield);
	ADD_LOOT(item_Flashlight);
	ADD_LOOT(item_Taser);
	ADD_LOOT(item_LaserPoint);
	ADD_LOOT(item_Screwdriver);
	ADD_LOOT(item_MobilePhone);
	ADD_LOOT(item_Pager);
	ADD_LOOT(item_Rake);
	ADD_LOOT(item_HotDog);
	ADD_LOOT(item_EasterEgg1);
	ADD_LOOT(item_EasterEgg2);
	ADD_LOOT(item_EasterEgg3);
	ADD_LOOT(item_EasterEgg4);
	ADD_LOOT(item_EasterEgg5);
	ADD_LOOT(item_Cane);
	ADD_LOOT(item_HandCuffs);
	ADD_LOOT(item_Bucket);
	ADD_LOOT(item_GasMask);

	return CallLocalFunction("misc_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad misc_OnLoad
forward misc_OnLoad();


ItemType:GenerateLoot()
{
	new
		index = random(loot_index),
		ItemType:id;

	id = LootTable[index];

	if(!IsValidItemType(id))
		printf("INVALID ITEM IN LOOT TABLE! INDEX: %d ID: %d", index, _:id);

	new name[32];
	GetItemTypeName(id, name);

	return id;
}
