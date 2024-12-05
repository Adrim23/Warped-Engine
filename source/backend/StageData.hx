package backend;

import openfl.utils.Assets;
import haxe.Json;
import backend.Song;
import psychlua.ModchartSprite;

import haxe.Exception;
import haxe.io.Path;
import haxe.xml.Access;

import adrim.backend.XMLHelper;

typedef StageFile = {
	var directory:String;
	var defaultZoom:Float;
	@:optional var isPixelStage:Null<Bool>;
	var stageUI:String;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
	var hide_girlfriend:Bool;

	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;

	@:optional var preload:Dynamic;
	@:optional var objects:Array<Dynamic>;
	@:optional var _editorMeta:Dynamic;

	@:optional var folder:String; // incase it's a xml stage and wants to load stuff in
}

enum abstract LoadFilters(Int) from Int from UInt to Int to UInt
{
	var LOW_QUALITY:Int = (1 << 0);
	var HIGH_QUALITY:Int = (1 << 1);

	var STORY_MODE:Int = (1 << 2);
	var FREEPLAY:Int = (1 << 3);
}

class StageData {
	public static function dummy():StageFile
	{
		return {
			directory: "",
			defaultZoom: 0.9,
			stageUI: "normal",

			boyfriend: [770, 100],
			girlfriend: [400, 130],
			opponent: [100, 100],
			hide_girlfriend: false,

			camera_boyfriend: [0, 0],
			camera_opponent: [0, 0],
			camera_girlfriend: [0, 0],
			camera_speed: 1,

			_editorMeta: {
				gf: "gf",
				dad: "dad",
				boyfriend: "bf"
			}
		};
	}

	public static var forceNextDirectory:String = null;
	public static function loadDirectory(SONG:SwagSong) {
		var stage:String = '';
		if(SONG.stage != null)
			stage = SONG.stage;
		else if(Song.loadedSongName != null)
			stage = vanillaSongStage(Paths.formatToSongPath(Song.loadedSongName));
		else
			stage = 'stage';

		var stageFile:StageFile = getStageFile(stage);
		forceNextDirectory = (stageFile != null) ? stageFile.directory : ''; //preventing crashes
	}

	public static function getStageFile(stage:String):StageFile {
		spriteNum = 0;
		stageXML = null;
		stageSprites.clear();
		try
		{
			var path:String = Paths.getPath('stages/' + stage + '.json', TEXT, null, true);
			#if MODS_ALLOWED
			if(FileSystem.exists(path))
				return cast tjson.TJSON.parse(File.getContent(path));
			#else
			if(Assets.exists(path))
				return cast tjson.TJSON.parse(Assets.getText(path));
			#end

			trace('getting xml...');
			return loadStageXML(stage);
		}
		catch(e:Dynamic)
			trace('failed getting stage... ${e.message}');
		return dummy();
	}

	public static function vanillaSongStage(songName):String
	{
		switch (songName)
		{
			case 'spookeez' | 'south' | 'monster':
				return 'spooky';
			case 'pico' | 'blammed' | 'philly' | 'philly-nice':
				return 'philly';
			case 'milf' | 'satin-panties' | 'high':
				return 'limo';
			case 'cocoa' | 'eggnog':
				return 'mall';
			case 'winter-horrorland':
				return 'mallEvil';
			case 'senpai' | 'roses':
				return 'school';
			case 'thorns':
				return 'schoolEvil';
			case 'ugh' | 'guns' | 'stress':
				return 'tank';
		}
		return 'stage';
	}

	public static var reservedNames:Array<String> = ['gf', 'gfGroup', 'dad', 'dadGroup', 'boyfriend', 'boyfriendGroup']; //blocks these names from being used on stage editor's name input text
	public static function addObjectsToState(objectList:Array<Dynamic>, gf:FlxSprite, dad:FlxSprite, boyfriend:FlxSprite, ?group:Dynamic = null, ?ignoreFilters:Bool = false)
	{
		var addedObjects:Map<String, FlxSprite> = [];
		for (num => data in objectList)
		{
			if (addedObjects.exists(data)) continue;

			switch(data.type)
			{
				case 'gf', 'gfGroup':
					if(gf != null)
					{
						gf.ID = num; 
						if (group != null) group.add(gf);
						addedObjects.set('gf', gf);
					}
				case 'dad', 'dadGroup':
					if(dad != null)
					{
						dad.ID = num;
						if (group != null) group.add(dad);
						addedObjects.set('dad', dad);
					}
				case 'boyfriend', 'boyfriendGroup':
					if(boyfriend != null)
					{
						boyfriend.ID = num;
						if (group != null) group.add(boyfriend);
						addedObjects.set('boyfriend', boyfriend);
					}

				case 'square', 'sprite', 'animatedSprite':
					if(!ignoreFilters && !validateVisibility(data.filters)) continue;

					var spr:ModchartSprite = new ModchartSprite(data.x, data.y);
					spr.ID = num;
					if(data.type != 'square')
					{
						if(data.type == 'sprite')
							spr.loadGraphic(Paths.image(data.image));
						else
							spr.frames = Paths.getAtlas(data.image);
						
						if(data.type == 'animatedSprite' && data.animations != null)
						{
							var anims:Array<objects.Character.AnimArray> = cast data.animations;
							for (key => anim in anims)
							{
								if(anim.indices == null || anim.indices.length < 1)
									spr.animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);
								else
									spr.animation.addByIndices(anim.anim, anim.name, anim.indices, '', anim.fps, anim.loop);
	
								if(anim.offsets != null)
									spr.addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
	
								if(spr.animation.curAnim == null || data.firstAnimation == anim.anim)
									spr.playAnim(anim.anim, true);
							}
						}
						for (varName in ['antialiasing', 'flipX', 'flipY'])
						{
							var dat:Dynamic = Reflect.getProperty(data, varName);
							if(dat != null) Reflect.setProperty(spr, varName, dat);
						}
						if(!ClientPrefs.data.antialiasing) spr.antialiasing = false;
					}
					else
					{
						spr.makeGraphic(1, 1, FlxColor.WHITE);
						spr.antialiasing = false;
					}

					if(data.scale != null && (data.scale[0] != 1.0 || data.scale[1] != 1.0))
					{
						spr.scale.set(data.scale[0], data.scale[1]);
						spr.updateHitbox();
					}
					spr.scrollFactor.set(data.scroll[0], data.scroll[1]);
					spr.color = CoolUtil.colorFromString(data.color);
					
					for (varName in ['alpha', 'angle'])
					{
						var dat:Dynamic = Reflect.getProperty(data, varName);
						if(dat != null) Reflect.setProperty(spr, varName, dat);
					}

					if (group != null) group.add(spr);
					addedObjects.set(data.name, spr);

				default:
					var err = '[Stage .JSON file] Unknown sprite type detected: ${data.type}';
					trace(err);
					FlxG.log.error(err);
			}
		}
		return addedObjects;
	}

	public static function validateVisibility(filters:LoadFilters)
	{
		if((filters & STORY_MODE) == STORY_MODE)
			if(!PlayState.isStoryMode) return false;
		else if((filters & FREEPLAY) == FREEPLAY)
			if(PlayState.isStoryMode) return false;

		return ((ClientPrefs.data.lowQuality && (filters & LOW_QUALITY) == LOW_QUALITY) ||
			(!ClientPrefs.data.lowQuality && (filters & HIGH_QUALITY) == HIGH_QUALITY));
	}

	public static var stageXML:Access;
	public static var stageSprites:Map<String, FlxSprite> = [];
	static var spriteNum:Int = 0;
	static function loadStageXML(stageName:String)
	{
		var stageToLoad:StageFile = StageData.dummy();
		var stagePath:String = Paths.modFolders('stages/' + stageName + '.xml');
		if (!FileSystem.exists(stagePath)) stagePath = Paths.modFolders('data/stages/' + stageName + '.xml');
        if (FileSystem.exists(stagePath))
		{
			trace('found stage xml at $stagePath');
			try stageXML = new Access(Xml.parse(File.getContent(stagePath)).firstElement())
			catch(e) trace('Couldn\'t load stage "$stageName": ${e.message}');
		}
        else
		{
			trace('failed to find $stageName, returning default');
			return stageToLoad;
		}

		if (stageXML != null) {
			var parsed:Dynamic;
			if(stageXML.has.zoom && (parsed = Std.parseFloat(stageXML.att.zoom)) != null) stageToLoad.defaultZoom = parsed;
			if (stageXML.has.folder) {
				stageToLoad.folder = stageXML.att.folder;
				if (!stageToLoad.folder.endsWith("/")) stageToLoad.folder += "/";
			}
			else stageToLoad.folder = "";

			for(node in stageXML.elements) {
				var sprite:Dynamic = switch(node.name) {
					case "boyfriend" | "bf" | "player":
						stageToLoad = addCharPos("boyfriend", node, stageToLoad, {
							x: 770,
							y: 100,
							scroll: new FlxPoint(1,1),
							flip: true,
							flipX: true,
							camOffset: [0,0],
							alpha: 1,
							scale: new FlxPoint(1,1)
						});
					case "girlfriend" | "gf":
						stageToLoad = addCharPos("girlfriend", node, stageToLoad, {
							x: 400,
							y: 130,
							scroll: new FlxPoint(0.95),
							flip: false,
							flipX: false,
							camOffset: [0,0],
							alpha: 1,
							scale: new FlxPoint(1,1)
						});
					case "dad" | "opponent":
						stageToLoad = addCharPos("dad", node, stageToLoad, {
							x: 100,
							y: 100,
							scroll: new FlxPoint(1,1),
							flip: false,
							flipX: false,
							camOffset: [0,0],
							alpha: 1,
							scale: new FlxPoint(1,1)
						});
					case "character" | "char":
						if (!node.has.name) continue;
						trace('i have a limit goddamnit');
						null;
					case "use-extension" | "extension" | "ext":
						trace('pysch doesn\'t use this');
						null;
					default: null;
				}
			}
		}
		return stageToLoad;
	}

	public static function loadXMLSprites(?stageFile:StageFile)
	{
		if (stageFile == null) 
		{
			trace('loadXMLSprites: stageFile null, using a dummy stageFile');
			stageFile = dummy();
		}
		var xmlSprites:Array<FlxSprite> = [];
		for(node in stageXML.elements) {
			var sprite:Dynamic = switch(node.name) {
				case "sprite" | "spr" | "sparrow":
					if (!node.has.sprite || !node.has.name) continue;
					var nameSpr:String = '';
					if (node.has.name) nameSpr = node.att.name;

					var spr = XMLHelper.createSpriteFromXML(node, stageFile.folder, LOOP);
					if (nameSpr == '') {
						spriteNum++;
						nameSpr = 'sprite$spriteNum';
					}

					stageSprites.set(nameSpr, spr);
					PlayState.instance.add(spr);
					for(e in node.nodes.property)
						XMLHelper.applyXMLProperty(spr, e);
					xmlSprites.push(spr);
					spr;
				case "box" | "solid":
					if (!node.has.name || !node.has.width || !node.has.height) continue;
					var nameSpr:String = '';
					if (node.has.name) nameSpr = node.att.name;

					var spr = new FlxSprite(
						(node.has.x) ? Std.parseFloat(node.att.x) : 0,
						(node.has.y) ? Std.parseFloat(node.att.y) : 0
					);

					spr.makeGraphic(
						Std.parseInt(node.att.width),
						Std.parseInt(node.att.height),
						(node.has.color) ? CoolUtil.getColorFromDynamic(node.att.color) : -1
					);

					if (nameSpr == '') {
						spriteNum++;
						nameSpr = 'sprite$spriteNum';
					}

					stageSprites.set(nameSpr, spr);
					PlayState.instance.add(spr);
					for(e in node.nodes.property)
						XMLHelper.applyXMLProperty(spr, e);
					xmlSprites.push(spr);
					spr;
				case "boyfriend" | "bf" | "player":
				PlayState.instance.add(PlayState.instance.boyfriendGroup);	
				null;
				case "girlfriend" | "gf":
				PlayState.instance.add(PlayState.instance.gfGroup);	
				null;
				case "dad" | "opponent":
				PlayState.instance.add(PlayState.instance.dadGroup);
				null;
				default: null;
			}
		}
	}

	public static function getSprite(name:String)
		return stageSprites.get(name);

	static function addCharPos(charType:String, node:Access, stageFile:StageFile, info:StageCharPosInfo) {
		var xmlInfo:StageCharPosInfo = {
			x: 0,
			y: 0,
			flip: false,
			scroll: new FlxPoint(0,0),
			camOffset: [0,0],
			flipX: false,
			alpha: 1,
			scale: new FlxPoint(0,0)
		}
		if (info != null) {
			switch(charType)
			{
				case 'boyfriend':
					stageFile.boyfriend = [info.x, info.y];
					stageFile.camera_boyfriend = [info.camOffset[0], info.camOffset[1]];
				case 'girlfriend':
					stageFile.girlfriend = [info.x, info.y];
					stageFile.camera_girlfriend = [info.camOffset[0], info.camOffset[1]];
				case 'dad':
					stageFile.opponent = [info.x, info.y];
					stageFile.camera_opponent = [info.camOffset[0], info.camOffset[1]];
				default:
					stageFile.boyfriend = [info.x, info.y];
					stageFile.camera_boyfriend = [info.camOffset[0], info.camOffset[1]];
			}
		}

		if (node != null) {
			xmlInfo.x = (CoolUtil.isNaN(Std.parseFloat(node.x.get("x")))) ? info.x : Std.parseFloat(node.x.get("x"));
			xmlInfo.y = (CoolUtil.isNaN(Std.parseFloat(node.x.get("y")))) ? info.y : Std.parseFloat(node.x.get("y"));
			xmlInfo.camOffset = [Std.parseInt(node.x.get("camxoffset")), Std.parseInt(node.x.get("camyoffset"))];
			xmlInfo.alpha = Std.parseFloat(node.x.get("alpha"));
			xmlInfo.flipX = (node.has.flip || node.has.flipX) ? (node.x.get("flip") == "true" || node.x.get("flipX") == "true") : false;

			var scale = Std.parseFloat(node.x.get("scale"));
			xmlInfo.scale.set(scale, scale);

			if (node.has.scroll) {
				var scroll:Null<Float> = Std.parseFloat(node.att.scroll);
				if (scroll != null) xmlInfo.scroll.set(scroll, scroll);
			} else {
				if (node.has.scrollx) {
					var scroll:Null<Float> = Std.parseFloat(node.att.scrollx);
					if (scroll != null) xmlInfo.scroll.x = scroll;
				}
				if (node.has.scrolly) {
					var scroll:Null<Float> = Std.parseFloat(node.att.scrolly);
					if (scroll != null) xmlInfo.scroll.y = scroll;
				}
			}

			switch(charType)
			{
				case 'boyfriend':
					stageFile.boyfriend = [xmlInfo.x, xmlInfo.y];
					stageFile.camera_boyfriend = [xmlInfo.camOffset[0], xmlInfo.camOffset[1]];
				case 'girlfriend':
					stageFile.girlfriend = [xmlInfo.x, xmlInfo.y];
					stageFile.camera_girlfriend = [xmlInfo.camOffset[0], xmlInfo.camOffset[1]];
				case 'dad':
					stageFile.opponent = [xmlInfo.x, xmlInfo.y];
					stageFile.camera_opponent = [xmlInfo.camOffset[0], xmlInfo.camOffset[1]];
				default:
					stageFile.boyfriend = [xmlInfo.x, xmlInfo.y];
					stageFile.camera_boyfriend = [xmlInfo.camOffset[0], xmlInfo.camOffset[1]];
			}
		}

		return stageFile;
	}
}

//CODENAME STUFF (at the end of pysch's bc this shit is really big)
typedef StageCharPosInfo = {
	var x:Float;
	var y:Float;
	var flip:Bool;
	var scroll:FlxPoint;
	var camOffset:Array<Int>;
	var flipX:Bool;
	var alpha:Float;
	var scale:FlxPoint;
}