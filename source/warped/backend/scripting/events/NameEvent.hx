package warped.backend.scripting.events;

final class NameEvent extends CancellableEvent {
	/**
	 * Name
	 */
	public var name:String;

	public function new(n:String){super(); name = n;}
}