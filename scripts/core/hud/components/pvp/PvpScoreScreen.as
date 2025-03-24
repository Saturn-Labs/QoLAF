package core.hud.components.pvp {
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.Text;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	
	public class PvpScoreScreen extends PvpScreen {
		private var leaveButton:Button;
		
		private var addedItems:Vector.<PvpScoreHolder>;
		
		private var scrollArea:ScrollContainer;
		
		private var mainBody:Sprite;
		
		private var infoBox:Box;
		
		private var rewardBox:Box;
		
		private var contentBody:Sprite;
		
		public function PvpScoreScreen(g:Game) {
			super(g);
		}
		
		override public function load() : void {
			super.load();
			if(g.pvpManager != null) {
				g.pvpManager.scoreListUpdated = true;
			}
			leaveButton = new Button(showConfirmDialog,Localize.t("Leave Match"),"negative");
			leaveButton.x = 560;
			leaveButton.y = 520;
			addChild(leaveButton);
		}
		
		private function leaveMatch() : void {
			g.send("leavePvpMatch");
		}
		
		private function showConfirmDialog(e:TouchEvent) : void {
			var _local2:String = null;
			if(g.pvpManager.matchEnded == false) {
				_local2 = "Are you sure you want to leave? You will lose rating as if you lost the match!";
				g.showConfirmDialog(_local2,leaveMatch);
			} else {
				leaveMatch();
			}
		}
		
		override public function unload() : void {
			for each(var _local1 in addedItems) {
				if(mainBody.contains(_local1.img)) {
					mainBody.removeChild(_local1.img);
				}
			}
			addedItems = new Vector.<PvpScoreHolder>();
		}
		
		override public function update() : void {
			var _local1:* = undefined;
			if(!g.pvpManager.scoreListUpdated) {
				return;
			}
			g.pvpManager.scoreListUpdated = false;
			if(contentBody != null && contains(contentBody)) {
				removeChild(contentBody);
			}
			addedItems = new Vector.<PvpScoreHolder>();
			contentBody = new Sprite();
			mainBody = new Sprite();
			addChild(contentBody);
			var _local4:int = 70;
			var _local6:int = 0;
			if(g.pvpManager != null && g.pvpManager.matchEnded) {
				addInfoBox(_local4,_local6);
				addRewardBox(_local4,_local6);
				_local6 = 220;
			} else {
				_local6 = 40;
			}
			var _local7:Text = new Text();
			if(g.solarSystem.type == "pvp dom") {
				_local7.text = Localize.t("Team");
			} else {
				_local7.text = Localize.t("Rank");
			}
			_local7.x = _local4;
			_local7.y = _local6;
			_local7.color = 0x55ff55;
			_local7.size = 12;
			contentBody.addChild(_local7);
			_local4 += 60;
			_local7 = new Text();
			_local7.text = Localize.t("Name");
			_local7.x = _local4;
			_local7.y = _local6;
			_local7.color = 0x55ff55;
			_local7.size = 12;
			contentBody.addChild(_local7);
			_local4 += 160;
			if(g.solarSystem.type == "pvp dom") {
				_local4 -= 20;
				_local7 = new Text();
				_local7.text = Localize.t("Score");
				_local7.x = _local4;
				_local7.y = _local6;
				_local7.color = 0x55ff55;
				_local7.size = 12;
				contentBody.addChild(_local7);
				_local4 += 50;
				_local7 = new Text();
				_local7.text = Localize.t("Kills");
				_local7.x = _local4;
				_local7.y = _local6;
				_local7.color = 0x55ff55;
				_local7.size = 12;
				contentBody.addChild(_local7);
				_local4 += 50;
			} else {
				_local7 = new Text();
				_local7.text = Localize.t("Kills");
				_local7.x = _local4;
				_local7.y = _local6;
				_local7.color = 0x55ff55;
				_local7.size = 12;
				contentBody.addChild(_local7);
				_local4 += 50;
			}
			_local7 = new Text();
			_local7.text = Localize.t("Deaths");
			_local7.x = _local4;
			_local7.y = _local6;
			_local7.color = 0x55ff55;
			_local7.size = 12;
			contentBody.addChild(_local7);
			if(g.solarSystem.type == "pvp dom") {
				_local4 += 50;
			} else {
				_local4 += 70;
			}
			_local7 = new Text();
			_local7.text = Localize.t("Damage");
			_local7.x = _local4;
			_local7.y = _local6;
			_local7.color = 0x55ff55;
			_local7.size = 12;
			contentBody.addChild(_local7);
			_local4 += 80;
			_local7 = new Text();
			_local7.text = Localize.t("Reward Bonus");
			_local7.x = _local4;
			_local7.y = _local6;
			_local7.color = 0x5555ff;
			_local7.size = 12;
			contentBody.addChild(_local7);
			_local4 += 110;
			_local7 = new Text();
			_local7.text = Localize.t("Rating");
			_local7.x = _local4;
			_local7.y = _local6;
			_local7.color = 0x5555ff;
			_local7.size = 12;
			contentBody.addChild(_local7);
			_local4 += 60;
			_local6 += 30;
			scrollArea = new ScrollContainer();
			scrollArea.y = _local6;
			scrollArea.x = 4;
			scrollArea.width = 700;
			if(g.pvpManager != null && g.pvpManager.matchEnded) {
				scrollArea.height = 250;
			} else {
				scrollArea.height = 430;
			}
			_local1 = g.pvpManager.getScoreList();
			if(_local1 == null || _local1.length == 0) {
				return;
			}
			_local6 = 10;
			var _local2:Boolean = false;
			var _local5:Boolean = false;
			if(g.pvpManager is DominationManager) {
				_local2 = true;
			}
			for each(var _local3 in _local1) {
				_local3.load();
				_local3.img.x = 60;
				_local3.img.y = _local6;
				if(_local2) {
					if(g.me.team == _local3.team) {
						_local5 = true;
					} else {
						_local5 = false;
					}
				}
				_local3.update(_local2,_local5);
				mainBody.addChild(_local3.img);
				addedItems.push(_local3);
				_local6 = _local6 + _local3.img.height + 5;
			}
			contentBody.addChild(scrollArea);
			scrollArea.addChild(mainBody);
		}
		
		private function addInfoBox(x:int, y:int) : void {
			var _local3:PvpScoreHolder = g.pvpManager.getScoreItem(g.me.id);
			if(infoBox != null && contains(infoBox)) {
				removeChild(infoBox);
			}
			infoBox = new Box(280,140,"highlight",0.5,10);
			infoBox.x = x - 10;
			infoBox.y = y + 60;
			addChild(infoBox);
			var _local5:Text = new Text();
			_local5.text = Localize.t("Achievement");
			_local5.x = 0;
			_local5.y = 0;
			_local5.color = 0x5555ff;
			_local5.size = 14;
			infoBox.addChild(_local5);
			_local5 = new Text();
			_local5.text = Localize.t("Bonus");
			_local5.x = 100;
			_local5.y = 0;
			_local5.color = 0x5555ff;
			_local5.size = 14;
			infoBox.addChild(_local5);
			if(_local3 == null) {
				return;
			}
			var _local4:int = 20;
			if(_local3.afk == true) {
				_local5 = new Text();
				_local5.text = Localize.t("Inactive/Afk") + ":";
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = "-100%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
				Game.trackEvent("pvp","afk",g.me.name);
				return;
			}
			if(_local3.first > 0) {
				_local5 = new Text();
				if(g.pvpManager is DominationManager) {
					_local5.text = Localize.t("Victory") + ":";
				} else {
					_local5.text = Localize.t("First place") + ":";
				}
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = _local3.first.toString() + "%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
			if(_local3.second > 0) {
				_local5 = new Text();
				_local5.text = Localize.t("Second place") + ":";
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = _local3.second.toString() + "%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
			if(_local3.third > 0) {
				_local5 = new Text();
				_local5.text = Localize.t("Third place") + ":";
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = _local3.third.toString() + "%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
			if(_local3.hotStreak3 > 0) {
				_local5 = new Text();
				_local5.text = Localize.t("Hot Streak x3") + ":";
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = _local3.hotStreak3.toString() + "%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
			if(_local3.hotStreak10 > 0) {
				_local5 = new Text();
				_local5.text = Localize.t("Hot Streak x10") + ":";
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = _local3.hotStreak10.toString() + "%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
			if(_local3.noDeaths > 0) {
				_local5 = new Text();
				_local5.text = Localize.t("Undying") + ":";
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = _local3.noDeaths.toString() + "%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
			if(_local3.capZone > 0) {
				_local5 = new Text();
				_local5.text = Localize.t("Successful Assult") + ":";
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = _local3.capZone.toString() + "%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
			if(_local3.defZone > 0) {
				_local5 = new Text();
				_local5.text = Localize.t("Dedicated Defence") + ":";
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = _local3.defZone.toString() + "%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
			if(_local3.brokeKillingSpree > 0) {
				_local5 = new Text();
				_local5.text = Localize.t("Broke a Spree") + ":";
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = _local3.brokeKillingSpree.toString() + "%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
			if(_local3.pickups > 0) {
				_local5 = new Text();
				_local5.text = Localize.t("Pickup Bonus") + ":";
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local5 = new Text();
				_local5.text = _local3.pickups.toString() + "%";
				_local5.x = 220;
				_local5.y = _local4;
				_local5.color = 0x5555ff;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
			if(_local3.dailyBonus >= 0) {
				_local5 = new Text();
				_local5.text = Localize.t("Daily Bonus Reward!");
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x33ff33;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
				_local5 = new Text();
				_local5.text = "(" + _local3.dailyBonus + Localize.t("x matches left today)");
				_local5.x = 5;
				_local5.y = _local4;
				_local5.color = 0x33ff33;
				_local5.size = 12;
				infoBox.addChild(_local5);
				_local4 += 16;
			}
		}
		
		private function addRewardBox(x:int, y:int) : void {
			var _local9:Number = NaN;
			var _local3:PvpScoreHolder = g.pvpManager.getScoreItem(g.me.id);
			if(rewardBox != null && contains(rewardBox)) {
				removeChild(rewardBox);
			}
			var _local7:Number = 0.5;
			if(g.solarSystem.type == "pvp dm") {
				_local7 = 2;
			} else if(g.solarSystem.type == "pvp dom") {
				_local7 = 2;
			}
			rewardBox = new Box(280,140,"highlight",0.5,10);
			rewardBox.x = x + 320;
			rewardBox.y = y + 60;
			addChild(rewardBox);
			var _local8:Text = new Text();
			_local8.y = 0;
			_local8.color = 0x5555ff;
			_local8.size = 14;
			if(_local3.dailyBonus >= 0) {
				_local8.x = 10;
				_local8.htmlText = Localize.t("Reward <font color=\'#33ff33\'>(Daily Bonus)</font>");
				_local9 = 0;
				if(g.solarSystem.type == "pvp dm") {
					_local9 = 2;
				} else if(g.solarSystem.type == "pvp dom") {
					_local9 = 2;
				} else {
					_local9 = 0.5;
				}
			} else {
				_local8.x = 50;
				_local8.htmlText = Localize.t("Reward");
			}
			rewardBox.addChild(_local8);
			if(_local3 == null) {
				return;
			}
			if(_local3.afk == true) {
				return;
			}
			var _local6:int = 20;
			_local8 = new Text();
			_local8.text = Localize.t("XP") + ":";
			_local8.x = 5;
			_local8.y = _local6;
			_local8.color = 0x5555ff;
			_local8.size = 12;
			rewardBox.addChild(_local8);
			_local8 = new Text();
			_local8.color = 0x5555ff;
			_local8.alignRight();
			_local8.x = 285;
			_local8.y = _local6;
			_local8.size = 12;
			var _local4:int = Math.ceil(0.01 * _local3.bonusPercent * _local7 * (32 * g.me.level + 158 + _local3.xpSum));
			var _local5:int = Math.ceil(0.01 * _local3.bonusPercent * _local9 * (32 * g.me.level + 158 + _local3.xpSum));
			_local4 = Math.ceil(_local4 * (0.2 + 8 / (10 + (g.me.level - 1))));
			_local5 = Math.ceil(_local5 * (0.2 + 8 / (10 + (g.me.level - 1))));
			if(g.me.hasExpBoost) {
				_local4 = Math.ceil(_local4 * (1 + 0.3));
				_local5 = Math.ceil(_local5 * (1 + 0.3));
			}
			if(_local3.dailyBonus >= 0) {
				_local8.htmlText = _local4 + " <font color=\'#33ff33\'>(" + _local5 + ")</font>";
			} else {
				_local8.htmlText = _local4.toString();
			}
			rewardBox.addChild(_local8);
			_local6 += 16;
			_local8 = new Text();
			_local8.text = Localize.t("Steel") + ":";
			_local8.x = 5;
			_local8.y = _local6;
			_local8.color = 0x5555ff;
			_local8.size = 12;
			rewardBox.addChild(_local8);
			_local8 = new Text();
			_local8.color = 0x5555ff;
			_local8.alignRight();
			_local8.x = 285;
			_local8.y = _local6;
			_local8.size = 12;
			if(_local3.dailyBonus >= 0) {
				_local8.htmlText = int(Math.ceil(0.01 * _local3.bonusPercent * _local7 * (12 * g.me.level + 138 + _local3.steelSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _local3.bonusPercent * _local9 * (12 * g.me.level + 138 + _local3.steelSum))) + ")</font>";
			} else {
				_local8.htmlText = int(Math.ceil(0.01 * _local3.bonusPercent * _local7 * (12 * g.me.level + 138 + _local3.steelSum))).toString();
			}
			rewardBox.addChild(_local8);
			_local6 += 16;
			_local8 = new Text();
			_local8.text = Localize.t("Hyrdogen Crystals") + ":";
			_local8.x = 5;
			_local8.y = _local6;
			_local8.color = 0x5555ff;
			_local8.size = 12;
			rewardBox.addChild(_local8);
			_local8 = new Text();
			_local8.color = 0x5555ff;
			_local8.alignRight();
			_local8.x = 285;
			_local8.y = _local6;
			_local8.size = 12;
			if(_local3.dailyBonus >= 0) {
				_local8.htmlText = int(Math.ceil(0.01 * _local3.bonusPercent * _local7 * (3 * g.me.level + 52 + _local3.hydrogenSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _local3.bonusPercent * _local9 * (3 * g.me.level + 52 + _local3.hydrogenSum))) + ")</font>";
			} else {
				_local8.htmlText = int(Math.ceil(0.01 * _local3.bonusPercent * _local7 * (3 * g.me.level + 52 + _local3.hydrogenSum))).toString();
			}
			rewardBox.addChild(_local8);
			_local6 += 16;
			_local8 = new Text();
			_local8.text = Localize.t("Plasma Fluid") + ":";
			_local8.x = 5;
			_local8.y = _local6;
			_local8.color = 0x5555ff;
			_local8.size = 12;
			rewardBox.addChild(_local8);
			_local8 = new Text();
			_local8.color = 0x5555ff;
			_local8.alignRight();
			_local8.x = 285;
			_local8.y = _local6;
			_local8.size = 12;
			if(_local3.dailyBonus >= 0) {
				_local8.htmlText = int(Math.ceil(0.01 * _local3.bonusPercent * _local7 * (2.5 * g.me.level + 40 + _local3.plasmaSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _local3.bonusPercent * _local9 * (2.5 * g.me.level + 40 + _local3.plasmaSum))) + ")</font>";
			} else {
				_local8.htmlText = int(Math.ceil(0.01 * _local3.bonusPercent * _local7 * (2.5 * g.me.level + 40 + _local3.plasmaSum))).toString();
			}
			rewardBox.addChild(_local8);
			_local6 += 16;
			_local8 = new Text();
			_local8.text = Localize.t("Iridium") + ":";
			_local8.x = 5;
			_local8.y = _local6;
			_local8.color = 0x5555ff;
			_local8.size = 12;
			rewardBox.addChild(_local8);
			_local8 = new Text();
			_local8.color = 0x5555ff;
			_local8.alignRight();
			_local8.x = 285;
			_local8.y = _local6;
			_local8.size = 12;
			if(_local3.dailyBonus >= 0) {
				_local8.htmlText = int(Math.ceil(0.01 * _local3.bonusPercent * _local7 * (2 * g.me.level + 28 + _local3.iridiumSum))).toString() + " <font color=\'#33ff33\'>(" + int(Math.ceil(0.01 * _local3.bonusPercent * _local9 * (2 * g.me.level + 28 + _local3.iridiumSum))) + ")</font>";
			} else {
				_local8.htmlText = int(Math.ceil(0.01 * _local3.bonusPercent * _local7 * (2 * g.me.level + 28 + _local3.iridiumSum))).toString();
			}
			rewardBox.addChild(_local8);
			_local6 += 16;
		}
	}
}

