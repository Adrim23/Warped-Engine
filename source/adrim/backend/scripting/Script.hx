package adrim.backend.scripting;

import lime.app.Application;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.io.Path;
import flixel.util.FlxStringUtil;
import flixel.FlxBasic;
import lime.utils.Assets;
import adrim.backend.scripting.HScriptCodename;
import flixel.ui.FlxBar;

@:allow(adrim.backend.scripting.ScriptPack)
/**
 * Class used for scripting.
 */
class Script extends FlxBasic implements IFlxDestroyable {
	/**
	 * Use "static var thing = true;" in hscript to use those!!
	 * are reset every mod switch so once you're done with them make sure to make them null!!
	 */
	public static var staticVariables:Map<String, Dynamic> = [];

	public static function getDefaultVariables(?script:Script):Map<String, Dynamic> {
		return [
			// Haxe related stuff
			"Std"			   => Std,
			"Math"			   => Math,
			"Reflect"		   => Reflect,
			"StringTools"	   => StringTools,
			"FileSystem"	   => FileSystem,
			"File"	           => File,
			"Type"	           => Type,
			"Json"			   => haxe.Json,
			"JsonParser"	   => haxeCustom.format.JsonParser,

			// OpenFL & Lime related stuff
			"Assets"			=> openfl.utils.Assets,
			"Application"	   => lime.app.Application,
			"Main"				=> Main,
			"window"			=> lime.app.Application.current.window,

			// Flixel related stuff
			"FlxG"			  => flixel.FlxG,
			"FlxSprite"		 => flixel.FlxSprite,
			"FlxBasic"		  => flixel.FlxBasic,
			"FlxCamera"		 => flixel.FlxCamera,
			"state"			 => flixel.FlxG.state,
			"FlxEase"		   => flixel.tweens.FlxEase,
			"FlxTween"		  => flixel.tweens.FlxTween,
			"FlxSound"		  => flixel.sound.FlxSound,
			"FlxAssets"		 => flixel.system.FlxAssets,
			"FlxMath"		   => flixel.math.FlxMath,
			"lerp"		   => FlxMath.lerp,
			"FlxGroup"		  => flixel.group.FlxGroup,
			"FlxTypedGroup"	 => flixel.group.FlxGroup.FlxTypedGroup,
			"FlxSpriteGroup"	=> flixel.group.FlxSpriteGroup,
			"FlxTypeText"	   => flixel.addons.text.FlxTypeText,
			"FlxText"		   => flixel.text.FlxText,
			"FlxTimer"		  => flixel.util.FlxTimer,
			"FlxBar"		  => flixel.ui.FlxBar,
			"FlxBarFillDirection" => {
				LEFT_TO_RIGHT: FlxBarFillDirection.LEFT_TO_RIGHT,
				RIGHT_TO_LEFT: FlxBarFillDirection.RIGHT_TO_LEFT,
				TOP_TO_BOTTOM: FlxBarFillDirection.TOP_TO_BOTTOM,
				BOTTOM_TO_TOP: FlxBarFillDirection.BOTTOM_TO_TOP,
				HORIZONTAL_INSIDE_OUT: FlxBarFillDirection.HORIZONTAL_INSIDE_OUT,
				HORIZONTAL_OUTSIDE_IN: FlxBarFillDirection.HORIZONTAL_OUTSIDE_IN,
				VERTICAL_INSIDE_OUT: FlxBarFillDirection.VERTICAL_INSIDE_OUT,
				VERTICAL_OUTSIDE_IN: FlxBarFillDirection.VERTICAL_OUTSIDE_IN,
			},
			"FlxPoint"		  => CoolUtil.getMacroAbstractClass("flixel.math.FlxPoint"),
			"FlxAxes"		   => CoolUtil.getMacroAbstractClass("flixel.util.FlxAxes"),
			"FlxColor"		  => CoolUtil.getMacroAbstractClass("flixel.util.FlxColor"),
			"FlxTrail"		  => adrim.flixel.addons.effects.FlxTrail,

			// Engine related stuff
			"ModState"		  => adrim.backend.scripting.ModState,
			"ModSubState"	   => adrim.backend.scripting.ModSubState,
			"PlayState"		 => states.PlayState,
			"game"		 => states.PlayState.instance,
			"GameOverSubstate"  => substates.GameOverSubstate,
			"HealthIcon"		=> objects.HealthIcon,
			"HudCamera"		 => adrim.objects.HudCamera,
			"Note"			  => objects.Note,
			"StrumNote"			 => objects.StrumNote,
			"Character"		 => objects.Character,
			"Boyfriend"		 => objects.Character, // for compatibility
			"PauseSubstate"	 => substates.PauseSubState,
			"FreeplayState"	 => states.FreeplayState,
			"MainMenuState"	 => states.MainMenuState,
			"PauseSubState"	 => substates.PauseSubState,
			"StoryMenuState"	=> states.StoryMenuState,
			"TitleState"		=> states.TitleState,
			"Options"		   => adrim.backend.options.Options,
			"Paths"			 => backend.Paths,
			"Conductor"		 => backend.Conductor,
			"FunkinShader"	  => adrim.shaders.FunkinShader,
			"CustomShader"	  => adrim.shaders.CustomShader,
			"FunkinText"		=> adrim.objects.FunkinText,
			"FlxAnimate"		=> flxanimate.PsychFlxAnimate,
			//"FunkinSprite"		=> adrim.objects.FunkinSprite,
			"Alphabet"		  => objects.Alphabet,

			"CoolUtil"		  => backend.CoolUtil,
			//"IniUtil"		   => funkin.backend.utils.IniUtil,
			"XMLUtil"		   => adrim.backend.XMLHelper,
			//#if sys "ZipUtil"   => funkin.backend.utils.ZipUtil, #end
			//"MarkdownUtil"	  => funkin.backend.utils.MarkdownUtil,
			//"EngineUtil"		=> funkin.backend.utils.EngineUtil,
			//"MemoryUtil"		=> funkin.backend.utils.MemoryUtil,
			//"BitmapUtil"		=> funkin.backend.utils.BitmapUtil, TBD
			"WindowUtils"		=> adrim.backend.utils.WindowUtils,
			"StageData"		=> backend.StageData
		];
	}
	public static function getDefaultPreprocessors():Map<String, Dynamic> {
		var dumbMap = new Map<String, Dynamic>();
		dumbMap.set("CODENAME_ENGINE", false);
		dumbMap.set("CODENAME_VER", Application.current.meta.get('version'));
		return dumbMap;
	}
	/**
	 * All available script extensions
	 */
	public static var scriptExtensions:Array<String> = [
		"hx", "hscript", "hsc", "hxs",
		"pack", // combined file
		"lua" /** ACTUALLY NOT SUPPORTED, ONLY FOR THE MESSAGE **/
	];

	/**
	 * Currently executing script.
	 */
	public static var curScript:Script = null;

	/**
	 * Script name (with extension)
	 */
	public var fileName:String;

	/**
	 * Script Extension
	 */
	public var extension:String;

	/**
	 * Path to the script.
	 */
	public var path:String = null;

	private var rawPath:String = null;

	private var didLoad:Bool = false;

	public var remappedNames:Map<String, String> = [];

	/**
	 * Creates a script from the specified asset path. The language is automatically determined.
	 * @param path Path in assets
	 */
	public static function create(path:String):Script {
		trace('CODENAME SCRIPT PATH: $path');
		if (FileSystem.exists(path)) {
			return switch(Path.extension(path).toLowerCase()) {
				case "hx" | "hscript" | "hsc" | "hxs":
					new HScriptCodename(path);
				case "pack":
					var arr = File.getContent(path).split("________PACKSEP________");
					fromString(arr[1], arr[0]);
				case "lua":
					Logs.trace("Lua is not supported in this engine. Use HScript instead.", ERROR);
					new DummyScript(path);
				default:
					new DummyScript(path);
			}
		}
		return new DummyScript(path);
	}

	/**
	 * Creates a script from the string. The language is determined based on the path.
	 * @param code code
	 * @param path filename
	 */
	public static function fromString(code:String, path:String):Script {
		return switch(Path.extension(path).toLowerCase()) {
			case "hx" | "hscript" | "hsc" | "hxs":
				new HScriptCodename(path).loadFromString(code);
			case "lua":
				Logs.trace("Lua is not supported in this engine. Use HScript instead.", ERROR);
				new DummyScript(path).loadFromString(code);
			default:
				new DummyScript(path).loadFromString(code);
		}
	}

	/**
	 * Creates a new instance of the script class.
	 * @param path
	 */
	public function new(path:String) {
		super();

		rawPath = path;
		path = Paths.getFilenameFromLibFile(path);

		fileName = Path.withoutDirectory(path);
		extension = Path.extension(path);
		this.path = path;
		onCreate(path);
		for(k=>e in getDefaultVariables(this)) {
			set(k, e);
		}
		set("disableScript", () -> {
			active = false;
		});
		set("__script__", this);
	}


	/**
	 * Loads the script
	 */
	public function load() {
		if(didLoad) return;

		var oldScript = curScript;
		curScript = this;
		onLoad();
		curScript = oldScript;

		didLoad = true;
	}

	/**
	 * HSCRIPT ONLY FOR NOW
	 * Sets the "public" variables map for ScriptPack
	 */
	public function setPublicMap(map:Map<String, Dynamic>) {

	}

	/**
	 * Hot-reloads the script, if possible
	 */
	public function reload() {

	}

	/**
	 * Traces something as this script.
	 */
	public function trace(v:Dynamic) {
		var fileName = this.fileName;
		if(remappedNames.exists(fileName))
			fileName = remappedNames.get(fileName);
		Logs.traceColored([
			Logs.logText('${fileName}: ', GREEN),
			Logs.logText(Std.string(v))
		], TRACE);
	}


	/**
	 * Calls the function `func` defined in the script.
	 * @param func Name of the function
	 * @param parameters (Optional) Parameters of the function.
	 * @return Result (if void, then null)
	 */
	public function call(func:String, ?parameters:Array<Dynamic>):Dynamic {
		var oldScript = curScript;
		curScript = this;

		var result = onCall(func, parameters == null ? [] : parameters);

		curScript = oldScript;
		return result;
	}

	/**
	 * Loads the code from a string, doesnt really work after the script has been loaded
	 * @param code The code.
	 */
	public function loadFromString(code:String) {
		return this;
	}

	/**
	 * Sets a script's parent object so that its properties can be accessed easily. Ex: Passing `PlayState.instance` will allow `boyfriend` to be typed instead of `PlayState.instance.boyfriend`.
	 * @param variable Parent variable.
	 */
	public function setParent(variable:Dynamic) {}

	/**
	 * Gets the variable `variable` from the script's variables.
	 * @param variable Name of the variable.
	 * @return Variable (or null if it doesn't exists)
	 */
	public function get(variable:String):Dynamic {return null;}

	/**
	 * Gets the variable `variable` from the script's variables.
	 * @param variable Name of the variable.
	 * @return Variable (or null if it doesn't exists)
	 */
	public function set(variable:String, value:Dynamic):Void {}

	/**
	 * Shows an error from this script.
	 * @param text Text of the error (ex: Null Object Reference).
	 * @param additionalInfo Additional information you could provide.
	 */
	public function error(text:String, ?additionalInfo:Dynamic):Void {
		var fileName = this.fileName;
		if(remappedNames.exists(fileName))
			fileName = remappedNames.get(fileName);
		Logs.traceColored([
			Logs.logText(fileName, RED),
			Logs.logText(text)
		], ERROR);
	}

	override public function toString():String {
		return FlxStringUtil.getDebugString(didLoad ? [
			LabelValuePair.weak("path", path),
			LabelValuePair.weak("active", active),
		] : [
			LabelValuePair.weak("path", path),
			LabelValuePair.weak("active", active),
			LabelValuePair.weak("loaded", didLoad),
		]);
	}

	/**
	 * PRIVATE HANDLERS - DO NOT TOUCH
	 */
	private function onCall(func:String, parameters:Array<Dynamic>):Dynamic {
		return null;
	}
	public function onCreate(path:String) {}

	public function onLoad() {}
}