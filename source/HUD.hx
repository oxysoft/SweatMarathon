package ;
import entities.Player;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import flixel.FlxG;
import motion.Actuate;
import motion.easing.Sine;

/**
 * ...
 * @author oxysoft
 */
class HUD extends FlxGroup {

	public var heatText:FlxText;
	public var heatMeter:FlxSprite;
	public var heatMeterOverlay:FlxSprite;
	public var heatPercent:FlxText;
		
	public var sweatText:FlxText;
	public var sweatMeter:FlxSprite;
	public var sweatPercent:FlxText;

	public var minimapText:FlxText;
	public var minimapBg:FlxSprite;
	public var minimap:Minimap;

	
	public var checkPointTimeText:FlxText;
	
	public function new() {
		super();
		
		//158, 117 
		
		//heat meter
		heatMeter = new FlxSprite(175, 300);
		heatMeter.loadGraphic("assets/images/meter_heat.png", false, false, 14, 40);
		add(heatMeter);
		
		heatMeterOverlay = new FlxSprite(heatMeter.x, heatMeter.y);
		heatMeterOverlay.loadGraphic("assets/images/meter_heat.png", false, false, 14, 40);
		for (i in 0...28) {
			heatMeterOverlay.animation.add("" + i, [i]);
		}
		add(heatMeterOverlay);
		
		heatText = new FlxText(heatMeter.x - (heatMeter.frameWidth / 2) + 2, heatMeter.y - 15, 45, "Heat");
		heatText.setBorderStyle(FlxText.BORDER_SHADOW, 0x111111);
		add(heatText);
		
		heatPercent = new FlxText(heatMeter.x - 5, heatMeter.y + heatMeter.frameHeight, heatMeter.frameWidth + 12, "0%");
		heatPercent.setBorderStyle(FlxText.BORDER_SHADOW, 0x111111);
		heatPercent.alignment = "center";
		heatPercent.wordWrap = false;
		add(heatPercent);
		
		//sweat meter
		var spacing:Int = 15;
		
		sweatMeter = new FlxSprite(heatMeter.x + heatMeter.frameWidth + spacing, heatMeter.y + 3);
		sweatMeter.loadGraphic("assets/images/meter_sweat.png", false, false, 32, 37);
		for (i in 0...9) {
			sweatMeter.animation.add("" + i, [i]);
		}
		add(sweatMeter);
		
		sweatText = new FlxText(heatMeter.x + heatMeter.frameWidth + spacing + (sweatMeter.frameWidth / 2) - 15, heatText.y, 40, "Sweat");
		sweatText.setBorderStyle(FlxText.BORDER_SHADOW, 0x111111);
		add(sweatText);
		
		sweatPercent = new FlxText(sweatMeter.x + 2, sweatMeter.y + sweatMeter.frameHeight + 1, sweatMeter.frameWidth, "0%");
		sweatPercent.setBorderStyle(FlxText.BORDER_SHADOW, 0x111111);
		sweatPercent.alignment = "center";
		sweatPercent.wordWrap = false;
		add(sweatPercent);
		
		//minimap
		minimap = new Minimap(this, cast(FlxG.state, PlayState).tilemap, cast(FlxG.state, PlayState).player, 370, Std.int(sweatMeter.y));
		minimapBg = new FlxSprite(minimap.x - 1, minimap.y - 1);
		minimapBg.makeGraphic(Std.int(minimap.width + 2), Std.int(minimap.height + 2), 0xffC8C8C8);
		add(minimapBg);
		add(minimap);
		
		minimapText = new FlxText(minimapBg.x, minimapBg.y - 14, 43, "Minimap");
		if (minimapText.width > minimapBg.width) {
			minimapText.x += minimapBg.width / 2 - minimapText.width / 2;
		} else {
			minimapText.x += minimapBg.width / 2 - minimapText.width / 2;
		}
		minimapText.setBorderStyle(FlxText.BORDER_SHADOW, 0x111111);
		minimapText.wordWrap = false;
		add(minimapText);
		
		//checkpoint
		checkPointTimeText = new FlxText(159, 130, 316, "Time remaining: " + "-");
		checkPointTimeText.alignment = "center";
		checkPointTimeText.setBorderStyle(FlxText.BORDER_SHADOW);
		checkPointTimeText.alpha = 0;
		add(checkPointTimeText);
		
		//disable motherfucking camera scroll
		setAll('scrollFactor', new FlxPoint(0, 0));
	}
	
	public override function update():Void {
		super.update();
		
		var state:PlayState = cast(FlxG.state, PlayState);
		var player:Player = state.player;
		
		var heatstate:Int = Std.parseInt("" + player._heat);
		heatMeterOverlay.animation.play("" + (heatstate + 1));
		
		var sweatstate:Int = Std.parseInt("" + Math.floor(player.sweat / 10));
		sweatMeter.animation.play("" + sweatstate);
		
		heatPercent.text = (Math.round(player._heat / 26 * 100)) + "%";
		sweatPercent.text = (Math.ceil(player.sweat)) + "%";
	}
	
}