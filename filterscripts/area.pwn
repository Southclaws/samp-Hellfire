#include <a_samp>

	#undef MAX_PLAYERS
	#define MAX_PLAYERS 16

#include <streamer>


#define GRID_DIVIDE 2 // How much each side is divide into (2 will result in 4 areas)
#define GRID_TOTAL (GRID_DIVIDE * GRID_DIVIDE) // The total amount of areas


new AreaData[GRID_TOTAL+1];


public OnFilterScriptInit()
{
	new
	    Float:xMax,
	    Float:xMin,
	    Float:yMax,
	    Float:yMin,
		xLoop,
		yLoop,
		idx;

	while(idx < GRID_DIVIDE * GRID_DIVIDE)
	{
	    xMin = ((6000 / GRID_DIVIDE) * xLoop) - 3000.0;
	    xMax = ((6000 / GRID_DIVIDE) * (xLoop+1)) - 3000.0;

		yMin = ((6000 / GRID_DIVIDE) * yLoop) - 3000.0;
		yMax = ((6000 / GRID_DIVIDE) * (yLoop+1)) - 3000.0;


		printf("xMin: %.1f yMin: %.1f xMax: %.1f yMax: %.1f", xMin, yMin, xMax, yMax);
		AreaData[idx] = CreateDynamicRectangle(xMin, yMin, xMax, yMax, -1, 0);


		xLoop++;
		idx++;

		if(xLoop == GRID_DIVIDE) // When the farmost east is reached, return to far west and go north one chunk
		{
		    xLoop = 0;
			yLoop++;
		}

	}
	
	idx = 0;

	new
		Float:tmp_posX = 1462.074462,
		Float:tmp_posY = 2630.878662,
		Float:tmp_posZ = 0.0;

	while(idx < GRID_TOTAL)
	{
		printf("Is %f, %f InAnyArea: %d",
			tmp_posX, tmp_posY, IsPointInAnyDynamicArea(tmp_posX, tmp_posY, tmp_posZ));

		if(IsPointInDynamicArea(AreaData[idx], tmp_posX, tmp_posY, tmp_posZ))
		{
			break;
		}
		idx++;
	}
	printf("Final IDX: %d", idx);

}
