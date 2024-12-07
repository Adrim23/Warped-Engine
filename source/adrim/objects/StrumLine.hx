package adrim.objects;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxSignal.FlxTypedSignal;

import backend.Conductor;
import backend.Rating;

import objects.Note;
import objects.StrumNote;
import objects.Character;

import psychlua.LuaUtils;

class StrumLine extends FlxTypedSpriteGroup<StrumNote>
{
  //CODENAME SHIT HERE
   /**
	 * Signal that triggers whenever a note is hit. Similar to onPlayerHit and onDadHit, except strumline specific.
	 * To add a listener, do
	 * `strumLine.onHit.add(function(e:NoteHitEvent) {});`
	 */
	public var onHit:FlxTypedSignal<NoteHitEvent->Void> = new FlxTypedSignal<NoteHitEvent->Void>();
	/**
	 * Signal that triggers whenever a note is missed. Similar to onPlayerMiss, except strumline specific.
	 * To add a listener, do
	 * `strumLine.onMiss.add(function(e:NoteMissEvent) {});`
	 */
	public var onMiss:FlxTypedSignal<NoteMissEvent->Void> = new FlxTypedSignal<NoteMissEvent->Void>();
	/**
	 * Signal that triggers whenever a note is being updated. Similar to onNoteUpdate, except strumline specific.
	 * To add a listener, do
	 * `strumLine.onNoteUpdate.add(function(e:NoteUpdateEvent) {});`
	 */
	public var onNoteUpdate:FlxTypedSignal<NoteUpdateEvent->Void> = new FlxTypedSignal<NoteUpdateEvent->Void>();
	/**
	 * Signal that triggers whenever a note is being deleted. Similar to onNoteDelete, except strumline specific.
	 * To add a listener, do
	 * `strumLine.onNoteDelete.add(function(e:SimpleNoteEvent) {});`
	 */
	public var onNoteDelete:FlxTypedSignal<SimpleNoteEvent->Void> = new FlxTypedSignal<SimpleNoteEvent->Void>();
  //

  public var curCharacters:Array<Character>; //The characters that are currently singing
  public var characters:Array<Character> = []; //The array of all the characters that are linked to this strumline
  public var texture(default, set):String; //The texture of all the strumnotes attached to this strumline
  public var size(default, set):Null<Float> = null; //The size of all the strumnotes attached to this strumline
  public var strumShader(default, set):FlxShader = null; //The shader of all the strumnotes attached to this strumline
  public var useRGBShader(default, set):Bool = false; //Should the strumnotes attached to this strumline use the rgb shader?
	public var altAnim(default, set):Bool = false; //Should the singing character use alt animations?
	public var cpu:Bool=false; //For opponentStrums and or botplay or smth
	public var isPlayer:Bool=false; //Checks if its the player or not
  public var ratingsData:Array<Rating> = Rating.loadDefault(); //The ratings, yeah you can change them
  public var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT']; //Default character prefixes, you can change them if you want to
  public var missFunction:Note->Void; //The function that controls missing, if null then it does nothing
  public var callbackName:String = 'opponentNoteHit'; //The name of it when it calls lua and hs

  override public function new(X:Float, Y:Float, ?char:Character=null, ?spawnStrum:Bool=true, ?tex:String='')
  {
    super(X,Y);
    if (char != null) characters.push(char);
    if (characters != null) curCharacters = characters;
    if (!spawnStrum) return;
		for (i in 0...4)
		{
			var babyArrow:StrumNote = new StrumNote(0, 50, i, 0);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			add(babyArrow);
			babyArrow.setStrumPos();
		}
   
    size = 0.7;
    if (tex != null) texture = tex;
    size = 2;
  }

  function set_texture(value:String):String
  {
    if (this.texture != value)
        for (i in 0...members.length)
        {
            this.texture = value;
            members[i].texture = value;
            members[i].reloadNote();
        }
    return value;
  }
  
  function set_size(value:Null<Float>):Null<Float>
  {
    if (value == null) return null;
    size = value;
    for (i in 0...members.length)
      members[i].size = value;
    return value;
  }

  function set_strumShader(value:FlxShader)
  {
    shader = value;
    for (i in 0...members.length)
      members[i].shader = value;

    return value;
  }

  function set_useRGBShader(value:Bool)
  {
    useRGBShader = value;
    for (i in 0...members.length)
      members[i].useRGBShader = value;

    return value;
  }
  
  function set_altAnim(value:Bool)
  {
    altAnim = value;
    for (char in characters)
      char.useAlts = value;

    return value;
  }

  public function playStrumAnim(id:Int, time:Float)
  {
    var spr:StrumNote = this.members[id];
		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
  }

  public function hit(note:Note)
  {
    var game = PlayState.instance;
    var event:NoteHitEvent;
    var useRating:Rating = Rating.loadDefault()[0];
    if (this.isPlayer)
      {
        if(note.wasGoodHit) return;
        if(this.cpu && note.ignoreNote) return;
    
        var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
        var leData:Int = Math.round(Math.abs(note.noteData));
        var leType:String = note.noteType;
    
        var result:Dynamic = game.callOnLuas('${callbackName}Pre', [game.notes.members.indexOf(note), leData, leType, isSus]);
        if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) result = game.callOnHScript('${callbackName}Pre', [note]);
    
        if(result == LuaUtils.Function_Stop) return;
    
        var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
        var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / game.playbackRate);
        useRating = daRating;
    
        event = new NoteHitEvent(false, !note.isSustainNote, !note.isSustainNote, true, note, this.characters, true, note.noteType, note.animSuffix, "",  "", note.noteData, daRating.score, daRating.ratingMod, 0.023, daRating.name, daRating.name == "sick", 0.5, ClientPrefs.data.antialiasing, 0.7, ClientPrefs.data.antialiasing, false);
        event = game.scripts.event('onPlayerHit', event);
        if (event.cancelled) return;
    
        note.ratingMod = event.accuracy;
        if(!note.ratingDisabled) daRating.hits++;
        note.rating = event.rating;
    
        note.wasGoodHit = !event.misses;
        note.hitCausesMiss = event.misses;
    
        if (note.hitsoundVolume > 0 && !note.hitsoundDisabled)
          FlxG.sound.play(Paths.sound(note.hitsound), note.hitsoundVolume);
    
        game.stagesFunc(function(stage:BaseStage) stage.goodNoteHit(note));
        var result:Dynamic = game.callOnLuas(callbackName, [game.notes.members.indexOf(note), leData, leType, isSus]);
        if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) game.callOnHScript(callbackName, [note]);
        if(!note.isSustainNote) game.invalidateNote(note);

        game.vocals.volume = 1;
    
        if (!note.isSustainNote)
        {
          if (event.countAsCombo)game.combo++;
          if(game.combo > 9999) game.combo = 9999;
          if(event.countScore) game.popUpScore(note, event);
        }
        var gainHealth:Bool = true; // prevent health gain, *if* sustains are treated as a singular note
        if (ClientPrefs.data.guitarHeroSustains && note.isSustainNote) gainHealth = false;
        if (gainHealth) game.health += event.healthGain * game.healthGain;
      }
      else
      {
        var result:Dynamic = game.callOnLuas('${callbackName}Pre', [game.notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
        if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) result = game.callOnHScript('${callbackName}Pre', [note]);
    
        if(result == LuaUtils.Function_Stop) return;
  
        event = new NoteHitEvent(false, !note.isSustainNote, !note.isSustainNote, true, note, this.characters, true, note.noteType, note.animSuffix, "",  "", note.noteData, 350, 1, 0.023, "sick", true, 0.5, ClientPrefs.data.antialiasing, 0.7, ClientPrefs.data.antialiasing, false);
        event = game.scripts.event('onDadHit', event);
        if (event.cancelled) return;
    
        if (game.songName != 'tutorial')
          game.camZooming = true;
    
        if(game.opponentVocals.length <= 0) game.vocals.volume = 1;
        playStrumAnim(Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / game.playbackRate);
        note.hitByOpponent = true;
        
        game.stagesFunc(function(stage:BaseStage) stage.opponentNoteHit(note));
        var result:Dynamic = game.callOnLuas(callbackName, [game.notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
        if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) game.callOnHScript(callbackName, [note]);
    
        if (!note.isSustainNote) game.invalidateNote(note);
      }

        if(!note.hitCausesMiss) //Common notes
        {
          for (char in curCharacters)
            doAnim(note, char, false, event.animCancelled);
            
          if(!this.cpu)
          {
            var spr = this.members[note.noteData];
            if(spr != null && !event.strumGlowCancelled) spr.playAnim('confirm', true);
          }
          else playStrumAnim(Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / game.playbackRate);
        }
        else
        {
          for (char in curCharacters)
            doAnim(note, char, true, event.animCancelled);
        }
        if(!note.noteSplashData.disabled && !note.isSustainNote && useRating.noteSplash && this.isPlayer && event.showSplash) game.spawnNoteSplashOnNote(note);
  }

  function doAnim(note:Note, char:Character, miss:Bool=false, cancelAnim:Bool=false)
  {
    var game = PlayState.instance;
    if (!miss)
    {
      if(!note.noAnimation && !cancelAnim)
        {
            var animToPlay:String = singAnims[Std.int(Math.abs(Math.min(singAnims.length-1, note.noteData)))] + note.animSuffix;
    
            var animCheck:String = 'hey';
            if(note.gfNote)
            {
              char = game.gf;
              animCheck = 'cheer';
            }
    
            if(char != null)
            {
              var canPlay:Bool = true;
              if(note.isSustainNote)
              {
                var holdAnim:String = animToPlay + '-hold';
                if(char.animation.exists(holdAnim)) animToPlay = holdAnim;
                if(char.getAnimationName() == holdAnim || char.getAnimationName() == holdAnim + '-loop') canPlay = false;
              }
      
              if(canPlay) char.playAnim(animToPlay, true);
              char.holdTimer = 0;
    
              if(note.noteType == 'Hey!')
              {
                if(char.hasAnimation(animCheck))
                {
                  char.playAnim(animCheck, true);
                  char.specialAnim = true;
                  char.heyTimer = 0.6;
                }
              }
            }
        }
    }
    else
    {
      if(!note.noMissAnimation)
        {
          switch(note.noteType)
          {
            case 'Hurt Note':
              if(char.hasAnimation('hurt'))
              {
                char.playAnim('hurt', true);
                char.specialAnim = true;
              }
          }
        }
  
        if (missFunction != null) missFunction(note);
    }
  }
}