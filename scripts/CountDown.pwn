static Timer:CountDownTimer;

new Text:CountdownText = INVALID_TEXT_DRAW;

StartCountdown(m, s)
{
	if(s > 60)s = 60;

	gCountMinute = m;
	gCountSecond = s;

	CountDownTimer = repeat CountDownTick();
}
timer CountDownTick[1000]()
{
	new
		timeStr[16];

    format(timeStr, 16, "%02d:%02d", gCountMinute, gCountSecond);

    TextDrawSetString(CountdownText, timeStr);
    TextDrawShowForAll(CountdownText);

	if(gCountMinute != 0 && gCountSecond == 0)
	{
		gCountMinute--;
		gCountSecond = 60;
	}

	if(gCountMinute == 0 && gCountSecond==0)
		StopCountdown();

	else
		gCountSecond--;
}
StopCountdown()
{
    TextDrawHideForAll(CountdownText);

	if(gCountMinute == 0 && gCountSecond == 0)
	{
		GameTextForAll("~r~GO!", 3000, 5);

		if(gCurrentChallenge != CHALLENGE_NONE)
			ch_Stop(-1);
	}

	gCountMinute = 0;
	gCountSecond = 0;

	stop CountDownTimer;

	return 1;
}
