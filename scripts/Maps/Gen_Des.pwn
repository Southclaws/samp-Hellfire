public OnLoad()
{
	new
		buttonid[2];

	buttonid[0]=CreateButton(-101.579933, 1374.613769, 10.4698, "Press F to enter", 0, 0);
	buttonid[1]=CreateButton(-217.913787, 1402.804199, 27.7734, "Press F to exit", 0, 18);
	LinkTP(buttonid[0], buttonid[1]);

	AddSprayTag(-399.77, 1514.92, 75.26, 0.00, 0.00, 0.00);
	AddSprayTag(-229.34, 1082.35, 20.29, 0.00, 0.00, 0.00);
	AddSprayTag(-2442.17, 2299.23, 5.71, 0.00, 0.00, 270.00);
	AddSprayTag(-2662.95, 2121.44, 2.14, 0.00, 0.00, 180.00);
	AddSprayTag(146.92, 1831.78, 18.02, 0.00, 0.00, 90.00);

	CreateDispenser(-1470.98, 2610.81, 55.44, 0.00, disp_HealoMatic);
	CreateDispenser(-861.18, 1536.52, 22.21, 180.00, disp_HealoMatic);
	CreateDispenser(-328.51, 1060.61, 19.36, 180.00, disp_HealoMatic);
	CreateDispenser(-254.86, 2600.91, 62.46, 180.00, disp_HealoMatic);
	CreateDispenser(696.90, 1968.48, 5.13, 0.00, disp_HealoMatic);

	CreateTurret(287.0, 2047.0, 17.5, 270.0, .type = 1);
	CreateTurret(335.0, 1843.0, 17.5, 270.0, .type = 1);
	CreateTurret(10.0, 1805.0, 17.40, 180.0, .type = 1);

	return CallLocalFunction("gendes_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad gendes_OnLoad
forward gendes_OnLoad();


#endinput

	des_FenceGate=CreateDynamicObject(980, -29.6011, 2514.2014, 18.2577, 0, 0, 270.6756, ABD_WORLD);


    des_WhShutter[0]=CreateDynamicObject(974, -1481.880737, 2611.466553, 58.833641, 0.0000, 0.0000, 0.0000);
    des_WhShutter[1]=CreateDynamicObject(974, -1485.840820, 2615.600098, 58.983650, 0.0000, 0.0000, 90.2408);
    des_WhShutter[2]=CreateDynamicObject(974, -1485.797974, 2623.722412, 58.916321, 0.0000, 0.0000, 90.2408);
    des_WhShutter[3]=CreateDynamicObject(974, -1485.812622, 2631.457275, 58.908646, 0.0000, 0.0000, 90.2408);
    des_WhShutter[4]=CreateDynamicObject(974, -1485.790649, 2639.139404, 58.833641, 0.0000, 0.0000, 90.2408);

	//Warehouse des_WhShutters
    Cmd("/shutup")
	{
        MoveDynamicObject(des_WhShutter[0], -1481.880737, 2611.466553, 58.833641, 5.0);
        MoveDynamicObject(des_WhShutter[1], -1485.840820, 2615.600098, 58.983650, 5.0);
        MoveDynamicObject(des_WhShutter[2], -1485.797974, 2623.722412, 58.916321, 5.0);
        MoveDynamicObject(des_WhShutter[3], -1485.812622, 2631.457275, 58.908646, 5.0);
        MoveDynamicObject(des_WhShutter[4], -1485.790649, 2639.139404, 58.833641, 5.0);
        return 1;
    }
    Cmd("/shutdn")
	{
        MoveDynamicObject(des_WhShutter[0], -1481.880737, 2611.466553, 55.0, 5.0);
        MoveDynamicObject(des_WhShutter[1], -1485.840820, 2615.600098, 55.0, 5.0);
        MoveDynamicObject(des_WhShutter[2], -1485.797974, 2623.722412, 55.0, 5.0);
        MoveDynamicObject(des_WhShutter[3], -1485.812622, 2631.457275, 55.0, 5.0);
        MoveDynamicObject(des_WhShutter[4], -1485.790649, 2639.139404, 55.0, 5.0);
        return 1;
    }
	Cmd("/shutter")
	{
	    new dir, sht;
	    if(sscanf(params, "dd", dir, sht))return msg(playerid, YELLOW, "/shutter [up/down-1/0] [des_WhShutter]");
		if(sht==1)
		{
        	if(dir)MoveDynamicObject(des_WhShutter[0], -1481.880737, 2611.466553, 58.833641, 5.0);
        	else MoveDynamicObject(des_WhShutter[0], -1481.880737, 2611.466553, 55.0, 5.0);
		}
		else if(sht==2)
		{
		    if(dir)MoveDynamicObject(des_WhShutter[1], -1485.840820, 2615.600098, 58.983650, 5.0);
		    else MoveDynamicObject(des_WhShutter[1], -1485.840820, 2615.600098, 55.0, 5.0);
		}
		else if(sht==3)
		{
		    if(dir)MoveDynamicObject(des_WhShutter[2], -1485.797974, 2623.722412, 58.916321, 5.0);
		    else MoveDynamicObject(des_WhShutter[2], -1485.797974, 2623.722412, 55.0, 5.0);
		}
		else if(sht==4)
		{
		    if(dir)MoveDynamicObject(des_WhShutter[3], -1485.812622, 2631.457275, 58.908646, 5.0);
		    else MoveDynamicObject(des_WhShutter[3], -1485.812622, 2631.457275, 55.0, 5.0);
		}
		else if(sht==5)
		{
		    if(dir)MoveDynamicObject(des_WhShutter[4], -1485.790649, 2639.139404, 58.833641, 5.0);
		    else MoveDynamicObject(des_WhShutter[4], -1485.790649, 2639.139404, 55.0, 5.0);
		}
		return 1;
    }
    return 0;
}

