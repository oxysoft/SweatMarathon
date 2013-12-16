package ;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.FlxG;
import entities.Player;
import motion.Actuate;
import motion.easing.Bounce;

/**
 * ...
 * @author oxysoft
 */
class Checkpoint extends FlxSprite {

	public var hud:HUD;
	public var elapsed:Float = 0;
	public var time:Float = 0;
	public var started:Bool = false;
	public var reached:Bool = false;
	
	public function new(min:String, sec:String, x:Int, y:Int, width:Int, height:Int) {
		super(x, y);
		var m:Float = Std.parseFloat(min) * 60;
		var s:Float = Std.parseFloat(sec);
		
		if (min == null) m = 0;
		if (sec == null) s = 0;
		
		time = m + s;
		
		this.width = width;
		this.height = height;
		this.alpha = 0.3;
		
		if (this.width == 0) this.width = 16;
		if (this.height == 0) this.height = 16;
		
		this.makeGraphic(Std.int(width), Std.int(height), 0xff00ffff);
		visible = false;
	}
	
	public function start(hud:HUD) {
		started = true;
		this.hud = hud;
		hud.checkPointTimeText.alpha = 1;
		visible = true;
	}
	
	public function pause() {
		started = false;
	}
	
	public override function update():Void {
		super.update();
		
		if (!reached && started) {
			elapsed += FlxG.elapsed;

			var d = (time - elapsed);
			if (d < 0) {
				if (d < -1.0) {
					FlxG.camera.fade(0xff000000, 2.8, false);
				}
				d = 0;
			}
			var s = Std.string(d).substr(0, Std.string(d).indexOf('.') + 3);
			hud.checkPointTimeText.text = "Time remaining: " + s;
		}
	}
	
	public function isOver():Bool {
		return elapsed >= time;
	}
	
	public function isReached(player:Player):Bool {
		if (reached) return true;
		if (isOver()) return false;
	
		var oldReached:Bool = reached;
		reached = FlxG.overlap(this, player);
		if (!oldReached && reached) {
			pause();
			FlxG.sound.play("assets/sounds/cpReached.wav", 7);
			visible = false;
		}
	
		return reached;
	}
	
}