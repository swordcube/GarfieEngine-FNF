package funkin.gameplay.notes;

import flixel.tweens.FlxTween;
import funkin.gameplay.notes.HoldTrail;

class StrumLine extends FlxSpriteGroup {
    public var strums:FlxTypedSpriteGroup<Strum>;
    public var notes:FlxTypedSpriteGroup<Note>;
    public var holdTrails:FlxTypedSpriteGroup<HoldTrail>;
    public var splashes:FlxTypedSpriteGroup<NoteSplash>;

    public var downscroll:Bool = false;
    public var botplay:Bool = false;
    
    public var scrollSpeed:Float = 1;
    public var playField:PlayField;
    
    public function new(x:Float = 0, y:Float = 0, downscroll:Bool, botplay:Bool, skin:String) {
        super(x, y);

        this.downscroll = downscroll;
        this.botplay = botplay;

        strums = new FlxTypedSpriteGroup<Strum>();
        add(strums);

        holdTrails = new FlxTypedSpriteGroup<HoldTrail>();
        add(holdTrails);
        
        notes = new FlxTypedSpriteGroup<Note>();
        add(notes);

        splashes = new FlxTypedSpriteGroup<NoteSplash>();
        add(splashes);

        for(i in 0...Constants.KEY_COUNT) {
            final strum:Strum = new Strum((i - (Constants.KEY_COUNT * 0.5)) * Constants.STRUM_SPACING, 0, i, skin);
            strum.strumLine = this;
            strums.add(strum);
        }
        for(i in 0...48) {
            final note:Note = new Note().setup(this, 0, i % Constants.KEY_COUNT, 0, "Default", strums.members[i % Constants.KEY_COUNT].skin);
            note.kill();
            notes.add(note);
        }
        for(i in 0...8) {
            final splash:NoteSplash = new NoteSplash().setup(this, i % Constants.KEY_COUNT, strums.members[i % Constants.KEY_COUNT].skin);
            splash.kill();
            splashes.add(splash);
        }
        @:privateAccess {
            // force this splash to draw to force it
            // into vram, since flixel only puts the shit in vram when the sprite is drawn
            // instead of immediately as the graphic is loaded
            final cacheSplash:NoteSplash = splashes.members[0];
            cacheSplash.alpha = 0.001;
            cacheSplash.drawComplex(FlxG.camera);
        }
    }

    public function showSplash(direction:Int):Void {
        final strum:Strum = strums.members[direction];
        final splash:NoteSplash = splashes.recycle(_splashFactory).setup(this, direction, strum.skin);
        splash.setPosition(strum.x - ((splash.width - strum.width) * 0.5), strum.y - ((splash.height - strum.height) * 0.5));
    }

    public function processNote(note:Note):Void {
        final strum:Strum = strums.members[note.direction];
        final attachedConductor:Conductor = playField?.attachedConductor ?? Conductor.instance;
        
        final absSpeed:Float = Math.abs(scrollSpeed);
        final scrollMult:Float = ((downscroll) ? -1 : 1) * ((scrollSpeed < 0) ? -1 : 1);

        note.x = strum.x + note.offsetX;
        
        note.holdTrail.x = note.x + note.holdTrail.offsetX + ((note.width - note.holdTrail.width) * 0.5);
        
        note.holdTrail.strip.x = note.holdTrail.x;
        note.holdTrail.tail.x = note.holdTrail.x;
        
        note.holdTrail.strip.flipY = (absSpeed * scrollMult) < 0;
        
        if(note.wasHit && !note.wasMissed) {
            note.y = strum.y + note.offsetY;
            
            final sexo:Float = Constants.PIXELS_PER_MS * (attachedConductor.playhead - note.time) * absSpeed;
            final calcHeight:Float = Math.max((Constants.PIXELS_PER_MS * note.length * absSpeed) - sexo, 0);
            
            note.holdTrail.y = strum.y + note.holdTrail.offsetY + (strum.height * 0.5);
            note.holdTrail.height = calcHeight;

            if(playField != null && playField.playerStrumLine == this && note.scoreSteps.length != 0) {
                while(note.curScoreStep < note.scoreSteps.length && attachedConductor.time >= note.scoreSteps[note.curScoreStep].time) {
                    if(note.hitEvent.gainHealthFromHolds)
                        playField.stats.health += note.hitEvent.healthGain;

                    if(note.hitEvent.gainScoreFromHolds)
                        playField.stats.score += note.scoreSteps[note.curScoreStep++].score;

                    if(playField.hud != null) {
                        playField.hud.updateHealthBar();
                        playField.hud.updatePlayerStats();
                    }
                }
            }

        } else {
            note.y = strum.y + note.offsetY + (Constants.PIXELS_PER_MS * (note.time - attachedConductor.playhead) * absSpeed * scrollMult);
            
            final calcHeight:Float = (Constants.PIXELS_PER_MS * note.length * absSpeed);
            note.holdTrail.y = note.y + note.holdTrail.offsetY + (strum.height * 0.5);
            
            note.holdTrail.height = calcHeight; 
        }
        if(botplay) {
            // use playhead instead of time, otherwise automatic note hitting becomes slightly delayed sometimes
            if(!note.wasHit && !note.wasMissed && note.time <= attachedConductor.playhead)
                playField.hitNote(note);
            
            if(note.wasHit && note.length > 0 && note.time <= attachedConductor.time - note.length) {
                // kill the note if it is a hold note and it was
                // held the entire way through
                playField.killNote(note);
            }
            if(note.time <= attachedConductor.time - ((350 / scrollSpeed) + note.length)) {
                // kill the note if it goes off-screen, regardless of if it was missed or not
                // nobody will know trust 🤫
                playField.killNote(note);
            }
        } else {
            if(!note.wasHit && !note.wasMissed && note.time <= attachedConductor.time - Options.hitWindow) {
                // miss the note if it's out of range to be hit
                playField.missNote(note);
            }
            if(note.wasHit && note.length > 0 && note.time <= attachedConductor.time - note.length) {
                // kill the note if it is a hold note and it was
                // held the entire way through
                playField.killNote(note);
            }
            if(note.wasMissed && note.time <= attachedConductor.time - ((350 / scrollSpeed) + note.length)) {
                // kill the note if it goes off-screen (only if it was missed)
                playField.killNote(note);
            }
        }
    }

    override function update(elapsed:Float) {
        notes.forEachAlive(processNote);
        super.update(elapsed);
    }

    private function _splashFactory():NoteSplash {
        return new NoteSplash();
    }
}