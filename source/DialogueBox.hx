package;

import flixel.math.FlxPoint;
#if windows
import openfl.display.Shader;
#end
import flixel.tweens.FlxTween;
import haxe.Log;
import flixel.input.gamepad.lists.FlxBaseGamepadList;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var blackScreen:FlxSprite;

	var curCharacter:String = '';
	var curMod:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var noAa:Array<String> = ["dialogue/altbox/dave_furiosity", "dialogue/altbox/3d_bamb", "dialogue/altbox/unfairnessPortrait"];

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var bfPortraitSizeMultiplier:Float = 1.5;
	var textBoxSizeFix:Float = 7;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var debug:Bool = false;

	#if windows
	var curshader:Dynamic;
	#end

	public static var randomNumber:Int;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'insanity' | 'splitathon':
				FlxG.sound.playMusic(Paths.music('a-new-day'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'furiosity' | 'polygonized' | 'cheating' | 'unfairness':
				FlxG.sound.playMusic(Paths.music('im-angey'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'supernovae' | 'glitch':
				randomNumber = FlxG.random.int(0, 50);
				if(randomNumber == 50)
				{
					FlxG.sound.playMusic(Paths.music('secret'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
				}
				else
				{
					FlxG.sound.playMusic(Paths.music('dooDooFeces'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
				}
			case 'blocked' | 'corn-theft':
				randomNumber = FlxG.random.int(0, 50);
				if(randomNumber == 50)
				{
					FlxG.sound.playMusic(Paths.music('secret'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
				}
				else
				{
					FlxG.sound.playMusic(Paths.music('DaveDialogue'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
				}
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);

		blackScreen = new FlxSprite(0, 0).makeGraphic(5000, 5000, FlxColor.BLACK);
		blackScreen.screenCenter();
		blackScreen.alpha = 0;
		add(blackScreen);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear instance 1', [4], "", 24);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH instance 1', [4], "", 24);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn instance 1', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
			case 'house' | 'insanity' | 'furiosity' | 'polygonized' | 'supernovae' | 'cheating' | 'unfairness' | 'glitch' | 'blocked' | 'corn-theft' | 'maze' | 'splitathon':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('dialogue/altbox/alt_bubble');
				box.setGraphicSize(Std.int(box.width / textBoxSizeFix));
				box.updateHitbox();
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
				box.antialiasing = true;
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		var portraitLeftCharacter:String = '';
		var portraitRightCharacter:String = 'bf';

		portraitLeft = new FlxSprite();
		portraitRight = new FlxSprite();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai' | 'roses' | 'thorns':
				portraitLeftCharacter = 'senpai';
				portraitRightCharacter = 'bfPixel';
				
			case 'house' | 'insanity' | 'furiosity' | 'polygonized':
				portraitLeftCharacter = 'dave';
				
			case 'blocked' | 'corn-theft' | 'maze' | 'supernovae' | 'glitch' | 'splitathon' | 'cheating' | 'unfairness':
				portraitLeftCharacter = 'bambi';
		}

		var leftPortrait:Portrait = getPortrait(portraitLeftCharacter);

		portraitLeft.frames = Paths.getSparrowAtlas(leftPortrait.portraitPath);
		portraitLeft.animation.addByPrefix('enter', leftPortrait.portraitPrefix, 24, false);
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();

		var rightPortrait:Portrait = getPortrait(portraitRightCharacter);
		
		portraitRight.frames = Paths.getSparrowAtlas(rightPortrait.portraitPath);
		portraitRight.animation.addByPrefix('enter', rightPortrait.portraitPrefix, 24, false);
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		
		portraitRight.visible = false;
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai' | 'roses' | 'thorns':
				handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
				handSelect.setGraphicSize(Std.int(handSelect.width * 6));
				handSelect.updateHitbox();
				add(handSelect);
			case 'furiosity' | 'polygonized' | 'cheating' | 'unfairness':
				dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
				dropText.font = 'Comic Sans MS Bold';
				dropText.color = 0xFFFFFFFF;
				add(dropText);
			
				swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
				swagDialogue.font = 'Comic Sans MS Bold';
				swagDialogue.color = 0xFF000000;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue'), 0.6)];
				add(swagDialogue);
			default:
				dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
				dropText.font = 'Comic Sans MS Bold';
				dropText.color = 0xFF00137F;
				add(dropText);
		
				swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
				swagDialogue.font = 'Comic Sans MS Bold';
				swagDialogue.color = 0xFF000000;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue'), 0.6)];
				add(swagDialogue);
		}
		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);

		handSelect = new FlxSprite(1042, 590).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
		handSelect.setGraphicSize(Std.int(handSelect.width * PlayState.daPixelZoom * 0.9));
		handSelect.updateHitbox();
		handSelect.visible = false;
		add(handSelect);


		if (!talkingRight)
		{
			// box.flipX = true;
		}
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.visible = false;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if(PlayerSettings.player1.controls.ACCEPT)
		{
			if (dialogueEnded)
			{
				remove(dialogue);
				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;
						FlxG.sound.play(Paths.sound('clickText'), 0.8);	

						if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
							FlxG.sound.music.fadeOut(1.5, 0);

						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							box.alpha -= 1 / 5;
							bgFade.alpha -= 1 / 5 * 0.7;
							portraitLeft.visible = false;
							portraitRight.visible = false;
							swagDialogue.alpha -= 1 / 5;
							handSelect.alpha -= 1 / 5;
							dropText.alpha = swagDialogue.alpha;
						}, 5);

						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							finishThing();
							kill();
						});
					}
				}
				else
				{
					dialogueList.remove(dialogueList[0]);
					startDialogue();
					FlxG.sound.play(Paths.sound('clickText'), 0.8);
				}
			}
			else if (dialogueStarted)
			{
				FlxG.sound.play(Paths.sound('clickText'), 0.8);
				swagDialogue.skip();
				
				if(skipDialogueThing != null) {
					skipDialogueThing();
				}
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);
		#if windows
		curshader = null;
		#end
		if (curCharacter != 'generic')
		{
			var portrait:Portrait = getPortrait(curCharacter);
			if (portrait.left)
			{
				portraitLeft.frames = Paths.getSparrowAtlas(portrait.portraitPath);
				portraitLeft.animation.addByPrefix('enter', portrait.portraitPrefix, 24, false);
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
				}
			}
			else
			{
				portraitRight.frames = Paths.getSparrowAtlas(portrait.portraitPath);
				portraitRight.animation.addByPrefix('enter', portrait.portraitPrefix, 24, false);
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
				}
			}
			switch (curCharacter)
			{
				case 'dave' | 'bambi' | 'tristan' | 'insanityEndDave': //guys its the funny bambi character
						portraitLeft.setPosition(220, 220);
				case 'bf' | 'gf': //create boyfriend & genderbent boyfriend
					portraitRight.setPosition(570, 220);
			}
			box.flipX = portraitLeft.visible;
			portraitLeft.x -= 150;
			//portraitRight.x += 100;
			portraitLeft.antialiasing = !noAa.contains(portrait.portraitPath);
			portraitRight.antialiasing = true;
			portraitLeft.animation.play('enter',true);
			portraitRight.animation.play('enter',true);
		}
		else
		{
			portraitLeft.visible = false;
			portraitRight.visible = false;
		}
		switch (curMod)
		{
			case 'setfont_normal':
				dropText.font = 'Comic Sans MS Bold';
				swagDialogue.font = 'Comic Sans MS Bold';
			case 'setfont_code':
				dropText.font = Paths.font("barcode.ttf");
				swagDialogue.font = Paths.font("barcode.ttf");
			case 'to_black':
				FlxTween.tween(blackScreen, {alpha:1}, 0.25);
		}
	}
	function getPortrait(character:String):Portrait
	{
		var portrait:Portrait = new Portrait('', '', '', true);
		switch (character)
		{
			case 'dave':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'house':
						portrait.portraitPath = 'dialogue/altbox/dave_house';
						portrait.portraitPrefix = 'dave house portrait';

					case 'insanity':
						portrait.portraitPath = 'dialogue/altbox/dave_insanity';
						portrait.portraitPrefix = 'dave insanity portrait';

					case 'pre-furiosity':
						portrait.portraitPath = 'dialogue/altbox/dave_pre-furiosity';
						portrait.portraitPrefix = 'dave pre-furiosity portrait';

					case 'furiosity' | 'polygonized':
						portrait.portraitPath = 'dialogue/altbox/dave_furiosity';
						portrait.portraitPrefix = 'dave furiosity portrait';

					case 'blocked' | 'corn-theft' | 'maze':
						portrait.portraitPath = 'dialogue/altbox/dave_bambiweek';
						portrait.portraitPrefix = 'dave bambi week portrait';
					case 'splitathon':
						portrait.portraitPath = 'dialogue/altbox/dave_splitathon';
						portrait.portraitPrefix = 'dave splitathon portrait';
				}
			case 'insanityEndDave':
				portrait.portraitPath = 'dialouge/dave_pre-furiosity';
				portrait.portraitPrefix = 'dave pre-furiosity portrait';
			case 'bambi':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'blocked':
						portrait.portraitPath = 'dialogue/altbox/bambi_blocked';
						portrait.portraitPrefix = 'bambi blocked portrait';
					case 'old-corn-theft' | 'old-maze':
						portrait.portraitPath = 'dialogue/altbox/oldFarmBambiPortrait';
						portrait.portraitPrefix = 'bambienter';
					case 'corn-theft':
						portrait.portraitPath = 'dialogue/altbox/bambi_corntheft';
						portrait.portraitPrefix = 'bambi corntheft portrait';
					case 'maze':
						portrait.portraitPath = 'dialogue/altbox/bambi_maze';
						portrait.portraitPrefix = 'bambi maze portrait';
					case 'supernovae' | 'glitch':
						portrait.portraitPath = 'dialogue/altbox/bambi_bevel';
						portrait.portraitPrefix = 'bambienter';
					case 'splitathon':
						portrait.portraitPath = 'dialogue/altbox/bambi_splitathon';
						portrait.portraitPrefix = 'bambi splitathon portrait';
					case 'cheating':
						portrait.portraitPath = 'dialogue/altbox/3d_bamb';
						portrait.portraitPrefix = 'bambi 3d portrait';
					case 'unfairness':
						portrait.portraitPath = 'dialogue/altbox/unfairnessPortrait';
						portrait.portraitPrefix = 'bambi unfairness portrait';
				}
			case 'senpai':
				portrait.portraitPath = 'weeb/senpaiPortrait';
				portrait.portraitPrefix = 'Senpai Portrait Enter';
				portrait.portraitLibraryPath = 'week6';
			case 'bfPixel':
				portrait.portraitPath = 'weeb/bfPortrait';
				portrait.portraitPrefix = 'Boyfriend portrait enter';
				portrait.portraitLibraryPath = 'week6';
				portrait.left = false;
			case 'bf':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'blocked' | 'maze':
						portrait.portraitPath = 'dialogue/altbox/bf_blocked_maze';
						portrait.portraitPrefix = 'bf blocked & maze portrait';
					case 'furiosity' | 'polygonized' | 'corn-theft' | 'cheating' | 'unfairness' | 'supernovae' | 'glitch':
						portrait.portraitPath = 'dialogue/altbox/bf_furiosity';
						portrait.portraitPrefix = 'bf furiosity & corntheft portrait';
					case 'house':
						portrait.portraitPath = 'dialogue/altbox/bf_house';
						portrait.portraitPrefix = 'bf house portrait';
					case 'insanity' | 'splitathon':
						portrait.portraitPath = 'dialogue/altbox/bf_insanity_splitathon';
						portrait.portraitPrefix = 'bf insanity & splitathon portrait';
				}
				portrait.left = false;
			case 'gf':
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'blocked':
						portrait.portraitPath = 'dialogue/altbox/gf_blocked';
						portrait.portraitPrefix = 'gf blocked portrait';
					case 'corn-theft' | 'cheating' | 'unfairness':
						portrait.portraitPath = 'dialogue/altbox/gf_corntheft';
						portrait.portraitPrefix = 'gf corntheft portrait';
					case 'maze':
						portrait.portraitPath = 'dialogue/altbox/gf_maze';
						portrait.portraitPrefix = 'gf maze portrait';
					case 'splitathon':
						portrait.portraitPath = 'dialogue/altbox/gf_splitathon';
						portrait.portraitPrefix = 'gf splitathon portrait';
				}
				portrait.left = false;
			case 'tristan':
				portrait.portraitPath = 'dialogue/altbox/tristanPortrait';
				portrait.portraitPrefix = 'tristan portrait';
		}
		return portrait;
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
class Portrait
{
	public var portraitPath:String;
	public var portraitLibraryPath:String = '';
	public var portraitPrefix:String;
	public var left:Bool;
	public function new (portraitPath:String, portraitLibraryPath:String = '', portraitPrefix:String, left:Bool)
	{
		this.portraitPath = portraitPath;
		this.portraitLibraryPath = portraitLibraryPath;
		this.portraitPrefix = portraitPrefix;
		this.left = left;
	}
}
