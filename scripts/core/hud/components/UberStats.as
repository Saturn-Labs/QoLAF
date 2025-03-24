package core.hud.components {
	import core.scene.Game;
	import flash.utils.Dictionary;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class UberStats extends Sprite {
		private var g:Game;
		
		public var uberMaxLevel:Number = 100;
		
		public var uberMinLevel:Number = 1;
		
		public var uberDifficultyAtTopRank:Number = 2000;
		
		public var uberTopRank:Number = 10;
		
		public var uberLevel:Number = 0;
		
		public var uberLives:Number = 3;
		
		public var uberRank:Number = 0;
		
		private var oldScore:Number = 0;
		
		private var oldXpLeft:int = 0;
		
		private var oldBossesLeft:int = 0;
		
		private var oldMiniBossesLeft:int = 0;
		
		private var oldSpawnerLeft:int = 0;
		
		private var oldUberRank:int = 0;
		
		private var optionalRank:int = 3;
		
		private var scoreTime:Number = 0;
		
		private var lives:Dictionary = new Dictionary();
		
		private var rankText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		
		private var challengeText:TextBitmap = new TextBitmap();
		
		private var missionText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		
		private var optionalMissionText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		
		private var xpText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		
		private var optionalText:TextBitmap = new TextBitmap();
		
		private var scoreText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		
		private var highscoreText:TextField = new TextField(200,20,"",new TextFormat("DAIDRR"));
		
		private var lifes:TextBitmap = new TextBitmap();
		
		private var oldCompleted:Boolean = false;
		
		private var oldOptionalCompleted:Boolean = false;
		
		public function UberStats(g:Game) {
			super();
			this.g = g;
			addChild(rankText);
			addChild(challengeText);
			addChild(xpText);
			addChild(missionText);
			addChild(optionalText);
			addChild(optionalMissionText);
			addChild(scoreText);
			addChild(highscoreText);
			addChild(lifes);
		}
		
		public function update(m:Message) : void {
			var _local14:int = 0;
			var _local13:* = 0;
			var _local27:Object = null;
			var _local18:TextBitmap = null;
			var _local23:int = 0;
			uberRank = m.getNumber(_local23++);
			uberLevel = m.getNumber(_local23++);
			var _local22:int = m.getInt(_local23++);
			var _local7:Number = m.getNumber(_local23++);
			var _local20:Number = m.getNumber(_local23++);
			var _local3:int = m.getInt(_local23++);
			var _local24:int = m.getInt(_local23++);
			var _local8:int = m.getInt(_local23++);
			var _local9:int = m.getInt(_local23++);
			var _local15:int = m.getInt(_local23++);
			var _local26:int = m.getInt(_local23++);
			var _local6:int = m.getInt(_local23++);
			var _local4:String = m.getString(_local23++);
			var _local10:String = m.getString(_local23++);
			var _local16:Boolean = m.getBoolean(_local23++);
			var _local25:Boolean = m.getBoolean(_local23++);
			var _local2:int = m.getInt(_local23++);
			var _local21:Array = [];
			if(uberRank == oldUberRank + 1) {
				g.textManager.createUberRankCompleteText("START RANK " + uberRank + "");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if(_local16 && !oldCompleted) {
				g.textManager.createUberRankCompleteText("RANK " + uberRank + " COMPLETE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if(_local25 && !oldOptionalCompleted && uberRank >= optionalRank) {
				g.textManager.createUberExtraLifeText("EXTRA LIFE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if(oldScore < _local20 && _local7 > _local20) {
				g.textManager.createUberExtraLifeText("NEW HIGHSCORE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			var _local5:int = _local3 - _local22;
			var _local17:int = _local8 - _local24;
			var _local12:int = _local15 - _local9;
			var _local11:int = _local6 - _local26;
			if(_local17 < oldBossesLeft && (_local10 == "boss" && uberRank >= optionalRank || _local4 == "boss")) {
				g.textManager.createUberTaskText(_local24 + " of " + _local8 + " bosses destroyed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if(_local12 < oldMiniBossesLeft && (_local10 == "miniboss" && uberRank >= optionalRank || _local4 == "miniboss")) {
				g.textManager.createUberTaskText(_local9 + " of " + _local15 + " mini bosses killed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if(_local11 < oldSpawnerLeft && (_local10 == "spawner" && uberRank >= optionalRank || _local4 == "spawner")) {
				g.textManager.createUberTaskText(_local26 + " of " + _local6 + " spawners smashed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if(g.time > scoreTime && _local7 > oldScore) {
				g.textManager.createScoreText(_local7 - oldScore);
			}
			var _local19:String = "<FONT COLOR=\'#88FF88\'>complete</FONT>";
			missionText.format.size = 14;
			missionText.format.color = Style.COLOR_HIGHLIGHT;
			missionText.format.horizontalAlign = "right";
			missionText.alignPivot("right");
			missionText.isHtmlText = true;
			if(_local4 == "boss") {
				missionText.text = "Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_local17 == 0 ? _local19 : _local24 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local8) + "</FONT></FONT>";
			} else if(_local4 == "miniboss") {
				missionText.text = "Mini Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_local12 == 0 ? _local19 : _local9 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local15) + "</FONT></FONT>";
			} else if(_local4 == "spawner") {
				missionText.text = "Spawners: <FONT COLOR=\'#FFFFFF\'>" + (_local11 == 0 ? _local19 : _local26 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local6) + "</FONT></FONT>";
			} else {
				missionText.text = "";
			}
			rankText.format.color = Style.COLOR_HIGHLIGHT;
			rankText.isHtmlText = true;
			rankText.format.horizontalAlign = "right";
			rankText.alignPivot("right");
			rankText.text = "Rank <FONT COLOR=\'#FFFFFF\'>" + Math.floor(uberRank) + "</FONT>, Level > <FONT COLOR=\'#FFFFFF\'>" + Math.floor(uberLevel) + "</FONT>";
			challengeText.format.color = 0xaaaaaa;
			challengeText.y = rankText.y + rankText.height + 25;
			challengeText.alignRight();
			xpText.format.color = Style.COLOR_HIGHLIGHT;
			xpText.format.size = 14;
			xpText.isHtmlText = true;
			xpText.format.horizontalAlign = "right";
			xpText.alignPivot("right");
			xpText.text = "Troons: <FONT COLOR=\'#FFFFFF\'>" + (_local5 == 0 ? _local19 : Math.floor(_local22 / 10) + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + Math.floor(_local3 / 10)) + "</FONT></FONT>";
			xpText.y = challengeText.y + challengeText.height + 5;
			missionText.y = xpText.y + xpText.height + 5;
			optionalText.text = "(extra life)";
			optionalText.format.color = 0xaaaaaa;
			optionalText.y = missionText.y + missionText.height + 10;
			optionalText.alignRight();
			optionalMissionText.format.color = Style.COLOR_HIGHLIGHT;
			optionalMissionText.isHtmlText = true;
			optionalMissionText.format.horizontalAlign = "right";
			optionalMissionText.alignPivot("right");
			optionalMissionText.y = optionalText.y + optionalText.height + 5;
			if(_local10 == "boss") {
				optionalMissionText.text = "Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_local17 == 0 ? _local19 : _local24 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local8) + "</FONT></FONT>";
			} else if(_local10 == "miniboss") {
				optionalMissionText.text = "Mini Bosses: <FONT COLOR=\'#FFFFFF\'>" + (_local12 == 0 ? _local19 : _local9 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local15) + "</FONT></FONT>";
			} else if(_local10 == "spawner") {
				optionalMissionText.text = "Spawners: <FONT COLOR=\'#FFFFFF\'>" + (_local11 == 0 ? _local19 : _local26 + "<FONT SIZE=\'10\' COLOR=\'#AAAAAA\'>/ " + _local6) + "</FONT></FONT>";
			}
			if(uberRank >= optionalRank) {
				optionalText.visible = true;
				optionalMissionText.visible = true;
			} else {
				optionalText.visible = false;
				optionalMissionText.visible = false;
			}
			scoreText.format.color = Style.COLOR_HIGHLIGHT;
			scoreText.format.size = 16;
			scoreText.isHtmlText = true;
			scoreText.format.horizontalAlign = "right";
			scoreText.alignPivot("right");
			scoreText.text = "Total Troons: <FONT COLOR=\'#FF44aa\'>" + Math.floor(_local7) + "</FONT>";
			scoreText.y = optionalMissionText.y + optionalMissionText.height + 25;
			highscoreText.format.color = Style.COLOR_HIGHLIGHT;
			highscoreText.isHtmlText = true;
			highscoreText.format.horizontalAlign = "right";
			highscoreText.alignPivot("right");
			highscoreText.text = "Highscore: <FONT COLOR=\'#FFFFFF\'>" + Math.floor(_local20) + "</FONT>";
			highscoreText.y = scoreText.y + scoreText.height + 5;
			lifes.text = "Lives";
			lifes.format.color = 0xaaaaaa;
			lifes.y = highscoreText.y + highscoreText.height + 25;
			lifes.alignRight();
			_local14 = 0;
			_local13 = _local23;
			while(_local13 < _local23 + 3 * _local2) {
				_local27 = {};
				_local27.key = m.getString(_local13);
				_local27.name = m.getString(_local13 + 1);
				_local27.lives = m.getInt(_local13 + 2);
				lives[_local27.key] = _local27.lives;
				_local21.push(_local27);
				_local18 = TextBitmap(getChildByName(_local27.key));
				if(_local18 == null) {
					_local18 = new TextBitmap();
					addChild(_local18);
				}
				_local18.name = _local27.key;
				_local18.text = _local27.name + ": " + _local27.lives;
				_local18.y = lifes.y + lifes.height + 2 + _local14 * (lifes.height + 2);
				_local18.alignRight();
				_local14++;
				_local13 += 3;
			}
			oldXpLeft = _local5;
			oldBossesLeft = _local17;
			oldMiniBossesLeft = _local12;
			oldSpawnerLeft = _local11;
			oldCompleted = _local16;
			oldOptionalCompleted = _local25;
			oldUberRank = uberRank;
			if(g.time > scoreTime) {
				scoreTime = g.time + 1000;
				oldScore = _local7;
			}
		}
		
		public function CalculateUberRankFromLevel(level:Number) : Number {
			var _local2:int = uberMaxLevel - uberMinLevel;
			if(level <= uberMinLevel + _local2 * 0.9) {
				return (level - uberMinLevel) * uberTopRank / (_local2 * 0.9);
			}
			return (level - uberMinLevel - _local2 * 0.9) * uberTopRank / (_local2 * 0.1) + uberTopRank;
		}
		
		public function CalculateUberLevelFromRank(rank:Number) : Number {
			var _local2:Number = NaN;
			var _local3:int = uberMaxLevel - uberMinLevel;
			if(rank <= uberTopRank) {
				return uberMinLevel + _local3 * 0.9 * (rank / uberTopRank);
			}
			_local2 = uberMinLevel + _local3 * 0.9 + _local3 * 0.1 * ((rank - uberTopRank) / uberTopRank);
			return _local2 > uberMaxLevel ? uberMaxLevel : _local2;
		}
		
		public function CalculateUberDifficultyFromRank(rank:Number, originalLevel:Number) : Number {
			var _local3:Number = 1 / Math.pow(originalLevel,1.2);
			if(rank <= uberTopRank) {
				return 1 + uberDifficultyAtTopRank * (rank / uberTopRank) * _local3;
			}
			return 1 + uberDifficultyAtTopRank * _local3 * Math.pow(1.2,rank - uberTopRank);
		}
		
		public function getMyLives() : int {
			return lives[g.me.id];
		}
	}
}

