package ;
import entities.Player;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;

/**
 * ...
 * @author oxysoft
 */
class MessageZone extends FlxSprite {

	public var txt:FlxText;
	public var steppedOn:Bool;
	public var cp:Bool;
	
	public function new(x:Float, y:Float, w:Float, h:Float) {
		super(x, y);
		this.width = w;
		this.height = h;
		txt = new FlxText(159, 160, 316, "");
		txt.alignment = "center";
		txt.setBorderStyle(FlxText.BORDER_SHADOW);
		txt.color = 0xFFFF00;
		txt.scrollFactor.set(0, 0);
		txt.height = 200;
	}
	
	public override function update():Void {
		super.update();
		txt.update();
		
		var player:Player = cast(FlxG.state, PlayState).player;
		if (FlxG.overlap(this, player)) {
			if (!steppedOn) {
				if (cp) {
					cast(FlxG.state, PlayState).tilemap.startNextCheckpoint();
				}
			}
			
			steppedOn = true;
		}
	}
	
	public override function draw():Void {
		var player:Player = cast(FlxG.state, PlayState).player;
		if (FlxG.overlap(this, player)) {
			txt.draw();
		}
	}
	
}