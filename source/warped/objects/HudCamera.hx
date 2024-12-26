package warped.objects;

import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.FlxObject;

class HudCamera extends FlxCamera {
	public var downscroll:Bool = false;
	//public override function update(elapsed:Float) {
	//	super.update(elapsed);
	//	// flipY = downscroll;
	//}


	// public override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false,
	// 	?shader:FlxShader):Void
	// {
	// 	if (downscroll) {
	// 		matrix.scale(1, -1);
	// 		matrix.translate(0, height);
	// 	}
	// 	super.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
	// }


	public override function alterScreenPosition(spr:FlxObject, pos:FlxPoint) {
		if (downscroll) {
			pos.set(pos.x+spr.camOffsetX, height - pos.y+spr.camOffsetY - spr.height);
		}
		return pos;
	}
}