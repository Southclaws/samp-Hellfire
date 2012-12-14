#include <a_samp>
#include <formatex>
#include <zcmd>
#include <streamer>
#include <colours>

#undef MAX_PLAYERS
#define MAX_PLAYERS 16

#define MAX_ANIMS		(1812)  // Total amount of animations
#define MAX_LIBRARY		(131)   // Total amount of libraries
#define MAX_LIBANIMS    (294)   // Largest library
#define MAX_LIBNAME     (32)
#define MAX_ANIMNAME    (32)    // Same as LIBNAME but just for completion!


new
	gAnimTotal[MAX_LIBRARY],
	gLibArray[MAX_LIBRARY][MAX_LIBNAME],
	gAnimArray[MAX_LIBRARY][MAX_LIBANIMS][MAX_ANIMNAME],
	g_tmpLibList[MAX_LIBRARY * (MAX_LIBNAME+1)];


public OnFilterScriptInit()
{
	new
	    lib[32],
	    anim[32],
		tmplib[32] = "NULL",
		curlib = 0;

	for(new i = 1;i<MAX_ANIMS;i++)
	{
	    printf("\tFIRST 1 - %02d LIBGLOBAL: '%s'", curlib, gLibArray[0]);
	    GetAnimationName(i, lib, 32, anim, 32);

	    if(strcmp(lib, tmplib))
	    {
	        gLibArray[curlib] = lib;
		    strcat(g_tmpLibList, lib);
		    strcat(g_tmpLibList, "\n");
	        curlib++;
	        tmplib = lib;
	        print("\n\n");
	    }
	    else
	    {
	    	gAnimArray[ curlib ][ gAnimTotal[curlib] ] = anim;
	    	gAnimTotal[ curlib ]++;
	    }
	}
	printf("FINAL LIBGLOBAL: '%s'", gLibArray[0]);
}

