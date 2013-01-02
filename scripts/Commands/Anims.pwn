	CMD:carjacked1(playerid, params[])
	{
		LoopAnimation(playerid, "PED", "CAR_jackedLHS", 4.0, 0, 1, 1, 1, 0);
		return 1;
    }
    CMD:carjacked2(playerid, params[])
	{
		LoopAnimation(playerid,"PED", "CAR_jackedRHS", 4.0, 0, 1, 1, 1, 0);
		return 1;
    }
	CMD:handsup(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid, "ROB_BANK", "SHP_HandsUp_Scr", 4.0, 0, 1, 1, 1, 0);
		return 1;
    }
	CMD:cellin(playerid, params[])
	{
	    #pragma unused params
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
        return 1;
    }
	CMD:cellout(playerid, params[])
	{
	    #pragma unused params
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
        return 1;
    }
    CMD:drunk(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"PED","WALK_DRUNK",4.1,1,1,1,1,1);
		return 1;
    }
    CMD:bomb(playerid, params[])
	{
	    #pragma unused params
		ClearAnimations(playerid);
		LoopAnimation(playerid, "BOMBER","BOM_Plant_Loop",4.0,1,0,0,1,0); // Place Bomb
		return 1;
	}
    CMD:getarrested(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"ped", "ARRESTgun", 4.0, 0, 1, 1, 1, -1); // Gun Arrest
		return 1;
    }
    CMD:laugh(playerid, params[])
    {
	    #pragma unused params
		SingleAnimation(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0); // Laugh
		return 1;
	}
    CMD:lookout(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid, "SHOP", "ROB_Shifty", 4.0, 0, 0, 0, 0, 0); // Rob Lookout
		return 1;
	}
    CMD:robman(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0); // Rob
		return 1;
	}
    CMD:crossarms(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1); // Arms crossed
		return 1;
	}
    CMD:lay(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0); // Lay down
		return 1;
    }
    CMD:cower(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid, "ped", "cower", 3.0, 1, 0, 0, 0, 0); // Taking Cover
		return 1;
	}
    CMD:vomit(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0); // Vomit BAH!
		return 1;
	}
    CMD:eat(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0); // Eat Burger
		return 1;
	}
    CMD:wave(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, 0); // Wave
		return 1;
	}
    CMD:slapass(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0); // Ass Slapping
		return 1;
	}
    CMD:deal(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid, "DEALER", "DEALER_DEAL", 4.0, 0, 0, 0, 0, 0); // Deal Drugs
		return 1;
	}
    CMD:crack(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0); // Dieing of Crack
		return 1;
	}
	CMD:smoke(playerid, params[])
    {
		if(!strlen(params)) return SendClientMessage(playerid, YELLOW, "Usage: /smoke [1-4]");
		switch(params[0])
		{
			case '1': LoopAnimation(playerid,"SMOKING", "M_smklean_loop", 4.0, 1, 0, 0, 0, 0); // male
			case '2': LoopAnimation(playerid,"SMOKING", "F_smklean_loop", 4.0, 1, 0, 0, 0, 0); //female
			case '3': LoopAnimation(playerid,"SMOKING","M_smkstnd_loop", 4.0, 1, 0, 0, 0, 0); // standing-fucked
			case '4': LoopAnimation(playerid,"SMOKING","M_smk_out", 4.0, 1, 0, 0, 0, 0); // standing
			default: SendClientMessage(playerid, YELLOW, "Usage: /smoke [1-4]");
		}
		return 1;
	}
    CMD:sit(playerid, params[])
    {
	    #pragma unused params
		LoopAnimation(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0); // Sit
		return 1;
    }
    CMD:talk(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"PED","IDLE_CHAT",4.0,1,0,0,1,1);
		return 1;
    }
    CMD:fucku(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"PED","fucku",4.0,0,0,0,0,0);
		return 1;
    }
	CMD:taichi(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"PARK","Tai_Chi_Loop",4.0,1,0,0,0,0);
		return 1;
    }
    CMD:chairsit(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"PED","SEAT_down",4.1,0,1,1,1,0);
		return 1;
    }
    CMD:fall(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"PED","KO_skid_front",4.1,0,1,1,1,0);
        return 1;
    }
    CMD:fallback(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid, "PED","FLOOR_hit_f", 4.0, 1, 0, 0, 0, 0);
        return 1;
    }
    CMD:kiss(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid, "KISSING", "Playa_Kiss_02", 3.0, 1, 1, 1, 1, 0);
        return 1;
    }
    CMD:injured(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 0, 0);
        return 1;
    }
    CMD:sup(playerid, params[])
    {
        if(!strlen(params)) return SendClientMessage(playerid, YELLOW, "Usage: /sup [1-3]");
    	switch(params[0])
    	{
        	case '1': SingleAnimation(playerid,"GANGS","hndshkba",4.0,0,0,0,0,0);
         	case '2': SingleAnimation(playerid,"GANGS","hndshkda",4.0,0,0,0,0,0);
         	case '3': SingleAnimation(playerid,"GANGS","hndshkfa_swt",4.0,0,0,0,0,0);
        	default: SendClientMessage(playerid, YELLOW, "Usage: /sup [1-3]");
    	}
    	return 1;
    }
    CMD:rap(playerid, params[])
    {
        if(!strlen(params))return SendClientMessage(playerid, YELLOW, "Usage: /rap [1-4]");
    	switch(params[0])
    	{
    	    case '1': LoopAnimation(playerid,"RAPPING","RAP_A_Loop",4.0,1,0,0,0,0);
        	case '2': LoopAnimation(playerid,"RAPPING","RAP_C_Loop",4.0,1,0,0,0,0);
        	case '3': LoopAnimation(playerid,"GANGS","prtial_gngtlkD",4.0,1,0,0,0,0);
        	case '4': LoopAnimation(playerid,"GANGS","prtial_gngtlkH",4.0,1,0,0,1,1);
        	default: SendClientMessage(playerid, YELLOW, "Usage: /rap [1-4]");
    	}
    	return 1;
    }
    CMD:push(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"GANGS","shake_cara",4.0,0,0,0,0,0);
        return 1;
    }

    CMD:akick(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"POLICE","Door_Kick",4.0,0,0,0,0,0);
        return 1;
    }

    CMD:lowbodypush(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"GANGS","shake_carSH",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:spray(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"SPRAYCAN","spraycan_full",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:headbutt(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"WAYFARER","WF_Fwd",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:cpr(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"MEDIC","CPR",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:koface(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"PED","KO_shot_face",4.0,0,1,1,1,0);
        return 1;
    }
    CMD:kostomach(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"PED","KO_shot_stom",4.0,0,1,1,1,0);
        return 1;
    }
    CMD:lifejump(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"PED","EV_dive",4.0,0,1,1,1,0);
        return 1;
    }
    CMD:exhaust(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"PED","IDLE_tired",3.0,1,0,0,0,0);
        return 1;
    }
    CMD:leftslap(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"PED","BIKE_elbowL",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:rollfall(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"PED","BIKE_fallR",4.0,0,1,1,1,0);
        return 1;
    }
    CMD:carlock(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"PED","CAR_doorlocked_LHS",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:rcarjack1(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"PED","CAR_pulloutL_LHS",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:lcarjack1(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"PED","CAR_pulloutL_RHS",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:rcarjack2(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"PED","CAR_pullout_LHS",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:lcarjack2(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"PED","CAR_pullout_RHS",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:hoodfrisked(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"POLICE","crm_drgbst_01",4.0,0,1,1,1,0);
        return 1;
    }
    CMD:lightcig(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"SMOKING","M_smk_in",3.0,0,0,0,0,0);
        return 1;
    }
    CMD:tapcig(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"SMOKING","M_smk_tap",3.0,0,0,0,0,0);
        return 1;
    }
    CMD:bat(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"BASEBALL","Bat_IDLE",4.0,1,1,1,1,0);
        return 1;
    }
    CMD:box(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"GYMNASIUM","GYMshadowbox",4.0,1,1,1,1,0);
        return 1;
    }
    CMD:lay2(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"SUNBATHE","Lay_Bac_in",3.0,0,1,1,1,0);
        return 1;
    }
    CMD:chant(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"RIOT","RIOT_CHANT",4.0,1,1,1,1,0);
        return 1;
    }
    CMD:finger(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"RIOT","RIOT_FUKU",2.0,0,0,0,0,0);
        return 1;
    }
    CMD:shouting(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"RIOT","RIOT_shout",4.0,1,0,0,0,0);
        return 1;
    }
    CMD:cop(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"SWORD","sword_block",50.0,0,1,1,1,1);
        return 1;
    }
    CMD:elbow(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"FIGHT_D","FightD_3",4.0,0,1,1,0,0);
        return 1;
    }
    CMD:kneekick(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"FIGHT_D","FightD_2",4.0,0,1,1,0,0);
        return 1;
    }
    CMD:fstance(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"FIGHT_D","FightD_IDLE",4.0,1,1,1,1,0);
        return 1;
    }
    CMD:gpunch(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"FIGHT_B","FightB_G",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:airkick(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"FIGHT_C","FightC_M",4.0,0,1,1,0,0);
        return 1;
    }
    CMD:gkick(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"FIGHT_D","FightD_G",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:lowthrow(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"GRENADE","WEAPON_throwu",3.0,0,0,0,0,0);
        return 1;
    }
    CMD:highthrow(playerid, params[])
	{
	    #pragma unused params
		SingleAnimation(playerid,"GRENADE","WEAPON_throw",4.0,0,0,0,0,0);
        return 1;
    }
    CMD:dealstance(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"DEALER","DEALER_IDLE",4.0,1,0,0,0,0);
		return 1;
    }
    CMD:pee(playerid, params[])
	{
	    #pragma unused params
		SetPlayerSpecialAction(playerid, 68);
        return 1;
    }
    CMD:knife(playerid, params[])
    {
        if(!strlen(params)) return SendClientMessage(playerid, YELLOW, "Usage: /knife [1-4]");
    	switch(params[0])
    	{
    	    case '1': LoopAnimation(playerid,"KNIFE","KILL_Knife_Ped_Damage",4.0,0,1,1,1,0);
        	case '2': LoopAnimation(playerid,"KNIFE","KILL_Knife_Ped_Die",4.0,0,1,1,1,0);
        	case '3': SingleAnimation(playerid,"KNIFE","KILL_Knife_Player",4.0,0,0,0,0,0);
        	case '4': LoopAnimation(playerid,"KNIFE","KILL_Partial",4.0,0,1,1,1,1);
        	default: SendClientMessage(playerid, YELLOW, "Usage: /knife [1-4]");
    	}
    	return 1;
    }
    CMD:basket(playerid, params[])
    {
        if(!strlen(params)) return SendClientMessage(playerid, YELLOW, "Usage: /basket [1-6]");
    	switch(params[0])
    	{
        	case '1': LoopAnimation(playerid,"BSKTBALL","BBALL_idleloop",4.0,1,0,0,0,0);
        	case '2': SingleAnimation(playerid,"BSKTBALL","BBALL_Jump_Shot",4.0,0,0,0,0,0);
        	case '3': SingleAnimation(playerid,"BSKTBALL","BBALL_pickup",4.0,0,0,0,0,0);
        	case '4': LoopAnimation(playerid,"BSKTBALL","BBALL_run",4.1,1,1,1,1,1);
        	case '5': LoopAnimation(playerid,"BSKTBALL","BBALL_def_loop",4.0,1,0,0,0,0);
        	case '6': LoopAnimation(playerid,"BSKTBALL","BBALL_Dnk",4.0,1,0,0,0,0);
        	default: SendClientMessage(playerid, YELLOW, "Usage: /basket [1-6]");
    	}
    	return 1;
    }
    CMD:reload(playerid, params[])
    {
        if (!strlen(params)) return SendClientMessage(playerid, YELLOW, "Usage: /reload [deagle/smg/ak/m4]");
       	if (strcmp("deagle",params,true) == 0)
   	    {
   			SingleAnimation(playerid,"COLT45","colt45_reload",4.0,0,0,0,0,1);
 	    }
 	    else if (strcmp("smg",params,true) == 0 || strcmp("ak",params,true) == 0 || strcmp("m4",params,true) == 0)
   	    {
   			SingleAnimation(playerid,"UZI","UZI_reload",4.0,0,0,0,0,0);
 	    }
       	else SendClientMessage(playerid, YELLOW, "Usage: /reload [deagle/smg/ak/m4]");
    	return 1;
    }
    CMD:gwalk(playerid, params[])
    {
        if (!strlen(params)) return SendClientMessage(playerid, YELLOW, "Usage: /gwalk [1/2]");
    	switch(params[0])
    	{
    		case '1':LoopAnimation(playerid,"PED","WALK_gang1",4.1,1,1,1,1,1);
			case '2':LoopAnimation(playerid,"PED","WALK_gang2",4.1,1,1,1,1,1);
			default: SendClientMessage(playerid, YELLOW, "Usage: /gwalk [1/2]");
		}
    	return 1;
    }
    CMD:aim(playerid, params[])
    {
		if(!strlen(params))return SendClientMessage(playerid, YELLOW, "Usage: /aim [1-.]");
    	switch(params[0])
    	{
        	case '1': LoopAnimation(playerid,"PED","gang_gunstand",4.0,1,1,1,1,1);
        	case '2': LoopAnimation(playerid,"PED","Driveby_L",4.0,0,1,1,1,1);
        	case '3': LoopAnimation(playerid,"PED","Driveby_R",4.0,0,1,1,1,1);
        	default: SendClientMessage(playerid, YELLOW, "Usage: /aim [1-3]");
    	}
    	return 1;
    }
    CMD:lean(playerid, params[])
    {
        if(!strlen(params))return SendClientMessage(playerid, YELLOW, "Usage: /lean [1-2]");
    	switch(params[0])
    	{
        	case '1': LoopAnimation(playerid,"GANGS","leanIDLE",4.0,0,1,1,1,0);
        	case '2': LoopAnimation(playerid,"MISC","Plyrlean_loop",4.0,0,1,1,1,0);
        	default: SendClientMessage(playerid, YELLOW, "Usage: /lean [1-2]");
    	}
    	return 1;
    }
    CMD:run(playerid, params[])
    {
	    #pragma unused params
		LoopAnimation(playerid,"PED","sprint_civi",floatstr(params),1,1,1,1,1);
		printf("%f",floatstr(params));
    	return 1;
    }
    CMD:clear(playerid, params[])
	{
	    #pragma unused params
		ApplyAnimation(playerid, "CARRY", "crry_prtial", 1.0, 0, 0, 0, 0, 0);
		return 1;
    }
    CMD:strip(playerid, params[])
    {
    	switch(params[0])
    	{
        	case '1': LoopAnimation(playerid,"STRIP", "strip_A", 4.1, 1, 1, 1, 1, 1 );
        	case '2': LoopAnimation(playerid,"STRIP", "strip_B", 4.1, 1, 1, 1, 1, 1 );
        	case '3': LoopAnimation(playerid,"STRIP", "strip_C", 4.1, 1, 1, 1, 1, 1 );
        	case '4': LoopAnimation(playerid,"STRIP", "strip_D", 4.1, 1, 1, 1, 1, 1 );
        	case '5': LoopAnimation(playerid,"STRIP", "strip_E", 4.1, 1, 1, 1, 1, 1 );
        	case '6': LoopAnimation(playerid,"STRIP", "strip_F", 4.1, 1, 1, 1, 1, 1 );
        	case '7': LoopAnimation(playerid,"STRIP", "strip_G", 4.1, 1, 1, 1, 1, 1 );
        	default: SendClientMessage(playerid, YELLOW, "Usage: /strip [1-7]");
    	}
    	return 1;
    }
    CMD:inbedright(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"INT_HOUSE","BED_Loop_R",4.0,1,0,0,0,0);
		return 1;
    }
    CMD:inbedleft(playerid, params[])
	{
	    #pragma unused params
		LoopAnimation(playerid,"INT_HOUSE","BED_Loop_L",4.0,1,0,0,0,0);
		return 1;
    }
	CMD:dance(playerid, params[])
	{
    	switch(params[0])
    	{
			case '1': SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE1);
			case '2': SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE2);
			case '3': SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE3);
			case '4': SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE4);
			default: SendClientMessage(playerid,0xFF0000FF,"Usage: /dance [style 1-4]");
		}
 	  	return 1;
	}
	SingleAnimation(playerid, animlib[], animname[], Float:Speed, looping, lockx, locky, lockz, lp)
	{
		ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp, 1);
		bitTrue(bPlayerGameSettings[playerid], LoopingAnimation);
	}
	LoopAnimation(playerid, animlib[], animname[], Float:Speed, looping, lockx, locky, lockz, lp)
	{
		bitTrue(bPlayerGameSettings[playerid], LoopingAnimation);
	    ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp, 1);
	    TextDrawShowForPlayer(playerid, StopAnimText);
	}
	StopLoopAnimation(playerid)
	{
		bitFalse(bPlayerGameSettings[playerid], LoopingAnimation);
		ClearAnimations(playerid);
	    TextDrawHideForPlayer(playerid, StopAnimText);
	}


