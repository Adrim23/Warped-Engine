package warped.substates;

import objects.HealthIcon;

enum ChosenCharacter {
    BOYFRIEND;
    GIRLFRIEND;
    DAD;
}

class CustomCharSubstate extends MusicBeatSubstate
{
    var chars:Array<String> = [];

    private var grpChars:FlxTypedGroup<Alphabet>;
	private var iconCharArray:Array<HealthIcon> = [];
    private static var curSelectedChars:Int = 0;
    var lerpSelectedChars:Float = 0;
    var chosenChar:ChosenCharacter = BOYFRIEND;

    var bgSub:FlxSprite;
    var charTxt:FlxText;
    var gfTxt:FlxText;
    var dadTxt:FlxText;

    override function create(){
        bgSub = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgSub.alpha = 0.5;
		add(bgSub);

        charTxt = new FlxText(0, 5, 0, "", 32);
		charTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
        add(charTxt);
        
        gfTxt = new FlxText(0, 40, 0, "", 32);
		gfTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
        add(gfTxt);
        
        dadTxt = new FlxText(0, 75, 0, "", 32);
		dadTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
        add(dadTxt);

        daTextColors(BOYFRIEND);

        grpChars = new FlxTypedGroup<Alphabet>();
		add(grpChars);

        chars.push('default');

        for (i in FileSystem.readDirectory('custom/characters'))
            {
                if (FileSystem.isDirectory('custom/characters'+'/'+i))
                chars.push(i);
            }
        
        for (b in 0...chars.length)
        {
                var songText:Alphabet = new Alphabet(90, 320, chars[b], true);
                songText.targetY = b;
                grpChars.add(songText);
    
                songText.scaleX = Math.min(1, 980 / songText.width);
                songText.snapToPosition();

                var icon:HealthIcon = new HealthIcon((chars[b] == 'default') ? 'face' : chars[b], true, true, (chars[b] == 'default') ? false : true);
                icon.sprTracker = songText;
    
                
                // too laggy with a lot of songs, so i had to recode the logic for it
                songText.visible = songText.active = songText.isMenuItem = false;
                icon.visible = icon.active = false;
    
                // using a FlxGroup is too much fuss!
                iconCharArray.push(icon);
                add(icon);
    
                // songText.x += 40;
                // DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
                // songText.screenCenter(X);
        }

        lerpSelectedChars = curSelectedChars;

        if (chars != null || chars != [])
        changeSelection();
        else
        {
            close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
        }

        #if mobile
		addTouchPad('UP_DOWN', 'A_B');
		addTouchPadCamera();
		#end

        super.create();
    }

    function changeSelection(change:Int = 0, playSound:Bool = true)
        {
            if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
            curSelectedChars += change;
            if(curSelectedChars >= chars.length) curSelectedChars = 0;
            if(curSelectedChars < 0) curSelectedChars = chars.length - 1;
            var bullShit:Int = 0;
    
            for (i in 0...iconCharArray.length)
            {
                iconCharArray[i].alpha = 0.6;
            }
    
            iconCharArray[curSelectedChars].alpha = 1;
    
            for (item in grpChars.members)
            {
                bullShit++;
                item.alpha = 0.6;
                if (item.targetY == curSelectedChars)
                    item.alpha = 1;
            }
        }

        var _drawDistanceChars:Int = 4;
        var _lastVisiblesChars:Array<Int> = [];
        public function updateTexts(elapsed:Float = 0.0)
            {
                lerpSelectedChars = FlxMath.lerp(curSelectedChars, lerpSelectedChars, Math.exp(-elapsed * 9.6));
                for (i in _lastVisiblesChars)
                {
                    grpChars.members[i].visible = grpChars.members[i].active = false;
                    iconCharArray[i].visible = iconCharArray[i].active = false;
                }
                _lastVisiblesChars = [];
        
                var min:Int = Math.round(Math.max(0, Math.min(chars.length, lerpSelectedChars - _drawDistanceChars)));
                var max:Int = Math.round(Math.max(0, Math.min(chars.length, lerpSelectedChars + _drawDistanceChars)));
                for (i in min...max)
                {
                    var item:Alphabet = grpChars.members[i];
                    item.visible = item.active = true;
                    item.x = ((item.targetY - lerpSelectedChars) * item.distancePerItem.x) + item.startPosition.x;
                    item.y = ((item.targetY - lerpSelectedChars) * 1.3 * item.distancePerItem.y) + item.startPosition.y;
        
                    var icon:HealthIcon = iconCharArray[i];
                    icon.visible = icon.active = true;
                    _lastVisiblesChars.push(i);
                }
                charTxt.text = 'Current Player: ' + ClientPrefs.data.customChar;
                gfTxt.text = 'Current Girlfriend: ' + ClientPrefs.data.customGF;
                dadTxt.text = 'Current Opponent: ' + ClientPrefs.data.customDAD;
            }

    override function update(elapsed:Float){
        if (controls.BACK #if mobile || touchPad.buttonB.justPressed #end) {
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
        if (controls.ACCEPT #if mobile || touchPad.buttonA.justPressed #end)
        {
            switch(chosenChar)
            {
                case BOYFRIEND:
                    ClientPrefs.data.customChar = chars[curSelectedChars];
                case GIRLFRIEND:
                    ClientPrefs.data.customGF = chars[curSelectedChars];
                case DAD:
                    ClientPrefs.data.customDAD = chars[curSelectedChars];
                default:
                    ClientPrefs.data.customChar = chars[curSelectedChars];
            }
            
            ClientPrefs.saveSettings();
        }

            if (controls.UI_UP_P #if mobile || touchPad.buttonUp.justPressed #end)
                changeSelection(-1);
            if (controls.UI_DOWN_P #if mobile || touchPad.buttonDown.justPressed #end)
                changeSelection(1);

        if (FlxG.keys.justPressed.CONTROL)
        {
            switch(chosenChar)
            {
                case BOYFRIEND:
                    chosenChar = GIRLFRIEND;
                    daTextColors(GIRLFRIEND);
                
                case GIRLFRIEND:
                    chosenChar = DAD;
                    daTextColors(DAD);
                
                case DAD:
                    chosenChar = BOYFRIEND;
                    daTextColors(BOYFRIEND);
            }
        }
            
        updateTexts(elapsed);
        super.update(elapsed);
    }

    function daTextColors(who:ChosenCharacter)
    {
        charTxt.color = 0xFFFFFFFF;
        gfTxt.color = 0xFFFFFFFF;
        dadTxt.color = 0xFFFFFFFF;

        switch(who)
        {
            case BOYFRIEND:
                charTxt.color = 0xFF00FF00;
            case GIRLFRIEND:
                gfTxt.color = 0xFF00FF00;
            case DAD:
                dadTxt.color = 0xFF00FF00;
        }
    }
}