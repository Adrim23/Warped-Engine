package adrim.backend.scripting.events;

import objetcs.Note;

final class SimpleNoteEvent extends CancellableEvent {
	/**
		Note that is affected.
	**/
	public var note:Note;
}