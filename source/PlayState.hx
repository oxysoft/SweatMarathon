package ;
import entities.Player;
import flash.geom.Point;
import flash.media.Sound;
import flixel.effects.particles.FlxTypedEmitter.FlxTypedEmitter;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxPoint;
import openfl.Assets;
import haxe.ds.ArraySort;
import flixel.FlxBasic;

/**
 * ...
 * @author oxysoft
 */
class PlayState extends FlxState {

	public var tilemap:TiledLevel;
	public var trees:FlxGroup;
	public var entities:FlxGroup;
	public var shadows:FlxGroup;
	public var checkpoints:FlxGroup;
	public var player:Player;
	public var hud:HUD;
	
	var tick:Int;
	
	public override function create():Void {
		#if !FLX_NO_DEBUG //woot
		//FlxG.sound.muted = true;
		#end
		
		//FlxG.log.redirectTraces = false;
		FlxG.cameras.bgColor = 0xff131c1b;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		//load level
		if (!Assets.exists("assets/levels/level" + Reg.currentLevel + ".tmx")) {
			FlxG.switchState(new WinState());
			this.kill();
			return;
		}
		tilemap = new TiledLevel("assets/levels/level" + Reg.currentLevel + ".tmx");
		FlxG.worldBounds.set(0, 0, tilemap.fullWidth, tilemap.fullHeight);
		
		//load entities
		trees = new FlxGroup();
		entities = new FlxGroup();
		shadows = new FlxGroup();
		checkpoints = new FlxGroup();
		tilemap.loadObjects(this);
		
		//add to scene
		add(tilemap.nonCollidableTilemaps);
		add(tilemap.collidableTilemaps);
		add(shadows);
		add(checkpoints);
		add(entities);
		add(tilemap.messages);
		add(hud);
		
		//setup camera
		FlxG.camera.follow(player, FlxCamera.STYLE_LOCKON);
		FlxG.camera.followLerp = 5;
		FlxG.camera.zoom = 2;
		//FlxG.resizeGame(cast(tilemap.width, Int), cast(tilemap.height, Int));
		
		entities.sort();
	}
	
	override public function destroy():Void {
		super.destroy();
	}

	private var lastY:Float = -1;
	private var dTick:Int = 0;
	
	override public function draw():Void {
		if (alive) {
			if (dTick % 10 == 0) fastSort(entities);
			super.draw();
			dTick++;
		}
	}
	
	public override function update():Void {
		if (this.alive) {
			super.update();
			
			FlxG.collide(tilemap.collidableTilemaps, player);
			FlxG.collide(trees, player);
			
			if (tick == 0) FlxG.sound.playMusic("assets/music/04.mp3", 0.8);
			
			tick++;
			
			if (tilemap.currentCheckpoint != null) {
				if (tilemap.currentCheckpoint.isReached(player)) {
					tilemap.startNextCheckpoint();
				}
			}
		}
	}
	
	public function isShadow(x:Float, y:Float):Bool {
		return FlxG.overlap(shadows, player);
	}
	
	public function sortMembers():Void {
		for (member in members) {
			if (Std.is(member, FlxGroup)) {
				cast(member, FlxGroup).sort();
			}
		}
	}
	
	//cocktail sort because this is faster
	public function fastSort(group:FlxGroup):Void {
		var swapped = false;
		do {
			for (i in 0...(group.members.length - 1) - 2) {
				if (Reflect.getProperty(cast(group.members[i], FlxBasic), "y") > Reflect.getProperty(cast(group.members[i + 1], FlxBasic), "y")) {
					if (Std.is(group.members[i], Player) && Std.is(group.members[i], FlxTypedEmitter)) continue; 
					var _item:FlxBasic = cast(group.members[i], FlxBasic);
					group.members[i] = group.members[i + 1];
					group.members[i + 1] = _item;
					swapped = true;
				}
			}
			if (!swapped) {
				break;
			}
			swapped = false;
			//stupid fucking haxe
			for (_i in -group.members.length + 2 ... 0) {
				var i:Int = -_i;
				if (Reflect.getProperty(cast(group.members[i], FlxBasic), "y") > Reflect.getProperty(cast(group.members[i + 1], FlxBasic), "y")) {
					if (Std.is(group.members[i], Player) && Std.is(group.members[i], FlxTypedEmitter)) continue; 
					var _item:FlxBasic = cast(group.members[i], FlxBasic);
					group.members[i] = group.members[i + 1];
					group.members[i + 1] = _item;
					swapped = true;
				}
			}
		} while (swapped);
	}
}