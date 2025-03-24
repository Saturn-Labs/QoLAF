package core.hud.components {
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
	
	public class CrewDisplayBoxNew extends Sprite {
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
		
		public function CrewDisplayBoxNew(g:Game, crewMember:CrewMember, mode:int = 0) {
			this.crewMember = crewMember;
			this.mode = mode;
			this.g = g;
			super();
			var _local4:Sprite = new Sprite();
			var _local6:ITextureManager = TextureLocator.getService();
			img = new Image(_local6.getTextureGUIByKey(crewMember.imageKey));
			img.height = 58;
			img.width = 52;
			var _local5:Text = new Text(60,7);
			_local5.text = crewMember.name;
			_local5.color = 16623682;
			_local5.size = 14;
			box = new Quad(273,58,bgColor);
			box.useHandCursor = true;
			addChild(box);
			addChild(_local5);
			_local4.addChild(img);
			addChild(_local4);
			if(mode == 2) {
				new ToolTip(g,_local4,crewMember.getToolTipText(),null,"crewSkill");
			}
			addEventListener("touch",onTouch);
			addLocation();
			setSelected(false);
			addEventListener("removedFromStage",clean);
			update();
		}
		
		public function get key() : String {
			return crewMember.key;
		}
		
		public function setSelected(value:Boolean) : void {
			value ? (box.alpha = 1) : (box.alpha = 0);
			isSelected = value;
			if(!value) {
				return;
			}
			dispatchEventWith("crewSelected",true);
		}
		
		public function getLevel(i:int) : int {
			return crewMember.skills[i];
		}
		
		public function update() : void {
			if(exploreTimer != null) {
				if(exploreTimer.isComplete()) {
					removeChild(exploreTimer);
					exploreTimer = null;
					addWaitingForPickup();
					reloadDetails();
				} else {
					exploreTimer.update();
				}
			}
			updateTraining();
			if(injuryTimer != null) {
				if(injuryTimer.isComplete()) {
					removeChild(injuryTimer);
					removeChild(injuryStatus);
					injuryTimer = null;
					reloadDetails();
					addOnboardShip();
				} else {
					injuryTimer.update();
				}
			}
			if(upgradeArtifactTimer != null) {
				if(upgradeArtifactTimer.isComplete()) {
					upgradeArtifactComplete();
				} else {
					upgradeArtifactTimer.update();
				}
			} else if(crewMember.isUpgrading) {
				addUpgradeTimer();
			}
			if(!doUpdate) {
				return;
			}
			TweenMax.delayedCall(1,update);
		}
		
		private function upgradeArtifactComplete() : void {
			removeChild(upgradeArtifactTimer);
			removeChild(upgradeArtifactBox);
			removeChild(upgradeInstantButton);
			upgradeArtifactTimer = null;
			reloadDetails();
			if(onBoardShipText == null) {
				addOnboardShip();
			}
			onBoardShipText.text = Localize.t("Onboard ship");
			dispatchEventWith("upgradeArtifactComplete",true);
		}
		
		private function updateTraining() : void {
			if(trainingTimer != null) {
				if(trainingTimer.isComplete()) {
					addTrainingComplete();
					reloadDetails();
				} else {
					trainingTimer.update();
				}
			} else if(crewMember.isTraining) {
				addTrainingTimer();
			}
			if(trainingCompleteText != null && crewMember.trainingEnd == 0) {
				if(waitingTween) {
					waitingTween.kill();
				}
				removeChild(trainingCompleteText);
				onBoardShipText.text = Localize.t("Onboard ship");
			}
		}
		
		private function reloadDetails() : void {
			if(!isSelected) {
				return;
			}
			dispatchEventWith("reloadDetails",true);
		}
		
		private function addTrainingTimer() : void {
			if(crewMember.trainingEnd == 0) {
				return;
			}
			if(crewMember.trainingEnd < g.time) {
				addTrainingComplete();
				return;
			}
			if(trainingTimer != null) {
				return;
			}
			trainingTimer = new HudTimer(g,10);
			trainingTimer.start(g.time,crewMember.trainingEnd);
			trainingTimer.x = 175;
			trainingTimer.y = 30 + 1;
			onBoardShipText.text = Localize.t("Training");
			addChild(trainingTimer);
			trainInstantButton = new Button(function():void {
				g.creditManager.refresh(function():void {
					var confirmBuyWithFlux:CreditBuyBox = new CreditBuyBox(g,CreditManager.getCostCrewTraining(),Localize.t("Are you sure you want to buy instant crew training?"));
					g.addChildToOverlay(confirmBuyWithFlux);
					confirmBuyWithFlux.addEventListener("accept",function():void {
						g.rpc("buyInstantCrewTraining",instantCrewTraining,crewMember.key);
						confirmBuyWithFlux.removeEventListeners();
						g.removeChildFromOverlay(confirmBuyWithFlux,true);
					});
					confirmBuyWithFlux.addEventListener("close",function():void {
						trainInstantButton.enabled = true;
						confirmBuyWithFlux.removeEventListeners();
						g.removeChildFromOverlay(confirmBuyWithFlux,true);
					});
				});
			},Localize.t("Speed up"),"buy");
			trainInstantButton.scaleX = trainInstantButton.scaleY = 0.9;
			trainInstantButton.x = 3 * 60;
			trainInstantButton.y = 30 + 1 - 25;
			addChild(trainInstantButton);
		}
		
		private function instantCrewTraining(m:Message) : void {
			var _local2:int = 0;
			var _local3:int = 0;
			if(m.getBoolean(0)) {
				_local2 = m.getInt(1);
				_local3 = _local2 - crewMember.skillPoints;
				crewMember.completeTraining(_local2);
				g.showMessageDialog(Localize.t("[name] got [diff] new skill points!").replace("[name]",crewMember.name).replace("[diff]",_local3),reloadDetails);
				removeChild(trainingTimer);
				removeChild(trainInstantButton);
				trainingTimer = null;
				trainInstantButton = null;
				Game.trackEvent("used flux","instant crew training",g.me.level.toString(),CreditManager.getCostCrewTraining());
			} else if(m.length > 1) {
				g.showErrorDialog(m.getString(1),false);
			}
		}
		
		private function addUpgradeTimer() : void {
			if(crewMember.artifactEnd == 0) {
				return;
			}
			if(crewMember.artifactEnd < g.time) {
				return;
			}
			if(upgradeArtifactTimer != null) {
				return;
			}
			upgradeArtifactTimer = new HudTimer(g,10);
			upgradeArtifactTimer.start(g.time,crewMember.artifactEnd);
			upgradeArtifactTimer.x = 175;
			upgradeArtifactTimer.y = 30 + 1;
			onBoardShipText.text = Localize.t("Upgrading");
			addChild(upgradeArtifactTimer);
			upgradeArtifactBox = new ArtifactCargoBox(g,g.me.getArtifactById(crewMember.artifact));
			upgradeArtifactBox.scaleX = upgradeArtifactBox.scaleY = 0.75;
			upgradeArtifactBox.x = onBoardShipText.x + onBoardShipText.width + 10;
			upgradeArtifactBox.y = onBoardShipText.y;
			addChild(upgradeArtifactBox);
			upgradeInstantButton = new Button(function():void {
				g.showModalLoadingScreen(Localize.t("Hang on..."));
				g.creditManager.refresh(function():void {
					var confirmBuyWithFlux:CreditBuyBox;
					g.hideModalLoadingScreen();
					confirmBuyWithFlux = new CreditBuyBox(g,CreditManager.getCostArtifactUpgrade(g,crewMember.artifactEnd),Localize.t("Are you sure you want to buy instant artifact upgrade?"));
					g.addChildToOverlay(confirmBuyWithFlux);
					confirmBuyWithFlux.addEventListener("accept",function():void {
						g.showModalLoadingScreen(Localize.t("Upgrading..."));
						g.rpc("buyInstantArtifactUpgrade",instantArtifactUpgrade,crewMember.key);
						confirmBuyWithFlux.removeEventListeners();
						g.removeChildFromOverlay(confirmBuyWithFlux,true);
					});
					confirmBuyWithFlux.addEventListener("close",function():void {
						upgradeInstantButton.enabled = true;
						confirmBuyWithFlux.removeEventListeners();
						g.removeChildFromOverlay(confirmBuyWithFlux,true);
					});
				});
			},Localize.t("Speed Up"),"buy");
			upgradeInstantButton.scaleX = upgradeInstantButton.scaleY = 0.9;
			upgradeInstantButton.x = 3 * 60;
			upgradeInstantButton.y = 30 + 1 - 25;
			addChild(upgradeInstantButton);
		}
		
		private function instantArtifactUpgrade(m:Message) : void {
			g.hideModalLoadingScreen();
			if(m.getBoolean(0)) {
				crewMember.artifactEnd = m.getNumber(1);
				upgradeArtifactComplete();
				Game.trackEvent("used flux","instant artifact upgrade",g.me.level.toString(),CreditManager.getCostArtifactUpgrade(g,crewMember.artifactEnd));
			} else if(m.length > 1) {
				g.showErrorDialog(m.getString(1),false);
			}
		}
		
		private function addLocation() : void {
			if(crewMember.isDeployed) {
				addText(60,30,crewMember.getCompactFullLocation(),0xffff00);
				for each(var _local1 in g.me.explores) {
					if(_local1.areaKey == crewMember.area) {
						if(_local1.finishTime < g.time) {
							addWaitingForPickup();
							break;
						}
						exploreTimer = new HudTimer(g,10);
						exploreTimer.start(_local1.startTime,_local1.finishTime);
						exploreTimer.x = 175;
						exploreTimer.y = 30;
						addChild(exploreTimer);
						break;
					}
				}
			} else if(crewMember.isInjured) {
				injuryStatus = new Text(60,30);
				injuryStatus.font = "Verdana";
				injuryStatus.text = Localize.t("In sick bay, injured");
				injuryStatus.size = 11;
				injuryStatus.color = 0xff0000;
				addChild(injuryStatus);
				injuryTimer = new HudTimer(g,10);
				injuryTimer.x = 175;
				injuryTimer.y = 30;
				injuryTimer.start(crewMember.injuryStart,crewMember.injuryEnd);
				addChild(injuryTimer);
			} else {
				addOnboardShip();
			}
		}
		
		private function addWaitingForPickup() : void {
			var t:Text = addText(175 + 3,30,Localize.t("Awaiting pickup"),16623682);
			waitingTween = TweenMax.to(t,1,{
				"repeat":-1,
				"yoyo":true,
				"alpha":0.5,
				"onComplete":function():void {
					t.alpha = 1;
				}
			});
		}
		
		private function addTrainingComplete() : void {
			removeChild(trainingTimer);
			removeChild(trainInstantButton);
			trainingTimer = null;
			if(trainingCompleteText) {
				return;
			}
			trainingCompleteText = addText(175 - 10,30,Localize.t("Training complete"),0x55ff55);
			if(onBoardShipText == null) {
				addOnboardShip();
			}
			onBoardShipText.text = Localize.t("Onboard ship");
			waitingTween = TweenMax.to(trainingCompleteText,1,{
				"repeat":-1,
				"yoyo":true,
				"alpha":0.5
			});
		}
		
		private function addOnboardShip() : void {
			if(mode == 1) {
				return;
			}
			onBoardShipText = addText(60,30,Localize.t("Onboard ship"),0xffffff);
		}
		
		private function addText(xPos:int, yPos:int, text:String, color:uint) : Text {
			var _local5:Text = new Text(xPos,yPos);
			_local5.size = 11;
			_local5.font = "Verdana";
			_local5.text = text;
			_local5.color = color;
			addChild(_local5);
			return _local5;
		}
		
		private function onClick(e:TouchEvent = null) : void {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < parent.numChildren) {
				if(parent.getChildAt(_local2) is CrewDisplayBoxNew) {
					(parent.getChildAt(_local2) as CrewDisplayBoxNew).setSelected(false);
				}
				if(parent.getChildAt(_local2) is CrewBuySlot) {
					(parent.getChildAt(_local2) as CrewBuySlot).setSelected(false);
				}
				_local2++;
			}
			setSelected(true);
		}
		
		public function mOver(e:TouchEvent) : void {
			if(hovering) {
				return;
			}
			hovering = true;
			if(isSelected) {
				return;
			}
			box.alpha = 0.6;
		}
		
		public function mOut(e:TouchEvent) : void {
			if(!hovering) {
				return;
			}
			hovering = false;
			if(isSelected) {
				box.alpha = 1;
				return;
			}
			box.alpha = 0;
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(mode == 2 && (crewMember.isDeployed || crewMember.isInjured || crewMember.isTraining || crewMember.isUpgrading)) {
				useHandCursor = false;
				return;
			}
			useHandCursor = true;
			if(e.getTouch(this,"ended")) {
				onClick(e);
			} else if(e.interactsWith(this)) {
				mOver(e);
			} else if(!e.interactsWith(this)) {
				mOut(e);
			}
		}
		
		public function clean(e:Event = null) : void {
			doUpdate = false;
			ToolTip.disposeType("crewSkill");
			removeEventListener("touch",onTouch);
			removeEventListener("removedFromStage",clean);
			if(waitingTween) {
				waitingTween.kill();
			}
		}
	}
}

