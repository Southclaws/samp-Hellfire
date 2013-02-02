new
	Boxes[1000][1000],
	Float:BOX_OFFSET = 1.4,
	MAX_BOXES = 20;

	Cmd("/makeboxes")
	{
		for(new x;x<MAX_BOXES;x++)
		{
			for(new y;y<MAX_BOXES;y++)
			{
				Boxes[x][y] = CreateDynamicObject(1224, (x*BOX_OFFSET), (y*BOX_OFFSET), 10.00,   0.00, 0.00, 0.00, .streamdistance = 1000.0);
			}
		}
		return 1;
	}
	Cmd("/resetboxes")
	{
		for(new x;x<MAX_BOXES;x++)
		{
			for(new y;y<MAX_BOXES;y++)
			{
				SetDynamicObjectPos(Boxes[x][y], (x*BOX_OFFSET), (y*BOX_OFFSET), 10.00);
			}
		}
	}
	Cmd("/destroyboxes")
	{
		for(new x;x<MAX_BOXES;x++)
		{
			for(new y;y<MAX_BOXES;y++)
			{
				DestroyDynamicObject(Boxes[x][y]);
			}
		}
		return 1;
	}
	Cmd("/setoffset")
	{
	    BOX_OFFSET = floatstr(params);
		for(new x;x<MAX_BOXES;x++)
		{
			for(new y;y<MAX_BOXES;y++)
			{
				SetDynamicObjectPos(Boxes[x][y], (x*BOX_OFFSET), (y*BOX_OFFSET), 10.00);
			}
		}
	    return 1;
	}
	Cmd("/setmaxbox")
	{
	    MAX_BOXES = strval(params);
	    return 1;
	}
