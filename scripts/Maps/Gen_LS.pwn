public OnLoad()
{
	CreateDispenser(1173.22, -1338.81, 13.58, 90.00, disp_HealoMatic);
	CreateDispenser(1155.37, -1464.25, 15.42, -71.82, disp_HealoMatic);
	CreateDispenser(2043.81, -1412.86, 16.77, -90.00, disp_HealoMatic);
	CreateDispenser(1937.86, -2111.91, 13.29, 180.06, disp_HealoMatic);
	CreateDispenser(396.06, -2072.71, 7.43, 0.00, disp_HealoMatic);


	CreateZipline(
		2159.08, -986.47, 70.59,
		2063.30, -993.57, 59.38, .worldid = 3);

	CreateZipline(
		2152.75, -1027.94, 73.47,
		2191.36, -1051.42, 57.25, .worldid = 3);

	CreateZipline(
		2228.26, -1120.77, 48.88,
		2200.78, -1096.47, 42.13, .worldid = 3);


	AddSprayTag(1172.8808, -1313.0510, 14.2463, 10.0, 0.0, 180.0);
	AddSprayTag(1237.39, -1631.60, 28.02, 0.00, 0.00, 91.00);
	AddSprayTag(1118.51, -1540.14, 24.66, 0.00, 0.00, 178.46);
	AddSprayTag(1202.11, -1201.55, 20.47, 0.00, 0.00, 90.00);
	AddSprayTag(1264.15, -1270.28, 15.16, 0.00, 0.00, 270.00);

	CreateShop("Los Santos General Store", GeneralStore, 1158.2169, -1443.7321, 15.7981, 1157.36, -1443.48, 15.84);

	return CallLocalFunction("genls_OnLoad", "");
}
#if defined _ALS_OnLoad
	#undef OnLoad
#else
	#define _ALS_OnLoad
#endif
#define OnLoad genls_OnLoad
forward genls_OnLoad();


