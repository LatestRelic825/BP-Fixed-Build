package;

import CharacterSelectionState.CharacterUnlockObject;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import Shaders.PulseEffect;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxRandom;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import flixel.system.debug.Window;
import openfl.filters.BitmapFilter;
#if windows
import openfl.filters.ShaderFilter;
#end
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import lime.tools.ApplicationData;
import purgatory.PurFreeplayState;
import purgatory.PurWeekData;
import purgatory.NewStoryPurgatory;
import trolling.SusState;
import trolling.CheaterState;
import trolling.YouCheatedSomeoneIsComing;
import trolling.CrasherState;
import Shaders;
import Conductor.Rating;
import Note.EventNote;
#if sys
import sys.FileSystem;
#end

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if windows
import sys.io.File;
import sys.io.Process;
import lime.app.Application;
#end

import flixel.system.debug.Window;
import lime.app.Application;
import openfl.Lib;
import openfl.geom.Matrix;
import lime.ui.Window;
import openfl.geom.Rectangle;
import openfl.display.Sprite;

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['D', 0.6], //From 0% to 59%
		['C', 0.7], //From 60% to 69%
		['B', 0.8], //From 70% to 79%
		['A', 0.85], //From 80% to 84%
		['A.', 0.9], //From 85% to 89%
		['A:', 0.93], //From 90% to 92%
		['AA', 0.9650], //From 93% to 96.49%
		['AA.', 0.99], //From 96.50% to 98%
		['AA:', 0.9970], //from 99 to 99.69%
		['AAA', 0.9980], //From 99.70% to 99.79%
		['AAA.', 0.9990], //From 99.80 to 99.89%
		['AAA:', 0.99955], //From 99.90% to 99.954%
		['AAAA', 0.99970], //From 99.954% to 99.969%
		['AAAA.', 0.99980], //From 99.970% to 99.979%
		['AAAA:', 0.999935], //From 99.80% to 99.9934%
		['AAAAA', 1], //from 99.9935 to 100%
		['AAAAA', 1] //The value on this one isn't used actually, since Perfect is always "1" // your m
	];
	public static var ratingStuffPsych:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();

	public var shader_chromatic_abberation:ChromaticAberrationEffect;
	public var scanline_shader:ScanlineEffect;
	public var grain_shader:GrainEffect;
	public var vcr_shader:VCRDistortionEffect;
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];
	public var camOtherShaders:Array<ShaderEffect> = [];
	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public var shaderUpdates:Array<Float->Void> = [];
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var is3DStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var isPurStoryMode:Bool = false;
	public static var isFreeplayPur:Bool = false;
	public static var isFreeplay:Bool = false;
	public static var isModded:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var curbg:FlxSprite;
	public var screenshader:Shaders.PulseEffect = new PulseEffect();
	//public var screenshader:ShadersHandler.ChromaticAberration = new ChromaticAberration();
	public var UsingNewCam:Bool = false;

	//public var sex:Bool = true; //no more sex

	//reality breaking stuff for shaders lol
	var doneloll:Bool = false;
	var doneloll2:Bool = false;
	var stupidInt:Int = 0;
	var stupidBool:Bool = false;
	//ends here

	public var elapsedtime:Float = 0;

	public var elapsedexpungedtime:Float = 0;

	private var swagSpeed:Float;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var dad2:Character = null;
	public var dad3:Character = null;
	public var gf:Character = null;
	public var dave:Character = null;
	public var bambi:Character = null;
	public var badai:Character = null;
	public var bandu:Character = null;
	public var bamburg:Character = null;
	private var swaggy:Character = null;
	private var swagBombu:Character = null;
	public var boyfriend:Boyfriend = null;
	public var boyfriend2:Character = null;
	private var littleIdiot:Character = null;
	public var stupidThing:Boyfriend = null;

	private var altSong:SwagSong;

	public var subtitleManager:SubtitleManager;

	public var stupidx:Float = 0;
	public var stupidy:Float = 0; // stupid velocities for cutscene
	public var updatevels:Bool = false;

	var isDadGlobal:Bool = true;

	var funnyFloatyBoys:Array<String> = ['dave-3d', 'trueexpunged', 'crimson-dave', 'dave-3d-new', 'poip', 'dave-splitathon-3d', 'exosphere', 'upheaval_bambi', 'but-awesome', 'bambi-3d', 'bambi-unfair', 'minion', 'expunged', 'ripple_dude', 'expunged-new', 'decimated', 'crusti', 'crusturn', 'baiburg', 'baiburgascend', 'baiburgburger1', 'baiburgburger2', 'baiburgburger3', 'baiburgburger4', 'baiburgchoking', 'baiburgeating', 'bambi-piss-3d', 'bambi-scaryooo', 'bambi-god', 'bambi-god2d', 'bambi-god2d-24fps', 'bambi-hell', 'bombu', 'bombu-expunged', 'badai', 'gary', 'bamburg', 'bamburg-player', 'bombai'];
	var funnyBanduFloaty:Array<String> = ['bandu'];
	var funnySideFloatyBoys:Array<String> = ['bombu', 'bombu-expunged', 'bombai'];
	var canSlide:Bool = true;
	
	var dontDarkenChar:Array<String> = ['bambi-god', 'bambi-god2d', 'bambi-god2d-24fps', 'baiburgascend'];

	var isNewCam:Array<String> = ['corn-theft', 'maze', 'polygonized', 'splitathon', 'mealie', 'furiosity', 'cheating', 'unfairness', 'pp1', 'pp2', 'pp3', 'pp4', 'pp5', 'pp6', 'pp7', 'pp8', 'old-house', 'old-insanity', 'old-furiosity', 'old-blocked', 'old-corn-theft', 'old-maze', 'beta-maze', 'old-splitathon'];
	// this is for the modded songs to not move the cameras by default if the guy who added it didnt want to do that when using the default vs dave stages 

	var dontMiddle:Array<String> = ['cheating', 'disposition', 'despair', 'devastation-fanmade']; // dont middlescroll (this makes the arrows not go offscreen with middlescroll unless u manage to force the game to 999 fps LOL)

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var altNotes:FlxTypedGroup<Note>; 
	private var altUnspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var altStrumLine:FlxSprite;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	var nightColor:FlxColor = 0xFF878787;
	public var sunsetColor:FlxColor = FlxColor.fromRGB(255, 143, 178);

	private var STUPDVARIABLETHATSHOULDNTBENEEDED:FlxSprite;

	public static var eyesoreson = true;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	private var poopStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var charactersSpeed:Int = 2;
	public var health:Float = 1;
	public var combo:Int = 0;
	public var comboMax:Int = 0;
	var sectionComboBreaks:Bool = false;
	var sectionHits:Bool = false;

	var healthTweenObj:FlxTween;

	var glitch:FlxSprite;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	public var healthBarOverlay:FlxSprite;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var danceBeatSnap:Int = 2;
	public var dadDanceSnap:Int = 2;

	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	public var hasBfDarkLevels:Array<String> = ['farmNight', 'houseNight', '3dScary', '3dRed', '3dScary', '3dFucked', 'houseroof'];
	public var hasBfSunsetLevels:Array<String> = ['farmSunset', 'houseSunset'];
	public var hasBfDarkerLevels:Array<String> = ['spooky'];

	public var ExpungedWindowCenterPos:FlxPoint = new FlxPoint(0,0);

	private var windowSteadyX:Float;

	private var shakeCam:Bool = false;
	private var shakeCamALT:Bool = false;

	private var fartt:Bool = false;
	private var fartt2:Bool = false;
	private var bALLS:Bool = false;

	private var daspinlmao:Bool = false;
	private var daleftspinlmao:Bool = false;

	private var oppositionMoment:Bool = false;

	private var bfSingYeah:Bool = false;
	private var dadSingYeah:Bool = false;

	private var camZoomSnap:Bool = false;
	private var camZoomHalfSnap:Bool = false;
	private var autoCamZoom:Bool = true;

	public var isNormalStart:Bool = true;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public var badaiTime:Bool = false;
	public var banduTime:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;
	var shartingTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var BAMBICUTSCENEICONHURHURHUR:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	public static var offsetTesting:Bool = false;

	var expungedBG:BGSprite;
	var preDadPos:FlxPoint = new FlxPoint();

	public static var window:Window;
	var expungedScroll = new Sprite();
	var expungedSpr = new Sprite();
	var windowProperties:Array<Dynamic> = new Array<Dynamic>();
	var expungedWindowMode:Bool = false;
	var expungedOffset:FlxPoint = new FlxPoint();
	var expungedMoving:Bool = true;
	var lastFrame:FlxFrame;

	var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var notesHitArray:Array<Date> = [];

	var swagCounter:Int = 0;

	var score:Int = 350;
	var freeplayScore:Int = 350;

	var scoreMultipliersThing:Array<Float> = [1, 1, 1, 1];

	var redSky:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/redsky'));
	var insanityRed:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/redsky_insanity'));
	//var redPlatform:FlxSprite = new FlxSprite(-275, 750).loadGraphic(Paths.image('dave/redPlatform')); // that never happened oops
	var backyardnight:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/backyardnight'));
	var backyard:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/backyard'));
	var poop:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/blank'));
	var soscaryishitmypants:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/ok'));
	var poopBG:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/3dFucked'));
	var whiteBG:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/lol'));
	var jeezBG:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/jeez_fr'));
	var poop2BG:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/3dFucked2'));
	var laptopBG:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/3dLaptop'));
	var blackBG:FlxSprite = new FlxSprite(-120, -120).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
	//var computer:FlxSprite;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var evilTrail:FlxTrail;

	var phillyLightsColors:Array<FlxColor>;
	var phillyWindow:BGSprite;
	var phillyStreet:BGSprite;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:FlxSprite;
	var phillyWindowEvent:BGSprite;
	var trainSound:FlxSound;

	var phillyGlowGradient:PhillyGlow.PhillyGlowGradient;
	var phillyGlowParticles:FlxTypedGroup<PhillyGlow.PhillyGlowParticle>;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;
	var devaExpunged:FlxSprite;
	var devaLaptop:FlxSprite;
	var devaDave:FlxSprite;
	var devaBurger:FlxSprite;
	var gridBG:FlxSprite;
	var bgHELL:BGSprite;
	var gridSine:Float = 0;
	var bgshitH:DepthSprite;
	var bgshitH2:DepthSprite;
	var cloudsH:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var whiteflash:FlxSprite;
	var blackScreen:FlxSprite;
	var blackScreen2:FlxSprite;
	var blackScreendeez:FlxSprite;
	var redGlow:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var arrowJunks:Array<Array<Float>> = [];

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var ghostMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var judgementCounter:FlxText;
	var scoreTxtTween:FlxTween;

	var creditsWatermark:FlxText;
	var songWatermark:FlxText;

	var ballsText:FlxText;
	var composersText:FlxText;

	public var redTunnel:FlxSprite;
	public var redTunnel2:FlxSprite;
	public var redBG:FlxSprite;
	public var purpleTunnel:FlxSprite;
	public var purpleBG:FlxSprite;

	public var thing:FlxSprite = new FlxSprite(0, 250);
	public var splitathonExpressionAdded:Bool = false;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var daveExpressionSplitathon:Character;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public static var theFunne:Bool = true;

	#if windows
	public var crazyBatch:String = "shutdown /r /t 0"; // this isnt actually getting used cuz i dont think gb allows it lmao
    #end

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	public var playbackRate(default, set):Float = 1;

	public static var previousScrollSpeedLmao:Float = 0;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var camFollowX:Int = 0;
    var camFollowY:Int = 0;
    var dadCamFollowX:Int = 0;
	var dadCamFollowY:Int = 0;

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	var canFloat:Bool = true;

	var stageName:String = '';

	var swagBG:FlxSprite;

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	var precacheList:Map<String, String> = new Map<String, String>();

	public var comboVisual:FlxSprite;

	override public function create()
	{
		if(ClientPrefs.freezeGame)
		{
			FlxG.autoPause = true;
		} 
		else
		{
			FlxG.autoPause = false;
		}
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		//Ratings

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		healthTweenObj = FlxTween.tween(this, {}, 0);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		if(isFreeplay || isFreeplayPur)
			{
				if(CharacterSelectionState.notBF)
					{
						SONG.player1 = CharacterSelectionState.characterFile;
						scoreMultipliersThing = CharacterSelectionState.scoreMultipliers;
					}
			}

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);
		#if windows
		shader_chromatic_abberation = new ChromaticAberrationEffect(0.0075); // i think this one was from psych itself?
		grain_shader = new GrainEffect(0.01, 0.05, true);
		vcr_shader = new VCRDistortionEffect(0.2, true, false, false);
		scanline_shader = new ScanlineEffect(false);
		#end

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('warmup');



		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		previousScrollSpeedLmao = SONG.speed;

		SONG.speed /= playbackRate;

		if (SONG.speed < 0)
			SONG.speed = 0;

		whiteflash = new FlxSprite(-100, -100).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 100), FlxColor.WHITE);
		whiteflash.scrollFactor.set();

		blackScreen = new FlxSprite(-215, -120).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
		blackScreen.scrollFactor.set();

		blackScreen2 = new FlxSprite(-215, -120).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
		blackScreen2.scrollFactor.set();

		blackScreendeez = new FlxSprite(-120, -120).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
		blackScreendeez.scrollFactor.set();
		blackScreendeez.alpha = 0;
		add(blackScreendeez);

		redGlow = new FlxSprite(-120, -120).loadGraphic(Paths.image('dave/redGlow'));
		redGlow.scrollFactor.set();
		redGlow.antialiasing = true;
		redGlow.active = true;
		redGlow.screenCenter();
		add(redGlow);
		redGlow.visible = false;

		#if desktop
		storyDifficultyText = '' + CoolUtil.difficultyStuff[storyDifficulty][0];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else if (isStoryMode)
		{
			detailsText = "Purgatory Story Mode: " + PurWeekData.getCurrentWeek().weekName;
		}

		if (isFreeplayPur || isFreeplay)
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				case 'house' | 'insanity' | 'supernovae' | 'warmup':
					curStage = 'houseDay';
				case 'old-house' | 'old-insanity':
					curStage = 'houseOlderDay';
				case 'bonus-song' | 'glitch':
					curStage = 'houseNight';
				case 'vs-dave-christmas':
					curStage = 'houseChristmas';
				case 'blocked' | 'corn-theft' | 'old-blocked' | 'old-corn-theft' | 'secret' | 'old-maze':
					curStage = 'farmDay';
				case 'maze' | 'old-maze' | 'beta-maze':
					curStage = 'farmSunset';
				case 'splitathon' | 'old-splitathon' | 'mealie' | 'supplanted' | 'screwed':
					curStage = 'farmNight';
				case 'furiosity' | 'polygonized':
					curStage = '3dRed';
				case 'master':
					curStage = 'master';
				case 'exploitation':
					curStage = 'desktop';	
				case 'disposition' | 'disposition_but_awesome':
					curStage = 'bambersHell';
				case 'old-furiosity':
					curStage = 'oldRed';
				case 'cheating' | 'cheating b-side':
					curStage = 'green-void';
				case 'technology':
					curStage = '3dBombuboi';
				case 'unfairness' | 'unfairness-remix':
					curStage = '3dScary';
				case 'devastation':
					curStage = '3dDevastation';
				case 'antagonism-test':
					curStage = 'mostStages';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
				is3DStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		is3DStage = stageData.is3DStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'houseDay' | 'houseSunset' | 'houseNight': //Dave Week
			defaultCamZoom = 0.8;
				
				var skyType:String = '';
				var assetType:String = '';
				switch (curStage)
				{
					case 'houseDay':
						stageName = 'daveHouse';
						skyType = 'sky';
					case 'houseNight':
						stageName = 'daveHouse_night';
						skyType = 'sky_night';
						assetType = 'night/';
					case 'houseSunset':
						stageName = 'daveHouse_sunset';
						skyType = 'sky_sunset';
				}
				var bg:BGSprite = new BGSprite('backgrounds/shared/${skyType}', -600, -300, 0.6, 0.6);
				bg.updateHitbox();
				add(bg);
				
				var stageHills:BGSprite = new BGSprite('backgrounds/dave-house/${assetType}hills', -834, -159, 0.7, 0.7);
				stageHills.updateHitbox();
				add(stageHills);

				var grassbg:BGSprite = new BGSprite('backgrounds/dave-house/${assetType}grass bg', -1205, 580);
				grassbg.updateHitbox();
				add(grassbg);
	
				var gate:BGSprite = new BGSprite('backgrounds/dave-house/${assetType}gate', -755, 250);
				gate.updateHitbox();
				add(gate);
	
				var stageFront:BGSprite = new BGSprite('backgrounds/dave-house/${assetType}grass', -832, 505);
				stageFront.updateHitbox();
				add(stageFront);

				if (SONG.song.toLowerCase() == 'insanity')
				{
					var bg:BGSprite = new BGSprite('backgrounds/void/redsky_insanity', -600, -200, 1, 1);
					bg.alpha = 0.75;
					bg.visible = false;
					bg.active = true;
					add(bg);
					// below code assumes shaders are always enabled which is bad
					voidShader(bg);
				}

				var variantColor = getBackgroundColor(stageName);
				if (stageName != 'daveHouse_night')
				{
					stageHills.color = variantColor;
					grassbg.color = variantColor;
					gate.color = variantColor;
					stageFront.color = variantColor;
				}

			if (isNewCam.contains(SONG.song.toLowerCase())) {
				UsingNewCam = true;
			}

		case 'master':
			defaultCamZoom = 0.4;
			stageName = 'master';

			var space:BGSprite = new BGSprite('backgrounds/shared/sky_space', -1724, -971, 1.2, 1.2);
			space.setGraphicSize(Std.int(space.width * 10));
			space.antialiasing = false;
			space.updateHitbox();
			add(space);
	
			var land:BGSprite = new BGSprite('backgrounds/dave-house/land', 675, 555, 0.9, 0.9);
			land.updateHitbox();
			add(land);
		case 'desktop':
			defaultCamZoom = 0.5;
			stageName = 'desktop';

			expungedBG = new BGSprite('backgrounds/void/exploit/creepyRoom', -600, -600, 1, 1);
			expungedBG.setPosition(-1000, -700);
			expungedBG.setGraphicSize(Std.int(expungedBG.width * 1.25));
			expungedBG.scrollFactor.set();
			expungedBG.antialiasing = false;
			expungedBG.active = true;
			expungedBG.updateHitbox();
			add(expungedBG);
			if (ClientPrefs.waving){
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
			
				expungedBG.shader = testshader.shader;
				
				curbg = expungedBG;
			}

		case 'red-void' | 'green-void' | 'glitchy-void':
			defaultCamZoom = 0.7;

			var bg:BGSprite = new BGSprite('backgrounds/void/redsky', -600, -200, 1, 1);
			
			switch (curStage.toLowerCase())
			{
				case 'red-void':
					defaultCamZoom = 0.8;
					bg.loadGraphic(Paths.image('backgrounds/void/redsky'));
					bg.active = true;
					stageName = 'daveEvilHouse';
				case 'green-void':
					stageName = 'cheating';
					bg.loadGraphic(Paths.image('backgrounds/void/cheater'));
					bg.setPosition(-600, -300);
					bg.scrollFactor.set(0.6, 0.6);
					bg.active = true;
				case 'glitchy-void':
					bg.loadGraphic(Paths.image('backgrounds/void/scarybg'));
					bg.setPosition(0, 200);
					bg.setGraphicSize(Std.int(bg.width * 3));
					bg.active = true;
					stageName = 'unfairness';
			}
			bg.updateHitbox();
			add(bg);
			voidShader(bg);
		case 'houseroof': //SKIPPER WTF
	    	defaultCamZoom = 0.8;

			var bg:BGSprite = new BGSprite('dave/sky_night', -600, -200, 0.2, 0.2);
			add(bg);

			soscaryishitmypants.loadGraphic(Paths.image('dave/ok'));
		    soscaryishitmypants.antialiasing = true;
			soscaryishitmypants.scrollFactor.set(0.6, 0.6);
			soscaryishitmypants.active = true;
			soscaryishitmypants.visible = false;
			add(soscaryishitmypants);

			var grass:BGSprite = new BGSprite('dave/roof', -195, -105, 0.9, 0.9);
			grass.setGraphicSize(Std.int(grass.width * 1.5));
			grass.updateHitbox();
			add(grass);

			grass.color = 0xFF878787;

		case 'houseChristmas': //bab
	    	var bg:BGSprite = new BGSprite('dave/sky_night', -600, -200, 0.2, 0.2);
	     	add(bg);
	
        	var hills:BGSprite = new BGSprite('dave/Christmas/hills', -225, -125, 0.5, 0.5);
			hills.setGraphicSize(Std.int(hills.width * 1.25));
			hills.updateHitbox();
			add(hills);
	
			var gate:BGSprite = new BGSprite('dave/Christmas/gate', -226, -125, 0.9, 0.9);
			gate.setGraphicSize(Std.int(gate.width * 1.2));
			gate.updateHitbox();
			add(gate);
	
			var grass:BGSprite = new BGSprite('dave/Christmas/grass', -225, -125, 0.9, 0.9);
			grass.setGraphicSize(Std.int(grass.width * 1.2));
			grass.updateHitbox();
	    	add(grass);

		case 'houseOlderDay': //Older Dave Week
			var bg:BGSprite = new BGSprite('dave/davehouseback', -600, -200, 0.2, 0.2);
			add(bg);

			var davehouseceiling:BGSprite = new BGSprite('dave/davehouseceiling', -825, -125, 0.85, 0.85);
			davehouseceiling.setGraphicSize(Std.int(davehouseceiling.width * 1.25));
			davehouseceiling.updateHitbox();
			add(davehouseceiling);

			var davehousefloor:BGSprite = new BGSprite('dave/davehousefloor', -425, 625, 1.0, 1.0);
			davehousefloor.setGraphicSize(Std.int(davehousefloor.width * 1.3));
			davehousefloor.updateHitbox();
			add(davehousefloor);

			if (isNewCam.contains(SONG.song.toLowerCase())) {
	    		UsingNewCam = true;
			}

		case 'oldRed': 
			var bg:BGSprite = new BGSprite('dave/oldred', -600, -200, 0.9, 0.9);
			add(bg);

			UsingNewCam = true;

		case '3dRed':
			{
				defaultCamZoom = 0.85;
				curStage = '3dRed';

				redSky.loadGraphic(Paths.image('dave/redsky'));
				redSky.antialiasing = true;
				redSky.scrollFactor.set(0.6, 0.6);
				redSky.active = true;

				add(redSky);

				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				redSky.shader = testshader.shader;
				curbg = redSky;
				}

				//redPlatform.loadGraphic(Paths.image('dave/redPlatform'));
				//redPlatform.setGraphicSize(Std.int(redPlatform.width * 0.85));
				//redPlatform.updateHitbox();
				//redPlatform.antialiasing = true;
				//redPlatform.scrollFactor.set(1.0, 1.0);
				//redPlatform.active = true;
				//add(redPlatform);

				blackBG = new FlxSprite(-120, -120).makeGraphic(Std.int(FlxG.width * 100), Std.int(FlxG.height * 150), FlxColor.BLACK);
				blackBG.scrollFactor.set();
                blackBG.alpha = 0;
				add(blackBG);

				backyardnight.loadGraphic(Paths.image('dave/backyardnight'));
				backyardnight.antialiasing = true;
				backyardnight.scrollFactor.set(0.6, 0.6);
				backyardnight.active = true;
				backyardnight.visible = false;
				add(backyardnight);

				if (isNewCam.contains(SONG.song.toLowerCase())) {
			    	UsingNewCam = true;
				}
			}

		case '3dPissed':
			{
				defaultCamZoom = 0.85;
				curStage = '3dPissed';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/disrupted'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
				}
			}

		case '3dGreen':
			{
				defaultCamZoom = 0.85;
				curStage = '3dGreen';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/cheater'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
				}

				if (isNewCam.contains(SONG.song.toLowerCase())) {
		    		UsingNewCam = true;
				}
			}

		case 'mostStages':
			{
				defaultCamZoom = 0.5;
				curStage = 'mostStages';
				poopBG.loadGraphic(Paths.image('dave/3dFucked'));
				poopBG.antialiasing = true;
				poopBG.setGraphicSize(Std.int(poopBG.width * 1.8));
				poopBG.antialiasing = true;
				poopBG.scrollFactor.set(0.4, 0.4);
				poopBG.active = true;
				add(poopBG);

				poop2BG.loadGraphic(Paths.image('dave/3dFucked2'));
				poop2BG.antialiasing = true;
				poop2BG.setGraphicSize(Std.int(poop2BG.width * 3.4));
				poop2BG.antialiasing = true;
				poop2BG.scrollFactor.set(0.4, 0.4);
				poop2BG.active = false;
				poop2BG.visible = false;
				add(poop2BG);

				redBG = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/redTunnelBG'));
				redBG.setGraphicSize(Std.int(redBG.width * 1.15));
				redBG.updateHitbox();
				redBG.active = false;
				redBG.visible = false;
				add(redBG);

				redTunnel = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/redTunnel'));
				redTunnel.setGraphicSize(Std.int(redTunnel.width * 1.15));
				redTunnel.updateHitbox();
				redTunnel.active = false;
				redTunnel.visible = false;
				add(redTunnel);

				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				poopBG.shader = testshader.shader;
				curbg = poopBG;
				}
			}

		case '3dDisruption':
			{
				defaultCamZoom = 0.85;
				curStage = '3dDisruption';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/disruptor'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
				}

				if (isNewCam.contains(SONG.song.toLowerCase())) {
		    		UsingNewCam = true;
				}
			}

		case '3dLaptop':
			{
				defaultCamZoom = 0.75;
				curStage = '3dLaptop';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/3dLaptop'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
				}

				if (isNewCam.contains(SONG.song.toLowerCase())) {
		    		UsingNewCam = true;
				}
			}
		
		case 'whiteBG':
			{
				defaultCamZoom = 0.6;
				curStage = 'whiteBG';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/lol'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if (isNewCam.contains(SONG.song.toLowerCase())) {
		    		UsingNewCam = true;
				}
			}

		case 'bambersHell':
			{
				defaultCamZoom = 0.7;
				curStage = 'bambersHell';
				gridBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/purgatory/grid'));
				gridBG.antialiasing = true;
				gridBG.scrollFactor.set(0.6, 0.6);
				gridBG.active = true;
				gridBG.scale.set(1.5, 1.5);
				gridBG.screenCenter(X);
	
				add(gridBG);
	
				if(ClientPrefs.waving)
				{
					var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
					testshader.waveAmplitude = 0.095;
					testshader.waveFrequency = 5;
					testshader.waveSpeed = 1.15;
					gridBG.shader = testshader.shader;
					curbg = gridBG;
				}
				
				bgHELL = new BGSprite('bambi/purgatory/graysky', -600, -200, 0.2, 0.2);
				bgHELL.antialiasing = false;
				bgHELL.scrollFactor.set(0, 0);
				bgHELL.screenCenter(X);
				bgHELL.scale.set(10, 10);
				bgHELL.alpha = 0.85;
				add(bgHELL);

				bgshitH2 = new DepthSprite('bambi/purgatory/3dBG_Objects', -600, -200, 0.5, 0.5);
				bgshitH2.scale.set(1.5, 1.5);
				bgshitH2.screenCenter(X);
				bgshitH2.depth = 0.5;
				bgshitH2.defaultScale = 1.5;
				add(bgshitH2);
		
				bgshitH = new DepthSprite('bambi/purgatory/3d_Objects', -600, -200, 0.7, 0.7);
				bgshitH.scale.set(1.25, 1.25);
			    //bgshitH.screenCenter(X);
			    bgshitH.depth = 0.7;
				bgshitH.defaultScale = 1.25;
				add(bgshitH);

				cloudsH = new BGSprite('bambi/purgatory/scaryclouds', -600, -200, 0.2, 0.2);
				cloudsH.updateHitbox();
				cloudsH.screenCenter(X);
				cloudsH.antialiasing = true;
				cloudsH.scale.set(1.45, 1.55);
				add(cloudsH);
			}

		case '3dComputer':
			{
				defaultCamZoom = 0.75;
				curStage = '3dComputer';
				if(SONG.song.toLowerCase() == "technology") swagSpeed = 3.2; // https://cdn.discordapp.com/attachments/923248425145868329/936403638794993714/video0_1.mp4
				// wtf is this for
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/purgatory/billgates/computer'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
				}
			}

		case '3dBurger':
			{
				defaultCamZoom = 0.75;
				curStage = '3dBurger';

				if(SONG.song.toLowerCase() == "devastation") {
			    	swaggy = new Character(-1350, 100, 'bandu'); // needs to go to -300, 100 lol
			    	swagBombu = new Character(-400, 1350, 'bombu');
				}

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/purgatory/hamburger'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.5, 0.5);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 2;
				testshader.waveSpeed = 0.95;
				bg.shader = testshader.shader;
				curbg = bg;
				}

				
				if(SONG.song.toLowerCase() == "devastation") {
			    	littleIdiot = new Character(200, -175, 'expunged');
			    	add(littleIdiot);
			    	littleIdiot.visible = false;
			    	poipInMahPahntsIsGud = false;

					swaggy = new Character(-1350, 100, 'bandu'); // needs to go to -300, 100 lol
					swagBombu = new Character(-400, 1350, 'bombu');

			      	what = new FlxTypedGroup<FlxSprite>();
			    	add(what);
			    }
			}

		case '3dScary':
			{
				defaultCamZoom = 0.85;
				curStage = '3dScary';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/scarybg'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.6, 0.6);
				bg.active = true;

				add(bg);
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				bg.shader = testshader.shader;
				curbg = bg;
				}

				if (isNewCam.contains(SONG.song.toLowerCase())) {
			    	UsingNewCam = true;
				}
			}

		case '3dPhone':
			{
			    defaultCamZoom = 0.5;
			    curStage = '3dPhone';

				swagBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/3dPhone'));
				//swagBG.scrollFactor.set(0, 0);
				swagBG.scale.set(1.75, 1.75);
				//swagBG.updateHitbox();
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 1;
				testshader.waveSpeed = 2;
				swagBG.shader = testshader.shader;
				curbg = swagBG;
				}
				add(swagBG);

				littleIdiot = new Character(200, -175, 'expunged');
				add(littleIdiot);
				littleIdiot.visible = false;
				poipInMahPahntsIsGud = false;

				what = new FlxTypedGroup<FlxSprite>();
				add(what);

				/*computer = new FlxSprite(750, -150);
				computer.frames = Paths.getSparrowAtlas('bambi/pizza');
				computer.animation.addByPrefix('idle', 'p', 12, true);
				computer.animation.play('idle');
				computer.visible = true;
				computer.antialiasing = false;
				add(computer);*/

				for (i in 0...2) {
					var pizza = new FlxSprite(FlxG.random.int(100, 1000), FlxG.random.int(100, 500));
					pizza.frames = Paths.getSparrowAtlas('bambi/pizza');
					pizza.animation.addByPrefix('idle', 'p', 12, true); // https://m.gjcdn.net/game-thumbnail/500/652229-crop175_110_1130_647-stnkjdtv-v4.jpg
					pizza.animation.play('idle');
					pizza.ID = i;
					pizza.visible = false;
					pizza.antialiasing = false;
					wow2.push([pizza.x, pizza.y, FlxG.random.int(400, 1200), FlxG.random.int(500, 700), i]);
					gasw2.push(FlxG.random.int(800, 1200));
					what.add(pizza);
				}
			}

		case '3dBembos':
			{
			    defaultCamZoom = 0.5;
			    curStage = '3dBembos';

				swagBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/BembosBG'));
				//swagBG.scrollFactor.set(0, 0);
				swagBG.scale.set(3.5, 3.5);
				//swagBG.updateHitbox();
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 1;
				testshader.waveSpeed = 2;
				swagBG.shader = testshader.shader;
				curbg = swagBG;
				}
				add(swagBG);

				littleIdiot = new Character(200, -175, 'expunged');
				add(littleIdiot);
				littleIdiot.visible = false;
				poipInMahPahntsIsGud = false;

				what = new FlxTypedGroup<FlxSprite>();
				add(what);

				/*computer = new FlxSprite(750, -150);
				computer.frames = Paths.getSparrowAtlas('bambi/pizza');
				computer.animation.addByPrefix('idle', 'p', 12, true);
				computer.animation.play('idle');
				computer.visible = true;
				computer.antialiasing = false;
				add(computer);*/

				for (i in 0...2) {
					var pizza = new FlxSprite(FlxG.random.int(100, 1000), FlxG.random.int(100, 500));
					pizza.frames = Paths.getSparrowAtlas('bambi/pizza');
					pizza.animation.addByPrefix('idle', 'p', 12, true); // https://m.gjcdn.net/game-thumbnail/500/652229-crop175_110_1130_647-stnkjdtv-v4.jpg
					pizza.animation.play('idle');
					pizza.ID = i;
					pizza.visible = false;
					pizza.antialiasing = false;
					wow2.push([pizza.x, pizza.y, FlxG.random.int(400, 1200), FlxG.random.int(500, 700), i]);
					gasw2.push(FlxG.random.int(800, 1200));
					what.add(pizza);
				}
			}

		case '3dDevastation':
			{
				defaultCamZoom = 0.7;
				curStage = '3dDevastation';
				devaBurger = new FlxSprite(0,0).loadGraphic(Paths.image('bambi/purgatory/hamburger'));
				devaBurger.setGraphicSize(Std.int(devaBurger.width * 1.8));
				devaBurger.antialiasing = true;
				devaBurger.scrollFactor.set(0.5, 0.5);
				devaBurger.active = true;
				
				devaLaptop = new FlxSprite(0,0).loadGraphic(Paths.image('dave/3dLaptop'));
				devaLaptop.setGraphicSize(Std.int(devaLaptop.width * 1.3));
				devaLaptop.antialiasing = true;
				devaLaptop.scrollFactor.set(0.5, 0.5);
				devaLaptop.active = false;

				devaDave = new FlxSprite(0,0).loadGraphic(Paths.image('dave/disabled'));
				devaDave.setGraphicSize(Std.int(devaDave.width * 1.3));
				devaDave.antialiasing = true;
				devaDave.scrollFactor.set(0.5, 0.5);
				devaDave.active = false;

				devaExpunged = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/3dFucked'));
				devaExpunged.setGraphicSize(Std.int(devaExpunged.width * 1.8));
				devaExpunged.antialiasing = true;
				devaExpunged.scrollFactor.set(0.4, 0.4);
				devaExpunged.active = false;

				add(devaExpunged);
				add(devaLaptop);
				add(devaDave);
				add(devaBurger);
				#if windows
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				var testshader2:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader2.waveAmplitude = 0.1;
				testshader2.waveFrequency = 5;
				testshader2.waveSpeed = 2;
				var testshader3:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader3.waveAmplitude = 0.1;
				testshader3.waveFrequency = 5;
				testshader3.waveSpeed = 2;
				var testshader4:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader4.waveAmplitude = 0.1;
				testshader4.waveFrequency = 5;
				testshader4.waveSpeed = 2;
				devaBurger.shader = testshader.shader;
				devaLaptop.shader = testshader2.shader;
				devaDave.shader = testshader3.shader;
				devaExpunged.shader = testshader4.shader;
				curbg = devaBurger;
				#end

				//var scaryPlatform:FlxSprite = new FlxSprite(-275, 750).loadGraphic(Paths.image('dave/scaryPlatform'));
				//scaryPlatform.setGraphicSize(Std.int(scaryPlatform.width * 0.85));
				//scaryPlatform.updateHitbox();
				//scaryPlatform.antialiasing = true;
				//scaryPlatform.scrollFactor.set(1.0, 1.0);
				//scaryPlatform.active = true;
				//add(scaryPlatform);

			}

		case '3dCrusti':
			{
				defaultCamZoom = 0.5;
				curStage = '3dCrusti';
				poopBG.loadGraphic(Paths.image('dave/3dCrusti'));
				poopBG.antialiasing = true;
				poopBG.setGraphicSize(Std.int(poopBG.width * 1.8));
				poopBG.antialiasing = true;
				poopBG.scrollFactor.set(0.4, 0.4);
				poopBG.active = true;
				add(poopBG);

				purpleBG = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/purpleTunnelBG'));
				purpleBG.setGraphicSize(Std.int(purpleBG.width * 1.15));
				purpleBG.updateHitbox();
				purpleBG.active = false;
				purpleBG.visible = false;
				add(purpleBG);

				purpleTunnel = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/purpleTunnel'));
				purpleTunnel.setGraphicSize(Std.int(purpleTunnel.width * 1.15));
				purpleTunnel.updateHitbox();
				purpleTunnel.active = false;
				purpleTunnel.visible = false;
				add(purpleTunnel);

				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				poopBG.shader = testshader.shader;
				curbg = poopBG;
				}
			}

		case 'demiseStage':
			{
				defaultCamZoom = 0.55;
				curStage = 'demiseStage';
				poopBG.loadGraphic(Paths.image('dave/3dFucked'));
				poopBG.antialiasing = true;
				poopBG.setGraphicSize(Std.int(poopBG.width * 1.8));
				poopBG.antialiasing = true;
				poopBG.scrollFactor.set(0.4, 0.4);
				poopBG.active = true;
				add(poopBG);

				poop2BG.loadGraphic(Paths.image('dave/3dFucked2'));
				poop2BG.antialiasing = true;
				poop2BG.setGraphicSize(Std.int(poop2BG.width * 3.4));
				poop2BG.antialiasing = true;
				poop2BG.scrollFactor.set(0.4, 0.4);
				poop2BG.active = true;
				poop2BG.visible = false;
				add(poop2BG);

				jeezBG.loadGraphic(Paths.image('dave/jeez_fr'));
				jeezBG.antialiasing = true;
				jeezBG.setGraphicSize(Std.int(jeezBG.width * 3.4));
				jeezBG.antialiasing = true;
				jeezBG.scrollFactor.set(0.4, 0.4);
				jeezBG.active = false;
				jeezBG.visible = false;
				add(jeezBG);

				redBG = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/redTunnelBG'));
				redBG.setGraphicSize(Std.int(redBG.width * 1.15));
				redBG.updateHitbox();
				redBG.active = false;
				redBG.visible = false;
				add(redBG);

				redTunnel = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/redTunnel'));
				redTunnel.setGraphicSize(Std.int(redTunnel.width * 1.15));
				redTunnel.updateHitbox();
				redTunnel.active = false;
				redTunnel.visible = false;

				redTunnel2 = new FlxSprite(-500, -700).loadGraphic(Paths.image('bambi/redTunnel'));
				redTunnel2.setGraphicSize(Std.int(redTunnel2.width * 1.15));
				redTunnel2.updateHitbox();
				redTunnel2.active = false;
				redTunnel2.visible = false;

				gridBG = new FlxSprite(-600, -200).loadGraphic(Paths.image('bambi/purgatory/grid'));
				gridBG.antialiasing = true;
				gridBG.scrollFactor.set(0.6, 0.6);
				gridBG.active = false;
				gridBG.visible = false;
				gridBG.scale.set(1.5, 1.5);
				gridBG.screenCenter(X);
	
				add(gridBG);
				
				bgHELL = new BGSprite('bambi/purgatory/graysky', -600, -200, 0.2, 0.2);
				bgHELL.antialiasing = false;
				bgHELL.scrollFactor.set(0, 0);
				bgHELL.visible = false;
				bgHELL.screenCenter(X);
				bgHELL.scale.set(10, 10);
				bgHELL.alpha = 0.85;
				add(bgHELL);

				add(redTunnel);

				add(redTunnel2);

				bgshitH2 = new DepthSprite('bambi/purgatory/3dBG_Objects', -600, -200, 0.5, 0.5);
				bgshitH2.scale.set(1.5, 1.5);
				bgshitH2.visible = false;
				bgshitH2.screenCenter(X);
				bgshitH2.depth = 0.5;
				bgshitH2.defaultScale = 1.5;
				add(bgshitH2);
		
				bgshitH = new DepthSprite('bambi/purgatory/3d_Objects', -600, -200, 0.7, 0.7);
				bgshitH.scale.set(1.25, 1.25);
				bgshitH.visible = false;
			    //bgshitH.screenCenter(X);
			    bgshitH.depth = 0.7;
				bgshitH.defaultScale = 1.25;
				add(bgshitH);

				cloudsH = new BGSprite('bambi/purgatory/scaryclouds', -600, -200, 0.2, 0.2);
				cloudsH.updateHitbox();
				cloudsH.visible = false;
				cloudsH.screenCenter(X);
				cloudsH.antialiasing = true;
				cloudsH.scale.set(1.45, 1.55);
				add(cloudsH);
				
				if(ClientPrefs.waving)
				{
					var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
					testshader.waveAmplitude = 0.1;
					testshader.waveFrequency = 5;
					testshader.waveSpeed = 2;
					var testshader2:Shaders.GlitchEffect = new Shaders.GlitchEffect();
					testshader2.waveAmplitude = 0.1;
					testshader2.waveFrequency = 5;
					testshader2.waveSpeed = 2;
					var testshader3:Shaders.GlitchEffect = new Shaders.GlitchEffect();
					testshader3.waveAmplitude = 0.1;
					testshader3.waveFrequency = 5;
					testshader3.waveSpeed = 2;
					var testshader4:Shaders.GlitchEffect = new Shaders.GlitchEffect();
					testshader4.waveAmplitude = 0.1;
					testshader4.waveFrequency = 5;
					testshader4.waveSpeed = 2;
					poopBG.shader = testshader.shader;
					poop2BG.shader = testshader2.shader;
					gridBG.shader = testshader3.shader;
					jeezBG.shader = testshader4.shader;
					curbg = poop2BG;
				}
			}
		
		case '3dFucked':
			{
				defaultCamZoom = 0.6;
				curStage = '3dFucked';
				poopBG.loadGraphic(Paths.image('dave/3dFucked'));
				poopBG.antialiasing = true;
				poopBG.setGraphicSize(Std.int(poopBG.width * 1.8));
				poopBG.antialiasing = true;
				poopBG.scrollFactor.set(0.4, 0.4);
				poopBG.active = true;
				add(poopBG);
	
				poop2BG.loadGraphic(Paths.image('dave/3dFucked2'));
				poop2BG.antialiasing = true;
				poop2BG.setGraphicSize(Std.int(poop2BG.width * 3.4));
				poop2BG.antialiasing = true;
				poop2BG.scrollFactor.set(0.4, 0.4);
				poop2BG.active = false;
				poop2BG.visible = false;
				add(poop2BG);
	
				redBG = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/redTunnelBG'));
				redBG.setGraphicSize(Std.int(redBG.width * 1.15));
				redBG.updateHitbox();
				redBG.active = false;
				redBG.visible = false;
				add(redBG);
	
				redTunnel = new FlxSprite(-1000, -700).loadGraphic(Paths.image('bambi/redTunnel'));
				redTunnel.setGraphicSize(Std.int(redTunnel.width * 1.15));
				redTunnel.updateHitbox();
				redTunnel.active = false;
				redTunnel.visible = false;
				add(redTunnel);
	
				if(ClientPrefs.waving)
				{
				// below code assumes shaders are always enabled which is bad
				var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
				testshader.waveAmplitude = 0.1;
				testshader.waveFrequency = 5;
				testshader.waveSpeed = 2;
				poopBG.shader = testshader.shader;
				curbg = poopBG;
				}
			}

		case 'farmDay':
			{
				defaultCamZoom = 0.85;
				curStage = 'farmDay';

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/sky'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = true;	

				var hills:FlxSprite = new FlxSprite(-300, 110).loadGraphic(Paths.image('bambi/orangey hills'));
				hills.antialiasing = true;
				hills.scrollFactor.set(0.5, 0.5);
				hills.active = true;

				var farm:FlxSprite = new FlxSprite(150, 200).loadGraphic(Paths.image('bambi/funfarmhouse'));
				farm.antialiasing = true;
				farm.scrollFactor.set(0.65, 0.65);
				farm.active = true;

				var foreground:FlxSprite = new FlxSprite(-400, 600).loadGraphic(Paths.image('bambi/grass lands'));
				foreground.antialiasing = true;
				foreground.scrollFactor.set(1, 1);
				foreground.active = true;

				var cornSet:FlxSprite = new FlxSprite(-350, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet.antialiasing = true;
				cornSet.scrollFactor.set(1, 1);
				cornSet.active = true;

				var cornSet2:FlxSprite = new FlxSprite(1050, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet2.antialiasing = true;
				cornSet2.scrollFactor.set(1, 1);
				cornSet2.active = true;

				var fence:FlxSprite = new FlxSprite(-350, 450).loadGraphic(Paths.image('bambi/crazy fences'));
				fence.antialiasing = true;
				fence.scrollFactor.set(0.98, 0.98);
				fence.active = true;

				var sign:FlxSprite = new FlxSprite(0, 500).loadGraphic(Paths.image('bambi/sign'));
				sign.antialiasing = true;
				sign.scrollFactor.set(1, 1);
				sign.active = true;

				add(bg);
				add(hills);
				add(farm);
				add(foreground);
				add(cornSet);
				add(cornSet2);
				add(fence);
				add(sign);

				if (isNewCam.contains(SONG.song.toLowerCase())) {
			    	UsingNewCam = true;
				}
			}

		case 'farmSunset':
			{
				defaultCamZoom = 0.85;
				curStage = 'farmSunset';

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('dave/sky_sunset'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = true;

				var hills:FlxSprite = new FlxSprite(-300, 110).loadGraphic(Paths.image('bambi/orangey hills'));
				hills.antialiasing = true;
				hills.scrollFactor.set(0.5, 0.5);
				hills.active = true;

				var farm:FlxSprite = new FlxSprite(150, 200).loadGraphic(Paths.image('bambi/funfarmhouse'));
				farm.antialiasing = true;
				farm.scrollFactor.set(0.65, 0.65);
				farm.active = true;

				var foreground:FlxSprite = new FlxSprite(-400, 600).loadGraphic(Paths.image('bambi/grass lands'));
				foreground.antialiasing = true;
				foreground.scrollFactor.set(1, 1);
				foreground.active = true;

				var cornSet:FlxSprite = new FlxSprite(-350, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet.antialiasing = true;
				cornSet.scrollFactor.set(1, 1);
				cornSet.active = true;

				var cornSet2:FlxSprite = new FlxSprite(1050, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet2.antialiasing = true;
				cornSet2.scrollFactor.set(1, 1);
				cornSet2.active = true;

				var fence:FlxSprite = new FlxSprite(-350, 450).loadGraphic(Paths.image('bambi/crazy fences'));
				fence.antialiasing = true;
				fence.scrollFactor.set(0.98, 0.98);
				fence.active = true;

				var sign:FlxSprite = new FlxSprite(0, 500).loadGraphic(Paths.image('bambi/sign'));
				sign.antialiasing = true;
				sign.scrollFactor.set(1, 1);
				sign.active = true;

				hills.color = 0xFFF9974C;
				farm.color = 0xFFF9974C;
				foreground.color = 0xFFF9974C;
				cornSet.color = 0xFFF9974C;
				cornSet2.color = 0xFFF9974C;
				fence.color = 0xFFF9974C;
				sign.color = 0xFFF9974C;

				add(bg);
				add(hills);
				add(farm);
				add(foreground);
				add(cornSet);
				add(cornSet2);
				add(fence);
				add(sign);

				if (isNewCam.contains(SONG.song.toLowerCase())) {
		    		UsingNewCam = true;
				}
			}

		case 'farmNight':
			{
				defaultCamZoom = 0.85;
				curStage = 'farmNight';
				
				/*if(ClientPrefs.chromaticAberration)
				  camGame.setFilters([ShadersHandler.ChromaticAberration]);
				  ShadersHandler.setChrome(1000);
				*/

				var bg:FlxSprite = new FlxSprite(-600, -400).loadGraphic(Paths.image('dave/sky_night'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = true;

				var hills:FlxSprite = new FlxSprite(-300, 110).loadGraphic(Paths.image('bambi/orangey hills'));
				hills.antialiasing = true;
				hills.scrollFactor.set(0.5, 0.5);
				hills.active = true;

				var farm:FlxSprite = new FlxSprite(150, 200).loadGraphic(Paths.image('bambi/funfarmhouse'));
				farm.antialiasing = true;
				farm.scrollFactor.set(0.65, 0.65);
				farm.active = true;

				var foreground:FlxSprite = new FlxSprite(-400, 600).loadGraphic(Paths.image('bambi/grass lands'));
				foreground.antialiasing = true;
				foreground.scrollFactor.set(1, 1);
				foreground.active = true;

				var cornSet:FlxSprite = new FlxSprite(-350, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet.antialiasing = true;
				cornSet.scrollFactor.set(1, 1);
				cornSet.active = true;

				var cornSet2:FlxSprite = new FlxSprite(1050, 325).loadGraphic(Paths.image('bambi/Cornys'));
				cornSet2.antialiasing = true;
				cornSet2.scrollFactor.set(1, 1);
				cornSet2.active = true;

				var fence:FlxSprite = new FlxSprite(-350, 450).loadGraphic(Paths.image('bambi/crazy fences'));
				fence.antialiasing = true;
				fence.scrollFactor.set(0.98, 0.98);
				fence.active = true;

				var sign:FlxSprite = new FlxSprite(0, 500).loadGraphic(Paths.image('bambi/sign'));
				sign.antialiasing = true;
				sign.scrollFactor.set(1, 1);
				sign.active = true;

				hills.color = 0xFF878787;
				farm.color = 0xFF878787;
				foreground.color = 0xFF878787;
				cornSet.color = 0xFF878787;
				cornSet2.color = 0xFF878787;
				fence.color = 0xFF878787;
				sign.color = 0xFF878787;

				add(bg);
				add(hills);
				add(farm);
				add(foreground);
				add(cornSet);
				add(cornSet2);
				add(fence);
				add(sign);

				if (isNewCam.contains(SONG.song.toLowerCase())) {
					UsingNewCam = true;
				}
	        }
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); //troll'd

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				precacheList.set('thunder_1', 'sound');
				precacheList.set('thunder_2', 'sound');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}

				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
				phillyWindow = new BGSprite('philly/window', city.x, city.y, 0.3, 0.3);
				phillyWindow.setGraphicSize(Std.int(phillyWindow.width * 0.85));
				phillyWindow.updateHitbox();
				add(phillyWindow);
				phillyWindow.alpha = 0;

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				phillyStreet = new BGSprite('philly/street', -40, 50);
				add(phillyStreet);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					precacheList.set('dancerdeath', 'sound');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				precacheList.set('Lights_Shut_off', 'sound');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/
				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			case 'tank': //Week 7 - Ugh, Guns, Stress
				var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(sky);

				if(!ClientPrefs.lowQuality)
				{
					var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					add(clouds);

					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(1.2 * mountains.width));
					mountains.updateHitbox();
					add(mountains);

					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(1.1 * buildings.width));
					buildings.updateHitbox();
					add(buildings);
				}

				var ruins:BGSprite = new BGSprite('tankRuins',-200,0,.35,.35);
				ruins.setGraphicSize(Std.int(1.1 * ruins.width));
				ruins.updateHitbox();
				add(ruins);

				if(!ClientPrefs.lowQuality)
				{
					var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeLeft);
					var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeRight);

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
				}

				tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5,['BG tank w lighting'], true);
				add(tankGround);

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var ground:BGSprite = new BGSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(1.15 * ground.width));
				ground.updateHitbox();
				add(ground);
				moveTank();

				foregroundSprites = new FlxTypedGroup<BGSprite>();
				foregroundSprites.add(new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']));
				foregroundSprites.add(new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']));
				foregroundSprites.add(new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']));
				if(!ClientPrefs.lowQuality) foregroundSprites.add(new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']));
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel') {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dadGroup);
		add(boyfriendGroup);

		switch(curStage)
		{
			case 'spooky':
				add(halloweenWhite);
			case 'tank':
				add(foregroundSprites);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if(SONG.song.toLowerCase() == "unfairness" || SONG.song.toLowerCase() == "unfairness-remix" || SONG.song.toLowerCase() == "upheaval")
		{
			health = 2;
		}

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end


		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		screenshader.waveAmplitude = 1;
        screenshader.waveFrequency = 2;
        screenshader.waveSpeed = 1;
        screenshader.shader.uTime.value[0] = new flixel.math.FlxRandom().float(-100000, 100000);

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
				default:
					gfVersion = 'gf';
			}

			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

			if(gfVersion == 'pico-speaker')
			{
				if(!ClientPrefs.lowQuality)
				{
					var firstTank:TankmenBG = new TankmenBG(20, 500, true);
					firstTank.resetShit(20, 600, true);
					firstTank.strumTime = 10;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
							tankmanRun.add(tankBih);
						}
					}
				}
			}
		}
		if(isFreeplay || isFreeplayPur)
			{
				if(CharacterSelectionState.notBF)
					gf.visible = false;
			}
		
		if(SONG.song.toLowerCase() == 'antagonism')
			{
				badai = new Character(-300, 100, 'badai');
				gf.visible = true;
			}

		if(SONG.song.toLowerCase() == 'disregard')
			{
				bambi = new Character(-500, 100, 'bambi-god2d-24fps');
				dave = new Character(0, 300, 'dave-splitathon');
				gf.visible = true;
			}

		if(SONG.song.toLowerCase() == 'platonic')
			{
				bambi = new Character(-100, 575, 'bambi');
				dave = new Character(0, 500, 'tristan');
				boyfriend2 = new Boyfriend(650, 200, 'babman-player');
			}

		if(SONG.song.toLowerCase() == 'rascal')
			{
				dave = new Character(0, 100, 'dave-splitathon');
			}

		if(SONG.song.toLowerCase() == 'devastation')
			{
				bandu = new Character(-300, 100, 'bandu');
				gf.visible = true;
			}

		if(SONG.song.toLowerCase() == 'devastation-fanmade')
			{
				bandu = new Character(-300, 100, 'bandu');
				bamburg = new Character(-300, 100, 'bamburg');
				gf.visible = true;
			}

		if(SONG.song.toLowerCase() == 'demise pt 1')
			{
				badai = new Character(-300, 100, 'badai');
				dave = new Character(-800, 100, 'crimson-dave');
				gf.visible = true;
			}
		
		if(SONG.song.toLowerCase() == 'demise pt 2')
			{
				dave = new Character(-300, 100, 'crimson-dave');
				bamburg = new Character(-800, -300, 'bombai');
				gf.visible = true;
			}

		if(SONG.song.toLowerCase() == 'new-antagonism')
			{
				badai = new Character(-300, 100, 'badai');
				gf.visible = true;
			}
		if(SONG.song.toLowerCase() == 'antagonism-11-minutes')
			{
				badai = new Character(-300, 100, 'badai');
				gf.visible = true;
			}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		if(badai != null) add(badai);
		if(bambi != null) add(bambi);
		if(dave != null) add(dave);
		if(bandu != null) add(bandu);
		if(bamburg != null) add(bamburg);
		if (swaggy != null) add(swaggy);
		if (swagBombu != null) add(swagBombu);
		if(boyfriend2 != null) add(boyfriend2);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				addBehindGF(fastCar);

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
		}
		switch(dad.curCharacter)
		{
			case 'bambi-scaryooo' | 'bambi-god' | 'bambi-god2d' | 'bambi-hell' | 'expunged':
				evilTrail = new FlxTrail(dad, null, 4, 12, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
				switch (curStage)
		    	{
		     		case 'spooky':
			    	evilTrail.color = 0xFF383838;
				}
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		switch (curSong.toLowerCase())
		{
			case 'roundabout' | 'upheaval-teaser' | 'reheated' | 'lacuna' | 'antagonism-poip-part' | 'dethroned' | 'crimson corridor' | 'demise pt 1' | 'demise pt 2' | 'demise-pt-1' | 'demise-pt-2' | 'platonic':
				doof.finishThing = startSongNoCountDown;
			default:
				doof.finishThing = startCountdown;
		}
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(!dontMiddle.contains(SONG.song.toLowerCase()) && ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll || SONG.song.toLowerCase() == 'unfairness' || SONG.song.toLowerCase() == "unfairness-remix") strumLine.y = FlxG.height - 165;
		strumLine.scrollFactor.set();

		laneunderlayOpponent = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlayOpponent.alpha = ClientPrefs.laneTransparency;
		laneunderlayOpponent.color = FlxColor.BLACK;
		laneunderlayOpponent.scrollFactor.set();

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.alpha = ClientPrefs.laneTransparency;
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();

		if (ClientPrefs.laneunderlay)
		{
			add(laneunderlay);
			add(laneunderlayOpponent);
			if(ClientPrefs.middleScroll)
			{
				remove(laneunderlayOpponent);
				laneunderlayOpponent.visible = false;
			}
		}

		var showTime:Bool =  (!ClientPrefs.hideTime);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 252, 20, 400, "", 32);
	    	timeTxt.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		} else {
			timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 252, 20, 400, "", 32);
			timeTxt.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		timeTxt.scrollFactor.set();
		timeTxt.screenCenter(X);
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('healthBarNew');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.GRAY;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		timeBarBG.screenCenter(X);
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		reloadTimeBarColors();
		timeBar.screenCenter(X);
		insert(members.indexOf(timeBarBG), timeBar);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		add(timeTxt);

		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();
		poopStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		if(!ClientPrefs.longAssBar) {
     		healthBarBG = new AttachedSprite('healthBarNew');
			 
			 if (ClientPrefs.uiStyle == 'Kade Engine' || ClientPrefs.uiStyle == 'Dave Engine') {
				healthBarBG.y = FlxG.height * 0.9;
			} else {
				healthBarBG.y = FlxG.height * 0.89;
			}
	     	healthBarBG.xAdd = -4;
	     	healthBarBG.yAdd = -4;
		}
	    else if(ClientPrefs.longAssBar) {
			healthBarBG = new AttachedSprite('healthBarWIDE');
			if (ClientPrefs.uiStyle == 'Kade Engine' || ClientPrefs.uiStyle == 'Dave Engine') {
				healthBarBG.y = FlxG.height * 0.9;
			} else {
				healthBarBG.y = FlxG.height * 0.89;
			}
			healthBarBG.xAdd = -4;
			healthBarBG.yAdd = -4;
		}
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 50;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		if(!ClientPrefs.longAssBar) {
			insert(members.indexOf(healthBarBG), healthBar);
		} else if(ClientPrefs.longAssBar) {
			add(healthBar);
		}
		healthBarBG.sprTracker = healthBar;

		healthBarOverlay = new FlxSprite().loadGraphic(Paths.image('healthBarOverlay'));
		if (ClientPrefs.uiStyle == 'Kade Engine' || ClientPrefs.uiStyle == 'Dave Engine') {
			healthBarOverlay.y = FlxG.height * 0.9;
		} else {
			healthBarOverlay.y = FlxG.height * 0.89;
		}
		healthBarOverlay.screenCenter(X);
		healthBarOverlay.scrollFactor.set();
		if(!ClientPrefs.longAssBar) {
			healthBarOverlay.visible = !ClientPrefs.hideHud;
		} else if(ClientPrefs.longAssBar) {
			healthBarOverlay.visible = false;
		}
    	healthBarOverlay.color = FlxColor.BLACK;
		healthBarOverlay.blend = MULTIPLY;
		healthBarOverlay.x = healthBarBG.x-1.9;
	    healthBarOverlay.alpha = ClientPrefs.healthBarAlpha;
		healthBarOverlay.antialiasing = ClientPrefs.globalAntialiasing;
		healthBarOverlay.cameras = [camHUD];
		add(healthBarOverlay); healthBarOverlay.alpha = ClientPrefs.healthBarAlpha; if(ClientPrefs.downScroll) healthBarOverlay.y = 0.11 * FlxG.height;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		if (ClientPrefs.uiStyle == 'Kade Engine' || ClientPrefs.uiStyle == 'Dave Engine') {
			iconP1.y = healthBar.y - (iconP1.height / 2);
		} else {
			iconP1.y = healthBar.y - 75;
		}
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		if (ClientPrefs.uiStyle == 'Kade Engine' || ClientPrefs.uiStyle == 'Dave Engine') {
			iconP2.y = healthBar.y - (iconP2.height / 2);
		} else {
			iconP2.y = healthBar.y - 75;
		}
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		comboVisual = new FlxSprite(75, 75);
		comboVisual.frames = Paths.getSparrowAtlas('NOTECOMBO');
		comboVisual.animation.addByPrefix('idle', 'appear', 24, false);

		if (ClientPrefs.uiStyle == 'Purgatory') {
			scoreTxt = new FlxText(0, healthBarBG.y + 50, FlxG.width, "", 20);
			scoreTxt.setFormat(Paths.font("comic.ttf"), 17, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.borderSize = 1.25;
		}
		if (ClientPrefs.uiStyle == 'Kade Engine') {
			scoreTxt = new FlxText(0, healthBarBG.y + 50, FlxG.width, "", 20);
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		if (ClientPrefs.uiStyle == 'Psych Engine') {
			scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.borderSize = 1.25;
		}
		if (ClientPrefs.uiStyle == 'Dave Engine') {
			scoreTxt = new FlxText(0, healthBarBG.y + 40, FlxG.width, "", 20);
			scoreTxt.setFormat(Paths.font("comic.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.borderSize = 1.5;
		}
		scoreTxt.scrollFactor.set();
		scoreTxt.screenCenter(X);
		scoreTxt.visible = !ClientPrefs.hideHud;

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.cameras = [camHUD];
		judgementCounter.screenCenter(Y);
		if (ClientPrefs.judgementCounter == 'Advanced') {
			judgementCounter.text = 'Combo: ${combo}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nTotal Notes: ${totalNotesHit}\nMisses: ${songMisses}';
		}
		if (ClientPrefs.judgementCounter == 'Simple') {
			judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${songMisses}';
		}
		if (ClientPrefs.judgementCounter != 'Disabled') {
			add(judgementCounter);
		}

		var credits:String;
		switch (SONG.song.toLowerCase())
		{
			case 'supernovae' | 'supernovae-uber':
				credits = 'Original Song made by ArchWk!';
			case 'dethroned':
				credits = 'Original Song made by AadstaPinwheel';
			case 'fast-food':
				credits = 'Song Made by randy the slope!';
			case 'reheated':
				credits = 'Song Made by BezieAnims!';
			case 'antagonism-poip-part':
				credits = 'Song Made by GambitGourmet!';
			case 'glitch':
				credits = 'Original Song made by DeadShadow and PixelGH!';
			case 'mealie':
				credits = 'Song made by Alexander Cooper 19!';
			case '8-28-63':
				credits = 'Original Song made by Tsuraran! | VS SKIPPA';
			case 'unfairness':
				credits = "Ghost tapping is forced off! Screw you!";
			case 'unfairness-remix':
				credits = "Ghost tapping is forced off! Screw you!";
			case 'opposition':
				credits = "Fuck you. You're done.";
			case 'lacuna':
				credits = "Fuck you. You're done. Song made by NULL_Y34R!";
			case 'disruption':
				credits = "Screw You! | Original song made by Grantare for Golden Apple!";
			case 'sucked':
				credits = 'Original Song made by ZackGM/SomeThing111 for Vs Umball!';
			case 'cheating':
				credits = 'Screw you!';
			case 'vs-dave-thanksgiving' | 'vs-dave-christmas':
				credits = 'this song is a joke lol, What the fuck.';
			case 'secret':
				credits = 'ATTENTION: WE HAVE DISCOVERED YOU HAVE MORE THAN ONE CHILD! THE BALDI BASICS VIRUS HAS INFECTED YOUR GOVERNMENT ISSUED COMPUTER! SEND US FIVE BILLION ¥ OR WE WILL ASSASSINATE YOUR FAMILY!';
			case 'secret-2':
				credits = 'https://www.youtube.com/watch?v=8hicUF3oxoU&t=111s';
			case 'secret-3':
				credits = 'rip bozo - Freedom Dive by XI';
			case 'bombu x bamburg shipping cute':
				credits = 'they kissign love of true | Original Song by Grantare for Golden Apple! (Cover by randy the slope!)';
			case 'harvested':
				credits = 'Original Song made by BezieAnims!';
			case 'DATA_EXPUNGED_(HAXELIB_ERROR)':
				credits = "????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????";
			case 'exploitation':
				credits = 'You won\'t survive' + " " + CoolSystemStuff.getUsername() + "!";
			default:
				credits = '';
		}
		var randomThingy:Int = FlxG.random.int(0, 7);
		var engineName:String = 'stupid';
		switch(randomThingy)
	    {
			case 0:
				engineName = 'PE ';
			case 1:
				engineName = 'PE ';
			case 2:
				engineName = 'PE ';
			case 3:
				engineName = 'PE '; // hey this DOESNT mean david is coming to bp, its cuz is like some alternative version of dave lol
			case 4:
				engineName = 'PE ';
			case 5:
				engineName = 'PE ';
			case 6:
				engineName = 'PE ';
			case 7:
				engineName = 'PE '; 
			case 8:
				engineName = 'PE '; 
			case 9:
				engineName = 'PE '; 
		/*	case 10:
				engineName = 'KE ';*/
		/*	case 11:
				engineName = 'KE ';*/ //  not adding these guys till the next update lololo
		}
		var creditsText:Bool = credits != '';
		var textYPos:Float = healthBarBG.y + 50;
		if (creditsText)
		{
			textYPos = healthBarBG.y + 32;
		}

		if(ClientPrefs.uiStyle == 'Kade Engine') {
			creditsWatermark = new FlxText(5, healthBarBG.y + 50, 0, credits, 16);
			creditsWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		if (ClientPrefs.uiStyle == 'Dave Engine' || ClientPrefs.uiStyle == 'Purgatory' || ClientPrefs.uiStyle == 'Psych Engine') {
			creditsWatermark = new FlxText(5, healthBarBG.y + 50, 0, credits, 16);
			creditsWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			creditsWatermark.borderSize = 1.25;
		}
		creditsWatermark.scrollFactor.set();
		add(creditsWatermark);
		creditsWatermark.cameras = [camHUD];

		// credits to kade dev for the song watermark lol
		if(ClientPrefs.uiStyle == 'Kade Engine') {
	    	songWatermark = new FlxText(5, textYPos, FlxG.width,
			SONG.song
			+ " - "
			+ (curSong.toLowerCase() != 'splitathon' ? (storyDifficulty == 3 ? "FINALE" : storyDifficulty == 2 ? "HARD" : storyDifficulty == 1 ? "NORMAL" : "EASY") : "FINALE")
			+ " | " + engineName + '0.6.2', 14);
			songWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		} 
		if (ClientPrefs.uiStyle == 'Dave Engine' || ClientPrefs.uiStyle == 'Purgatory' || ClientPrefs.uiStyle == 'Psych Engine') {
			songWatermark = new FlxText(5, textYPos, FlxG.width,
			SONG.song
			+ " - "
			+ (curSong.toLowerCase() != 'splitathon' ? (storyDifficulty == 3 ? "FINALE" : storyDifficulty == 2 ? "HARD" : storyDifficulty == 1 ? "NORMAL" : "EASY") : "FINALE")
			+ " | " + engineName + '0.6.2', 14);
			songWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songWatermark.borderSize = 1.25;
			//+ " ", 16);
		}
		songWatermark.visible = !ClientPrefs.hideHud;
		add(songWatermark);

		switch (SONG.song.toLowerCase())
		{
			case 'insanity':
				Paths.returnGraphic('backgrounds/void/redsky');
				Paths.returnGraphic('backgrounds/void/redsky_insanity');
			case 'exploitation':
				Paths.returnGraphic('ui/glitch/glitchSwitch');
				Paths.returnGraphic('backgrounds/void/exploit/cheater GLITCH');
				Paths.returnGraphic('backgrounds/void/exploit/glitchyUnfairBG');
				Paths.returnGraphic('backgrounds/void/exploit/expunged_chains');
				Paths.returnGraphic('backgrounds/void/exploit/broken_expunged_chain');
				Paths.returnGraphic('backgrounds/void/exploit/glitchy_cheating_2');
		}

		shartingTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (ClientPrefs.downScroll ? 100 : -100), 0, "CHARTING MODE", 20);
		shartingTxt.setFormat(Paths.font("comic-sans.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		shartingTxt.scrollFactor.set();
		shartingTxt.screenCenter(X);
		shartingTxt.borderSize = 4;
		shartingTxt.borderQuality = 2;
		if(chartingMode) insert(members.indexOf(strumLineNotes), shartingTxt);

		var composersWatermark:String;
		switch (SONG.song.toLowerCase())
		{
			// add moldy's songs here
			case 'house' | 'insanity' | 'furiosity' | 'bonus-song' | 'polygonized' | 'blocked' | 'corn-theft' | 'maze' | 'splitathon' | 'cheating' | 'unfairness' | 'old-house' | 'old-insanity' | 'old-furiosity' | 'old-blocked' | 'old-corn-theft' | 'old-maze' | 'old-splitathon', 'beta-maze':
		    	composersWatermark = 'MoldyGH';
			// add pyramix's songs here
            case 'reality breaking' | 'technology' | 'body destroyer' | 'face-destroyer':
				composersWatermark = 'Pyramix';
			// add randomness songs here 
		    case 'shattered' | 'Tyranny':
				composersWatermark = 'EpicRandomness11';
			// add villezen's songs here
			case 'rascal' | 'callback' | 'delivery' | 'inventive':
				composersWatermark = 'Villezen';
			// add aadsta's songs here
			case 'acquaintance' | 'dethroned':
				composersWatermark = 'AadstaPinwheel';
			//randy the slope
		    case 'fast-food':
				composersWatermark = 'randy the slope';
			// razordballsc
			case 'velocity':
		        composersWatermark = 'RazorDC';
			// NULL_Y34R
			case 'lacuna' | 'disregard':
		        composersWatermark = 'NULL_Y34R';
			// welcome to collab or v2s zone
			case 'supplanted' | 'supplanted-old':
                composersWatermark = 'EpicRandomness (V2), Cynda (V1)';
			case 'malware':
				composersWatermark = 'sola, RazorDC';
			case 'computer' | 'crimson corridor' | 'demise pt 1' | 'demise pt 2':
				composersWatermark = 'cheemy';
			case 'new-antagonism':
				composersWatermark = 'BezieAnims, AadstaPinwheel';
			case 'reheated':
				composersWatermark = 'BezieAnims';
			case 'unfairness-remix':
				composersWatermark = 'Basil';
		    case 'upheaval-teaser':
				composersWatermark = 'EpicRandomness11, BezieAnims';
			case 'triple-threat':
				composersWatermark = 'EpicRandomness11, add the composer here lololo';
			case 'antagonism-poip-part':
				composersWatermark = 'GambitGourmet';
			case 'bambi-bass':
				composersWatermark = 'Biddle3';
			case 'devastation':
				composersWatermark = 'Hortas, Pyramix';
			case 'devastation-fanmade':
				composersWatermark = 'Ayop';
			case 'disposition' | 'disposition_but_awesome' | 'roundabout' | 'antagonism' |'antagonism-11-minutes' | 'upheaval' | 'antagonism-test' | 'rebound':
				composersWatermark = 'Shredboi';
			case 'antagonism definitive mix':
				composersWatermark = 'Villezen, BezieAnims, Aadsta, Bokvae, Basil, EpicRandomness11, TempestLD, Hortas, Pyramix, ShredBoi';
			case 'bombu x bamburg shipping cute':
				composersWatermark = 'Original song by Grantare\nCover by randy the slope';
			case 'disruption':
				composersWatermark = 'Grantare';
			case "beefin'":
		    	composersWatermark = 'Cynda'; // who will make v2
			// fdsgujhosfdjohfsdjgn
			default:
				composersWatermark = ' ';
		}

		ballsText = new FlxText(20, 0, 0, "", 20);
		ballsText.setFormat(Paths.font("comic-sans.ttf"), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ballsText.borderSize = 4;
		ballsText.borderQuality = 2;
		ballsText.y = 170;
		ballsText.x -= 600;
		ballsText.scrollFactor.set();
		ballsText.cameras = [camOther];
        ballsText.text = SONG.song;
		add(ballsText);

		composersText = new FlxText(20, 40/*hi remember that this is the y pos*/, 0, "", 20);
		composersText.setFormat(Paths.font("comic-sans.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		composersText.borderSize = 4;
		composersText.borderQuality = 2;
		composersText.y = 200;
		composersText.x -= 600;
		composersText.scrollFactor.set();
		composersText.cameras = [camOther];
        composersText.text = 'Composer(s): ' + composersWatermark;
		add(composersText);

		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("comic-sans.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		blackScreen2.cameras = [camHUD];
		blackScreendeez.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		shartingTxt.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		songWatermark.cameras = [camHUD];
		comboVisual.cameras = [camHUD];

		healthBar.alpha = 0;
		healthBarBG.alpha = 0;
		healthBarOverlay.alpha = 0;
		iconP1.alpha = 0;
		iconP2.alpha = 0;
		scoreTxt.alpha = 0;
		judgementCounter.alpha = 0;
		songWatermark.alpha = 0;
		creditsWatermark.alpha = 0;

		subtitleManager = new SubtitleManager();
		subtitleManager.cameras = [camHUD];
		add(subtitleManager);

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) + '/' ));// using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode || isPurStoryMode || ClientPrefs.freeplayCuts && !seenCutscene)
		{
			switch (daSong)
			{
				case 'senpai' | 'roses' | 'thorns' | 'polygonized' | 'furiosity' | 'cheating' | 'unfairness':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

					    case 'tutorial':
							startDialogue(dialogueJson);						
		 
						case 'insanity' | 'blocked' | 'corn-theft' | 'splitathon' | 'shattered' | 'supplanted' | 'reality-breaking' | 'rebound' | 'disposition' | 'upheaval':
							dialogBullshitStart();
		 
						case 'maze':
							startVideoDIALOGUE('bambiCutscene'); 

						case 'roundabout' | 'upheaval-teaser' | 'reheated' | 'lacuna' | 'antagonism-poip-part' | 'dethroned' | 'crimson corridor' | 'demise pt 1' | 'demise pt 2' | 'demise-pt-1' | 'demise-pt-2' | 'platonic':
							startSongNoCountDown(); // replace this l8 when there's dialogue

					default:
			    		startCountdown();
			}
			seenCutscene = true;
		} else {
			switch (curSong.toLowerCase())
			{
				case 'roundabout' | 'upheaval-teaser' | 'reheated' | 'lacuna' | 'antagonism-poip-part' | 'dethroned' | 'crimson corridor' | 'demise pt 1' | 'demise pt 2' | 'demise-pt-1' | 'demise-pt-2' | 'platonic':
					startSongNoCountDown();
				default:
		         	startCountdown();
			}
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');

		#if desktop
		// Updating Discord Rich Presence.
		iconRPC = iconP2.getCharacter();
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);

		super.create();

		cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		CustomFadeTransition.nextCamera = camOther;

		Paths.clearUnusedMemory();
	}

	static public function quickSpin(sprite)
		{
			FlxTween.angle(sprite, 0, 360, 0.5, {
				type: FlxTween.ONESHOT,
				ease: FlxEase.quadInOut,
				startDelay: 0,
				loopDelay: 0
			});
		}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		
		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		if(ClientPrefs.colorBars) {
     		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
		    	FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		} else {
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		}
			
		healthBar.updateBar();
	}

	public function reloadTimeBarColors() {
		if(ClientPrefs.colorBars) {
		    timeBar.createFilledBar(FlxColor.GRAY, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));
		} else {
			timeBar.createFilledBar(0xFF000000, 0xFF66FF33);
		}

		timeBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}
	#if windows
	  public function addShaderToCamera(cam:String,effect:ShaderEffect){//STOLE FROM ANDROMEDA
	  
	  
	  
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud':
					camHUDShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camHUDShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
					camOtherShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camOtherShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camOther.setFilters(newCamEffects);
			case 'camgame' | 'game':
					camGameShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camGameShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camGame.setFilters(newCamEffects);
			default:
				if(modchartSprites.exists(cam)) {
					Reflect.setProperty(modchartSprites.get(cam),"shader",effect.shader);
				} else if(modchartTexts.exists(cam)) {
					Reflect.setProperty(modchartTexts.get(cam),"shader",effect.shader);
				} else {
					var OBJ = Reflect.getProperty(PlayState.instance,cam);
					Reflect.setProperty(OBJ,"shader", effect.shader);
				}
			
			
				
				
		}
	  
	  
	  
	  
  }

  public function removeShaderFromCamera(cam:String,effect:ShaderEffect){
	  
	  
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': 
    camHUDShaders.remove(effect);
    var newCamEffects:Array<BitmapFilter>=[];
    for(i in camHUDShaders){
      newCamEffects.push(new ShaderFilter(i.shader));
    }
    camHUD.setFilters(newCamEffects);
			case 'camother' | 'other': 
					camOtherShaders.remove(effect);
					var newCamEffects:Array<BitmapFilter>=[];
					for(i in camOtherShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camOther.setFilters(newCamEffects);
			default: 
				camGameShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camGameShaders){
				  newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
		}
		
	  
  }
  #end
	
	
	
  public function clearShaderFromCamera(cam:String){
	  
	  
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': 
				camHUDShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camHUD.setFilters(newCamEffects);
			case 'camother' | 'other': 
				camOtherShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camOther.setFilters(newCamEffects);
			default: 
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camGame.setFilters(newCamEffects);
		}
		
	  
  }

  public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	public function startVideoDIALOGUE(name:String):Void
		{
			#if VIDEOS_ALLOWED
			inCutscene = true;
	
			var filepath:String = Paths.video(name);
			#if sys
			if(!FileSystem.exists(filepath))
			#else
			if(!OpenFlAssets.exists(filepath))
			#end
			{
				FlxG.log.warn('Couldnt find video file: ' + name);
				startAndEnd();
				return;
			}
	
			var video:MP4Handler = new MP4Handler();
			video.playVideo(filepath);
			video.finishCallback = function()
			{
				startAndEnd();
				return;
			}
			#else
			FlxG.log.warn('Platform not supported!');
			startAndEnd();
			return;
			#end
			if(endingSong) {
				endSong();
			} else {
				startDialogue(dialogueJson);
			}
		}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				switch (curSong.toLowerCase()) {
					case 'roundabout' | 'upheaval-teaser' | 'reheated' | 'lacuna' | 'antagonism-poip-part' | 'dethroned' | 'crimson corridor' | 'demise pt 1' | 'demise pt 2' | 'demise-pt-1' | 'demise-pt-2' | 'platonic':
						startSongNoCountDown();
					default:
			    		startCountdown();
				}
			}
		}
	}

	public function getBackgroundColor(stage:String):FlxColor
	{
		var variantColor:FlxColor = FlxColor.WHITE;
		switch (stage)
		{
			case 'bambiFarmNight' | 'daveHouse_night' | 'backyard' | 'bedroomNight':
				variantColor = nightColor;
			case 'bambiFarmSunset' | 'daveHouse_sunset':
				variantColor = sunsetColor;
			default:
				variantColor = FlxColor.WHITE;
		}
		return variantColor;
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					switch (curSong.toLowerCase()) {
					case 'roundabout' | 'upheaval-teaser' | 'reheated' | 'lacuna' | 'antagonism-poip-part' | 'dethroned' | 'crimson corridor' | 'demise pt 1' | 'demise pt 2' | 'demise-pt-1' | 'demise-pt-2' | 'platonic':
						startSongNoCountDown();
					default:
			    		startCountdown();
					}

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var midTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	// For being able to mess with the sprites on Lua
	public var countDownSprites:Array<FlxSprite> = [];

	function voidShader(background:BGSprite)
	{
		if (ClientPrefs.waving){
			var testshader:Shaders.GlitchEffect = new Shaders.GlitchEffect();
			testshader.waveAmplitude = 0.1;
			testshader.waveFrequency = 5;
			testshader.waveSpeed = 2;
		
			background.shader = testshader.shader;
			
			curbg = background;
		}
	}

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		if (SONG.song.toLowerCase() == 'deploration' || SONG.song.toLowerCase() == 'dishonored') {
			introAssets.set('default', ['ready', 'set', 'go_glitch']);
			introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date_glitch-pixel']);
		} else {
			introAssets.set('default', ['ready', 'set', 'go']);
			introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
		}

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel') introAlts = introAssets.get('pixel');
		
		for (asset in introAlts)
			Paths.image(asset);
		
		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
		Paths.sound('introGo_weird' + introSoundsSuffix);
	}

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		if (SONG.song.toLowerCase() == 'unfairness' || SONG.song.toLowerCase() == 'cheating')
		{
			if(cpuControlled || practiceMode)
			{
				FlxG.switchState(new SusState());
			}
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			#if android
			androidc.visible = true;
			#end

		    	generateStaticArrows(0);
		    	generateStaticArrows(1);
		    	for (i in 0...playerStrums.length) {
			     	setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
			    	setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			    }
		    	for (i in 0...opponentStrums.length) {
			    	setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
			    	setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
			    	if(ClientPrefs.middleScroll) opponentStrums.members[i].alpha = 0.35;
		    	}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			laneunderlay.x = playerStrums.members[0].x - 25;
			laneunderlayOpponent.x = opponentStrums.members[0].x - 25;
			
			laneunderlay.screenCenter(Y);
			laneunderlayOpponent.screenCenter(Y);

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance2();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}
				if (badai != null)
					{
						if (badai.animation.curAnim != null && !badai.animation.curAnim.name.startsWith("sing") && !badai.stunned)
						{
							badai.dance();
						}
				}
				if (dave != null)
					{
						if (tmr.loopsLeft % dave.danceEveryNumBeats == 0 && dave.animation.curAnim != null && !dave.animation.curAnim.name.startsWith("sing") && !dave.stunned)
						{
							dave.dance();
						}
				}
				if (bambi != null)
					{
						if (bambi.animation.curAnim != null && !bambi.animation.curAnim.name.startsWith("sing") && !bambi.stunned)
						{
							bambi.dance();
						}
				}
				if (bandu != null)
					{
						if (bandu.animation.curAnim != null && !bandu.animation.curAnim.name.startsWith("sing") && !bandu.stunned)
						{
							bandu.dance();
						}
				}
				if (bamburg != null)
					{
						if (bamburg.animation.curAnim != null && !bamburg.animation.curAnim.name.startsWith("sing") && !bamburg.stunned)
						{
							bamburg.dance();
						}
				}
				if (boyfriend2 != null)
					{
						if (tmr.loopsLeft % boyfriend2.danceEveryNumBeats == 0 && boyfriend2.animation.curAnim != null && !boyfriend2.animation.curAnim.name.startsWith('sing') && !boyfriend2.stunned)
						{
							boyfriend2.dance();
						}
				}
				
				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				if (SONG.song.toLowerCase() == 'deploration' || SONG.song.toLowerCase() == 'dishonored') {
					introAssets.set('default', ['ready', 'set', 'go_glitch']);
					introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date_glitch-pixel']);
				}
				else
				{
					introAssets.set('default', ['ready', 'set', 'go']);
					introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
				}

				switch (SONG.song.toLowerCase())
				{
		    	case 'polygonized':
					introAssets.set('default', ['dave/blank', 'dave/blank', 'dave/blank']);
				}

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel') {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);

					bottomBoppers.dance(true);
					santa.dance(true);
				}

				if (curSong == 'Roundabout')
				{
					swagCounter = 4;
				}

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						if(ClientPrefs.followarrow) isDadGlobal = false;
						if(ClientPrefs.followarrow) moveCamera(false);
					case 1:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel')
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						countdownReady.cameras = [camHUD];
						add(countdownReady);
						countDownSprites.push(countdownReady);
						FlxTween.tween(countdownReady, {y: countdownReady.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(countdownReady);
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					    if(ClientPrefs.followarrow)	isDadGlobal = true;
						if(ClientPrefs.followarrow) moveCamera(true);
					case 2:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel')
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						countdownSet.cameras = [camHUD];
						add(countdownSet);
						countDownSprites.push(countdownSet);
						FlxTween.tween(countdownSet, {y: countdownSet.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(countdownSet);
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						if(ClientPrefs.followarrow) isDadGlobal = false;
						if(ClientPrefs.followarrow) moveCamera(false);
					case 3:
						var countdownGo:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel')
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						countdownGo.cameras = [camHUD];
						add(countdownGo);
						countDownSprites.push(countdownGo);
						FlxTween.tween(countdownGo, {y:400}, 0.5, {ease: FlxEase.cubeOut});

						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						if (SONG.song.toLowerCase() == 'deploration' || SONG.song.toLowerCase() == 'dishonored') {
							FlxG.sound.play(Paths.sound('introGo_weird' + introSoundsSuffix), 0.6);
						}
						else 
						{
							FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						}
						if(ClientPrefs.followarrow) isDadGlobal = true;
						if(ClientPrefs.followarrow) moveCamera(true);
						strumLineNotes.forEach(function(note)
							{
								quickSpin(note);
							});
							if(isNormalStart) {
						    	FlxTween.tween(healthBar, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
						    	FlxTween.tween(healthBarBG, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
								FlxTween.tween(healthBarOverlay, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
						    	FlxTween.tween(iconP1, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
						    	FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 0.35);

						    	FlxTween.tween(scoreTxt, {alpha:1}, 0.35);
						    	FlxTween.tween(judgementCounter, {alpha:1}, 0.35);
					    		FlxTween.tween(songWatermark, {alpha:1}, 0.35);
						    	FlxTween.tween(creditsWatermark, {alpha:1}, 0.35);
							}

					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function startSongNoCountDown():Void
	{
		if (SONG.song.toLowerCase() == 'lacuna') {
	    	fartt = true;
		}

		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		var antialias:Bool = ClientPrefs.globalAntialiasing;
		if(isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel') {
			introAlts = introAssets.get('pixel');
			antialias = false;
		}

		inCutscene = false;

		if (SONG.song.toLowerCase() == 'upheaval-teaser') {
            isNormalStart = false;
		}

		#if android
		androidc.visible = true;
		#end


		    generateStaticArrows(0);
		    generateStaticArrows(1);
		    for (i in 0...playerStrums.length) {
			   	setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
		    }
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
			  	setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if(ClientPrefs.middleScroll) opponentStrums.members[i].alpha = 0.35;
		 	}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;

			var swagCounter:Int = 0;

			laneunderlay.x = playerStrums.members[0].x - 25;
			laneunderlayOpponent.x = opponentStrums.members[0].x - 25;
			
			laneunderlay.screenCenter(Y);
			laneunderlayOpponent.screenCenter(Y);

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance2();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}
				if (boyfriend2 != null)
					{
						if (tmr.loopsLeft % boyfriend2.danceEveryNumBeats == 0 && boyfriend2.animation.curAnim != null && !boyfriend2.animation.curAnim.name.startsWith('sing') && !boyfriend2.stunned)
						{
							boyfriend2.dance();
						}
				}

			switch (swagCounter)
				{
					case 3:
				}

				if(isNormalStart) {
					FlxTween.tween(healthBar, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(healthBarBG, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(healthBarOverlay, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(iconP1, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 0.35);

				/*	FlxTween.tween(healthBarBG, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(iconP1, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 0.35);
					 */ // i need to finish this uhhh uhhh

					FlxTween.tween(scoreTxt, {alpha:1}, 0.35);
					FlxTween.tween(judgementCounter, {alpha:1}, 0.35);
					FlxTween.tween(songWatermark, {alpha:1}, 0.35);
					FlxTween.tween(creditsWatermark, {alpha:1}, 0.35);
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
					}
				});

				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
	     	}, 5);

			strumLineNotes.forEach(function(note)
			{
				quickSpin(note);
			});
	}

	public function daCountDownMidSong():Void
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', 'set', 'go']);
			introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		var antialias:Bool = ClientPrefs.globalAntialiasing;
			if(isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel') {
				introAlts = introAssets.get('pixel');
				antialias = false;
			}

			var swagCounter:Int = 0;
			
			if (curSong == 'roundabout')
				{
					swagCounter = 4;
				}

			midTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				switch (swagCounter)

				{
					case 1:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 2:
						countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel')
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						countdownReady.cameras = [camHUD];
						add(countdownReady);
						countDownSprites.push(countdownReady);
						FlxTween.tween(countdownReady, {y: countdownReady.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(countdownReady);
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 3:
						countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel')
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						countdownSet.cameras = [camHUD];
						add(countdownSet);
						countDownSprites.push(countdownSet);
						FlxTween.tween(countdownSet, {y: countdownSet.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(countdownSet);
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 4:
						var countdownGo:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel')
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						countdownGo.cameras = [camHUD];
						add(countdownGo);
						countDownSprites.push(countdownGo);
						FlxTween.tween(countdownGo, {y:400}, 0.5, {ease: FlxEase.cubeOut});

						FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
				}

				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	function scoreZoom() {
		if(ClientPrefs.scoreZoom) 
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.065;
			scoreTxt.scale.y = 1.065;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.85, {
				ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
	}

	public function updateScore()
	{
		if (ClientPrefs.uiStyle == 'Purgatory') {
			scoreTxt.text =  'NPS: ' + nps
			+ ' (Max ' + maxNPS + ')' 
			+ ' | ' + 'Score: ' + songScore 
			+ ' | Combo Breaks: ' + songMisses 
			+ ' | Accuracy: ' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%' 
			+ ' | '
			+ (ratingName != '?' ? '($ratingFC) ' + ratingName : 'N/A');
		}
		if (ClientPrefs.uiStyle == 'Kade Engine') {
			scoreTxt.text =  'NPS:' + nps
			+ ' (Max ' + maxNPS + ')' 
			+ ' | ' + 'Score:' + songScore 
			+ ' | Combo Breaks:' + songMisses 
			+ ' | Accuracy:' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%' 
			+ ' | '
			+ (ratingName != '?' ? '($ratingFC) ' + ratingName : 'N/A');
		}
		if (ClientPrefs.uiStyle == 'Psych Engine') {
			scoreTxt.text = 'Score: ' + songScore
			+ ' | Misses: ' + songMisses
			+ ' | Rating: ' + ratingNamePsych
			+ (ratingNamePsych != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');
		}
		if (ClientPrefs.uiStyle == 'Dave Engine') {
			scoreTxt.text = 'Score:' + songScore
			+ ' | Misses:' + songMisses
			+ ' | Accuracy:' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%';
		}
		callOnLuas('onUpdateScore', []);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		for (dicknballs in [composersText, ballsText]) {
			if (dicknballs != null) {
				FlxTween.tween(dicknballs, {x:0}, 1.5, {
					ease: FlxEase.elasticInOut
				});

				FlxTween.tween(dicknballs, {x:-1000}, 1.5, {
					startDelay: 6 / playbackRate,
					onComplete: function(tween:FlxTween) {
						remove(dicknballs);
					},
					ease: FlxEase.elasticInOut
				});
			}
		}
		switch (SONG.song.toLowerCase())
		{
			case 'exploitation':
				blackScreen = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				blackScreen.cameras = [camHUD];
				blackScreen.screenCenter();
				blackScreen.scrollFactor.set();
				blackScreen.alpha = 0;
				add(blackScreen);
					
				Application.current.window.title = "[DATA EXPUNGED]";
				Application.current.window.setIcon(lime.graphics.Image.fromFile("art/icons/AAAA.png"));
		}

		switch(curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength / playbackRate);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	var isFunnySong = false;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		if(ClientPrefs.scroll) {
			songSpeed = ClientPrefs.speed;
		}

		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note;
				if(PlayState.SONG.isSkinSep) {
					if (gottaHitNote){
						swagNote = new Note(daStrumTime, daNoteData, oldNote, false, false, true);
					} else {
						 swagNote = new Note(daStrumTime, daNoteData, oldNote);
					}
				} else {
					swagNote = new Note(daStrumTime, daNoteData, oldNote);
				}
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note;
						if(PlayState.SONG.isSkinSep) {
							 //checks if its a player note, if it is, then it turns it into a note that DOESNT use the custom style
							if (gottaHitNote){
								sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true, false, true);
							} else {
								sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
							}
						} else { 
							sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						}
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}

		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);


			case 'Philly Glow':
				blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				blammedLightsBlack.visible = false;
				insert(members.indexOf(phillyStreet), blammedLightsBlack);

				phillyWindowEvent = new BGSprite('philly/window', phillyWindow.x, phillyWindow.y, 0.3, 0.3);
				phillyWindowEvent.setGraphicSize(Std.int(phillyWindowEvent.width * 0.85));
				phillyWindowEvent.updateHitbox();
				phillyWindowEvent.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyWindowEvent);


				phillyGlowGradient = new PhillyGlow.PhillyGlowGradient(-400, 225); //This shit was refusing to properly load FlxGradient so fuck it
				phillyGlowGradient.visible = false;
				insert(members.indexOf(blammedLightsBlack) + 1, phillyGlowGradient);
				if(!ClientPrefs.flashing) phillyGlowGradient.intendedAlpha = 0.7;

				precacheList.set('philly/particle', 'image'); //precache particle image
				phillyGlowParticles = new FlxTypedGroup<PhillyGlow.PhillyGlowParticle>();
				phillyGlowParticles.visible = false;
				insert(members.indexOf(phillyGlowGradient) + 1, phillyGlowParticles);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(!dontMiddle.contains(SONG.song.toLowerCase()) && ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	private var swagThings:FlxTypedGroup<FlxSprite>;

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, (songLength - Conductor.songPosition - ClientPrefs.noteOffset) / playbackRate);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, (songLength - Conductor.songPosition - ClientPrefs.noteOffset) / playbackRate);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	var speed:Float = 1.0;

	private var poipInMahPahntsIsGud:Bool = true;

	private var banduJunk:Float = 0;
	private var dadFront:Bool = false;
	private var hasJunked:Bool = false;
	private var wtfThing:Bool = false;
	private var orbit:Bool = true;
	private var unfairPart:Bool = false;
	private var noteJunksPlayer:Array<Float> = [0, 0, 0, 0];
	private var noteJunksDad:Array<Float> = [0, 0, 0, 0];
	private var what:FlxTypedGroup<FlxSprite>;
	private var wow2:Array<Array<Float>> = [];
	private var gasw2:Array<Float> = [];
	private var poiping:Bool = true;
	private var canPoip:Bool = true;
	private var lanceyLovesWow2:Array<Bool> = [false, false];
	private var whatDidRubyJustSay:Int = 0;

	override public function update(elapsed:Float)
	{
	elapsedtime += elapsed;


	if (curbg != null)
	{
		if (curbg.active) // only the furiosity background is active
		{
			var shad = cast(curbg.shader, Shaders.GlitchShader);
			shad.uTime.value[0] += elapsed;
		}
	}
	if(redTunnel != null)
	{
		redTunnel.angle += elapsed * 3.5;
	}
	if(redTunnel2 != null)
	{
		redTunnel2.angle += elapsed * 3.5;
	}
	if(purpleTunnel != null)
	{
		purpleTunnel.angle += elapsed * 3.5;
	}
	banduJunk += elapsed * 2.5;
	if(badaiTime)
	{
		dad.angle += elapsed * 0;
	}
	if(banduTime)
	{
		dad.angle += elapsed * 0;
	}

	if (SONG.song.toLowerCase() == 'devastation') {

		/*if (poiping) {
			what.forEach(function(spr:FlxSprite){
				spr.x += Math.abs(Math.sin(elapsed)) * gasw2[spr.ID];
				if (spr.x > 3000 && !lanceyLovesWow2[spr.ID]) {
					lanceyLovesWow2[spr.ID] = true;
					trace('whattttt ${spr.ID}');
					whatDidRubyJustSay++;
				}
			});
			if (whatDidRubyJustSay >= 2) poiping = false;
		}
		else if (canPoip) {
			trace("ON TO THE POIPIGN!!!");
			canPoip = false;
			lanceyLovesWow2 = [false, false];
			whatDidRubyJustSay = 0;
			new FlxTimer().start(FlxG.random.float(3, 6.3), function(tmr:FlxTimer){
				what.forEach(function(spr:FlxSprite){
					spr.visible = true;
					spr.x = FlxG.random.int(-2000, -3000);
					gasw2[spr.ID] = FlxG.random.int(600, 1200);
					if (spr.ID == 1) {
						trace("POIPING...");
						poiping = true;
						canPoip = true;
					}
				});
			});
		}
		what.forEach(function(spr:FlxSprite){
			var daCoords = wow2[spr.ID];
			daCoords[4] == 1 ? 
			spr.y = Math.cos(elapsedtime + spr.ID) * daCoords[3] + daCoords[1]: 
			spr.y = Math.sin(elapsedtime) * daCoords[3] + daCoords[1];
			spr.y += 45;
			var dontLookAtAmongUs:Float = Math.sin(elapsedtime * 1.5) * 0.05 + 0.95;
			spr.scale.set(dontLookAtAmongUs - 0.15, dontLookAtAmongUs - 0.15);
			if (dad.POOP) spr.angle += (Math.sin(elapsed * 2) * 0.5 + 0.5) * spr.ID == 1 ? 0.65 : -0.65;
		});*/

		playerStrums.forEach(function(spr:FlxSprite){
			noteJunksPlayer[spr.ID] = spr.y;
		});
		opponentStrums.forEach(function(spr:FlxSprite){
			noteJunksDad[spr.ID] = spr.y;
		});
		if (unfairPart) {
			playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin(elapsedtime + (spr.ID)) * 300);
				spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos(elapsedtime + (spr.ID)) * 300);
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin((elapsedtime + (spr.ID )) * 2) * 300);
				spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos((elapsedtime + (spr.ID)) * 2) * 300);
			});
		}
		if (SONG.notes[Math.floor(curStep / 16)] != null) {
			if (SONG.notes[Math.floor(curStep / 16)].altAnim && !unfairPart) {
				var krunkThing = 60;
				poopStrums.forEach(function(spr:StrumNote)
				{
					spr.x = arrowJunks[spr.ID + 4][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
					spr.y = swagThings.members[spr.ID].y + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;

					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / 4;

					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / 2);

					spr.scale.x += 0.2;
					spr.scale.y += 0.2;
					
					spr.scale.x *= 1.5;
					spr.scale.y *= 1.5;
				});

				altNotes.forEachAlive(function(spr:Note){
					spr.x = arrowJunks[(spr.noteData % 4) + 4][0] + (Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing;
					#if debug
					if (FlxG.keys.justPressed.SPACE) {
						trace(arrowJunks[(spr.noteData % 4) + 4][0]);
						trace(spr.noteData);
						trace(spr.x == arrowJunks[(spr.noteData % 4) + 4][0] + (Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing);
					}
					#end
				});
			}
			if (!SONG.notes[Math.floor(curStep / 16)].altAnim && wtfThing) {
				
				
			}
		}

		
	}
	
	var toy = -100 + -Math.sin((curStep / 9.5) * 2) * 30 * 5;
	var tox = -330 -Math.cos((curStep / 9.5)) * 100;

    //welcome to 3d sinning avenue
	if(funnyFloatyBoys.contains(dad.curCharacter.toLowerCase()) && canFloat && orbit)
	{
		switch(dad.curCharacter) 
		{
			case 'bandu-candy':
				dad.x += Math.sin(elapsedtime * 50) / 9;
			case 'trueexpunged':
				dad.x += (tox - dad.x) / 12;
				dad.y += (toy - dad.y) / 12;
			case 'badai':
				dad.angle += elapsed * 10;
				dad.y += (Math.sin(elapsedtime) * 0.6);
			default:
				dad.y += (Math.sin(elapsedtime) * 0.6);
		}
	}
	if(badai != null)
	{
		switch(badai.curCharacter) 
		{
			case 'badai':
				badai.angle = Math.sin(elapsedtime) * 15;
				badai.x += Math.sin(elapsedtime) * 0.6;
				badai.y += (Math.sin(elapsedtime) * 0.6);
			default:
				badai.y += (Math.sin(elapsedtime) * 0.6);
		}
	}
	if(bamburg != null)
	{
		switch(bamburg.curCharacter) 
		{
			case 'bamburg':
				bamburg.y += (Math.sin(elapsedtime) * 0.6);
			case 'bombai':
				bamburg.x += (Math.cos(elapsedtime) * 0.6);
				bamburg.y += (Math.sin(elapsedtime) * 0.6);
		}
	}
	if(dave != null)
		{
			switch(dave.curCharacter) 
			{
				case 'crimson-dave':
					dave.y += (Math.sin(elapsedtime) * 0.6);
			}
		}
	if(bandu != null)
	{
		switch(bandu.curCharacter) 
		{
			case 'bandu':
				bandu.x += (Math.sin(elapsedtime) * 0.6);
			default:
				bandu.x += (Math.sin(elapsedtime) * 0.6);
		}
	}
	if (littleIdiot != null) {
		if(funnyFloatyBoys.contains(littleIdiot.curCharacter.toLowerCase()) && canFloat && poipInMahPahntsIsGud)
		{
			littleIdiot.y += (Math.sin(elapsedtime) * 0.75);
			littleIdiot.x = 200 + Math.sin(elapsedtime) * 425;
		}
	}
	if (swaggy != null) {
		if(funnyFloatyBoys.contains(swaggy.curCharacter.toLowerCase()) && canSlide)
		{
			swaggy.x += (Math.sin(elapsedtime) * 1.4);
		}
	}
	if(funnySideFloatyBoys.contains(dad.curCharacter.toLowerCase()) && canSlide)
	{
		dad.x += (Math.cos(elapsedtime) * 0.6);
	}
	if(funnyFloatyBoys.contains(boyfriend.curCharacter.toLowerCase()) && canFloat)
	{
		boyfriend.y += (Math.sin(elapsedtime) * 0.6);
	}

	if (SONG.song.toLowerCase() == 'cheating') // fuck you
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.x -= Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1);
				spr.x += Math.sin(elapsedtime) * 1.5;
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x += Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1);
				spr.x -= Math.sin(elapsedtime) * 1.5;
			});
		}
	if (SONG.song.toLowerCase() == 'technology')
	{
				playerStrums.forEach(function(spr:FlxSprite)
				{
				    spr.y += Math.sin(elapsedtime) * ((spr.ID % 0.2) == 0 ? 0.005 : -0.005);
				    spr.y -= Math.sin(elapsedtime) * 0.05;
					spr.x -= Math.sin(elapsedtime) * ((spr.ID % 0.1) == 0 ? 0 : -0);
					spr.x += Math.sin(elapsedtime) * 0.1;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
				    spr.y -= Math.sin(elapsedtime) * ((spr.ID % 0.2) == 0 ? 0.005 : -0.005);
				    spr.y += Math.sin(elapsedtime) * 0.05;
					spr.x -= Math.sin(elapsedtime) * ((spr.ID % 0.1) == 0 ? 0 : -0);
					spr.x += Math.sin(elapsedtime) * 0.1;
			    });
	}
	if (SONG.song.toLowerCase() == 'disposition')
			{
				if (ClientPrefs.laneunderlay){
				    laneunderlay.x -= Math.sin(elapsedtime) * 1.3;
					laneunderlayOpponent.visible = false;
				}

				for(str in opponentStrums)
				{
					str.angle = 60*Math.cos((elapsedtime*2)+str.ID*2);
					str.y = strumLine.y+(20*Math.sin((elapsedtime*2)+str.ID*2));
				}

		    	playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 0.005 : -0.005);
					spr.x -= Math.sin(elapsedtime) * 1.5;
		    	});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += Math.sin(elapsedtime) * 1.3;

					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / 4;
	
					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / 2);
	
					spr.scale.x += 0.3;
					spr.scale.y += 0.3;
	
					spr.scale.x *= 1.15;
					spr.scale.y *= 1.15;
				});
			}
	if (SONG.song.toLowerCase() == 'disposition_but_awesome')
		    {
				if (ClientPrefs.laneunderlay){
				    laneunderlay.x -= Math.sin(elapsedtime) * 1.3;
					laneunderlayOpponent.visible = false;
				}

				for(str in opponentStrums)
				{
					str.angle = 60*Math.cos((elapsedtime*2)+str.ID*2);
					str.y = strumLine.y+(20*Math.sin((elapsedtime*2)+str.ID*2));
				}

		    	playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 0.005 : -0.005);
					spr.x -= Math.sin(elapsedtime) * 1.5;
		    	});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += Math.sin(elapsedtime) * 1.3;

					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / 4;
	
					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / 2);
	
					spr.scale.x += 0.3;
					spr.scale.y += 0.3;
	
					spr.scale.x *= 1.15;
					spr.scale.y *= 1.15;
				});
			}
	if (SONG.song.toLowerCase() == 'reality breaking' && ClientPrefs.chromaticAberration)
		{
			
			#if windows
			grain_shader.update(elapsed);
			if(stupidInt > 0 && !stupidBool)
				{
					grain_shader.shader.grainsize.value = [FlxG.random.float(1, 2)];
					grain_shader.shader.lumamount.value = [FlxG.random.float(1, 2)];
					if(ClientPrefs.chromaticAberration)
						{
							shader_chromatic_abberation.setChrome(FlxG.random.float(0.01, 0.015));
						}
					stupidInt -= 1;
				}
			else if(!stupidBool)
				{
					doneloll2 = false;
				}
			else
				{
					if(ClientPrefs.chromaticAberration)
						{
					shader_chromatic_abberation.setChrome(FlxG.random.float(0.01, 0.015));
						}
					grain_shader.shader.grainsize.value = [FlxG.random.float(1, 2)];
					grain_shader.shader.lumamount.value = [FlxG.random.float(1, 2)];
				}
			if(!doneloll2)
				{
					grain_shader.shader.grainsize.value = [0.01];
					grain_shader.shader.lumamount.value = [0.05];
					if(ClientPrefs.chromaticAberration)
						{
					shader_chromatic_abberation.setChrome(FlxG.random.float(0.003, 0.005));
						}
				}
			#end
		}
	if (SONG.song.toLowerCase() == 'unfairness') // fuck you x2
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin(elapsedtime + (spr.ID)) * 300);
					spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos(elapsedtime + (spr.ID)) * 300);
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin((elapsedtime + (spr.ID )) * 2) * 300);
					spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos((elapsedtime + (spr.ID)) * 2) * 300);
				});
			}

		if (oppositionMoment)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 12) - (spr.width / 7)) + (Math.sin(elapsedtime + (spr.ID)) * 500);
				spr.x += 500; 
				spr.y += Math.sin(elapsedtime) * Math.random();
				spr.y -= Math.sin(elapsedtime) * 1.3;
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 12) - (spr.width / 7)) + (Math.sin((elapsedtime + (spr.ID )) * 2) * 500);
				spr.x += 500; 
				spr.y += Math.sin(elapsedtime) * Math.random();
				spr.y -= Math.sin(elapsedtime) * 1.3;
			});

			for(str in playerStrums)
			{
				str.angle = -360*Math.cos((elapsedtime*2)+str.ID*2);
			}
			
			for(str in opponentStrums)
			{
				str.angle = 360*Math.cos((elapsedtime*2)+str.ID*2);
			}
		}
	if (SONG.song.toLowerCase() == 'unfairness-remix') // fuck you x2
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin(elapsedtime + (spr.ID)) * 300);
					spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos(elapsedtime + (spr.ID)) * 300);
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = ((FlxG.width / 2) - (spr.width / 2)) + (Math.sin((elapsedtime + (spr.ID )) * 2) * 300);
					spr.y = ((FlxG.height / 2) - (spr.height / 2)) + (Math.cos((elapsedtime + (spr.ID)) * 2) * 300);
				});
			}

		if (oppositionMoment)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 12) - (spr.width / 7)) + (Math.sin(elapsedtime + (spr.ID)) * 500);
				spr.x += 500; 
				spr.y += Math.sin(elapsedtime) * Math.random();
				spr.y -= Math.sin(elapsedtime) * 1.3;
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 12) - (spr.width / 7)) + (Math.sin((elapsedtime + (spr.ID )) * 2) * 500);
				spr.x += 500; 
				spr.y += Math.sin(elapsedtime) * Math.random();
				spr.y -= Math.sin(elapsedtime) * 1.3;
			});

			for(str in playerStrums)
			{
				str.angle = -360*Math.cos((elapsedtime*2)+str.ID*2);
			}
			
			for(str in opponentStrums)
			{
				str.angle = 360*Math.cos((elapsedtime*2)+str.ID*2);
			}
		}
	/*if (SONG.song.toLowerCase() == 'furiosity') // is cool, ratio
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.y += Math.sin(elapsedtime) * Math.random();
					spr.y -= Math.sin(elapsedtime) * 0.3;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.y -= Math.sin(elapsedtime) * Math.random();
					spr.y += Math.sin(elapsedtime) * 0.3;
				});
			}*/ // leaving these here mostly for archive
	if (SONG.song.toLowerCase() == 'devastation') // oh shit
		{
			if (curStep > 1280 && curStep < 3232)
			{
				playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.y += Math.sin(elapsedtime) * ((spr.ID % 0.2) == 0 ? 0.005 : -0.005);
						spr.y -= Math.sin(elapsedtime) * 0.05;
						spr.x -= Math.sin(elapsedtime) * ((spr.ID % 0.1) == 0 ? 0 : -0);
						spr.x += Math.sin(elapsedtime) * 0.1;
					});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.y -= Math.sin(elapsedtime) * ((spr.ID % 0.2) == 0 ? 0.005 : -0.005);
					spr.y += Math.sin(elapsedtime) * 0.05;
					spr.x -= Math.sin(elapsedtime) * ((spr.ID % 0.1) == 0 ? 0 : -0);
					spr.x += Math.sin(elapsedtime) * 0.1;
				});
			}
			if (curStep > 3232)
			{
				for(str in playerStrums)
				{
					str.angle = 15*Math.cos((elapsedtime*2)+str.ID*2);
					str.y = strumLine.y+(40*Math.sin((elapsedtime*2)+str.ID*2));
				}

				for(str in opponentStrums)
				{
					str.angle = 15*Math.cos((elapsedtime*2)+str.ID*2);
					str.y = strumLine.y+(40*Math.sin((elapsedtime*2)+str.ID*2));
				}
			}
		}
	if (SONG.song.toLowerCase() == 'devastation-fanmade') // oh shit
		{
			if (curStep > 1280 && curStep < 3448)
			{
				playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.y += Math.sin(elapsedtime) * ((spr.ID % 0.2) == 0 ? 0.005 : -0.005);
						spr.y -= Math.sin(elapsedtime) * 0.05;
						spr.x -= Math.sin(elapsedtime) * ((spr.ID % 0.1) == 0 ? 0 : -0);
						spr.x += Math.sin(elapsedtime) * 0.1;
					});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.y -= Math.sin(elapsedtime) * ((spr.ID % 0.2) == 0 ? 0.005 : -0.005);
					spr.y += Math.sin(elapsedtime) * 0.05;
					spr.x -= Math.sin(elapsedtime) * ((spr.ID % 0.1) == 0 ? 0 : -0);
					spr.x += Math.sin(elapsedtime) * 0.1;
				});
			}
			if(curStep > 3456 && curStep < 4800)
			{
				if (ClientPrefs.laneunderlay){
					laneunderlayOpponent.visible = false;
					laneunderlay.visible = false;
				}
		    	playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 0.005 : -0.005);
					spr.x -= Math.sin(elapsedtime) * 1.1;
		    	});
			    opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x -= Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 0.005 : -0.005);
					spr.x += Math.sin(elapsedtime) * 1.1;
				});
			}
			if (curStep > 4800)
			{
				if (ClientPrefs.laneunderlay){
					laneunderlayOpponent.visible = true;
					laneunderlay.visible = true;
				}
				for(str in playerStrums)
				{
					str.angle = 15*Math.cos((elapsedtime*2)+str.ID*2);
					str.y = strumLine.y+(40*Math.sin((elapsedtime*2)+str.ID*2));
				}

				for(str in opponentStrums)
				{
					str.angle = 15*Math.cos((elapsedtime*2)+str.ID*2);
					str.y = strumLine.y+(40*Math.sin((elapsedtime*2)+str.ID*2));
				}
			}
		}
	if(SONG.song.toLowerCase() == 'rebound')
	{
		for(str in playerStrums)
		{
			str.angle = 15*Math.cos((elapsedtime*2)+str.ID*2);
			str.y = strumLine.y+(40*Math.sin((elapsedtime*2)+str.ID*2));
		}

		for(str in opponentStrums)
		{
		    str.angle = 15*Math.cos((elapsedtime*2)+str.ID*2);
			str.y = strumLine.y+(40*Math.sin((elapsedtime*2)+str.ID*2));
		}
	}
	if(SONG.song.toLowerCase() == 'despair')
	{
		for(str in playerStrums)
		{
			str.angle = 15*Math.cos((elapsedtime*2)+str.ID*2);
			str.y = strumLine.y+(40*Math.sin((elapsedtime*2)+str.ID*2));
		}

		for(str in opponentStrums)
		{
		    str.angle = 15*Math.cos((elapsedtime*2)+str.ID*2);
			str.y = strumLine.y+(40*Math.sin((elapsedtime*2)+str.ID*2));
		}
		if (curBeat > 515)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 12) - (spr.width / 7)) + (Math.sin(elapsedtime + (spr.ID)) * 500);
				spr.x += 500; 
				spr.y += Math.sin(elapsedtime) * Math.random();
				spr.y -= Math.sin(elapsedtime) * 1.3;
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x = ((FlxG.width / 12) - (spr.width / 7)) + (Math.sin((elapsedtime + (spr.ID )) * 2) * 500);
				spr.x += 500; 
				spr.y += Math.sin(elapsedtime) * Math.random();
				spr.y -= Math.sin(elapsedtime) * 1.3;
			});

			for(str in playerStrums)
			{
				str.angle = -360*Math.cos((elapsedtime*2)+str.ID*2);
			}
			
			for(str in opponentStrums)
			{
				str.angle = 360*Math.cos((elapsedtime*2)+str.ID*2);
			}
		}
	}
	    	if (SONG.song.toLowerCase() == 'disruption') // deez all day
				{
				var krunkThing = 60;
	
				poop.alpha = Math.sin(elapsedtime) / 2.5 + 0.4;
	
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = arrowJunks[spr.ID + 4][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
					spr.y = arrowJunks[spr.ID + 4][1] + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;
	
					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / 4;
	
					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / 2);

					spr.scale.x += 0.2;
					spr.scale.y += 0.2;

					spr.scale.x *= 1.5;
					spr.scale.y *= 1.5;
				});
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x = arrowJunks[spr.ID][0] + (Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) * krunkThing;
					spr.y = arrowJunks[spr.ID][1] + Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1) * krunkThing;
	
					spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.ID % 2) == 0 ? 1 : -1)) / 4;
	
					spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.ID % 2) == 0 ? 1 : -1)) / 2);
	
					spr.scale.x += 0.2;
					spr.scale.y += 0.2;
	
					spr.scale.x *= 1.5;
		     		spr.scale.y *= 1.5;
				});
	
				notes.forEachAlive(function(spr:Note){
					if (spr.mustPress) {
						spr.x = arrowJunks[spr.noteData + 4][0] + (Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing;
						spr.y = arrowJunks[spr.noteData + 4][1] + Math.sin(elapsedtime - 5) * ((spr.noteData % 2) == 0 ? 1 : -1) * krunkThing;

						spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.noteData % 2) == 0 ? 1 : -1)) / 4;

						spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) / 2);
	
						spr.scale.x += 0.2;
						spr.scale.y += 0.2;

						spr.scale.x *= 1.5;
						spr.scale.y *= 1.5;
						}
				     	else
					    {
						spr.x = arrowJunks[spr.noteData][0] + (Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) * krunkThing;
						spr.y = arrowJunks[spr.noteData][1] + Math.sin(elapsedtime - 5) * ((spr.noteData % 2) == 0 ? 1 : -1) * krunkThing;

						spr.scale.x = Math.abs(Math.sin(elapsedtime - 5) * ((spr.noteData % 2) == 0 ? 1 : -1)) / 4;
	
						spr.scale.y = Math.abs((Math.sin(elapsedtime) * ((spr.noteData % 2) == 0 ? 1 : -1)) / 2);
	
						spr.scale.x += 0.2;
						spr.scale.y += 0.2;
	
						spr.scale.x *= 1.5;
						spr.scale.y *= 1.5;
					}
				});
	    	}
			if(badai != null)
			{
				if ((badai.animation.finished || badai.animation.curAnim.name == 'idle') && badai.holdTimer <= 0 && curBeat % 2 == 0)
					badai.dance();
			}
			if(bambi != null)
			{
				if ((bambi.animation.finished || bambi.animation.curAnim.name == 'idle') && bambi.holdTimer <= 0 && curBeat % 2 == 0)
					bambi.dance();
			}
			if(dave != null)
			{
				if ((dave.animation.finished || dave.animation.curAnim.name == 'idle') && dave.holdTimer <= 0 && curBeat % 2 == 0)
					dave.dance();
			}
			if(bandu != null)
			{
				if ((bandu.animation.finished || bandu.animation.curAnim.name == 'idle') && bandu.holdTimer <= 0 && curBeat % 2 == 0)
					bandu.dance();
			}
			if(bamburg != null)
			{
				if ((bamburg.animation.finished || bamburg.animation.curAnim.name == 'idle') && bamburg.holdTimer <= 0 && curBeat % 2 == 0)
					bamburg.dance();
			}
			if (swaggy != null) {
				if (swaggy.holdTimer <= 0 && curBeat % 2 == 0 && swaggy.animation.finished)
					swaggy.dance();
			}
			if (swagBombu != null) {
				if (swagBombu.holdTimer <= 0 && curBeat % 2 == 0 && swagBombu.animation.finished)
					swagBombu.dance();
			}
			if (littleIdiot != null) {
				if (littleIdiot.animation.finished && littleIdiot.holdTimer <= 0 && curBeat % 2 == 0) littleIdiot.dance();
			}

		#if windows
		if (SONG.song.toLowerCase() != 'lacuna') {
	    	FlxG.camera.setFilters([new ShaderFilter(screenshader.shader)]); // this is very stupid but doesn't effect memory all that much so
		}
		if (SONG.song.toLowerCase() == 'lacuna') {
			camHUD.setFilters([new ShaderFilter(screenshader.shader)]);
		}
		#end
		if (shakeCam && eyesoreson)
		{
			if (SONG.song.toLowerCase() != 'lacuna') {
		    	FlxG.camera.shake(0.015, 0.015);
		    	if(gf.animOffsets.exists('scared')) {
	     			gf.playAnim('scared', true);
		    	}
		    }
			if (SONG.song.toLowerCase() == 'lacuna') {
				camHUD.shake(0.010, 0.010);
			}
		}
		if (shakeCamALT && eyesoreson)
		{
			FlxG.camera.shake(0.015, 0.015);
			if(gf.animOffsets.exists('scared')) {
				gf.playAnim('scared', true);
			}
			/*if(boyfriend.animOffsets.exists('scared')) {
				boyfriend.playAnim('scared', true);
			}*/
		}
		screenshader.shader.uTime.value[0] += elapsed;
		if (shakeCam && eyesoreson) {
			screenshader.shader.uampmul.value[0] = 1;
		} else {
			screenshader.shader.uampmul.value[0] -= (elapsed / 2);
		}
		screenshader.Enabled = shakeCam && eyesoreson;

		if (daspinlmao)
		{
			camHUD.angle += elapsed * 30;
		}

		if (daleftspinlmao)
		{
			camHUD.angle -= elapsed * 30;
		} 
	
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}
	/*if (FlxG.keys.justPressed.NINE)
	{
		iconP1.swapOldIcon();
	}*/

	if (SONG.stage == 'bambersHell') { // curStage didnt work for some reason wtf
		gridSine += 180 * elapsed;
		gridBG.alpha = 1 - Math.sin((Math.PI * gridSine) / 180);

		bgshitH.y += (Math.sin(elapsedtime*0.7) * 0.55);
		bgshitH2.y += (Math.sin(elapsedtime*0.6) * 0.5);
		cloudsH.x += (Math.sin(elapsedtime*0.45) * 0.75);
	}

	if (SONG.stage == 'demiseStage') { // curStage didnt work for some reason wtf
		gridSine += 180 * elapsed;
		gridBG.alpha = 1 - Math.sin((Math.PI * gridSine) / 180);

		bgshitH.y += (Math.sin(elapsedtime*0.7) * 0.55);
		bgshitH2.y += (Math.sin(elapsedtime*0.6) * 0.5);
		cloudsH.x += (Math.sin(elapsedtime*0.45) * 0.75);
	}

	switch (SONG.song.toLowerCase())
	{
		case 'disregard':
			switch (curBeat)
			{
				case 0:
					bambi.visible = true;
					dave.visible = true;
					iconP2.changeIcon('the_trio');
			}
		case 'devastation':
			switch (curBeat)
			{
				case 0:
					add(blackScreen2);
					blackScreen2.alpha = 0;
					bandu.visible = true;
					devaDave.visible = false;
					iconP2.changeIcon('bandu_and_bamburg');
				case 320: //note to self: 1280
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 0.5);
					bandu.visible = false;
					devaBurger.visible = false;
					devaLaptop.active = true;
					curbg = devaLaptop;
				case 744:
					FlxTween.tween(camHUD, {alpha:0}, 25.6);
					FlxTween.tween(blackScreen2, {alpha:1}, 25.6);
				case 808: //note to self: 3232
					health = 2;
					devaBurger.visible = false;
					devaLaptop.visible = false;
					devaExpunged.active = true;
					curbg = devaExpunged;
				case 824:
					FlxTween.tween(camHUD, {alpha:1}, 11.2);
					FlxTween.tween(blackScreen2, {alpha:0}, 11.2);
				case 1336:
					FlxTween.tween(camHUD, {alpha:0}, 13.65);
					FlxTween.tween(blackScreen2, {alpha:1}, 13.65);
			}
		case 'devastation-fanmade':
			switch (curBeat)
			{
				case 0:
					add(blackScreen2);
					blackScreen2.alpha = 1;
					bandu.visible = true;
					bamburg.visible = false;
					iconP2.changeIcon('bandu_and_bamburg');
				case 1:
					FlxTween.tween(blackScreen2, {alpha:0}, 13.5);
				case 272:
					blackScreen2.alpha = 1;
					FlxTween.tween(blackScreen2, {alpha:0}, 6);
				case 320: //note to self: 1280
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 0.5);
					bandu.visible = false;
					devaBurger.visible = false;
					devaDave.visible = false;
					devaLaptop.active = true;
					curbg = devaLaptop;
					health = 1;
				case 352:
					camZoomSnap = true;
				case 416:
					camZoomSnap = false;
				case 432:
					camZoomSnap = true;
				case 480:
					camZoomSnap = false;
				case 512:
					camZoomSnap = true;
				case 544:
					camZoomSnap = false;
				case 592:
					camZoomSnap = true;
				case 640:
					camZoomSnap = false;
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					bamburg.visible = true;
					iconP2.changeIcon('bombu_and_bamburg');
					health = 1;
				case 832:
					FlxTween.tween(blackScreen2, {alpha:1}, 13.29);
				case 864:
					devaLaptop.visible = false;
					devaLaptop.active = false;
					devaDave.visible = true;
					devaDave.active = true;
					FlxTween.tween(blackScreen2, {alpha:0}, 12);
					bamburg.visible = false;
					curbg = devaDave;
					health = 1;
				case 928:
					camZoomHalfSnap = true;
				case 992:
					camZoomHalfSnap = false;
				case 1024:
					camZoomHalfSnap = true;
				case 1056:
					camZoomHalfSnap = false;
				case 1088:
					camZoomHalfSnap = true;
				case 1168:
					FlxTween.tween(blackScreen2, {alpha:1}, 6.86);
				case 1184:
					camZoomHalfSnap = false;
				case 1200:
					FlxTween.tween(blackScreen2, {alpha:0}, 6.85);
					devaDave.active = false;
					devaDave.visible = false;
					devaExpunged.active = true;
					devaExpunged.visible = true;
					curbg = devaExpunged;
					health = 1;
				case 2152:
					FlxTween.tween(blackScreen2, {alpha:1}, 8.57);
			}
		case 'antagonism-11-minutes':
			switch(curBeat)
			{
				case 0:
					FlxTween.tween(badai, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redBG, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redTunnel, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
				case 292:
					FlxTween.tween(dad, {"scale.x": 0, "scale.y": 0}, 1, {ease: FlxEase.quadIn});
					FlxTween.tween(iconP2, {alpha:0}, 10);
					redTunnel.active = true;
					redTunnel.visible = true;
					FlxTween.tween(FlxG.camera, {zoom: 0.67}, 3, {ease: FlxEase.expoOut,});	
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 5, {ease: FlxEase.circInOut});
				case 350:
					badai.visible = true;
					FlxTween.tween(badai, {"scale.x": 1, "scale.y": 1}, 1, {ease: FlxEase.cubeOut});
				case 356:
					redBG.visible = true;
					redBG.active = true;
					FlxG.camera.flash(FlxColor.WHITE, 1);
					iconP2.changeIcon('badai');
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
				    FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 1.5);
				case 804:
					dad.visible = true;
					iconP2.changeIcon('badai_and_baiburg');
				case 1732:
					FlxTween.tween(iconP2, {alpha:0}, 1.5);
				case 1744:
					badai.visible = false;
					badaiTime = false;
					FlxG.camera.flash(FlxColor.WHITE,1);
				case 1745:
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 1.5);
				case 2500:
					FlxTween.tween(iconP2, {alpha:0}, 1.5);
				case 2512:
					FlxG.camera.flash(FlxColor.WHITE,1);
					redTunnel.active = false;
					redTunnel.visible = false;
					redBG.visible = false;
					redBG.active = false;
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 1.5);
			}
		case 'antagonism':
			switch(curBeat)
			{
				case 0:
					FlxTween.tween(badai, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redBG, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redTunnel, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
				case 448:
					FlxTween.tween(dad, {"scale.x": 0, "scale.y": 0}, 1, {ease: FlxEase.quadIn});
					FlxTween.tween(iconP2, {alpha:0}, 10);
					redTunnel.active = true;
					redTunnel.visible = true;
					FlxTween.tween(FlxG.camera, {zoom: 0.67}, 3, {ease: FlxEase.expoOut,});	
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 5, {ease: FlxEase.circInOut});
				case 477:
					badai.visible = true;
					FlxTween.tween(badai, {"scale.x": 1, "scale.y": 1}, 1, {ease: FlxEase.cubeOut});
				case 480:
					dad.visible = false;
					redBG.visible = true;
					redBG.active = true;
					FlxG.camera.flash(FlxColor.WHITE, 1);
					iconP2.changeIcon('badai');
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
				    FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 1.5);
					badaiTime = true;
				case 704:
					dad.visible = true;
					iconP2.changeIcon('badai_and_baiburg');
					badaiTime = false;
				case 1688:
					FlxTween.tween(iconP2, {alpha:0}, 2);
				case 1696:
					badai.visible = false;
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 1.5);
				case 2456:
					FlxTween.tween(iconP2, {alpha:0}, 2);
				case 2464:
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 1.5);
					redTunnel.active = false;
					redTunnel.visible = false;
					redBG.visible = false;
					redBG.active = false;
				case 2776:
					FlxTween.tween(iconP2, {alpha:0}, 2);
				case 2784:
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 1.5);
					FlxG.camera.flash(FlxColor.WHITE,1);
					redTunnel.active = true;
					redTunnel.visible = true;
					redBG.visible = true;
					redBG.active = true;
				case 3192:
					FlxTween.tween(iconP2, {alpha:0}, 2);
				case 3200:
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 1.5);
				case 3476:
					camZoomSnap = true;
				case 3636:
					camZoomSnap = false;
				case 4108:
					FlxTween.tween(iconP2, {alpha:0}, 2);
				case 4116:
					badai.visible = true;
					dad.visible = false;
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 1.5);
					badaiTime = true;
				case 4244:
					add(blackScreen2);
					blackScreen2.alpha = 0;
					FlxTween.tween(blackScreen2, {alpha:1}, 5.48);
					FlxTween.tween(camHUD, {alpha:0}, 5.48);
			}
		case 'new-antagonism':
			switch(curBeat)
			{
				case 0:
					FlxTween.tween(badai, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redBG, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redTunnel, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
				case 1:
					FlxTween.tween(dad, {"scale.x": 0, "scale.y": 0}, 1, {ease: FlxEase.quadIn});
					FlxTween.tween(iconP2, {alpha:0}, 10);
					redTunnel.active = true;
					redTunnel.visible = true;
					FlxTween.tween(FlxG.camera, {zoom: 0.67}, 3, {ease: FlxEase.expoOut,});	
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 5, {ease: FlxEase.circInOut});
				case 28:
					badai.visible = true;
					FlxTween.tween(badai, {"scale.x": 1, "scale.y": 1}, 1, {ease: FlxEase.cubeOut});
				case 32:
					dad.visible = false;
					badaiTime = true;
					redBG.visible = true;
					redBG.active = true;
					FlxG.camera.flash(FlxColor.WHITE, 1);
					iconP2.changeIcon('badai');
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
				    FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 1.5);
				case 335:
					badaiTime = false;
					iconP2.changeIcon('badai_and_baiburg');
				case 408 | 672 | 856:
					iconP2.changeIcon('badai_and_baiburg');
			}
		case 'antagonism-expunged':
			switch(curBeat)
			{
				case 0:
					FlxTween.tween(redBG, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redTunnel, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
			}
		case 'rascal':
			switch (curBeat)
			{
				case 0:
					dave.visible = false;
				case 260:
					dave.visible = true;
			}
		case 'velocity':
			switch (curBeat)
			{
				case 0:
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 0.001, {ease: FlxEase.circInOut});
					redTunnel.active = true;
					redTunnel.visible = true;
					redBG.visible = true;
					redBG.active = true;
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
			}
		case 'antagonism-test':
			switch (curBeat)
			{
				case 0:
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 0.001, {ease: FlxEase.circInOut});
					redTunnel.active = true;
					redTunnel.visible = true;
					redBG.visible = true;
					redBG.active = true;
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
				case 192:
					redTunnel.visible = false;
					redBG.visible = false;
					FlxG.camera.flash(FlxColor.WHITE, 2);
			}
		case 'dethroned':
			switch (curBeat)
			{
				case 0:
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 0.001, {ease: FlxEase.circInOut});
					redTunnel.active = false;
					redTunnel.visible = false;
					redBG.visible = false;
					redBG.active = false;
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
					add(blackScreen2);
				case 8:
					FlxTween.tween(blackScreen2, {alpha:0}, 8.65);
					poopBG.visible = false;
					poop2BG.active = true;
					poop2BG.visible = true;
				case 149:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					redTunnel.active = true;
					redTunnel.visible = true;
					redBG.visible = true;
					redBG.active = true;
				case 244:
					redTunnel.active = false;
					redTunnel.visible = false;
					redBG.visible = false;
					redBG.active = false;
					poop2BG.active = false;
					poop2BG.visible = false;
					poopBG.visible = true;
					FlxG.camera.flash(FlxColor.WHITE, 4);
			}
		case 'demise pt 1':
			switch (curBeat)
			{
				case 0:
					add(blackScreen2);
					blackScreen2.alpha = 1;
					FlxTween.tween(badai, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(dave, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redTunnel, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					redTunnel.active = false;
					redTunnel.alpha = 0;
					redTunnel.visible = false;
					redBG.visible = false;
					redBG.active = false;
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
					poopBG.visible = false;
					poop2BG.visible = true;
					gridBG.visible = false;
					bgHELL.visible = false;
					bgshitH.visible = false;
					bgshitH2.visible = false;
					cloudsH.visible = false;
					gridBG.active = false;
				case 1:
					FlxTween.tween(blackScreen2, {alpha:0}, 7.44);
				case 456:
					poop2BG.visible = false;
					FlxG.camera.flash(FlxColor.WHITE, 4);
					gridBG.visible = true;
					bgshitH.visible = true;
					bgshitH2.visible = true;
					bgHELL.visible = true;
					cloudsH.visible = true;
					gridBG.active = true;
					curbg = gridBG;
					dad.color = 0xFFFFFFFF;
				case 840:
					FlxTween.tween(blackScreen2, {alpha:1}, 9.83);
				case 880:
					FlxTween.tween(blackScreen2, {alpha:0}, 5.54);
					dad.color = 0xFF878787;
				case 1232:
					redTunnel.active = true;
					redTunnel.visible = true;
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 14.77, {ease: FlxEase.circInOut});
					FlxTween.tween(redTunnel, {alpha:1}, 14.77);
				case 1248:
					dave.visible = true;
					FlxTween.tween(dave, {"scale.x": 1, "scale.y": 1}, 10, {ease: FlxEase.cubeOut});
				case 1288:
					dad.visible = false;
					gridBG.visible = false;
					bgHELL.visible = false;
					bgshitH.visible = false;
					bgshitH2.visible = false;
					cloudsH.visible = false;
					gridBG.active = false;
					redBG.visible = true;
					redBG.active = true;
					FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxTween.tween(dave, {x:-300}, 1, {ease: FlxEase.backInOut});
				case 1672:
					FlxTween.tween(dave, {"scale.x": 0, "scale.y": 0}, 2, {ease: FlxEase.quadIn});
					dad.visible = true;
				case 3560:
					FlxTween.tween(dad, {x:-5000, y:-5000}, 4, {ease: FlxEase.backInOut});
					FlxTween.tween(dave, {y:5000}, 4, {ease: FlxEase.backInOut});
				case 3616:
					badai.visible = true;
					FlxTween.tween(badai, {"scale.x": 1, "scale.y": 1}, 1.6, {ease: FlxEase.cubeOut});
				case 3624:
					dad.visible = false;
					FlxG.camera.flash(FlxColor.WHITE, 1);
				case 4008:
					dad.visible = true;
					iconP2.changeIcon('minion_and_badai');
				case 4072:
					FlxTween.tween(badai, {x:-5000}, 4, {ease: FlxEase.backInOut});
					FlxTween.tween(iconP2, {alpha:0}, 2);
				case 4084:
					FlxTween.tween(iconP2, {alpha:1}, 2);
					iconP2.changeIcon('minion');
				case 4088:
					badai.visible = false;
				case 4264:
					poopBG.visible = true;
					redTunnel.active = false;
					redTunnel.visible = false;
					redBG.visible = false;
					redBG.active = false;
					FlxG.camera.flash(FlxColor.WHITE, 8);
					curbg = poopBG;
				case 5928:
					FlxTween.tween(blackScreen2, {alpha:1}, 11);
				case 5992:
					blackScreen2.alpha = 0;
					poopBG.visible = false;
					poop2BG.visible = true;
					FlxG.camera.flash(FlxColor.WHITE, 1);
					curbg = poop2BG;
					FlxTween.tween(dave, {"scale.x": 1, "scale.y": 1}, 0.001, {ease: FlxEase.cubeOut});
					FlxTween.tween(iconP2, {alpha:0}, 4);
				case 5996:
					FlxTween.tween(dave, {y:100}, 4, {ease: FlxEase.backInOut});
				case 6008:
					FlxTween.tween(iconP2, {alpha:1}, 4);
					iconP2.changeIcon('bambi_and_dave');
				case 6368:
					FlxTween.tween(dave, {y:5000}, 2, {ease: FlxEase.backInOut});
					FlxTween.tween(dad, {y:-5000}, 2, {ease: FlxEase.backInOut});
				case 6376:
					dave.visible = false;
				case 6808:
					FlxTween.tween(blackScreen2, {alpha:1}, 3.8);
			}
		case 'demise pt 2':
			switch (curBeat)
			{
				case 0:
					add(blackScreen2);
					blackScreen2.alpha = 1;
					FlxTween.tween(dave, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					FlxTween.tween(redTunnel, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					redTunnel.active = false;
					redTunnel.visible = false;
					FlxTween.tween(redTunnel2, {"scale.x": 0, "scale.y": 0}, 0.001, {ease: FlxEase.circInOut});
					redTunnel2.active = false;
					redTunnel2.visible = false;
					redBG.visible = false;
					redBG.active = false;
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
					poopBG.visible = false;
					poop2BG.visible = true;
					gridBG.visible = false;
					bgHELL.visible = false;
					bgshitH.visible = false;
					bgshitH2.visible = false;
					cloudsH.visible = false;
					gridBG.alpha = 0;
					bgHELL.alpha = 0;
					bgshitH.alpha = 0;
					bgshitH2.alpha = 0;
					cloudsH.alpha = 0;
					gridBG.active = false;
					bamburg.visible = false;
				case 1:
					FlxTween.tween(blackScreen2, {alpha:0}, 7.44);
				case 352:
					FlxTween.tween(blackScreen2, {alpha:1}, 7.44);
					redTunnel2.active = true;
					redTunnel2.visible = true;
					FlxTween.tween(redTunnel2, {"scale.x": 1.15, "scale.y": 1.15}, 3, {ease: FlxEase.circInOut});
				case 368:
					FlxTween.tween(gf, {"scale.x": 0, "scale.y": 0}, 1.15, {ease: FlxEase.quadIn});
					FlxTween.tween(boyfriend, {"scale.x": 0, "scale.y": 0}, 1.15, {ease: FlxEase.quadIn});
				case 376:
					FlxTween.tween(redTunnel2, {"scale.x": 0, "scale.y": 0}, 1.15, {ease: FlxEase.quadIn});
				case 384:
					blackScreen2.alpha = 0;
					poopBG.visible = true;
					poop2BG.visible = false;
					curbg = poopBG;
					FlxTween.tween(redTunnel2, {"scale.x": 1.15, "scale.y": 1.15}, 3, {ease: FlxEase.circInOut});
					hideshit();
				case 392:
					FlxTween.tween(gf, {"scale.x": 1, "scale.y": 1}, 1.15, {ease: FlxEase.cubeOut});
					FlxTween.tween(boyfriend, {"scale.x": 1, "scale.y": 1}, 1.15, {ease: FlxEase.cubeOut});
				case 400:
					FlxTween.tween(redTunnel2, {"scale.x": 0, "scale.y": 0}, 3, {ease: FlxEase.quadIn});
					FlxG.camera.flash(FlxColor.WHITE, 2);
					showshit();
				case 424:
					redTunnel2.active = false;
					redTunnel2.visible = false;
				case 880:
					FlxTween.tween(blackScreen2, {alpha:1}, 16);
				case 944:
					blackScreen2.alpha = 0;
					redTunnel.active = true;
					redTunnel.visible = true;
					redBG.visible = true;
					redBG.active = true;
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 0.001, {ease: FlxEase.circInOut});
					FlxG.camera.flash(FlxColor.WHITE, 6);
				case 1200:
					FlxG.camera.flash(FlxColor.WHITE, 2);
					bamburg.visible = true;
					iconP2.changeIcon('bombai_and_baiburg');
				case 1584:
					poopBG.visible = false;
					redTunnel.active = false;
					redTunnel.visible = false;
					redBG.visible = false;
					redBG.active = false;
					FlxG.camera.flash(FlxColor.WHITE, 2);
					bamburg.visible = false;
					dad.visible = false;
					boyfriend.visible = false;
					gf.visible = false;
					FlxTween.tween(iconP2, {alpha:0}, 2);
				case 1616:
					FlxTween.tween(iconP2, {alpha:1}, 4);
					dad.visible = true;
					boyfriend.visible = true;
					gf.visible = true;
					jeezBG.active = true;
					jeezBG.visible = true;
					curbg = jeezBG;
				case 2128:
					FlxTween.tween(blackScreen2, {alpha:1}, 14);
				case 2192:
					jeezBG.active = false;
					jeezBG.visible = false;
					FlxG.camera.flash(FlxColor.WHITE, 0.5);
					camHUD.alpha = 0;
					gridBG.visible = true;
					bgHELL.visible = true;
					bgshitH.visible = true;
					bgshitH2.visible = true;
					cloudsH.visible = true;
					blackScreen2.alpha = 0;
					dad.alpha = 0;
					boyfriend.alpha = 0;
					gf.alpha = 0;
					FlxTween.tween(gridBG, {alpha:1}, 0.75);
					FlxTween.tween(bgHELL, {alpha:0.85}, 0.75);
					gridBG.active = true;
					curbg = gridBG;
				case 2196:
					FlxTween.tween(bgshitH, {alpha:1}, 0.75);
				case 2200:
					FlxTween.tween(bgshitH2, {alpha:1}, 0.75);
				case 2204:
					FlxTween.tween(cloudsH, {alpha:1}, 0.75);
				case 2208:
					FlxTween.tween(dad, {alpha:1}, 0.75);
				case 2212:
					FlxTween.tween(gf, {alpha:1}, 0.75);
				case 2216:
					FlxTween.tween(boyfriend, {alpha:1}, 0.75);
				case 2220:
					FlxTween.tween(camHUD, {alpha:1}, 0.75);
				case 2480:
					redTunnel.active = true;
					redTunnel.visible = true;
					redBG.visible = true;
					redBG.active = true;
					gridBG.visible = false;
					bgHELL.visible = false;
					bgshitH.visible = false;
					bgshitH2.visible = false;
					cloudsH.visible = false;
				case 2928:
					FlxG.camera.flash(FlxColor.WHITE, 3);
					dad.alpha = 0;
					boyfriend.alpha = 0;
					gf.alpha = 0;
					redTunnel.active = false;
					redTunnel.visible = false;
					redBG.visible = false;
					redBG.active = false;
				case 2960:
					FlxG.camera.flash(FlxColor.WHITE, 8);
					dad.alpha = 0;
					boyfriend.alpha = 1;
					gf.alpha = 1;
					redTunnel.active = true;
					redTunnel.visible = true;
					redBG.visible = true;
					redBG.active = true;
				case 2992:
					FlxTween.tween(dave, {"scale.x": 1, "scale.y": 1}, 7.5, {ease: FlxEase.cubeOut});
				case 3600:
					FlxTween.tween(blackScreen2, {alpha:1}, 52.8);
			}
		case 'platonic':
			switch(curStep)
			{
				case 0:
					add(blackScreen2);
					blackScreen2.alpha = 0;
					dave.alpha = 0;
					bambi.alpha = 0;
					boyfriend2.alpha = 0;
				case 1:
					camZooming = true;
				case 912:
					dave.alpha = 1;
					dave.x += 70;
					camOther.flash(FlxColor.BLACK, 1.5);
				case 1904:
					dave.alpha = 0;
					boyfriend2.alpha = 1;
					boyfriend.x += 100;
					camOther.flash(FlxColor.BLACK, 1.5);
					boyfriendCanMiss = false;
					isboyfriend2 = true;
					iconP1.changeIcon('Babman');
					healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
		    		FlxColor.WHITE);
					healthBar.updateBar();
				case 2624:
					FlxTween.tween(dad, {alpha:0}, 0.35);
				case 2704:
					dad.alpha = 1;
					boyfriend2.alpha = 0;
					boyfriend.x = 770;
					camOther.flash(FlxColor.BLACK, 1.5);
					boyfriendCanMiss = true;
					isboyfriend2 = false;
					iconP1.changeIcon(boyfriend.healthIcon);
					reloadHealthBarColors();
				case 3280:
					boyfriend2.alpha = 1;
					boyfriend.x += 100;
					camOther.flash(FlxColor.BLACK, 1.5);
					boyfriendCanMiss = false;
					isboyfriend2 = true;
					iconP1.changeIcon('Babman');
					healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
		    		FlxColor.WHITE);
					healthBar.updateBar();
				case 3980:
					FlxTween.tween(FlxG.camera, {angle: 360}, 0.3 / playbackRate, {ease: FlxEase.backInOut});
					FlxTween.tween(camHUD, {angle: 360}, 0.3 / playbackRate, {ease: FlxEase.backInOut});
				case 4044:
					FlxTween.tween(FlxG.camera, {angle: 0}, 0.3 / playbackRate, {ease: FlxEase.backInOut});
					FlxTween.tween(camHUD, {angle: 0}, 0.3 / playbackRate, {ease: FlxEase.backInOut});
				case 4368:
					boyfriend2.alpha = 0;
					boyfriend.x = 770;
					dad.alpha = 0;
					camOther.flash(FlxColor.BLACK, 1.5);
					boyfriendCanMiss = true;
					isboyfriend2 = false;
					iconP1.changeIcon(boyfriend.healthIcon);
					reloadHealthBarColors();
				case 4624:
					dave.alpha = 1;
					camOther.flash(FlxColor.BLACK, 4);
				case 4880:
					dad.alpha = 1;
					camOther.flash(FlxColor.BLACK, 1.5);
				case 5008:
					bambi.alpha = 1;
					camOther.flash(FlxColor.BLACK, 1.5);
				case 5519:
					camZoomSnap = true;
				case 5775:
					camZoomHalfSnap = true;
					camZoomSnap = false;
				case 5903:
					camZoomHalfSnap = false;
				case 5904:
					FlxTween.tween(blackScreen2, {alpha:1}, 25 / playbackRate);
				case 6031:
					camZooming = false;
			}
		case 'soulless 5':
			switch (curBeat)
			{
				case 1:
					camZooming = true;
			}
		case 'antagonism-poip-part':
			switch (curBeat)
			{
				case 0:
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 0.001, {ease: FlxEase.circInOut});
					redTunnel.active = true;
					redTunnel.visible = true;
					redBG.visible = true;
					redBG.active = true;
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
					add(blackScreen2);
				case 32:
					FlxTween.tween(blackScreen2, {alpha:0}, 9.15);
					FlxG.camera.flash(FlxColor.WHITE, 4.57);
				case 64:
					FlxG.camera.flash(FlxColor.WHITE, 1);
				case 544:
					FlxTween.tween(blackScreen2, {alpha:1}, 16.48);
			}
		case 'splitathon' | 'old-splitaton':
			switch (curStep)
			{
				case 4736:
					dad.animation.play('scared', true);
				case 4800:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					splitterThonDave('what');
					if (BAMBICUTSCENEICONHURHURHUR == null)
					{
						BAMBICUTSCENEICONHURHURHUR = new HealthIcon("dave", false);
						BAMBICUTSCENEICONHURHURHUR.y = healthBar.y - (BAMBICUTSCENEICONHURHURHUR.height / 2);
						add(BAMBICUTSCENEICONHURHURHUR);
						BAMBICUTSCENEICONHURHURHUR.cameras = [camHUD];
						BAMBICUTSCENEICONHURHURHUR.x = -100;
						FlxTween.linearMotion(BAMBICUTSCENEICONHURHURHUR, -100, BAMBICUTSCENEICONHURHURHUR.y, iconP2.x, BAMBICUTSCENEICONHURHURHUR.y, 0.3, true, {ease: FlxEase.expoInOut});
						new FlxTimer().start(0.3, FlingCharacterIconToOblivionAndBeyond);
					}
				case 5824:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					splitathonExpression('bambi-what', -100, 550);
				case 6080:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					splitterThonDave('happy');
				case 8384:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					splitathonExpression('bambi-corn', -100, 550);
			}
		case 'insanity':
			switch (curStep)
			{
				case 660 | 680:
					FlxG.sound.play(Paths.sound('static'), 0.1);
                    insanityRed.visible = true;
				case 664 | 684:
					insanityRed.visible = false;
				case 1176:
					FlxG.sound.play(Paths.sound('static'), 0.1);
					insanityRed.visible = true;
				case 1180:
					dad.animation.play('scared', true);
			}
		case 'furiosity':
			switch (curStep)
			{
				case 256:
					camZoomSnap = true;
				case 896:
					camZoomSnap = false;
				case 1305:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					redSky.visible = false;
					//redPlatform.visible = false;
					backyardnight.visible = true;
			}
		case 'disposition' | 'disposition_but_awesome':
			switch (curStep)
			{
				case 0:
					blackScreendeez.alpha = 1;
				case 1:
					FlxTween.tween(blackScreendeez, {alpha:0}, 1);
					camZooming = true;
			}
		case 'despair':
			switch (curBeat)
			{
				case 516:
					FlxG.camera.flash(FlxColor.WHITE, 2.5);
			}
		case 'acquaintance':
			switch (curStep)
			{
				case 0:
					blackScreendeez.alpha = 1;
				case 1:
					FlxTween.tween(blackScreendeez, {alpha:0}, 1);
					camZooming = true;
				case 504:
					defaultCamZoom = 1.25;
					FlxTween.tween(blackBG, {alpha:1}, 1);
				case 508:
					defaultCamZoom = 2;	
				case 511:
					camHUD.alpha = 0;
				case 512:
					defaultCamZoom = 0.5;
					fartt = true;
					bALLS = true;
					camZoomSnap = true;
					autoCamZoom = false;
					FlxTween.tween(camHUD, {alpha:1}, 1);
				case 1535: // what the fuck??
			    	fartt = false;
					fartt2 = false;
					camZoomSnap = false;
					autoCamZoom = true;
					camHUD.angle = 0;
					camHUD.flash(FlxColor.WHITE, 1);
			}
		case 'polygonized':
			switch (curStep)
			{
				case 0:
					hideshit();
					add(blackScreen);
				case 1:
					FlxTween.tween(camHUD, {alpha:0}, 1);
				case 60:
					FlxTween.tween(blackScreen, {alpha:0}, 1);
				case 127:
					showshit();
					FlxTween.tween(camHUD, {alpha:1}, 1);
				case 1024 | 1312 | 1424 | 1552 | 1664:
					shakeCam = true;
				case 1152 | 1408 | 1472 | 1600 | 2048 | 2176:
					shakeCam = false;
				case 2175:
					defaultCamZoom = 1.45;	
					FlxTween.tween(gf, {alpha:0}, 1);
					FlxTween.tween(dad, {alpha:0}, 1);
					FlxTween.tween(blackScreendeez, {alpha:0.5}, 1);
					FlxTween.tween(blackBG, {alpha:1}, 1);
				case 2434:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					blackBG.alpha = 0;
					FlxTween.tween(camHUD, {alpha:0}, 2);
					redSky.visible = false;
					//redPlatform.visible = false;
					backyardnight.visible = true;
					blackScreendeez.alpha = 0;
					defaultCamZoom = 0.9;
					gf.alpha = 1;
					dad.alpha = 1;

			}
		case 'mealie':
			switch (curStep)
			{
		    	case 1855:
		    		camZoomSnap = true;
			}
		case 'computer':
			switch (curBeat)
			{
				case 64:
					FlxG.camera.flash(FlxColor.WHITE, 2);
					camZoomSnap = true;
				case 256:
					camZoomSnap = false;
			}
		case 'crimson corridor':
			switch (curStep)
			{
				case 0:
					hideshit();
					strumLineNotes.visible = false;
					FlxTween.tween(redTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 0.001, {ease: FlxEase.circInOut});
					redTunnel.active = false;
					redTunnel.visible = false;
					redBG.visible = false;
					redBG.active = false;
					FlxTween.tween(redBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
					poopBG.visible = false;
					boyfriend.alpha = 0;
					gf.alpha = 0;
					dad.alpha = 0;
					redTunnel.alpha = 0;
					redBG.alpha = 0;
				case 1:
					FlxTween.tween(scoreTxt, {alpha:0}, 0.1);
					FlxTween.tween(judgementCounter, {alpha:0}, 0.1);
					FlxTween.tween(songWatermark, {alpha:0}, 0.1);
					FlxTween.tween(creditsWatermark, {alpha:0}, 0.1);
					FlxTween.tween(healthBar, {alpha:0}, 0.1);
					FlxTween.tween(healthBarBG, {alpha:0}, 0.1);
					FlxTween.tween(healthBarOverlay, {alpha:0}, 0.1);
					FlxTween.tween(timeBarBG, {alpha:0}, 0.1);
					FlxTween.tween(timeBar, {alpha:0}, 0.1);
					FlxTween.tween(timeTxt, {alpha:0}, 0.1);
					FlxTween.tween(iconP1, {alpha:0}, 0.1);
					FlxTween.tween(iconP2, {alpha:0}, 0.1);
				case 3:
					showshit();
					FlxTween.tween(scoreTxt, {alpha:1}, 2);
					FlxTween.tween(judgementCounter, {alpha:1}, 2);
					FlxTween.tween(songWatermark, {alpha:1}, 2);
					FlxTween.tween(creditsWatermark, {alpha:1}, 2);
				case 16:
					FlxTween.tween(healthBar, {alpha:1}, 2);
					FlxTween.tween(healthBarBG, {alpha:1}, 2);
					FlxTween.tween(healthBarOverlay, {alpha:1}, 2);
					FlxTween.tween(timeBarBG, {alpha:1}, 2);
					FlxTween.tween(timeBar, {alpha:1}, 2);
					FlxTween.tween(timeTxt, {alpha:1}, 2);
				case 32:
					FlxTween.tween(iconP1, {alpha:1}, 2);
				case 48:
					FlxTween.tween(iconP2, {alpha:1}, 2);
				case 64:
					FlxTween.tween(redBG, {alpha:1}, 2);
					FlxTween.tween(redTunnel, {alpha:1}, 2);
					redTunnel.active = true;
					redTunnel.visible = true;
					redBG.visible = true;
					redBG.active = true;
				case 80:
					FlxTween.tween(boyfriend, {alpha:1}, 2);
				case 96:
					FlxTween.tween(gf, {alpha:1}, 2);
				case 112:
					FlxTween.tween(dad, {alpha:1}, 2);
				case 128:
					strumLineNotes.visible = true;
				case 1536:
					FlxTween.tween(dad, {alpha:0}, 4);
				case 1568:
					FlxTween.tween(gf, {alpha:0}, 4);
					FlxTween.tween(boyfriend, {alpha:0}, 4);
				case 1600:
					FlxTween.tween(redBG, {alpha:0}, 4);
					FlxTween.tween(redTunnel, {alpha:0}, 4);
				case 1632:
					FlxTween.tween(camHUD, {alpha:0}, 6);
			}
		case 'reheated':
			switch (curBeat)
			{	
				case 0:
					add(blackScreen2);
					FlxTween.tween(purpleTunnel, {"scale.x": 1.15, "scale.y": 1.15}, 0.001, {ease: FlxEase.circInOut});
					purpleTunnel.active = true;
					purpleTunnel.visible = true;
					purpleBG.visible = true;
					purpleBG.active = true;
					FlxTween.tween(purpleBG, {"scale.x": 9, "scale.y": 9}, 0.001, {ease: FlxEase.circInOut});
				case 32:
					FlxG.camera.flash(FlxColor.WHITE, 2);
					camZoomSnap = true;
					FlxTween.tween(blackScreen2, {alpha:0}, 0.001);
			}
		case 'callback':
			switch (curBeat)
			{
				case 0:
					iconP2.changeIcon('bandu');
			}
		case 'rebound':
			switch (curStep)
			{
				case 0:
					hideshit();
				case 15:
					showonlystrums();
				case 512:
					camOther.flash(FlxColor.WHITE, 1.5);
				case 2178:
					FlxTween.tween(FlxG.camera, {angle: 0}, 0.20, {ease: FlxEase.quadOut});
			}
		case 'shattered':
			switch (curStep)
			{
				case 0:
					hideshit();
				case 1:
					camHUD.alpha = 0;
					showshit();
				case 120:
					showHUDFade();
				case 895:
					add(blackScreen);
				case 896:
					FlxTween.tween(blackScreen, {alpha:0}, 10);
				case 1024:
					FlxTween.tween(blackScreen, {alpha:1}, 5);
				case 1090:
					FlxTween.tween(blackScreen, {alpha:0}, 2);
				case 1665:
					boyfriend.playAnim('hurt', true);
				case 1792:
					redGlow.visible = true;
			}
		case 'supplanted':
			switch (curStep)
			{
				case 128:
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					redGlow.visible = true;
				case 802:
					defaultCamZoom = 1.5;
				case 805:
					defaultCamZoom = 0.85;
				case 859:
					defaultCamZoom = 1.75;
				case 863:
					defaultCamZoom = 0.85;
				case 892:
					defaultCamZoom = 1.5;
				case 895:
					defaultCamZoom = 0.85;
				case 944 | 1343 | 2176:
					camZoomSnap = false;
				case 720 | 960 | 1856:
					camZoomSnap = true;
				case 1344:
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
				case 2368:
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					redGlow.visible = false;
					FlxTween.tween(camFollowPos, {y:camFollowPos.y -1000}, 5, {ease: FlxEase.expoOut,}); 
					camZooming = false;
				case 2384: // 2384
					add(blackScreen);
				case 2386: // 2386
					FlxTween.tween(blackScreen, {alpha:1}, 5);
					camZooming = true;
				case 2656: // 2656
			    	FlxTween.tween(blackScreen, {alpha:0}, 3);
				case 2688:
					redGlow.visible = true;
					camZooming = true;
				case 2960:
					dad.color = 0xFF000000;
					defaultCamZoom = 1.35;

			}
		/*case 'technology':
			switch (curBeat)
			{*/
			/*	case 317: // 317
				    swagSpeed = 1.6;*/
			/*	case 581:
					add(blackScreen);
				}
			}*/
		case '8-28-63':
			switch (curStep)
			{
				case 0:
					gf.alpha = 0;
				case 639 | 1920:
					FlxG.sound.play(Paths.sound('static'), 0.1);
					soscaryishitmypants.visible = true;
				case 1152 | 2432:
					soscaryishitmypants.visible = false;
			}
	    case 'roundabout':
			switch(curStep)
			{
				case 1:
			     	FlxTween.tween(FlxG.camera, {zoom:1.20}, 17);
				case 239:
					resyncVocals();
				case 256:
					camZoomSnap = true;
			}
		case 'fast-food':
			switch(curStep)
	    	{
				case 112:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 116:
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 120:
					camZoomSnap = true;
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 124:
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 1567:
					camZoomSnap = false;
			}
		case 'upheaval-teaser':
			switch(curStep)
	    	{
				case 0:
					hideshit();
				case 1: // oh god
		     		healthBar.alpha = 0;
		      		healthBarBG.alpha = 0;
					healthBarOverlay.alpha = 0;
			    	iconP1.alpha = 0;
			       	iconP2.alpha = 0;
			    	scoreTxt.alpha = 0;
			    	judgementCounter.alpha = 0;
		    		songWatermark.alpha = 0;
			    	creditsWatermark.alpha = 0;
					timeBarBG.alpha = 0;
					timeBar.alpha = 0;
					timeTxt.alpha = 0;
				case 2:
					showshit();
					FlxTween.tween(FlxG.camera, {zoom: 0.7}, 1.85, {ease: FlxEase.expoOut,});
				case 133:
					FlxTween.tween(scoreTxt, {alpha:1}, 3);
					FlxTween.tween(judgementCounter, {alpha:1}, 3);
					FlxTween.tween(songWatermark, {alpha:1}, 3);
					FlxTween.tween(creditsWatermark, {alpha:1}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
				case 164:
					FlxTween.tween(timeBarBG, {alpha:1}, 3);
					FlxTween.tween(timeBar, {alpha:1}, 3);
					FlxTween.tween(timeTxt, {alpha:1}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
				case 197:
					FlxTween.tween(healthBar, {alpha:ClientPrefs.healthBarAlpha}, 3);
					FlxTween.tween(healthBarBG, {alpha:ClientPrefs.healthBarAlpha}, 3);
					FlxTween.tween(healthBarOverlay, {alpha:ClientPrefs.healthBarAlpha}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 4);
				case 262:
					FlxTween.tween(iconP1, {alpha:ClientPrefs.healthBarAlpha}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
				case 293:
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
                case 325:
					if(ClientPrefs.flashing) camHUD.shake(0.0035, 2);
			}
		case 'upheaval':
			switch(curStep)
	    	{
				case 0:
					hideshit();
				case 1: // oh god
		     		healthBar.alpha = 0;
		      		healthBarBG.alpha = 0;
					healthBarOverlay.alpha = 0;
			    	iconP1.alpha = 0;
			       	iconP2.alpha = 0;
			    	scoreTxt.alpha = 0;
			    	judgementCounter.alpha = 0;
		    		songWatermark.alpha = 0;
			    	creditsWatermark.alpha = 0;
					timeBarBG.alpha = 0;
					timeBar.alpha = 0;
					timeTxt.alpha = 0;
				case 2:
					showshit();
					FlxTween.tween(FlxG.camera, {zoom: 0.7}, 1.85, {ease: FlxEase.expoOut,});
				case 128:
					FlxTween.tween(scoreTxt, {alpha:1}, 3);
					FlxTween.tween(judgementCounter, {alpha:1}, 3);
					FlxTween.tween(songWatermark, {alpha:1}, 3);
					FlxTween.tween(creditsWatermark, {alpha:1}, 3);
					FlxTween.tween(timeBarBG, {alpha:1}, 3);
					FlxTween.tween(timeBar, {alpha:1}, 3);
					FlxTween.tween(timeTxt, {alpha:1}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
				case 160:
					FlxTween.tween(healthBar, {alpha:ClientPrefs.healthBarAlpha}, 3);
					FlxTween.tween(healthBarBG, {alpha:ClientPrefs.healthBarAlpha}, 3);
					FlxTween.tween(healthBarOverlay, {alpha:ClientPrefs.healthBarAlpha}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 4);
				case 192:
					FlxTween.tween(iconP1, {alpha:ClientPrefs.healthBarAlpha}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
				case 224:
					FlxTween.tween(iconP2, {alpha:ClientPrefs.healthBarAlpha}, 3);
					if(ClientPrefs.flashing) camHUD.shake(0.0025, 1.5);
				case 4992:
					FlxTween.tween(dad, {alpha:0}, 14.23);
				case 5504:
					FlxTween.tween(dad, {alpha:1}, 0.001);
					FlxG.camera.flash(FlxColor.WHITE, 1);
				case 6272:
					FlxTween.tween(dad, {alpha:0}, 14.22);
				case 6528:
					FlxTween.tween(dad, {alpha:1}, 0.001);
					FlxG.camera.flash(FlxColor.WHITE, 1);
				case 6784:
					add(blackScreen2);
					blackScreen2.alpha = 0;
				case 6785:
					FlxTween.tween(blackScreen2, {alpha:1}, 20);
			}
		case '5 minutes':
			switch(curBeat)
			{
				case 0:
					add(blackScreen2);
					blackScreen2.alpha = 0;
				case 383:
					camZoomHalfSnap = true;
				case 511:
					camZoomHalfSnap = false;
				case 703:
					camZoomHalfSnap = true;
				case 831:
					camZoomHalfSnap = false;
				case 839:
					fartt = true;
				case 904:
					blackScreen2.alpha = 1;
				case 908:
					blackScreen2.alpha = 0;
					camOther.flash(FlxColor.WHITE, 1.5);
				case 1040:
					fartt = false;
					fartt2 = false;
					FlxTween.tween(FlxG.camera, {angle: 0}, 0.20, {ease: FlxEase.quadOut});
			}
		case 'lacuna':
			switch(curStep)
	    	{
				case 0:
					add(blackScreen2);
					fartt = false;
				case 1:
					FlxTween.tween(blackScreen2, {alpha:0}, 15);
					windowProperties = [
						Application.current.window.x,
						Application.current.window.y,
						Application.current.window.width,
						Application.current.window.height
					];
				case 516:
					fartt = true;
                case 1032:
					oppositionMoment = true;
					if(ClientPrefs.flashing) camHUD.flash(FlxColor.WHITE, 1);
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					shakeCam = true;
				case 2064:
					oppositionMoment = false;
					guh();
					if(ClientPrefs.flashing) camHUD.flash(FlxColor.WHITE, 1);
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					shakeCam = false;
					camHUD.alpha = 0.75;
                case 2826:
					FlxTween.tween(camHUD, {alpha:1}, 0.75);
				case 3079:
					oppositionMoment = true;
					if(ClientPrefs.flashing) camHUD.flash(FlxColor.WHITE, 1); 
					if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					shakeCam = true;
				case 4614:
		    		shakeCam = false;
				case 4873:
					oppositionMoment = false;
					guh();
				case 5120:
					FlxTween.tween(Application.current.window, {x: windowProperties[0], y: windowProperties[1], width: windowProperties[2], height: windowProperties[3]}, 1, {ease: FlxEase.circInOut});
					fartt = false;
					fartt2 = false;
					FlxTween.tween(FlxG.camera, {angle: 0}, 0.20, {ease: FlxEase.quadOut});
					FlxTween.tween(camHUD, {angle: 0}, 0.20, {ease: FlxEase.quadOut});
				case 5184:
					for (i in 0...opponentStrums.length) {
						setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
						setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
						FlxTween.tween(opponentStrums.members[i], {alpha:0}, 1.5 / playbackRate);
					}
				case 5248:
					for (i in 0...playerStrums.length) {
						setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
						setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
						FlxTween.tween(playerStrums.members[i], {alpha:0}, 1.5 / playbackRate);
					}
				case 5312:
					FlxTween.tween(iconP2, {alpha:0}, 1.5 / playbackRate);
				case 5344:
					FlxTween.tween(iconP1, {alpha:0}, 1.5 / playbackRate);
				case 5376:
					FlxTween.tween(healthBar, {alpha:0}, 1.5 / playbackRate);
					FlxTween.tween(healthBarBG, {alpha:0}, 1.5 / playbackRate);
					FlxTween.tween(healthBarOverlay, {alpha:0}, 1.5 / playbackRate);
				case 5440:
					FlxTween.tween(timeBar, {alpha:0}, 1.5 / playbackRate);
					FlxTween.tween(timeBarBG, {alpha:0}, 1.5 / playbackRate);
					FlxTween.tween(timeTxt, {alpha:0}, 1.5 / playbackRate);
				case 5504:
					FlxTween.tween(camHUD, {alpha:0}, 1.5 / playbackRate);
				case 5575:
					FlxTween.tween(dad, {alpha:0}, 0.3);
				case 5591:
					FlxTween.tween(gf, {alpha:0}, 0.3);
				case 5608:
					FlxTween.tween(poopBG, {alpha:0}, 0.3);
                case 5624:
					FlxTween.tween(boyfriend, {alpha:0}, 1);
			}
	}

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{	
			case '3dRed' | '3dScary' | '3dFucked' | 'houseNight' | 'houseroof' | 'farmNight' | 'demiseStage': // Dark character thing
                {
                    dad.color = 0xFF878787;
					if(dave != null)
					{
						dave.color = 0xFF878787;
					}
					if(badai != null)
					{
						badai.color = 0xFF878787;
					}
                    gf.color = 0xFF878787;
                    boyfriend.color = 0xFF878787;

					if (SONG.player2 == 'bambi-god2d')
					{
						dad.color = 0xFFFFFFFF;
					}
                }
			case 'spooky': // Darker character thing
				{
					dad.color = 0xFF383838;
					gf.color = 0xFF383838;
					boyfriend.color = 0xFF383838;
				}
			case 'bambersHell': // glowing guy
				{
					gf.color = 0xFF878787;
					boyfriend.color = 0xFF878787;
				}
			case 'farmSunset' | 'houseSunset': // sunset !!
				{
					dad.color = sunsetColor;
					gf.color = sunsetColor;
					boyfriend.color = sunsetColor;
				}
			case 'tank':
				moveTank(elapsed);
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyWindow.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;

				if(phillyGlowParticles != null)
				{
					var i:Int = phillyGlowParticles.members.length-1;
					while (i > 0)
					{
						var particle = phillyGlowParticles.members[i];
						if(particle.alpha < 0)
						{
							particle.kill();
							phillyGlowParticles.remove(particle, true);
							particle.destroy();
						}
						--i;
					}
				}
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		updateScore();

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		if (FlxG.keys.justPressed.F12 && !endingSong && !inCutscene) // if you have f1 as the debug key thing im so sorry
		{
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new CheaterState());
	
			#if desktop
		    DiscordClient.changePresence("CHEATER FUCK YOU", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);
		var thingy = 0.88;

		if (ClientPrefs.iconBounce == 'Psych Engine') {
			var mult2:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			iconP1.scale.set(mult2, mult2);
			iconP1.updateHitboxPE();

			var mult2:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			iconP2.scale.set(mult2, mult2);
			iconP2.updateHitboxPE();
		}

		if (ClientPrefs.iconBounce == 'Vanilla FNF') {
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (ClientPrefs.iconBounce == 'Fixed Build') {
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 5), 0, 1))));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 5), 0, 1))));
	
			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (ClientPrefs.iconBounce == 'Dave Engine') {
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, thingy)),Std.int(FlxMath.lerp(150, iconP1.height, thingy)));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, thingy)),Std.int(FlxMath.lerp(150, iconP2.height, thingy)));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (ClientPrefs.iconBounce == 'Golden Apple') {
			iconP1.centerOffsets();
			iconP2.centerOffsets();

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		} 
		if (ClientPrefs.iconBounce == 'Custom Icon Bounce') {
			var mult:Float = FlxMath.lerp((playerIconScale-0.2), iconP1.scale.x, CoolUtil.boundTo((playerIconScale-0.2) - (elapsed * 9), 0, 1));
			iconP1.scale.set(mult, mult);
			iconP1.updateHitbox();

			var mult:Float = FlxMath.lerp((opponentIconScale-0.2), iconP2.scale.x, CoolUtil.boundTo((opponentIconScale-0.2) - (elapsed * 9), 0, 1));
			iconP2.scale.set(mult, mult);
			iconP2.updateHitbox();
		}

		var iconOffset:Int = 26;

		if (ClientPrefs.iconBounce == 'Psych Engine') {
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
	    	iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		} else {
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
		{
			iconP1.animation.curAnim.curFrame = 1;
			if(curBeat % 4 == 0)
				FlxTween.tween(scoreTxt, {color:0xFFFF0000}, 0.1 / playbackRate);
			if(curBeat % 4 == 2)
				FlxTween.tween(scoreTxt, {color:0xFFFFFFFF}, 0.1 / playbackRate);
		}
		else if (healthBar.percent > 80 && iconP1.hasWinning)
		{
			iconP1.animation.curAnim.curFrame = 2;
		}
		else
		{
			iconP1.animation.curAnim.curFrame = 0;
			FlxTween.tween(scoreTxt, {color:0xFFFFFFFF}, 0.03 / playbackRate);
		}

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else if (healthBar.percent < 20 && iconP2.hasWinning)
			iconP2.animation.curAnim.curFrame = 2;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Song and Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000 / playbackRate);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = SONG.song + ' (' + FlxStringUtil.formatTime(secondsTotal, false) + ')';
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		switch (curSong.toLowerCase())
		{
			case 'furiosity':
			switch (curBeat)
			{
				case 64:
					camZooming = true;
				case 287:
					camZooming = false;
			}
			case 'disposition':
				for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				opponentStrums.members[i].alpha = 0.2;
			}
			case 'devastation-fanmade':
			switch (curBeat)
			{
				case 832:
					for (i in 0...opponentStrums.length) {
					setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
					setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
					opponentStrums.members[i].alpha = 0.2;
					}
			}
	    }

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		var roundedSpeed:Float = FlxMath.roundDecimal(songSpeed, 2);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (altUnspawnNotes[0] != null)
		{
			if (altUnspawnNotes[0].strumTime - Conductor.songPosition < (SONG.song.toLowerCase() == 'unfairness' || SONG.song.toLowerCase() == 'unfairness-remix' ? 15000 : 1500))
			{
				var dunceNote:Note = altUnspawnNotes[0];
				altNotes.add(dunceNote);
		
				var index:Int = altUnspawnNotes.indexOf(dunceNote);
				altUnspawnNotes.splice(index, 1);
			}
		}	

		if (generatedMusic && !inCutscene)
		{
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance2();
				camFollowX = 0;
				camFollowY = 0;
				if(UsingNewCam) bfSingYeah = false;
				
				//boyfriend.animation.curAnim.finish();
			}
			
			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if(!daNote.mustPress) strumGroup = opponentStrums;

					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					if (strumScroll) //Downscroll
					{
						//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					else //Upscroll
					{
						//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha)
						daNote.alpha = strumAlpha;

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					if(daNote.copyY)
					{
						/*if (ClientPrefs.downScroll) {
							if (SONG.song.toLowerCase() == 'unfairness' || SONG.song.toLowerCase() == 'unfairness-remix')
								daNote.y = (strumY
							    	+ (0.45 * FlxMath.roundDecimal(1 * daNote.LocalScrollSpeed, 2)) * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
							else
								daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

							if (daNote.isSustainNote) {
								//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
								if (daNote.animation.curAnim.name.endsWith('end')) {
									daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
									daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
									if(PlayState.isPixelStage) {
										daNote.y += 8;
									} else {
										daNote.y -= 19;
									}
								} 
								daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
								daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

								if(daNote.mustPress || !daNote.ignoreNote)
								{
									if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
										&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
									{
										var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
										swagRect.height = (center - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;

										daNote.clipRect = swagRect;
									}
								}
							}
						} else {
							if (SONG.song.toLowerCase() == 'unfairness' || SONG.song.toLowerCase() == 'unfairness-remix')
								daNote.y = (strumY
							    	+ (0.45 * FlxMath.roundDecimal(1 * daNote.LocalScrollSpeed, 2)) * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
							else
			    	 			daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);

							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if (daNote.isSustainNote
									&& daNote.y + daNote.offset.y * daNote.scale.y <= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (center - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
						}*/
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								} else {
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						opponentNoteHit(daNote);
					}

					if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							}
						} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
							goodNoteHit(daNote);
						}
					}

					var center:Float = strumY + Note.swagWidth / 2;
					if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();
		moveCamera(isDadGlobal);
		
		#if debug
		if (FlxG.keys.justPressed.F3)
		{
			BAMBICUTSCENEICONHURHURHUR = new HealthIcon("bambi", false);
			BAMBICUTSCENEICONHURHURHUR.y = healthBar.y - (BAMBICUTSCENEICONHURHURHUR.height / 2);
			add(BAMBICUTSCENEICONHURHURHUR);
			BAMBICUTSCENEICONHURHURHUR.cameras = [camHUD];
			BAMBICUTSCENEICONHURHURHUR.x = -100;
			FlxTween.linearMotion(BAMBICUTSCENEICONHURHURHUR, -100, BAMBICUTSCENEICONHURHURHUR.y, iconP2.x, BAMBICUTSCENEICONHURHURHUR.y, 0.3, true, {ease: FlxEase.expoInOut});
			new FlxTimer().start(0.3, FlingCharacterIconToOblivionAndBeyond);
		}
		#end
		if (updatevels)
		{
			stupidx *= 0.98;
			stupidy += elapsed * 6;
			if (BAMBICUTSCENEICONHURHURHUR != null)
			{
				BAMBICUTSCENEICONHURHURHUR.x += stupidx;
				BAMBICUTSCENEICONHURHURHUR.y += stupidy;
			}
		}

		if (window == null)
		{
			if (expungedWindowMode)
			{
				#if windows
				popupWindow();
				#end
			}
			else
			{
				return;
			}
		}
		else if (expungedWindowMode)
		{
			var display = Application.current.window.display.currentMode;
	
			@:privateAccess
			var dadFrame = dad._frame;
			if (dadFrame == null || dadFrame.frame == null) return; // prevent crashes (i hope)
		  
			var rect = new Rectangle(dadFrame.frame.x, dadFrame.frame.y, dadFrame.frame.width, dadFrame.frame.height);
	
			expungedScroll.scrollRect = rect;
	
			window.x = Std.int(expungedOffset.x);
			window.y = Std.int(expungedOffset.y);
	
			if (!expungedMoving)
			{
				elapsedexpungedtime += elapsed * 9;
	
				var screenwidth = Application.current.window.display.bounds.width;
				var screenheight = Application.current.window.display.bounds.height;
	
				var toy = ((-Math.sin((elapsedexpungedtime / 9.5) * 2) * 30 * 5.1) / 1080) * screenheight;
				var tox = ((-Math.cos((elapsedexpungedtime / 9.5)) * 100) / 1980) * screenwidth;
	
				expungedOffset.x = ExpungedWindowCenterPos.x + tox;
				expungedOffset.y = ExpungedWindowCenterPos.y + toy;
	
				//center
				Application.current.window.y = Math.round(((screenheight / 2) - (720 / 2)) + (Math.sin((elapsedexpungedtime / 30)) * 80));
				Application.current.window.x = Std.int(windowSteadyX);
				Application.current.window.width = 1280;
				Application.current.window.height = 720;
			}
	
			if (lastFrame != null && dadFrame != null && lastFrame.name != dadFrame.name)
			{
				expungedSpr.graphics.clear();
				generateWindowSprite();
				lastFrame = dadFrame;
			}
	
			expungedScroll.x = (((dadFrame.offset.x) - (dad.offset.x)) * expungedScroll.scaleX) + 80;
			expungedScroll.y = (((dadFrame.offset.y) - (dad.offset.y)) * expungedScroll.scaleY);
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime + 800 >= Conductor.songPosition) {
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		for (i in shaderUpdates){
			i(elapsed);
		}
		#end
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
	}

	function openChartEditor()
	{
		switch (curSong.toLowerCase())
		{
			case 'supernovae' | 'glitch':
				#if debug
				MusicBeatState.switchState(new ChartingState());
				#end
				PlayState.SONG = Song.loadFromJson("cheating-hard", "cheating"); // you dun fucked up
				FlxG.save.data.cheatingFound = true;
				shakeCam = false;
				screenshader.Enabled = false;
				FlxG.switchState(new PlayState());
				return;
				// FlxG.switchState(new VideoState('assets/videos/fortnite/fortniteballs.webm', new CrasherState()));
			/*case 'disposition':
				#if debug
				MusicBeatState.switchState(new ChartingState());
				#end
				PlayState.SONG = Song.loadFromJson("disposition_but_awesome", "disposition_but_awesome"); // funny secret
				shakeCam = false;
				#if windows
				screenshader.Enabled = false;
				#end
				FlxG.switchState(new PlayState());
				return;*/
			case 'cheating':
				#if debug
				MusicBeatState.switchState(new ChartingState());
				#end
				PlayState.SONG = Song.loadFromJson("unfairness-hard", "unfairness"); // you dun fucked up again
				FlxG.save.data.unfairnessFound = true;
				shakeCam = false;
				screenshader.Enabled = false;
				FlxG.switchState(new PlayState());
				return;
			case 'unfairness':
				#if debug
				MusicBeatState.switchState(new ChartingState());
				#end
				PlayState.SONG = Song.loadFromJson("unfairness-remix-hard", "unfairness-remix"); // you dun fucked up again
				FlxG.save.data.unfairnessremixFound = true;
				shakeCam = false;
				screenshader.Enabled = false;
				FlxG.switchState(new PlayState());
				return;
			case 'unfairness-remix':
				shakeCam = false;
				screenshader.Enabled = false;
				FlxG.switchState(new SusState());
				return;
				#if debug
				MusicBeatState.switchState(new ChartingState());
				#end
			default:
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				persistentUpdate = false;
				paused = true;
				cancelMusicFadeTween();
				shakeCam = false;
				screenshader.Enabled = false;
				MusicBeatState.switchState(new ChartingState());
				chartingMode = true;
		
				#if desktop
				DiscordClient.changePresence("Chart Editor", null, null, true);
				#end
		}
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			#if windows
			if (window != null)
			{
				expungedWindowMode = false;
				window.close();
				//x,y, width, height
				FlxTween.tween(Application.current.window, {x: windowProperties[0], y: windowProperties[1], width: windowProperties[2], height: windowProperties[3]}, 1, {ease: FlxEase.circInOut});
			}
			#end
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
				isDead = true;
				if(shakeCam)
				{
					stupidThing = new Boyfriend(0, 0, "bambi3d");
					unlockCharacter("Expunged", "bambi3d", "3D Bambi", FlxColor.fromRGB(stupidThing.healthColorArray[0], stupidThing.healthColorArray[1], stupidThing.healthColorArray[2]), true);	
				}
	
				shakeCam = false;
				screenshader.Enabled = false;

				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if(val == null) val = 0;

				switch(Std.parseInt(value1))
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
						{
							dadbattleSmokes.visible = false;
						}});
				}

			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;
			case 'Quick note spin':
				strumLineNotes.forEach(function(note)
					{
						quickSpin(note);
					});
			case 'Flash effect':
				var flashId:Int = Std.parseInt(value1);
				switch (flashId)
				{
					case 0:
						if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 1);
					case 1:
						if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.BLACK, 1);
					case 2:
						if(ClientPrefs.flashing) camHUD.flash(FlxColor.WHITE, 1);
					case 3:
						if(ClientPrefs.flashing) camHUD.flash(FlxColor.BLACK, 1);
					case 4:
						if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.WHITE, 0.25);
					case 5:
						if(ClientPrefs.flashing) FlxG.camera.flash(FlxColor.BLACK, 0.25);
					case 6:
						if(ClientPrefs.flashing) camHUD.flash(FlxColor.WHITE, 0.25);
					case 7:
						if(ClientPrefs.flashing) camHUD.flash(FlxColor.BLACK, 0.25);
				}
			case 'Hide or Show HUD elements':
				var top10awesomeId:Int = Std.parseInt(value1);
				switch (top10awesomeId)
				{
					case 0:
						hideshit();
					case 1:
						showonlystrums();
					case 2:
						showshit();
				}
			case 'Hide or Show HUD elements with Fade':
				var vsEvilCorruptedBambiDay4Id:Int = Std.parseInt(value1);
				switch (vsEvilCorruptedBambiDay4Id)
				{
					case 0:
						hideHUDFade();
					case 1:
						showHUDFade();
				}
			case 'Toggle Eyesores':
				var a1000YOMAMAjokesCanYouWatchThemAllquestionmarkId:Int = Std.parseInt(value1);
				switch (a1000YOMAMAjokesCanYouWatchThemAllquestionmarkId)
				{
					case 0:
						shakeCam = false;
					case 1: 
						shakeCam = true;
				}
			case 'turn that fuckin spin on':
				var iranoutoffunnynamesId:Int = Std.parseInt(value1);
				switch (iranoutoffunnynamesId)
				{
					case 0:
						daspinlmao = false;
						daleftspinlmao = false;
						camHUD.angle = 0;
					case 1: 
						camHUD.angle = 0;
						daspinlmao = true;
						daleftspinlmao = false;
					case 2: 
						camHUD.angle = 0;
						daleftspinlmao = true;
						daspinlmao = false;
				}
			case 'Thunderstorm type black screen':
				var ballsId:Int = Std.parseInt(value1);
				switch (ballsId)
				{
					case 0: 
						FlxTween.tween(blackScreendeez, {alpha: 0}, Conductor.stepCrochet / 500);
					case 1:
						FlxTween.tween(blackScreendeez, {alpha: 0.35}, Conductor.stepCrochet / 500);
				}
			case 'Switch to Pixel or 3D UI':
				var soId:Int = Std.parseInt(value1);
				switch (soId)
				{
					case 0:
						isPixelStage = true;
						is3DStage = false;
					case 1: 
						isPixelStage = false;
						is3DStage = true;
					case 2:
						isPixelStage = false;
						is3DStage = false;
				}
			case 'Fling Icon To Oblivion And Beyond':
				if (BAMBICUTSCENEICONHURHURHUR == null)
				{
					BAMBICUTSCENEICONHURHURHUR = new HealthIcon('dave', false);
					BAMBICUTSCENEICONHURHURHUR.y = healthBar.y - (BAMBICUTSCENEICONHURHURHUR.height / 2);
					add(BAMBICUTSCENEICONHURHURHUR);
					BAMBICUTSCENEICONHURHURHUR.cameras = [camHUD];
					BAMBICUTSCENEICONHURHURHUR.x = -100;
					FlxTween.linearMotion(BAMBICUTSCENEICONHURHURHUR, -100, BAMBICUTSCENEICONHURHURHUR.y, iconP2.x, BAMBICUTSCENEICONHURHURHUR.y, 0.3, true, {ease: FlxEase.expoInOut});
					new FlxTimer().start(0.3, FlingCharacterIconToOblivionAndBeyond);
				}
			case 'Philly Glow':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var doFlash:Void->Void = function() {
					var color:FlxColor = FlxColor.WHITE;
					if(!ClientPrefs.flashing) color.alphaFloat = 0.5;

					FlxG.camera.flash(color, 0.15, null, true);
				};

				var chars:Array<Character> = [boyfriend, gf, dad];
				switch(lightId)
				{
					case 0:
						if(phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = false;
							phillyWindowEvent.visible = false;
							phillyGlowGradient.visible = false;
							phillyGlowParticles.visible = false;
							curLightEvent = -1;

							for (who in chars)
							{
								who.color = FlxColor.WHITE;
							}
							phillyStreet.color = FlxColor.WHITE;
						}

					case 1: //turn on
						curLightEvent = FlxG.random.int(0, phillyLightsColors.length-1, [curLightEvent]);
						var color:FlxColor = phillyLightsColors[curLightEvent];

						if(!phillyGlowGradient.visible)
						{
							doFlash();
							if(ClientPrefs.camZooms)
							{
								FlxG.camera.zoom += 0.5;
								camHUD.zoom += 0.1;
							}

							blammedLightsBlack.visible = true;
							blammedLightsBlack.alpha = 1;
							phillyWindowEvent.visible = true;
							phillyGlowGradient.visible = true;
							phillyGlowParticles.visible = true;
						}
						else if(ClientPrefs.flashing)
						{
							var colorButLower:FlxColor = color;
							colorButLower.alphaFloat = 0.25;
							FlxG.camera.flash(colorButLower, 0.5, null, true);
						}

						var charColor:FlxColor = color;
						if(!ClientPrefs.flashing) charColor.saturation *= 0.5;
						else charColor.saturation *= 0.75;

						for (who in chars)
						{
							who.color = charColor;
						}
						phillyGlowParticles.forEachAlive(function(particle:PhillyGlow.PhillyGlowParticle)
						{
							particle.color = color;
						});
						phillyGlowGradient.color = color;
						phillyWindowEvent.color = color;

						color.brightness *= 0.5;
						phillyStreet.color = color;

					case 2: // spawn particles
						if(!ClientPrefs.lowQuality)
						{
							var particlesNum:Int = FlxG.random.int(8, 12);
							var width:Float = (2000 / particlesNum);
							var color:FlxColor = phillyLightsColors[curLightEvent];
							for (j in 0...3)
							{
								for (i in 0...particlesNum)
								{
									var particle:PhillyGlow.PhillyGlowParticle = new PhillyGlow.PhillyGlowParticle(-400 + width * i + FlxG.random.float(-width / 5, width / 5), phillyGlowGradient.originalY + 200 + (FlxG.random.float(0, 125) + j * 40), color);
									phillyGlowParticles.add(particle);
								}
							}
						}
						phillyGlowGradient.bop();
				}

			case 'Kill Henchmen':
				killHenchmen();
			
			case 'Spawn Alt Character':
				switch(value1)
				{
					case 'Dad2':
						dad2 = new Character(-250, 0, value2);
						startCharacterPos(dad2, true);
						add(dad2);
					case 'Dad3':
						dad3 = new Character(-250, -100, value2);
						startCharacterPos(dad3, true);
						add(dad3);
				}
	
			case 'Remove Alt Character':
				switch(value1)
				{
					case 'Dad2':
						remove(dad2);
					case 'Dad3':
						remove(dad3);
				}

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}
			case 'Change the Default Camera Zoom': // not to be confused with the one above!
				var mZoom:Float = Std.parseFloat(value1);
				if(Math.isNaN(mZoom)) mZoom = 0.09;

				defaultCamZoom = mZoom;
			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
							case 3: char = badai;
							case 4: char = bandu;
							case 5: char = dave;
							case 6: char = bambi;
							case 7: char = bamburg;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(!CharacterSelectionState.notBF || (isStoryMode || isPurStoryMode))
							{
								if(boyfriend.curCharacter != value2) {
									if(!boyfriendMap.exists(value2)) {
										addCharacterToList(value2, charType);
									}
		
									var lastAlpha:Float = boyfriend.alpha;
									boyfriend.alpha = 0.00001;
									boyfriend = boyfriendMap.get(value2);
									boyfriend.alpha = lastAlpha;
									iconP1.changeIcon(boyfriend.healthIcon);
								}
								setOnLuas('boyfriendName', boyfriend.curCharacter);
							}

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
				reloadTimeBarColors();

			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	var lastCamFocused:Bool;
	var isboyfriend2:Bool = false;
	public function moveCamera(isDad:Bool)
	{
		var bfplaying:Bool = false;
		if(isDad)
		{
			if (lastCamFocused != isDad)
			{
				if (!sectionComboBreaks && sectionHits) {
					add(comboVisual);
					comboVisual.setGraphicSize(Std.int(comboVisual.width * 0.7));
					comboVisual.animation.play('idle');
					new FlxTimer().start(1 / playbackRate, function(tmr:FlxTimer)
						{
							remove(comboVisual);
						});
				}
				sectionComboBreaks = false;
				sectionHits = false;
			}
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.y += dadCamFollowY;
			camFollow.x += dadCamFollowX;
	
			notes.forEachAlive(function(daNote:Note)
			{
				if (!bfplaying)
				{
					if (lastCamFocused != isDad)
					{
						if (!sectionComboBreaks && sectionHits) {
							add(comboVisual);
							comboVisual.setGraphicSize(Std.int(comboVisual.width * 0.7));
							comboVisual.animation.play('idle');
							new FlxTimer().start(0.65 / playbackRate, function(tmr:FlxTimer)
								{
									remove(comboVisual);
								});
						}
						sectionComboBreaks = false;
						sectionHits = false;
					}
					camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					camFollow.y += dadCamFollowY;
					camFollow.x += dadCamFollowX;
	
					if (daNote.mustPress)
					{
						bfplaying = true;
					}
				}
			});
			if (UsingNewCam && bfplaying)
			{
				return;
			}
		}
		if(isDad)
		{
			switch (dad.curCharacter)
			{
				case 'dave-3d' | 'wtf-dave' | 'dave-insanity-3d' | 'bambi-expunged' | 'expunged-tilt':
					camFollow.y = dad.getMidpoint().y;
				case 'bambi-3d' | 'bambi-unfair':
					camFollow.y = dad.getMidpoint().y - 350;
				case 'bombu':
					camFollow.y = dad.getMidpoint().y;
					camFollow.x = dad.getMidpoint().x;
			}

			if (SONG.song.toLowerCase() == 'warmup')
			{
				tweenCamIn();
			}
	
			if (SONG.song.toLowerCase() == 'roundabout')
			{
				defaultCamZoom = 0.95;
			}
	
			if (SONG.song.toLowerCase() == 'rebound' || SONG.song.toLowerCase() == 'disposition' || SONG.song.toLowerCase() == 'dispositon_but_awesome' || SONG.song.toLowerCase() == 'upheaval' || SONG.song.toLowerCase() == 'upheaval-teaser')
			{
				defaultCamZoom = 0.55;
			}
	
			if (SONG.song.toLowerCase() == 'lacuna') {
				defaultCamZoom = 0.45;
			}
	
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.y += dadCamFollowY;
			camFollow.x += dadCamFollowX;
		}
				
		if(!isDad && !isboyfriend2)
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.y += camFollowY;
			camFollow.x += camFollowX;
		
			switch(boyfriend.curCharacter)
			{
				case 'dave-3d' | 'dave-insanity-3d' | 'wtf-dave':
					camFollow.y = boyfriend.getMidpoint().y;
				case 'bambi-3d' | 'bambi-unfair':
					camFollow.y = boyfriend.getMidpoint().y - 350;
			}
		
			if (SONG.song.toLowerCase() == 'warmup')
			{
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.sineInOut});
			}
	
			if (SONG.song.toLowerCase() == 'roundabout')
			{
				defaultCamZoom = 0.95;
			}
	
			if (SONG.song.toLowerCase() == 'rebound' || SONG.song.toLowerCase() == 'disposition' || SONG.song.toLowerCase() == 'disposition_but_awesome' || SONG.song.toLowerCase() == 'upheaval' || SONG.song.toLowerCase() == 'upheaval-teaser')
			{
				defaultCamZoom = 0.7;
			}
	
			if (SONG.song.toLowerCase() == 'lacuna') {
				defaultCamZoom = 0.65;
			}
		}
		if (boyfriend2 != null)
		{
			if(!isDad && isboyfriend2)
			{
				camFollow.set(boyfriend2.getMidpoint().x - 100, boyfriend2.getMidpoint().y - 100);
				camFollow.y += camFollowY;
				camFollow.x += camFollowX;
			}				
		}
	lastCamFocused = isDad;
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.sineInOut});
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		switch (curSong.toLowerCase()) // ENDING DIALOGUE STUFF WITHOUT LUA
		{
	            case 'insanity' | 'maze' | 'splitathon' | 'upheaval': // ADD YOUR SONGS WITH ENDING DIALOGUE HERE
					if (isStoryMode || isPurStoryMode || ClientPrefs.freeplayCuts) 
					{
                        hideshit();
	         	        canPause = false;
	                    endingSong = true;
	                 	camZooming = false;
		                inCutscene = false;
						deathCounter = 0;
						seenCutscene = false;
						updateTime = false;
						FlxG.sound.music.volume = 0;
						vocals.volume = 0;
					}
					else // ELSE IF DEEZ NUTS IN YOUR MOUTH (FUNNY)
					{
						updateTime = false;
						FlxG.sound.music.volume = 0;
						vocals.volume = 0;
						vocals.pause();
						if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
							finishCallback();
						} else {
							finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
								finishCallback();
							});
						}
					}
	    	default:
				updateTime = false;
				FlxG.sound.music.volume = 0;
				vocals.volume = 0;
				vocals.pause();
				if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
					finishCallback();
				} else {
					finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
						finishCallback();
					});
				}
      	}
	}

	function FlingCharacterIconToOblivionAndBeyond(e:FlxTimer = null):Void
	{
		iconP2.changeIcon(dad.healthIcon);
		BAMBICUTSCENEICONHURHURHUR.animation.play(SONG.player2, true, false, 1);
		stupidx = -5;
		stupidy = -5;
		updatevels = true;
	}
	
	function THROWPHONEMARCELLO(e:FlxTimer = null):Void
	{
		STUPDVARIABLETHATSHOULDNTBENEEDED.animation.play("throw_phone");
		new FlxTimer().start(5.5, function(timer:FlxTimer)
		{ 
			FlxG.switchState(new FreeplayState());
		});
	}

	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
		PauseSubState.isPlayState = false;

		#if windows
		if (window != null)
		{
			window.close();
			expungedWindowMode = false;
			window = null;
		}
		#end

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		switch (SONG.song.toLowerCase())
		{
			case 'exploitation':
				Application.current.window.title = Main.applicationName;
		}

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore && !cpuControlled)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}
			switch(curSong.toLowerCase())
				{
					case "bonus-song" | "bonus song":
						stupidThing = new Boyfriend(0, 0, "dave");
						unlockCharacter("Dave", "dave", null, FlxColor.fromRGB(stupidThing.healthColorArray[0], stupidThing.healthColorArray[1], stupidThing.healthColorArray[2]));
						if(characterUnlockObj != null)
							return;
					case "reality-breaking":
						stupidThing = new Boyfriend(0, 0, "lucky");
						unlockCharacter("Lucky", "lucky", null, FlxColor.fromRGB(stupidThing.healthColorArray[0], stupidThing.healthColorArray[1], stupidThing.healthColorArray[2]));
						if(characterUnlockObj != null)
							return;
					case "polygonized":
						if(storyDifficulty == 2)
							{
								stupidThing = new Boyfriend(0, 0, "dave-3d");
								unlockCharacter("3D Dave", "dave3d", null, FlxColor.fromRGB(stupidThing.healthColorArray[0], stupidThing.healthColorArray[1], stupidThing.healthColorArray[2]));
								if(characterUnlockObj != null)
									return;
							}
				}

			if (isStoryMode || isPurStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;
	
				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					cancelMusicFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
			switch (curSong.toLowerCase())
				{
					case 'polygonized':
						stupidThing = new Boyfriend(0, 0, "tristan");
						unlockCharacter("Tristan", "tristan", null, FlxColor.fromRGB(stupidThing.healthColorArray[0], stupidThing.healthColorArray[1], stupidThing.healthColorArray[2]));
						if(characterUnlockObj != null)
							return;
						if (health >= 0.1)
						FlxG.switchState(new EndingState('goodEnding', 'good-ending'));
						else if (health < 0.1)
							{
								FlxG.switchState(new EndingState('vomit_ending', 'bad-ending'));
							}
						else
						FlxG.switchState(new EndingState('badEnding', 'bad-ending'));
					default:
						if (isStoryMode){
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							MusicBeatState.switchState(new StoryMenuState());
						}
						else if (isPurStoryMode){
							FlxG.sound.playMusic(Paths.music('purFreakyMenu'));
							MusicBeatState.switchState(new NewStoryPurgatory());
						}
				}

					// if ()
					if(!practiceMode || !cpuControlled) {
						if (isStoryMode){
							StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

							if (SONG.validScore)
							{
								Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
							}
	 
							FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
							FlxG.save.flush();
						}
						else if (isPurStoryMode){
							NewStoryPurgatory.weekCompleted.set(PurWeekData.weeksList[storyWeek], true);

							if (SONG.validScore)
							{
								Highscore.saveWeekScore(PurWeekData.getWeekFileName(), campaignScore, storyDifficulty);
							}
	 
							FlxG.save.data.weekCompleted = NewStoryPurgatory.weekCompleted;
							FlxG.save.flush();
						}
					}
					practiceMode = false;
					changedDifficulty = false;
					cpuControlled = false;
					chartingMode = false;
				}
				else
				{
					var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];
		
	

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							//resetSpriteCache = true;
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						//resetSpriteCache = true;
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY');
				cancelMusicFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				switch (curSong.toLowerCase())
				{
				case 'demise pt 1':
					PlayState.SONG = Song.loadFromJson("demise-pt-2-hard", "demise-pt-2");
					FlxG.switchState(new PlayState()); // song looping, idk if it will get used again
					return;
				default:
					scoreMultipliersThing = [1, 1, 1, 1];
					if (isFreeplay){
						MusicBeatState.switchState(new FreeplayState());
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						practiceMode = false;
						changedDifficulty = false;
						cpuControlled = false;
						chartingMode = false;
					}
					if (isFreeplayPur){
						MusicBeatState.switchState(new PurFreeplayState());
						FlxG.sound.playMusic(Paths.music('purFreakyMenu'));
						practiceMode = false;
						changedDifficulty = false;
						cpuControlled = false;
						chartingMode = false;
					}
				}
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var hits:Array<Float> = [];
	public var offsetTest:Float = 0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var timeShown = 0;
	public var currentTimingShown:FlxText = null;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		var polyShitPart1:String = "";
		var polyShitPart2:String = '';
		if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel')
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}
		if (curStage.startsWith('3d') || is3DStage)
		{
			polyShitPart1 = 'polygonized/polyUI/';
			polyShitPart2 = '-poly';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
		Paths.image(polyShitPart1 + "sick" + polyShitPart2);
		Paths.image(polyShitPart1 + "good" + polyShitPart2);
		Paths.image(polyShitPart1 + "bad" + polyShitPart2);
		Paths.image(polyShitPart1 + "shit" + polyShitPart2);
		Paths.image(polyShitPart1 + "combo" + polyShitPart2);
		
		for (i in 0...10) {
			Paths.image(polyShitPart1 + 'num' + i + polyShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		if(ClientPrefs.ratinginHud) {
			coolText.x = FlxG.width * 0.35;
		} else { 
			coolText.x = FlxG.width * 0.55;
		}
		//

		var rating:FlxSprite = new FlxSprite();

		//tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff);

		switch (daRating)
		{
			case "shit": // shit
				totalNotesHit += 0;
				shits++;
			case "bad": // bad
				totalNotesHit += 0.5;
				bads++;
			case "good": // good
				totalNotesHit += 0.75;
				goods++;
			case "sick": // sick
				totalNotesHit += 1;
				sicks++;
		}
	
	
		if(daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode) {
			if(isFreeplay || isFreeplayPur)
				{
					songScore += freeplayScore;
				}
			else
				{
					songScore += score;
				}
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		var polyShitPart1:String = "";
		var polyShitPart2:String = '';

		if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' || SONG.player1 == 'bf-holding-gf-pixel')
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}
		if (curStage.startsWith('3d') || is3DStage)
		{
			polyShitPart1 = 'polygonized/polyUI/';
			polyShitPart2 = '-poly';
		}
		
		if(is3DStage) {
			rating.loadGraphic(Paths.image(polyShitPart1 + daRating + polyShitPart2));
		} else {
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		}
		rating.screenCenter();
		rating.x = coolText.x - 40;
		if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' && !PlayState.is3DStage || SONG.player1 == 'bf-holding-gf-pixel' && !PlayState.is3DStage)
		{
			rating.y -= 120;
		}
		else
		{
			rating.y -= 60;
		}
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		if(ClientPrefs.ratinginHud) {
			rating.x += ClientPrefs.comboOffset[0];
			rating.y -= ClientPrefs.comboOffset[1];
		}

		var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
		if(cpuControlled) msTiming = 0;		

		if (currentTimingShown != null)
			remove(currentTimingShown);

		currentTimingShown = new FlxText(500,500,500,"0ms");
		timeShown = 0;
		switch(daRating)
		{
			case 'shit' | 'bad':
				currentTimingShown.color = FlxColor.RED;
			case 'good':
				currentTimingShown.color = FlxColor.GREEN;
			case 'sick':
				currentTimingShown.color = FlxColor.CYAN;
		}
		currentTimingShown.borderStyle = OUTLINE;
		currentTimingShown.borderSize = 2;
		currentTimingShown.borderColor = FlxColor.BLACK;
		currentTimingShown.text = msTiming + "ms";
		currentTimingShown.size = 20;
		currentTimingShown.visible = !ClientPrefs.hideRatings;
		currentTimingShown.active = !ClientPrefs.hideRatings;

		if (currentTimingShown.alpha != 1)
			currentTimingShown.alpha = 1;

		if(!ClientPrefs.hideRatings) {
			insert(members.indexOf(strumLineNotes), currentTimingShown);
		}

		var comboSpr:FlxSprite = new FlxSprite();
			comboSpr.loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = FlxG.random.int(200, 300);
			comboSpr.velocity.y -= FlxG.random.int(140, 160);
			comboSpr.x += ClientPrefs.comboOffset[0];
			comboSpr.y -= ClientPrefs.comboOffset[1];
			if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' && !PlayState.is3DStage || SONG.player1 == 'bf-holding-gf-pixel' && !PlayState.is3DStage)
			{
				comboSpr.y -= 60;
			}
			if(ClientPrefs.ratinginHud) {
				comboSpr.y += 60;
			}
			comboSpr.velocity.x += FlxG.random.int(1, 10);

			currentTimingShown.screenCenter();
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
			if(ClientPrefs.ratinginHud) currentTimingShown.cameras = [camHUD];
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			currentTimingShown.updateHitbox();
			if(ClientPrefs.ratinginHud) {
				currentTimingShown.x += ClientPrefs.comboOffset[0] + 290;
				currentTimingShown.y -= ClientPrefs.comboOffset[1] + 100;
			} else {
				currentTimingShown.x = coolText.x + 230;
				currentTimingShown.y -= 100;
			}

		if(is3DStage) {
			comboSpr.loadGraphic(Paths.image(polyShitPart1 + 'combo' + polyShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			comboSpr.x += ClientPrefs.comboOffset[0];
			comboSpr.y -= ClientPrefs.comboOffset[1];
			if(ClientPrefs.ratinginHud) {
				comboSpr.y += 60;
			}
			comboSpr.velocity.x += FlxG.random.int(1, 10);
		}

		if(!ClientPrefs.hideRatings) {
			insert(members.indexOf(strumLineNotes), rating);
		}

		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' && !PlayState.is3DStage || SONG.player1 == 'bf-holding-gf-pixel' && !PlayState.is3DStage)
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		if(ClientPrefs.ratinginHud) {
		    comboSpr.cameras = [camHUD];
		    rating.cameras = [camHUD];
		}

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			if(!ClientPrefs.hideRatings) {
				insert(members.indexOf(strumLineNotes), comboSpr);
			}
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' && !PlayState.is3DStage || SONG.player1 == 'bf-holding-gf-pixel' && !PlayState.is3DStage)
			{
				numScore.y += 20;
			}
			else
			{
				numScore.y += 80;
			}

			if(ClientPrefs.ratinginHud) {
			    numScore.x += ClientPrefs.comboOffset[2];
				numScore.y -= ClientPrefs.comboOffset[3];
			}

			if(is3DStage) {
			    numScore.loadGraphic(Paths.image(polyShitPart1 + 'num' + Std.int(i) + polyShitPart2));
				numScore.screenCenter();
		     	numScore.x = coolText.x + (43 * daLoop) - 90;
			    numScore.y += 80;
				
	
				if(ClientPrefs.ratinginHud) {
			        numScore.x += ClientPrefs.comboOffset[2];
				    numScore.y -= ClientPrefs.comboOffset[3];
				}
			}

			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (PlayState.isPixelStage || SONG.player1 == 'bf-pixel-normalpos' && !PlayState.is3DStage || SONG.player1 == 'bf-holding-gf-pixel' && !PlayState.is3DStage)
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			else
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			if(ClientPrefs.ratinginHud) {
				numScore.cameras = [camHUD];
			}

			if(!ClientPrefs.hideRatings) {
				insert(members.indexOf(strumLineNotes), numScore);
			}

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		if (combo >= 10 || combo == 0) {
			if(!ClientPrefs.hideRatings) {
				insert(members.indexOf(strumLineNotes), comboSpr);
			}
		}	

		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(currentTimingShown, {alpha:0}, 0.5);

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();
				if (currentTimingShown != null && timeShown >= 20)
				{
					currentTimingShown = null;
				}
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002
		});
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = false;
					}
					if(SONG.song.toLowerCase() == "unfairness" || SONG.song.toLowerCase() == "unfairness-remix")
					{
						canMiss = true; // cry about it
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance2();
				camFollowX = 0;
				camFollowY = 0;
				if(UsingNewCam) bfSingYeah = false;
				//boyfriend.animation.curAnim.finish();
			} 
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}
	var boyfriendCanMiss:Bool = true;

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		sectionComboBreaks = true;
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		healthTween(-daNote.missHealth * healthLoss);
		
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		if (!ClientPrefs.noMissSounds)
		{
			vocals.volume = 0;
		}
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';
	
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		} else if(!boyfriend.hasMissAnimations) {
			boyfriend.color = 0xFF000084;
	
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))];
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{	
		if(ClientPrefs.ghostTapping) return; //fuck it
		
		sectionComboBreaks = true;
		if (!boyfriend.stunned)
		{
			healthTween(-0.05 * healthLoss);
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			if (!ClientPrefs.noMissSounds)
			{	
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			}
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			} else if(!boyfriend.hasMissAnimations) {
				boyfriend.color = 0xFF000084;

				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))], true);
			}
		}
		callOnLuas('noteMissPress', [direction]);
	}

	var healthtolower:Float = 0.02;
	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'warmup')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.notes[Math.floor(curStep / 16)].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].altAnim || note.noteType == 'Alt Animation') {
				altAnim = '-alt';
			}
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.notes[Math.floor(curStep / 16)].altAnim)
					if (SONG.song.toLowerCase() != "cheating" || SONG.song.toLowerCase() != "disruption")
					{
						altAnim = '-alt';
					}
					else
					{
						healthtolower = 0.005;
					}
			}

		//'LEFT', 'DOWN', 'UP', 'RIGHT'
		var fuckingDumbassBullshitFuckYou:String;
		fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(note.noteData)) % 4];
		if(dad.nativelyPlayable)
		{
			switch(notestuffs[Math.round(Math.abs(note.noteData)) % 4])
			{
				case 'LEFT':
					fuckingDumbassBullshitFuckYou = 'RIGHT';
				case 'RIGHT':
					fuckingDumbassBullshitFuckYou = 'LEFT';
			}
		}
		if(badaiTime)
		{
			badai.holdTimer = 0;
			badai.playAnim('sing' + fuckingDumbassBullshitFuckYou + altAnim, true);
		}

			var char:Character = dad;
			var animToPlay:String = '';
			switch (Math.abs(note.noteData))
			{
				case 0:
					animToPlay = 'singLEFT';
					switch (curSong.toLowerCase())
						{
						case 'sucked':
							if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
					    	if(ClientPrefs.flashing) FlxTween.tween(camHUD,{x: -25}, 0.1, {ease: FlxEase.expoOut});
						}
					if(ClientPrefs.followarrow) dadCamFollowY = 0;
					if(ClientPrefs.followarrow)	dadCamFollowX = -25;
				case 1:
					animToPlay = 'singDOWN';
					switch (curSong.toLowerCase())
						{
						case 'sucked':
							if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
							if(ClientPrefs.flashing) FlxTween.tween(camHUD,{y: 25}, 0.1, {ease: FlxEase.expoOut});
						}
					if(ClientPrefs.followarrow) dadCamFollowY = 25;
					if(ClientPrefs.followarrow)	dadCamFollowX = 0;
				case 2:
					animToPlay = 'singUP';
					switch (curSong.toLowerCase())
						{
						case 'sucked':
							if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
							if(ClientPrefs.flashing) FlxTween.tween(camHUD,{y: -25}, 0.1, {ease: FlxEase.expoOut});
						}
					if(ClientPrefs.followarrow) dadCamFollowY = -25;
					if(ClientPrefs.followarrow)	dadCamFollowX = 0;
				case 3:
					animToPlay = 'singRIGHT';
					switch (curSong.toLowerCase())
						{
						case 'sucked':
							if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
							if(ClientPrefs.flashing) FlxTween.tween(camHUD,{x: 25}, 0.1, {ease: FlxEase.expoOut});
						}
					if(ClientPrefs.followarrow) dadCamFollowY = 0;
					if(ClientPrefs.followarrow)	dadCamFollowX = 25;
				}
			if (UsingNewCam && !bfSingYeah) {
				isDadGlobal = true;
				moveCamera(true);
			}
			if(note.noteType == 'GF Sing') {
				gf.playAnim(animToPlay + altAnim, true);
				gf.holdTimer = 0;
			}
			if(note.noteType == 'badai') {
				badai.playAnim(animToPlay + altAnim, true);
				badai.holdTimer = 0;
			}
			if(note.noteType == 'bandu') {
				bandu.playAnim(animToPlay + altAnim, true);
				bandu.holdTimer = 0;
			}
			if(note.noteType == 'bamburg') {
				bamburg.playAnim(animToPlay + altAnim, true);
				bamburg.holdTimer = 0;
			}
			if(note.noteType == 'dave') {
				dave.playAnim(animToPlay + altAnim, true);
				dave.holdTimer = 0;
			}
			if(note.noteType == 'bambi') {
				bambi.playAnim(animToPlay + altAnim, true);
				bambi.holdTimer = 0;
			}
			if(note.noteType == '') {
				dad.playAnim(animToPlay + altAnim, true);
				dad.holdTimer = 0;
			}
		}

		switch (curSong.toLowerCase()){
			case 'disposition' | 'disposition_but_awesome':
				if(ClientPrefs.flashing) camHUD.shake(0.0065, 0.1);
				if(health > 0.05) health -= 0.01;
				if(gf.animOffsets.exists('scared')) {
				gf.playAnim('scared', true); 
				}
			case 'devastation':
				if(health > 0.1) health -= 0.01;
				if(curStep > 3232) camHUD.shake(0.0065, 0.1);
			case 'devastation-fanmade':
				if(health > 0.1) health -= 0.01;
				if(curStep > 4800) camHUD.shake(0.0065, 0.1);
				if(curStep > 4800) FlxG.camera.shake(0.0075, 0.1);
			case 'rebound':
				if(ClientPrefs.flashing) camHUD.shake(0.0025, 0.050);
				if(health > 0.5) health -= 0.01;
				if(gf.animOffsets.exists('scared')) {
				gf.playAnim('scared', true);
				}
			case 'antagonism' | 'new-antagonism' | 'antagonism-11-minutes' | 'reheated':
				if(ClientPrefs.flashing) camHUD.shake(0.0025, 0.050);
				if(health > 0.5) health -= 0.02;
				if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
			case 'antagonism-poip-part':
				if(health > 0.5) health -= 0.01;
			case 'demise pt 1' | 'demise pt 2':
				if(health > 0.5) health -= 0.02;
			case 'despair':
				if(ClientPrefs.flashing) camHUD.shake(0.0025, 0.050);
				if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
				if(health > 0.25) health -= 0.02;
			case 'cheating':
			   	health -= healthtolower;		
			  	if(ClientPrefs.flashing) camHUD.shake(0.0045, 0.1);
			case 'cheating b-side' | 'exploitation':
				if (((health + (FlxEase.backInOut(health / 16.5)) - 0.002) >= 0) && !(curBeat >= 320 && curBeat <= 330))
				{
					health += ((FlxEase.backInOut(health / 16.5)) * (curBeat <= 160 ? 0.25 : 1)) - 0.002; //some training wheels cuz rapparep say mod too hard
				}		
			case 'reality breaking':
				if(health > 0.5) health -= healthtolower;		
				if(ClientPrefs.flashing) camHUD.shake(0.0025, 0.050);
				if(ClientPrefs.chromaticAberration) doneloll2 = true;
				if(ClientPrefs.chromaticAberration) stupidInt = 10;				
			case 'unfairness' | 'unfairness-remix':
			 	health -= (healthtolower / 6);
			   	if(ClientPrefs.flashing) camHUD.shake(0.0045, 0.1);
				if(ClientPrefs.flashing) FlxG.camera.shake(0.0075, 0.1);
			case 'disruption':
			   	health -= healthtolower / 2.65;
				if(ClientPrefs.flashing) camHUD.shake(0.0045, 0.1);
			case 'lacuna':
				if(health > 0.5) health -= 0.01;
				#if desktop
				if (oppositionMoment) {
					shakewindow(); // this shit kinda fuck ups the framerate LOL, is it a good idea to keep it?
				}
				#end
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
		
		switch (SONG.song.toLowerCase())
		{
			case 'ok':
				if (unfairPart)
				{
					note.y = ((note.mustPress ? noteJunksPlayer[note.noteData] : noteJunksDad[note.noteData])- (Conductor.songPosition - note.strumTime) * (-0.45 * FlxMath.roundDecimal(1 * note.LocalScrollSpeed, 2))); // couldnt figure out this stupid mystrum thing
				}
				else
				{
					if (FlxG.save.data.downscroll)
						note.y = (strumLine.y - (Conductor.songPosition - note.strumTime) * (-0.45 * FlxMath.roundDecimal(songSpeed * 1, 2)));
					else
						note.y = (strumLine.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(songSpeed * 1, 2)));
				}
			case 'algebra':
				if (FlxG.save.data.downscroll)
					note.y = (strumLine.y - (Conductor.songPosition - note.strumTime) * (-0.45 * FlxMath.roundDecimal(swagSpeed * note.LocalScrollSpeed, 2)));
				else
					note.y = (strumLine.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(swagSpeed * note.LocalScrollSpeed, 2)));
			default:
				if (FlxG.save.data.downscroll)
					note.y = (strumLine.y - (Conductor.songPosition - note.strumTime) * (-0.45 * FlxMath.roundDecimal(songSpeed * note.LocalScrollSpeed, 2)));
				else
					note.y = (strumLine.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(songSpeed * note.LocalScrollSpeed, 2)));
		}
		// trace(daNote.y);
		// WIP interpolation shit? Need to fix the pause issue
		// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.songSpeed));
	
		var strumliney = note.MyStrum != null ? note.MyStrum.y : strumLine.y;
	
		if (SONG.song.toLowerCase() == 'ok') {
			if (unfairPart) strumliney = note.MyStrum != null ? note.MyStrum.y : strumLine.y;
			else strumliney = strumLine.y;
		}
	
		if (((note.y < -note.height && !FlxG.save.data.downscroll || note.y >= strumliney + 106 && FlxG.save.data.downscroll) && SONG.song.toLowerCase() != 'ok') 
			|| (SONG.song.toLowerCase() == 'ok' && unfairPart && note.y >= strumliney + 106) 
			|| (SONG.song.toLowerCase() == 'ok' && !unfairPart && (note.y < -note.height && !FlxG.save.data.downscroll || note.y >= strumliney + 106 && FlxG.save.data.downscroll)))
		{
			/*
			trace((SONG.song.toLowerCase() == 'devastation' && unfairPart && daNote.y >= strumliney + 106) );
			trace(daNote.y);
			*/
	
			note.active = false;
			note.visible = false;
	
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	var nps:Int = 0;
	var maxNPS:Int = 0;
	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (!note.isSustainNote)
				notesHitArray.unshift(Date.now());

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				if(ClientPrefs.hitsounds)
				{
					FlxG.sound.play(Paths.sound('hitsounds/' + ClientPrefs.hitsoundtype, 'shared'), ClientPrefs.hitsoundVolume);
				}
				
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}
			//health += note.hitHealth * healthGain;
			healthTween(note.hitHealth * healthGain);

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';

				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];
				switch (Std.int(Math.abs(note.noteData)))
				{
					case 0:
						animToPlay = 'singLEFT';
						switch (curSong.toLowerCase())
						{
						case 'sucked':
						   camHUD.x = 0;
						   camHUD.y = 0;
					    }
							if(ClientPrefs.followarrow) camFollowY = 0;
							if(ClientPrefs.followarrow)	camFollowX = -25;
					case 1:
						animToPlay = 'singDOWN';
						switch (curSong.toLowerCase())
						{
						case 'sucked':
						   camHUD.x = 0;
						   camHUD.y = 0;
					    }
							if(ClientPrefs.followarrow) camFollowY = 25;
							if(ClientPrefs.followarrow)	camFollowX = 0;
					case 2:
						animToPlay = 'singUP';
						switch (curSong.toLowerCase())
						{
						case 'sucked':
						   camHUD.x = 0;
						   camHUD.y = 0;
					    }
							if(ClientPrefs.followarrow) camFollowY = -25;
							if(ClientPrefs.followarrow)	camFollowX = 0;
					case 3:
						animToPlay = 'singRIGHT';
						switch (curSong.toLowerCase())
						{
						case 'sucked':
						   camHUD.x = 0;
						   camHUD.y = 0;
					    }
							if(ClientPrefs.followarrow) camFollowY = 0;
							if(ClientPrefs.followarrow)	camFollowX = 25;
				}

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else if(boyfriend2 != null) {
					if(note.noteType == 'boyfriend2') 
					{
						boyfriend2.playAnim(animToPlay + note.animSuffix, true);
						boyfriend2.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}

				if(!boyfriend.hasMissAnimations) {
			    	if (hasBfDarkLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
			    		boyfriend.color = 0xFF878787;
			    	}
		     		if(hasBfSunsetLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
			    		boyfriend.color = 0xFFFF8F65;
			    	}
			    	if(hasBfDarkerLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
				    	boyfriend.color = 0xFF383838;
			     	}
			    	else
		     		{
			    		boyfriend.color = FlxColor.WHITE;
			    	}
				}
				if (UsingNewCam) bfSingYeah = true;
			}

			if (UsingNewCam && !dadSingYeah) {
			    isDadGlobal = false;
			    moveCamera(false);
		    }

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			sectionHits = true;
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	function shakewindow()
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			Lib.application.window.move(Lib.application.window.x + FlxG.random.int( -5, 5),Lib.application.window.y + FlxG.random.int( -1, 1));
		}, 20);
	}
	
	function movesidetoside()
	{
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			Lib.application.window.move(Lib.application.window.x + 5, Lib.application.window.y + 0);
		}, 2);
	}
	
	function guh()
	{
		playerStrums.forEach(function(spr:FlxSprite)
			{
				if(!ClientPrefs.downScroll) {
					spr.y = 40;
				}
				if(ClientPrefs.downScroll) {
					spr.y = 550;
				}
			});
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				if(!ClientPrefs.downScroll) {
					spr.y = 40;
				}
				if(ClientPrefs.downScroll) {
					spr.y = 550;
				}
			});
	}

	function dialogBullshitStart() {
		startDialogue(dialogueJson);
	}

	function hideshit() // basically a camHUD.visible = false; except it doesnt fuck up dialogue (and i didnt want to do another camera for the dialogue)
	{
		if(!ClientPrefs.hideHud) {
			songWatermark.visible = false;
			healthBar.visible = false;
			healthBarBG.visible = false;
			healthBarOverlay.visible = false;
			iconP1.visible = false;
			iconP2.visible = false;
			scoreTxt.visible = false;
		} 
		creditsWatermark.visible = false;
		judgementCounter.visible = false;
		strumLineNotes.visible = false;
		grpNoteSplashes.visible = false;
		notes.visible = false;
		if(!ClientPrefs.hideTime) {
	    	timeBar.visible = false;
	    	timeBarBG.visible = false;
		    timeTxt.visible = false;
		}
	}
	
	function showshit()
	{
		if(!ClientPrefs.hideHud) {
			songWatermark.visible = true;
			healthBar.visible = true;
			healthBarBG.visible = true;
			healthBarOverlay.visible = true;
			iconP1.visible = true;
			iconP2.visible = true;
			scoreTxt.visible = true;
		} 
		creditsWatermark.visible = true;
		judgementCounter.visible = true;
		strumLineNotes.visible = true;
		grpNoteSplashes.visible = true;
		notes.visible = true;
		if(!ClientPrefs.hideTime) {
	    	timeBar.visible = true;
	    	timeBarBG.visible = true;
		    timeTxt.visible = true; 
		} 
	}
	
	function showonlystrums() // does the thing that it says
	{
		songWatermark.visible = true;
		creditsWatermark.visible = true;
		judgementCounter.visible = true;
		if(!ClientPrefs.hideHud) {
			healthBar.visible = false;
			healthBarBG.visible = false;
			healthBarOverlay.visible = false;
			iconP1.visible = false;
			iconP2.visible = false;
			scoreTxt.visible = false;
		}
		strumLineNotes.visible = true;
		grpNoteSplashes.visible = true;
		notes.visible = true;
		if(!ClientPrefs.hideTime) {
			timeBar.visible = false;
			timeBarBG.visible = false;
			timeTxt.visible = false;
	   }
	}
	
	function hideHUDFade() // DONT USE THIS AT STEP 0!!!
	{
		FlxTween.tween(camHUD, {alpha:0}, 1);
	}
		
	function showHUDFade()
	{
		FlxTween.tween(camHUD, {alpha:1}, 1);
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	var tankX:Float = 400;
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank(?elapsed:Float = 0):Void
	{
		if(!inCutscene)
		{
			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		#if hscript
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	function swapGlitch(glitchTime:Float, toBackground:String)
	{
		//hey t5 if you make the static fade in and out, can you use the sounds i made? they are in preload
		var glitch = new BGSprite('ui/glitch/glitchSwitch', 0, 0); 
		glitch.animation.addByPrefix('glitch', 'glitchScreen', 24, false);
		glitch.setGraphicSize(Std.int(glitch.width * 2));
		glitch.scrollFactor.set();
		glitch.cameras = [camHUD];
		glitch.setGraphicSize(FlxG.width, FlxG.height);
		glitch.updateHitbox();
		glitch.screenCenter();
		glitch.animation.play('glitch');
		add(glitch);

		new FlxTimer().start(glitchTime, function(timer:FlxTimer)
		{
			expungedBG.setPosition(-1000, -700);
			switch (toBackground)
			{
				case 'expunged':
					expungedBG.loadGraphic(Paths.image('backgrounds/void/exploit/creepyRoom'));
					expungedBG.setGraphicSize(Std.int(expungedBG.width * 1.25));
				case 'cheating':
					expungedBG.loadGraphic(Paths.image('backgrounds/void/exploit/cheater GLITCH'));
					expungedBG.setGraphicSize(Std.int(expungedBG.width * 1.25));
				case 'cheating-2':
					expungedBG.loadGraphic(Paths.image('backgrounds/void/exploit/glitchy_cheating_2'));
					expungedBG.setGraphicSize(Std.int(expungedBG.width * 1.25));
				case 'unfair':
					expungedBG.loadGraphic(Paths.image('backgrounds/void/exploit/glitchyUnfairBG'));
					expungedBG.setGraphicSize(Std.int(expungedBG.width * 1.25));
				case 'chains':
					expungedBG.loadGraphic(Paths.image('backgrounds/void/exploit/expunged_chains'));
					expungedBG.setGraphicSize(Std.int(expungedBG.width * 1.25));
			}
			remove(glitch);
		});
	}

	var lastStepHit:Int = -1;
	var black:FlxSprite;
	override function stepHit()
	{

		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}
	
		if (curSong == '8-28-63' || curSong == 'prejudice')
		{
			if (curStep >= 576 && curStep < 608 || curStep >= 1856 && curStep < 1888)
			{
					if (curBeat % 0.5 == 0)
					{
						defaultCamZoom += 0.01;	
						
					}
			}
			if (curStep >= 624 && curStep < 640 || curStep >= 1904 && curStep < 1920 )
			{
					if (curBeat % 0.5 == 0)
					{
						defaultCamZoom -= 0.02;	
					}
			}
			switch (curStep)
			{			
				case 640, 1920:
					defaultCamZoom = 1.2;
				case 1152, 2432:
					defaultCamZoom = 0.8;
			}
		}
	
		switch (SONG.song.toLowerCase())
		{
			case 'platonic':
				switch (curStep)
				{
					case 120:
						daCountDownMidSong();
				}
			case 'furiosity':
				switch (curStep)
				{
					case 512 | 768:
						shakeCam = true;
					case 640 | 896:
						shakeCam = false;
					case 1305:
						var position = dad.getPosition();
						FlxG.camera.flash(FlxColor.WHITE, 0.25);
						FlxTween.linearMotion(dad, dad.x, dad.y, 350, 260, 0.6, true);
				}
			case 'old-furiosity':
				switch (curStep)
				{
					case 512 | 768:
						shakeCamALT = true;
					case 640 | 896:
						shakeCamALT = false;
				}
			case 'polygonized':
				switch(curStep)
				{
					case 1024 | 1312 | 1424 | 1552 | 1664:
						shakeCam = true;
					case 1152 | 1408 | 1472 | 1600 | 2048 | 2176:
						shakeCam = false;
				}
			case 'glitch':
				switch (curStep)
				{
					case 15:
						dad.playAnim('hey', true);
					case 16 | 719 | 1167:
						defaultCamZoom = 1;
					case 80 | 335 | 588 | 1103:
						defaultCamZoom = 0.8;
					case 584 | 1039:
						defaultCamZoom = 1.2;
					case 272 | 975:
						defaultCamZoom = 1.1;
					case 464:
						defaultCamZoom = 1;
						FlxTween.linearMotion(dad, dad.x, dad.y, 25, 50, 20, true);
					case 848:
						shakeCam = false;
						camZoomSnap = false;
						defaultCamZoom = 1;
					case 132 | 612 | 740 | 771 | 836:
						shakeCam = true;
						camZoomSnap = true;
						defaultCamZoom = 1.2;
					case 144 | 624 | 752 | 784:
						shakeCam = false;
						camZoomSnap = false;
						defaultCamZoom = 0.8;
					case 1231:
						defaultCamZoom = 0.8;
						FlxTween.linearMotion(dad, dad.x, dad.y, 50, 280, 1, true);
				}
			case 'supernovae':
				switch (curStep)
				{
					case 60:
						dad.playAnim('hey', true);
					case 64:
						defaultCamZoom = 1;
					case 192:
						defaultCamZoom = 0.9;
					case 320 | 768:
						defaultCamZoom = 1.1;
					case 444:
						defaultCamZoom = 0.6;
					case 448 | 960 | 1344:
						defaultCamZoom = 0.8;
					case 896 | 1152:
						defaultCamZoom = 1.2;
					case 1024:
						defaultCamZoom = 1;
						shakeCam = true;
						FlxTween.linearMotion(dad, dad.x, dad.y, 25, 50, 15, true);

					case 1280:
						FlxTween.linearMotion(dad, dad.x, dad.y, 50, 280, 0.6, true);
						shakeCam = false;
						defaultCamZoom = 1;
				}
			case 'master':
				switch (curStep)
				{
					case 128:
						defaultCamZoom = 0.7;
					case 252 | 512:
						defaultCamZoom = 0.4;
						shakeCam = false;
					case 256:
						defaultCamZoom = 0.8;
					case 380:
						defaultCamZoom = 0.5;
					case 384:
						defaultCamZoom = 1;
						shakeCam = true;
					case 508:
						defaultCamZoom = 1.2;
					case 560:
						dad.playAnim('die', true);			
						FlxG.sound.play(Paths.sound('dead'), 1);
					case 568:
						dad.playAnim('die', true);
					case 576:
						dad.playAnim('die', true);	
					}
			case 'mastered':
				switch (curStep)
				{
					case 128:
						defaultCamZoom = 0.7;
					case 252 | 512:
						defaultCamZoom = 0.4;
						shakeCam = false;
					case 256:
						defaultCamZoom = 0.8;
					case 380:
						defaultCamZoom = 0.5;
					case 384:
						defaultCamZoom = 1;
						shakeCam = true;
					case 508:
						defaultCamZoom = 1.2;
					case 608:
						defaultCamZoom += 0.2;
						black = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
						black.screenCenter();
						black.alpha = 0;
						add(black);
						FlxTween.tween(black, {alpha: 0.6}, 1);
						makeInvisibleNotes(true);
					case 624:
						subtitleManager.addSubtitle('You are monster.', 0.02, 0.6);
					case 640:
						defaultCamZoom -= 0.2;
						FlxTween.tween(black, {alpha: 0}, 1);
						makeInvisibleNotes(false);
					case 2576:
						makeInvisibleNotes(true);
					case 2608:
						defaultCamZoom += 0.2;
						black = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
						black.screenCenter();
						black.alpha = 0;
						add(black);
						FlxTween.tween(black, {alpha: 0.6}, 1);
						makeInvisibleNotes(true);
					case 2624:
						subtitleManager.addSubtitle('You ruined my life.', 0.02, 1);
					case 2656:
						dad.playAnim('die', true);
						defaultCamZoom -= 0.2;
						FlxTween.tween(black, {alpha: 0}, 1);
					case 2664:
						dad.playAnim('die', true);
					case 2672:
						dad.playAnim('die', true);
					case 2680:
						dad.playAnim('die', true);
					case 2688:
						dad.playAnim('die', true);
					}
			case 'cheating b-side':
				switch(curStep)
				{
					case 640:
						defaultCamZoom += 0.2;
						black = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
						black.screenCenter();
						black.alpha = 0;
						add(black);
						FlxTween.tween(black, {alpha: 0.6}, 1);
						makeInvisibleNotes(true);
					case 654:
						subtitleManager.addSubtitle('Stop.', 0.02, 0.3);
					case 663:
						subtitleManager.addSubtitle('Fucking.', 0.02, 0.3);
					case 669:
						subtitleManager.addSubtitle('Calling me, you hate me.', 0.02, 1);
					case 684:
						subtitleManager.addSubtitle('You\'re bullying me, you trollin me.', 0.02, 1);
					case 699:
						subtitleManager.addSubtitle('You liar!', 0.02, 0.3);
					case 733:
						subtitleManager.addSubtitle('I want you look at me.', 0.02, 1);
					case 745:
						subtitleManager.addSubtitle('Look, at the fucking me.', 0.02, 1.25);
					case 759:
						subtitleManager.addSubtitle('Look at me!', 0.02, 0.3);
					case 767:
						subtitleManager.addSubtitle('Allison, just stop!', 0.02, 0.6);
					case 783:
						subtitleManager.addSubtitle('Holy shit!', 0.02, 0.6);
					case 799:
						subtitleManager.addSubtitle('Allison, Allison.', 0.02, 0.6);
					case 809:
						subtitleManager.addSubtitle('Look at me.', 0.02, 0.3);
					case 818:
						subtitleManager.addSubtitle('Look at you...', 0.02, 0.3);
					case 824:
						subtitleManager.addSubtitle('Ugly, look at you, you ugly shit!', 0.02, 1.5);
					case 844:
						subtitleManager.addSubtitle('Allison, stop!', 0.02, 0.6);
					case 862:
						subtitleManager.addSubtitle('Holy shit!', 0.02, 0.3);
					case 868:
						makeInvisibleNotes(false);
					case 883:
						subtitleManager.addSubtitle('Shut the fuck up!', 0.02, 1);
					case 896:
						defaultCamZoom -= 0.2;
						FlxTween.tween(black, {alpha: 0}, 1);
					case 1400:
						makeInvisibleNotes(true);
					case 1520:
						defaultCamZoom += 0.2;
						black = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
						black.screenCenter();
						black.alpha = 0;
						add(black);
						FlxTween.tween(black, {alpha: 0.6}, 1);
					case 1524:
						subtitleManager.addSubtitle('That\'s it.', 0.02, 0.3);
					case 1532:
						subtitleManager.addSubtitle('That\'s it.', 0.02, 0.3);
					case 1536:
						defaultCamZoom -= 0.2;
						FlxTween.tween(black, {alpha: 0}, 1);
	
				}
			case 'exploitation':
				switch(curStep)
				{
					case 12, 18, 23:
						blackScreen.alpha = 1;
						FlxTween.tween(blackScreen, {alpha: 0}, Conductor.crochet / 1000);
						FlxG.sound.play(Paths.sound('static'), 0.5);
						
					case 32:
						FlxTween.tween(boyfriend, {alpha: 0}, 3);
						FlxTween.tween(gf, {alpha: 0}, 3);
						defaultCamZoom = FlxG.camera.zoom + 0.3;
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 4);
						subtitleManager.addSubtitle('The fuck?', 0.02, 1);
					case 56:
						subtitleManager.addSubtitle('Ehhhhhhhhhhhhhhhhhhhhh!!!', 0.02, 0.8);
					case 64:
						subtitleManager.addSubtitle('Wahahauahahahuehehe!', 0.02, 1);
					case 85:
						subtitleManager.addSubtitle('Fucking phone...', 0.02, 1);
					case 99:
						subtitleManager.addSubtitle('Eoooooooooooooooooo', 0.02, 0.5);
					case 105:
						subtitleManager.addSubtitle('Seeeiuuuuuuuuuuuuuu', 0.02, 0.5);
					case 117:
						subtitleManager.addSubtitle('Naaaaaaaaaaaaaaaaaaaaa', 0.02, 1);		
					case 128 | 576:
						defaultCamZoom = FlxG.camera.zoom - 0.3;
						FlxTween.tween(boyfriend, {alpha: 1}, 0.2);
						FlxTween.tween(gf, {alpha: 1}, 0.2);
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.3}, 0.05);
					case 184 | 824:
						FlxTween.tween(FlxG.camera, {angle: 10}, 0.1);
					case 188 | 828:
						FlxTween.tween(FlxG.camera, {angle: -10}, 0.1);
					case 192 | 832:
						FlxTween.tween(FlxG.camera, {angle: 0}, 0.2);
					case 512:
						subtitleManager.addSubtitle('Aehehehe...', 0.02, 1);
						FlxTween.tween(boyfriend, {alpha: 0}, 3);
						FlxTween.tween(gf, {alpha: 0}, 3);
						defaultCamZoom = FlxG.camera.zoom + 0.3;
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 4);
					case 524:
						subtitleManager.addSubtitle('Oh he...', 0.02, 1);
					case 533:
						subtitleManager.addSubtitle('You are so', 0.02, 0.7);
					case 545:
						subtitleManager.addSubtitle('get trolled!', 0.02, 1);
					case 566:
						subtitleManager.addSubtitle('Whoopsies...', 0.02, 1);
					case 1263:
						subtitleManager.addSubtitle('You lying!', 0.02, 0.3);
					case 1270:
						subtitleManager.addSubtitle('YOU LYING!', 0.02, 0.3);	
					case 1276:
						subtitleManager.addSubtitle('A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€A€', 0.02, 0.3);
						FlxG.camera.fade(FlxColor.WHITE, (Conductor.stepCrochet / 1000) * 4, false, function()
						{
							FlxG.camera.stopFX();
						});
						FlxG.camera.shake(0.015, (Conductor.stepCrochet / 1000) * 4);
						windowProperties = [
							Application.current.window.x,
							Application.current.window.y,
							Application.current.window.width,
							Application.current.window.height
						];
					case 1280:
						shakeCam = true;
						FlxG.camera.zoom -= 0.2;

						#if windows
						popupWindow();
						#end

					case 1282:
						expungedBG.loadGraphic(Paths.image('backgrounds/void/exploit/broken_expunged_chain'));
						expungedBG.setGraphicSize(Std.int(expungedBG.width * 2));
					case 1311:
						shakeCam = false;
						FlxG.camera.zoom += 0.2;	
					case 1343:
						shakeCam = true;
						FlxG.camera.zoom -= 0.2;	
					case 1375:
						shakeCam = false;
						FlxG.camera.zoom += 0.2;
					case 1487:
						shakeCam = true;
						FlxG.camera.zoom -= 0.2;
					case 1503:
						shakeCam = false;
						FlxG.camera.zoom += 0.2;
					case 1536:						
						expungedBG.loadGraphic(Paths.image('backgrounds/void/exploit/creepyRoom'));
						expungedBG.setGraphicSize(Std.int(expungedBG.width * 2));
						expungedBG.setPosition(0, 200);
						

					case 2080:
						#if windows
						if (window != null)
						{
							window.close();
							expungedWindowMode = false;
							window = null;
							FlxTween.tween(Application.current.window, {x: windowProperties[0], y: windowProperties[1], width: windowProperties[2], height: windowProperties[3]}, 1, {ease: FlxEase.circInOut});
							FlxTween.tween(iconP2, {alpha: 0}, 1, {ease: FlxEase.bounceOut});
						}
						#end
					case 2083:
						PlatformUtil.sendWindowsNotification("Anticheat.dll", "Threat expunged.dat successfully contained.");
				}
			case 'dishonored':
				switch(curStep)
				{
					case 1:
						windowProperties = [
							Application.current.window.x,
							Application.current.window.y,
							Application.current.window.width,
							Application.current.window.height
						];
					case 768:
						#if windows
						popupWindow();
						#end
					case 1940:
						#if windows
						if (window != null)
						{
							window.close();
							expungedWindowMode = false;
							window = null;
							FlxTween.tween(Application.current.window, {x: windowProperties[0], y: windowProperties[1], width: windowProperties[2], height: windowProperties[3]}, 1, {ease: FlxEase.circInOut});
						}
						#end
				}
			case 'deploration':
				switch (curStep)
				{
					case 1788:
						windowProperties = [
							Application.current.window.x,
							Application.current.window.y,
							Application.current.window.width,
							Application.current.window.height
						];
					case 1792:
						#if windows
						popupWindow();
						#end
					case 3104:
						#if windows
						if (window != null)
						{
							window.close();
							expungedWindowMode = false;
							window = null;
							FlxTween.tween(Application.current.window, {x: windowProperties[0], y: windowProperties[1], width: windowProperties[2], height: windowProperties[3]}, 1, {ease: FlxEase.circInOut});
						}
						#end
				}
		}
		if (SONG.song.toLowerCase() == 'exploitation' && curStep % 8 == 0)
		{
			var fonts = ['arial', 'chalktastic', 'openSans', 'pkmndp', 'barcode', 'vcr', 'comic'];
			var chosenFont = fonts[FlxG.random.int(0, fonts.length)];
			songWatermark.font = Paths.font('exploit/${chosenFont}.ttf');
			creditsWatermark.font = Paths.font('exploit/${chosenFont}.ttf');
			scoreTxt.font = Paths.font('exploit/${chosenFont}.ttf');
			judgementCounter.font = Paths.font('exploit/${chosenFont}.ttf');
			timeTxt.font = Paths.font('exploit/${chosenFont}.ttf');
			botplayTxt.font = Paths.font('exploit/${chosenFont}.ttf');
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	public var opponentIconScale:Float = 1.2;
	public var playerIconScale:Float = 1.2;

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		switch (SONG.song.toLowerCase())
     	{
			case 'exploitation':
				switch (curBeat)
				{
					case 143:
						swapGlitch(Conductor.crochet / 1500, 'cheating');
					case 191:
						swapGlitch(Conductor.crochet / 1500, 'expunged');
					case 255:
						swapGlitch(Conductor.crochet / 4000, 'unfair');
					case 287:
						swapGlitch(Conductor.crochet / 1500, 'chains');
					case 455:
						swapGlitch(Conductor.crochet / 1500, 'cheating-2');
					case 486:
						swapGlitch((Conductor.crochet / 4000) * 2, 'expunged');
				}
			case 'reality breaking':
				switch (curBeat)
				{
					case 128:
						camHUD.flash(FlxColor.WHITE, 0.25);
						#if windows
						if(ClientPrefs.chromaticAberration)
						{
				     		if(ClientPrefs.chromaticAberration)
							{
								camHUD.setFilters([new ShaderFilter(shader_chromatic_abberation.shader), new ShaderFilter(grain_shader.shader)]);
							}
					     	else
							{
								camHUD.setFilters([new ShaderFilter(grain_shader.shader)]);
							}
						}
						#end
					case 256 | 512:
						if(ClientPrefs.chromaticAberration) stupidBool = true;
						FlxG.camera.flash(FlxColor.WHITE, 0.25);
						if(ClientPrefs.chromaticAberration) doneloll2 = true;
					case 384:
						if(ClientPrefs.chromaticAberration) stupidBool = false;
						FlxG.camera.flash(FlxColor.WHITE, 0.25);
						if(ClientPrefs.chromaticAberration) doneloll2 = false;
					case 640:
						if(ClientPrefs.chromaticAberration) stupidBool = false;
						FlxG.camera.flash(FlxColor.WHITE, 0.25);
						if(ClientPrefs.chromaticAberration) doneloll2 = false;
						camHUD.setFilters([]);
				}
				case 'splitathon':
					switch (curBeat)
					{
						case 1 | 92 | 107 | 124 | 144 | 336 | 720 | 1008 | 1200 | 1648 | 2032 | 2348:
							  camZoomSnap = true;
						case 80 | 95 | 112 | 128 | 209 | 592 | 848 | 1168 | 1520 | 1904 | 2290 | 2384:
							camZoomSnap = false;
					}
	    }

		if (!UsingNewCam)
		{
			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if (curBeat % 4 == 0)
				{
					// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
				}

				if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					isDadGlobal = true;
					moveCamera(true);
				}

				if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					isDadGlobal = false;
					moveCamera(false);
				}
			}
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, SONG.song.toLowerCase() == 'unfairness' || SONG.song.toLowerCase() == 'unfairness-remix' || ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (curBeat % 4 == 0 && SONG.song.toLowerCase() == "lacuna") // i swear i didnt watch gaming man's vid before doing this we had the same idea :sob
		{
			if(fartt) {
				FlxTween.tween(camHUD, {angle: 180}, 0.20, {ease: FlxEase.quadOut});
				FlxTween.tween(FlxG.camera, {angle: 2.5}, 0.20, {ease: FlxEase.quadOut});
				fartt = false;
				fartt2 = true;
			} else if (fartt2) {
				FlxTween.tween(camHUD, {angle: 0}, 0.20, {ease: FlxEase.quadOut});
				FlxTween.tween(FlxG.camera, {angle: -2.5}, 0.20, {ease: FlxEase.quadOut});
				fartt = true;
				fartt2 = false;
			}
		}

		if (curBeat % 2 == 0 && SONG.song.toLowerCase() == "5 minutes")
		{
			if(fartt) {
				FlxTween.tween(FlxG.camera, {angle: 2.5}, 0.20, {ease: FlxEase.quadOut});
				fartt = false;
				fartt2 = true;
			} else if (fartt2) {
				FlxTween.tween(FlxG.camera, {angle: -2.5}, 0.20, {ease: FlxEase.quadOut});
				fartt = true;
				fartt2 = false;
			}
		}
	
		if (curBeat % 4 == 0 && SONG.song.toLowerCase() == "acquaintance" && bALLS)
		{
			if(fartt) {
				FlxTween.tween(camHUD, {angle: 1.5}, 0.075, {ease: FlxEase.quadOut});
				fartt = false;
				fartt2 = true;
			} else if (fartt2) {
					FlxTween.tween(camHUD, {angle: -1.5}, 0.075, {ease: FlxEase.quadOut});
				fartt = true;
				fartt2 = false;
			}
		}

		if (camZooming && autoCamZoom && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && !camZoomSnap && !camZoomHalfSnap && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015 * camZoomingMult;
			camHUD.zoom += 0.03 * camZoomingMult;
		}

		if (camZoomSnap) {
			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms) {
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}
		}
	
		if (camZoomHalfSnap) {
			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 2 == 0) {
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}
		}
		var funny:Float = Math.max(Math.min(healthBar.value,1.9),0.1);

		if (ClientPrefs.iconBounce == 'Psych Engine') {
			iconP1.scale.set(1.2, 1.2);
			iconP2.scale.set(1.2, 1.2);

			iconP1.updateHitboxPE();
			iconP2.updateHitboxPE();
		} 

		if (ClientPrefs.iconBounce == 'Vanilla FNF' || ClientPrefs.iconBounce == 'Fixed Build') {
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (ClientPrefs.iconBounce == 'Dave Engine') {
			iconP1.setGraphicSize(Std.int(iconP1.width + (50 * (funny + 0.1))),Std.int(iconP1.height - (25 * funny)));
			iconP2.setGraphicSize(Std.int(iconP2.width + (50 * ((2 - funny) + 0.1))),Std.int(iconP2.height - (25 * ((2 - funny) + 0.1))));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (ClientPrefs.iconBounce == 'Custom Icon Bounce') {
			iconP1.scale.set(playerIconScale, playerIconScale);
			iconP2.scale.set(opponentIconScale, opponentIconScale);

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		var funny2:Float = (healthBar.percent * 0.01) + 0.01;

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		//health icon bounce but epic
		if (ClientPrefs.iconBounce == 'Golden Apple' || ClientPrefs.iconBounce == 'Fixed Build') {
			if (curBeat % gfSpeed == 0) {
				curBeat % (gfSpeed * 2) == 0 ? {
					iconP1.scale.set(1.1, 0.8);
					iconP2.scale.set(1.1, 1.3);

					FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 * gfSpeed / playbackRate, {ease: FlxEase.quadOut});
					FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 * gfSpeed / playbackRate, {ease: FlxEase.quadOut});
				} : {
					iconP1.scale.set(1.1, 1.3);
					iconP2.scale.set(1.1, 0.8);

					FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 * gfSpeed / playbackRate, {ease: FlxEase.quadOut});
					FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 * gfSpeed / playbackRate, {ease: FlxEase.quadOut});
				}

				FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed / playbackRate, {ease: FlxEase.quadOut});
				FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed / playbackRate, {ease: FlxEase.quadOut});

				iconP1.updateHitbox();
				iconP2.updateHitbox();
			}
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
			{
				boyfriend.dance2();
		    	if(UsingNewCam) bfSingYeah = false;
				//boyfriend.playAnim('idle', true);

				if(!boyfriend.hasMissAnimations) {
			    	if (hasBfDarkLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
			    		boyfriend.color = 0xFF878787;
			    	}
		     		if(hasBfSunsetLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
			    		boyfriend.color = 0xFFFF8F65;
			    	}
			    	if(hasBfDarkerLevels.contains(curStage) && !dontDarkenChar.contains(dad.curCharacter.toLowerCase()))
			    	{
				    	boyfriend.color = 0xFF383838;
			     	}
			    	else
		     		{
			    		boyfriend.color = FlxColor.WHITE;
			    	}
				}
			}
		if (boyfriend2 != null){
			if (curBeat % boyfriend2.danceEveryNumBeats == 0 && boyfriend2.animation.curAnim != null && !boyfriend2.animation.curAnim.name.startsWith('sing') && !boyfriend2.stunned)
				{
					boyfriend2.dance();
		    		if(UsingNewCam) bfSingYeah = false;
					//boyfriend.playAnim('idle', true);
				}
			}
		if(curBeat % 2 == 0)
		{
			if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
			{
				dad.dance();
				camFollowX = 0;
				camFollowY = 0;
				if(UsingNewCam) bfSingYeah = false;
			}
			if (badai != null)
			{
				if (badai.animation.curAnim.name != null && !badai.animation.curAnim.name.startsWith("sing") && !badai.stunned)
				{
					badai.dance();
				}
			}
			if (bandu != null)
			{
				if (bandu.animation.curAnim.name != null && !bandu.animation.curAnim.name.startsWith("sing") && !bandu.stunned)
				{
					bandu.dance();
				}
			}
			if (bamburg != null)
			{
				if (curBeat % bamburg.danceEveryNumBeats == 0 && bamburg.animation.curAnim.name != null && !bamburg.animation.curAnim.name.startsWith("sing") && !bamburg.stunned)
				{
					bamburg.dance();
				}
			}
			if (dave != null)
			{
				if (curBeat % dave.danceEveryNumBeats == 0 && dave.animation.curAnim.name != null && !dave.animation.curAnim.name.startsWith("sing") && !dave.stunned)
				{
					dave.dance();

					dave.playAnim('idle', true);
				}
			}
			if (bambi != null)
			{
				if (bambi.animation.curAnim.name != null && !bambi.animation.curAnim.name.startsWith("sing") && !bambi.stunned)
				{
					bambi.dance();
				}
			}
		}

		switch (curStage)
		{
			case 'tank':
				if(!ClientPrefs.lowQuality) tankWatchtower.dance();
				foregroundSprites.forEach(function(spr:BGSprite)
				{
					spr.dance();
				});

			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
					phillyWindow.color = phillyLightsColors[curLight];
					phillyWindow.alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = cast ret;
			}
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingNamePsych:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);
		
		if(!badHit)
			scoreZoom();

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				if (ClientPrefs.uiStyle == 'Psych Engine') {
					ratingNamePsych = '?';
				}
				else
				{
					ratingName = '?';
				}
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingNamePsych = ratingStuffPsych[ratingStuffPsych.length-1][0]; //Uses last string
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuffPsych.length-1)
					{
						if(ratingPercent < ratingStuffPsych[i][1])
						{
							ratingNamePsych = ratingStuffPsych[i][0];
							break;
						}
					}		
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "MFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			if (songMisses >= 10) ratingFC = "Clear";
			if (songMisses >= 100) ratingFC = "Clear - Skill issue";
	     	if (songMisses >= 500) ratingFC = "Skill Issue";
	    	else if (songMisses >= 1000) ratingFC = "vers good";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingNamePsych', ratingNamePsych);
		setOnLuas('ratingFC', ratingFC);
		if (ClientPrefs.judgementCounter == 'Advanced') {
			if (ClientPrefs.uiStyle == 'Kade Engine' || ClientPrefs.uiStyle == 'Purgatory') {
				judgementCounter.text = 'Total Notes: ${totalPlayed}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nCombo: ${combo}\nCombo Breaks: ${songMisses}';
			} else {
				judgementCounter.text = 'Total Notes: ${totalPlayed}\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nCombo: ${combo}\nMisses: ${songMisses}';
			}
		} else if (ClientPrefs.judgementCounter == 'Simple') {
			if (ClientPrefs.uiStyle == 'Kade Engine' || ClientPrefs.uiStyle == 'Purgatory') {
				judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nCombo Breaks: ${songMisses}';
			} else {
				judgementCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${songMisses}';
			}
		}
	}

	public function addSplitathonChar(char:String):Void
		{
			boyfriend.stunned = true; //hopefully this stun stuff should prevent BF from randomly missing a note
			remove(dad);
			dad = new Character(100, 100, char);
			add(dad);
			dad.color = 0xFF878787;
			switch (dad.curCharacter)
			{
				case 'dave-splitathon':
					{
						dad.y += 160;
						dad.x += 250;
					}
				case 'bambi-splitathon':
					{
						dad.x += 100;
						dad.y += 450;
					}
			}
			boyfriend.stunned = false;
		}
	
		public function splitterThonDave(expression:String):Void
		{
			boyfriend.stunned = true; //hopefully this stun stuff should prevent BF from randomly missing a note
			//stupid bullshit cuz i dont wanna bother with removing thing erighkjrehjgt
			thing.x = -9000;
			thing.y = -9000;
			if(daveExpressionSplitathon != null)
				remove(daveExpressionSplitathon);
			daveExpressionSplitathon = new Character(-200, 260, 'dave-splitathon');
			add(daveExpressionSplitathon);
			daveExpressionSplitathon.color = 0xFF878787;
			daveExpressionSplitathon.playAnim(expression, true);
			boyfriend.stunned = false;
		}

		var characterUnlockObj:CharacterUnlockObject = null;

		public function unlockCharacter(characterToUnlock:String, characterIcon:String, characterDisplayName:String = null, color:FlxColor = FlxColor.BLACK, botplayUnlocks:Bool = false)
			{
				if(!chartingMode || botplayUnlocks)
					{if(!FlxG.save.data.unlockedCharacters.contains(characterToUnlock))
						{
							if(characterDisplayName == null)
								characterDisplayName = characterToUnlock;
							characterUnlockObj = new CharacterUnlockObject(characterDisplayName, camOther, characterIcon, color);
							characterUnlockObj.onFinish = characterUnlockEnd;
							add(characterUnlockObj);
							FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
							FlxG.save.data.unlockedCharacters.push(characterToUnlock);
						}
					}
			}
		
		function characterUnlockEnd():Void
		{
			characterUnlockObj = null;
			if(endingSong && !inCutscene) {
				endSong();
			}
		}
	
		public function splitathonExpression(expression:String, x:Float, y:Float):Void
		{
			if (SONG.song.toLowerCase() == 'splitathon' || SONG.song.toLowerCase() == 'old-splitathon')
			{
				if(daveExpressionSplitathon != null)
				{
					remove(daveExpressionSplitathon);
				}
				if (expression != 'lookup')
				{
					camFollowPos.setPosition(dad.getGraphicMidpoint().x + 100, boyfriend.getGraphicMidpoint().y + 150);
				}
				boyfriend.stunned = true;
				thing.color = 0xFF878787;
				thing.x = x;
				thing.y = y;
				remove(dad);
	
				switch (expression)
				{
					case 'bambi-what':
						thing.frames = Paths.getSparrowAtlas('splitathon/Bambi_WaitWhatNow');
						thing.animation.addByPrefix('uhhhImConfusedWhatsHappening', 'what', 24);
						thing.animation.play('uhhhImConfusedWhatsHappening');
					case 'bambi-corn':
						thing.frames = Paths.getSparrowAtlas('splitathon/Bambi_ChillingWithTheCorn');
						thing.animation.addByPrefix('justGonnaChillHereEatinCorn', 'cool', 24);
						thing.animation.play('justGonnaChillHereEatinCorn');
				}
				if (!splitathonExpressionAdded)
				{
					splitathonExpressionAdded = true;
					add(thing);
				}
				thing.antialiasing = true;
				boyfriend.stunned = false;
			}
		}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'week6_nomiss' | 'week7_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 || CoolUtil.difficultyString() == 'HARD' && CoolUtil.difficultyString() == 'FINALE' && storyPlaylist.length <= 1 && !changedDifficulty && !practiceMode)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'week1':
									if(achievementName == 'week1_nomiss') unlock = true;
								case 'week2':
									if(achievementName == 'week2_nomiss') unlock = true;
								case 'week3':
									if(achievementName == 'week3_nomiss') unlock = true;
							/*	case 'week4':
									if(achievementName == 'week4_nomiss') unlock = true;*/ // dont ask for this u will see later heheheh hehh hh hhhh
							}
						}
						if(isPurStoryMode && campaignMisses + songMisses < 1 || CoolUtil.difficultyString() == 'HARD' && CoolUtil.difficultyString() == 'FINALE' && storyPlaylist.length <= 1 && !changedDifficulty && !practiceMode)
							{
								var weekName:String = PurWeekData.getWeekFileName();
								switch(weekName) // dsf9uvhfdsgfduibgui
								{
									case 'week4':
										if(achievementName == 'week4_nomiss') unlock = true;
									case 'week5':
										if(achievementName == 'week5_nomiss') unlock = true;
									case 'week6':
										if(achievementName == 'week6_nomiss') unlock = true;
									case 'week7':
										if(achievementName == 'week7_nomiss') unlock = true;
									case 'week8':
										if(achievementName == 'week8_nomiss') unlock = true;
									case 'week9':
										if(achievementName == 'week9_nomiss') unlock = true;
									case 'week10':
										if(achievementName == 'week10_nomiss') unlock = true;
								}
							}
					case 'whatthefuck_how':
						if(campaignMisses + songMisses < 1 && storyPlaylist.length <= 1)
						{
							switch (curSong.toLowerCase()) //troll face
							{
								case 'opposition':
									if(achievementName == 'whatthefuck_how') unlock = true;
							}
						}
					case 'cheater':
						if(campaignMisses + songMisses < 1 && storyPlaylist.length <= 1)
						{
							switch (curSong.toLowerCase()) 
							{
								case 'cheating':
									if(achievementName == 'cheater') unlock = true;
							}
						}
					case 'unfaircheat':
						if(campaignMisses + songMisses < 1 && storyPlaylist.length <= 1)
						{
							switch (curSong.toLowerCase())
							{
								case 'unfairness':
									if(achievementName == 'unfaircheat') unlock = true;
							}
						}
					case 'unfairremixcheat':
						if(campaignMisses + songMisses < 1 && storyPlaylist.length <= 1)
						{
							switch (curSong.toLowerCase())
							{
								case 'unfairness-remix':
									if(achievementName == 'unfairremixcheat') unlock = true;
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	function makeInvisibleNotes(invisible:Bool)
	{
		if (invisible)
		{
			for (strumNote in strumLineNotes)
			{
				FlxTween.cancelTweensOf(strumNote);
				FlxTween.tween(strumNote, {alpha: 0}, 1);
			}
		}
		else
		{
			for (strumNote in strumLineNotes)
			{
				FlxTween.cancelTweensOf(strumNote);
				FlxTween.tween(strumNote, {alpha: 1}, 1);
			}
		}
	}

	
	function healthTween(amt:Float)
	{
		healthTweenObj.cancel();
		healthTweenObj = FlxTween.num(health, health + amt, 0.1, {ease: FlxEase.cubeInOut}, function(v:Float)
		{
			health = v;
		});
	}

	function popupWindow()
		{
			var screenwidth = Application.current.window.display.bounds.width;
			var screenheight = Application.current.window.display.bounds.height;
	
			// center
			Application.current.window.x = Std.int((screenwidth / 2) - (1280 / 2));
			Application.current.window.y = Std.int((screenheight / 2) - (720 / 2));
			Application.current.window.width = 1280;
			Application.current.window.height = 720;
	
			window = Application.current.createWindow({
				title: "expunged.dat",
				width: 800,
				height: 800,
				borderless: true,
				alwaysOnTop: true
			});
	
			window.stage.color = 0x00010101;
			@:privateAccess
			window.stage.addEventListener("keyDown", FlxG.keys.onKeyDown);
			@:privateAccess
			window.stage.addEventListener("keyUp", FlxG.keys.onKeyUp);
			#if linux
			//testing stuff
			window.stage.color = 0xff000000;
			trace('BRAP');
			#end
			PlatformUtil.getWindowsTransparent();

			preDadPos = dad.getPosition();
			dad.x = 0;
			dad.y = 0;
	
			FlxG.mouse.useSystemCursor = true;
	
			generateWindowSprite();
	
			expungedScroll.scrollRect = new Rectangle();
			window.stage.addChild(expungedScroll);
			expungedScroll.addChild(expungedSpr);
			expungedScroll.scaleX = 0.5;
			expungedScroll.scaleY = 0.5;
	
			expungedOffset.x = Application.current.window.x;
			expungedOffset.y = Application.current.window.y;
	
			dad.visible = false;
	
			var windowX = Application.current.window.x + ((Application.current.window.display.bounds.width) * 0.140625);
	
			windowSteadyX = windowX;
	
			FlxTween.tween(expungedOffset, {x: -20}, 2 / playbackRate, {ease: FlxEase.elasticOut});
	
			FlxTween.tween(Application.current.window, {x: windowX}, 2.2 / playbackRate, {
				ease: FlxEase.elasticOut,
				onComplete: function(tween:FlxTween)
				{
					ExpungedWindowCenterPos.x = expungedOffset.x;
					ExpungedWindowCenterPos.y = expungedOffset.y;
					expungedMoving = false;
				}
			});
	
			Application.current.window.onClose.add(function()
			{
				if (window != null)
				{
					window.close();
				}
			}, false, 100);
	
			Application.current.window.focus();
			expungedWindowMode = true;
	
			@:privateAccess
			lastFrame = dad._frame;
		}
	
		function generateWindowSprite()
		{
			var m = new Matrix();
			m.translate(0, 100);
			expungedSpr.graphics.beginBitmapFill(dad.pixels, m);
			expungedSpr.graphics.drawRect(0, 0, dad.pixels.width, dad.pixels.height);
			expungedSpr.graphics.endFill();
		}

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}
