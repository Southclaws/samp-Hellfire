public OnLoad()
{
	new
		buttonid[2];

	buttonid[0] = CreateButton(-2208.2568, 579.8558, 35.7653, "Press F to activate", 0);
	buttonid[1] = CreateButton(-2208.2561, 584.4679, 35.7653, "Press F to activate", 0);
	CreateDoor(16501, buttonid,
		-2211.40, 581.99, 36.37,   0.00, 0.00, 90.00,
		-2211.40, 581.99, 39.61,   0.00, 0.00, 90.00);

	buttonid[0] = CreateButton(-2243.0400, 640.7287, 49.9911, "Press F to activate", 0);
	buttonid[1] = CreateButton(-2238.6035, 641.0287, 49.9911, "Press F to activate", 0);
	CreateDoor(16501, buttonid,
		-2241.90, 643.55, 50.69,   0.00, 0.00, 0.00,
		-2241.90, 643.55, 53.96,   0.00, 0.00, 0.00);


	CreateZipline(
		-2176.1233, 624.6251, 64.5186,
		-2199.2416, 599.1184, 58.2986);

	CreateZipline(
		-2172.7917, 598.8414, 71.2611,
		-2225.6408, 661.6533, 67.7622);

	CreateLadder(-1164.6187, 370.0174, 1.9609, 14.1484, 221.1218);
	CreateLadder(-1182.6258, 60.4429, 1.9609, 14.1484, 134.2914);
	CreateLadder(-1736.4494, -445.9549, 1.9609, 14.1484, 270.7138);
	CreateLadder(-1392.0263, -15.0978, 213.9799, 234.0190, 183.5498);
	CreateLadder(-2208.4399, 646.6311, 53.9300, 63.7599, 90.7508);

	AddSprayTag(-1908.91, 299.56, 41.52, 0.00, 0.00, 180.00);
	AddSprayTag(-2636.70, 635.52, 15.63, 0.00, 0.00, 0.00);
	AddSprayTag(-2224.75, 881.27, 84.13, 0.00, 0.00, 90.00);
	AddSprayTag(-1788.32, 748.42, 25.36, 0.00, 0.00, 270.00);

	CreateDispenser(-1954.63, -723.39, 31.83, 180.00, disp_HealoMatic);
	CreateDispenser(-1980.59, 133.35, 27.28, -90.00, disp_HealoMatic);
	CreateDispenser(-2695.17, 259.96, 4.25, 180.00, disp_HealoMatic);
	CreateDispenser(-2353.84, 1003.79, 50.52, 0.00, disp_HealoMatic);
	CreateDispenser(-1674.29, 1382.10, 6.79, 90.00, disp_HealoMatic);
	CreateDispenser(-2475.85, 2311.76, 4.60, 90.00, disp_HealoMatic);

	return CallLocalFunction("gensf_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad gensf_OnLoad
forward gensf_OnLoad();

