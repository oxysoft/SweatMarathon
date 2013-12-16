package ;
import entities.Player;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
import flixel.tile.FlxTilemap;
import flixel.util.FlxRandom;
import motion.Actuate;

/**
 * ...
 * @author oxysoft
 */
class Minimap extends FlxSprite {

	var tick:Int = 0;
	
	var hud:HUD;
	var level:TiledLevel;
	var player:Player;
	var w:Int = -1;
	var h:Int = -1;
	
	var playerSprite:FlxSprite;
	var cpRegionSprite:FlxSprite;
	
	public function new(hud:HUD, level:TiledLevel, player:Player, x:Int, y:Int) {
		super(x, y);
		this.makeGraphic(level.width, level.height, 0xFFFF0000);
		
		this.hud = hud;
		this.level = level;
		this.player = player;
		this.w = level.width;
		this.h = level.height;

		for (i in 0...w) {
			for (j in 0...h) {
				var uc:UInt = 0;
				var t = cast(level.nonCollidableTilemaps.members[0], FlxTilemap).getTile(i, j);
				var r = FlxRandom.intRanged(0, 2);

				
				if (t == 1 || t == 2 || t == 3) uc = r == 0 ? 0xFF5B4237 : r == 1 ? 0xFF664A3D : r == 2 ? 0xFF7F5D4C : 0;
				else if (t == 4 || t == 5 || t == 6) uc = r == 0 ? 0xFF56A028: r == 1 ? 0xFF66C030: r == 2 ? 0xFF71D334: 0;
				//else trace("Unhandled minimap tile: " + t);
				
				this.getFlxFrameBitmapData().setPixel(i, j, uc);
			}
		}
		
		playerSprite = new FlxSprite(this.x + (player.x / 16), this.y + (player.y / 16));
		playerSprite.makeGraphic(3, 3, 0xffffff00);
		playerSprite.scrollFactor.set(0, 0);
		
		cpRegionSprite = new FlxSprite(this.x + ((player.x + 5) / 16), this.y + (player.y / 16));
		cpRegionSprite.scrollFactor.set(0, 0);
		cpRegionSprite.alpha = 0;
	}
	
	public override function update():Void {
		playerSprite.x = x + (player.x / 16);
		playerSprite.y = y + (player.y / 16);
		
		var cp:Checkpoint = level.currentCheckpoint;
		if (cp != null) {
			if (cp.isOver() || cp.isReached(player)) {
				cpRegionSprite.alpha = 0;
				cpRegionSprite.visible = false;
			} else {
				cpRegionSprite.x = x + (cp.x / 16);
				cpRegionSprite.y = y + (cp.y / 16);
				cpRegionSprite.alpha = 0.7;
				//Actuate.tween(cpRegionSprite, 0.3, { alpha: 0.8 } );
				cpRegionSprite.visible = true;
				cpRegionSprite.makeGraphic(Std.int(Math.ceil(cp.width / 16)), Std.int(Math.ceil(cp.height / 16)), 0xFF00FFFF); 
			}
		} else {
			cpRegionSprite.alpha = 0;
		}
		
		tick++;
	}
	
	public override function draw():Void {
		super.draw();
		
		cpRegionSprite.draw();
		playerSprite.draw();
	}

}