package core.hud.components.explore {
	import core.credits.CreditManager;
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.HudTimer;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.player.CrewMember;
	import core.player.Explore;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.solarSystem.Body;
	import debug.Console;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ExploreArea extends Sprite {
		public static var COLOR:uint = 3225899;
		private var min:Number = 0;
		private var max:Number = 1;
		private var value:Number = 0;
		private var _exploring:Boolean = false;
		private var finished:Boolean = false;
		private var failed:Boolean = false;
		private var successfulEvents:int = 0;
		private var totalEvents:int = 0;
		public var lootClaimed:Boolean = false;
		private var confirmInstantExploreBox:CreditBuyBox;
		private var actionButton:Button;
		public var body:Body;
		private var g:Game;
		private var timer:Timer = new Timer(1000,1);
		private var startTime:Number = 0;
		private var finishTime:Number = 0;
		private var failTime:Number = 0;
		private var areaTypes:Dictionary = areaTypes;
		private var playerExplores:Dictionary = playerExplores;
		public var areaKey:String;
		public var level:Number;
		public var rewardLevel:Number;
		public var size:int;
		private var areaName:TextBitmap;
		public var type:int;
		public var specialTypes:Array;
		private var teamKey:String = null;
		private var progressBar:ExploreProgressBar;
		private var box:Box;
		private var boxFinished:Box;
		private var exploreMapArea:ExploreMapArea;
		private var exploreTimer:HudTimer;
		private var overlay:Sprite;
		private var exploreStartedCallback:Function = null;
		
		public function ExploreArea(g:Game, expMap:ExploreMap, body:Body, areaKey:String, teamKey:String, level:Number, rewardLevel:Number, size:int, type:int, specialTypes:Array, name:String, successfulEvents:int, failed:Boolean, finished:Boolean, lootClaimed:Boolean, failTime:Number, finishTime:Number, startTime:Number) {
			this.level = level;
			this.rewardLevel = rewardLevel;
			this.size = size;
			this.type = type;
			this.specialTypes = specialTypes;
			this.name = name;
			this.g = g;
			this.body = body;
			this.areaKey = areaKey;
			this.teamKey = teamKey;
			this.finished = finished;
			this.failed = failed;
			this.successfulEvents = successfulEvents;
			this.totalEvents = size + 4;
			this.lootClaimed = lootClaimed;
			this.failTime = failTime;
			this.finishTime = finishTime;
			this.startTime = startTime;
			super();
			var _local22:String = "9iZrZ9p5nEWqrPhkxTYNgA";
			var _local23:* = 2868903748;
			exploreMapArea = expMap.getMapArea(areaKey);
			if(type == 0) {
				_local22 = "oGIhRDJPa0mDobL-DLecdA";
				_local23 = Area.COLORTYPE[0];
			} else if(type == 1) {
				_local22 = "xGIhC6OP6k-ynT1KpLQX3w";
				_local23 = Area.COLORTYPE[1];
			} else if(type == 2) {
				_local22 = "xGIhC6OP6k-ynT1KpLQX3w";
				_local23 = Area.COLORTYPE[2];
			}
			box = new Box(610,60,"light",0.95,12);
			addChild(box);
			areaName = new TextBitmap();
			areaName.size = 22;
			areaName.format.color = Area.COLORTYPE[type];
			areaName.text = name;
			areaName.x = 4;
			areaName.y = -6;
			addChild(areaName);
			while(areaName.width > 390) {
				areaName.size--;
			}
			var _local20:ITextureManager = TextureLocator.getService();
			var _local19:int = 0;
			addSkillIcon(_local20.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SKILLS[type]),_local19,Area.SKILLTYPE[type]);
			for each(var _local21:* in specialTypes) {
				_local19++;
				addSkillIcon(_local20.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SPECIALS[_local21]),_local19,Area.SPECIALTYPE[_local21]);
			}
			actionButton = new Button(null,"DEPLOY TEAM","positive");
			actionButton.y = 0;
			actionButton.x = 0;
			actionButton.size = 13;
			actionButton.visible = false;
			addChild(actionButton);
			progressBar = new ExploreProgressBar(g,body,progressBarOnComplete,type);
			progressBar.x = 6;
			progressBar.y = 36;
			addChild(progressBar);
			if(successfulEvents == 0 && failTime == 0) {
				handleNotStarted();
			} else if(!lootClaimed && failTime < g.time) {
				handleClaimLoot();
			} else if(successfulEvents < totalEvents && failTime < g.time) {
				handleFailed();
			} else if(finished && successfulEvents == totalEvents && failTime < g.time) {
				handleFinished();
			} else {
				resume();
			}
		}
		
		public function addSkillIcon(txt:Texture, i:int, toolTipText:String) : void {
			var _local5:Image = new Image(txt);
			_local5.x = areaName.x + areaName.width + 10 + 20 * i;
			_local5.y = 4;
			var _local4:Sprite = new Sprite();
			_local4.addChild(_local5);
			new ToolTip(g,_local4,toolTipText,null,"skill");
			addChild(_local4);
		}
		
		public function adjustTimeEstimate(value:Number) : Number {
			if(successfulEvents > 0) {
				value = value * (totalEvents - successfulEvents) / totalEvents;
			} else if(failTime != 0 && failTime > g.time) {
				value *= 1 - (g.time - startTime) / (finishTime - startTime);
			}
			return value;
		}
		
		public function updateExploreObj() : void {
			var _local1:Explore = g.me.getExploreByKey(areaKey);
			if(_local1 != null) {
				_local1.lootClaimed = true;
				_local1.finished = true;
				_local1.failed = true;
				_local1.finished = true;
			}
		}
		
		public function updateState(lootClaimed:Boolean) : void {
			this.lootClaimed = lootClaimed;
			if(successfulEvents < totalEvents) {
				failed = true;
			}
			if(successfulEvents == totalEvents) {
				finished = true;
			}
			updateExploreObj();
			if(successfulEvents == 0 && !failed && failTime < g.time) {
				handleNotStarted();
			} else if(!lootClaimed && failTime < g.time) {
				handleClaimLoot();
			} else if(successfulEvents < totalEvents && failTime < g.time) {
				handleFailed();
			} else if(finished && successfulEvents == totalEvents && failTime < g.time) {
				handleFinished();
			} else {
				resume();
			}
		}
		
		private function handleStarted() : void {
			adjustActionButton();
			actionButton.visible = false;
		}
		
		private function adjustActionButton() : void {
			actionButton.x = progressBar.x + progressBar.width + 10;
			actionButton.y = progressBar.y - 6;
			actionButton.visible = true;
		}
		
		private function progressBarOnComplete() : void {
			Console.write("progressBarOnComplete");
			actionButton.visible = true;
			actionButton.callback = showRewardScreen;
			if(exploreTimer != null && contains(exploreTimer)) {
				removeChild(exploreTimer);
			}
			actionButton.text = "CLAIM REWARD";
			adjustActionButton();
			actionButton.enabled = true;
		}
		
		private function handleClaimLoot() : void {
			Console.write("handle claim loot");
			progressBarOnComplete();
			progressBar.setValueAndEffect((successfulEvents + 1) / (totalEvents + 1),successfulEvents < totalEvents);
		}
		
		private function handleFailed() : void {
			Console.write("handle failed");
			actionButton.visible = true;
			progressBar.setValueAndEffect((successfulEvents + 1) / (totalEvents + 1),true);
			actionButton.callback = showSelectTeam;
			actionButton.text = "DEPLOY TEAM";
			adjustActionButton();
			actionButton.enabled = true;
		}
		
		private function handleNotStarted() : void {
			Console.write("hadnle not started");
			actionButton.visible = true;
			progressBar.setValueAndEffect(0);
			actionButton.callback = showSelectTeam;
			actionButton.text = "DEPLOY TEAM";
			adjustActionButton();
			actionButton.enabled = true;
		}
		
		public function handleFinished() : void {
			Console.write("handle finished");
			removeChild(actionButton);
			progressBar.setMax();
			boxFinished = new Box(610,60,"normal",0.8,13);
			var _local1:TextField = new TextField(610,60,"EXPLORED!",new TextFormat("font13",20,0xffffff));
			boxFinished.x = 0;
			boxFinished.y = 0;
			addChild(boxFinished);
			addChild(_local1);
			removeChild(progressBar);
		}
		
		private function showSelectTeam(e:TouchEvent = null) : void {
			dispatchEvent(new Event("showSelectTeam"));
		}
		
		public function startExplore(selectedTeams:Vector.<CrewDisplayBox>, callback:Function = null) : void {
			exploreStartedCallback = callback;
			requestStartExplore(selectedTeams);
		}
		
		private function requestStartExplore(teams:Vector.<CrewDisplayBox> = null) : void {
			if(teams == null) {
				return;
			}
			var _local2:String = "";
			for each(var _local3:* in teams) {
				if(_local2 != "") {
					_local2 += " ";
				}
				_local2 += _local3.key;
			}
			actionButton.enabled = false;
			g.rpc("startExplore",exploreStarted,areaKey,teams.length,_local2);
		}
		
		private function resume() : void {
			Console.write("resume");
			progressBar.start(startTime,finishTime,failTime);
			if(exploreTimer != null && contains(exploreTimer)) {
				exploreTimer.stop();
				removeChild(exploreTimer);
			}
			exploreTimer = new HudTimer(g);
			exploreTimer.start(startTime,finishTime);
			exploreTimer.x = 520;
			exploreTimer.y = 0;
			actionButton.callback = instant;
			actionButton.text = " Speed up! ";
			actionButton.enabled = true;
			adjustActionButton();
			addChild(exploreTimer);
		}
		
		private function exploreStarted(m:Message) : void {
			var _local2:Explore = null;
			var _local4:int = 0;
			var _local7:int = 0;
			var _local6:String = null;
			var _local3:String = null;
			if(m.getBoolean(0)) {
				if(exploreStartedCallback != null) {
					exploreStartedCallback();
				}
				g.tutorial.showExploreAdvice2();
				_local2 = g.me.getExploreByKey(areaKey);
				if(_local2 == null) {
					_local2 = new Explore();
				}
				startTime = m.getNumber(1);
				finishTime = m.getNumber(2);
				failTime = m.getNumber(3);
				successfulEvents = m.getNumber(4);
				_local2.areaKey = areaKey;
				_local2.bodyKey = body.key;
				_local2.finished = false;
				_local2.failTime = failTime;
				_local2.startTime = startTime;
				_local2.finishTime = finishTime;
				_local2.lootClaimed = false;
				_local2.successfulEvents = successfulEvents;
				_local2.startEvent = 0;
				g.me.explores.push(_local2);
				progressBar.start(startTime,finishTime,failTime);
				if(exploreTimer != null && contains(exploreTimer)) {
					exploreTimer.stop();
					removeChild(exploreTimer);
				}
				exploreTimer = new HudTimer(g);
				exploreTimer.start(startTime,finishTime);
				exploreTimer.x = 520;
				exploreTimer.y = 0;
				actionButton.callback = instant;
				actionButton.visible = true;
				actionButton.text = " Speed up! ";
				actionButton.enabled = true;
				addChild(exploreTimer);
				if(contains(actionButton)) {
					removeChild(actionButton);
				}
				addChild(actionButton);
				_local4 = m.getInt(5);
				_local7 = 6;
				while(_local7 < 7 + (_local4 - 1) * 5) {
					_local6 = m.getString(_local7);
					for each(var _local5:* in g.me.crewMembers) {
						if(_local5.key == _local6) {
							_local5.solarSystem = m.getString(_local7 + 1);
							_local5.body = m.getString(_local7 + 2);
							_local5.area = m.getString(_local7 + 3);
							_local5.fullLocation = m.getString(_local7 + 4);
							break;
						}
					}
					_local7 += 5;
				}
				exploreMapArea.explore = _local2;
			} else {
				actionButton.enabled = true;
				_local3 = m.getString(1);
				if(_local3 == "occupied") {
					g.showErrorDialog("One of crew members is occupied exploring somewhere else.");
					return;
				}
				if(_local3 == "injured") {
					g.showErrorDialog("One of crew members is injured.");
					return;
				}
				if(_local3 == "training") {
					g.showErrorDialog("One of crew members is busy training.");
					return;
				}
				if(_local3 == "explored") {
					g.showErrorDialog("You can\'t explore this area.");
					return;
				}
			}
		}
		
		public function update() : void {
			exploreMapArea.update();
			progressBar.update();
			if(exploreTimer != null) {
				exploreTimer.update();
			}
		}
		
		public function stopEffect() : void {
			progressBar.stopEffect();
		}
		
		public function set exploring(value:Boolean) : void {
			this._exploring = value;
		}
		
		private function showRewardScreen(e:TouchEvent = null) : void {
			actionButton.enabled = false;
			dispatchEvent(new Event("showRewardScreen"));
		}
		
		public function get success() : Boolean {
			if(finished && lootClaimed) {
				return true;
			}
			return false;
		}
		
		public function get failedValue() : Number {
			return (failTime - startTime) / (finishTime - startTime);
		}
		
		private function instantExplore(m:Message) : void {
			if(!m.getBoolean(0)) {
				actionButton.enabled = true;
				g.showErrorDialog(m.getString(1));
				return;
			}
			var _local3:int = CreditManager.getCostInstant(size);
			Game.trackEvent("used flux","instant explore","size " + size,_local3);
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			g.creditManager.refresh();
			g.showErrorDialog("Explore completed!");
			var _local2:Explore = g.me.getExploreByKey(areaKey);
			_local2.finishTime = m.getNumber(1);
			finishTime = _local2.finishTime;
			_local2.failTime = m.getNumber(2);
			failTime = _local2.failTime;
			_local2.successfulEvents = m.getInt(3);
			successfulEvents = _local2.successfulEvents;
			_local2.finished = true;
			finished = true;
			_local2.lootClaimed = false;
			lootClaimed = false;
			if(contains(exploreTimer)) {
				exploreTimer.stop();
				removeChild(exploreTimer);
			}
			progressBar.stop();
			progressBar.setValueAndEffect(1,false);
			progressBarOnComplete();
			exploreMapArea.explore = _local2;
		}
		
		private function sendInstant() : void {
			g.rpc("buyInstantExplore",instantExplore,areaKey);
		}
		
		private function instant(e:TouchEvent = null) : void {
			g.creditManager.refresh(function():void {
				var _local1:int = CreditManager.getCostInstant(size);
				confirmInstantExploreBox = new CreditBuyBox(g,_local1,"Are you sure you want to buy instant explore?");
				g.addChildToOverlay(confirmInstantExploreBox);
				confirmInstantExploreBox.addEventListener("accept",onAccept);
				confirmInstantExploreBox.addEventListener("close",onClose);
			});
		}
		
		private function onAccept(e:Event) : void {
			sendInstant();
			confirmInstantExploreBox.removeEventListener("accept",onAccept);
			confirmInstantExploreBox.removeEventListener("close",onClose);
		}
		
		private function onClose(e:Event) : void {
			actionButton.enabled = true;
			confirmInstantExploreBox.removeEventListener("accept",onAccept);
			confirmInstantExploreBox.removeEventListener("close",onClose);
		}
		
		private function send(e:TouchEvent) : void {
			g.removeChildFromOverlay(overlay);
			actionButton.enabled = true;
			showSelectTeam();
		}
		
		override public function dispose() : void {
			if(exploreMapArea) {
				exploreMapArea.dispose();
			}
			super.dispose();
		}
	}
}

