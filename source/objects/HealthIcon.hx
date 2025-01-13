package objects;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'face', isPlayer:Bool = false, ?allowGPU:Bool = true, ?isCustom:Bool=false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU, isCustom);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true, ?isCum:Bool=false) {
		if(this.char != char) {
			if (!isCum)
			{
				var name:String = 'icons/' + char;
				if(!FileSystem.exists(Paths.modFolders('images/' + name + '.png'))) name = 'icons/icon-' + char; //Older versions of psych engine's support
				if(!FileSystem.exists(Paths.modFolders('images/' + name + '.png'))) name = 'icons/icon-face'; //Prevents crash from missing icon
				
				var graphic = Paths.image(name, allowGPU);
				var iSize:Float = Math.round(graphic.width / graphic.height);
				loadGraphic(graphic, true, Math.floor(graphic.width / iSize), Math.floor(graphic.height));
				iconOffsets[0] = (width - 150) / iSize;
				iconOffsets[1] = (height - 150) / iSize;
				updateHitbox();
	
				animation.add(char, [for(i in 0...frames.frames.length) i], 0, false, isPlayer);
				animation.play(char);
				this.char = char;
	
				if(char.endsWith('-pixel'))
					antialiasing = false;
				else
					antialiasing = ClientPrefs.data.antialiasing;
			}
			else
			{
				var name:String = 'healthicon';
				var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile('custom/characters/$char/' + name + '.png'));
				var iSize:Float = Math.round(graphic.width / graphic.height);
				loadGraphic(graphic, true, Math.floor(graphic.width / iSize), Math.floor(graphic.height));
				iconOffsets[0] = (width - 150) / iSize;
				iconOffsets[1] = (height - 150) / iSize;
				updateHitbox();
	
				animation.add(char, [for(i in 0...frames.frames.length) i], 0, false, isPlayer);
				animation.play(char);
				this.char = char;
	
				if(char.endsWith('-pixel'))
					antialiasing = false;
				else
					antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	public function setIcon(char:String, ?allowGPU:Bool = true){changeIcon(char, allowGPU);}

	public var autoAdjustOffset:Bool = true;
	override function updateHitbox()
	{
		super.updateHitbox();
		if(autoAdjustOffset)
		{
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		}
	}

	public function getCharacter():String {
		return char;
	}
}
