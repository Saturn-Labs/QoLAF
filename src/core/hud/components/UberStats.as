package core.hud.components
{
	import core.scene.Game;
	import flash.utils.Dictionary;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class UberStats extends Sprite
	{
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
		private var lives:Dictionary;
		
		private var rankText:TextField;
		
		private var challengeText:TextBitmap;
		
		private var missionText:TextField;
		
		private var optionalMissionText:TextField;
		
		private var xpText:TextField;
		
		private var optionalText:TextBitmap;
		
		private var scoreText:TextField;
		
		private var highscoreText:TextField;
		
		private var lifes:TextBitmap;
		
		private var oldCompleted:Boolean = false;
		private var oldOptionalCompleted:Boolean = false;
		public function UberStats(param1:Game)
		{
			lives = new Dictionary();
			rankText = new TextField(200, 20, "", new TextFormat("DAIDRR"));
			challengeText = new TextBitmap();
			missionText = new TextField(200, 20, "", new TextFormat("DAIDRR"));
			optionalMissionText = new TextField(200, 20, "", new TextFormat("DAIDRR"));
			xpText = new TextField(200, 20, "", new TextFormat("DAIDRR"));
			optionalText = new TextBitmap();
			scoreText = new TextField(200, 20, "", new TextFormat("DAIDRR"));
			highscoreText = new TextField(200, 20, "", new TextFormat("DAIDRR"));
			lifes = new TextBitmap();
			super();
			this.g = param1;
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
		
		public function update(param1:Message):void
		{
			var _loc22_:int = 0;
			var _loc24_:* = 0;
			var _loc9_:Object = null;
			var _loc3_:TextBitmap = null;
			var _loc27_:int = 0;
			uberRank = param1.getNumber(_loc27_++);
			uberLevel = param1.getNumber(_loc27_++);
			var _loc6_:int = param1.getInt(_loc27_++);
			var _loc5_:Number = param1.getNumber(_loc27_++);
			var _loc17_:Number = param1.getNumber(_loc27_++);
			var _loc12_:int = param1.getInt(_loc27_++);
			var _loc26_:int = param1.getInt(_loc27_++);
			var _loc15_:int = param1.getInt(_loc27_++);
			var _loc4_:int = param1.getInt(_loc27_++);
			var _loc20_:int = param1.getInt(_loc27_++);
			var _loc10_:int = param1.getInt(_loc27_++);
			var _loc2_:int = param1.getInt(_loc27_++);
			var _loc11_:String = param1.getString(_loc27_++);
			var _loc25_:String = param1.getString(_loc27_++);
			var _loc16_:Boolean = param1.getBoolean(_loc27_++);
			var _loc7_:Boolean = param1.getBoolean(_loc27_++);
			var _loc21_:int = param1.getInt(_loc27_++);
			var _loc18_:Array = [];
			if (uberRank == oldUberRank + 1)
			{
				g.textManager.createUberRankCompleteText("START RANK " + uberRank + "");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if (_loc16_ && !oldCompleted)
			{
				g.textManager.createUberRankCompleteText("RANK " + uberRank + " COMPLETE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if (_loc7_ && !oldOptionalCompleted && uberRank >= optionalRank)
			{
				g.textManager.createUberExtraLifeText("EXTRA LIFE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			if (oldScore < _loc17_ && _loc5_ > _loc17_)
			{
				g.textManager.createUberExtraLifeText("NEW HIGHSCORE!");
				SoundLocator.getService().play("5wAlzsUCPEKqX7tAdCw3UA");
			}
			var _loc13_:int = _loc12_ - _loc6_;
			var _loc19_:int = _loc15_ - _loc26_;
			var _loc14_:int = _loc20_ - _loc4_;
			var _loc8_:int = _loc2_ - _loc10_;
			if (_loc19_ < oldBossesLeft && (_loc25_ == "boss" && uberRank >= optionalRank || _loc11_ == "boss"))
			{
				g.textManager.createUberTaskText(_loc26_ + " of " + _loc15_ + " bosses destroyed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if (_loc14_ < oldMiniBossesLeft && (_loc25_ == "miniboss" && uberRank >= optionalRank || _loc11_ == "miniboss"))
			{
				g.textManager.createUberTaskText(_loc4_ + " of " + _loc20_ + " mini bosses killed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if (_loc8_ < oldSpawnerLeft && (_loc25_ == "spawner" && uberRank >= optionalRank || _loc11_ == "spawner"))
			{
				g.textManager.createUberTaskText(_loc10_ + " of " + _loc2_ + " spawners smashed!");
				SoundLocator.getService().play("F3RA7-UJ6EKLT6WeJyKq-w");
			}
			if (g.time > scoreTime && _loc5_ > oldScore)
			{
				g.textManager.createScoreText(_loc5_ - oldScore);
			}
			var _loc23_:String = "<FONT COLOR='#88FF88'>complete</FONT>";
			missionText.format.size = 14;
			missionText.format.color = Style.COLOR_HIGHLIGHT;
			missionText.format.horizontalAlign = "right";
			missionText.alignPivot("right");
			missionText.isHtmlText = true;
			if (_loc11_ == "boss")
			{
				missionText.text = "Bosses: <FONT COLOR='#FFFFFF'>" + (_loc19_ == 0 ? _loc23_ : _loc26_ + "<FONT SIZE='10' COLOR='#AAAAAA'>/ " + _loc15_) + "</FONT></FONT>";
			}
			else if (_loc11_ == "miniboss")
			{
				missionText.text = "Mini Bosses: <FONT COLOR='#FFFFFF'>" + (_loc14_ == 0 ? _loc23_ : _loc4_ + "<FONT SIZE='10' COLOR='#AAAAAA'>/ " + _loc20_) + "</FONT></FONT>";
			}
			else if (_loc11_ == "spawner")
			{
				missionText.text = "Spawners: <FONT COLOR='#FFFFFF'>" + (_loc8_ == 0 ? _loc23_ : _loc10_ + "<FONT SIZE='10' COLOR='#AAAAAA'>/ " + _loc2_) + "</FONT></FONT>";
			}
			else
			{
				missionText.text = "";
			}
			rankText.format.color = Style.COLOR_HIGHLIGHT;
			rankText.isHtmlText = true;
			rankText.format.horizontalAlign = "right";
			rankText.alignPivot("right");
			rankText.text = "Rank <FONT COLOR='#FFFFFF'>" + Math.floor(uberRank) + "</FONT>, Level > <FONT COLOR='#FFFFFF'>" + Math.floor(uberLevel) + "</FONT>";
			challengeText.format.color = 11184810;
			challengeText.y = rankText.y + rankText.height + 25;
			challengeText.alignRight();
			xpText.format.color = Style.COLOR_HIGHLIGHT;
			xpText.format.size = 14;
			xpText.isHtmlText = true;
			xpText.format.horizontalAlign = "right";
			xpText.alignPivot("right");
			xpText.text = "Troons: <FONT COLOR='#FFFFFF'>" + (_loc13_ == 0 ? _loc23_ : Math.floor(_loc6_ / 10) + "<FONT SIZE='10' COLOR='#AAAAAA'>/ " + Math.floor(_loc12_ / 10)) + "</FONT></FONT>";
			xpText.y = challengeText.y + challengeText.height + 5;
			missionText.y = xpText.y + xpText.height + 5;
			optionalText.text = "(extra life)";
			optionalText.format.color = 11184810;
			optionalText.y = missionText.y + missionText.height + 10;
			optionalText.alignRight();
			optionalMissionText.format.color = Style.COLOR_HIGHLIGHT;
			optionalMissionText.isHtmlText = true;
			optionalMissionText.format.horizontalAlign = "right";
			optionalMissionText.alignPivot("right");
			optionalMissionText.y = optionalText.y + optionalText.height + 5;
			if (_loc25_ == "boss")
			{
				optionalMissionText.text = "Bosses: <FONT COLOR='#FFFFFF'>" + (_loc19_ == 0 ? _loc23_ : _loc26_ + "<FONT SIZE='10' COLOR='#AAAAAA'>/ " + _loc15_) + "</FONT></FONT>";
			}
			else if (_loc25_ == "miniboss")
			{
				optionalMissionText.text = "Mini Bosses: <FONT COLOR='#FFFFFF'>" + (_loc14_ == 0 ? _loc23_ : _loc4_ + "<FONT SIZE='10' COLOR='#AAAAAA'>/ " + _loc20_) + "</FONT></FONT>";
			}
			else if (_loc25_ == "spawner")
			{
				optionalMissionText.text = "Spawners: <FONT COLOR='#FFFFFF'>" + (_loc8_ == 0 ? _loc23_ : _loc10_ + "<FONT SIZE='10' COLOR='#AAAAAA'>/ " + _loc2_) + "</FONT></FONT>";
			}
			if (uberRank >= optionalRank)
			{
				optionalText.visible = true;
				optionalMissionText.visible = true;
			}
			else
			{
				optionalText.visible = false;
				optionalMissionText.visible = false;
			}
			scoreText.format.color = Style.COLOR_HIGHLIGHT;
			scoreText.format.size = 16;
			scoreText.isHtmlText = true;
			scoreText.format.horizontalAlign = "right";
			scoreText.alignPivot("right");
			scoreText.text = "Total Troons: <FONT COLOR='#FF44aa'>" + Math.floor(_loc5_) + "</FONT>";
			scoreText.y = optionalMissionText.y + optionalMissionText.height + 25;
			highscoreText.format.color = Style.COLOR_HIGHLIGHT;
			highscoreText.isHtmlText = true;
			highscoreText.format.horizontalAlign = "right";
			highscoreText.alignPivot("right");
			highscoreText.text = "Highscore: <FONT COLOR='#FFFFFF'>" + Math.floor(_loc17_) + "</FONT>";
			highscoreText.y = scoreText.y + scoreText.height + 5;
			lifes.text = "Lives";
			lifes.format.color = 11184810;
			lifes.y = highscoreText.y + highscoreText.height + 25;
			lifes.alignRight();
			_loc22_ = 0;
			_loc24_ = _loc27_;
			while (_loc24_ < _loc27_ + 3 * _loc21_)
			{
				_loc9_ = {};
				_loc9_.key = param1.getString(_loc24_);
				_loc9_.name = param1.getString(_loc24_ + 1);
				_loc9_.lives = param1.getInt(_loc24_ + 2);
				lives[_loc9_.key] = _loc9_.lives;
				_loc18_.push(_loc9_);
				_loc3_ = TextBitmap(getChildByName(_loc9_.key));
				if (_loc3_ == null)
				{
					_loc3_ = new TextBitmap();
					addChild(_loc3_);
				}
				_loc3_.name = _loc9_.key;
				_loc3_.text = _loc9_.name + ": " + _loc9_.lives;
				_loc3_.y = lifes.y + lifes.height + 2 + _loc22_ * (lifes.height + 2);
				_loc3_.alignRight();
				_loc22_++;
				_loc24_ += 3;
			}
			oldXpLeft = _loc13_;
			oldBossesLeft = _loc19_;
			oldMiniBossesLeft = _loc14_;
			oldSpawnerLeft = _loc8_;
			oldCompleted = _loc16_;
			oldOptionalCompleted = _loc7_;
			oldUberRank = uberRank;
			if (g.time > scoreTime)
			{
				scoreTime = g.time + 1000;
				oldScore = _loc5_;
			}
		}
		
		public function CalculateUberRankFromLevel(param1:Number):Number
		{
			var _loc2_:int = uberMaxLevel - uberMinLevel;
			if (param1 <= uberMinLevel + _loc2_ * 0.9)
			{
				return (param1 - uberMinLevel) * uberTopRank / (_loc2_ * 0.9);
			}
			return (param1 - uberMinLevel - _loc2_ * 0.9) * uberTopRank / (_loc2_ * 0.1) + uberTopRank;
		}
		
		public function CalculateUberLevelFromRank(param1:Number):Number
		{
			var _loc2_:Number = NaN;
			var _loc3_:int = uberMaxLevel - uberMinLevel;
			if (param1 <= uberTopRank)
			{
				return uberMinLevel + _loc3_ * 0.9 * (param1 / uberTopRank);
			}
			_loc2_ = uberMinLevel + _loc3_ * 0.9 + _loc3_ * 0.1 * ((param1 - uberTopRank) / uberTopRank);
			return _loc2_ > uberMaxLevel ? uberMaxLevel : _loc2_;
		}
		
		public function CalculateUberDifficultyFromRank(param1:Number, param2:Number):Number
		{
			var _loc3_:Number = 1 / Math.pow(param2, 1.2);
			if (param1 <= uberTopRank)
			{
				return 1 + uberDifficultyAtTopRank * (param1 / uberTopRank) * _loc3_;
			}
			return 1 + uberDifficultyAtTopRank * _loc3_ * Math.pow(1.2, param1 - uberTopRank);
		}
		
		public function getMyLives():int
		{
			return lives[g.me.id];
		}
	}
}
