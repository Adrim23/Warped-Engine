package warped.backend.scripting.events;

import backend.StageData;
import haxe.xml.Access;

final class StageXMLEvent extends CancellableEvent {
	/**
	 * The stage instance
	 */
	public var stage:StageData;

	/**
	 * The xml
	 */
	public var xml:Access;

	/**
	 * The object which was parsed
	 */
	public var elems:Array<Access>;
}