package warped.backend.scripting.events;

import objects.Note;

final class NoteCreationEvent extends CancellableEvent {
	/**
	 * Note that is being created
	 */
	public var note:Note;

	/**
	 * ID of the strum (from 0 to 3)
	 */
	public var strumID:Int;

	/**
	 * Note Type (ex: "My Super Cool Note", or "Mine")
	 */
	public var noteType:String;

	/**
	 * ID of the note type.
	 */
	public var noteTypeID:Int;

	/**
	 * ID of the player.
	 */
	public var strumLineID:Int;

	/**
	 * Whenever the note will need to be hit by the player
	 */
	public var mustHit(default, set):Bool;

	function set_mustHit(value:Bool)
	{
		mustHit = value;
		note.mustPress = value;
		return value;
	}

	/**
	 * Note sprite, if you only want to replace the sprite.
	 */
	public var noteSprite(default, set):String;

	function set_noteSprite(value:String)
	{
		noteSprite = value;
		note.texture = value;
		return value;
	}

	/**
	 * Note scale, if you only want to replace the scale.
	 */
	public var noteScale:Float;

	/**
	 * Sing animation suffix. "-alt" for alt anim or "" for normal notes.
	 */
	public var animSuffix:String;

	public function new(note:Note,nD:Int,nT:String,nTID:Int=0,strumID:Int=0,must:Bool,sprite:String,scale:Float,suffix:String)
	{
	  super();
	  this.note = note;
	  this.strumID = nD;
	  noteType = nT;
	  noteTypeID = nTID;
	  strumLineID = strumID;
	  mustHit = must;
	  noteSprite = sprite;
	  noteScale = scale;
	  animSuffix = suffix;
	}
}