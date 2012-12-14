new isTDIDUsed[MAX_TEXT_DRAWS];

#define TextDrawCreate TextDrawCreateEx             // Re-define
#define TextDrawDestroy TextDrawDestroyEx

Text:TextDrawCreateEx(Float:x, Float:y, text[])
{
	new Text:tmpID = TextDrawCreate(x, y, text);	// Create the textdraw, get the ID
	isTDIDUsed[tmpID] = true;						// This ID is now used
	return tmpID;									// Return the ID so it can be assigned
}
TextDrawDestroyEx(Text:text)
{
	if(!isTDIDUsed[text])return 0;					// If it was never created, exit here
	isTDIDUsed[text]=false;							// This ID is not used any more
	return TextDrawDestroy(text);					// Return whatever TDD returns (if anything)
}

new isPTDIDUsed[MAX_PLAYERS][MAX_PLAYER_TEXT_DRAWS];

#define CreatePlayerTextDraw CreatePlayerTextDrawEx
#define PlayerTextDrawDestroy PlayerTextDrawDestroyEx

Text:CreatePlayerTextDrawEx(playerid, Float:x, Float:y, text[])
{
	new Text:tmpID = CreatePlayerTextDraw(playerid, x, y, text);
	isTDIDUsed[playerid][tmpID] = true;
	return tmpID;					
}
PlayerTextDrawDestroyEx(playerid, Text:text)
{
	if(!isTDIDUsed[playerid][text])return 0;
	isTDIDUsed[playerid][text]=false;
	return PlayerTextDrawDestroy(playerid, text);
}

