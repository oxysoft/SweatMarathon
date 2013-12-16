package entities;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.FlxObject;

/**
 * ...
 * @author oxysoft
 */
class Tree extends FlxSprite {

	public function new(x:Int, y:Int) {
		super(x, y);
		loadGraphic("assets/images/tree.png", false, true);
		#if !FLX_NO_DEBUG
		this.drawDebugOnCamera();
		#end
		this.scale.set(2, 2);
		this.offset.set(11, 48);
		this.width = 30;
		this.height = 14;
		this.solid = true;
		this.immovable = true;
		if (FlxRandom.sign() == 1) this.facing = FlxObject.RIGHT;
	}
	
	override public function update():Void {
		super.update();
	}
	
}