package adrim.objects;

import objects.StrumNote;
import objects.Character;

class StrumLine extends FlxTypedSpriteGroup<StrumNote>
{
  public var link:Character;
  public var texture(default, set):String;
  public var size(default, set):Null<Float> = null;

  override public function new(X:Float, Y:Float, ?character:Character=null, ?tex:String=null)
  {
    super(X,Y,4);
		for (i in 0...4)
		{
			var babyArrow:StrumNote = new StrumNote(0, 50, i, 0);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			add(babyArrow);
			babyArrow.setStrumPos();
		}
   
    if (character != null) link = character;
    size = 0.7;
    if (tex != null) texture = tex;
    size = 2;
  }

  function set_texture(value:String):String
  {
    if (this.texture != value)
        for (i in 0...4)
        {
            this.texture = value;
            members[i].texture = value;
            members[i].reloadNote();
        }
    return value;
  }
  
  function set_size(value:Null<Float>):Null<Float>
  {
    if (value == null) return null;
    if (this.members.length != 4) return null;
    size = value;
    for (i in 0...4)
      members[i].size = value;
    return value;
  }

  public function playStrumAnim(id:Int, time:Int)
  {
        var spr:StrumNote = this.members[id];
		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
  }
}