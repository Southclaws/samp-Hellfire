#include <a_samp>
#include <sscanf>

#define loot_Civilian		"loot_Civilian"
#define loot_Industrial		"loot_Industrial"
#define loot_Police			"loot_Police"
#define loot_Military		"loot_Military"
#define loot_Medical		"loot_Medical"
#define loot_CarCivilian	"loot_CarCivilian"
#define loot_CarIndustrial	"loot_CarIndustrial"
#define loot_CarPolice		"loot_CarPolice"
#define loot_CarMilitary	"loot_CarMilitary"
#define loot_Survivor		"loot_Survivor"

#define FILENAME "raisedobjects.txt"

public OnFilterScriptInit()
{
	CreateLootSpawn(-2220.93, 703.67, 62.58, 4, 20, loot_Survivor);
	CreateLootSpawn(-2164.51, 606.81, 72.04, 4, 20, loot_Survivor);
	CreateLootSpawn(-2174.33, 706.44, 52.89, 4, 20, loot_Survivor);
	CreateLootSpawn(-2197.19, 849.88, 68.72, 4, 20, loot_Survivor);
	CreateLootSpawn(-2072.39, 982.21, 76.10, 4, 20, loot_Survivor);
	CreateLootSpawn(-2073.31, 978.42, 69.37, 4, 20, loot_Survivor);
	CreateLootSpawn(-2042.04, 878.53, 61.61, 4, 20, loot_Survivor);
	CreateLootSpawn(-2230.68, 589.19, 50.35, 4, 20, loot_Survivor);


	CreateLootSpawn(-1942.71, 487.50, 30.96, 4, 30, loot_Civilian);
	CreateLootSpawn(-1944.51, 560.77, 34.15, 4, 30, loot_Civilian);
	CreateLootSpawn(-1934.14, 576.48, 34.15, 4, 30, loot_Civilian);
	CreateLootSpawn(-1810.05, 535.64, 34.16, 4, 30, loot_Civilian);
	CreateLootSpawn(-1825.88, 567.93, 34.16, 4, 30, loot_Civilian);
	CreateLootSpawn(-1783.96, 669.75, 34.16, 4, 30, loot_Civilian);
	CreateLootSpawn(-1987.63, 898.64, 44.19, 4, 30, loot_Civilian);
	CreateLootSpawn(-1976.53, 869.33, 44.19, 4, 30, loot_Civilian);
	CreateLootSpawn(-2020.10, 906.36, 45.39, 4, 30, loot_Civilian);
	CreateLootSpawn(-1979.96, 955.00, 44.44, 4, 30, loot_Civilian);
	CreateLootSpawn(-1866.99, 1080.63, 45.06, 4, 30, loot_Civilian);
	CreateLootSpawn(-1982.64, 1117.63, 52.10, 4, 30, loot_Civilian);
	CreateLootSpawn(-2043.83, 1027.72, 53.66, 4, 30, loot_Civilian);
	CreateLootSpawn(-1914.80, 1188.52, 44.43, 4, 30, loot_Civilian);
	CreateLootSpawn(-1713.49, 1205.71, 24.10, 4, 30, loot_Civilian);
	CreateLootSpawn(-1749.81, 1087.42, 44.43, 4, 30, loot_Civilian);
	CreateLootSpawn(-1813.01, 1079.06, 45.07, 4, 30, loot_Civilian);
	CreateLootSpawn(-1764.72, 961.36, 23.87, 4, 30, loot_Civilian);
	CreateLootSpawn(-1741.82, 960.37, 23.87, 4, 30, loot_Civilian);
	CreateLootSpawn(-1697.97, 950.62, 23.88, 4, 30, loot_Civilian);
	CreateLootSpawn(-1749.39, 862.25, 23.88, 4, 30, loot_Civilian);
	CreateLootSpawn(-1750.04, 906.33, 23.88, 4, 30, loot_Civilian);
	CreateLootSpawn(-1736.39, 790.23, 23.88, 4, 30, loot_Civilian);
	CreateLootSpawn(-1705.69, 785.82, 23.86, 4, 30, loot_Civilian);
	CreateLootSpawn(-1603.11, 780.66, 5.81, 4, 30, loot_Civilian);
	CreateLootSpawn(-1600.22, 871.59, 8.20, 4, 30, loot_Civilian);
	CreateLootSpawn(-1629.33, 891.02, 8.85, 4, 30, loot_Civilian);

	CreateLootSpawn(-1978.96, 429.78, 24.10, 3, 35, loot_Industrial);
	CreateLootSpawn(-2054.51, 455.98, 34.16, 3, 35, loot_Industrial);
	CreateLootSpawn(-1959.56, 618.29, 34.00, 3, 35, loot_Industrial);
	CreateLootSpawn(-1950.54, 796.15, 54.71, 3, 35, loot_Industrial);
	CreateLootSpawn(-1779.18, 763.19, 23.88, 3, 35, loot_Industrial);
	CreateLootSpawn(-1659.74, 788.77, 17.09, 3, 35, loot_Industrial);
	CreateLootSpawn(-1680.98, 1058.98, 53.68, 3, 35, loot_Industrial);
	CreateLootSpawn(-1669.19, 1018.32, 6.91, 3, 35, loot_Industrial);
	CreateLootSpawn(-1770.94, 1206.27, 24.11, 3, 35, loot_Industrial);
	CreateLootSpawn(-1790.77, 1223.55, 31.64, 3, 35, loot_Industrial);
	CreateLootSpawn(-1837.06, 992.39, 44.60, 3, 35, loot_Industrial);
	CreateLootSpawn(-2050.91, 1112.79, 52.27, 3, 35, loot_Industrial);
	CreateLootSpawn(-2009.70, 1226.75, 30.62, 3, 35, loot_Industrial);
	CreateLootSpawn(-1962.37, 1227.40, 30.64, 3, 35, loot_Industrial);
	CreateLootSpawn(-1791.85, 1304.28, 58.72, 3, 35, loot_Industrial);
	CreateLootSpawn(-1833.89, 1297.56, 58.72, 3, 35, loot_Industrial);
	CreateLootSpawn(-1850.19, 1287.25, 49.43, 3, 35, loot_Industrial);
	CreateLootSpawn(-1778.03, 1313.90, 40.14, 3, 35, loot_Industrial);
	CreateLootSpawn(-1829.74, 1306.73, 30.85, 3, 35, loot_Industrial);
	CreateLootSpawn(-1843.32, 1284.11, 21.55, 3, 35, loot_Industrial);
	CreateLootSpawn(-1705.19, 1017.33, 16.57, 3, 35, loot_Industrial);
	CreateLootSpawn(-1715.12, 1043.73, 16.91, 3, 35, loot_Industrial);

	CreateLootSpawn(-1951.27, 643.76, 45.56, 4, 14, loot_Military);
	CreateLootSpawn(-1981.88, 657.57, 45.56, 4, 14, loot_Military);
	CreateLootSpawn(-1952.75, 683.21, 45.56, 4, 14, loot_Military);
	CreateLootSpawn(-1923.60, 666.20, 45.56, 4, 14, loot_Military);
	CreateLootSpawn(-1950.80, 726.67, 44.29, 4, 14, loot_Military);
	CreateLootSpawn(-1982.65, 702.38, 45.56, 4, 14, loot_Military);
	CreateLootSpawn(-1922.66, 701.91, 45.56, 4, 14, loot_Military);
	CreateLootSpawn(-1920.95, 714.37, 45.56, 4, 14, loot_Military);

	CreateLootSpawn(-1917.63, 946.89, 44.81, 5, 10, loot_Survivor);
	CreateLootSpawn(-1855.86, 986.12, 44.42, 5, 10, loot_Survivor);
	CreateLootSpawn(-1868.22, 972.48, 48.67, 5, 10, loot_Survivor);
	CreateLootSpawn(-1953.01, 1018.93, 66.81, 5, 10, loot_Survivor);
	CreateLootSpawn(-1989.02, 1106.05, 82.59, 5, 10, loot_Survivor);
	CreateLootSpawn(-1808.14, 1027.05, 44.23, 5, 10, loot_Survivor);
	CreateLootSpawn(-1868.49, 811.46, 111.53, 5, 10, loot_Survivor);
	CreateLootSpawn(-1844.57, 825.57, 108.84, 5, 10, loot_Survivor);
	CreateLootSpawn(-1883.75, 793.53, 108.84, 5, 10, loot_Survivor);
	CreateLootSpawn(-2021.96, 771.82, 61.47, 5, 10, loot_Survivor);
	CreateLootSpawn(-2018.77, 871.26, 61.63, 5, 10, loot_Survivor);
	CreateLootSpawn(-2018.30, 901.65, 59.63, 5, 10, loot_Survivor);
	CreateLootSpawn(-2017.92, 901.98, 54.27, 5, 10, loot_Survivor);
	CreateLootSpawn(-1780.02, 1312.43, 58.73, 5, 10, loot_Survivor);
	CreateLootSpawn(-1854.55, 1075.63, 144.12, 5, 10, loot_Survivor);
	CreateLootSpawn(-1820.05, 1079.70, 144.12, 5, 10, loot_Survivor);
	CreateLootSpawn(-1922.23, 630.08, 144.27, 5, 10, loot_Survivor);
	CreateLootSpawn(-1985.24, 631.12, 144.26, 5, 10, loot_Survivor);
	CreateLootSpawn(-1982.33, 692.29, 144.27, 5, 10, loot_Survivor);
	CreateLootSpawn(-1922.01, 689.42, 144.28, 5, 10, loot_Survivor);
	CreateLootSpawn(-1935.52, 775.36, 104.23, 5, 10, loot_Survivor);
	CreateLootSpawn(-1963.88, 816.20, 91.26, 5, 10, loot_Survivor);
	CreateLootSpawn(-1738.65, 789.03, 166.62, 5, 10, loot_Survivor);
	CreateLootSpawn(-1764.64, 769.39, 166.62, 5, 10, loot_Survivor);
	CreateLootSpawn(-1766.95, 810.69, 166.62, 5, 10, loot_Survivor);
	CreateLootSpawn(-1667.65, 894.35, 135.08, 5, 10, loot_Survivor);
	CreateLootSpawn(-1668.02, 878.10, 135.08, 5, 10, loot_Survivor);
	CreateLootSpawn(-1649.58, 874.49, 135.07, 5, 10, loot_Survivor);
	CreateLootSpawn(-1683.38, 897.47, 135.08, 5, 10, loot_Survivor);

}

CreateLootSpawn(Float:x, Float:y, Float:z, size, chance, type[])
{
	new
		File:file,
		str[128];

	if(!fexist(FILENAME))
		file = fopen(FILENAME, io_write);

	else
		file = fopen(FILENAME, io_append);

	format(str, 128, "CreateLootSpawn(%f, %f, %f,\t%d, %d, %s);\r\n", x, y, z+0.09, size, chance, type);
	fwrite(file, str);

	fclose(file);
}
