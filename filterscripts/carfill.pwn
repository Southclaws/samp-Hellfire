#include <a_samp>
#include <zcmd>

#define ORIGIN_X 429.5609
#define ORIGIN_Y 2482.741

#define MAX_X -77.6706
#define MAX_Y 2508.7195

#define OFFSET_X 5.0
#define OFFSET_Y 10.0

public OnFilterScriptInit()
{
	for(new i;i<MAX_VEHICLES;i++)DestroyVehicle(i);

	new
	    v_counter		= 0,
		xLoop			= 0,
		yLoop			= 0,
		Float:xPos		= ORIGIN_X,
		Float:yPos		= ORIGIN_Y;

	while(v_counter < MAX_VEHICLES) // Y-axis Limit
	{
		xPos = ORIGIN_X - (xLoop * OFFSET_X);
		yPos = ORIGIN_Y + (yLoop * OFFSET_Y);

		if(xPos < MAX_X)
		{
		    xLoop = 0;
			yLoop++;

			xPos = ORIGIN_X - (xLoop * OFFSET_X);
			yPos = ORIGIN_Y + (yLoop * OFFSET_Y);
		}
		if(yPos > MAX_Y) break;


		AddStaticVehicle(471,
			xPos, yPos, 16.74,
			random(2)*180, random(128), random(128));

		xLoop++;
		v_counter++;
	}
}

#endinput

// original

// Vehicles
	new v_counter=0; // Vehicle counter
	new bool:v_break=false;
	new x=0, y=0; // Multiplier
	new Float:CurrY=2508.1195, Float:CurrX=429.5609; // Current
	while(CurrY < 2526.7195) // Y-axis Limit
	{
		while(CurrX > -77.6706) // X-axies Limit
		{
			CurrX=CurrX-(7*x);
			x++;
            AddStaticVehicle(CarModels[random(sizeof(CarModels))],CurrX,CurrY, 16.74, random(2)*180, random(128), random(128));
            v_counter++;
			if(v_counter >= MAX_VEHICLES)
			{
				printf("MAX Vehicles loaded! 2k!");
				v_break=true;
				break;
			}
		}
		if(v_break==true)
		{
			printf("MAX Vehicles loaded! Finnished!");
			break;
		}
		CurrY=CurrY+(18.6*y);
		x=0;
		y++;
	}
