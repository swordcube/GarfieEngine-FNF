package funkin.backend;

import flixel.input.keyboard.FlxKey;

import funkin.backend.native.NativeAPI;
import funkin.graphics.RatioScaleModeEx;

import funkin.utilities.FlxUtil;
import funkin.utilities.AudioSwitchFix;

import funkin.states.PlayState;
import funkin.states.menus.FreeplayState;

class InitState extends FlxState {
    private static var _lastState:Class<FlxState>;

    override function create() {
        super.create();

        AudioSwitchFix.init();
        FlxG.fixedTimestep = false;

        #if windows
        NativeAPI.setDarkMode(FlxG.stage.window.title, true);

        // Hacky fix for Windows 10 not applying dark mode correctly
        // Doesn't happen on Windows 11, would be ideal to check for Windows 11
        // but i don't know how to do that
        FlxG.stage.window.borderless = !FlxG.stage.window.borderless;
        FlxG.stage.window.borderless = !FlxG.stage.window.borderless;
        #end

        Logs.init();
        Paths.initAssetSystem();

        Controls.init();

        ModManager.scanMods();
        ModManager.registerMods();

        FlxUtil.init();
        FlxG.scaleMode = new RatioScaleModeEx();

        FlxG.signals.preStateCreate.add((newState:FlxState) -> {
            if(Type.getClass(newState) != _lastState) {
                Cache.clearAll();
            }
            _lastState = Type.getClass(newState);
        });
        Cursor.init();
        
        Conductor.instance = new Conductor();
        FlxG.plugins.addPlugin(Conductor.instance);

        FlxG.mouse.visible = false;
        FlxSprite.defaultAntialiasing = true;

        final args = Sys.args();
        if(args.contains("--song")) {
            FlxG.switchState(PlayState.new.bind({
                song: args[args.indexOf("--song") + 1],
                difficulty: args[args.indexOf("--diff") + 1]
            }));    
        } else {
            FlxG.switchState(FreeplayState.new);
        }
    }
}