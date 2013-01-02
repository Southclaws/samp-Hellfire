public OnLoad()
{
	CreateDispenser(619.34, -583.53, 16.84, 0.00, disp_HealoMatic);
	CreateDispenser(157.84, -202.17, 1.21, 0.00, disp_HealoMatic);
	CreateDispenser(1374.32, 473.67, 19.72, -114.42, disp_HealoMatic);
	CreateDispenser(2329.96, 82.02, 26.12, 180.00, disp_HealoMatic);

	return CallLocalFunction("genred_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad genred_OnLoad
forward genred_OnLoad();


