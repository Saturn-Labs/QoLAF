package core.states.gameStates.missions {
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import core.credits.CreditManager;
	import core.drops.DropBase;
	import core.drops.DropItem;
	import core.hud.components.Button;
	import core.hud.components.GradientBox;
	import core.hud.components.Text;
	import core.hud.components.ToolTip;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.player.Mission;
	import core.scene.Game;
	import core.states.gameStates.RoamingState;
	import core.states.gameStates.ShopState;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Localize;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class MissionView extends Sprite {
		private var mission:Mission;
		
		private var g:Game;
		
		private var heading:Text;
		
		private var description:Text;
		
		private var missionType:Object;
		
		private var box:GradientBox;
		
		private var dataManager:IDataManager;
		
		private var fluxIcon:Image;
		
		private var dropBase:DropBase;
		
		private var boxWidth:int;
		
		private var textureManager:ITextureManager;
		
		private var tween:TweenMax;
		
		private var timeLeft:Text = new Text();
		
		public function MissionView(game:Game, mission:Mission, boxWidth:int) {
			super();
			this.mission = mission;
			this.g = game;
			this.boxWidth = boxWidth;
			this.textureManager = TextureLocator.getService();
		}
		
		public static function fixText(g:Game, missionType:Object, s:String) : String {
			if(missionType.value != null) {
				s = s.replace("[amount]","<font color=\'#ffffff\'>" + missionType.value + "</font>");
			}
			s = s.replace("[player]",g.me.name);
			s = s.replace("[h]","<font color=\'#ffffff\'>");
			return s.replace("[/h]","</font>");
		}
		
		public function init() : void {
			var instance:MissionView;
			var rewardY:Number;
			var cancelButton:Button;
			if(mission.majorType == "time") {
				box = new GradientBox(boxWidth,160,0,1,15,0xff8844);
			} else {
				box = new GradientBox(boxWidth,160,0,1,15,0x88ff88);
			}
			instance = this;
			box.load();
			addChild(box);
			dataManager = DataLocator.getService();
			missionType = dataManager.loadKey("MissionTypes",mission.missionTypeKey);
			addHeading();
			rewardY = addReward();
			addDescription();
			addRewardButton(rewardY);
			if(mission.majorType == "time" && !mission.finished) {
				cancelButton = new Button(function():void {
					g.creditManager.refresh(function():void {
						var confirmBuyWithFlux:CreditBuyBox = new CreditBuyBox(g,CreditManager.getCostSkipMission(),Localize.t("Skip this timed mission and receive a new one!"));
						g.addChildToOverlay(confirmBuyWithFlux);
						confirmBuyWithFlux.addEventListener("accept",function(param1:Event):void {
							var e:Event = param1;
							g.rpc("skipMission",function(param1:Message):void {
								if(param1.getBoolean(0)) {
									Game.trackEvent("used flux","skipped mission","player level " + g.me.level,CreditManager.getCostSkipMission());
									removeAndRedrawList();
									g.creditManager.refresh();
								} else {
									g.showErrorDialog(param1.getString(1),false);
								}
							},mission.id);
							confirmBuyWithFlux.removeEventListeners();
						});
						confirmBuyWithFlux.addEventListener("close",function(param1:Event):void {
							confirmBuyWithFlux.removeEventListeners();
							cancelButton.enabled = true;
							g.removeChildFromOverlay(confirmBuyWithFlux,true);
						});
					});
				},Localize.t("Skip Mission"),"normal",12);
				cancelButton.x = width - cancelButton.width - box.padding * 2;
				cancelButton.y = height - cancelButton.height - box.padding * 2;
				addChild(cancelButton);
			}
			instance[missionType.type]();
		}
		
		public function level() : void {
		}
		
		public function transport() : void {
			var _local4:Object = null;
			var _local1:Text = null;
			var _local2:Vector.<Object> = new Vector.<Object>();
			var _local3:int = 1;
			var _local6:String = description.htmlText;
			for each(var _local5 in missionType.addedBodies) {
				_local4 = dataManager.loadKey("Bodies",_local5);
				_local2.push(_local4);
				_local6 = _local6.replace("[location" + _local3 + "]","<font color=\'#ffffff\'>" + _local4.name + "</font>");
				_local3++;
			}
			description.htmlText = _local6;
			_local3 = 1;
			for each(var _local7 in _local2) {
				_local1 = new Text();
				_local1.size = 13;
				_local1.x = 0;
				_local1.y = description.height + 10 + _local3 * 20;
				if(_local3 == 1) {
					_local1.htmlText = Localize.t("Go to") + ": <font color=\'#ae7108\'>" + _local7.name;
				} else {
					_local1.htmlText = Localize.t("Then to") + ": <font color=\'#ae7108\'>" + _local7.name;
				}
				box.addChild(_local1);
				_local3++;
			}
		}
		
		private function kill() : void {
			var _local1:* = this;
			_local1[missionType.subtype]();
		}
		
		private function pvpStart() : void {
		}
		
		private function player() : void {
			var _local1:Text = new Text();
			_local1.size = 13;
			_local1.x = 0;
			_local1.y = 145;
			_local1.htmlText = Localize.t("Killed") + ": <font color=\'#ae0808\'>" + mission.count + " / " + missionType.value;
			box.addChild(_local1);
		}
		
		private function frenzy() : void {
			var _local1:Text = new Text();
			_local1.size = 13;
			_local1.x = 0;
			_local1.y = 145;
			_local1.htmlText = Localize.t("Longest killing frenzy") + ": <font color=\'#ae0808\'>" + mission.count + " / " + missionType.value;
			box.addChild(_local1);
		}
		
		private function explore() : void {
		}
		
		private function pickup() : void {
			var _local2:Object = null;
			var _local3:Image = null;
			if(missionType.item != null) {
				_local2 = dataManager.loadKey("Commodities",missionType.item);
				_local3 = new Image(textureManager.getTextureGUIByKey(_local2.bitmap));
				_local3.y = description.y + description.height + 20;
				box.addChild(_local3);
			}
			var _local1:Text = new Text();
			_local1.size = 13;
			_local1.x = 0;
			_local1.y = 145;
			_local1.htmlText = Localize.t("Picked up") + ": <font color=\'#08ae08\'>" + mission.count + " / " + missionType.value;
			box.addChild(_local1);
		}
		
		private function recycle() : void {
			var _local2:Object = null;
			var _local3:Image = null;
			if(missionType.item != null) {
				_local2 = dataManager.loadKey("Commodities",missionType.item);
				_local3 = new Image(textureManager.getTextureGUIByKey(_local2.bitmap));
				_local3.y = description.y + description.height + 20;
				box.addChild(_local3);
			}
			var _local1:Text = new Text();
			_local1.size = 13;
			_local1.x = 0;
			_local1.y = 145;
			_local1.htmlText = Localize.t("Recycled") + ": <font color=\'#08ae08\'>" + mission.count + " / " + missionType.value;
			box.addChild(_local1);
		}
		
		private function reputation() : void {
		}
		
		private function boss() : void {
			var _local1:Text = new Text();
			_local1.size = 13;
			_local1.x = 0;
			_local1.y = 145;
			_local1.htmlText = Localize.t("Killed") + ": <font color=\'#ae7108\'>" + mission.count + " / 1";
			box.addChild(_local1);
		}
		
		private function ship() : void {
			var _local1:Object = null;
			var _local11:Object = null;
			var _local8:Object = null;
			var _local6:MovieClip = null;
			var _local10:Vector.<Object> = new Vector.<Object>();
			for each(var _local12 in missionType.addedEnemies) {
				_local1 = dataManager.loadKey("Enemies",_local12);
				_local11 = {};
				if(_local1 != null) {
					_local8 = dataManager.loadKey("Ships",_local1.ship);
					_local11.ship = _local8;
					_local11.enemy = _local1;
					_local10.push(_local11);
				}
			}
			var _local5:String = "";
			var _local3:Number = 0;
			var _local7:int = 5;
			var _local9:int = description.y + description.height + 20;
			for each(var _local4 in _local10) {
				if(_local5 != _local4.ship.bitmap) {
					_local5 = _local4.ship.bitmap;
					_local6 = new MovieClip(textureManager.getTexturesMainByKey(_local4.ship.bitmap));
					_local6.x = _local7;
					_local6.y = _local9;
					_local7 += _local6.width + 15;
					if(_local7 > 400) {
						_local9 += _local6.height + 5;
						_local7 = 5;
					}
					new ToolTip(g,_local6,_local4.enemy.name,null,"missionView");
					_local3 = Math.max(_local3,_local6.height);
					box.addChild(_local6);
				}
			}
			var _local2:Text = new Text();
			_local2.size = 13;
			_local2.x = 0;
			_local2.y = _local9 + _local3 + 20;
			_local2.htmlText = Localize.t("Killed") + ": <font color=\'#ae7108\'>" + mission.count + " / " + missionType.value;
			box.addChild(_local2);
		}
		
		private function spawner() : void {
			var _local3:String = null;
			var _local2:Text = new Text();
			_local2.size = 13;
			_local2.x = 70;
			_local2.y = 125;
			_local2.htmlText = Localize.t("Killed") + ": <font color=\'#ae7108\'>" + mission.count + " / " + missionType.value;
			box.addChild(_local2);
			if(missionType.hasOwnProperty("bitmap")) {
				_local3 = missionType.bitmap;
			} else {
				_local3 = "MSpsdfGpTU2S9DE5B393Tw";
			}
			var _local1:MovieClip = new MovieClip(textureManager.getTexturesMainByKey(_local3));
			_local1.x = 0;
			_local1.y = 110;
			_local1.scaleX = _local1.scaleY = 0.7;
			box.addChild(_local1);
		}
		
		private function addReward() : Number {
			var x:int;
			var rewardY:int;
			var d:DropItem;
			var fluxText:Text;
			var artifactText:Text;
			var artifactIcon:Image;
			var t:ToolTip;
			var xpText:TextField;
			var s:String;
			var boostXp:int;
			var toolTipText:String;
			var xpBoostIcon:Image;
			var repImg:String;
			var reputationIcon:Image;
			var reputationText:Text;
			dropBase = g.dropManager.getDropItems(missionType.drop,g,mission.created);
			var rewardHeading:Text = new Text();
			rewardHeading.color = 11432200;
			rewardHeading.size = 14;
			rewardHeading.text = Localize.t("REWARD").toUpperCase();
			rewardHeading.x = 560;
			rewardHeading.y = 10;
			rewardHeading.alignCenter();
			box.addChild(rewardHeading);
			x = rewardHeading.x;
			rewardY = rewardHeading.y + 25;
			if(dropBase == null) {
				g.showErrorDialog(Localize.t("Error with mission") + ": " + missionType.title,true);
				return 0;
			}
			for each(d in dropBase.items) {
				rewardY = addRewardItem(d,x,rewardY);
			}
			rewardY += 5;
			if(dropBase.flux > 0) {
				fluxText = new Text();
				fluxText.color = 0xffffff;
				fluxText.size = 16;
				fluxText.alignCenter();
				fluxText.text = "" + dropBase.flux;
				fluxText.x = x;
				fluxText.y = rewardY;
				fluxIcon = new Image(textureManager.getTextureGUIByTextureName("credit_small.png"));
				fluxIcon.x = x - fluxText.width / 2 - fluxIcon.width / 2 - 4;
				fluxIcon.y = rewardY + fluxText.height / 2 - fluxIcon.height / 2 - 2;
				fluxText.x += fluxIcon.width / 2 - 2;
				addChild(fluxIcon);
				addChild(fluxText);
				rewardY += 20;
			}
			if(dropBase.artifactAmount > 0) {
				artifactText = new Text();
				artifactText.color = 0xffffff;
				artifactText.size = 16;
				artifactText.alignCenter();
				artifactText.text = "" + dropBase.artifactAmount;
				artifactText.x = x;
				artifactText.y = rewardY;
				artifactIcon = new Image(textureManager.getTextureGUIByTextureName("artifact_icon.png"));
				artifactIcon.x = x - artifactText.width / 2 - artifactIcon.width / 2 - 4;
				artifactIcon.y = rewardY + artifactText.height / 2 - artifactIcon.height / 2 - 2;
				artifactText.x += artifactIcon.width / 2 - 2;
				addChild(artifactIcon);
				addChild(artifactText);
				rewardY += 20;
				t = new ToolTip(g,artifactIcon,Localize.t("[amount]x (lvl [level]) artifacts").replace("[amount]",dropBase.artifactAmount).replace("[level]",dropBase.artifactLevel),null,"missionView");
			}
			if(dropBase.xp > 0) {
				xpText = new TextField(100,30,"",new TextFormat("DAIDRR"));
				xpText.format.color = 0xffffff;
				xpText.autoSize = "bothDirections";
				xpText.isHtmlText = true;
				dropBase.xp = 0.75 * dropBase.xp + 0.5;
				s = Localize.t("XP") + ": " + dropBase.xp;
				boostXp = Math.ceil(dropBase.xp * 0.3);
				if(g.me.hasExpBoost) {
					s += " <FONT COLOR=\'#88ff88\'>(+" + boostXp + ")</FONT>";
					xpText.text = s;
					new ToolTip(g,xpText,Localize.t("You have XP BOOST enabled!."),null,"missionView");
				} else {
					s += " <FONT COLOR=\'#333333\'>(+" + boostXp + ")</FONT>";
					xpText.text = s;
					new ToolTip(g,xpText,Localize.t("You don\'t have any XP BOOST active, get one if you want to gain <FONT COLOR=\'#FFFFFF\'>[xpBoost]%</FONT> more XP.").replace("[xpBoost]",0.3 * 100),null,"missionView");
				}
				xpText.x = x;
				xpText.y = rewardY + 5;
				xpText.pivotX = xpText.width / 2;
				if(!g.me.hasExpBoost) {
					toolTipText = Localize.t("Get XP BOOST now!");
					xpBoostIcon = new Image(textureManager.getTextureGUIByTextureName("button_pay"));
					xpBoostIcon.useHandCursor = true;
					xpBoostIcon.addEventListener("touch",function(param1:TouchEvent):void {
						if(param1.getTouch(xpBoostIcon,"ended")) {
							g.enterState(new RoamingState(g));
							g.enterState(new ShopState(g,"xpBoost"));
						}
					});
					xpBoostIcon.x = xpText.x + xpText.width / 2 + 5;
					xpBoostIcon.y = xpText.y;
					addChild(xpBoostIcon);
					new ToolTip(g,xpBoostIcon,toolTipText,null,"shopIcons");
				}
				addChild(xpText);
				rewardY += 20;
			}
			if(mission.majorType == "time") {
				timeLeft.font = "Verdana";
				timeLeft.color = 11432200;
				timeLeft.size = 12;
				timeLeft.x = heading.x + heading.width + 20;
				timeLeft.y = heading.y;
				addChild(timeLeft);
			}
			if(dropBase.reputation > 0) {
				if(g.me.reputation > 0) {
					repImg = "police_icon.png";
				} else {
					repImg = "pirate_icon.png";
				}
				reputationIcon = new Image(textureManager.getTextureGUIByTextureName(repImg));
				reputationIcon.scaleX = 0.5;
				reputationIcon.scaleY = 0.5;
				reputationText = new Text();
				reputationText.color = 0xffffff;
				reputationText.size = 16;
				reputationText.alignCenter();
				reputationText.text = "" + dropBase.reputation;
				reputationText.y = rewardY;
				reputationIcon.x = x - reputationText.width / 2 - reputationText.width / 2;
				reputationIcon.y = rewardY + reputationText.height / 2 - reputationText.height / 2 + 3;
				reputationText.x = x + reputationText.width / 2 - 2;
				addChild(reputationIcon);
				addChild(reputationText);
				rewardY += 20;
			}
			return rewardY;
		}
		
		public function update() : void {
			if(mission.majorType == "time") {
				drawExpireTime();
			}
		}
		
		private function drawExpireTime() : void {
			var _local1:int = (mission.expires - g.time) / 1000;
			if(_local1 < 0) {
				removeAndRedrawList();
				return;
			}
			if(timeLeft != null) {
				timeLeft.htmlText = "" + _local1;
			}
			var _local2:int = Math.floor(_local1 / (60 * 60));
			_local1 -= _local2 * (60) * (60);
			var _local5:int = Math.floor(_local1 / (60));
			_local1 -= _local5 * (60);
			var _local3:int = Math.floor(_local1);
			var _local6:String = _local2 < 10 ? "0" + _local2 : "" + _local2;
			var _local7:String = _local5 < 10 ? "0" + _local5 : "" + _local5;
			var _local4:String = _local3 < 10 ? "0" + _local3 : "" + _local3;
			if(timeLeft != null) {
				timeLeft.htmlText = "(" + Localize.t("expires in") + ": " + _local6 + ":" + _local7 + ":" + _local4 + ")";
			}
		}
		
		private function addRewardItem(item:DropItem, x:int, y:int) : int {
			var _local7:Image = null;
			var _local4:Text = new Text();
			_local4.color = 0xffffff;
			_local4.size = 14;
			_local4.alignCenter();
			_local4.x = x;
			_local4.y = y;
			var _local8:String = item.name;
			_local8.toLocaleUpperCase();
			_local4.htmlText = item.quantity.toString();
			while(_local4.width > 160) {
				_local4.size--;
			}
			var _local5:Sprite = new Sprite();
			if(item.table == "Skins") {
				_local7 = new Image(textureManager.getTexturesMainByKey(item.bitmapKey)[0]);
			} else {
				_local7 = new Image(textureManager.getTextureGUIByKey(item.bitmapKey));
			}
			if(_local7.height > 30) {
				_local7.scaleX = _local7.scaleY = 20 / _local7.height;
			}
			_local7.x = x - _local4.width / 2 - _local7.width / 2 - 4;
			_local7.y = y + _local4.height / 2 - _local7.height / 2 - 2;
			_local4.x += _local7.width / 2 - 2;
			var _local6:ToolTip = new ToolTip(g,_local5,_local8,null,"missionView");
			_local5.addChild(_local7);
			box.addChild(_local5);
			box.addChild(_local4);
			return y + _local7.height + 5;
		}
		
		private function addRewardButton(rewardY:Number) : void {
			var _local2:Button = new Button(tryCollectReward,Localize.t("COLLECT REWARD").toUpperCase(),"positive");
			_local2.visible = mission.finished;
			if(box.height < rewardY + _local2.height + box.padding * 2) {
				box.height = rewardY + _local2.height + box.padding;
			}
			_local2.x = box.width - _local2.width - box.padding * 2;
			_local2.y = height - _local2.height - box.padding * 2;
			addChild(_local2);
		}
		
		private function addHeading() : void {
			heading = new Text();
			heading.y = -5;
			heading.color = 0xffffff;
			heading.size = 13;
			var _local1:String = missionType.title;
			heading.htmlText = fixText(g,missionType,_local1);
			addChild(heading);
		}
		
		private function addDescription() : void {
			description = new Text();
			description.font = "Verdana";
			description.color = 0xa1a1a1;
			description.size = 12;
			description.wordWrap = true;
			description.width = 380;
			var _local1:String = missionType.description;
			if(mission.finished && missionType.completeDescription != null) {
				if(missionType.hasOwnProperty("nextMission")) {
					description.htmlText = Localize.t("Mission Completed! Click claim reward to proceed to next step.");
				} else {
					description.htmlText = missionType.completeDescription;
				}
			} else {
				description.htmlText = fixText(g,missionType,_local1);
			}
			description.y = 22;
			if(description.height > 90) {
				description.width = 460;
			}
			if(description.height > 90) {
				description.size--;
			}
			addChild(description);
		}
		
		private function tryCollectReward(e:TouchEvent) : void {
			g.rpc("requestMissionReward",rewardArrived,mission.id,mission.majorType);
		}
		
		private function rewardArrived(m:Message) : void {
			var _local3:Boolean = m.getBoolean(0);
			if(!_local3) {
				g.showErrorDialog(Localize.t("Mission not complete."));
				return;
			}
			if(missionType.majorType == "static") {
				Game.trackEvent("missions","static",missionType.title);
			} else if(missionType.majorType == "time") {
				Game.trackEvent("missions","timed",missionType.title);
			}
			g.me.removeMission(mission);
			g.creditManager.refresh();
			for each(var _local2 in dropBase.items) {
				transferItemToCargo(_local2);
			}
			g.hud.cargoButton.update();
			g.hud.resourceBox.update();
			g.hud.cargoButton.flash();
			animateCollectReward();
		}
		
		private function removeAndRedrawList() : void {
			tween = TweenMax.to(this,0.3,{
				"alpha":0,
				"onComplete":redrawParentList,
				"ease":Circ.easeIn
			});
		}
		
		private function redrawParentList() : void {
			g.me.removeMission(mission);
			dispatchEventWith("reload");
		}
		
		private function animateCollectReward() : void {
			tween = TweenMax.to(this,0.3,{
				"alpha":0,
				"onComplete":collectReward,
				"ease":Circ.easeIn
			});
			var _local1:ISound = SoundLocator.getService();
			_local1.preCacheSound("7zeIcPFb-UWzgtR_3nrZ8Q");
		}
		
		private function collectReward() : void {
			dispatchEventWith("animateCollectReward",true);
			g.textManager.createMissionCompleteText();
		}
		
		private function transferItemToCargo(d:Object) : void {
			var _local4:String = d.table;
			var _local2:String = d.item;
			var _local3:Number = Number(d.quantity);
			g.myCargo.addItem(_local4,_local2,_local3);
		}
	}
}

