package ;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;

/**
 * ...
 * @author oxysoft
 */
class WinState extends FlxState {

	//LAST MINUTE MOTHERFUCKER
	override public function create():Void {
		FlxG.log.redirectTraces = false;
		FlxG.cameras.bgColor = 0xff131c1b;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		FlxG.sound.playMusic("assets/music/01.mp3", 0.7);
		add(new FlxSprite(0, 0, "assets/images/win.png"));
	
		var t = new FlxText(100, 80, 500, "Total saved time: " + Std.string(Reg.savedTime).substr(0, Std.string(Reg.savedTime).indexOf('.') + 3));
		t.setBorderStyle(FlxText.BORDER_OUTLINE);
		t.size = 24;
		add(t);
	}
	
}