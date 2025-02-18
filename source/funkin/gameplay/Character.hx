package funkin.gameplay;

import funkin.graphics.AtlasType;
import funkin.graphics.SkinnableSprite;

class Character extends FlxSprite {
    /**
     * Returns fallback character data in the case that
     * loading it from JSON fails.
     */
    public static function getFallbackData():CharacterData {
        return {
            atlasType: SPARROW,
            atlasPath: "bf/normal",
            
            healthIcon: {
                isPixel: false,
                scale: 1,
                flip: {x: false, y: false},
                offset: {x: 0, y: 0},
                color: "#FFFFFF"
            },
            animations: []
        };
    }

    /**
     * Returns the character data for a given character.
     * 
     * @param  charID  The name of the character to fetch data from.
     */
    public static function loadData(charID:String):CharacterData {
        var jsonPath:String = Paths.json('gameplay/characters/${charID}/conf');
        if(FlxG.assets.exists(jsonPath)) {
            final parser = new JsonParser<CharacterData>();
            parser.ignoreUnknownVariables = true;
            return parser.fromJson(FlxG.assets.getText(jsonPath));
        } else {
            Logs.error('Character config for ${charID} doesn\'t exist, loading default!');
            jsonPath = Paths.json('gameplay/characters/${Constants.DEFAULT_CHARACTER}/conf');

            if(FlxG.assets.exists(jsonPath)) {
                final parser = new JsonParser<CharacterData>();
                parser.ignoreUnknownVariables = true;
                return parser.fromJson(FlxG.assets.getText(jsonPath));
            }
        }
        return getFallbackData();
    }
}

@:structInit
class CharacterData {
    @:optional
    public var healthIcon:HealthIconData;

    public var atlasType:AtlasType;
    public var atlasPath:String;

    @:optional
    @:default({x: 0, y: 0})
    public var gridSize:PointData<Float> = {x: 0, y: 0};
    
    public var animations:Array<AnimationData>;
    
    @:optional
    @:default({x: 0, y: 0})
    public var position:PointData<Float> = {x: 0, y: 0};
    
    @:optional
    @:default({x: 0, y: 0})
    public var camera:PointData<Float> = {x: 0, y: 0};

    @:optional
    @:default(1)
    public var scale:Float = 1;

    @:optional
    @:default({x: false, y: false})
    public var flip:PointData<Bool> = {x: false, y: false};

    @:optional
    @:default(false)
    public var isPlayer:Bool = false;

    @:optional
    @:default(true)
    public var antialiasing:Bool = true;

    @:optional
    @:default(4)
    public var singDuration:Float = 4;

    @:optional
    @:default(["idle"])
    public var danceSteps:Array<String> = ["idle"];
}

@:structInit
class HealthIconData {
	@:optional
	@:default(false)
	public var isPixel:Bool = false;

	@:optional
	@:default(1)
	public var scale:Float = 1;

	@:optional
	@:default({x: false, y: false})
	public var flip:PointData<Bool> = {x: false, y: false};

	@:optional
	@:default({x: 0, y: 0})
	public var offset:PointData<Float> = {x: 0, y: 0};

	@:optional
	@:default("#FFFFFF")
	public var color:String = "#FFFFFF";
}