package warped.objects;

import haxe.xml.Access;
import warped.backend.XMLHelper;
import warped.objects.FunkinSprite;
import backend.Mods;
import backend.CoolUtil;
import objects.StrumNote;
import flixel.group.FlxGroup.FlxTypedGroup;

class SplashGroup extends FlxTypedGroup<FunkinSprite> {
	/**
	 * Whenever the splash group has successfully loaded or not.
	 */
	public var valid:Bool = true;

	/**
	 * XML data for the note splashes.
	 */
	public var xml:Access;

	/**
	 * Animation names sorted by strum IDs.
	 * Use `getSplashAnim` to get one.
	 */
	public var animationNames:Array<Array<String>> = [];

	/**
	 * Creates a new Splash group
	 * @param path Path to the splash data (xml)
	 */
	public function new(path:String) {
		super();

		try {
			var plainXML:String = File.getContent(path);
			var trueXML:Xml = Xml.parse(plainXML).firstElement();
			xml = new Access(trueXML);

			if (!xml.has.sprite) throw "The <splash> element requires a sprite attribute.";
			trace('a1');
			var splash = createSplash(xml.att.sprite);
			setupAnims(xml, splash);
			pregenerateSplashes(splash);
			add(splash);
			trace('done!');
		} catch(e:Dynamic) {
			Logs.trace('Couldn\'t parse splash data for "${path}": ${e.toString()}', ERROR);
			valid = false;
		}
		maxSize = 8;
	}

	function createSplash(imagePath:String) {
		var splash = new FunkinSprite();
		splash.antialiasing = true;
		splash.active = splash.visible = false;
		splash.loadSprite(imagePath);
		if (xml.has.scale) splash.scale.scale(CoolUtil.isNaN(Std.parseFloat(xml.att.scale)) ? 1 : Std.parseFloat(xml.att.scale));
		if (xml.has.alpha) splash.alpha = CoolUtil.isNaN(Std.parseFloat(xml.att.alpha)) ? 1 : Std.parseFloat(xml.att.alpha);
		if (xml.has.antialiasing) splash.antialiasing = xml.att.antialiasing == "true";
		return splash;
	}

	function setupAnims(xml:Access, splash:FunkinSprite) {
		for(strum in xml.nodes.strum) {
			var id:Null<Int> = Std.parseInt(strum.att.id);
			if (id != null) {
				animationNames[id] = [];
				for(anim in strum.nodes.anim) {
					if (!anim.has.name) continue;
					XMLHelper.addXMLAnimation(splash, anim, false);
					animationNames[id].push(anim.att.name);
				}
			}
		}

		// if (animationNames.length <= 0)
		//		animationNames.push([]);

		for(anim in xml.nodes.anim) {
			if (!anim.has.name) continue;
			XMLHelper.addXMLAnimation(splash, anim, false);
			for(a in animationNames) {
				if (a == null) continue;
				a.push(anim.att.name);
			}
		}
		splash.animation.finishCallback = function(name:String) {
			splash.active = splash.visible = false;
		};
	}

	function pregenerateSplashes(splash:FunkinSprite) {
		// make 7 additional splashes
		for(i in 0...7) {
			var spr = FunkinSprite.copyFrom(splash);
			spr.animation.finishCallback = function(name:String) {
				spr.active = spr.visible = false;
			};
			add(spr);
		}
	}

	public function getSplashAnim(id:Int):String {
		if (animationNames.length <= 0) return null;
		id %= animationNames.length;
		if (animationNames[id] == null || animationNames[id].length <= 0) return null;
		return animationNames[id][FlxG.random.int(0, animationNames[id].length - 1)];
	}

	var __splash:FunkinSprite;
	public function showOnStrum(strum:StrumNote) {
		if (!valid) return null;
		__splash = recycle();

		__splash.cameras = strum.cameras;
		__splash.setPosition(strum.x + ((strum.width - __splash.width) / 2), strum.y + ((strum.height - __splash.height) / 2));
		__splash.active = __splash.visible = true;
		__splash.playAnim(getSplashAnim(strum.ID), true);
		__splash.scrollFactor.set(strum.scrollFactor.x, strum.scrollFactor.y);

		return __splash;
	}
}