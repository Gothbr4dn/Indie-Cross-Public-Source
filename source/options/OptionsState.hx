package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Controls', 'Graphics', 'Visuals and UI', 'Gameplay', 'Adjust Delay and Combo'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			/*
			case 'Note Colors':
				persistentUpdate = false;
				openSubState(new options.NotesSubState());
			*/
			#if (desktop || html5)
			case 'Controls':
				persistentUpdate = false;
				openSubState(new options.ControlsSubState());
			#else
			case 'Controls':
				persistentUpdate = false;
				openSubState(new options.PreferencesSubstate());
			#end
			case 'Graphics':
				persistentUpdate = false;
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				persistentUpdate = false;
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				persistentUpdate = false;
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
		}
	}

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

        FlxG.sound.music.stop();
	    FlxG.sound.playMusic(Paths.music('settin'));

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i], true, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;
			optionText.forceX = optionText.x;
			optionText.targetY = i;
			grpOptions.add(optionText);
		}

		#if android
		var tipText:FlxText = new FlxText(10, FlxG.height - 24, 0, 'Press C to Go In Android Controls Menu', 16);
		tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2;
		tipText.scrollFactor.set();
		add(tipText);
		#end

		changeSelection();
		ClientPrefs.saveSettings();

                #if android
		addVirtualPad(UP_DOWN, A_B_C);
                #end

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.sound.music.stop();
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}

		#if android
		if (_virtualpad.buttonC.justPressed) {
			MusicBeatState.switchState(new android.AndroidControlsMenu());
		}
		#end
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
