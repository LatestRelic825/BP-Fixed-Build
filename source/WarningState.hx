package;
import flixel.*;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

/**
 * ...
 * sorry bbpanzu
 */
class WarningState extends MusicBeatState
{

	public function new() 
	{
		super();
	}
	override function create() 
	{
		super.create();
		
		var bg:FlxSprite = new FlxSprite();
		
		bg.loadGraphic(Paths.image("dave/warning", "preload"));
		add(bg);
		
		#if mobileC
		addVirtualPad(NONE, A_B);
		#end
			
	}
	
	
	override function update(elapsed:Float) 
	{
		super.update(elapsed);
		
		
		if (controls.ACCEPT){
			FlxG.sound.play(Paths.sound('scrollMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleState());
		}
	}
}
