package;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;
import flixel.math.FlxMath;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	public var hasWinning:Bool = false;
	private var char:String = '';
	public var id:Int;

	public var defualtIconScale:Float = 1;
	public var iconScale:Float = 1;
	public var iconSize:Float;

	private var tween:FlxTween;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?_id:Int = -1)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();

		animation.play(char);
		scrollFactor.set();

		tween = FlxTween.tween(this, {}, 0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ClientPrefs.iconBounce == 'Dave Engine') {
			offset.set(Std.int(FlxMath.bound(width - 150, 0)), Std.int(FlxMath.bound(height - 150, 0)));
		}

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			loadGraphic(file); //Load stupidly first for getting the file size
			if (file.width == 450) {
				loadGraphic(file, true, Math.floor(width / 3), Math.floor(height));
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				iconOffsets[2] = (width - 150) / 2;
				updateHitbox();
				animation.add(char, [0, 1, 2], 0, false, isPlayer);
				animation.play(char);
				this.char = char;
				hasWinning = true;
			} else {
				loadGraphic(file, true, Math.floor(width / 2), Math.floor(height));
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				updateHitbox();
				animation.add(char, [0, 1], 0, false, isPlayer);
				animation.play(char);
				this.char = char;
				hasWinning = false;
			}

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel') || char == 'bambi-3d' || char == 'dave-3d' || char == 'bambi-unfair' || char == 'decimated' || char == 'bambi-god' || char == 'gary' || char == 'expunged' || char == 'bombu' || char == 'bamburg' || char == 'bamburg-player' || char == 'bambi-piss-3d') {
				antialiasing = false;
			}
		}
	}

	public function updateHitboxPE()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}

	public function tweenToDefaultScale(_time:Float, _ease:Null<flixel.tweens.EaseFunction>){

		if (ClientPrefs.iconBounce == 'Fixed Build') {
			tween.cancel();
			tween = FlxTween.tween(this, {iconScale: this.defualtIconScale}, _time, {ease: _ease});
		}
	}
}
