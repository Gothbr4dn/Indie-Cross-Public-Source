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
import flixel.FlxCamera;
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

class Startup extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;
	public var fuckingVolume:Float = 1;
	public var useVideo = false;
	public static var webmHandler:WebmHandler;
	public var playingDathing = false;
	public var videoSprite:FlxSprite;
	public var camHUD2:FlxCamera;

	var loaded = false;

	var VideoPlaying = false;

	public static var bitmapData:Map<String, FlxGraphic>;

	var images = [];
	var music = [];
	var charts = [];

	override function create()
	{
		FlxG.mouse.visible = false;

		camHUD2 = new FlxCamera();
		camHUD2.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD2);

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('Loading_screen'));
		add(bg);

		bitmapData = new Map<String, FlxGraphic>();

		#if desktop
		trace("caching images...");

		// TODO: Refactor this to use OpenFlAssets.
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
		{
			if (!i.endsWith(".png"))
				continue;
			images.push(i);
		}

		trace("caching music...");

		for (i in music)
		{
			var inst = Paths.inst(i);
			if (Paths.doesSoundAssetExist(inst))
			{
				FlxG.sound.cache(inst);
			}
		
			var voices = Paths.voices(i);
			if (Paths.doesSoundAssetExist(voices))
			{
				FlxG.sound.cache(voices);
			}
	    }
		
		trace("Finished caching...");

		// TODO: Get the song list from OpenFlAssets.
		#end

		toBeDone = Lambda.count(images);

		var bar = new FlxBar(10, FlxG.height - 50, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 40, null, "done", 0, toBeDone);
		bar.color = FlxColor.PURPLE;
		add(bar);

		trace('starting caching..');

		#if desktop
		// cache thread
		sys.thread.Thread.create(() ->
		{
			cache();
		});
		#end

		//penis

		super.create();
	}

	var calledDone = false;

	override function update(elapsed)
	{
		if (FlxG.keys.justPressed.ENTER)// && VideoPlaying)
		{
			//FlxG.sound.music.stop();
			//GlobalVideo.get().clearPause();
			#if desktop
			//GlobalVideo.get().stop();
			//GlobalVideo.get().hide();
			//remove(videoSprite);
			#end
			//remove(tmr);
			FlxG.switchState(new TitleState());
			//LoadingState.loadAndSwitchState(new TitleState());
		}

		super.update(elapsed);
	}

	public function Video():Void // for background videos and its edited kade engine 1.18 code lol
	{  
		#if desktop
		useVideo = true;

		var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";
		var str1:String = "WEBM SHIT";
		// WebmPlayer.SKIP_STEP_LIMIT = 90;
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source('assets/videos/credits/intro.webm');
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		FlxG.sound.playMusic(Paths.sound('credits/intro'));
	
		var data = webmHandler.webm.bitmapData;
		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);
		videoSprite.scrollFactor.set(0, 0);
		videoSprite.cameras = [camHUD2];
		videoSprite.antialiasing = ClientPrefs.globalAntialiasing;
		videoSprite.screenCenter();
		add(videoSprite);
		
		trace('ITS PLAYING NOW!!!!!!');
		
		webmHandler.resume();
		//VideoPlaying = true;
		#else
		VideoPlaying = true;
		#end
	}

	function cache()
	{
		#if desktop
		trace("LOADING: " + toBeDone + " OBJECTS.");

		for (i in images)
		{
			var replaced = i.replace(".png", "");

			// var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			var imagePath = Paths.image('characters/$i', 'shared');
			trace('Caching character graphic $i');
			//var data = OpenFlAssets.getBitmapData(imagePath);
			//var graph = FlxGraphic.fromBitmapData(data);
			//graph.persist = true;
			//bitmapData.set(replaced);
			done++;
		}

		trace("Finished caching...");

		loaded = true;

		trace(OpenFlAssets.cache.hasBitmapData('GF_assets'));
		#end
		//LoadingState.loadAndSwitchState(new VideoState("assets/videos/start&end/intro.webm", new TitleState()));
		//Video(); //did this since what i did above just crashes the game :/
		new FlxTimer().start(60.0, function(tmr:FlxTimer)
		{
			FlxG.sound.music.stop();
			//GlobalVideo.get().clearPause();
			#if desktop
			GlobalVideo.get().stop();
			GlobalVideo.get().hide();
			remove(videoSprite);
			#end
			//remove(tmr);
			FlxG.switchState(new TitleState());
		});
	}
}