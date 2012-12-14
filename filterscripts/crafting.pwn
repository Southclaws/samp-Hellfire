#include <a_samp>
#define DIALOG_WEAPON_CRAFT 13337
new Entrance_CraftShop;
new MetalScrap_Pickups[4];
new bool:Craft_MetalParts[MAX_PLAYERS];

public OnFilterScriptInit()
{
        print("\n--------------------------------------\nSimple Weapon Crafting by Patrik356b\n--------------------------------------\n");
        Entrance_CraftShop=CreatePickup(1277, 19, -181.3102,1163.0958,19.750, -1);
        MetalScrap_Pickups[0] = CreatePickup(2960, 19, -331.7113, 824.4234, 14.7362, -1);
        MetalScrap_Pickups[1] = CreatePickup(2960, 19, -318.8606, 813.8593, 14.9397, -1);
        MetalScrap_Pickups[2] = CreatePickup(2960, 19, -331.6526, 840.9549, 15.1418, -1);
        MetalScrap_Pickups[3] = CreatePickup(2960, 19, -318.0849, 799.0787, 15.6554, -1);
        return 1;
}

public OnFilterScriptExit()
{
        DestroyPickup(Entrance_CraftShop);
        for(new i=0; i < sizeof(MetalScrap_Pickups); i++)
        {
                DestroyPickup(MetalScrap_Pickups[i]);
        }
        print("\t<<\t\t>>\n\tFS: Simple Weapon Crafting\nUnloaded!");
        return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
        if(pickupid == Entrance_CraftShop)
        {   // Enter the craft shop in Fort Carson
                ShowPlayerDialog(playerid, DIALOG_WEAPON_CRAFT, DIALOG_STYLE_LIST, "Weapon Crafting", "Brass Knuckels\nGolf Club\nNite Stick\nCane", "Select", "Cancel");
        }else{
                for(new i=0; i < sizeof(MetalScrap_Pickups); i++)
                {
                        if(pickupid == MetalScrap_Pickups[i])
                        {
                                if(Craft_MetalParts[playerid] == false)
                                {
                                        Craft_MetalParts[playerid]=true;
                                        SendClientMessage(playerid, 0xFFFF00FF, "You have picked up one peice of scrap metal!.");
                                }else{
                                        SendClientMessage(playerid, 0xFFFF00FF, "You can only carry one peice of scrap metal!.");
                                        return 1;
                                }
                        }
                }
        }
        return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
        if(dialogid == DIALOG_WEAPON_CRAFT)
        {
                if(!response)
                {
                        SendClientMessage(playerid, 0xFFFF00FF, "Weapon crafting aborted!.");
                        return 1;
                }
                if(Craft_MetalParts[playerid] == false)
                {
                        SendClientMessage(playerid, 0xFFFF00FF, "You don't have any materials to work with!.");
                        return 1;
                }
                switch(listitem) // If they clicked 'Select' or double-clicked a weapon
                {
                        // Give them the weapon
                        case 0: GivePlayerWeapon(playerid, 1, 1); // Brass Knuckels
                        case 1: GivePlayerWeapon(playerid, 2, 1); // Golf Club
                        case 2: GivePlayerWeapon(playerid, 3, 1); // Nite stick
                        case 3: GivePlayerWeapon(playerid, 15, 1); // Cane
                }
                return 1;
        }
        return 0;
}

