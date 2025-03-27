![DAABBCC](/.github/platformer.png?raw=true)

Example platformer project for daabbcc.  
Requires Defold >= 1.9.9

Play it here: https://selimanac.github.io/defold-daabbcc3d-example-charming-kitchen/

Highly recommend controller. Tip: Keep holding the jump button while sliding to jump left or right, and don’t let it go if you want to chain jumps.

### Debug View
- Add [debug.factory](https://github.com/selimanac/defold-daabbcc-example-platformer/blob/cb326b49705a60b2228fdbb491c30cdae2cd8cfe/components/factories/debug.factory) to [game.collection](https://github.com/selimanac/defold-daabbcc-example-platformer/blob/cb326b49705a60b2228fdbb491c30cdae2cd8cfe/scenes/game.collection) under factories
- Set [platformer.debug](https://github.com/selimanac/defold-daabbcc-example-platformer/blob/cb326b49705a60b2228fdbb491c30cdae2cd8cfe/game.project#L59) to 1 on game.project


### Tiled Map
Map is created usinf Tiled, all Tiled files are in [assets/tiled](https://github.com/selimanac/defold-daabbcc-example-platformer/tree/cb326b49705a60b2228fdbb491c30cdae2cd8cfe/assets/tiled) folder. [map.tmx](https://github.com/selimanac/defold-daabbcc-example-platformer/blob/cb326b49705a60b2228fdbb491c30cdae2cd8cfe/assets/tiled/map.tmx) is the main map file. You can export the map as json to data folder.

### Build
There is a simple [shell script](https://github.com/selimanac/defold-daabbcc-example-platformer/blob/cb326b49705a60b2228fdbb491c30cdae2cd8cfe/production/build.zsh) to bundle the project using [bob](https://defold.com/manuals/bob/).  

- Download latest [bob](https://github.com/defold/defold/releases) (>= 1.9.9) and put it in production folder.
- Modify the build shell script according to your needs.
- Execute shell script. Bundles will ve created under production/bundle folder

## Thanks
Special thanks to [Paweł Jarosz](https://x.com/pawel_developer) and [8BitSkull](https://x.com/8BitSkull) for their support.  

## Credits

**Assets** by _[Pixel Frog](https://x.com/PixelFrogStudio)_ - Slightly modified version of https://pixelfrog-assets.itch.io/pixel-adventure-1   
**Music** by _[MFCC](https://www.youtube.com/channel/UCQF2DyKUgg4yYo2h_f3jzcA)_ -  https://pixabay.com/music/upbeat-game-music-player-console-8bit-background-intro-theme-297305/  

**On-Screen Input** by _[Björn Ritzl](https://x.com/bjornritzl)_ - https://github.com/britzl/defold-input  
**ImGUI** by _[Björn Ritzl](https://x.com/bjornritzl)_ - https://github.com/britzl/extension-imgui/tree/master/example  
**Device** by _[Artsiom Trubchyk](https://x.com/aglitchman)_ - https://gist.github.com/aglitchman/fca1d6c4f5bad3e16033798cffea9ae1  
**DefOS** by _[Subsoap](https://x.com/Subsoap)_  -  Slightly modified(only for MacOS) version of  https://github.com/subsoap/defos   
**Water Shader**  Modified version of https://www.shadertoy.com/view/MltyRs  
**Waterfall Shader**  Modified version of https://shadered.org/view?s=6Gny24_ojD  