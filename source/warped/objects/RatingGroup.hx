package warped.objects;

import flixel.group.FlxSpriteGroup;
import backend.Conductor;
import backend.Rating;

class RatingGroup extends FlxSpriteGroup
{
    public var prefix:String = ''; //Prefix of the image
    public var postfix:String = ''; //Postfix of the image
    public var folder:String = ''; //folder of the image
    public var comboFunction:Void->Bool; //Function that plays when the score pops up, return false to cancel the normal ht counter
    public var comboOffsets:Array<Null<Float>> = []; //Set the values inside and it will automatically set the combo shit there

    public function popUp(event:NoteHitEvent, daRating:Rating)
    {
		var shouldPlay:Bool=true;
        if (comboFunction != null) shouldPlay = comboFunction();
		if (!event.showRating) return;
		if (!shouldPlay) return;
        var placement:Float = FlxG.width * 0.35;
        if (!ClientPrefs.data.comboStacking && this.members.length > 0)
		{
			for (spr in this)
			{
				if(spr == null) continue;

				remove(spr);
				spr.destroy();
			}
		}

        var daPrefix:String = prefix;
        if (folder != '' && folder != null) daPrefix = prefix+"/"+"UI";

        var rating:FlxSprite = new FlxSprite();
		rating.loadGraphic(Paths.image((PlayState.instance.comboPrefix == null) ? daPrefix +"/"+ daRating.image + postfix : PlayState.instance.comboPrefix + daRating.image + postfix));
		rating.screenCenter();
		rating.x = placement - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * PlayState.instance.playbackRate * PlayState.instance.playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * PlayState.instance.playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * PlayState.instance.playbackRate;
		rating.visible = (!ClientPrefs.data.hideHud && PlayState.instance.showRating);
		rating.x += (comboOffsets[0] == null) ? ClientPrefs.data.comboOffset[0] : comboOffsets[0];
		rating.y -= (comboOffsets[1] == null) ? ClientPrefs.data.comboOffset[1] : comboOffsets[1];
		rating.antialiasing = event.ratingAntialiasing;
		rating.alt = false;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image((PlayState.instance.comboPrefix == null) ? daPrefix +"/"+ 'combo' + postfix : PlayState.instance.comboPrefix + 'combo' + postfix));
		comboSpr.screenCenter();
		comboSpr.x = placement;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * PlayState.instance.playbackRate * PlayState.instance.playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * PlayState.instance.playbackRate;
		comboSpr.visible = (!ClientPrefs.data.hideHud && PlayState.instance.showCombo);
		comboSpr.x += (comboOffsets[0] == null) ? ClientPrefs.data.comboOffset[0] : comboOffsets[0];
		comboSpr.y -= (comboOffsets[1] == null) ? ClientPrefs.data.comboOffset[1] : comboOffsets[1];
		comboSpr.antialiasing = event.ratingAntialiasing;
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * PlayState.instance.playbackRate;
		comboSpr.alt = false;
		add(rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * event.ratingScale));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * event.ratingScale));
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * PlayState.daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * PlayState.daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (PlayState.instance.showCombo)
			add(comboSpr);

		var separatedScore:String = Std.string(PlayState.instance.combo).lpad('0', 3);
		for (i in 0...separatedScore.length)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image((PlayState.instance.comboPrefix == null) ? daPrefix +"/"+ 'num' + Std.parseInt(separatedScore.charAt(i)) + postfix + postfix : PlayState.instance.comboPrefix + 'num' + Std.parseInt(separatedScore.charAt(i)) + postfix + postfix));
			numScore.screenCenter();
			var nScore:Array<Dynamic> = [];
			nScore[0] = (comboOffsets[2] == null) ? ClientPrefs.data.comboOffset[2] : comboOffsets[2];
			nScore[1] = (comboOffsets[3] == null) ? ClientPrefs.data.comboOffset[3] : comboOffsets[3];
			numScore.x = placement + (43 * daLoop) - 90 + nScore[0];
			numScore.y += 80 - nScore[1];

			if (!PlayState.isPixelStage) numScore.setGraphicSize(Std.int(numScore.width * event.numScale));
			else numScore.setGraphicSize(Std.int(numScore.width * PlayState.daPixelZoom));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * PlayState.instance.playbackRate * PlayState.instance.playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * PlayState.instance.playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * PlayState.instance.playbackRate;
			numScore.visible = !ClientPrefs.data.hideHud;
			numScore.antialiasing = event.numAntialiasing;
			numScore.alt = false;

			//if (combo >= 10 || combo == 0)
			if(PlayState.instance.showComboNum)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / PlayState.instance.playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / PlayState.instance.playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		FlxTween.tween(rating, {alpha: 0}, 0.2 / PlayState.instance.playbackRate, {
			startDelay: Conductor.crochet * 0.001 / PlayState.instance.playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / PlayState.instance.playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / PlayState.instance.playbackRate
		});
    }
}