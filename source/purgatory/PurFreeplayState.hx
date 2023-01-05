package purgatory;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.util.FlxStringUtil;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
#if desktop
import Discord.DiscordClient;
#end
using StringTools;
import WeekData;
import purgatory.PurWeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

class PurFreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var bg:FlxSprite = new FlxSprite(0).loadGraphic(PurMainMenuState.randomizeBG());

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	private var curChar:String = "unknown";

	public static var fart:Bool = false;
	public static var songsReady:Bool = false;

	private var InMainFreeplayState:Bool = false;
	private var isInMods:Bool = false;

	public var allowinputShit:Bool = true;

	private var CurrentSongIcon:FlxSprite;

	private var AllPossibleSongs:Array<String> = ["purgatory", "extrasandfanmades", "old", "joke", "mods"];

	private var CurrentPack:Int = 0;

	var loadingPack:Bool = false;

	var songColors:Array<FlxColor> = [
		0xFF0CB500, // purgatory stuff
		0xFFFF0D00, // purgatory stuff
		0xFF189429, // purgatory stuff
		0xFF24177D, // purgatory stuff
		0xFF420000, // purgatory stuff
		0xFFFFFFFF, // purgatory stuff
    ];

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		#if NO_PRELOAD_ALL
		if(!songsReady)
		{
			Assets.loadLibrary("songs").onComplete(function (_) {
				FlxTween.tween(black, {alpha: 0}, 0.5, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						remove(black);
						black.kill();
						black.destroy();
					}
				});
	
				songsReady = true;
			});
		}
		#else
		songsReady = true;
		#end

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		#if desktop
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end
		
		var isDebug:Bool = false;

		persistentUpdate = true;
		WeekData.reloadWeekFiles(false);

		#if debug
		isDebug = true;
		#end

		bg.loadGraphic(PurMainMenuState.randomizeBG());
		bg.color = 0xFF4965FF;
		add(bg);

		CurrentSongIcon = new FlxSprite(0,0).loadGraphic(Paths.image('week_icons_' + (AllPossibleSongs[CurrentPack].toLowerCase())));

		CurrentSongIcon.centerOffsets(false);
		CurrentSongIcon.x = (FlxG.width / 2) - 256;
		CurrentSongIcon.y = (FlxG.height / 2) - -605; // haxe is weird
		CurrentSongIcon.antialiasing = true;

		add(CurrentSongIcon);

		FlxTween.tween(CurrentSongIcon,{y: 50}, 1.4, {ease: FlxEase.expoInOut});

		isInMods = false;

		super.create();
	}

	public function LoadProperPack()
		{
			switch (AllPossibleSongs[CurrentPack].toLowerCase())
			{
				case 'purgatory':
					addWeek(['Shattered'], 1, ['bambiMad']);
					addWeek(['Supplanted'], 1, ['bambiRage']);
					addWeek(['Reality-Breaking'], 2, ['bambiGod2d']);
					addWeek(['Rebound', 'Disposition', 'Disposition_BUT_AWESOME', 'Upheaval-Teaser'], 2, ['bambiGod']);
					addWeek(['Upheaval'], 2, ['god-expunged-1']);
					addWeek(['Roundabout'], 3, ['dave']);
					addWeek(['Rascal'], 3, ['caillougetsgroundedforseventeenthousandyears']);
					addWeek(['Triple-Threat'], 3, ['uhmmm']);
					addWeek(['Callback'], 3, ['bandu']);
					addWeek(['Delivery'], 3, ['crusti']);
					addWeek(['Acquaintance'], 3, ['minion']);
					addWeek(["Beefin'"], 3, ['homo']);
					addWeek(['Technology'], 3, ['bombu']);
					addWeek(['Inventive'], 3, ['bombu']);
					addWeek(['Devastation'], 3, ['dagang']);
					addWeek(['Tyranny'], 4, ['dataexpunged']);
					addWeek(['Antagonism'], 4, ['ohfuck']);
				case 'extrasandfanmades':
					addWeek(['Fast-Food'], 2, ['homo']);
					addWeek(['bombu-x-bamburg-shipping-cute'], 2, ['homo']);
					addWeek(['Computer'], 2, ['bombu']);
					addWeek(['Instinct'], 2, ['bombu']);
					addWeek(['sunshine'], 2, ['bandu']);
					addWeek(['Reheated'], 2, ['crusti']);
					addWeek(['Body-Destroyer'], 3, ['bambi3dUnfair']);
					addWeek(['VOLATILE'], 4, ['dataexpunged']);
					addWeek(['Opposition'], 4, ['dataexpunged']);
					addWeek(['Velocity'], 3, ['decimated']);
					addWeek(['Malware'], 3, ['bombuExpunged']);
					addWeek(['Crimson-Corridor'], 3, ['bombuExpunged']);
					addWeek(['Inflorescence'], 2, ['bambiGod']);
					addWeek(['Antagonism-Poip-Part'], 3, ['minion']);
					addWeek(['Antagonism-Test'], 3, ['bambiPISSED']);
					addWeek(['Antagonism-Expunged'], 3, ['dataexpunged']);
					addWeek(['Deploration'], 3, ['expunged']);
					addWeek(['Dishonored'], 3, ['expunged']);
					//	#if !debug
				///	if(FlxG.save.data.idkFound)
				///	#end
				    	addWeek(['LACUNA'], 4, ['dataexpunged']);
					addWeek(['Disregard'], 3, ['the_trio']);
					addWeek(['Dethroned'], 4, ['dataexpunged']);
					addWeek(['Devastation-Fanmade'], 3, ['dagang']);
					addWeek(['Demise-PT-1'], 3, ['ohfuck']);
					addWeek(['Demise-PT-2'], 3, ['ohfuck']);
				case 'old':
					addWeek(['Fast-Food-Old'], 2, ['homo']);
					addWeek(['Balding'], 3, ['bambi-old']);
					addWeek(['Roundabout-Unused'], 3, ['dave']);
					addWeek(['Nylon'], 3, ['dave']);
					addWeek(['Antagonism-11-minutes'], 4, ['ohfuck']);
					addWeek(['New-Antagonism'], 4, ['ohfuck']);
				case 'joke':
					addWeek(['5 minutes'], 2, ['expunged']);
					addWeek(['Platonic'], 2, ['face']);
			    case 'mods':
					for (i in 0...WeekData.weeksList.length) {
						if(weekIsLocked(WeekData.weeksList[i])) continue;
			
						var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
						var leSongs:Array<String> = [];
						var leChars:Array<String> = [];
			
						for (j in 0...leWeek.songs.length)
						{
							leSongs.push(leWeek.songs[j][0]);
							leChars.push(leWeek.songs[j][1]);
						}
			
						WeekData.setDirectoryFromWeek(leWeek);
						for (song in leWeek.songs)
						{
							var colors:Array<Int> = song[2];
							if(colors == null || colors.length < 3)
							{
								colors = [146, 113, 253];
							}
							addSong(song[0], i, song[1]);
						}
					}
					bg.color = 0xFF4965FF;
					WeekData.loadTheFirstEnabledMod();
					isInMods = true;
			}
		}


	public function GoToActualFreeplay()
	{
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = false;
			songText.itemType = "D-Shape";
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("comic-sans.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.x = 20;
		scoreText.y = -60;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 1), 66, 0xFF000000);
		scoreBG.alpha = 0.5;
		scoreBG.screenCenter(X);
		scoreBG.y = -40;
		add(scoreBG);

		add(scoreText);

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		#if (PRELOAD_ALL && android)
	    	var leText:String = "Press X to listen to the Song / Press C to open the Gameplay Changers Menu / Press Y to Reset your Score and Accuracy.";
		#elseif (PRELOAD_ALL)
	    	var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		#elseif android
	    	var leText:String = "Press C to open the Gameplay Changers Menu / Press Y to Reset your Score and Accuracy."
 		#else 
	    	var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		#end
		var text:FlxText = new FlxText(textBG.x + -10, textBG.y + 3, FlxG.width, leText, 21);
		text.setFormat(Paths.font("comic-sans.ttf"), 18, FlxColor.WHITE, LEFT);
		text.scrollFactor.set();
		add(text);
		
		#if android
		addVirtualPad(FULL, A_B_C_X_Y);
		#end

		FlxTween.tween(scoreBG,{y: 25},0.5,{ease: FlxEase.expoInOut});
		FlxTween.tween(scoreText,{y: 20},0.5,{ease: FlxEase.expoInOut});

		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public function UpdatePackSelection(change:Int)
	{
		CurrentPack += change;
		if (CurrentPack == -1)
		{
			CurrentPack = AllPossibleSongs.length - 1;
		}
		if (CurrentPack == AllPossibleSongs.length)
		{
			CurrentPack = 0;
		}
		CurrentSongIcon.loadGraphic(Paths.image('week_icons_' + (AllPossibleSongs[CurrentPack].toLowerCase())));
	}

	override function beatHit()
	{
		super.beatHit();
		FlxTween.tween(FlxG.camera, {zoom:1.05}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(fart) allowinputShit = true;

		if (!InMainFreeplayState) 
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				UpdatePackSelection(-1);
			}
			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				UpdatePackSelection(1);
			}
			if (controls.ACCEPT && !loadingPack)
			{
				loadingPack = true;
				LoadProperPack();
				FlxTween.tween(CurrentSongIcon, {alpha: 0}, 0.3);
				new FlxTimer().start(0.5, function(Dumbshit:FlxTimer)
				{
					CurrentSongIcon.visible = false;
					GoToActualFreeplay();
					InMainFreeplayState = true;
					loadingPack = false;
				});
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new PurMainMenuState());
			}
		
			return;
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + Math.floor(lerpRating * 100) + '%)';


		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		var shift = FlxG.keys.pressed.SHIFT;
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE #if android || _virtualpad.buttonX.justPressed #end;
		var ctrl = FlxG.keys.justPressed.CONTROL #if android || _virtualpad.buttonC.justPressed #end;
	//	var fuckyou = FlxG.keys.justPressed.SEVEN;

		if(songsReady)
		{
			if(-1 * Math.floor(FlxG.mouse.wheel) != 0)
				changeSelection(-1 * Math.floor(FlxG.mouse.wheel));
		}

		if (upP && allowinputShit)
		{
			changeSelection(-1);
		}
		if (downP && allowinputShit)
		{
			changeSelection(1);
		}
		
		if (controls.UI_LEFT_P && allowinputShit)
			changeDiff(-1);
		if (controls.UI_RIGHT_P && allowinputShit)
			changeDiff(1);

		if (controls.BACK && allowinputShit)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new PurFreeplayState());
	
			if (accepted && allowinputShit)
			{
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			
				trace(poop);
			

				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isPurStoryMode = false;
				PlayState.isFreeplayPur = true;
				PlayState.isStoryMode = false;
				PlayState.isFreeplay = false;
				PlayState.storyDifficulty = curDifficulty;

				PlayState.storyWeek = songs[curSelected].week;
				LoadingState.loadAndSwitchState(new CharacterSelectState());
			}
		}
    /*	if (fuckyou)
		{
			FlxG.sound.music.volume = 0;
			PlayState.SONG = Song.loadFromJson("ok-hard", "ok"); // you dun fucked up again
			FlxG.save.data.idkFound = true;
			PlayState.isPurStoryMode = true;
			
			new FlxTimer().start(0.25, function(tmr:FlxTimer)
			{
			LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
				PurFreeplayState.destroyFreeplayVocals();
			});
		}*/
		if(ctrl)
		{
			openSubState(new GameplayChangersSubstate());
			allowinputShit = false;
			fart = false;
		}
	#if PRELOAD_ALL
	if(space && instPlaying != curSelected)
	{
		destroyFreeplayVocals();
		Paths.currentModDirectory = songs[curSelected].folder;
		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
		PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
		if (PlayState.SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
		vocals.play();
		vocals.persist = true;
		vocals.looped = true;
		vocals.volume = 0.7;
		instPlaying = curSelected;
	}
	else #end if (accepted && allowinputShit)
	{
		var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
		#if MODS_ALLOWED
		if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
		#else
		if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
		#end
			poop = songLowercase;
			curDifficulty = 1;
			trace('Couldnt find file');
		}
		trace(poop);

		PlayState.SONG = Song.loadFromJson(poop, songLowercase);
		PlayState.isPurStoryMode = false;
		PlayState.isFreeplayPur = true;
		PlayState.isStoryMode = false;
		PlayState.isFreeplay = false;

		PlayState.storyDifficulty = curDifficulty;

		PlayState.storyWeek = songs[curSelected].week;
		trace('CURRENT WEEK: ' + PurWeekData.getWeekFileName());
		CharacterSelectionState.characterFile = 'bf';
		CharacterSelectionState.scoreMultipliers = [1, 1, 1, 1];
		LoadingState.loadAndSwitchState(new CharacterSelectionState());

		FlxG.sound.music.volume = 0;
				
		destroyFreeplayVocals();
	}
	else if(controls.RESET #if android || _virtualpad.buttonY.justPressed #end)
	{
		openSubState(new PurResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
		FlxG.sound.play(Paths.sound('scrollMenu'));
		allowinputShit = false;
		fart = false;
	}
	super.update(elapsed);
}

public static function destroyFreeplayVocals() {
	if(vocals != null) {
		vocals.stop();
		vocals.destroy();
	}
	vocals = null;
}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 2)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 2;
		
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end
	
		PlayState.storyDifficulty = curDifficulty;
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;

		if (curSelected >= songs.length)
			curSelected = 0;

		if (songs[curSelected].week != 1 || songs[curSelected].songName == 'Old-Insanity')
		{
			if (curDifficulty < 2)
				curDifficulty = 2;

			if (curDifficulty > 2)
				curDifficulty = 2;
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		changeDiff();
		if(!isInMods) {
			FlxTween.color(bg, 0.25, bg.color, songColors[songs[curSelected].week]);
	   }
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
