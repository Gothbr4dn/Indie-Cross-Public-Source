package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	//sprites :)
	var bg:FlxSprite;
	var sans:FlxSprite;
	var cuphead:FlxSprite;
	var bendy:FlxSprite;
	var panel:FlxSprite;
	var Difficulty:FlxSprite;
	var DifficultyMechanic:FlxSprite;
	var week1:FlxSprite;
	var week1s:FlxSprite;
	var week2:FlxSprite;
	var week2s:FlxSprite;
	var week3:FlxSprite;
	var week3s:FlxSprite;
	var storytext:FlxSprite;
	var scorepanel:FlxSprite;
	var The_Thing:FlxSprite; //loading screen

	//mechanic shit
	var Shifting:Bool = false;
	var MechanicSelection:Int = 1;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		//rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
				weekThing.y += ((weekThing.height + 20) * num);
				weekThing.targetY = num;
				grpWeekText.add(weekThing);

				weekThing.screenCenter(X);
				weekThing.antialiasing = ClientPrefs.globalAntialiasing;
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					lock.antialiasing = ClientPrefs.globalAntialiasing;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		add(bgYellow);
		add(bgSprite);
		add(grpWeekCharacters);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(txtWeekTitle);

		//so no vision :)
		//difficultySelectors.visible = false;
		grpWeekText.visible = false;
		blackBarThingie.visible = false;
	    grpLocks.visible = false;
		bgYellow.visible = false;
		bgSprite.visible = false;
		grpWeekCharacters.visible = false;
		tracksSprite.visible = false;
		txtTracklist.visible = false;
		txtWeekTitle.visible = false;

		bg = new FlxSprite(-250, -200).loadGraphic(Paths.image('story mode/BG'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.scale.set(0.6, 0.65);
		bg.visible = false;
		add(bg);

		cuphead = new FlxSprite(675, 50); //how did this take me 2 hours to figure out
		cuphead.frames = Paths.getSparrowAtlas('story mode/Cuphead_Gaming');
		cuphead.animation.addByPrefix('cup', 'Cuphead Gaming instance 1', 24); 
		cuphead.animation.play('cup');
		cuphead.antialiasing = ClientPrefs.globalAntialiasing;
		cuphead.scale.set(0.75, 0.75);
		cuphead.visible = false;
		add(cuphead);

		sans = new FlxSprite(0, -50); //how did this take me 2 hours to figure out
		sans.frames = Paths.getSparrowAtlas('story mode/SansStorymodeMenu');
		sans.animation.addByPrefix('sansanim', 'Saness instance 1', 24); 
		sans.animation.play('sansanim');
		sans.antialiasing = ClientPrefs.globalAntialiasing;
		sans.visible = false;
		add(sans);

		bendy = new FlxSprite(-250, -225); //how did this take me 2 hours to figure out
		bendy.frames = Paths.getSparrowAtlas('story mode/Bendy_Gaming');
		bendy.animation.addByPrefix('bendycreep', 'Creepy shit instance 1', 24); 
		bendy.animation.play('bendycreep');
		bendy.antialiasing = ClientPrefs.globalAntialiasing;
		bendy.scale.set(0.6, 0.65);
		bendy.visible = false;
		add(bendy);

		panel = new FlxSprite(0, -350).loadGraphic(Paths.image('story mode/Left-Panel_above BGs'));
		panel.antialiasing = ClientPrefs.globalAntialiasing;
		panel.screenCenter();
		add(panel);

		Difficulty = new FlxSprite(-10, 175); //how did this take me 2 hours to figure out
		Difficulty.frames = Paths.getSparrowAtlas('story mode/Difficulties');
		Difficulty.animation.addByPrefix('easy', 'Chart Easy instance 1', 24); 
		Difficulty.animation.addByPrefix('normal', 'Chart Normal instance 1', 24);
		Difficulty.animation.addByPrefix('hard', 'Chart Hard instance 1', 24);
		Difficulty.animation.play('normal');
		Difficulty.antialiasing = ClientPrefs.globalAntialiasing;
		//Difficulty.scale.set(0.6, 0.65);
		add(Difficulty);

		DifficultyMechanic = new FlxSprite(-10, 250); //how did this take me 2 hours to figure out
		DifficultyMechanic.frames = Paths.getSparrowAtlas('story mode/MechanicDifficulty');
		DifficultyMechanic.animation.addByPrefix('mechanic-off', 'Mechs Dis instance 1', 24);
		DifficultyMechanic.animation.addByPrefix('mechanic-standard', 'Mechs Hard instance 1', 24);
		DifficultyMechanic.animation.addByPrefix('mechanic-hard', 'Mechs Hell instance 1', 24);
		DifficultyMechanic.animation.play('mechanic-standard');
		DifficultyMechanic.antialiasing = ClientPrefs.globalAntialiasing;
		//Difficulty.scale.set(0.6, 0.65);
		add(DifficultyMechanic);

		week1 = new FlxSprite(-215, -125).loadGraphic(Paths.image('story mode/Weeks/Week1'));
		week1.antialiasing = ClientPrefs.globalAntialiasing;
		week1.scale.set(0.75, 0.75);
		week1.visible = false;
		add(week1);

		week1s = new FlxSprite(-215, -125).loadGraphic(Paths.image('story mode/Weeks/Week1_selected'));
		week1s.antialiasing = ClientPrefs.globalAntialiasing;
		week1s.scale.set(0.75, 0.75);
		week1s.visible = false;
		add(week1s);

		week2 = new FlxSprite(-215, -125).loadGraphic(Paths.image('story mode/Weeks/Week2'));
		week2.antialiasing = ClientPrefs.globalAntialiasing;
		week2.scale.set(0.75, 0.75);
		week2.visible = false;
		add(week2);

		week2s = new FlxSprite(-215, -125).loadGraphic(Paths.image('story mode/Weeks/Week2_selected'));
		week2s.antialiasing = ClientPrefs.globalAntialiasing;
		week2s.scale.set(0.75, 0.75);
		week2s.visible = false;
		add(week2s);

		week3 = new FlxSprite(-215, -125).loadGraphic(Paths.image('story mode/Weeks/Week3'));
		week3.antialiasing = ClientPrefs.globalAntialiasing;
		week3.scale.set(0.75, 0.75);
		week3.visible = false;
		add(week3);

		week3s = new FlxSprite(-215, -125).loadGraphic(Paths.image('story mode/Weeks/Week3_selected'));
		week3s.antialiasing = ClientPrefs.globalAntialiasing;
		week3s.scale.set(0.75, 0.75);
		week3s.visible = false;
		add(week3s);

		storytext = new FlxSprite(-480, -200).loadGraphic(Paths.image('story mode/Storymode'));
		storytext.antialiasing = ClientPrefs.globalAntialiasing;
		storytext.scale.set(0.5, 0.5);
		add(storytext);

		scorepanel = new FlxSprite(0, -350).loadGraphic(Paths.image('story mode/Score_bottom panel'));
		scorepanel.antialiasing = ClientPrefs.globalAntialiasing;
		scorepanel.screenCenter(X);
		add(scorepanel);

		scoreText = new FlxText(0, 665, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);
		scoreText.screenCenter(X);
		add(scoreText);

		The_Thing = new FlxSprite(0, 0); //how did this take me 2 hours to figure out
		The_Thing.frames = Paths.getSparrowAtlas('the_thing2.0', 'cup');
		The_Thing.animation.addByPrefix('load', 'BOO instance 1', 20, false);
		The_Thing.antialiasing = ClientPrefs.globalAntialiasing;
		The_Thing.scale.set(1.25, 1.25);
		The_Thing.screenCenter();
		The_Thing.visible = false;
		add(The_Thing);

		changeWeek();
		changeDifficulty();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		if (curWeek == 0)
		{
			week1.visible = false;
			week1s.visible = true;
			week2.visible = true;
			week2s.visible = false;
			week3.visible = true;
			week3s.visible = false;

			bg.visible = true;
			cuphead.visible = true;
			sans.visible = false;
			bendy.visible = false;
		}
		else if (curWeek == 1)
		{
			week1.visible = true;
			week1s.visible = false;
			week2.visible = false;
			week2s.visible = true;
			week3.visible = true;
			week3s.visible = false;

			bg.visible = false;
			cuphead.visible = false;
			sans.visible = true;
			bendy.visible = false;
		}
		else if (curWeek == 2)
		{
			week1.visible = true;
			week1s.visible = false;
			week2.visible = true;
			week2s.visible = false;
			week3.visible = false;
			week3s.visible = true;

			bg.visible = false;
			cuphead.visible = false;
			sans.visible = false;
			bendy.visible = true;
		}

		if (curDifficulty == 0)
		{
			Difficulty.animation.play('easy');
		}
		else if (curDifficulty == 1)
		{
			Difficulty.animation.play('normal');
		}
		else if (curDifficulty == 2)
		{
			Difficulty.animation.play('hard');
		}

		if (MechanicSelection == 0)
		{
			DifficultyMechanic.animation.play('mechanic-off');
		}
		else if (MechanicSelection == 1)
		{
			DifficultyMechanic.animation.play('mechanic-standard');
		}
		else if (MechanicSelection == 2)
		{
			DifficultyMechanic.animation.play('mechanic-hard');
		}

		Shifting = FlxG.keys.pressed.SHIFT;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			if (upP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (downP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (Shifting && controls.UI_RIGHT_P)
			{
				changeMechanicDifficulty(1);
			}
			else if (Shifting && controls.UI_LEFT_P)
			{
				changeMechanicDifficulty(-1);
			}
			else if (Shifting && upP || downP)
			{
				changeMechanicDifficulty();
			}

			if (controls.UI_RIGHT_P && !Shifting)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P && !Shifting)
				changeDifficulty(-1);
			else if (upP || downP && !Shifting)
				changeDifficulty();

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				if (curWeek == 0)
				{
					The_Thing.visible = true;
					The_Thing.animation.play('load');
					FlxG.sound.play(Paths.sound('boing', 'cup'));
				}

				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
			lock.visible = (lock.y > FlxG.height / 2);
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			if (stopspamming == false)
			{
				//FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();

				var bf:MenuCharacter = grpWeekCharacters.members[1];
				if(bf.character != '' && bf.hasConfirmAnimation) grpWeekCharacters.members[1].animation.play('confirm');
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = CoolUtil.difficulties[curDifficulty];
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Paths.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 15;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
			}});
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	function changeMechanicDifficulty(MechanicChange:Int = 0):Void
	{
		MechanicSelection += MechanicChange;

		if (MechanicSelection < 0)
		{
			MechanicSelection = CoolUtil.difficulties.length-1;
		}
        //same code different thing still works lol
		if (MechanicSelection >= CoolUtil.difficulties.length)
		{
			MechanicSelection = 0;
		}
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && unlocked)
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5
		difficultySelectors.visible = unlocked;

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
