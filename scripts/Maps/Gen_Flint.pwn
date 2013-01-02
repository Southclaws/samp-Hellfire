public OnLoad()
{
	CreateBalloon(-2237.60, -1711.45, 479.88, 0.0, 1529.81, -1358.07, 328.37, 0.0);

	CreateDispenser(27.29, -2643.36, 40.06, 184.02, disp_HealoMatic);
	CreateDispenser(-2143.76, -2392.63, 30.22, 52.02, disp_HealoMatic);

	return CallLocalFunction("genflint_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad genflint_OnLoad
forward genflint_OnLoad();


