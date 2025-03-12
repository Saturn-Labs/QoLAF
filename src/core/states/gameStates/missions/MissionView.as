package core.states.gameStates.missions
{
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
	
	public class MissionView extends Sprite
	{
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
		
		private var timeLeft:Text;
		
		public function MissionView(param1:Game, param2:Mission, param3:int)
		{
			timeLeft = new Text();
			super();
			this.mission = param2;
			this.g = param1;
			this.boxWidth = param3;
			this.textureManager = TextureLocator.getService();
		}
		
		public static function fixText(param1:Game, param2:Object, param3:String):String
		{
			if (param2.value != null)
			{
				param3 = param3.replace("[amount]", "<font color='#ffffff'>" + param2.value + "</font>");
			}
			param3 = param3.replace("[player]", param1.me.name);
			param3 = param3.replace("[h]", "<font color='#ffffff'>");
			return param3.replace("[/h]", "</font>");
		}
		
		public function init():void
		{
			var instance:MissionView;
			var rewardY:Number;
			var cancelButton:Button;
			if (mission.majorType == "time")
			{
				box = new GradientBox(boxWidth, 160, 0, 1, 15, 16746564);
			}
			else
			{
				box = new GradientBox(boxWidth, 160, 0, 1, 15, 8978312);
			}
			instance = this;
			box.load();
			addChild(box);
			dataManager = DataLocator.getService();
			missionType = dataManager.loadKey("MissionTypes", mission.missionTypeKey);
			addHeading();
			rewardY = addReward();
			addDescription();
			addRewardButton(rewardY);
			if (mission.majorType == "time" && !mission.finished)
			{
				cancelButton = new Button(function():void
				{
					g.creditManager.refresh(function():void
					{
						var confirmBuyWithFlux:CreditBuyBox = new CreditBuyBox(g, CreditManager.getCostSkipMission(), Localize.t("Skip this timed mission and receive a new one!"));
						g.addChildToOverlay(confirmBuyWithFlux);
						confirmBuyWithFlux.addEventListener("accept", function(param1:Event):void
						{
							var e:Event = param1;
							g.rpc("skipMission", function(param1:Message):void
							{
								if (param1.getBoolean(0))
								{
									Game.trackEvent("used flux", "skipped mission", "player level " + g.me.level, CreditManager.getCostSkipMission());
									removeAndRedrawList();
									g.creditManager.refresh();
								}
								else
								{
									g.showErrorDialog(param1.getString(1), false);
								}
							}, mission.id);
							confirmBuyWithFlux.removeEventListeners();
						});
						confirmBuyWithFlux.addEventListener("close", function(param1:Event):void
						{
							confirmBuyWithFlux.removeEventListeners();
							cancelButton.enabled = true;
							g.removeChildFromOverlay(confirmBuyWithFlux, true);
						});
					});
				}, Localize.t("Skip Mission"), "normal", 12);
				cancelButton.x = width - cancelButton.width - box.padding * 2;
				cancelButton.y = height - cancelButton.height - box.padding * 2;
				addChild(cancelButton);
			}
			instance[missionType.type]();
		}
		
		public function level():void
		{
		}
		
		public function transport():void
		{
			var _loc1_:Object = null;
			var _loc2_:Text = null;
			var _loc5_:Vector.<Object> = new Vector.<Object>();
			var _loc7_:int = 1;
			var _loc3_:String = description.htmlText;
			for each (var _loc6_:* in missionType.addedBodies)
			{
				_loc1_ = dataManager.loadKey("Bodies", _loc6_);
				_loc5_.push(_loc1_);
				_loc3_ = _loc3_.replace("[location" + _loc7_ + "]", "<font color='#ffffff'>" + _loc1_.name + "</font>");
				_loc7_++;
			}
			description.htmlText = _loc3_;
			_loc7_ = 1;
			for each (var _loc4_:* in _loc5_)
			{
				_loc2_ = new Text();
				_loc2_.size = 13;
				_loc2_.x = 0;
				_loc2_.y = description.height + 10 + _loc7_ * 20;
				if (_loc7_ == 1)
				{
					_loc2_.htmlText = Localize.t("Go to") + ": <font color='#ae7108'>" + _loc4_.name;
				}
				else
				{
					_loc2_.htmlText = Localize.t("Then to") + ": <font color='#ae7108'>" + _loc4_.name;
				}
				box.addChild(_loc2_);
				_loc7_++;
			}
		}
		
		private function kill():void
		{
			var _loc1_:* = this;
			_loc1_[missionType.subtype]();
		}
		
		private function pvpStart():void
		{
		}
		
		private function player():void
		{
			var _loc1_:Text = new Text();
			_loc1_.size = 13;
			_loc1_.x = 0;
			_loc1_.y = 145;
			_loc1_.htmlText = Localize.t("Killed") + ": <font color='#ae0808'>" + mission.count + " / " + missionType.value;
			box.addChild(_loc1_);
		}
		
		private function frenzy():void
		{
			var _loc1_:Text = new Text();
			_loc1_.size = 13;
			_loc1_.x = 0;
			_loc1_.y = 145;
			_loc1_.htmlText = Localize.t("Longest killing frenzy") + ": <font color='#ae0808'>" + mission.count + " / " + missionType.value;
			box.addChild(_loc1_);
		}
		
		private function explore():void
		{
		}
		
		private function pickup():void
		{
			var _loc3_:Object = null;
			var _loc2_:Image = null;
			if (missionType.item != null)
			{
				_loc3_ = dataManager.loadKey("Commodities", missionType.item);
				_loc2_ = new Image(textureManager.getTextureGUIByKey(_loc3_.bitmap));
				_loc2_.y = description.y + description.height + 20;
				box.addChild(_loc2_);
			}
			var _loc1_:Text = new Text();
			_loc1_.size = 13;
			_loc1_.x = 0;
			_loc1_.y = 145;
			_loc1_.htmlText = Localize.t("Picked up") + ": <font color='#08ae08'>" + mission.count + " / " + missionType.value;
			box.addChild(_loc1_);
		}
		
		private function recycle():void
		{
			var _loc3_:Object = null;
			var _loc2_:Image = null;
			if (missionType.item != null)
			{
				_loc3_ = dataManager.loadKey("Commodities", missionType.item);
				_loc2_ = new Image(textureManager.getTextureGUIByKey(_loc3_.bitmap));
				_loc2_.y = description.y + description.height + 20;
				box.addChild(_loc2_);
			}
			var _loc1_:Text = new Text();
			_loc1_.size = 13;
			_loc1_.x = 0;
			_loc1_.y = 145;
			_loc1_.htmlText = Localize.t("Recycled") + ": <font color='#08ae08'>" + mission.count + " / " + missionType.value;
			box.addChild(_loc1_);
		}
		
		private function reputation():void
		{
		}
		
		private function boss():void
		{
			var _loc1_:Text = new Text();
			_loc1_.size = 13;
			_loc1_.x = 0;
			_loc1_.y = 145;
			_loc1_.htmlText = Localize.t("Killed") + ": <font color='#ae7108'>" + mission.count + " / 1";
			box.addChild(_loc1_);
		}
		
		private function ship():void
		{
			var _loc9_:Object = null;
			var _loc1_:Object = null;
			var _loc7_:Object = null;
			var _loc5_:MovieClip = null;
			var _loc2_:Vector.<Object> = new Vector.<Object>();
			for each (var _loc11_:* in missionType.addedEnemies)
			{
				_loc9_ = dataManager.loadKey("Enemies", _loc11_);
				_loc1_ = {};
				if (_loc9_ != null)
				{
					_loc7_ = dataManager.loadKey("Ships", _loc9_.ship);
					_loc1_.ship = _loc7_;
					_loc1_.enemy = _loc9_;
					_loc2_.push(_loc1_);
				}
			}
			var _loc6_:String = "";
			var _loc8_:Number = 0;
			var _loc12_:int = 5;
			var _loc10_:int = description.y + description.height + 20;
			for each (var _loc4_:* in _loc2_)
			{
				if (_loc6_ != _loc4_.ship.bitmap)
				{
					_loc6_ = _loc4_.ship.bitmap;
					_loc5_ = new MovieClip(textureManager.getTexturesMainByKey(_loc4_.ship.bitmap));
					_loc5_.x = _loc12_;
					_loc5_.y = _loc10_;
					_loc12_ += _loc5_.width + 15;
					if (_loc12_ > 400)
					{
						_loc10_ += _loc5_.height + 5;
						_loc12_ = 5;
					}
					new ToolTip(g, _loc5_, _loc4_.enemy.name, null, "missionView");
					_loc8_ = Math.max(_loc8_, _loc5_.height);
					box.addChild(_loc5_);
				}
			}
			var _loc3_:Text = new Text();
			_loc3_.size = 13;
			_loc3_.x = 0;
			_loc3_.y = _loc10_ + _loc8_ + 20;
			_loc3_.htmlText = Localize.t("Killed") + ": <font color='#ae7108'>" + mission.count + " / " + missionType.value;
			box.addChild(_loc3_);
		}
		
		private function spawner():void
		{
			var _loc2_:String = null;
			var _loc1_:Text = new Text();
			_loc1_.size = 13;
			_loc1_.x = 70;
			_loc1_.y = 125;
			_loc1_.htmlText = Localize.t("Killed") + ": <font color='#ae7108'>" + mission.count + " / " + missionType.value;
			box.addChild(_loc1_);
			if (missionType.hasOwnProperty("bitmap"))
			{
				_loc2_ = missionType.bitmap;
			}
			else
			{
				_loc2_ = "MSpsdfGpTU2S9DE5B393Tw";
			}
			var _loc3_:MovieClip = new MovieClip(textureManager.getTexturesMainByKey(_loc2_));
			_loc3_.x = 0;
			_loc3_.y = 110;
			_loc3_.scaleX = _loc3_.scaleY = 0.7;
			box.addChild(_loc3_);
		}
		
		private function addReward():Number
		{
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
			dropBase = g.dropManager.getDropItems(missionType.drop, g, mission.created);
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
			if (dropBase == null)
			{
				g.showErrorDialog(Localize.t("Error with mission") + ": " + missionType.title, true);
				return 0;
			}
			for each (d in dropBase.items)
			{
				rewardY = addRewardItem(d, x, rewardY);
			}
			rewardY += 5;
			if (dropBase.flux > 0)
			{
				fluxText = new Text();
				fluxText.color = 16777215;
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
			if (dropBase.artifactAmount > 0)
			{
				artifactText = new Text();
				artifactText.color = 16777215;
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
				t = new ToolTip(g, artifactIcon, Localize.t("[amount]x (lvl [level]) artifacts").replace("[amount]", dropBase.artifactAmount).replace("[level]", dropBase.artifactLevel), null, "missionView");
			}
			if (dropBase.xp > 0)
			{
				xpText = new TextField(100, 30, "", new TextFormat("DAIDRR"));
				xpText.format.color = 16777215;
				xpText.autoSize = "bothDirections";
				xpText.isHtmlText = true;
				dropBase.xp = 0.75 * dropBase.xp + 0.5;
				s = Localize.t("XP") + ": " + dropBase.xp;
				boostXp = Math.ceil(dropBase.xp * 0.3);
				if (g.me.hasExpBoost)
				{
					s += " <FONT COLOR='#88ff88'>(+" + boostXp + ")</FONT>";
					xpText.text = s;
					new ToolTip(g, xpText, Localize.t("You have XP BOOST enabled!."), null, "missionView");
				}
				else
				{
					s += " <FONT COLOR='#333333'>(+" + boostXp + ")</FONT>";
					xpText.text = s;
					new ToolTip(g, xpText, Localize.t("You don't have any XP BOOST active, get one if you want to gain <FONT COLOR='#FFFFFF'>[xpBoost]%</FONT> more XP.").replace("[xpBoost]", 0.3 * 100), null, "missionView");
				}
				xpText.x = x;
				xpText.y = rewardY + 5;
				xpText.pivotX = xpText.width / 2;
				if (!g.me.hasExpBoost)
				{
					toolTipText = Localize.t("Get XP BOOST now!");
					xpBoostIcon = new Image(textureManager.getTextureGUIByTextureName("button_pay"));
					xpBoostIcon.useHandCursor = true;
					xpBoostIcon.addEventListener("touch", function(param1:TouchEvent):void
					{
						if (param1.getTouch(xpBoostIcon, "ended"))
						{
							g.enterState(new RoamingState(g));
							g.enterState(new ShopState(g, "xpBoost"));
						}
					});
					xpBoostIcon.x = xpText.x + xpText.width / 2 + 5;
					xpBoostIcon.y = xpText.y;
					addChild(xpBoostIcon);
					new ToolTip(g, xpBoostIcon, toolTipText, null, "shopIcons");
				}
				addChild(xpText);
				rewardY += 20;
			}
			if (mission.majorType == "time")
			{
				timeLeft.font = "Verdana";
				timeLeft.color = 11432200;
				timeLeft.size = 12;
				timeLeft.x = heading.x + heading.width + 20;
				timeLeft.y = heading.y;
				addChild(timeLeft);
			}
			if (dropBase.reputation > 0)
			{
				if (g.me.reputation > 0)
				{
					repImg = "police_icon.png";
				}
				else
				{
					repImg = "pirate_icon.png";
				}
				reputationIcon = new Image(textureManager.getTextureGUIByTextureName(repImg));
				reputationIcon.scaleX = 0.5;
				reputationIcon.scaleY = 0.5;
				reputationText = new Text();
				reputationText.color = 16777215;
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
		
		public function update():void
		{
			if (mission.majorType == "time")
			{
				drawExpireTime();
			}
		}
		
		private function drawExpireTime():void
		{
			var _loc2_:int = (mission.expires - g.time) / 1000;
			if (_loc2_ < 0)
			{
				removeAndRedrawList();
				return;
			}
			if (timeLeft != null)
			{
				timeLeft.htmlText = "" + _loc2_;
			}
			var _loc5_:int = Math.floor(_loc2_ / 3600);
			_loc2_ -= _loc5_ * 60 * 60;
			var _loc1_:int = Math.floor(_loc2_ / 60);
			_loc2_ -= _loc1_ * 60;
			var _loc4_:int = Math.floor(_loc2_);
			var _loc7_:String = _loc5_ < 10 ? "0" + _loc5_ : "" + _loc5_;
			var _loc6_:String = _loc1_ < 10 ? "0" + _loc1_ : "" + _loc1_;
			var _loc3_:String = _loc4_ < 10 ? "0" + _loc4_ : "" + _loc4_;
			if (timeLeft != null)
			{
				timeLeft.htmlText = "(" + Localize.t("expires in") + ": " + _loc7_ + ":" + _loc6_ + ":" + _loc3_ + ")";
			}
		}
		
		private function addRewardItem(param1:DropItem, param2:int, param3:int):int
		{
			var _loc6_:Image = null;
			var _loc4_:Text = new Text();
			_loc4_.color = 16777215;
			_loc4_.size = 14;
			_loc4_.alignCenter();
			_loc4_.x = param2;
			_loc4_.y = param3;
			var _loc8_:String = param1.name;
			_loc8_.toLocaleUpperCase();
			_loc4_.htmlText = param1.quantity.toString();
			while (_loc4_.width > 160)
			{
				_loc4_.size--;
			}
			var _loc7_:Sprite = new Sprite();
			if (param1.table == "Skins")
			{
				_loc6_ = new Image(textureManager.getTexturesMainByKey(param1.bitmapKey)[0]);
			}
			else
			{
				_loc6_ = new Image(textureManager.getTextureGUIByKey(param1.bitmapKey));
			}
			if (_loc6_.height > 30)
			{
				_loc6_.scaleX = _loc6_.scaleY = 20 / _loc6_.height;
			}
			_loc6_.x = param2 - _loc4_.width / 2 - _loc6_.width / 2 - 4;
			_loc6_.y = param3 + _loc4_.height / 2 - _loc6_.height / 2 - 2;
			_loc4_.x += _loc6_.width / 2 - 2;
			var _loc5_:ToolTip = new ToolTip(g, _loc7_, _loc8_, null, "missionView");
			_loc7_.addChild(_loc6_);
			box.addChild(_loc7_);
			box.addChild(_loc4_);
			return param3 + _loc6_.height + 5;
		}
		
		private function addRewardButton(param1:Number):void
		{
			var _loc2_:Button = new Button(tryCollectReward, Localize.t("COLLECT REWARD").toUpperCase(), "positive");
			_loc2_.visible = mission.finished;
			if (box.height < param1 + _loc2_.height + box.padding * 2)
			{
				box.height = param1 + _loc2_.height + box.padding;
			}
			_loc2_.x = box.width - _loc2_.width - box.padding * 2;
			_loc2_.y = height - _loc2_.height - box.padding * 2;
			addChild(_loc2_);
		}
		
		private function addHeading():void
		{
			heading = new Text();
			heading.y = -5;
			heading.color = 16777215;
			heading.size = 13;
			var _loc1_:String = missionType.title;
			heading.htmlText = fixText(g, missionType, _loc1_);
			addChild(heading);
		}
		
		private function addDescription():void
		{
			description = new Text();
			description.font = "Verdana";
			description.color = 10592673;
			description.size = 12;
			description.wordWrap = true;
			description.width = 380;
			var _loc1_:String = missionType.description;
			if (mission.finished && missionType.completeDescription != null)
			{
				if (missionType.hasOwnProperty("nextMission"))
				{
					description.htmlText = Localize.t("Mission Completed! Click claim reward to proceed to next step.");
				}
				else
				{
					description.htmlText = missionType.completeDescription;
				}
			}
			else
			{
				description.htmlText = fixText(g, missionType, _loc1_);
			}
			description.y = 22;
			if (description.height > 90)
			{
				description.width = 460;
			}
			if (description.height > 90)
			{
				description.size--;
			}
			addChild(description);
		}
		
		private function tryCollectReward(param1:TouchEvent):void
		{
			g.rpc("requestMissionReward", rewardArrived, mission.id, mission.majorType);
		}
		
		private function rewardArrived(param1:Message):void
		{
			var _loc3_:Boolean = param1.getBoolean(0);
			if (!_loc3_)
			{
				g.showErrorDialog(Localize.t("Mission not complete."));
				return;
			}
			if (missionType.majorType == "static")
			{
				Game.trackEvent("missions", "static", missionType.title);
			}
			else if (missionType.majorType == "time")
			{
				Game.trackEvent("missions", "timed", missionType.title);
			}
			g.me.removeMission(mission);
			g.creditManager.refresh();
			for each (var _loc2_:* in dropBase.items)
			{
				transferItemToCargo(_loc2_);
			}
			g.hud.cargoButton.update();
			g.hud.resourceBox.update();
			g.hud.cargoButton.flash();
			animateCollectReward();
		}
		
		private function removeAndRedrawList():void
		{
			tween = TweenMax.to(this, 0.3, {"alpha": 0, "onComplete": redrawParentList, "ease": Circ.easeIn});
		}
		
		private function redrawParentList():void
		{
			g.me.removeMission(mission);
			dispatchEventWith("reload");
		}
		
		private function animateCollectReward():void
		{
			tween = TweenMax.to(this, 0.3, {"alpha": 0, "onComplete": collectReward, "ease": Circ.easeIn});
			var _loc1_:ISound = SoundLocator.getService();
			_loc1_.preCacheSound("7zeIcPFb-UWzgtR_3nrZ8Q");
		}
		
		private function collectReward():void
		{
			dispatchEventWith("animateCollectReward", true);
			g.textManager.createMissionCompleteText();
		}
		
		private function transferItemToCargo(param1:Object):void
		{
			var _loc4_:String = param1.table;
			var _loc3_:String = param1.item;
			var _loc2_:Number = Number(param1.quantity);
			g.myCargo.addItem(_loc4_, _loc3_, _loc2_);
		}
	}
}
