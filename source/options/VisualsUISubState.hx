package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Judgement Counter:',
			"Shows a judgement counter at the left of the screen (Example: Sicks: 93,\nGoods:0, Bads: 1, 'Shits: 0)",
			'judgementCounter',
			'string',
			'Disabled',
			['Disabled', 'Simple', 'Advanced']);
		addOption(option);

		var option:Option = new Option('UI Style:',
			"Changes which UI style is shown\nduring gameplay.",
			'uiStyle',
			'string',
			'Purgatory',
			['Purgatory', 'Kade Engine', 'Psych Engine', 'Dave Engine']);
		addOption(option);

		var option:Option = new Option('Icon Bounce:',
			"Changes what icon bounce it plays in-game.",
			'iconBounce',
			'string',
			'Fixed Build',
			['Fixed Build', 'Golden Apple', 'Psych Engine', 'Dave Engine', 'Vanilla FNF']);
		addOption(option);

		 var option:Option = new Option('Ratings and Combo in the Hud',
			'Enable this to have the Ratings, Combo and MS in the Hud.',
			'ratinginHud',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Eyesores, Flashing Lights\nAnd Shaking',
			"Uncheck this if you're sensitive to flashing lights\nand Fast flashing colors!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Enable Waving Backgrounds',
			"If Checked, Enables Waving backgrounds in stages with them",
			'waving',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Note Movement',
			'If checked it will enable a Camera Movement according to the Note Hit.',
			'followarrow',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Longer Health Bar',
			"Makes the Health bar longer visually\n(This doesn't give you more health!)",
			'longAssBar',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			'Song and Time Left',
			['Song and Time Left', 'Song and Time Elapsed', 'Song Name']);
		addOption(option);

		var option:Option = new Option('Hide Time Bar',
			"If Checked, Hides the Time Bar",
			'hideTime',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Character Colored Bars',
			'Enable this to make the\nTime and Health Bars Colored\nby the Character json Color',
			'colorBars',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Hide Ratings',
			'If checked, hides the ratings, MS, and\nnumbers in the Hud.',
			'hideRatings',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		
		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			'bool',
			true);
		addOption(option);

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}