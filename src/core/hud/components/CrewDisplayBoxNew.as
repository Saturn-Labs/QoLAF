package core.hud.components
{
	import com.greensock.TweenMax;
	import core.artifact.ArtifactCargoBox;
	import core.credits.CreditManager;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.player.CrewMember;
	import core.player.Explore;
	import core.scene.Game;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewDisplayBoxNew extends Sprite
	{
		private static const HEIGHT:int = 58;
		
		private static const WIDTH:int = 52;
		
		private static const textX1:int = 60;
		
		private static const textX2:int = 175;
		
		private static const textY1:int = 7;
		
		private static const textY2:int = 30;
		
		public static const MODE_SHIP:int = 0;
		
		public static const MODE_CANTINA:int = 1;
		
		public static const MODE_UPGRADE_ARTIFACT:int = 2;
		
		private var exploreTimer:HudTimer;
		
		private var trainingTimer:HudTimer;
		
		private var trainInstantButton:Button;
		
		private var upgradeArtifactBox:ArtifactCargoBox;
		
		private var upgradeInstantButton:Button;
		
		private var upgradeArtifactTimer:HudTimer;
		
		private var img:Image;
		
		public var crewMember:CrewMember;
		
		private var injuryTimer:HudTimer;
		
		private var injuryStatus:Text;
		
		private var box:Quad;
		
		private var g:Game;
		
		private var bgColor:uint = 1717572;
		
		public var mode:int;
		
		private var isSelected:Boolean = false;
		
		private var selectButton:Button;
		
		private var waitingTween:TweenMax;
		
		private var trainingCompleteText:Text;
		
		private var onBoardShipText:Text;
		
		private var hovering:Boolean = false;
		
		private var doUpdate:Boolean = true;
		
		public function CrewDisplayBoxNew(param1:Game, param2:CrewMember, param3:int = 0)
		{
			this.crewMember = param2;
			this.mode = param3;
			this.g = param1;
			super();
			var _loc6_:Sprite = new Sprite();
			var _loc4_:ITextureManager = TextureLocator.getService();
			img = new Image(_loc4_.getTextureGUIByKey(param2.imageKey));
			img.height = 58;
			img.width = 52;
			var _loc5_:Text = new Text(60, 7);
			_loc5_.text = param2.name;
			_loc5_.color = 16623682;
			_loc5_.size = 14;
			box = new Quad(273, 58, bgColor);
			box.useHandCursor = true;
			addChild(box);
			addChild(_loc5_);
			_loc6_.addChild(img);
			addChild(_loc6_);
			if (param3 == 2)
			{
				new ToolTip(param1, _loc6_, param2.getToolTipText(), null, "crewSkill");
			}
			addEventListener("touch", onTouch);
			addLocation();
			setSelected(false);
			addEventListener("removedFromStage", clean);
			update();
		}
		
		public function get key():String
		{
			return crewMember.key;
		}
		
		public function setSelected(param1:Boolean):void
		{
			param1 ? (box.alpha = 1) : (box.alpha = 0);
			isSelected = param1;
			if (!param1)
			{
				return;
			}
			dispatchEventWith("crewSelected", true);
		}
		
		public function getLevel(param1:int):int
		{
			return crewMember.skills[param1];
		}
		
		public function update():void
		{
			if (exploreTimer != null)
			{
				if (exploreTimer.isComplete())
				{
					removeChild(exploreTimer);
					exploreTimer = null;
					addWaitingForPickup();
					reloadDetails();
				}
				else
				{
					exploreTimer.update();
				}
			}
			updateTraining();
			if (injuryTimer != null)
			{
				if (injuryTimer.isComplete())
				{
					removeChild(injuryTimer);
					removeChild(injuryStatus);
					injuryTimer = null;
					reloadDetails();
					addOnboardShip();
				}
				else
				{
					injuryTimer.update();
				}
			}
			if (upgradeArtifactTimer != null)
			{
				if (upgradeArtifactTimer.isComplete())
				{
					upgradeArtifactComplete();
				}
				else
				{
					upgradeArtifactTimer.update();
				}
			}
			else if (crewMember.isUpgrading)
			{
				addUpgradeTimer();
			}
			if (!doUpdate)
			{
				return;
			}
			TweenMax.delayedCall(1, update);
		}
		
		private function upgradeArtifactComplete():void
		{
			removeChild(upgradeArtifactTimer);
			removeChild(upgradeArtifactBox);
			removeChild(upgradeInstantButton);
			upgradeArtifactTimer = null;
			reloadDetails();
			if (onBoardShipText == null)
			{
				addOnboardShip();
			}
			onBoardShipText.text = Localize.t("Onboard ship");
			dispatchEventWith("upgradeArtifactComplete", true);
		}
		
		private function updateTraining():void
		{
			if (trainingTimer != null)
			{
				if (trainingTimer.isComplete())
				{
					addTrainingComplete();
					reloadDetails();
				}
				else
				{
					trainingTimer.update();
				}
			}
			else if (crewMember.isTraining)
			{
				addTrainingTimer();
			}
			if (trainingCompleteText != null && crewMember.trainingEnd == 0)
			{
				if (waitingTween)
				{
					waitingTween.kill();
				}
				removeChild(trainingCompleteText);
				onBoardShipText.text = Localize.t("Onboard ship");
			}
		}
		
		private function reloadDetails():void
		{
			if (!isSelected)
			{
				return;
			}
			dispatchEventWith("reloadDetails", true);
		}
		
		private function addTrainingTimer():void
		{
			if (crewMember.trainingEnd == 0)
			{
				return;
			}
			if (crewMember.trainingEnd < g.time)
			{
				addTrainingComplete();
				return;
			}
			if (trainingTimer != null)
			{
				return;
			}
			trainingTimer = new HudTimer(g, 10);
			trainingTimer.start(g.time, crewMember.trainingEnd);
			trainingTimer.x = 175;
			trainingTimer.y = 30 + 1;
			onBoardShipText.text = Localize.t("Training");
			addChild(trainingTimer);
			trainInstantButton = new Button(function():void
			{
				g.creditManager.refresh(function():void
				{
					var confirmBuyWithFlux:CreditBuyBox = new CreditBuyBox(g, CreditManager.getCostCrewTraining(), Localize.t("Are you sure you want to buy instant crew training?"));
					g.addChildToOverlay(confirmBuyWithFlux);
					confirmBuyWithFlux.addEventListener("accept", function():void
					{
						g.rpc("buyInstantCrewTraining", instantCrewTraining, crewMember.key);
						confirmBuyWithFlux.removeEventListeners();
						g.removeChildFromOverlay(confirmBuyWithFlux, true);
					});
					confirmBuyWithFlux.addEventListener("close", function():void
					{
						trainInstantButton.enabled = true;
						confirmBuyWithFlux.removeEventListeners();
						g.removeChildFromOverlay(confirmBuyWithFlux, true);
					});
				});
			}, Localize.t("Speed up"), "buy");
			trainInstantButton.scaleX = trainInstantButton.scaleY = 0.9;
			trainInstantButton.x = 180;
			trainInstantButton.y = 30 + 1 - 25;
			addChild(trainInstantButton);
		}
		
		private function instantCrewTraining(param1:Message):void
		{
			var _loc2_:int = 0;
			var _loc3_:int = 0;
			if (param1.getBoolean(0))
			{
				_loc2_ = param1.getInt(1);
				_loc3_ = _loc2_ - crewMember.skillPoints;
				crewMember.completeTraining(_loc2_);
				g.showMessageDialog(Localize.t("[name] got [diff] new skill points!").replace("[name]", crewMember.name).replace("[diff]", _loc3_), reloadDetails);
				removeChild(trainingTimer);
				removeChild(trainInstantButton);
				trainingTimer = null;
				trainInstantButton = null;
				Game.trackEvent("used flux", "instant crew training", g.me.level.toString(), CreditManager.getCostCrewTraining());
			}
			else if (param1.length > 1)
			{
				g.showErrorDialog(param1.getString(1), false);
			}
		}
		
		private function addUpgradeTimer():void
		{
			if (crewMember.artifactEnd == 0)
			{
				return;
			}
			if (crewMember.artifactEnd < g.time)
			{
				return;
			}
			if (upgradeArtifactTimer != null)
			{
				return;
			}
			upgradeArtifactTimer = new HudTimer(g, 10);
			upgradeArtifactTimer.start(g.time, crewMember.artifactEnd);
			upgradeArtifactTimer.x = 175;
			upgradeArtifactTimer.y = 30 + 1;
			onBoardShipText.text = Localize.t("Upgrading");
			addChild(upgradeArtifactTimer);
			upgradeArtifactBox = new ArtifactCargoBox(g, g.me.getArtifactById(crewMember.artifact));
			upgradeArtifactBox.scaleX = upgradeArtifactBox.scaleY = 0.75;
			upgradeArtifactBox.x = onBoardShipText.x + onBoardShipText.width + 10;
			upgradeArtifactBox.y = onBoardShipText.y;
			addChild(upgradeArtifactBox);
			upgradeInstantButton = new Button(function():void
			{
				g.showModalLoadingScreen(Localize.t("Hang on..."));
				g.creditManager.refresh(function():void
				{
					var confirmBuyWithFlux:CreditBuyBox;
					g.hideModalLoadingScreen();
					confirmBuyWithFlux = new CreditBuyBox(g, CreditManager.getCostArtifactUpgrade(g, crewMember.artifactEnd), Localize.t("Are you sure you want to buy instant artifact upgrade?"));
					g.addChildToOverlay(confirmBuyWithFlux);
					confirmBuyWithFlux.addEventListener("accept", function():void
					{
						g.showModalLoadingScreen(Localize.t("Upgrading..."));
						g.rpc("buyInstantArtifactUpgrade", instantArtifactUpgrade, crewMember.key);
						confirmBuyWithFlux.removeEventListeners();
						g.removeChildFromOverlay(confirmBuyWithFlux, true);
					});
					confirmBuyWithFlux.addEventListener("close", function():void
					{
						upgradeInstantButton.enabled = true;
						confirmBuyWithFlux.removeEventListeners();
						g.removeChildFromOverlay(confirmBuyWithFlux, true);
					});
				});
			}, Localize.t("Speed Up"), "buy");
			upgradeInstantButton.scaleX = upgradeInstantButton.scaleY = 0.9;
			upgradeInstantButton.x = 180;
			upgradeInstantButton.y = 30 + 1 - 25;
			addChild(upgradeInstantButton);
		}
		
		private function instantArtifactUpgrade(param1:Message):void
		{
			g.hideModalLoadingScreen();
			if (param1.getBoolean(0))
			{
				crewMember.artifactEnd = param1.getNumber(1);
				upgradeArtifactComplete();
				Game.trackEvent("used flux", "instant artifact upgrade", g.me.level.toString(), CreditManager.getCostArtifactUpgrade(g, crewMember.artifactEnd));
			}
			else if (param1.length > 1)
			{
				g.showErrorDialog(param1.getString(1), false);
			}
		}
		
		private function addLocation():void
		{
			if (crewMember.isDeployed)
			{
				addText(60, 30, crewMember.getCompactFullLocation(), 16776960);
				for each (var _loc1_:* in g.me.explores)
				{
					if (_loc1_.areaKey == crewMember.area)
					{
						if (_loc1_.finishTime < g.time)
						{
							addWaitingForPickup();
							break;
						}
						exploreTimer = new HudTimer(g, 10);
						exploreTimer.start(_loc1_.startTime, _loc1_.finishTime);
						exploreTimer.x = 175;
						exploreTimer.y = 30;
						addChild(exploreTimer);
						break;
					}
				}
			}
			else if (crewMember.isInjured)
			{
				injuryStatus = new Text(60, 30);
				injuryStatus.font = "Verdana";
				injuryStatus.text = Localize.t("In sick bay, injured");
				injuryStatus.size = 11;
				injuryStatus.color = 16711680;
				addChild(injuryStatus);
				injuryTimer = new HudTimer(g, 10);
				injuryTimer.x = 175;
				injuryTimer.y = 30;
				injuryTimer.start(crewMember.injuryStart, crewMember.injuryEnd);
				addChild(injuryTimer);
			}
			else
			{
				addOnboardShip();
			}
		}
		
		private function addWaitingForPickup():void
		{
			var t:Text = addText(175 + 3, 30, Localize.t("Awaiting pickup"), 16623682);
			waitingTween = TweenMax.to(t, 1, {"repeat": -1, "yoyo": true, "alpha": 0.5, "onComplete": function():void
			{
				t.alpha = 1;
			}});
		}
		
		private function addTrainingComplete():void
		{
			removeChild(trainingTimer);
			removeChild(trainInstantButton);
			trainingTimer = null;
			if (trainingCompleteText)
			{
				return;
			}
			trainingCompleteText = addText(175 - 10, 30, Localize.t("Training complete"), 5635925);
			if (onBoardShipText == null)
			{
				addOnboardShip();
			}
			onBoardShipText.text = Localize.t("Onboard ship");
			waitingTween = TweenMax.to(trainingCompleteText, 1, {"repeat": -1, "yoyo": true, "alpha": 0.5});
		}
		
		private function addOnboardShip():void
		{
			if (mode == 1)
			{
				return;
			}
			onBoardShipText = addText(60, 30, Localize.t("Onboard ship"), 16777215);
		}
		
		private function addText(param1:int, param2:int, param3:String, param4:uint):Text
		{
			var _loc5_:Text = new Text(param1, param2);
			_loc5_.size = 11;
			_loc5_.font = "Verdana";
			_loc5_.text = param3;
			_loc5_.color = param4;
			addChild(_loc5_);
			return _loc5_;
		}
		
		private function onClick(param1:TouchEvent = null):void
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < parent.numChildren)
			{
				if (parent.getChildAt(_loc2_) is CrewDisplayBoxNew)
				{
					(parent.getChildAt(_loc2_) as CrewDisplayBoxNew).setSelected(false);
				}
				if (parent.getChildAt(_loc2_) is CrewBuySlot)
				{
					(parent.getChildAt(_loc2_) as CrewBuySlot).setSelected(false);
				}
				_loc2_++;
			}
			setSelected(true);
		}
		
		public function mOver(param1:TouchEvent):void
		{
			if (hovering)
			{
				return;
			}
			hovering = true;
			if (isSelected)
			{
				return;
			}
			box.alpha = 0.6;
		}
		
		public function mOut(param1:TouchEvent):void
		{
			if (!hovering)
			{
				return;
			}
			hovering = false;
			if (isSelected)
			{
				box.alpha = 1;
				return;
			}
			box.alpha = 0;
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (mode == 2 && (crewMember.isDeployed || crewMember.isInjured || crewMember.isTraining || crewMember.isUpgrading))
			{
				useHandCursor = false;
				return;
			}
			useHandCursor = true;
			if (param1.getTouch(this, "ended"))
			{
				onClick(param1);
			}
			else if (param1.interactsWith(this))
			{
				mOver(param1);
			}
			else if (!param1.interactsWith(this))
			{
				mOut(param1);
			}
		}
		
		public function clean(param1:Event = null):void
		{
			doUpdate = false;
			ToolTip.disposeType("crewSkill");
			removeEventListener("touch", onTouch);
			removeEventListener("removedFromStage", clean);
			if (waitingTween)
			{
				waitingTween.kill();
			}
		}
	}
}
