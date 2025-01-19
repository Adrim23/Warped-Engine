package warped.backend.freeplay;
import warped.backend.freeplay.AnimationData;

@:nullSafety
class PlayerData
{
	public function new() {}
	/**
	 * The sematic version number of the player data JSON format.
	 * Supports fancy comparisons like NPM does it's neat.
	 */
	public var version:String = "1.0";

	/**
	 * A readable name for this playable character.
	 */
	public var name:String = 'Unknown';

	/**
	 * The character IDs this character is associated with.
	 * Only songs that use these characters will show up in Freeplay.
	 */
	public var ownedChars:Array<String> = ["bf"];

	/**
	 * Whether to show songs with character IDs that aren't associated with any specific character.
	 */
	public var showUnownedChars:Bool = false;

	/**
	 * Which freeplay style to use for this character.
	 */
	public var freeplayStyle:String = 'bf';

	/**
	 * Data for displaying this character in the Freeplay menu.
	 * If null, display no DJ.
	 */
	public var freeplayDJ:Null<PlayerFreeplayDJData> = null;

	/**
	 * Whether this character is unlocked by default.
	 * Use a ScriptedPlayableCharacter to add custom logic.
	 */
	public var unlocked:Bool = true;
}

class PlayerFreeplayDJData
{
	var assetPath:String;
	var animations:Array<AnimationData>;


	var text1:String = "BOYFRIEND";

	var text2:String = "HOT BLOODED IN MORE WAYS THAN ONE";

	var text3:String = "PROTECT YO NUTS";

	@:jignored
	var animationMap:Map<String, AnimationData>;

	@:jignored
	var prefixToOffsetsMap:Map<String, Array<Float>>;

	var charSelect:Null<PlayerFreeplayDJCharSelectData>;

	var cartoon:Null<PlayerFreeplayDJCartoonData>;

	var fistPump:Null<PlayerFreeplayDJFistPumpData>;

	public function new()
	{
		animationMap = new Map();
	}

	function mapAnimations()
	{
		if (animationMap == null)
			animationMap = new Map();
		if (prefixToOffsetsMap == null)
			prefixToOffsetsMap = new Map();

		animationMap.clear();
		prefixToOffsetsMap.clear();
		for (anim in animations)
		{
			animationMap.set(anim.name, anim);
			prefixToOffsetsMap.set(anim.prefix, anim.offsets);
		}
	}

	public function getAtlasPath():String
	{
		return Paths.animateAtlas(assetPath);
	}

	public function getFreeplayDJText(index:Int):String
	{
		switch (index)
		{
			case 1:
				return text1;
			case 2:
				return text2;
			case 3:
				return text3;
			default:
				return '';
		}
	}

	public function getAnimationPrefix(name:String):Null<String>
	{
		if (!animationMap.iterator().hasNext())
			mapAnimations();

		var anim = animationMap.get(name);
		if (anim == null)
			return null;
		return anim.prefix;
	}

	public function getAnimationOffsetsByPrefix(?prefix:String):Array<Float>
	{
		if (!prefixToOffsetsMap.iterator().hasNext())
			mapAnimations();
		if (prefix == null)
			return [0, 0];
		return prefixToOffsetsMap.get(prefix);
	}

	public function getAnimationOffsets(name:String):Array<Float>
	{
		return getAnimationOffsetsByPrefix(getAnimationPrefix(name));
	}

	// TODO: These should really be frame labels, ehe.

	public function getCartoonSoundClickFrame():Int
	{
		return cartoon?.soundClickFrame ?? 80;
	}

	public function getCartoonSoundCartoonFrame():Int
	{
		return cartoon?.soundCartoonFrame ?? 85;
	}

	public function getCartoonLoopBlinkFrame():Int
	{
		return cartoon?.loopBlinkFrame ?? 112;
	}

	public function getCartoonLoopFrame():Int
	{
		return cartoon?.loopFrame ?? 166;
	}

	public function getCartoonChannelChangeFrame():Int
	{
		return cartoon?.channelChangeFrame ?? 60;
	}

	public function getFistPumpIntroStartFrame():Int
	{
		return fistPump?.introStartFrame ?? 0;
	}

	public function getFistPumpIntroEndFrame():Int
	{
		return fistPump?.introEndFrame ?? 0;
	}

	public function getFistPumpLoopStartFrame():Int
	{
		return fistPump?.loopStartFrame ?? 0;
	}

	public function getFistPumpLoopEndFrame():Int
	{
		return fistPump?.loopEndFrame ?? 0;
	}

	public function getFistPumpIntroBadStartFrame():Int
	{
		return fistPump?.introBadStartFrame ?? 0;
	}

	public function getFistPumpIntroBadEndFrame():Int
	{
		return fistPump?.introBadEndFrame ?? 0;
	}

	public function getFistPumpLoopBadStartFrame():Int
	{
		return fistPump?.loopBadStartFrame ?? 0;
	}

	public function getFistPumpLoopBadEndFrame():Int
	{
		return fistPump?.loopBadEndFrame ?? 0;
	}

	public function getCharSelectTransitionDelay():Float
	{
		return charSelect?.transitionDelay ?? 0.25;
	}
}

typedef PlayerFreeplayDJCharSelectData =
{
	var transitionDelay:Float;
}

typedef PlayerFreeplayDJCartoonData =
{
	var soundClickFrame:Int;
	var soundCartoonFrame:Int;
	var loopBlinkFrame:Int;
	var loopFrame:Int;
	var channelChangeFrame:Int;
}

typedef PlayerFreeplayDJFistPumpData =
{
	@:default(0)
	var introStartFrame:Int;

	@:default(4)
	var introEndFrame:Int;

	@:default(4)
	var loopStartFrame:Int;

	@:default(-1)
	var loopEndFrame:Int;

	@:default(0)
	var introBadStartFrame:Int;

	@:default(4)
	var introBadEndFrame:Int;

	@:default(4)
	var loopBadStartFrame:Int;

	@:default(-1)
	var loopBadEndFrame:Int;
};