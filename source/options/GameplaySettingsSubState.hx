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

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Controller Mode',
			'Check this if you want to play with\na controller instead of using your Keyboard.',
			'controllerMode',
			'bool',
			false);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'If checked, notes go Down instead of Up, simple enough.', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Opponent Notes',
			'If unchecked, opponent notes get hidden.',
			'opponentStrums',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Disable Reset Button',
			"If checked, pressing Reset won't do anything.",
			'noReset',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Enable Chromatic Aberration',
			'Disable if this is causing a crash',
			'chromaticAberration',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Freeze Game',
			'If unchecked, the game will not freeze\nif clicked out of window.',
			'freezeGame',
			'bool',
			true);
		option.onChange = pauseGame;
		addOption(option);

		var option:Option = new Option('Freeplay Cutscenes',
			'If checked, enables Cutscenes on Freeplay',
			'freeplayCuts',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Enable Hitsounds',
			'Funny notes does \"Tick!\" when you hit them."',
			'hitsounds',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Select Hitsound:',
			"Select what Sound would you prefer sounding on a Note Hit",
			'hitsoundtype',
			'string',
			'vs-dave',
			['vs-dave', 'osu', 'andromeda-engine', 'vineboom']);
		addOption(option);

		var option:Option = new Option('Hitsound Volume',
			'Funny notes does \"Tick!\" when you hit them."',
			'hitsoundVolume',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Disable Miss Sounds',
			"If checked, miss sounds will be muted.",
			'noMissSounds',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Enable Custom Scroll Speed',
			"Leave unchecked for chart-dependent scroll speed",
			'scroll',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Set Custom Scroll Speed',
		    'Set the custom Scroll Speed (Custom Scroll Speed must be Enabled).',
		    'speed',
		    'float'
		    , 1);
		option.scrollSpeed = 1.5;
		option.minValue = 1;
		option.maxValue = 4;
		option.changeValue = 0.1;
		option.displayFormat = '%v';
		addOption(option);

		var option:Option = new Option('Enable Lane Underlay',
			"Enables a black underlay behind the notes\nfor better reading!\n(Similar to Funky Friday's Scroll Underlay or osu!mania's thing)",
			'laneunderlay',
			'bool',
			true);
		addOption(option);
		
		var option:Option = new Option('Lane Underlay Transparency',
			'Set the Lane Underlay Transparency (Lane Underlay must be enabled)',
			'laneTransparency',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Rating Offset',
			'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window',
			'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.',
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window',
			'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.',
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window',
			'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.',
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames',
			'Changes how many frames you have for\nhitting a note earlier or late.',
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	function pauseGame()
	{
		if(ClientPrefs.freezeGame)
		{
			FlxG.autoPause = true;
		} 
		else
		{
			FlxG.autoPause = false;
		}
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
}