#include <a_samp>
#include <colours>
#include <sscanf2>
#include <zcmd>
#include <strlib>
/*
Movies - liked
	Old school
		In the movie Old School what was that man thinking going steaking at night!
	Shaun Of the dead
		I love at the end where shauns friend is a zombie but the still play on the playstation!
	Toy story 3
		I laughed at spanish buzz!

Movies - disliked

TV shows - liked
	family guy
	american dad
	south park
	my name is earl
	two and a half men
	how i met your mother
	simpsons
	
TV shows - disliked
	hannah montanna

Music - liked
	foo fighters
	guns n roses
	bob dylan
	nirvana
	feeder
	niel young
	led zeppelin
	biffy clyro
	avenged sevenfold
	system of a down
	metallica
	lynyrd skynyrd
	black sabbath
	
Music - disliked
	justin bieber
	rihanna
	eminem
	miley cyrus
	tinchy stryder
	usher
	s-club seven
	take that
	willow smith
	Tinie Tempah
	mcfly
	n-dubz
	the wanted
	JLS
	cheryl cole

Musicians - liked
	dave grohl
	kurt cobain
	bob dylan
	neil young
	newton faulkner

Musicians - disliked
	justin bieber
	miley cyrus


Games - liked
	sa-mp
	grand theft auto
	burnout
	battlefield
	fallout
	uncharted
	assassins creed
	little big planet
	


Games - disliked
	call of duty

Activities - liked
Activities - disliked



*/

#define QUESTION_WHO	(0)
#define QUESTION_WHAT	(1)
#define QUESTION_WHEN	(2)
#define QUESTION_WHERE	(3)
#define QUESTION_HOW	(4)
#define QUESTION_WHICH	(5)

/*
j jokey
i intellectual
d deeper description
s sad
c cant be bothered to explain
*/

new SteveText[10][64]=
{
	{"bite me."},
	{"yeah whatever mate"},
	{"who said my name?"},
	{"how about you shut up",},
	{"stop talking about me!"},
	{"i like Cheese! :P"},
	{"who Likes Spadge?"},
	{"what you talkin bout fool?"},
	{"haha, you're an idiot"},
	{"and.....?"}
},
gSteveChatTimer,
gSteveChatText[128],
gSteveLastSubject[32];

public OnPlayerText(playerid, text[])
{
	if(strfind(text, "steve", true) != -1)
	{
	    new
			words[16][16],
			wordcount,
			qpos,
			qtype;

		strtrim(text, ",.!?");
	    wordcount = strexplode(words, text, " ");

		GetQuestionWord(words, wordcount, qpos, qtype);

	    if(qtype != -1)
	    {
			if(qtype == QUESTION_WHO)
			{
			}
			if(qtype == QUESTION_WHAT)
			{
			    new
					str[64];

				GetQuestionSubject(words, wordcount, qpos, qtype);
				if(qpos != -1)
				{
				    if(!strcmp(words[qpos], "you"))
					{
						SendSteveChat(WhatAmI());
				    }
				    else if(WordFileExists(words[qpos]))
				    {
				        new reply[128];
				        GetWordFileData(words[qpos], 'j', reply);
				        SendSteveChat(reply);
				    }
				    else
				    {
			    		format(str, 64, "I don't know what %s is", words[qpos]);
			    		SendSteveChat(str);
			    		gSteveLastSubject = words[qpos];
			    	}
			    }
			}
			if(qtype == QUESTION_WHEN)
			{
			}
			if(qtype == QUESTION_WHERE)
			{
			}
			if(qtype == QUESTION_HOW)
			{
			}
			if(qtype == QUESTION_WHICH)
			{
			}
	    }
	    else
		{
		    new spos;
		    GetPrevSubj(words, wordcount, spos);
		    if(spos != -1)
		    {
		        if(!strcmp(words[spos+1], "is", true))
		        {
		            new str[128];
		            format(str, 128, "So %s is %s", gSteveLastSubject, words[spos+2]);
		            SendSteveChat(str);
		        }
				if(!strcmp(words[spos+1], "are", true))
		        {
		            new str[128];
		            format(str, 128, "So %s are %s", gSteveLastSubject, words[spos+2]);
		            SendSteveChat(str);
		        }
		    }
			else SendSteveChat(SteveText[random(sizeof(SteveText))]);
		}
	}
	return 1;
}

SendSteveChat(text[])
{
	new time = floatround(strlen(text)*50);

	KillTimer(gSteveChatTimer);
	format(gSteveChatText, 128, text);
	gSteveChatTimer = SetTimer("SteveTalk", time, false);

	return 1;
}

forward SteveTalk();
public SteveTalk()
{
	new str[128];
	format(str, 128, "(-1) {FFFF00}Steve{FFFFFF}: %s", gSteveChatText);
	SendClientMessageToAll(0xFFFFFFFF, str);
	printf("[chat] [Steve]: %s", gSteveChatText);
	return 1;
}

new QuestionWords[6][16]=
{
	"who",
	"what",
	"when",
	"where",
	"how",
	"which"
};
GetQuestionWord(words[][], len, &pos, &type)
{
	new
		i;

	while(i<len)
	{
	    for(new j;j<sizeof(QuestionWords);j++)
	    {
			if(!strcmp(words[i], QuestionWords[j], true))
			{
			    pos = i;
				type = j;
				return;
			}
		}
		i++;
	}
	pos = -1;
	type = -1;
	return;
}
GetQuestionSubject(words[][], len, &pos, type)
{
	if(type == QUESTION_WHAT)
	{
		new
			i,
			foundconnective;

		while(i<len)
		{
			if(!foundconnective && (!strcmp(words[i], "is", true, 2) || !strcmp(words[i], "are", true, 3)) )
			{
				pos = i+1;
				return;
			}
			i++;
		}
	}
	pos = -1;
	return;
}
GetPrevSubj(words[][], len, &pos)
{
	new
	    i;

	while(i<len)
	{
	    if(!strcmp(words[i], gSteveLastSubject, true))
	    {
	        pos = i;
	        return;
	    }
	    i++;
	}
	pos = -1;
	return;
}

WordFileExists(word[])
{
	new
		filename[64];

	filename = "Steve/";
	strcat(filename, word);

	return fexist(filename);
}
GetWordFileData(word[], mood, output[])
{
	new
		filename[64],
		File:file;

	filename = "Steve/";
	strcat(filename, word);

	file=fopen(filename, io_read);
	while(fread(file, output, 128))
	{
	    if(output[0] == mood)
		{
			strdel(output, 0, 2);
			break;
		}
	}
	fclose(file);
}


WhatAmI()
{
	new str[32];
	str = "I'm not really sure yet...";
	return str;
}
/*
	sAnswers[2][6][6]=
	{
	    // Positive
		{
			"yes",
			"yeah",
			"yeh",
			"yh",
			"ok",
			"okay"
		},
		// Negative
		{
			"no",
			"na",
			"false",
			"not",
			"nah",
			"noes"
		}
	},
	sVerbs[2][][64]=
	{
	    {
			"good",
		},
	    {
			"bad",
		}
	}
*/



CMD:steve(playerid, params[])
{
	new name[24];
	GetPlayerName(playerid, name, 24);
	if(!strcmp(name, "[HLF]Southclaw"))
	{
		if(strval(params)<1)return SendClientMessage(playerid, YELLOW, "Usage: /steve [phrase]");
		else
		{
			format(gSteveChatText, 128, params);
			SteveTalk();
		}
	}
	else return 0;
	return 1;
}

