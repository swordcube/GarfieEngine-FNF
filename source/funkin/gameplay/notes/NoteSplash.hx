package funkin.gameplay.notes;

import flixel.util.FlxColor;

import funkin.gameplay.UISkin;
import funkin.graphics.SkinnableSprite;

import funkin.backend.scripting.events.notes.*;

class NoteSplash extends SkinnableSprite {
    public var strumLine:StrumLine;
    public var direction(default, set):Int;
    public var splashCount(default, null):Int;

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
        animation.onFinish.add((_) -> kill());
    }

    public function setup(strumLine:StrumLine, direction:Int, skin:String):NoteSplash {
        loadSkin(skin);
        scale.set(_skinData.scale, _skinData.scale);

        this.strumLine = strumLine;
        this.direction = direction % Constants.KEY_COUNT;

        // reset a bunch of properties the programmer
        // could end up changing via note types

        // which i underestimated when writing this comment
        // holy SHIT there's a lot to account for
        angle = 0;
        alpha = _skinData.alpha;
        shader = null;
        visible = true;
        frameOffset.set();
        color = FlxColor.WHITE;

        colorTransform.redOffset = colorTransform.greenOffset = colorTransform.blueOffset = 0;
        colorTransform.redMultiplier = colorTransform.greenMultiplier = colorTransform.blueMultiplier = 1;

        return this;
    }

    override function loadSkin(newSkin:String):Void {
        if(_skin == newSkin)
            return;

        final json:UISkinData = UISkin.get(newSkin);
        loadSkinComplex(newSkin, json.splash, 'gameplay/uiskins/${newSkin}');

        splashCount = Lambda.count(json.splash.animation);
        direction = direction; // force animation update
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
        // if(strumLine != null) {
        //     final strum:Strum = strumLine.strums.members[direction];
        //     setPosition(strum.x - (width * 0.5), strum.y - (height * 0.5));
        // }
    }
    
    //----------- [ Private API ] -----------//

    @:noCompletion
    private function set_direction(newDirection:Int):Int {
        direction = newDirection;
        animation.play('${Constants.NOTE_DIRECTIONS[direction]} splash${FlxG.random.int(1, splashCount)}');

        centerOrigin();        
        updateHitbox();
        centerOffsets();

        return direction;
    }
}