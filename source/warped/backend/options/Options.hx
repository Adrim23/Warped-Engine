package warped.backend.options;

import openfl.Lib;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;

class Options
{
	@:dox(hide) @:doNotSave
	public static var __save:FlxSave;
	@:dox(hide) @:doNotSave
	private static var __eventAdded = false;

	/**
	 * SETTINGS
	 */
	public static var naughtyness:Bool = true;
	public static var downscroll:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var flashingMenu:Bool = true;
	public static var camZoomOnBeat:Bool = true;
	public static var fpsCounter:Bool = true;
	public static var autoPause:Bool = true;
	public static var antialiasing:Bool = true;
	public static var volume:Float = 1;
	public static var week6PixelPerfect:Bool = true;
	public static var gameplayShaders:Bool = true;
	public static var colorHealthBar:Bool = true;
	public static var lowMemoryMode:Bool = false;
	public static var betaUpdates:Bool = false;
	public static var splashesEnabled:Bool = true;
	public static var hitWindow:Float = 250;
	public static var songOffset:Float = 0;
	public static var framerate:Int = 120;
	public static var gpuOnlyBitmaps:Bool = #if (mac || web) false #else true #end; // causes issues on mac and web

	public static var lastLoadedMod:String = null;

	/**
	 * EDITORS SETTINGS
	 */
	public static var intensiveBlur:Bool = true;
	public static var editorSFX:Bool = true;
	public static var editorPrettyPrint:Bool = false;
	public static var maxUndos:Int = 120;

	/**
	 * QOL FEATURES
	 */
	public static var freeplayLastSong:String = null;
	public static var freeplayLastDifficulty:String = "normal";
	public static var mainDevs:Array<Int> = [];  // IDs
	public static var lastUpdated:Null<Float>;

	/**
	 * CHARTER
	 */
	public static var charterMetronomeEnabled:Bool = false;
	public static var charterShowSections:Bool = true;
	public static var charterShowBeats:Bool = true;
	public static var charterEnablePlaytestScripts:Bool = true;
	public static var charterLowDetailWaveforms:Bool = false;
	public static var charterAutoSaves:Bool = true;
	public static var charterAutoSaveTime:Float = 60*5;
	public static var charterAutoSaveWarningTime:Float = 5;
	public static var charterAutoSavesSeperateFolder:Bool = false;

	public static function load() {
        var psychData = ClientPrefs.data;
        downscroll = psychData.cnDownScroll;
        ghostTapping = psychData.ghostTapping;
        fpsCounter = psychData.showFPS;
        autoPause = psychData.autoPause;
        antialiasing = psychData.antialiasing;
        gameplayShaders = psychData.shaders;
        lowMemoryMode = psychData.lowQuality;
        framerate = psychData.framerate;
        gpuOnlyBitmaps = psychData.cacheOnGPU;
	}
}