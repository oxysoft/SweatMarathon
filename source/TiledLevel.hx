package ;
import entities.Player;
import entities.Tree;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import haxe.io.Path;
import flixel.FlxG;

/**
 * ...
 * @author oxysoft
 */
class TiledLevel extends TiledMap {

	public var playstate:PlayState;
	public var collidableTilemaps:FlxGroup;
	public var nonCollidableTilemaps:FlxGroup;
	public var checkpoints:Map<Int, Checkpoint>;
	public var currentCheckpoint:Checkpoint;
	public var currentCheckpointId:Int = -1;
	public var messages:FlxGroup;
	
	public function new(level:Dynamic) {
		super(level);
		
		checkpoints = new Map<Int, Checkpoint>();
		collidableTilemaps = new FlxGroup();
		nonCollidableTilemaps = new FlxGroup();
		messages = new FlxGroup();

		for (layer in layers) {
			var tilesetname = layer.properties.get("tileset");
			
			if (tilesetname == null)
				throw "Tileset property not defined for the " + layer.name + " layer.";
			
			var tileset:TiledTileSet = null;
			for (ts in tilesets) {
				if (ts.name == tilesetname) {
					tileset = ts;
					break;
				}
			}
			if (tileset == null)
				throw "Tileset " + tilesetname + " not found";
				
			var imagepath = new Path(tileset.imageSource);
			var path = "assets/images/" + imagepath.file + "." + imagepath.ext;
			
			var tilemap = new FlxTilemap();
			tilemap.widthInTiles = width;
			tilemap.heightInTiles = height;
			tilemap.loadMap(layer.tileArray, path, tileset.tileWidth, tileset.tileHeight, 0, 1 , 1, 1);
			if (layer.properties.contains("nocollide")) {
				nonCollidableTilemaps.add(tilemap);
			} else {
				collidableTilemaps.add(tilemap);
			}
		}
	}
	
	public function loadObjects(state:PlayState) {
		this.playstate = state;
		
		for (group in objectGroups) {
			for (object in group.objects) {
				loadObject(object, group, state);
			}
		}
	}
	
	private function loadObject(object:TiledObject, group:TiledObjectGroup, state:PlayState) {
		var x = object.x;
		var y = object.y;
		
		if (object.gid != -1)
			y -= group.map.getGidOwner(object.gid).tileHeight;
			
		switch (group.name) {
			case "trees": {
				var tree:Tree = new Tree(object.x, object.y);
				state.entities.add(tree);
				state.trees.add(tree);
				
				var shadow:FlxSprite = new FlxSprite(tree.x - 10, tree.y + 26);
				shadow.loadfromSprite(tree);
				shadow.facing = tree.facing == 0x0001 ? 0x0002 : 0x0001;
				shadow.angle = 180;
				shadow.scale.set(2, 1.2);
				shadow.color = 0x000000;
				shadow.alpha = 0.40;
				shadow.offset.set( -12, 0);
				shadow.x -= -shadow.offset.x;
				shadow.width += Math.abs(shadow.offset.x) * 2;
				state.shadows.add(shadow);
			}
			case "messages": {
				var zone:MessageZone = new MessageZone(object.x, object.y, object.width, object.height);
				if (object.name == "[object]") zone.txt.text = "";
				else zone.txt.text = object.name;
				messages.add(zone);
				if (object.type == "cp") {
					zone.cp = true;
				}
			}
			case "checkpoints": {
				var id:Int = Std.parseInt(object.name);
				var m = object.custom.keys.exists("m") ? object.custom.get("m") : "0";
				var s = object.custom.keys.exists("s") ? object.custom.get("s") : "0";
				var cp:Checkpoint = new Checkpoint(m, s, object.x, object.y, object.width, object.height);
				checkpoints.set(id, cp);
				state.checkpoints.add(cp);
			}
			case "player": {
				state.player = new Player(object.x, object.y);
				state.entities.add(state.player.groundEmitter);
				state.entities.add(state.player);
				state.hud = new HUD();
			}
			default:
				throw "Unhandled object type: " + group.name;
		}
	}
	
	public function startNextCheckpoint() {
		currentCheckpointId++;

		if (checkpoints.get(currentCheckpointId) != null) {
			var saved:Float = 0;
			
			if (currentCheckpoint != null) {
				if (currentCheckpoint.isOver()) {
					return;
				} else saved += (currentCheckpoint.time - currentCheckpoint.elapsed);
			}
			
			if (saved > 0) {
				var s = Std.string(saved).substr(0, Std.string(saved).indexOf('.') + 3);
				var t:FlxText = new FlxText(playstate.player.x, playstate.player.y, 40, s);
				t.immovable = false;
				t.solid = false;
				t.velocity.x = 50;
				t.velocity.y = -50;
				t.acceleration.y = 400;
				t.drag.x = 30;
				t.color = 0x80FF00;
				t.setBorderStyle(FlxText.BORDER_OUTLINE);
				playstate.player.gainText = t;
			}
			
			currentCheckpoint = checkpoints.get(currentCheckpointId);
			currentCheckpoint.time += saved;
			currentCheckpoint.start(playstate.hud);
		} else {
			FlxG.camera.fade(0xff000000, 1.0, false, function():Void {
				Reg.savedTime += currentCheckpoint.time;
				Reg.currentLevel++;
				FlxG.resetState();
			});
		}
	}
}