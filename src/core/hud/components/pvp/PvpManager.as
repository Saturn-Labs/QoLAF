package core.hud.components.pvp
{
	import core.hud.components.Text;
	import core.hud.components.map.Map;
	import core.player.Player;
	import core.scene.Game;
	import core.states.gameStates.PvpScreenState;
	import playerio.Message;
	import starling.events.Event;
	
	public class PvpManager
	{
		public static const MATCH_WARMUP:int = 0;
		public static const MATCH_STARTING:int = 1;
		public static const MATCH_RUNNING:int = 2;
		public static const MATCH_ENDED:int = 3;
		public static const MATCH_CLOSED:int = 4;
		public static const ITEM_HEALTH:String = "health";
		public static const ITEM_HEALTH_SMALL:String = "healthSmall";
		public static const ITEM_SHIELD:String = "shield";
		public static const ITEM_SHIELD_SMALL:String = "shieldSmall";
		public static const ITEM_QUAD:String = "quad";
		public static const ITEM_DOMINATION_ZONE:String = "dominationZone";
		public static const ITEM_TEAM1_SAFE_ZONE:String = "safezoneT1";
		public static const ITEM_TEAM2_SAFE_ZONE:String = "safezoneT2";
		protected var g:Game;
		
		public var type:String;
		
		protected var scoreLimit:int;
		
		protected var matchState:int;
		
		protected var roomStartTime:Number;
		
		protected var matchStartTime:Number;
		
		protected var matchEndTime:Number;
		
		protected var roomEndTime:Number;
		
		protected var endGameScreenTime:Number;
		
		protected var requestTime:Number;
		
		public var matchEnded:Boolean;
		
		public var scoreListUpdated:Boolean;
		
		protected var scoreList:Vector.<PvpScoreHolder>;
		
		protected var timerText:Text;
		
		protected var scoreText:Text;
		
		protected var leaderText:Text;
		
		protected var map:Map;
		
		protected var isLoaded:Boolean = false;
		public function PvpManager(param1:Game, param2:Boolean = true)
		{
			super();
			param1.addMessageHandler("setHostile", m_setHostile);
			param1.addMessageHandler("pvpInitPlayers", m_pvpInitPlayers);
			param1.addMessageHandler("gameEnded", m_gameEnded);
			param1.addMessageHandler("updateScore", m_updateScore);
			param1.addMessageHandler("usingQuad", m_startQuad);
			scoreList = new Vector.<PvpScoreHolder>();
			scoreListUpdated = false;
			matchEnded = false;
			matchState = 0;
			matchStartTime = 0;
			matchEndTime = 0;
			if (param2)
			{
				timerText = new Text();
				timerText.htmlText = "Starting in: <FONT COLOR='#7777ff'>x:xx</FONT>";
				timerText.alignLeft();
				timerText.size = 16;
				timerText.color = 5635925;
				param1.addChildToOverlay(timerText);
				scoreText = new Text();
				scoreText.htmlText = "Frags Left: <FONT COLOR='#7777ff'>xx</FONT>";
				scoreText.alignRight();
				scoreText.size = 16;
				scoreText.color = 5635925;
				param1.addChildToOverlay(scoreText);
				leaderText = new Text();
				leaderText.htmlText = "Leader: <FONT COLOR='#7777ff'>None</FONT>";
				leaderText.alignLeft();
				leaderText.size = 16;
				leaderText.color = 5635925;
				param1.addChildToOverlay(leaderText);
			}
			roomStartTime = 0;
			requestTime = param1.time;
			map = new Map(param1);
			param1.addChildToOverlay(map);
			param1.addResizeListener(resize);
			this.g = param1;
			resize();
		}
		
		private static function compareFunction(param1:PvpScoreHolder, param2:PvpScoreHolder):int
		{
			if (param1.score < param2.score)
			{
				return 1;
			}
			if (param1.score > param2.score)
			{
				return -1;
			}
			if (param1.deaths > param2.deaths)
			{
				return 1;
			}
			if (param1.deaths < param2.deaths)
			{
				return -1;
			}
			if (param1.damageSum < param2.damageSum)
			{
				return 1;
			}
			if (param1.damageSum > param2.damageSum)
			{
				return -1;
			}
			return 1;
		}
		
		public function updateMap(param1:Player):void
		{
			map.playerJoined(param1);
		}
		
		public function addZones(param1:Array):void
		{
		}
		
		public function formatTime(param1:Number):String
		{
			if (param1 < 0 || param1.toString() == "NaN")
			{
				return "0:00";
			}
			var _loc2_:int = param1;
			var _loc3_:int = _loc2_ % 60;
			_loc2_ = (_loc2_ - _loc3_) / 60;
			if (_loc3_ < 2)
			{
				return _loc2_ + ":01";
			}
			if (_loc3_ < 10)
			{
				return _loc2_ + ":0" + _loc3_;
			}
			return _loc2_ + ":" + _loc3_;
		}
		
		protected function loadMap():void
		{
			map.load(0.035, 160, 160, 0, 0, true);
			isLoaded = true;
		}
		
		public function update():void
		{
			if (!isLoaded)
			{
				loadMap();
			}
			if (requestTime < g.time && (roomStartTime == 0 || g.playerManager.players.length > scoreList.length))
			{
				requestTime = g.time + 2000;
				g.send("requestInitPlayers");
			}
			map.update();
			switch (matchState)
			{
			case 0: 
				if (timerText != null)
				{
					timerText.htmlText = "Starting in: <FONT COLOR='#7777ff'>" + formatTime((matchStartTime - g.time) / 1000) + "</FONT>";
					scoreText.htmlText = "Frags Left: <FONT COLOR='#7777ff'>" + scoreLimit + "</FONT>";
					leaderText.htmlText = "Leader: <FONT COLOR='#7777ff'>None</FONT>";
				}
				if (matchStartTime != 0 && matchStartTime < g.time)
				{
					matchState = 2;
					g.textManager.createPvpText("The Match begins! Fight!", 0, 50);
				}
				for each (var _loc1_:* in g.playerManager.players)
				{
					_loc1_.inSafeZone = true;
				}
				break;
			case 2: 
				if (timerText != null)
				{
					timerText.htmlText = "Time Left: <FONT COLOR='#7777ff'>" + formatTime((matchEndTime - g.time) / 1000) + "</FONT>";
					if (scoreList.length > 0)
					{
						scoreText.htmlText = "Frags Left: <FONT COLOR='#7777ff'>" + (scoreLimit - scoreList[0].score).toString() + "</FONT>";
						if (scoreList[0].playerKey == g.me.id)
						{
							leaderText.htmlText = "Leader: <FONT COLOR='#7777ff'>You</FONT>";
						}
						else
						{
							leaderText.htmlText = "Leader: <FONT COLOR='#7777ff'>" + scoreList[0].playerName + "</FONT>";
						}
					}
				}
				if (matchEndTime != 0 && matchEndTime < g.time)
				{
					matchState = 3;
					matchEnded = true;
				}
				break;
			case 3: 
				if (timerText != null)
				{
					timerText.htmlText = "Closing in: <FONT COLOR='#7777ff'>" + formatTime((roomEndTime - g.time) / 1000) + "</FONT>";
					scoreText.htmlText = "<FONT COLOR='#7777ff'>Game over!</FONT>";
					if (scoreList.length == 1)
					{
						if (scoreList[0].playerKey == g.me.id)
						{
							leaderText.htmlText = "Winner: <FONT COLOR='#7777ff'>You</FONT>";
						}
						else
						{
							leaderText.htmlText = "Winner: <FONT COLOR='#7777ff'>" + scoreList[0].playerName + "</FONT>";
						}
					}
				}
				if (endGameScreenTime != 0 && endGameScreenTime < g.time)
				{
					g.enterState(new PvpScreenState(g));
					endGameScreenTime = g.time + 60000;
				}
				if (roomEndTime != 0 && roomEndTime < g.time)
				{
					matchState = 4;
				}
			}
		}
		
		public function hideText():void
		{
			timerText.visible = false;
			scoreText.visible = false;
			leaderText.visible = false;
		}
		
		public function showText():void
		{
			timerText.visible = true;
			scoreText.visible = true;
			leaderText.visible = true;
		}
		
		protected function m_gameEnded(param1:Message):void
		{
			var _loc2_:Number = NaN;
			var _loc5_:int = 0;
			matchEndTime = param1.getNumber(_loc5_++);
			endGameScreenTime = matchEndTime + 5000;
			roomEndTime = param1.getNumber(_loc5_++);
			saveScore(param1, _loc5_);
			for each (var _loc4_:* in g.playerManager.players)
			{
				if (_loc4_.ship != null)
				{
					_loc4_.ship.hp = _loc4_.ship.hpMax;
					_loc4_.ship.shieldHp = _loc4_.ship.shieldHpMax;
				}
			}
			if (scoreList.length > 0)
			{
				if (scoreList[0].playerKey == g.me.id)
				{
					g.textManager.createPvpText("The Match has Ended!", -50);
					g.textManager.createPvpText("You won with " + scoreList[0].score + " points!");
					if (g.solarSystem.type == "pvp arena")
					{
						Game.trackEvent("pvp", "pvp arena won", g.me.name, scoreList[0].score);
					}
					else if (g.solarSystem.type == "pvp dm")
					{
						Game.trackEvent("pvp", "pvp dm won", g.me.name, g.me.level);
					}
					else if (g.solarSystem.type == "pvp dom")
					{
						Game.trackEvent("pvp", "pvp dom won", g.me.name, g.me.level);
					}
					if (scoreList[0].deaths == 0)
					{
						g.textManager.createPvpText("Flawless victory!", -110, 50);
					}
				}
				else
				{
					g.textManager.createPvpText("The Match has Ended!", -50);
					g.textManager.createPvpText(scoreList[0].playerName + " won with " + scoreList[0].score + " points!");
				}
			}
			var _loc3_:PvpScoreHolder = getScoreHolder(g.me.id, g.me.name);
			if (_loc3_ == null)
			{
				return;
			}
			if (_loc3_.deaths == 0)
			{
				_loc2_ = _loc3_.kills * 2;
			}
			else
			{
				_loc2_ = _loc3_.kills / _loc3_.deaths;
			}
			Game.trackEvent("pvp", "match stats", g.me.level.toString(), _loc2_);
		}
		
		protected function m_updateScore(param1:Message):void
		{
			saveScore(param1, 0);
		}
		
		protected function saveScore(param1:Message, param2:int):void
		{
			var _loc8_:* = 0;
			var _loc7_:String = null;
			var _loc5_:String = null;
			var _loc6_:int = 0;
			var _loc3_:PvpScoreHolder = null;
			var _loc4_:Player = null;
			_loc8_ = param2;
			while (_loc8_ < param1.length)
			{
				_loc7_ = param1.getString(_loc8_++);
				_loc5_ = param1.getString(_loc8_++);
				_loc6_ = param1.getInt(_loc8_++);
				_loc3_ = getScoreHolder(_loc7_, _loc5_);
				if (_loc3_ == null)
				{
					return;
				}
				if (g.playerManager && g.playerManager.playersById)
				{
					_loc4_ = g.playerManager.playersById[_loc7_];
					if (_loc4_ != null)
					{
						_loc4_.team = _loc6_;
					}
				}
				_loc3_.team = _loc6_;
				_loc3_.rank = param1.getInt(_loc8_++);
				_loc3_.score = param1.getInt(_loc8_++);
				_loc3_.kills = param1.getInt(_loc8_++);
				_loc3_.deaths = param1.getInt(_loc8_++);
				_loc3_.xpSum = param1.getInt(_loc8_++);
				_loc3_.steelSum = param1.getInt(_loc8_++);
				_loc3_.hydrogenSum = param1.getInt(_loc8_++);
				_loc3_.plasmaSum = param1.getInt(_loc8_++);
				_loc3_.iridiumSum = param1.getInt(_loc8_++);
				_loc3_.damageSum = param1.getInt(_loc8_++);
				_loc3_.healingSum = param1.getInt(_loc8_++);
				_loc3_.bonusPercent = param1.getInt(_loc8_++);
				_loc3_.first = param1.getInt(_loc8_++);
				_loc3_.second = param1.getInt(_loc8_++);
				_loc3_.third = param1.getInt(_loc8_++);
				_loc3_.hotStreak3 = param1.getInt(_loc8_++);
				_loc3_.hotStreak10 = param1.getInt(_loc8_++);
				_loc3_.noDeaths = param1.getInt(_loc8_++);
				_loc3_.capZone = param1.getInt(_loc8_++);
				_loc3_.defZone = param1.getInt(_loc8_++);
				_loc3_.brokeKillingSpree = param1.getInt(_loc8_++);
				_loc3_.pickups = param1.getInt(_loc8_++);
				_loc3_.rating = param1.getNumber(_loc8_++);
				_loc3_.ratingChange = param1.getNumber(_loc8_++);
				_loc3_.dailyBonus = param1.getInt(_loc8_++);
				_loc3_.afk = param1.getBoolean(_loc8_);
				_loc8_++;
			}
			scoreList.sort(compareFunction);
			_loc8_ = 0;
			while (_loc8_ < scoreList.length)
			{
				scoreList[_loc8_].rank = _loc8_ + 1;
				_loc8_++;
			}
			scoreListUpdated = true;
		}
		
		public function addDamage(param1:String, param2:int):void
		{
			var _loc3_:PvpScoreHolder = getScoreItem(param1);
			if (_loc3_ != null)
			{
				_loc3_.addDamage(param2);
			}
			scoreListUpdated = true;
		}
		
		public function addHealing(param1:String, param2:int):void
		{
			var _loc3_:PvpScoreHolder = getScoreItem(param1);
			if (_loc3_ != null)
			{
				_loc3_.addHealing(param2);
			}
			scoreListUpdated = true;
		}
		
		public function getScoreItem(param1:String):PvpScoreHolder
		{
			for each (var _loc2_:* in scoreList)
			{
				if (_loc2_.playerKey == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function getScoreList():Vector.<PvpScoreHolder>
		{
			return scoreList;
		}
		
		public function getScoreHolder(param1:String, param2:String):PvpScoreHolder
		{
			for each (var _loc3_:* in scoreList)
			{
				if (_loc3_.playerKey == param1)
				{
					return _loc3_;
				}
			}
			if (g.me == null)
			{
				return null;
			}
			_loc3_ = new PvpScoreHolder(param1, param2, param1 == g.me.id, type);
			scoreList.push(_loc3_);
			return _loc3_;
		}
		
		private function m_pvpInitPlayers(param1:Message):void
		{
			var _loc7_:String = null;
			var _loc4_:String = null;
			var _loc6_:int = 0;
			var _loc3_:Player = null;
			var _loc2_:PvpScoreHolder = null;
			var _loc8_:int = 0;
			type = param1.getString(_loc8_++);
			scoreLimit = param1.getInt(_loc8_++);
			var _loc5_:int = param1.getInt(_loc8_++);
			if (_loc5_ > 0)
			{
				matchState = _loc5_;
			}
			roomStartTime = param1.getNumber(_loc8_++);
			matchStartTime = param1.getNumber(_loc8_++);
			matchEndTime = param1.getNumber(_loc8_++);
			endGameScreenTime = matchEndTime + 5000;
			roomEndTime = param1.getNumber(_loc8_++);
			_loc8_;
			while (_loc8_ < param1.length)
			{
				_loc7_ = param1.getString(_loc8_++);
				_loc4_ = param1.getString(_loc8_++);
				_loc6_ = param1.getInt(_loc8_);
				_loc3_ = g.playerManager.playersById[_loc7_];
				if (_loc3_ != null)
				{
					_loc3_.team = _loc6_;
				}
				_loc2_ = getScoreHolder(_loc7_, _loc4_);
				_loc2_.team = _loc6_;
				_loc8_++;
			}
			scoreList.sort(compareFunction);
		}
		
		private function m_startQuad(param1:Message):void
		{
			var _loc3_:String = param1.getString(0);
			var _loc4_:Number = param1.getNumber(1);
			var _loc2_:Player = g.playerManager.playersById[_loc3_];
			if (_loc2_ == null || _loc2_.ship == null)
			{
				return;
			}
			_loc2_.ship.useQuad(_loc4_);
		}
		
		private function m_setHostile(param1:Message):void
		{
			var _loc3_:String = null;
			var _loc2_:Player = null;
			var _loc4_:int = 0;
			_loc4_ = 0;
			while (_loc4_ < param1.length - 1)
			{
				_loc3_ = param1.getString(_loc4_);
				_loc2_ = g.playerManager.playersById[_loc3_];
				if (_loc2_ != null)
				{
					_loc2_.isHostile = param1.getBoolean(_loc4_ + 1);
				}
				_loc4_ += 2;
			}
		}
		
		public function resize(param1:Event = null):void
		{
			if (timerText != null)
			{
				timerText.y = 25;
				timerText.x = 0.5 * g.stage.stageWidth - 214;
			}
			if (scoreText != null)
			{
				scoreText.x = 0.5 * g.stage.stageWidth + 40;
				scoreText.y = timerText.y;
			}
			if (leaderText != null)
			{
				leaderText.x = 0.5 * g.stage.stageWidth + 52;
				leaderText.y = scoreText.y;
			}
			if (map != null)
			{
				map.x = 0;
				map.y = g.stage.stageHeight - 170;
			}
		}
	}
}
