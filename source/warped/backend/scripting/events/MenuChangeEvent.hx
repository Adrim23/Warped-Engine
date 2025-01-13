package warped.backend.scripting.events;

final class MenuChangeEvent extends CancellableEvent {
	/**
	 * Value before the change
	 */
	public var oldValue:Int;

	/**
	 * Value after the change
	 */
	public var value:Int;

	/**
	 * Amount of change
	 */
	public var change:Int;

	/**
	 * Whenever the menu SFX should be played.
	 */
	public var playMenuSFX:Bool = true;

	public function new(oV:Int, v:Int, c:Int, SFX:Bool)
	{
		super();
		oldValue = oV;
		value = v;
		change = c;
		playMenuSFX = SFX;
	}
}