package funkin.backend.assets;

import flixel.graphics.frames.FlxFramesCollection;
import funkin.gameplay.UISkin.UISkinData;
import openfl.media.Sound;
import openfl.utils.AssetCache as OpenFLAssetCache;

class Cache {
    public static var atlasCache(default, never):Map<String, FlxFramesCollection> = [];
    public static var uiSkinCache(default, never):Map<String, UISkinData> = [];

    public static function clearAll():Void {
        // Clear graphics
        @:privateAccess {
            for(key => graph in FlxG.bitmap._cache) {
                // I check for destroyOnNoUse because if i don't, interacting
                // with some HaxeUI elements will try to access an invalid graphic
                // and immediately crash the game
                if(graph != null && !graph.persist && graph.destroyOnNoUse) {
                    if(graph.bitmap.__texture != null)
                        graph.bitmap.__texture.dispose();

                    graph.bitmap.disposeImage();
                    graph.bitmap.dispose();
                    
                    graph.destroy();

                    FlxG.bitmap.removeKey(key);
                    OpenFLAssets.cache.removeBitmapData(key);
                }
            }
        }
        // Clear fonts
        @:privateAccess {
            final cache:OpenFLAssetCache = (OpenFLAssets.cache is OpenFLAssetCache) ? cast OpenFLAssets.cache : null;
            if(cache != null) {
                for(key in cache.font.keys())
                    cache.removeFont(key);
            }
        }
        // Clear sounds
        @:privateAccess {
            final cache:OpenFLAssetCache = (OpenFLAssets.cache is OpenFLAssetCache) ? cast OpenFLAssets.cache : null;
            if(cache != null) {
                for(key in cache.sound.keys()) {
                    final snd:Sound = cache.sound.get(key);
                    if(FlxG.sound.music != null && FlxG.sound.music._sound != snd)
                        snd.close();

                    cache.removeSound(key);
                }
            }
        }
        for(atlas in atlasCache) {
            if(atlas.parent != null) {
                atlas.parent.persist = false;
                atlas.parent.destroyOnNoUse = true;
                atlas.parent.decrementUseCount();
            }
            atlas.destroy();
        }
        atlasCache.clear();
        uiSkinCache.clear();
    }
}