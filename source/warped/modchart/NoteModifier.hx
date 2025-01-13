// @author Nebula_Zorua

package warped.modchart;

import warped.modchart.Modifier.ModifierType;

import backend.*;
import states.*;
import substates.*;
import objects.*;

class NoteModifier extends Modifier {
	override function getModType()
		return NOTE_MOD; // tells the mod manager to call this modifier when updating receptors/notes

}