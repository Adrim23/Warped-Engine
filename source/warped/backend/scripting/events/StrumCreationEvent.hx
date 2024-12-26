package warped.backend.scripting.events;

import objects.StrumNote;

final class StrumCreationEvent extends CancellableEvent {
	@:dox(hide) public var __doAnimation = true;


	/**
	 * The strum that is being created
	 */
	public var strum:StrumNote;

	/**s
	 * Player ID
	 */
	public var player:Int;

	/**
	 * Strum ID, for the sprite.
	 */
	public var strumID:Int;

	/**
	 * Animation prefix (`left` = `arrowLEFT`, `left press`, `left confirm`).
	 */
	public var animPrefix:String;

	/**
	 * Sprite path, in case you only want to change the sprite.
	 */
	public var sprite(default, set):String = "";

	function set_sprite(value:String)
	{
		sprite = value;
		strum.texture = value;
		return value;
	}

	public function new(s:StrumNote,pl:Int,id:Int,prefix:String)
	{
		super();

		strum = s;
		player = pl;
		strumID = id;
		animPrefix = prefix;
	}

	/**
	 * Cancels the animation that makes the strum "land" in the strumline.
	 */
	public function cancelAnimation() {__doAnimation = false;}
	@:dox(hide) public function preventAnimation() {cancelAnimation();}
}