#define MAX_CONTAINER			10
#define MAX_CONTAINER_SIZE  	10

#define CONTAINER_TYPE_BOX  	0
#define CONTAINER_TYPE_BOOT     1

enum cnt_ENUM
{
	bUsed,
	dAssigned,
	cItem[MAX_CONTAINER_SIZE],
	cAmount[MAX_CONTAINER_SIZE],
	iType
}
new
	cnt_Data[MAX_CONTAINER][cnt_ENUM],
	pActiveContainer[MAX_PLAYERS]=-1;

CreateContainer(type_id, type=CONTAINER_TYPE_BOX)
{
	new i;
	while(cnt_Data[i][bUsed])i++;
	cnt_Data[i][iType]=type;
    cnt_Data[i][dAssigned]=type_id;
    cnt_Data[i][bUsed]=1;
    for(new x;x<MAX_CONTAINER_SIZE;x++)cnt_Data[i][cItem][x]=-1;
    return i;
}

GetPlayerContainer(playerid)
{
	new Float:x, Float:y, Float:z;
	for(new i;i<MAX_CONTAINER;i++)
	{
		GetDynamicObjectPos(cnt_Data[i][dAssigned], x, y, z);
		if(IsPlayerInRangeOfPoint(playerid, 1.5, x, y, z))return i;
    }
	return -1;
}

ContainerItem(containerid, itemid, quantity)
{
	new slot=0;
	while((slot<MAX_CONTAINER_SIZE-1)&&(cnt_Data[containerid][cItem][slot]!=-1&&cnt_Data[containerid][cItem][slot]!=itemid))slot++;
	if(cnt_Data[containerid][cAmount][slot]+quantity<1)ContainerItem_Remove(containerid, slot);
	else
	{
		cnt_Data[containerid][cItem][slot]=itemid;
		cnt_Data[containerid][cAmount][slot]+=quantity;
	}
}

ContainerItem_Remove(containerid, slot)
{
	new itemTmp, amountTmp;
	cnt_Data[containerid][cItem][slot]=-1;
	cnt_Data[containerid][cAmount][slot]=-1;
	for(new i=slot;i<MAX_CONTAINER-1;i++)
	{
		itemTmp=cnt_Data[containerid][cItem][i+1];
		amountTmp=cnt_Data[containerid][cAmount][i+1];
		cnt_Data[containerid][cItem][i]=itemTmp;
		cnt_Data[containerid][cAmount][i]=amountTmp;
	}
}

ContainerItem_Get(containerid, itemid)
{
	new slot=-1;
	while(cnt_Data[containerid][cItem][slot]!=-1 || cnt_Data[containerid][cItem][slot]!=itemid && (slot<MAX_CONTAINER_SIZE))slot++;
	if(slot!=-1)return cnt_Data[containerid][cAmount][slot];
	else return 0;
}

OpenContainer(playerid, containerid)
{
	new itemList[300], tmpLine[64], slot;
    while(slot<MAX_CONTAINER_SIZE && cnt_Data[containerid][cItem][slot]!=-1)
	{
		format(tmpLine, 64, "%d-%s\n", cnt_Data[containerid][cAmount][slot], ItemData[ cnt_Data[containerid][cItem][slot] ][itemName]);
		strcat(itemList, tmpLine);
		slot++;
	}
	ShowPlayerDialog(playerid, d_Container, DIALOG_STYLE_LIST, "Container", itemList, "Close", "");
	//Audio_play("contianer_Open");
}

CloseContainer(playerid)
{
    pActiveContainer[playerid]=-1;
	//Audio_play("container_Close);
}


ContainerPrint(containerid)
{
	new itemList[300], tmpLine[64], slot;
    while(slot<MAX_CONTAINER_SIZE && cnt_Data[containerid][cItem][slot]!=-1)
	{
		format(tmpLine, 64, "%d-%s\n", cnt_Data[containerid][cAmount][slot], ItemData[ cnt_Data[containerid][cItem][slot] ][itemName]);
		strcat(itemList, tmpLine);
		slot++;
	}
	print(itemList);
}
