package warped.backend.scripting.events;

import objects.Note;

final class SimpleNoteEvent extends CancellableEvent {
	/**
		Note that is affected.
	**/
	public var note:Note;
}