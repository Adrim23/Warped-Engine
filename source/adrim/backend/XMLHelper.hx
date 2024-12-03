package adrim.backend;

import haxe.Exception;
import haxe.io.Path;
import haxe.xml.Access;
import objects.Character;

//Codename stuff
typedef AnimData = {
	var name:String;
	var anim:String;
	var fps:Int;
	var loop:Bool;
	var x:Int;
	var y:Int;
	var indices:Array<Int>;
	var ?forced:Bool;
}

class XMLHelper
{
	public static function addXMLAnimation(sprite:FlxSprite, anim:Access, loop:Bool = false):AnimArray {
		var daAnimArr:AnimArray = {
			anim: '',
			name: '',
			fps: 24,
			loop: false,
			indices: [],
			offsets: [0,0]
		};
		var animVariables = extractAnimFromXML(anim, loop);
		addAnimToSprite(sprite, animVariables);
		daAnimArr.name = animVariables.anim;
		daAnimArr.anim = animVariables.name;
		daAnimArr.fps = animVariables.fps;
		daAnimArr.indices = animVariables.indices;
		daAnimArr.offsets = [animVariables.x, animVariables.y];
		trace(daAnimArr);
		return daAnimArr;
	}

	public static function addAnimToSprite(sprite:FlxSprite, animData:AnimData):ErrorCode {
		if (animData.name != null) {
			if (animData.fps <= 0 #if web || animData.fps == null #end) animData.fps = 24;
				if (animData.anim == null && animData.indices.length > 0)
					sprite.animation.add(animData.name, animData.indices, animData.fps, animData.loop);
				else if (animData.indices.length > 0)
					sprite.animation.addByIndices(animData.name, animData.anim, animData.indices, "", animData.fps, animData.loop);
				else
					sprite.animation.addByPrefix(animData.name, animData.anim, animData.fps, animData.loop);

			return OK;
		}
		return MISSING_PROPERTY;
	}

	public static function extractAnimFromXML(anim:Access, loop:Bool = false):AnimData {
		var animData:AnimData = {
			name: null,
			anim: null,
			fps: 24,
			loop: loop,
			x: 0,
			y: 0,
			indices: []
		};

		if (anim.has.name) animData.name = anim.att.name;
		if (anim.has.anim) animData.anim = anim.att.anim;
		if (anim.has.fps) animData.fps = Std.parseInt(anim.att.fps);
		if (anim.has.x) animData.x = Std.parseInt(anim.att.x);
		if (anim.has.y) animData.y = Std.parseInt(anim.att.y);
		if (anim.has.loop) animData.loop = anim.att.loop == "true";
		if (anim.has.forced) animData.forced = anim.att.forced == "true";
		if (anim.has.indices) animData.indices = CoolUtil.parseNumberRange(anim.att.indices);

		return animData;
	}

    public static function loadSpriteFromXML(spr:FlxSprite, node:Access, parentFolder:String = "", defaultAnimType:XMLAnimType = BEAT):FlxSprite {
		if (parentFolder == null) parentFolder = "";

		spr.antialiasing = true;
		spr.loadGraphic(Paths.image('$parentFolder${node.x.get("sprite")}'));

		if(node.has.x) {
			var x:Null<Float> = Std.parseFloat(node.att.x);
			if (CoolUtil.isNotNull(x) || !CoolUtil.isNaN(x)) spr.x = x; else spr.x = 0;
		}
		if(node.has.y) {
			var y:Null<Float> = Std.parseFloat(node.att.y);
			if (CoolUtil.isNotNull(y) || !CoolUtil.isNaN(y)) spr.y = y; else spr.y = 0;
		}
		if (node.has.scroll) {
			var scroll:Null<Float> = Std.parseFloat(node.att.scroll);
			if (CoolUtil.isNotNull(scroll) || !CoolUtil.isNaN(scroll)) spr.scrollFactor.set(scroll, scroll); else spr.scrollFactor.set(1, 1);
		}
		if (node.has.scrollx) {
			var scroll:Null<Float> = Std.parseFloat(node.att.scrollx);
			if (CoolUtil.isNotNull(scroll) || !CoolUtil.isNaN(scroll)) spr.scrollFactor.x = scroll; else spr.scrollFactor.x = 1;
		}
		if (node.has.scrolly) {
			var scroll:Null<Float> = Std.parseFloat(node.att.scrolly);
			if (CoolUtil.isNotNull(scroll) || !CoolUtil.isNaN(scroll)) spr.scrollFactor.y = scroll; else spr.scrollFactor.y = 1;
		}
		if (node.has.antialiasing) spr.antialiasing = node.att.antialiasing == "true";
		if (node.has.width) {
			var width:Null<Float> = Std.parseFloat(node.att.width);
			if (CoolUtil.isNotNull(width) || !CoolUtil.isNaN(width)) spr.width = width;
		}
		if (node.has.height) {
			var height:Null<Float> = Std.parseFloat(node.att.height);
			if (CoolUtil.isNotNull(height) || !CoolUtil.isNaN(height)) spr.height = height;
		}
		if (node.has.scale) {
			var scale:Null<Float> = Std.parseFloat(node.att.scale);
			if (CoolUtil.isNotNull(scale) || !CoolUtil.isNaN(scale)) spr.scale.set(scale, scale);
		}
		if (node.has.scalex) {
			var scale:Null<Float> = Std.parseFloat(node.att.scalex);
			if (CoolUtil.isNotNull(scale) || !CoolUtil.isNaN(scale)) spr.scale.x = scale;
		}
		if (node.has.scaley) {
			var scale:Null<Float> = Std.parseFloat(node.att.scaley);
			if (CoolUtil.isNotNull(scale) || !CoolUtil.isNaN(scale)) spr.scale.y = scale;
		}
		if (node.has.graphicSize) {
			var graphicSize:Null<Int> = Std.parseInt(node.att.graphicSize);
			if (CoolUtil.isNotNull(graphicSize) || !CoolUtil.isNaN(graphicSize)) spr.setGraphicSize(graphicSize, graphicSize);
		}
		if (node.has.graphicSizex) {
			var graphicSizex:Null<Int> = Std.parseInt(node.att.graphicSizex);
			if (CoolUtil.isNotNull(graphicSizex) || !CoolUtil.isNaN(graphicSizex)) spr.setGraphicSize(graphicSizex);
		}
		if (node.has.graphicSizey) {
			var graphicSizey:Null<Int> = Std.parseInt(node.att.graphicSizey);
			if (CoolUtil.isNotNull(graphicSizey) || !CoolUtil.isNaN(graphicSizey)) spr.setGraphicSize(0, graphicSizey);
		}
		if (node.has.updateHitbox && node.att.updateHitbox == "true") spr.updateHitbox();

		if (node.has.alpha)
			spr.alpha = Std.parseFloat(node.x.get("alpha"));
        else
            spr.alpha = 1;

		if(node.has.color)
			spr.color = FlxColor.fromString(node.x.get("color"));
        else
            spr.color = 0xFFFFFFFF;

		if(node.hasNode.anim) {
			for(anim in node.nodes.anim)
				addXMLAnimation(spr, anim);
		} else {
			if (spr.frames != null && spr.frames.frames != null) {
				addAnimToSprite(spr, {
					name: "idle",
					anim: null,
					fps: 24,
					loop: false,
					x: 0,
					y: 0,
					indices: [for(i in 0...spr.frames.frames.length) i]
				});
			}
		}

		return spr;
	}

	public static inline function createSpriteFromXML(node:Access, parentFolder:String = "", defaultAnimType:XMLAnimType = BEAT, ?cl:Class<FlxSprite>, ?args:Array<Dynamic>):FlxSprite {
		if(cl == null) cl = FlxSprite;
		if(args == null) args = [];
		return loadSpriteFromXML(Type.createInstance(cl, args), node, parentFolder, defaultAnimType);
	}

    public static function applyXMLProperty(object:Dynamic, property:Access):ErrorCode {
		if (!property.has.name || !property.has.type || !property.has.value) {
			trace('Failed to apply XML property: XML Element is missing name, type, or value attributes.');
			return MISSING_PROPERTY;
		}

		var keys = property.att.name.split(".");
		var o = object;
		var isPath = false;
		while(keys.length > 1) {
			isPath = true;
			o = Reflect.getProperty(o, keys.shift());
			// TODO: support arrays
		}

		var value:Dynamic = switch(property.att.type.toLowerCase()) {
			case "f" | "float" | "number":			Std.parseFloat(property.att.value);
			case "i" | "int" | "integer" | "color":	Std.parseInt(property.att.value);
			case "s" | "string" | "str" | "text":	property.att.value;
			case "b" | "bool" | "boolean":			property.att.value.toLowerCase() == "true";
			default:								return TYPE_INCORRECT;
		}
		if (value == null) return VALUE_NULL;

		try {
			Reflect.setProperty(o, keys[0], value);
		} catch(e) {
			var str = 'Failed to apply XML property: $e on ${Type.getClass(object)}';
			if(isPath) {
				str += ' (Path: ${property.att.name})';
			}
			trace(str);
			return REFLECT_ERROR;
		}
		return OK;
	}
}

enum abstract XMLAnimType(Int)
{
	var NONE = 0;
	var BEAT = 1;
	var LOOP = 2;

	public static function fromString(str:String, def:XMLAnimType = NONE)
	{
		return switch (str.trim().toLowerCase())
		{
			case "none": NONE;
			case "beat" | "onbeat": BEAT;
			case "loop": LOOP;
			default: def;
		}
	}
}

enum abstract ErrorCode(Int) {
	var OK = 0;
	var FAILED = 1;
	var MISSING_PROPERTY = 2;
	var TYPE_INCORRECT = 3;
	var VALUE_NULL = 4;
	var REFLECT_ERROR = 5;
}