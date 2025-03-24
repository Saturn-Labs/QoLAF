package core.hud.components.pvp {
	import core.hud.components.Text;
	import core.hud.components.map.Map;
	import core.player.Player;
	import core.scene.Game;
	import core.states.gameStates.PvpScreenState;
	import playerio.Message;
	import starling.events.Event;
	
	public class PvpManager {
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
		
		public function PvpManager(g:Game, addTexts:Boolean = true) {
			super();
			g.addMessageHandler("setHostile",m_setHostile);
			g.addMessageHandler("pvpInitPlayers",m_pvpInitPlayers);
			g.addMessageHandler("gameEnded",m_gameEnded);
			g.addMessageHandler("updateScore",m_updateScore);
			g.addMessageHandler("usingQuad",m_startQuad);
			scoreList = new Vector.<PvpScoreHolder>();
			scoreListUpdated = false;
			matchEnded = false;
			matchState = 0;
			matchStartTime = 0;
			matchEndTime = 0;
			if(addTexts) {
				timerText = new Text();
				timerText.htmlText = "Starting in: <FONT COLOR=\'#7777ff\'>x:xx</FONT>";
				timerText.alignLeft();
				timerText.size = 16;
				timerText.color = 0x55ff55;
				g.addChildToOverlay(timerText);
				scoreText = new Text();
				scoreText.htmlText = "Frags Left: <FONT COLOR=\'#7777ff\'>xx</FONT>";
				scoreText.alignRight();
				scoreText.size = 16;
				scoreText.color = 0x55ff55;
				g.addChildToOverlay(scoreText);
				leaderText = new Text();
				leaderText.htmlText = "Leader: <FONT COLOR=\'#7777ff\'>None</FONT>";
				leaderText.alignLeft();
				leaderText.size = 16;
				leaderText.color = 0x55ff55;
				g.addChildToOverlay(leaderText);
			}
			roomStartTime = 0;
			requestTime = g.time;
			map = new Map(g);
			g.addChildToOverlay(map);
			g.addResizeListener(resize);
			this.g = g;
			resize();
		}
		
		private static function compareFunction(psh1:PvpScoreHolder, psh2:PvpScoreHolder) : int {
			if(psh1.score < psh2.score) {
				return 1;
			}
			if(psh1.score > psh2.score) {
				return -1;
			}
			if(psh1.deaths > psh2.deaths) {
				return 1;
			}
			if(psh1.deaths < psh2.deaths) {
				return -1;
			}
			if(psh1.damageSum < psh2.damageSum) {
				return 1;
			}
			if(psh1.damageSum > psh2.damageSum) {
				return -1;
			}
			return 1;
		}
		
		public function updateMap(p:Player) : void {
			map.playerJoined(p);
		}
		
		public function addZones(items:Array) : void {
		}
		
		public function formatTime(time:Number) : String {
			if(time < 0 || time.toString() == "NaN") {
				return "0:00";
			}
			var _local3:int = time;
			var _local2:int = _local3 % (60);
			_local3 = (_local3 - _local2) / (60);
			if(_local2 < 2) {
				return _local3 + ":01";
			}
			if(_local2 < 10) {
				return _local3 + ":0" + _local2;
			}
			return _local3 + ":" + _local2;
		}
		
		protected function loadMap() : void {
			map.load(0.035,160,160,0,0,true);
			isLoaded = true;
		}
		
		public function update() : void {
			if(!isLoaded) {
				loadMap();
			}
			if(requestTime < g.time && (roomStartTime == 0 || g.playerManager.players.length > scoreList.length)) {
				requestTime = g.time + 2000;
				g.send("requestInitPlayers");
			}
			map.update();
			switch(matchState) {
				case 0:
					if(timerText != null) {
						timerText.htmlText = "Starting in: <FONT COLOR=\'#7777ff\'>" + formatTime((matchStartTime - g.time) / 1000) + "</FONT>";
						scoreText.htmlText = "Frags Left: <FONT COLOR=\'#7777ff\'>" + scoreLimit + "</FONT>";
						leaderText.htmlText = "Leader: <FONT COLOR=\'#7777ff\'>None</FONT>";
					}
					if(matchStartTime != 0 && matchStartTime < g.time) {
						matchState = 2;
						g.textManager.createPvpText("The Match begins! Fight!",0,50);
					}
					for each(var _local1 in g.playerManager.players) {
						_local1.inSafeZone = true;
					}
					break;
				case 2:
					if(timerText != null) {
						timerText.htmlText = "Time Left: <FONT COLOR=\'#7777ff\'>" + formatTime((matchEndTime - g.time) / 1000) + "</FONT>";
						if(scoreList.length > 0) {
							scoreText.htmlText = "Frags Left: <FONT COLOR=\'#7777ff\'>" + (scoreLimit - scoreList[0].score).toString() + "</FONT>";
							if(scoreList[0].playerKey == g.me.id) {
								leaderText.htmlText = "Leader: <FONT COLOR=\'#7777ff\'>You</FONT>";
							} else {
								leaderText.htmlText = "Leader: <FONT COLOR=\'#7777ff\'>" + scoreList[0].playerName + "</FONT>";
							}
						}
					}
					if(matchEndTime != 0 && matchEndTime < g.time) {
						matchState = 3;
						matchEnded = true;
					}
					break;
				case 3:
					if(timerText != null) {
						timerText.htmlText = "Closing in: <FONT COLOR=\'#7777ff\'>" + formatTime((roomEndTime - g.time) / 1000) + "</FONT>";
						scoreText.htmlText = "<FONT COLOR=\'#7777ff\'>Game over!</FONT>";
						if(scoreList.length == 1) {
							if(scoreList[0].playerKey == g.me.id) {
								leaderText.htmlText = "Winner: <FONT COLOR=\'#7777ff\'>You</FONT>";
							} else {
								leaderText.htmlText = "Winner: <FONT COLOR=\'#7777ff\'>" + scoreList[0].playerName + "</FONT>";
							}
						}
					}
					if(endGameScreenTime != 0 && endGameScreenTime < g.time) {
						g.enterState(new PvpScreenState(g));
						endGameScreenTime = g.time + 60 * 1000;
					}
					if(roomEndTime != 0 && roomEndTime < g.time) {
						matchState = 4;
					}
			}
		}
		
		public function hideText() : void {
			timerText.visible = false;
			scoreText.visible = false;
			leaderText.visible = false;
		}
		
		public function showText() : void {
			timerText.visible = true;
			scoreText.visible = true;
			leaderText.visible = true;
		}
		
		protected function m_gameEnded(m:Message) : void {
			var _local5:Number = NaN;
			var _local4:int = 0;
			matchEndTime = m.getNumber(_local4++);
			endGameScreenTime = matchEndTime + 5000;
			roomEndTime = m.getNumber(_local4++);
			saveScore(m,_local4);
			for each(var _local2 in g.playerManager.players) {
				if(_local2.ship != null) {
					_local2.ship.hp = _local2.ship.hpMax;
					_local2.ship.shieldHp = _local2.ship.shieldHpMax;
				}
			}
			if(scoreList.length > 0) {
				if(scoreList[0].playerKey == g.me.id) {
					g.textManager.createPvpText("The Match has Ended!",-50);
					g.textManager.createPvpText("You won with " + scoreList[0].score + " points!");
					if(g.solarSystem.type == "pvp arena") {
						Game.trackEvent("pvp","pvp arena won",g.me.name,scoreList[0].score);
					} else if(g.solarSystem.type == "pvp dm") {
						Game.trackEvent("pvp","pvp dm won",g.me.name,g.me.level);
					} else if(g.solarSystem.type == "pvp dom") {
						Game.trackEvent("pvp","pvp dom won",g.me.name,g.me.level);
					}
					if(scoreList[0].deaths == 0) {
						g.textManager.createPvpText("Flawless victory!",-110,50);
					}
				} else {
					g.textManager.createPvpText("The Match has Ended!",-50);
					g.textManager.createPvpText(scoreList[0].playerName + " won with " + scoreList[0].score + " points!");
				}
			}
			var _local3:PvpScoreHolder = getScoreHolder(g.me.id,g.me.name);
			if(_local3 == null) {
				return;
			}
			if(_local3.deaths == 0) {
				_local5 = _local3.kills * 2;
			} else {
				_local5 = _local3.kills / _local3.deaths;
			}
			Game.trackEvent("pvp","match stats",g.me.level.toString(),_local5);
		}
		
		protected function m_updateScore(m:Message) : void {
			saveScore(m,0);
		}
		
		protected function saveScore(m:Message, startIndex:int) : void {
			var _local6:* = 0;
			var _local8:String = null;
			var _local5:String = null;
			var _local7:int = 0;
			var _local4:PvpScoreHolder = null;
			var _local3:Player = null;
			_local6 = startIndex;
			while(_local6 < m.length) {
				_local8 = m.getString(_local6++);
				_local5 = m.getString(_local6++);
				_local7 = m.getInt(_local6++);
				_local4 = getScoreHolder(_local8,_local5);
				if(_local4 == null) {
					return;
				}
				if(g.playerManager && g.playerManager.playersById) {
					_local3 = g.playerManager.playersById[_local8];
					if(_local3 != null) {
						_local3.team = _local7;
					}
				}
				_local4.team = _local7;
				_local4.rank = m.getInt(_local6++);
				_local4.score = m.getInt(_local6++);
				_local4.kills = m.getInt(_local6++);
				_local4.deaths = m.getInt(_local6++);
				_local4.xpSum = m.getInt(_local6++);
				_local4.steelSum = m.getInt(_local6++);
				_local4.hydrogenSum = m.getInt(_local6++);
				_local4.plasmaSum = m.getInt(_local6++);
				_local4.iridiumSum = m.getInt(_local6++);
				_local4.damageSum = m.getInt(_local6++);
				_local4.healingSum = m.getInt(_local6++);
				_local4.bonusPercent = m.getInt(_local6++);
				_local4.first = m.getInt(_local6++);
				_local4.second = m.getInt(_local6++);
				_local4.third = m.getInt(_local6++);
				_local4.hotStreak3 = m.getInt(_local6++);
				_local4.hotStreak10 = m.getInt(_local6++);
				_local4.noDeaths = m.getInt(_local6++);
				_local4.capZone = m.getInt(_local6++);
				_local4.defZone = m.getInt(_local6++);
				_local4.brokeKillingSpree = m.getInt(_local6++);
				_local4.pickups = m.getInt(_local6++);
				_local4.rating = m.getNumber(_local6++);
				_local4.ratingChange = m.getNumber(_local6++);
				_local4.dailyBonus = m.getInt(_local6++);
				_local4.afk = m.getBoolean(_local6);
				_local6++;
			}
			scoreList.sort(compareFunction);
			_local6 = 0;
			while(_local6 < scoreList.length) {
				scoreList[_local6].rank = _local6 + 1;
				_local6++;
			}
			scoreListUpdated = true;
		}
		
		public function addDamage(key:String, dmg:int) : void {
			var _local3:PvpScoreHolder = getScoreItem(key);
			if(_local3 != null) {
				_local3.addDamage(dmg);
			}
			scoreListUpdated = true;
		}
		
		public function addHealing(key:String, heal:int) : void {
			var _local3:PvpScoreHolder = getScoreItem(key);
			if(_local3 != null) {
				_local3.addHealing(heal);
			}
			scoreListUpdated = true;
		}
		
		public function getScoreItem(key:String) : PvpScoreHolder {
			for each(var _local2 in scoreList) {
				if(_local2.playerKey == key) {
					return _local2;
				}
			}
			return null;
		}
		
		public function getScoreList() : Vector.<PvpScoreHolder> {
			return scoreList;
		}
		
		public function getScoreHolder(key:String, name:String) : PvpScoreHolder {
			for each(var _local3 in scoreList) {
				if(_local3.playerKey == key) {
					return _local3;
				}
			}
			if(g.me == null) {
				return null;
			}
			_local3 = new PvpScoreHolder(key,name,key == g.me.id,type);
			scoreList.push(_local3);
			return _local3;
		}
		
		private function m_pvpInitPlayers(m:Message) : void {
			var _local8:String = null;
			var _local4:String = null;
			var _local7:int = 0;
			var _local2:Player = null;
			var _local3:PvpScoreHolder = null;
			var _local5:int = 0;
			type = m.getString(_local5++);
			scoreLimit = m.getInt(_local5++);
			var _local6:int = m.getInt(_local5++);
			if(_local6 > 0) {
				matchState = _local6;
			}
			roomStartTime = m.getNumber(_local5++);
			matchStartTime = m.getNumber(_local5++);
			matchEndTime = m.getNumber(_local5++);
			endGameScreenTime = matchEndTime + 5000;
			roomEndTime = m.getNumber(_local5++);
			_local5;
			while(_local5 < m.length) {
				_local8 = m.getString(_local5++);
				_local4 = m.getString(_local5++);
				_local7 = m.getInt(_local5);
				_local2 = g.playerManager.playersById[_local8];
				if(_local2 != null) {
					_local2.team = _local7;
				}
				_local3 = getScoreHolder(_local8,_local4);
				_local3.team = _local7;
				_local5++;
			}
			scoreList.sort(compareFunction);
		}
		
		private function m_startQuad(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local2:Number = m.getNumber(1);
			var _local4:Player = g.playerManager.playersById[_local3];
			if(_local4 == null || _local4.ship == null) {
				return;
			}
			_local4.ship.useQuad(_local2);
		}
		
		private function m_setHostile(m:Message) : void {
			var _local3:String = null;
			var _local4:Player = null;
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < m.length - 1) {
				_local3 = m.getString(_local2);
				_local4 = g.playerManager.playersById[_local3];
				if(_local4 != null) {
					_local4.isHostile = m.getBoolean(_local2 + 1);
				}
				_local2 += 2;
			}
		}
		
		public function resize(e:Event = null) : void {
			if(timerText != null) {
				timerText.y = 25;
				timerText.x = 0.5 * g.stage.stageWidth - 214;
			}
			if(scoreText != null) {
				scoreText.x = 0.5 * g.stage.stageWidth + 40;
				scoreText.y = timerText.y;
			}
			if(leaderText != null) {
				leaderText.x = 0.5 * g.stage.stageWidth + 52;
				leaderText.y = scoreText.y;
			}
			if(map != null) {
				map.x = 0;
				map.y = g.stage.stageHeight - 170;
			}
		}
	}
}

