package debug;

import flixel.FlxG;
import flixel.FlxBasic;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;
	public var framerateText:TextField;
	public var fpsText:TextField;
	public var daOtherShit:TextField;
	public var renderedObjects:Int;

	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(Paths.font('Roobert.otf'), 0, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		times = [];

		framerateText = new TextField();
		framerateText.x = x; framerateText.y = y;
		framerateText.selectable = false; framerateText.mouseEnabled = false;
		framerateText.autoSize = LEFT; framerateText.multiline = true;
		framerateText.defaultTextFormat = new TextFormat(Paths.font('Roobert.otf'), 20, color);
		framerateText.text = '120';
		
		fpsText = new TextField();
		fpsText.x = x;
		fpsText.selectable = false; fpsText.mouseEnabled = false;
		fpsText.autoSize = LEFT; fpsText.multiline = true;
		fpsText.defaultTextFormat = new TextFormat(Paths.font('Roobert.otf'), 14, color);
		fpsText.text = 'FPS';
		fpsText.y = y+(framerateText.height-fpsText.height-4);
		
		daOtherShit = new TextField();
		daOtherShit.x = x;
		daOtherShit.selectable = false; daOtherShit.mouseEnabled = false;
		daOtherShit.autoSize = LEFT; daOtherShit.multiline = true;
		daOtherShit.defaultTextFormat = new TextFormat(Paths.font('Roobert.otf'), 14, color);
		daOtherShit.text = 'RAM';
		daOtherShit.y = y+daOtherShit.height;
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000) times.shift();
		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < 10) {
			deltaTimeout += deltaTime;
			return;
		}

		fpsText.x = x+framerateText.width;
		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
		updateText();
		deltaTimeout = 0.0;
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		framerateText.text = Std.string(currentFPS);
		daOtherShit.text = 'Memory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';

		textColor = 0xFFD595FF;
		if (currentFPS < FlxG.drawFramerate * 0.5)
			textColor = 0xFFFFCD83;

		framerateText.textColor = this.textColor;
		fpsText.textColor = this.textColor;
		daOtherShit.textColor = this.textColor;

		framerateText.alpha = this.alpha;
		fpsText.alpha = this.alpha;
		daOtherShit.alpha = this.alpha;

		framerateText.visible = this.visible;
		fpsText.visible = this.visible;
		daOtherShit.visible = this.visible;
	}

	inline function get_memoryMegas():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
}
