public OnLoad()
{
	CreateLadder(1177.6424, -1305.6337, 13.9241, 29.0859, 0.0);

	AddSprayTag(2267.55, 1518.13, 46.33, 0.00, 0.00, 180.00);

	CreateDispenser(1097.88, 1456.08, 12.15, 0.00, disp_HealoMatic);
	CreateDispenser(1580.06, 2217.96, 10.68, 0.00, disp_HealoMatic);
	CreateDispenser(2538.93, 2264.92, 10.42, 180.00, disp_HealoMatic);
	CreateDispenser(2552.14, 1045.83, 10.41, 90.00, disp_HealoMatic);
	CreateDispenser(2088.98, 1456.46, 10.37, 225.24, disp_HealoMatic);

	return CallLocalFunction("genlv_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad genlv_OnLoad
forward genlv_OnLoad();


