package warped.modchart.modifiers;
import warped.modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import warped.math.*;
import backend.*;
import states.*;
import substates.*;
import objects.*;

class ConfusionModifier extends NoteModifier {
    override function getName()return 'confusion';
	override function shouldExecute(player:Int, val:Float)return true;

    override function updateNote(beat:Float, note:Note, pos:Vector3, player:Int)
    {
        if(!note.isSustainNote)
			note.angle = (getValue(player) + getSubmodValue('confusion${note.noteData}', player) + getSubmodValue('note${note.noteData}Angle',player));
        else
            note.angle = note.mAngle;
    }

    override function updateReceptor(beat:Float, receptor:StrumNote , pos:Vector3, player:Int)
		receptor.angle = (getValue(player)
		+ getSubmodValue('confusion${receptor.noteData}', player)
			+ getSubmodValue('receptor${receptor.noteData}Angle', player));
    

    override function getSubmods(){
        var subMods:Array<String> = ["noteAngle","receptorAngle"];

        for(i in 0...4){
            subMods.push('note${i}Angle');
            subMods.push('receptor${i}Angle');
            subMods.push('confusion${i}');
        }

        return subMods;
    }
}