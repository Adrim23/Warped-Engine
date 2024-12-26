package warped.objects;

import flixel.group.FlxSpriteGroup;
import haxe.xml.Access;

class Stage extends FlxSpriteGroup
{
    public var stageSprites:Map<String, FlxSprite> = [];
    public var stageXML:Access = null;
}