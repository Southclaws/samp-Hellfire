new CarShopCars[24][2]=
{
	{602, 6000},
	{429, 6500},
	{496, 4000},
	{402, 5800},
	{541, 6800},
	{415, 6000},
	{589, 4500},
	{587, 5200},
	{565, 4500},
	{411, 7000},
	{559, 6800},
	{603, 4800},
	{475, 4500},
	{506, 6000},
	{451, 6000},
	{558, 4000},
	{477, 5800},
	{581, 2500},
	{522, 3200},
	{461, 2500},
	{521, 2500},
	{463, 3000},
	{468, 3000},
	{471, 4000}
},
DisplayCar[MAX_PLAYERS],
SelectedCar[MAX_PLAYERS];

stock script_Buyable_Pickup(playerid, pickupid)
{
	if(pickupid == CarShop)
	{
	    ShowCarShopMenu(playerid);
	}
}
stock ShowCarShopMenu(playerid, car=0)
{
	new str[300];
	str="Exit Car Shop";
	for(new x;x<(sizeof(CarShopCars));x++)format(str, 300, "%s\n$%d\t%s", str, CarShopCars[x][1], VehicleNames[CarShopCars[x][0]-400]);
	ShowPlayerDialog(playerid, d_CarBuy, DIALOG_STYLE_LIST, "Choose a car to buy", str, "Veiw", "Buy");

	DisplayCar[playerid]=CreateVehicle(CarShopCars[car][0], -1655.544433, 1208.156127, 21.0, 242.591857, -1, -1, 1000);
	SetVehicleVirtualWorld(DisplayCar[playerid], 4);
	SetPlayerVirtualWorld(playerid, 4);
	SetPlayerCameraPos(playerid, -1649.428955, 1213.219970, 23.0);
	SetPlayerCameraLookAt(playerid, -1655.544433, 1208.156127, 21.0);
	SetPlayerPos(playerid, -1649.428955, 1213.219970, 21.0);
}
stock script_Buyable_DialogResponse(playerid, dialogid, response, listitem)
{
	if(dialogid == d_CarBuy)
	{
	    if(listitem==0)
	    {
			DestroyVehicle(DisplayCar[playerid]);
			SetPlayerVirtualWorld(playerid, 0);
			SetCameraBehindPlayer(playerid);
	    }
	    if(response)
	    {
			DestroyVehicle(DisplayCar[playerid]);
			ShowCarShopMenu(playerid, listitem-1);
	    }
	    else
		{
		    if(GetPlayerMoney(playerid) < CarShopCars[listitem-1][1])
		    {
		        ShowCarShopMenu(playerid);
		        Msg(playerid, RED, "You don't have enough money");
		    }
		    else
		    {
		    	new str[100];
		    	format(str, 100, "Click Buy to buy this car worth $%d or click Back to choose another\n{FF0101}Warning: Buying a new car will erase any previously saved car at your house", CarShopCars[listitem-1][1]);
				ShowPlayerDialog(playerid, d_CarBuyConfirm, DIALOG_STYLE_MSGBOX, "Are you sure you want to buy this car?", str, "Back", "Buy");
				SelectedCar[playerid]=listitem-1;
			}
		}
	}
	if(dialogid == d_CarBuyConfirm)
	{
	    if(!response)
		{
			for(new h; h<MaxHouses; h++)
			{
				if(!strcmp(HouseInfo[h][HouseOwner], playerid))
				{
					DestroyVehicle(DisplayCar[playerid]);
					CreateVehicle(SelectedCar[playerid], -1655.544433, 1208.156127, 21.0, 242.591857, -1, -1, 10000);
					SelectedCar[playerid]=-1;
					GivePlayerMoney(playerid, -CarShopCars[SelectedCar[playerid]][1]);
					break;
				}
				else
				{
					DestroyVehicle(DisplayCar[playerid]);
					SetPlayerVirtualWorld(playerid, 0);
					SetCameraBehindPlayer(playerid);
					Msg(playerid, RED, "You do not own a house, you need to buy a house to save your car at");
					break;
				}
			}
		}
		else ShowCarShopMenu(playerid);
	}
	return 1;
}
