package warped.backend.scripting.events;

/**
 * CANCEL this event to prevent default behaviour!
 */
final class PauseCreationEvent extends CancellableEvent {
	/**
	 * Music that is going to be played
	 */
	public var music:String;

	/**
	 * All option names
	 */
	public var options:Array<String>;

	public function new(m:String, op:Array<String>)
	{
		super();
		music = m;
		options = op;
	}
}