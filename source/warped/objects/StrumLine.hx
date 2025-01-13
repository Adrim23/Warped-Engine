package warped.objects;

import openfl.events.KeyboardEvent;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.input.keyboard.FlxKey;

import backend.Conductor;
import backend.Rating;

import objects.Note;
import objects.StrumNote;
import objects.Character;
import warped.objects.RatingGroup;

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
	public var cpu:Bool=false; //For checks if botplay is on on this strumline
	public var isPlayer:Bool=false; //Makes this strumline player controlled or cpu controlled
  public var ratingsData:Array<Rating> = Rating.loadDefault(); //The ratings, yeah you can change them
  public var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT']; //Default character prefixes, you can change them if you want to
  public var missFunction:Note->Void; //The function that controls missing, if null then it does nothing
  public var missPressFunction:Int->Void; //The function that controls ghost tapping ig
  public var callbackName:String = 'opponentNoteHit'; //The name of it when it calls lua and hs
  public var notes:FlxTypedGroup<Note> = new FlxTypedGroup<Note>(); //The notes assigned to this strumline
  public var alphaStrum(default, set):Float = 1; //The alpha for the whole strum
  public var visibleStrum(default, set):Bool = true; //The visibility of the whole strum
  public var noteTexture:String = null; //texture of the notes of this strum (null is disabled, only works if the notetype is '')
  public var comboGroup:RatingGroup; //Manages the comboGroup of this strumline
  var widthBased:Bool; //basically playerStrums and opponentStrums

  // Less laggy controls
	var keysArray:Array<String> = ['note_left', 'note_down', 'note_up', 'note_right'];

	//Achievement shit
	public var keysPressed:Array<Int> = [];

  override public function new(X:Float, Y:Float, ?char:Character=null, ?spawnStrum:Bool=true, ?tex:String='')
  {
    super(X,Y);
    if (char != null) characters.push(char);
    if (characters != null) curCharacters = characters;
    FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
    FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
    PlayState.instance.strumLines.add(this);
    this.camera = PlayState.instance.camHUD;
    size = 0.7;
    widthBased = !spawnStrum;
    comboGroup = new RatingGroup();
    comboGroup.camera = this.camera;
    FlxG.state.add(comboGroup);
    if (!spawnStrum) return;
		for (i in 0...4)
		{
			var babyArrow:StrumNote = new StrumNote(0, 50, i, 0);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			add(babyArrow);
			babyArrow.setStrumPos();

      var animPrefix = PlayState.instance.strumDfltPrefix[i];
      var event:StrumCreationEvent = new StrumCreationEvent(babyArrow, 0, i, animPrefix);
			event = PlayState.instance.scripts.event('onStrumCreation', event);
		}
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
    {
      members[i].size = value;
      if (widthBased) members[i].playerPosition(); else members[i].setStrumPos();
    }
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

  function set_alphaStrum(value:Float)
  {
    alphaStrum = value;
    for (i in 0...members.length)
      members[i].alpha = value;

    return value;
  }

  function set_visibleStrum(value:Bool)
  {
    visibleStrum = value;
    for (i in 0...members.length)
      members[i].visible = value;

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
    
        event = new NoteHitEvent(false, !note.isSustainNote, !note.isSustainNote, true, note, this.characters, true, note.noteType, note.animSuffix, "",  "", note.noteData, daRating.score, daRating.ratingMod, 0.023, daRating.name, daRating.noteSplash, 0.5, ClientPrefs.data.antialiasing, 0.7, ClientPrefs.data.antialiasing, false);
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
        if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) game.callOnHScript(callbackName, [note, daRating]);
        if(!note.isSustainNote) game.invalidateNote(note);

        game.vocals.volume = 1;
    
        if (!note.isSustainNote)
        {
          if (event.countAsCombo)game.combo++;
          if(game.combo > 9999) game.combo = 9999;
          if(event.countScore) game.popUpScore(note, event, this);
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
        if(!note.isSustainNote && useRating.noteSplash && this.isPlayer && event.showSplash) 
          if (event.note.__strum != null && event.note.splash != null)
            PlayState.instance.splashHandler.showSplash(event.note.splash, event.note);
          else
          {if (!note.noteSplashData.disabled) game.spawnNoteSplashOnNote(note, this);}
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

  public function charDance(char:Character):Void
	{
		var anim:String = char.getAnimationName();
		if(char.holdTimer > Conductor.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.sound.music.pitch #end) * char.singDuration && anim.startsWith('sing') && !anim.endsWith('miss'))
			char.dance();
	}

  private function onKeyRelease(event:KeyboardEvent):Void
    {
      var eventKey:FlxKey = event.keyCode;
      var key:Int = getKeyFromEvent(keysArray, eventKey);
      if(!Controls.instance.controllerMode && key > -1) keyReleased(key);
    }
  
    private function keyReleased(key:Int)
    {
      if(this.cpu || !PlayState.instance.startedCountdown || PlayState.instance.paused || key < 0 || key >= this.length) return;
  
      var ret:Dynamic = PlayState.instance.callOnScripts('onKeyReleasePre', [key]);
      if(ret == LuaUtils.Function_Stop) return;
  
      var spr:StrumNote = this.members[key];
      if(spr != null)
      {
        spr.playAnim('static');
        spr.resetAnim = 0;
      }
      PlayState.instance.callOnScripts('onKeyRelease', [key]);
    }
  
    public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
    {
      if(key != NONE)
      {
        for (i in 0...arr.length)
        {
          var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
          for (noteKey in note)
            if(key == noteKey)
              return i;
        }
      }
      return -1;
    }
  
    // Hold notes
    private function keysCheck():Void
    {
      // HOLDING
      var holdArray:Array<Bool> = [];
      var pressArray:Array<Bool> = [];
      var releaseArray:Array<Bool> = [];
      for (key in keysArray)
      {
        holdArray.push(Controls.instance.pressed(key));
        pressArray.push(Controls.instance.justPressed(key));
        releaseArray.push(Controls.instance.justReleased(key));
      }
  
      // TO DO: Find a better way to handle controller inputs, this should work for now
      if(Controls.instance.controllerMode && pressArray.contains(true))
        for (i in 0...pressArray.length)
          if(pressArray[i])
            keyPressed(i);
  
      if (PlayState.instance.startedCountdown && !PlayState.instance.inCutscene && !curCharacters[0].stunned && PlayState.instance.generatedMusic)
      {
        if (PlayState.instance.notes.length > 0) {
          for (n in PlayState.instance.notes) { // I can't do a filter here, that's kinda awesome
            var canHit:Bool = (n != null && n.canBeHit && !n.tooLate && !n.wasGoodHit && !n.blockHit);
  
            if (ClientPrefs.data.guitarHeroSustains)
              canHit = canHit && n.parent != null && n.parent.wasGoodHit;
  
            if (canHit && n.isSustainNote) {
              var released:Bool = !holdArray[n.noteData];
  
              if (!released)
                hit(n);
            }
          }
        }
  
        if (!holdArray.contains(true) || PlayState.instance.endingSong)
          for (char in curCharacters)
          charDance(char);
  
        #if ACHIEVEMENTS_ALLOWED
        else PlayState.instance.checkForAchievement(['oversinging']);
        #end
      }
  
      // TO DO: Find a better way to handle controller inputs, this should work for now
      if((Controls.instance.controllerMode) && releaseArray.contains(true))
        for (i in 0...releaseArray.length)
          if(releaseArray[i])
            keyReleased(i);
    }

    private function onKeyPress(event:KeyboardEvent):Void
      {
        var eventKey:FlxKey = event.keyCode;
        var key:Int = getKeyFromEvent(keysArray, eventKey);
    
        if (!Controls.instance.controllerMode)
        {
          #if debug
          //Prevents crash specifically on debug without needing to try catch shit
          @:privateAccess if (!FlxG.keys._keyListMap.exists(eventKey)) return;
          #end
    
          if(FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
        }
      }
    
      private function keyPressed(key:Int)
      {
        if(this.cpu || PlayState.instance.paused || PlayState.instance.inCutscene || key < 0 || key >= this.length || !PlayState.instance.generatedMusic || PlayState.instance.endingSong || curCharacters[0].stunned) return;
    
        var ret:Dynamic = PlayState.instance.callOnScripts('onKeyPressPre', [key]);
        if(ret == LuaUtils.Function_Stop) return;
    
        // more accurate hit time for the ratings?
        var lastTime:Float = Conductor.songPosition;
        if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
    
        // obtain notes that the player can hit
        var plrInputNotes:Array<Note> = PlayState.instance.notes.members.filter(function(n:Note):Bool {
          var canHit:Bool = n != null && n.canBeHit && !n.tooLate && !n.wasGoodHit && !n.blockHit;
          return canHit && !n.isSustainNote && n.noteData == key;
        });
        plrInputNotes.sort(PlayState.sortHitNotes);
    
        if (plrInputNotes.length != 0) { // slightly faster than doing `> 0` lol
          var funnyNote:Note = plrInputNotes[0]; // front note
    
          if (plrInputNotes.length > 1) {
            var doubleNote:Note = plrInputNotes[1];
    
            if (doubleNote.noteData == funnyNote.noteData) {
              // if the note has a 0ms distance (is on top of the current note), kill it
              if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0)
                PlayState.instance.invalidateNote(doubleNote);
              else if (doubleNote.strumTime < funnyNote.strumTime)
              {
                // replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
                funnyNote = doubleNote;
              }
            }
          }
          hit(funnyNote);
        }
        else
        {
          if (ClientPrefs.data.ghostTapping)
            PlayState.instance.callOnScripts('onGhostTap', [key]);
          else
            missPressFunction(key);
        }
    
        // Needed for the  "Just the Two of Us" achievement.
        //									- Shadow Mario
        if(!keysPressed.contains(key)) keysPressed.push(key);
    
        //more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
        Conductor.songPosition = lastTime;
    
        var spr:StrumNote = this.members[key];
        if(spr != null && spr.animation.curAnim.name != 'confirm')
        {
          spr.playAnim('pressed');
          spr.resetAnim = 0;
        }
        PlayState.instance.callOnScripts('onKeyPress', [key]);
      }

  var notesToCheck:FlxTypedGroup<Note> = new FlxTypedGroup<Note>();
  public function updateStrum()
  {
    if(this.members.length > 0) checkNotes();

    if(!this.cpu && this.isPlayer)
      keysCheck();
    else
      for (char in curCharacters)
      charDance(char);
  }

  function checkNotes()
  {
    if(!PlayState.instance.inCutscene)
			{
				if(notes.length > 0)
				{
					if(PlayState.instance.startedCountdown)
					{
						var fakeCrochet = (60 / PlayState.SONG.bpm) * 1000;
						notes.forEachAlive(function(daNote:Note)
						{
              var result:Dynamic = PlayState.instance.callOnHScript('onNoteUpdate', [daNote, this]);

              if (noteTexture != null && daNote.texture == '')
                if (daNote.texture != noteTexture) daNote.texture = noteTexture;
              daNote.camera = this.camera;
							var strum:StrumNote = this.members[daNote.noteData];
							daNote.followStrumNote(strum, fakeCrochet, PlayState.instance.songSpeed / PlayState.instance.playbackRate);

							if(this.isPlayer)
							{
								if(this.cpu && !daNote.blockHit && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition))
									this.hit(daNote);
							}
							else if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
								this.hit(daNote);

							if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

							// Kill extremely late notes and cause misses
							if (Conductor.songPosition - daNote.strumTime > PlayState.instance.noteKillOffset)
							{
								if (this.isPlayer && !this.cpu && !daNote.ignoreNote && !PlayState.instance.endingSong && (daNote.tooLate || !daNote.wasGoodHit))
									missFunction(daNote);

								daNote.active = daNote.visible = false;
								PlayState.instance.invalidateNote(daNote);
							}

              if (PlayState.instance.modManager.isActive)
              {
                var visPos = -((Conductor.visualPosition - daNote.visualTime) * PlayState.instance.songSpeed);
                var pN:Int = daNote.mustPress ? 0 : 1;
                var pos = PlayState.instance.modManager.getPos(daNote.strumTime, visPos,
                daNote.strumTime - Conductor.songPosition, PlayState.instance.dbeatPublic, daNote.noteData, pN, daNote, [], daNote.vec3Cache);
                PlayState.instance.modManager.updateObject(PlayState.instance.dbeatPublic, daNote, pos, pN);
  
                if (daNote.isSustainNote)
                {
                  var futureSongPos = Conductor.visualPosition + (Conductor.stepCrochet * 0.001);
                  var diff = daNote.visualTime - futureSongPos;
                  var vDiff = -((futureSongPos - daNote.visualTime) * PlayState.instance.songSpeed);
        
                  var nextPos = PlayState.instance.modManager.getPos(daNote.strumTime, vDiff, diff, Conductor.getStep(futureSongPos) / 4, daNote.noteData, pN, daNote, [], daNote.vec3Cache);
                  nextPos.x += daNote.offsetX;
                  nextPos.y += daNote.offsetY;
                  var diffX = (nextPos.x - pos.x);
                  var diffY = (nextPos.y - pos.y);
                  var rad = Math.atan2(diffY, diffX);
                  var deg = rad * (180 / Math.PI);
                  daNote.mAngle = deg;
                }
              }
						});
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
  }

  public function destroyStrums()
  {
    FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
    destroy();
  }
}