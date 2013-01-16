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

// Military Loot

	CreateLootSpawn(-1315.70, 493.69, 17.23, 3, 15, 0, 15, 60);
	CreateLootSpawn(-1405.08, 496.66, 10.19, 3, 15, 0, 15, 60);
	CreateLootSpawn(-1301.60, 508.32, 10.19, 3, 15, 0, 15, 60);
	CreateLootSpawn(-1418.49, 506.10, 2.04, 3, 15, 0, 15, 60);
	CreateLootSpawn(-1381.09, 507.39, 2.04, 3, 15, 0, 15, 60);
	CreateLootSpawn(-1463.05, 426.34, 6.18, 3, 10, 0, 15, 60);
	CreateLootSpawn(-1464.43, 390.51, 6.18, 3, 10, 0, 15, 60);
	CreateLootSpawn(-1464.59, 355.12, 6.18, 3, 10, 0, 15, 60);
	CreateLootSpawn(-1616.11, 685.62, 6.18, 3, 10, 0, 15, 60);
	CreateLootSpawn(-1623.56, 668.17, -5.91, 3, 10, 0, 15, 60);
	CreateLootSpawn(-1969.48, 684.77, 45.56, 3, 10, 0, 15, 60);
	CreateLootSpawn(-1933.79, 684.98, 45.56, 3, 10, 0, 15, 60);
	CreateLootSpawn(-1844.24, -101.84, 4.65, 4, 50, 0, 0, 60);

// Industrial Loot

	CreateLootSpawn(-1691.99, 13.91, 2.55, 3, 40, 30, 70, 10);
	CreateLootSpawn(-1720.85, 14.49, 2.58, 3, 40, 30, 70, 10);
	CreateLootSpawn(-1494.45, 132.20, 16.32, 3, 40, 30, 70, 10);
	CreateLootSpawn(-1626.73, -42.40, 2.54, 3, 40, 30, 70, 10);
	CreateLootSpawn(-1723.23, 225.61, 0.95, 3, 40, 30, 70, 10);
	CreateLootSpawn(-1628.61, 156.78, 0.95, 3, 40, 30, 70, 10);
	CreateLootSpawn(-1819.82, -150.38, 8.39, 3, 40, 30, 70, 10);
	CreateLootSpawn(-2149.83, -146.49, 35.46, 3, 40, 30, 70, 10);
	CreateLootSpawn(-2182.53, -222.82, 35.51, 3, 40, 30, 70, 10);
	CreateLootSpawn(-2180.89, -263.45, 35.51, 3, 40, 30, 70, 10);
	CreateLootSpawn(-2144.21, -247.39, 35.51, 3, 40, 30, 70, 10);
	CreateLootSpawn(-2185.84, -247.80, 35.52, 3, 40, 30, 70, 10);
	CreateLootSpawn(-2758.13, 245.24, 6.17, 3, 40, 30, 70, 10);
	CreateLootSpawn(-2710.41, 639.10, 13.44, 3, 40, 30, 70, 10);
	CreateLootSpawn(-2640.90, 639.05, 13.43, 3, 40, 30, 70, 10);
	CreateLootSpawn(-2558.37, 661.22, 13.44, 3, 40, 30, 70, 10);
	CreateLootSpawn(-2512.86, 1545.11, 16.32, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2495.45, 1554.30, 23.15, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2483.07, 1534.02, 26.85, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2474.39, 1552.45, 32.23, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2476.98, 1548.95, 32.23, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2369.34, 1553.30, 1.11, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2393.18, 1546.20, 1.11, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2439.74, 1555.01, 1.11, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2427.19, 1536.21, 1.11, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2368.31, 1547.88, 16.32, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2309.41, 1544.52, 17.76, 3, 40, 10, 80, 30);
	CreateLootSpawn(-2329.70, 1555.93, 16.32, 3, 40, 10, 80, 30);

	CreateLootSpawn(-1953.77, 1500.53, 6.18, 2, 50, 30, 70, 10);
	CreateLootSpawn(-1834.67, 1542.72, 6.14, 2, 50, 30, 70, 10);
	CreateLootSpawn(-1789.83, 1542.86, 6.14, 2, 50, 30, 70, 10);
	CreateLootSpawn(-1740.69, 1542.90, 6.14, 2, 50, 30, 70, 10);
	CreateLootSpawn(-1638.35, 1415.92, 6.16, 2, 50, 30, 70, 10);
	CreateLootSpawn(-1508.80, 1296.07, 0.38, 2, 50, 30, 70, 10);
	CreateLootSpawn(-1467.28, 1086.26, 0.58, 2, 50, 30, 70, 10);
	CreateLootSpawn(-1461.60, 1019.15, 0.76, 2, 50, 30, 70, 10);
	CreateLootSpawn(-1481.19, 687.60, 0.30, 2, 50, 30, 70, 10);
	CreateLootSpawn(-1738.71, 1235.79, 6.54, 2, 50, 30, 70, 10);

	buttonid[0] = CreateButton(-904.7388, 335.7443, 1014.1530, "Press F to open", 0);
	buttonid[1] = CreateButton(-1857.1831, -169.5322, 9.1358, "Press F to open", 0);
	LinkTP(buttonid[0], buttonid[1]);


	return CallLocalFunction("gensf_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad gensf_OnLoad
forward gensf_OnLoad();

