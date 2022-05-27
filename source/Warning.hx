package;

import lime.app.Application;
#if desktop
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.ui.FlxBar;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;

using StringTools;

class Warning extends MusicBeatState
{
    public static var CupWarning:Bool = false;
	public static var SansWarning:Bool = false;
	public static var BendyWarning1:Bool = false;
	public static var BendyWarning2:Bool = false;
	public static var BendyWarning3:Bool = false;

	//the gang
	var thegang:FlxSprite;
	var thegang2:FlxSprite;

	override public function create()
	{
		if (CupWarning)
		{
			var Warning:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('instructions/Cuphead'));
			Warning.updateHitbox();
			Warning.screenCenter();
			add(Warning);

			FlxG.save.data.CupWarning;
			FlxG.save.data.CupWarning = true;
		}
		else if (SansWarning)
		{
			var Warning:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('instructions/Sans'));
			Warning.updateHitbox();
			Warning.screenCenter();
			add(Warning);

			FlxG.save.data.SansWarning;
			FlxG.save.data.SansWarning = true;
		}
		else if (BendyWarning1)
		{
			var Warning:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('instructions/Bendy-Phase2'));
			Warning.updateHitbox();
			Warning.screenCenter();
			add(Warning);

			FlxG.save.data.BendyWarning1;
			FlxG.save.data.BendyWarning1 = true;
		}
		else if (BendyWarning2)
		{
			var Warning:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('instructions/Bendy-Phase3'));
			Warning.updateHitbox();
			Warning.screenCenter();
			add(Warning);

			thegang = new FlxSprite(200, 200);
			thegang.frames = Paths.getSparrowAtlas('instructions/Tutorialanim');
			thegang.animation.addByPrefix('idle', "Example instance 1", 24);
			thegang.animation.play('idle');
			thegang.updateHitbox();
			add(thegang);

			FlxG.save.data.BendyWarning2;
			FlxG.save.data.BendyWarning2 = true;

			/*
			thegang2 = new FlxSprite(200, 200);
			thegang2.frames = Paths.getSparrowAtlas('instructions/Tutorialanim');
			thegang2.animation.addByPrefix('idle', "fezt instance 1", 24);
			thegang2.animation.play('idle');
			thegang2.updateHitbox();
			add(thegang2);
			*/
		}
		else if (BendyWarning3)
		{
			var Warning:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('instructions/Bendy-Phase4'));
			Warning.updateHitbox();
			Warning.screenCenter();
			add(Warning);

			FlxG.save.data.BendyWarning3;
			FlxG.save.data.BendyWarning3 = true;
		}
		else if (!CupWarning || !FlxG.save.data.SansWarning || !FlxG.save.data.BendyWarning1 || !FlxG.save.data.BendyWarning2 || !FlxG.save.data.BendyWarning3)
		{
			CupWarning = false;
			SansWarning = false;
			BendyWarning1 = false;
			BendyWarning2 = false;
			BendyWarning3 = false;
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			CupWarning = false;
			SansWarning = false;
			BendyWarning1 = false;
			BendyWarning2 = false;
			BendyWarning3 = false;

			LoadingState.loadAndSwitchState(new PlayState());
		}
	}
}