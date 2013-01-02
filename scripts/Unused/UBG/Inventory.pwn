#define MAX_INVENTORY   50
enum InvENUM
{
	Item[MAX_INVENTORY],
	Amount[MAX_INVENTORY]
}

new Inventory[MAX_PLAYERS][InvENUM];

InventoryItem(playerid, item, quantity)
{
	new slot;
	while((slot<MAX_INVENTORY)&&(Inventory[playerid][Item][slot]!=-1&&Inventory[playerid][Item][slot]!=item))slot++;
	if(slot==MAX_INVENTORY-1)return false;

	if(Inventory[playerid][Amount][slot]+quantity<1)InventoryItem_Remove(playerid, slot);
	else
	{
		Inventory[playerid][Item][slot]=item;
		Inventory[playerid][Amount][slot]+=quantity;
	}
	return true;
}

InventoryItem_Remove(playerid, slot)
{
	new itemTmp, amountTmp;
	Inventory[playerid][Item][slot]=-1;
	Inventory[playerid][Amount][slot]=-1;
	for(new i=slot;i<MAX_INVENTORY-1;i++)
	{
	    itemTmp=Inventory[playerid][Item][i+1];
	    amountTmp=Inventory[playerid][Amount][i+1];
	    Inventory[playerid][Item][i]=itemTmp;
	    Inventory[playerid][Amount][i]=amountTmp;
	}
}

InventoryOpen(playerid)
{
	new itemList[300], tmpLine[64], slot;
    while(slot<MAX_INVENTORY && Inventory[playerid][Item][slot]!=-1)
	{
		format(tmpLine, 64, "%d-%s\n", Inventory[playerid][Amount][slot], ItemData[ Inventory[playerid][Item][slot] ][itemName]);
		strcat(itemList, tmpLine);
		slot++;
	}

	ShowPlayerDialog(playerid, d_Inventory, DIALOG_STYLE_LIST, "Inventory", itemList, "Close", "");
}


