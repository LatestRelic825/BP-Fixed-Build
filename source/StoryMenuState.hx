package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import WeekData;

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	var gameplayModifierTxt:FlxText;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true];

	private static var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var yellowBG:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;
	var txtTrackdeco:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var weeks:Array<Week> = [
		new Week(['Warmup'], 'Dave’s Funkin Class', 0xFF8A42B7, 'warmup'),  // WARMUP
		new Week(['House', 'Insanity', 'Polygonized'], 'Dave’s Fun Rapping Battle!', 0xFF4965FF, 'DaveHouse'), // DAVE
		new Week(['Blocked', 'Corn-Theft', 'Maze'], 'Mr. Bambi’s Fun Corn Maze!', 0xFF00B515, 'bamboi'), // MISTER BAMBI RETARD
		new Week(['Splitathon'], 'The Finale', 0xFF00FFFF, 'splitathon'), // SPLIT THE THONNNNN
		new Week(['Shredder', 'Greetings', 'Interdimensional', 'Rano'], 'Bambi’s Corn Festival!', 0xFF800080, 'festival'), // FESTEVAL
	];

	var awaitingExploitation:Bool;
	static var awaitingToPlayMasterWeek:Bool;

	var weekBanners:Array<FlxSprite> = new Array<FlxSprite>();
	var lastSelectedWeek:Int = 0;

	var songColors:Array<FlxColor> = [
        0xFF8A42B7, // GF
		0xFF4965FF, // DAVE
		0xFF00B515, // STUPID MR BAMBI
		0xFF00FFFF, //SPLIT THE THONNNNN
		0xFF800080,	//el pepe
		0xFFFF0000,	//purgatory 2
		0xFFFF0000	//purgatory threeb cvbbccbvcbv
    ];

	override function create()
	{
		awaitingExploitation = (FlxG.save.data.exploitationState == 'awaiting');

		if (FlxG.save.data.masterWeekUnlocked)
		{
			var weekName = !FlxG.save.data.hasPlayedMasterWeek ? '?????????' : 'Bambi’s Master Week!';
			weeks.push(new Week(
				['Supernovae', 'Glitch', 'Master'], weekName, 0xFF116E1C, 
				FlxG.save.data.hasPlayedMasterWeek ? 'masterweek' : 'masterweekquestion'));  // MASTERA BAMBI
		}

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		gameplayModifierTxt = new FlxText(10, 690, 0, 'Press CTRL to open the Gameplay Modifier Menu', 18);
		gameplayModifierTxt.setFormat("Comic Sans MS Bold", 18, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		gameplayModifierTxt.borderSize = 1.5;
		gameplayModifierTxt.antialiasing = true;
		gameplayModifierTxt.scrollFactor.set();

		scoreText = new FlxText(10, 0, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("Comic Sans MS Bold", 32);
		scoreText.antialiasing = true;

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 0, 0, "", 32);
		txtWeekTitle.setFormat("Comic Sans MS Bold", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.antialiasing = true;
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("comic.ttf"), 32);
		rankText.antialiasing = true;
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width * 2, 400, FlxColor.WHITE);
		yellowBG.color = weeks[0].weekColor;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 57, FlxColor.BLACK);
		add(blackBarThingie);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...weeks.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 80, i);
			weekThing.x += ((weekThing.width + 20) * i);
			weekThing.targetX = i;
			weekThing.antialiasing = true;
			grpWeekText.add(weekThing);

			// weekThing.updateHitbox();

			// Needs an offset thingie
		}

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));

		add(yellowBG);

		txtTrackdeco = new FlxText(0, yellowBG.x + yellowBG.height + 50, FlxG.width, 'Tracks', 28);
		txtTrackdeco.alignment = CENTER;
		txtTrackdeco.font = rankText.font;
		txtTrackdeco.color = 0xFFe55777;
		txtTrackdeco.antialiasing = true;
		txtTrackdeco.screenCenter(X);

		txtTracklist = new FlxText(0, yellowBG.x + yellowBG.height + 80, FlxG.width, '', 28);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		txtTracklist.antialiasing = true;
		txtTracklist.screenCenter(X);
		add(txtTrackdeco);
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);
		add(gameplayModifierTxt);

		for (i in 0...weeks.length)
		{
			var weekBanner:FlxSprite = new FlxSprite(600, 56).loadGraphic(Paths.image('weekBanners/${weeks[i].bannerName}'));
			weekBanner.antialiasing = false;
			weekBanner.active = true;
			weekBanner.screenCenter(X);
			weekBanner.alpha = i == curWeek ? 1 : 0;
			add(weekBanner);

			weekBanners.push(weekBanner);
		}

		updateText();
		
		if (awaitingToPlayMasterWeek)
		{
			awaitingToPlayMasterWeek = false;
			changeWeek(5 - curWeek);
		}
		else
		{
			changeWeek(0);
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;
		txtWeekTitle.text = weeks[curWeek].weekName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UI_LEFT_P)
				{
					changeWeek(-1);
				}

				if (controls.UI_RIGHT_P)
				{
					changeWeek(1);
				}
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}
		if (FlxG.keys.justPressed.SEVEN && !FlxG.save.data.masterWeekUnlocked)
		{
			FlxG.sound.music.fadeOut(1, 0);
			FlxG.camera.shake(0.02, 5.1);
			FlxG.camera.fade(FlxColor.WHITE, 5.05, false, function()
			{
				FlxG.save.data.masterWeekUnlocked = true;
				FlxG.save.data.hasPlayedMasterWeek = false;
				awaitingToPlayMasterWeek = true;
				FlxG.save.flush();

				FlxG.resetState();
			});
			FlxG.sound.play(Paths.sound('doom'));
		}
		if(FlxG.keys.justPressed.CONTROL)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if(ClientPrefs.flashing) grpWeekText.members[curWeek].startFlashing();
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = weeks[curWeek].songList;
			PlayState.isStoryMode = true;
			PlayState.isFreeplay = false;
			PlayState.isFreeplayPur = false;
			PlayState.isPurStoryMode = false;
			selectedWeek = true;

			/*var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
			if(diffic == null) diffic = '';*/
			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{				
				switch (PlayState.storyWeek)
				{
					case 1:
						FlxG.sound.music.stop();
						var video:MP4Handler = new MP4Handler();
						video.finishCallback = function()
						{
							LoadingState.loadAndSwitchState(new PlayState(), true);
						}
						video.playVideo(Paths.video('daveCutscene'));
					case 5:
						if (!FlxG.save.data.hasPlayedMasterWeek)
						{
							FlxG.save.data.hasPlayedMasterWeek = true;
							FlxG.save.flush();
						}
						LoadingState.loadAndSwitchState(new PlayState(), true);
					default:
						LoadingState.loadAndSwitchState(new PlayState(), true);
				}
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length-1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;
		else
		{
			if (curDifficulty < 0)
				curDifficulty = 2;
			if (curDifficulty > 2)
				curDifficulty = 0;
		}
		if (curWeek == 3)
		{
			curDifficulty = 3;
		}
		if (curWeek == 4 || curWeek == 5 || curWeek == 6 || curWeek == 7 || curWeek == 8)
		{
			curDifficulty = 2;
		}

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		lastSelectedWeek = curWeek;
		curWeek += change;

		if (curWeek > weeks.length - 1)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weeks.length - 1;
		if (curWeek == 3)
			{
				curDifficulty = 3;
			}
		if (curWeek == 0 || curWeek == 1 || curWeek == 2 || curWeek == 4 || curWeek == 5) //updates the difficulty sprite when changing the week
			{
				curDifficulty = 2;
			}

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetX = bullShit - curWeek;
			if (item.targetX == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxTween.color(yellowBG, 0.25, yellowBG.color, weeks[curWeek].weekColor);

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
		updateWeekBanner();
	}

	function updateWeekBanner()
	{
		for (i in 0...weekBanners.length)
		{
			if (![lastSelectedWeek, curWeek].contains(i))
			{
				weekBanners[i].alpha = 0;
			}
		}
		FlxTween.tween(weekBanners[lastSelectedWeek], {alpha: 0}, 0.1);
		FlxTween.tween(weekBanners[curWeek], {alpha: 1}, 0.1);
	}

	function weekIsLocked(weekNum:Int) {
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		txtTracklist.text = "";

		var stringThing:Array<String> = weeks[curWeek].songList;

		if (curWeek == 5 && !FlxG.save.data.hasPlayedMasterWeek)
		{
			stringThing = ['???', '???', '???'];
		}

		for (i in stringThing)
		{
			//txtTracklist.text += " - " + i;

		}

		txtTracklist.text = stringThing.join(' - ');

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}
}
class Week
{
	public var songList:Array<String>;
	public var weekName:String;
	public var weekColor:FlxColor;
	public var bannerName:String;

	public function new(songList:Array<String>, weekName:String, weekColor:FlxColor, bannerName:String)
	{
		this.songList = songList;
		this.weekName = weekName;
		this.weekColor = weekColor;
		this.bannerName = bannerName;
	}
} 