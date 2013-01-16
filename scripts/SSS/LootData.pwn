#define ADD_LOOT(%0,%1);	LootTable[%0][loot_index[%0]++] = %1;

#define LOOT_TYPE_NONE		(-1)
#define LOOT_TYPE_LOW		(0)
#define LOOT_TYPE_MEDIUM	(1)
#define LOOT_TYPE_HIGH		(2)

new
	ItemType:LootTable[3][128],
	loot_index[3];


public OnLoad()
{
	// Items
	ADD_LOOT(LOOT_TYPE_LOW, item_FireworkBox);
	ADD_LOOT(LOOT_TYPE_LOW, item_FireLighter);
	ADD_LOOT(LOOT_TYPE_LOW, item_fusebox);
	ADD_LOOT(LOOT_TYPE_LOW, item_Beer);
	ADD_LOOT(LOOT_TYPE_LOW, item_Sign);
	ADD_LOOT(LOOT_TYPE_LOW, item_FishRod);
	ADD_LOOT(LOOT_TYPE_LOW, item_Wrench);
	ADD_LOOT(LOOT_TYPE_LOW, item_Crowbar);
	ADD_LOOT(LOOT_TYPE_LOW, item_Hammer);
	ADD_LOOT(LOOT_TYPE_LOW, item_Flashlight);
	ADD_LOOT(LOOT_TYPE_LOW, item_LaserPoint);
	ADD_LOOT(LOOT_TYPE_LOW, item_Screwdriver);
	ADD_LOOT(LOOT_TYPE_LOW, item_MobilePhone);
	ADD_LOOT(LOOT_TYPE_LOW, item_Pager);
	ADD_LOOT(LOOT_TYPE_LOW, item_Rake);
	ADD_LOOT(LOOT_TYPE_LOW, item_HotDog);
	ADD_LOOT(LOOT_TYPE_LOW, item_EasterEgg);
	ADD_LOOT(LOOT_TYPE_LOW, item_Cane);
	ADD_LOOT(LOOT_TYPE_LOW, item_Bucket);
	ADD_LOOT(LOOT_TYPE_LOW, item_Flag);
	ADD_LOOT(LOOT_TYPE_LOW, item_Satchel);

	ADD_LOOT(LOOT_TYPE_MEDIUM, item_Taser);
	ADD_LOOT(LOOT_TYPE_MEDIUM, item_GasMask);
	ADD_LOOT(LOOT_TYPE_MEDIUM, item_Medkit);
	ADD_LOOT(LOOT_TYPE_MEDIUM, item_timer);
	ADD_LOOT(LOOT_TYPE_MEDIUM, item_battery);
	ADD_LOOT(LOOT_TYPE_MEDIUM, item_HealthRegen);
	ADD_LOOT(LOOT_TYPE_MEDIUM, item_Wheel);
	ADD_LOOT(LOOT_TYPE_MEDIUM, item_Canister1);
	ADD_LOOT(LOOT_TYPE_MEDIUM, item_Canister2);
	ADD_LOOT(LOOT_TYPE_MEDIUM, item_Canister3);
	ADD_LOOT(LOOT_TYPE_MEDIUM, item_MotionSense);

	ADD_LOOT(LOOT_TYPE_HIGH, item_explosive);
	ADD_LOOT(LOOT_TYPE_HIGH, item_ArmourRegen);
	ADD_LOOT(LOOT_TYPE_HIGH, item_Shield);
	ADD_LOOT(LOOT_TYPE_HIGH, item_HandCuffs);
	ADD_LOOT(LOOT_TYPE_HIGH, item_Backpack);
	ADD_LOOT(LOOT_TYPE_HIGH, item_CapCase);
	ADD_LOOT(LOOT_TYPE_HIGH, item_CapMineBad);
	ADD_LOOT(LOOT_TYPE_HIGH, item_CapMine);


	// Weapons
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_KNUCKLES);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_GOLFCLUB);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_NITESTICK);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_KNIFE);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_BASEBALLBAT);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_SHOVEL);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_FLOWERS);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_CANE);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_SPRAYCAN);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_EXTINGUISHER);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_CAMERA);
	ADD_LOOT(LOOT_TYPE_LOW, ItemType:WEAPON_PARACHUTE);

	ADD_LOOT(LOOT_TYPE_MEDIUM, ItemType:WEAPON_KANTANA);
	ADD_LOOT(LOOT_TYPE_MEDIUM, ItemType:WEAPON_CHAINSAW);
	ADD_LOOT(LOOT_TYPE_MEDIUM, ItemType:WEAPON_COLT45);
	ADD_LOOT(LOOT_TYPE_MEDIUM, ItemType:WEAPON_COLT45SD);
	ADD_LOOT(LOOT_TYPE_MEDIUM, ItemType:WEAPON_DESERTEAGLE);
	ADD_LOOT(LOOT_TYPE_MEDIUM, ItemType:WEAPON_SHOTGUN);
	ADD_LOOT(LOOT_TYPE_MEDIUM, ItemType:WEAPON_SAWNOFF);
	ADD_LOOT(LOOT_TYPE_MEDIUM, ItemType:WEAPON_SPAS12);
	ADD_LOOT(LOOT_TYPE_MEDIUM, ItemType:WEAPON_MAC10);
	ADD_LOOT(LOOT_TYPE_MEDIUM, ItemType:WEAPON_TEC9);

	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_GRENADES);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_TEARGAS);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_MOLOTOV);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_MP5);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_AK47);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_M4);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_RIFLE);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_SNIPER);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_ROCKETLAUNCHER);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_HEATSEEKER);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_FLAMER);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_MINIGUN);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_SACHEL);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_NIGHTVISION);
	ADD_LOOT(LOOT_TYPE_HIGH, ItemType:WEAPON_THERMALVISION);

	printf("Loot Index LOW size: %d", loot_index[LOOT_TYPE_LOW]);
	printf("Loot Index MED size: %d", loot_index[LOOT_TYPE_MEDIUM]);
	printf("Loot Index HIG size: %d", loot_index[LOOT_TYPE_HIGH]);

	return CallLocalFunction("loot_OnLoad", "");
}
#if defined _ALS_OnLoad
    #undef OnLoad
#else
    #define _ALS_OnLoad
#endif
#define OnLoad loot_OnLoad
forward loot_OnLoad();


ItemType:GenerateLoot(type)
{
	if(!(0 <= type < 3))
		return INVALID_ITEM_TYPE;		

	new
		index = random(loot_index[type]),
		ItemType:id;

	id = LootTable[type][index];

	if(!IsValidItemType(id))
	{
		printf("ERROR: Invalid item type in loot table %d: cell: %d ID: %d", type, index, _:id);
		return INVALID_ITEM_TYPE;		
	}

	new name[32];
	GetItemTypeName(id, name);

	return id;
}
