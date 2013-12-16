package entities;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;
import motion.Actuate;
import motion.easing.Bounce;

/**
 * ...
 * @author oxysoft
 */
class Player extends FlxSprite {

	public var heat:Float = 0;
	public var _heat:Float = 0;
	public var heatElapsed:Float = 0;
	public var sweat:Float = 0;
	public var sweatElapsed:Float = 0;	
	
	public var walkSpeed:Float = 100;
	public var jumpForce:Float = 225;
	var tick:Int;

	public var groundEmitter:FlxEmitter;
	public var gainText:FlxText;

	
	public function new(x:Float, y:Float) {
		super(x, y);
		this.loadGraphic("assets/images/player.png", true, true, 11, 18);
		this.scale.set(2, 2);

		this.offset.x = -3;
		this.offset.y = 14;
		this.width = 8 * scale.x;
		this.height = 12 * scale.y - 14;
		
		this.animation.add("idle", [0]);
		this.animation.add("walk", [1, 2, 3, 2], 12);
		this.animation.add("jump", [3]);
		
		this.drag.set(walkSpeed * 6, walkSpeed * 6);
		this.maxVelocity.set(walkSpeed, walkSpeed);
		
		this.groundEmitter = new FlxEmitter(x + frameWidth / 2, y + frameHeight, 10);
		this.groundEmitter.acceleration.set(0, 0);
		this.groundEmitter.xVelocity.min = -40;
		this.groundEmitter.xVelocity.max = 80;
		this.groundEmitter.particleDrag.set(90, 0);
		this.groundEmitter.yVelocity.min = -25;
		this.groundEmitter.yVelocity.max = -40;
		this.groundEmitter.gravity = 190;
		this.groundEmitter.rotation.min = this.groundEmitter.rotation.max = 0;
		this.groundEmitter.endAlpha.min = this.groundEmitter.endAlpha.max = 0;
		
		for (i in 0...groundEmitter.maxSize) {
			var particle:FlxParticle = new FlxParticle();
			particle.makeGraphic(3, 3, 0xFFD8BC8C);
			particle.visible = false;
			groundEmitter.add(particle);
		}
	}
	
	public override function update():Void {
		if (gainText != null) {
			//trace(gainText.velocity.x + ", " + gainText.velocity.y + " | " + gainText.acceleration.y);
			gainText.update();
		}
		
		//FlxSpriteUtil.screenWrap(this);
		
		//moving
		this.acceleration.x = 0;
		this.acceleration.y = 0;
		
		this.groundEmitter.x = x + frameWidth / 2;
		this.groundEmitter.y = y + frameHeight + 0.25;
		
		var sweatF:Float = (sweat * 0.005);
		this.maxVelocity.set(walkSpeed * (1 - sweatF), walkSpeed * (1 - sweatF));
		
		if (FlxG.keyboard.pressed("W", "UP")) {
			this.acceleration.y -= drag.y;
			this.animation.play("walk");
		} else if (FlxG.keyboard.pressed("S", "DOWN")) {
			this.acceleration.y += drag.y;
			this.animation.play("walk");
		}
		
		if (FlxG.keyboard.pressed("A", "LEFT")) {
			this.acceleration.x -= drag.x;
			this.facing = FlxObject.LEFT;
			this.animation.play("walk");
		} else if (FlxG.keyboard.pressed("D", "RIGHT")) {
			this.acceleration.x += drag.x;
			this.facing = FlxObject.RIGHT;
			this.animation.play("walk");
		} 

		//debugging tools :3
		#if !FLX_NO_DEBUG
		if (FlxG.keyboard.justPressed("I")) {
			changeHeat(heat + 6);
		} else if (FlxG.keyboard.justPressed("O")) {
			changeHeat(heat - 6);
		}
		
		
		if (FlxG.keyboard.justPressed("Y")) {
			sweat += 5;
		} else if (FlxG.keyboard.justPressed("U")) {
			sweat -= 5;
		}
		#end
		
		//animations
		if (velocity.x == 0 && velocity.y == 0) {
			this.animation.play("idle");
			groundEmitter.on = false;
		} else {
			if (!this.groundEmitter.on) {
				groundEmitter.start(false, 0.4, .17);
			}
			
			if (FlxRandom.chanceRoll(3)) groundEmitter.emitParticle();
		}
		
		//sound
		if (velocity.x != 0 || velocity.y != 0) {
			if (tick % 12 == 0) {
				var sound = new FlxSound();
				FlxG.sound.play("assets/sounds/step.wav", 0.60);
			}
		}
		
		heatElapsed += FlxG.elapsed;

		if (!isInShadow()) {
			if (getHeatPercentage() >= 20) {
				sweatElapsed += FlxG.elapsed;
			}
			if (heatElapsed >= FlxRandom.floatRanged(1.3, 2.3)) {
				changeHeat(heat + FlxRandom.floatRanged(1, 2.5));
				heatElapsed = 0;
			}
			if (sweatElapsed >= FlxRandom.floatRanged(2.5, 5)) {
				sweat += FlxRandom.floatRanged(2, 4.5);
				sweatElapsed = 0;
			}
		} else {
			if (heatElapsed >= FlxRandom.floatRanged(0.7, 1.4)) {
				changeHeat(heat - FlxRandom.floatRanged(0.2, 0.8));
				heatElapsed = 0;
			}
		}
		
		tick++;
		super.update();
	}

	override public function draw():Void {
		super.draw();
		//if (gainText != null) gainText.draw();
	}
	
	public function isInShadow():Bool {
		return cast(FlxG.state, PlayState).isShadow(x + frameWidth / 2, y + frameHeight);
	}
	
	public function changeHeat(target:Float) {
		target = Math.max(0, target);
		target = Math.min(26, target);
		this.heat = target;
		Actuate.tween(this, 0.4, { _heat: target } ).ease(Bounce.easeOut);
	}
	
	function getHeatPercentage():Float { 
		return Math.round(heat / 26 * 100); }
	}