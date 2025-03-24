package core.artifact {
	import com.greensock.TweenMax;
	import core.credits.CreditManager;
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.CrewDisplayBoxNew;
	import core.hud.components.InputText;
	import core.hud.components.LootItem;
	import core.hud.components.PriceCommodities;
	import core.hud.components.Style;
	import core.hud.components.TextBitmap;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.hud.components.dialogs.LootPopupMessage;
	import core.hud.components.dialogs.PopupBuyMessage;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import core.states.gameStates.RoamingState;
	import core.states.gameStates.ShopState;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ToggleButton;
	import generics.Localize;
	import generics.Util;
	import playerio.DatabaseObject;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ArtifactOverview extends Sprite {
		private static var artifactsLoaded:Boolean;
		
		private static var textureManager:ITextureManager;
		
		private static const MAX_RECYCLE:int = 40;
		
		private var g:Game;
		
		private var p:Player;
		
		private var activeSlots:Vector.<ArtifactBox> = new Vector.<ArtifactBox>();
		
		private var cargoBoxes:Vector.<ArtifactCargoBox> = new Vector.<ArtifactCargoBox>();
		
		private var statisticSummary:TextField;
		
		private var recycleMode:Boolean;
		
		private var upgradeMode:Boolean;
		
		private var statsContainer:ScrollContainer;
		
		private var toggleRecycleButton:Button;
		
		private var toggleUpgradeButton:Button;
		
		private var upgradeButton:Button;
		
		private var cancelUpgradeButton:Button;
		
		private var chooseSortingButton:Button;
		
		private var selectAllRecycleButton:Button;
		
		private var recycleButton:Button;
		
		private var cancelRecycleButton:Button;
		
		private var recycleText:TextField;
		
		private var recycleTextInfo:TextField;
		
		private var autoRecycleButton:Button;
		
		private var buySupporter:Button;
		
		private var autoRecycleInput:InputText;
		
		private var autoRecycleText:TextField;
		
		private var autoRecycleTextInfo:TextField;
		
		private var markedForRecycle:Vector.<Artifact> = new Vector.<Artifact>();
		
		private var setups:Array = [];
		
		private var cargoContainer:ScrollContainer;
		
		private const artifactSetupButtonHeight:int = 24;
		
		private const artifactSetupY:int = 70;
		
		private var crewContainer:Sprite;
		
		private var labelSelectCrew:TextBitmap;
		
		private var loadingText:TextField;
		
		private var selectedUpgradeBox:ArtifactCargoBox;
		
		private var selectedCrewMember:CrewDisplayBoxNew;
		
		public function ArtifactOverview(g:Game) {
			super();
			this.g = g;
			this.p = g.me;
			addEventListener("artifactSelected",onSelect);
			addEventListener("artifactRecycleSelected",onRecycleSelect);
			addEventListener("artifactUpgradeSelected",onUpgradeSelect);
			addEventListener("artifactSlotUnlock",onUnlock);
			addEventListener("activeArtifactRemoved",onActiveRemoved);
			addEventListener("crewSelected",onCrewSelected);
			addEventListener("upgradeArtifactComplete",onUpgradeArtifactComplete);
		}
		
		public function load() : void {
			if(artifactsLoaded) {
				Starling.juggler.delayCall(drawComponents,0.1);
				return;
			}
			textureManager = TextureLocator.getService();
			loadingText = new TextField(400,100,Localize.t("Loading data..."),new TextFormat("DAIDRR",30,0xffffff));
			loadingText.x = 380 - loadingText.width / 2 - 55;
			loadingText.y = 5 * 60 - loadingText.height / 2 - 50;
			addChild(loadingText);
			TweenMax.fromTo(loadingText,1,{"alpha":1},{
				"alpha":0.5,
				"yoyo":true,
				"repeat":15
			});
			g.dataManager.loadRangeFromBigDB("Artifacts","ByPlayer",[p.id],function(param1:Array):void {
				var message:Message;
				var obj:DatabaseObject;
				var artifact:Artifact;
				var a:Artifact;
				var i:int;
				var cm:CrewMember;
				var array:Array = param1;
				if(array.length >= p.artifactLimit) {
					g.hud.showArtifactLimitText();
					g.tutorial.showArtifactLimitAdvice();
				}
				p.artifactCount = array.length;
				g.send("artifactCount",array.length);
				message = new Message("validateUniqueArts");
				for each(obj in array) {
					if(obj != null) {
						artifact = new Artifact(obj);
						if(artifact.isUnique) {
							message.add(artifact.id);
						}
						a = p.getArtifactById(artifact.id);
						i = 0;
						while(i < p.crewMembers.length) {
							cm = p.crewMembers[i];
							if(cm.artifact == artifact.id) {
								if(a != null) {
									a.upgrading = true;
								} else {
									artifact.upgrading = true;
								}
							}
							i++;
						}
						if(a == null) {
							p.artifacts.push(artifact);
						}
					}
				}
				if(message.length == 0) {
					loadComplate();
					return;
				}
				g.rpcMessage(message,function(param1:Message):void {
					if(param1.getBoolean(0)) {
						loadComplate();
					} else {
						updateInvalidUniqueArts(param1);
					}
				});
			},1000);
		}
		
		private function updateInvalidUniqueArts(m:Message) : void {
			var keys:Array = [];
			var i:int = 1;
			while(i < m.length) {
				keys.push(m.getString(i));
				i++;
			}
			g.dataManager.loadKeysFromBigDB("Artifacts",keys,function(param1:Array):void {
				var _local2:Artifact = null;
				for each(var _local3 in param1) {
					if(_local3 != null) {
						_local2 = g.me.getArtifactById(_local3.key);
						if(g.me.isActiveArtifact(_local2)) {
							g.me.removeArtifactStat(_local2,false);
							_local2.update(_local3);
							g.me.addArtifactStat(_local2,false);
						} else {
							_local2.update(_local3);
						}
					}
				}
				loadComplate();
			});
		}
		
		private function loadComplate() : void {
			artifactsLoaded = true;
			removeChild(loadingText);
			drawComponents();
		}
		
		public function drawComponents() : void {
			var q:Quad;
			var labelArtifactStats:TextBitmap;
			var crewMembersThatCompletedUpgrade:Vector.<CrewMember>;
			var i:int;
			var cm:CrewMember;
			var cmBox:CrewDisplayBoxNew;
			initActiveSlots();
			setActiveArtifacts();
			drawArtifactSetups();
			q = new Quad(650,1,0xaaaaaa);
			q.y = 70 + 24 - 1;
			addChildAt(q,0);
			drawArtifactsInCargo();
			statsContainer = new ScrollContainer();
			statsContainer.x = 390;
			statsContainer.y = 100;
			statsContainer.height = 365;
			statsContainer.width = 270;
			statsContainer.clipContent = true;
			addChild(statsContainer);
			labelArtifactStats = new TextBitmap(0,0,Localize.t("Artifact Stats"),16);
			labelArtifactStats.format.color = 0xffffcf;
			statsContainer.addChild(labelArtifactStats);
			statisticSummary = new TextField(250,560,"");
			statisticSummary.isHtmlText = true;
			statisticSummary.format.horizontalAlign = "left";
			statisticSummary.format.verticalAlign = "top";
			statisticSummary.format.color = 0xd3d3d3;
			statisticSummary.format.font = "Verdana";
			statisticSummary.format.size = 12;
			statisticSummary.autoSize = "vertical";
			statisticSummary.y = 30;
			statsContainer.addChild(statisticSummary);
			reloadStats();
			toggleRecycleButton = new Button(toggleRecycle,Localize.t("Recycle"));
			toggleRecycleButton.x = 97;
			toggleRecycleButton.y = 8 * 60;
			addChild(toggleRecycleButton);
			toggleUpgradeButton = new Button(toggleUpgrade,Localize.t("Upgrade"));
			toggleUpgradeButton.x = toggleRecycleButton.x + toggleRecycleButton.width + 10;
			toggleUpgradeButton.y = 8 * 60;
			addChild(toggleUpgradeButton);
			cancelUpgradeButton = new Button(toggleUpgrade,Localize.t("Cancel"));
			cancelUpgradeButton.x = 140;
			cancelUpgradeButton.y = 8 * 60;
			cancelUpgradeButton.visible = false;
			addChild(cancelUpgradeButton);
			upgradeButton = new Button(onUpgradeArtifact,Localize.t("Upgrade"),"positive");
			upgradeButton.x = cancelUpgradeButton.x + cancelUpgradeButton.width + 30;
			upgradeButton.y = 8 * 60;
			upgradeButton.visible = false;
			upgradeButton.enabled = false;
			addChild(upgradeButton);
			crewContainer = new Sprite();
			crewContainer.x = 390;
			crewContainer.y = 100;
			crewContainer.visible = false;
			addChild(crewContainer);
			labelSelectCrew = new TextBitmap();
			labelSelectCrew.text = Localize.t("Select artifact and crew");
			labelSelectCrew.size = 18;
			crewContainer.addChild(labelSelectCrew);
			crewMembersThatCompletedUpgrade = new Vector.<CrewMember>();
			i = 0;
			while(i < p.crewMembers.length) {
				cm = p.crewMembers[i];
				cmBox = new CrewDisplayBoxNew(g,cm,2);
				if(cm.isUpgradeComplete) {
					crewMembersThatCompletedUpgrade.push(cm);
				}
				cmBox.y = 30 + i * (60);
				crewContainer.addChild(cmBox);
				i++;
			}
			onLoadUpgradeArtifactComplete(crewMembersThatCompletedUpgrade);
			chooseSortingButton = new Button(chooseSorting,Localize.t("Sorting"));
			chooseSortingButton.x = 0;
			chooseSortingButton.y = 8 * 60;
			addChild(chooseSortingButton);
			cancelRecycleButton = new Button(toggleRecycle,Localize.t("Cancel"));
			cancelRecycleButton.x = 140;
			cancelRecycleButton.y = 8 * 60;
			cancelRecycleButton.visible = false;
			addChild(cancelRecycleButton);
			recycleButton = new Button(onRecycle,Localize.t("Recycle"),"positive");
			recycleButton.x = cancelRecycleButton.x + cancelRecycleButton.width + 30;
			recycleButton.y = 8 * 60;
			recycleButton.visible = false;
			addChild(recycleButton);
			selectAllRecycleButton = new Button(selectAllForRecycle,Localize.t("Select Max"));
			selectAllRecycleButton.x = cancelRecycleButton.x - selectAllRecycleButton.width - 10;
			selectAllRecycleButton.y = 8 * 60;
			selectAllRecycleButton.visible = false;
			addChild(selectAllRecycleButton);
			recycleText = new TextField(200,10,"",new TextFormat("DAIDRR",13,Style.COLOR_HIGHLIGHT,"left"));
			recycleText.autoSize = "vertical";
			recycleText.text = Localize.t("Recycle");
			recycleText.visible = false;
			recycleText.x = 380;
			recycleText.y = 100;
			addChild(recycleText);
			recycleTextInfo = new TextField(200,10,"",new TextFormat("Verdana",13,0xffffff,"left"));
			recycleTextInfo.autoSize = "vertical";
			recycleTextInfo.text = Localize.t("Select those artifacts you want to recycle. A recycled artifact will turn into junk that can be further recycled into minerals at the nearest recycle station.");
			recycleTextInfo.visible = false;
			recycleTextInfo.y = recycleText.y + recycleText.height + 2;
			recycleTextInfo.x = recycleText.x;
			addChild(recycleTextInfo);
			autoRecycleText = new TextField(4 * 60,10,"",new TextFormat("DAIDRR",13,Style.COLOR_HIGHLIGHT,"left"));
			autoRecycleText.isHtmlText = true;
			autoRecycleText.autoSize = "vertical";
			autoRecycleText.text = Localize.t("Auto Recycle <FONT COLOR=\'#666666\'>(Supporter Only!)</FONT>");
			autoRecycleText.visible = false;
			autoRecycleText.y = recycleTextInfo.y + recycleTextInfo.height + 10;
			autoRecycleText.x = recycleText.x;
			addChild(autoRecycleText);
			autoRecycleTextInfo = new TextField(200,10,"",new TextFormat("Verdana",13,Style.COLOR_HIGHLIGHT,"left"));
			autoRecycleTextInfo.autoSize = "vertical";
			autoRecycleTextInfo.text = Localize.t("Artifacts below a specified\x03 potential level will be auto-recycled when you pickup drops.");
			autoRecycleTextInfo.visible = false;
			autoRecycleTextInfo.y = autoRecycleText.y + autoRecycleText.height + 2;
			autoRecycleTextInfo.x = recycleText.x;
			addChild(autoRecycleTextInfo);
			buySupporter = new Button(function():void {
				if(g.me.isLanded) {
					g.me.leaveBody();
				} else {
					g.enterState(new RoamingState(g));
					g.enterState(new ShopState(g,"supporterPackage"));
				}
			},Localize.t("Buy Supporter"),"buy");
			buySupporter.y = autoRecycleTextInfo.y + autoRecycleTextInfo.height + 10;
			buySupporter.x = recycleText.x;
			buySupporter.visible = false;
			addChild(buySupporter);
			autoRecycleButton = new Button(onAutoRecycle,Localize.t("Set Level"),"positive");
			autoRecycleButton.x = recycleText.x;
			autoRecycleButton.enabled = g.me.hasSupporter();
			autoRecycleButton.visible = false;
			addChild(autoRecycleButton);
			if(g.me.hasSupporter()) {
				autoRecycleButton.y = autoRecycleTextInfo.y + autoRecycleTextInfo.height + 10;
			} else {
				autoRecycleButton.y = buySupporter.y + buySupporter.height + 10;
			}
			autoRecycleInput = new InputText(autoRecycleButton.x + autoRecycleButton.width + 5,autoRecycleButton.y,40,25);
			autoRecycleInput.text = g.me.artifactAutoRecycleLevel.toString();
			autoRecycleInput.restrict = "0-9";
			autoRecycleInput.maxChars = 3;
			autoRecycleInput.isEnabled = g.me.hasSupporter();
			autoRecycleInput.visible = false;
			addChild(autoRecycleInput);
		}
		
		private function initActiveSlots() : void {
			var _local2:ArtifactBox = null;
			var _local1:int = 0;
			while(_local1 < 5) {
				_local2 = new ArtifactBox(g,null);
				if(_local1 == p.unlockedArtifactSlots) {
					_local2.locked = true;
					_local2.unlockable = true;
				} else if(_local1 > p.unlockedArtifactSlots) {
					_local2.locked = true;
				}
				_local2.update();
				_local2.x = (_local2.width + 15) * _local1;
				_local2.slot = _local1;
				addChild(_local2);
				activeSlots.push(_local2);
				_local1++;
			}
		}
		
		private function setActiveArtifacts() : void {
			var _local1:Artifact = null;
			var _local4:ArtifactBox = null;
			var _local2:int = 0;
			for each(var _local3 in p.activeArtifacts) {
				_local1 = p.getArtifactById(_local3);
				if(_local1 != null) {
					_local4 = activeSlots[_local2++];
					_local4.setActive(_local1);
					_local4.update();
				}
			}
		}
		
		private function drawArtifactSetups() : void {
			var _local4:int = 0;
			var _local3:int = 0;
			var _local5:ToggleButton = null;
			for each(var _local1 in setups) {
				_local1.removeEventListeners();
				removeChild(_local1);
			}
			setups.length = 0;
			var _local2:int = p.artifactSetups.length + 1;
			_local4 = 0;
			_local3 = 10;
			while(_local4 < _local2) {
				_local5 = new ToggleButton();
				_local5.styleNameList.add("artifact_setup");
				addChild(_local5);
				if(_local4 == 0) {
					_local5.label = Localize.t("Setup") + " 1";
					_local5.addEventListener("triggered",onSetupChange);
				} else if(_local4 == _local2 - 1) {
					_local5.defaultIcon = new Image(textureManager.getTextureGUIByTextureName("setup_buy_button"));
					_local5.addEventListener("triggered",onSetupBuy);
				} else {
					_local5.label = (_local4 + 1).toString();
					_local5.addEventListener("triggered",onSetupChange);
				}
				if(_local4 == p.activeArtifactSetup) {
					_local5.isSelected = true;
				}
				_local5.x = _local3;
				_local5.y = 70;
				_local5.height = 24;
				_local5.useHandCursor = true;
				_local5.validate();
				_local3 += _local5.width - 1;
				setups.push(_local5);
				_local4++;
			}
		}
		
		private function drawArtifactsInCargo() : void {
			var _local6:int = 0;
			var _local5:int = 0;
			var _local1:Artifact = null;
			var _local3:ArtifactCargoBox = null;
			var _local7:Button = null;
			var _local2:TextBitmap = null;
			if(cargoContainer == null) {
				cargoContainer = new ScrollContainer();
				cargoContainer.y = 105;
				cargoContainer.height = 365;
				cargoContainer.width = 375;
				addChild(cargoContainer);
			}
			var _local4:int = 0;
			var _local8:int = p.artifacts.length > 100 ? Math.floor(p.artifacts.length / 10) + 1 : 10;
			_local6 = 0;
			while(_local6 < _local8) {
				_local5 = 0;
				while(_local5 < 10) {
					_local1 = _local4 < p.artifacts.length ? p.artifacts[_local4] : null;
					_local3 = new ArtifactCargoBox(g,_local1);
					_local3.x = 36 * _local5;
					_local3.y = (_local3.height + 8) * _local6;
					cargoContainer.addChild(_local3);
					cargoBoxes.push(_local3);
					_local4++;
					_local5++;
				}
				_local6++;
			}
			if(p.artifactCapacityLevel < Player.ARTIFACT_CAPACITY.length - 1) {
				_local7 = new Button(onUpgradeCapacity,p.artifactCount + " / " + p.artifactLimit + " " + Localize.t("INCREASE to") + " " + Player.ARTIFACT_CAPACITY[p.artifactCapacityLevel + 1],"positive");
				_local7.x = 0;
				_local7.width = 340;
				_local7.y = (_local3.height + 8) * _local6;
				cargoContainer.addChild(_local7);
			} else {
				_local2 = new TextBitmap();
				_local2.x = 0;
				_local2.y = (_local3.height + 8) * _local6;
				_local2.text = p.artifactCount + " / " + p.artifactLimit;
				cargoContainer.addChild(_local2);
			}
		}
		
		private function onSelect(e:Event) : void {
			var _local5:* = null;
			var _local2:Artifact = null;
			var _local4:ArtifactCargoBox = e.target as ArtifactCargoBox;
			var _local3:Artifact = _local4.a;
			var _local7:Boolean = p.isActiveArtifact(_local3);
			if(_local7) {
				p.toggleArtifact(_local3);
				for each(_local5 in activeSlots) {
					if(_local5.a == _local3) {
						_local5.setEmpty();
						break;
					}
				}
				_local4.update();
				reloadStats();
				return;
			}
			if(p.nrOfActiveArtifacts() >= p.unlockedArtifactSlots) {
				return;
			}
			for each(var _local6 in p.activeArtifacts) {
				_local2 = p.getArtifactById(_local6);
				if(_local2.isUnique && _local3.isUnique && _local2.name == _local3.name) {
					g.showMessageDialog(Localize.t("You can\'t equip the same unique artifact twice."));
					return;
				}
			}
			for each(_local5 in activeSlots) {
				if(_local5.isEmpty) {
					if(!_local5.locked) {
						_local5.setActive(_local3);
						p.toggleArtifact(_local3);
						_local4.update();
						reloadStats();
						break;
					}
				}
			}
		}
		
		private function onRecycleSelect(e:Event) : void {
			var _local5:int = 0;
			var _local2:Artifact = null;
			var _local4:ArtifactCargoBox = e.target as ArtifactCargoBox;
			var _local3:Artifact = _local4.a;
			_local5 = 0;
			while(_local5 < markedForRecycle.length) {
				_local2 = markedForRecycle[_local5];
				if(_local2 == _local3) {
					markedForRecycle.splice(_local5,1);
					return;
				}
				_local5++;
			}
			if(markedForRecycle.length >= 40) {
				_local4.setNotSelected();
				g.showMessageDialog(Localize.t("You can\'t select more than 40 artifacts to recycle."));
				return;
			}
			markedForRecycle.push(_local3);
		}
		
		private function onAutoRecycle(e:Event) : void {
			autoRecycleButton.enabled = true;
			var _local2:int = int(autoRecycleInput.text);
			g.me.artifactAutoRecycleLevel = _local2;
			g.send("setAutoRecycle",_local2);
			g.showMessageDialog("Auto recycle level has been set to: <font color=\'#FFFF88\'>" + _local2 + "</font>");
		}
		
		private function onUpgradeSelect(e:Event) : void {
			var _local3:ArtifactCargoBox = e.target as ArtifactCargoBox;
			var _local2:Artifact = _local3.a;
			if(selectedUpgradeBox != null && selectedUpgradeBox != _local3) {
				selectedUpgradeBox.setNotSelected();
			}
			if(selectedUpgradeBox == _local3) {
				upgradeButton.enabled = false;
				selectedUpgradeBox = null;
				return;
			}
			if(selectedCrewMember != null) {
				upgradeButton.enabled = true;
			}
			selectedUpgradeBox = _local3;
		}
		
		private function onUnlock(e:Event) : void {
			var box:ArtifactBox = e.target as ArtifactBox;
			var unlockCost:int = int(Player.SLOT_ARTIFACT_UNLOCK_COST[box.slot]);
			var number:int = box.slot + 1;
			var fluxCost:int = CreditManager.getCostArtifactSlot(number);
			var buyBox:PopupBuyMessage = new PopupBuyMessage(g);
			buyBox.text = Localize.t("Artifact Slot");
			buyBox.addCost(new PriceCommodities(g,"flpbTKautkC1QzjWT28gkw",unlockCost));
			buyBox.addBuyForFluxButton(fluxCost,number,"buyArtifactSlotWithFlux",Localize.t("Are you sure you want to buy an artifact slot?"));
			buyBox.addEventListener("fluxBuy",function(param1:Event):void {
				p.unlockedArtifactSlots = number;
				g.removeChildFromOverlay(buyBox,true);
				onSlotUnlock(box);
				Game.trackEvent("used flux","bought artifact slot","number " + number,fluxCost);
			});
			buyBox.addEventListener("accept",function(param1:Event):void {
				var e:Event = param1;
				g.me.tryUnlockSlot("slotArtifact",box.slot + 1,function():void {
					g.removeChildFromOverlay(buyBox,true);
					onSlotUnlock(box);
				});
			});
			buyBox.addEventListener("close",function(param1:Event):void {
				g.removeChildFromOverlay(buyBox,true);
			});
			g.addChildToOverlay(buyBox);
		}
		
		private function onUpgradeCapacity(e:Event) : void {
			var cost:int = CreditManager.getCostArtifactCapacityUpgrade(p.artifactCapacityLevel + 1);
			var creditBuyBox:CreditBuyBox = new CreditBuyBox(g,cost,Localize.t("Increases artifact capacity to") + " " + Player.ARTIFACT_CAPACITY[p.artifactCapacityLevel + 1]);
			g.addChildToOverlay(creditBuyBox);
			creditBuyBox.addEventListener("accept",function(param1:Event):void {
				g.removeChildFromOverlay(creditBuyBox,true);
				g.rpc("upgradeArtifactCapacity",onBuyArtifactConfirm);
			});
			creditBuyBox.addEventListener("close",function(param1:Event):void {
				g.removeChildFromOverlay(creditBuyBox,true);
			});
		}
		
		private function onBuyArtifactConfirm(m:Message) : void {
			var _local2:Boolean = m.getBoolean(0);
			if(!_local2) {
				g.showErrorDialog(m.getString(1));
				return;
			}
			g.showErrorDialog(Localize.t("Success!"));
			p.artifactCapacityLevel += 1;
			drawArtifactsInCargo();
			g.creditManager.refresh();
		}
		
		private function onSlotUnlock(box:ArtifactBox) : void {
			box.locked = false;
			box.unlockable = false;
			box.update();
			var _local2:int = box.slot + 1;
			if(_local2 < activeSlots.length) {
				activeSlots[_local2].unlockable = true;
				activeSlots[_local2].update();
			}
		}
		
		private function onSetupChange(e:Event) : void {
			if(!g.me.isLanded && !g.me.inSafeZone) {
				g.showErrorDialog(Localize.t("Artifacts can only be changed inside the safe zones."));
				return;
			}
			if(recycleMode) {
				g.showErrorDialog(Localize.t("Artifact setup can\'t be changed while recycling."));
				return;
			}
			var _local6:ToggleButton = e.target as ToggleButton;
			for each(var _local2 in setups) {
				if(_local2 != _local6) {
					_local2.isSelected = false;
				}
			}
			var _local4:int = int(setups.indexOf(_local6));
			if(_local4 == p.activeArtifactSetup) {
				_local6.isSelected = false;
				return;
			}
			if(recycleMode) {
				toggleRecycle();
			}
			g.send("changeArtifactSetup",_local4);
			p.changeArtifactSetup(_local4);
			for each(var _local5 in activeSlots) {
				_local5.setEmpty();
			}
			setActiveArtifacts();
			for each(var _local3 in cargoBoxes) {
				_local3.updateSetupChange();
			}
			reloadStats();
		}
		
		private function onSetupBuy(e:Event) : void {
			var button:ToggleButton;
			var cost:int = CreditManager.getCostArtifactSetup();
			var creditBuyBox:CreditBuyBox = new CreditBuyBox(g,cost,Localize.t("Unlocks one more artifact setup."));
			g.addChildToOverlay(creditBuyBox);
			creditBuyBox.addEventListener("accept",function(param1:Event):void {
				g.removeChildFromOverlay(creditBuyBox,true);
				g.rpc("buyArtifactSetup",onSetupBuyConfirm);
			});
			creditBuyBox.addEventListener("close",function(param1:Event):void {
				g.removeChildFromOverlay(creditBuyBox,true);
			});
			button = e.target as ToggleButton;
			button.isSelected = true;
		}
		
		private function onSetupBuyConfirm(m:Message) : void {
			var _local2:Boolean = m.getBoolean(0);
			if(!_local2) {
				g.showErrorDialog(m.getString(1));
				return;
			}
			g.showErrorDialog(Localize.t("Success!"));
			p.artifactSetups.push([]);
			g.creditManager.refresh();
			drawArtifactSetups();
		}
		
		private function reloadStats(e:Event = null) : void {
			reloadArtifactStats();
			reloadShipStats();
		}
		
		private function reloadArtifactStats() : void {
			if(p.artifacts.length == 0) {
				statisticSummary.text = Localize.t("You do not have any artifacts.");
				return;
			}
			if(p.activeArtifacts.length == 0) {
				statisticSummary.text = "";
				return;
			}
			var _local1:Object = sortStatsForSummary();
			addStatsToSummary(_local1);
		}
		
		private function sortStatsForSummary() : Object {
			var _local2:Artifact = null;
			var _local5:String = null;
			var _local1:Object = {};
			for each(var _local4 in p.activeArtifacts) {
				_local2 = p.getArtifactById(_local4);
				if(_local2 != null) {
					for each(var _local3 in _local2.stats) {
						_local5 = _local3.type;
						if(_local5.indexOf("2") != -1 || _local5.indexOf("3") != -1) {
							_local5 = _local5.slice(0,_local5.length - 1);
						}
						if(_local5 == "allResist") {
							if(!_local1.hasOwnProperty("kineticResist")) {
								_local1["kineticResist"] = 0;
							}
							if(!_local1.hasOwnProperty("energyResist")) {
								_local1["energyResist"] = 0;
							}
							if(!_local1.hasOwnProperty("corrosiveResist")) {
								_local1["corrosiveResist"] = 0;
							}
							var _local6:* = "kineticResist";
							var _local7:* = _local1[_local6] + _local3.value;
							_local1[_local6] = _local7;
							_local1["energyResist"] += _local3.value;
							_local1["corrosiveResist"] += _local3.value;
						} else if(_local5 == "allAdd") {
							if(!_local1.hasOwnProperty("kineticAdd")) {
								_local1["kineticAdd"] = 0;
							}
							if(!_local1.hasOwnProperty("energyAdd")) {
								_local1["energyAdd"] = 0;
							}
							if(!_local1.hasOwnProperty("corrosiveAdd")) {
								_local1["corrosiveAdd"] = 0;
							}
							_local7 = "kineticAdd";
							_local6 = _local1[_local7] + _local3.value * 4;
							_local1[_local7] = _local6;
							_local1["energyAdd"] += _local3.value * 4;
							_local1["corrosiveAdd"] += _local3.value * 4;
						} else if(_local5 == "allMulti") {
							if(!_local1.hasOwnProperty("kineticMulti")) {
								_local1["kineticMulti"] = 0;
							}
							if(!_local1.hasOwnProperty("energyMulti")) {
								_local1["energyMulti"] = 0;
							}
							if(!_local1.hasOwnProperty("corrosiveMulti")) {
								_local1["corrosiveMulti"] = 0;
							}
							_local6 = "kineticMulti";
							_local7 = _local1[_local6] + _local3.value * 1;
							_local1[_local6] = _local7;
							_local1["energyMulti"] += _local3.value * 1;
							_local1["corrosiveMulti"] += _local3.value * 1;
						} else {
							if(!_local1.hasOwnProperty(_local5)) {
								_local1[_local5] = 0;
							}
							_local7 = _local5;
							_local6 = _local1[_local7] + _local3.value;
							_local1[_local7] = _local6;
						}
					}
				}
			}
			return _local1;
		}
		
		private function addStatsToSummary(dataValues:Object) : void {
			var _local10:Number = NaN;
			var _local11:String = "";
			var _local7:String = "";
			var _local2:String = "";
			var _local4:String = "";
			var _local3:String = "";
			var _local6:String = "";
			var _local9:String = "";
			var _local8:String = "";
			for(var _local5 in dataValues) {
				switch(_local5) {
					case "corrosiveResist":
					case "energyResist":
					case "kineticResist":
						_local10 = Number(dataValues[_local5]);
						_local11 += ArtifactStat.parseTextFromStatType(_local5,_local10);
						if(_local10 > 75) {
							_local11 += " <FONT COLOR=\'#FFCCAA\'>(75% Max)</FONT>";
						}
						_local11 += "<br>";
						break;
					case "healthMulti":
					case "healthAdd":
					case "healthAdd3":
					case "healthAdd2":
					case "healthRegenAdd":
						_local7 += ArtifactStat.parseTextFromStatType(_local5,dataValues[_local5]) + "<br>";
						break;
					case "shieldMulti":
					case "shieldAdd":
					case "shieldAdd3":
					case "shieldAdd2":
					case "shieldRegen":
						_local2 += ArtifactStat.parseTextFromStatType(_local5,dataValues[_local5]) + "<br>";
						break;
					case "corrosiveMulti":
					case "corrosiveAdd":
					case "corrosiveAdd3":
					case "corrosiveAdd2":
						_local4 += ArtifactStat.parseTextFromStatType(_local5,dataValues[_local5]) + "<br>";
						break;
					case "kineticMulti":
					case "kineticAdd":
					case "kineticAdd3":
					case "kineticAdd2":
						_local6 += ArtifactStat.parseTextFromStatType(_local5,dataValues[_local5]) + "<br>";
						break;
					case "energyMulti":
					case "energyAdd":
					case "energyAdd3":
					case "energyAdd2":
						_local3 += ArtifactStat.parseTextFromStatType(_local5,dataValues[_local5]) + "<br>";
						break;
					default:
						if(ArtifactStat.isUnique(_local5)) {
							_local8 += ArtifactStat.parseTextFromStatType(_local5,dataValues[_local5],ArtifactStat.isUnique(_local5)) + "<br>";
						} else {
							_local9 += ArtifactStat.parseTextFromStatType(_local5,dataValues[_local5]) + "<br>";
						}
				}
				statisticSummary.text = "";
				if(_local11 != "") {
					statisticSummary.text += _local11;
				}
				if(_local2 != "") {
					statisticSummary.text += _local2;
				}
				if(_local7 != "") {
					statisticSummary.text += _local7;
				}
				if(_local9 != "") {
					statisticSummary.text += _local9;
				}
				if(_local6 != "") {
					statisticSummary.text += _local6;
				}
				if(_local3 != "") {
					statisticSummary.text += _local3;
				}
				if(_local4 != "") {
					statisticSummary.text += _local4;
				}
				if(_local8 != "") {
					statisticSummary.text += _local8;
				}
			}
		}
		
		private function reloadShipStats() : void {
		}
		
		private function chooseSorting(e:TouchEvent = null) : void {
			var _local2:ArtifactSorting = new ArtifactSorting(g,onSort);
			_local2.x = 0;
			_local2.y = 0;
			addChild(_local2);
		}
		
		private function toggleRecycle(e:TouchEvent = null) : void {
			recycleMode = !recycleMode;
			toggleRecycleButton.visible = !toggleRecycleButton.visible;
			cancelRecycleButton.visible = !cancelRecycleButton.visible;
			selectAllRecycleButton.visible = !selectAllRecycleButton.visible;
			recycleButton.visible = !recycleButton.visible;
			chooseSortingButton.visible = !chooseSortingButton.visible;
			toggleRecycleButton.enabled = toggleRecycleButton.visible;
			cancelRecycleButton.enabled = cancelRecycleButton.visible;
			recycleButton.enabled = recycleButton.visible;
			toggleUpgradeButton.visible = !toggleUpgradeButton.visible;
			statsContainer.visible = !statsContainer.visible;
			recycleText.visible = !recycleText.visible;
			recycleTextInfo.visible = !recycleTextInfo.visible;
			autoRecycleText.visible = !autoRecycleText.visible;
			autoRecycleTextInfo.visible = !autoRecycleTextInfo.visible;
			autoRecycleButton.visible = !autoRecycleButton.visible;
			autoRecycleInput.visible = !autoRecycleInput.visible;
			buySupporter.visible = !buySupporter.visible && !g.me.hasSupporter();
			markedForRecycle.splice(0,markedForRecycle.length);
			for each(var _local2 in cargoBoxes) {
				if(recycleMode) {
					_local2.setRecycleState();
				} else {
					_local2.removeRecycleState();
				}
			}
		}
		
		private function toggleUpgrade(e:TouchEvent = null) : void {
			upgradeMode = !upgradeMode;
			toggleRecycleButton.visible = !toggleRecycleButton.visible;
			chooseSortingButton.visible = !chooseSortingButton.visible;
			toggleUpgradeButton.visible = !toggleUpgradeButton.visible;
			cancelUpgradeButton.visible = !cancelUpgradeButton.visible;
			upgradeButton.visible = !upgradeButton.visible;
			toggleUpgradeButton.enabled = toggleUpgradeButton.visible;
			cancelUpgradeButton.enabled = cancelUpgradeButton.visible;
			crewContainer.visible = !crewContainer.visible;
			upgradeButton.enabled = false;
			statsContainer.visible = !statsContainer.visible;
			for each(var _local2 in cargoBoxes) {
				if(upgradeMode) {
					_local2.setUpgradeState();
				} else {
					_local2.removeUpgradeState();
				}
			}
			if(selectedCrewMember != null) {
				selectedCrewMember.setSelected(false);
				selectedCrewMember = null;
			}
			if(selectedUpgradeBox != null) {
				selectedUpgradeBox.setNotSelected();
				selectedUpgradeBox = null;
			}
			g.tutorial.showArtifactUpgradeAdvice();
		}
		
		private function selectAllForRecycle(e:TouchEvent = null) : void {
			var _local3:int = 0;
			markedForRecycle.splice(0,markedForRecycle.length);
			for each(var _local2 in cargoBoxes) {
				if(_local2.a != null) {
					if(!_local2.isUsedInSetup()) {
						if(!_local2.a.upgrading) {
							if(!_local2.a.upgrading) {
								if(_local2.a.upgraded <= 0) {
									if(!_local2.a.isUnique) {
										if(_local3 == 40) {
											break;
										}
										_local2.setSelectedForRecycle();
										markedForRecycle.push(_local2.a);
										_local3++;
									}
								}
							}
						}
					}
				}
			}
			cargoContainer.scrollToPosition(0,0);
			selectAllRecycleButton.enabled = true;
		}
		
		private function onSort(type:String) : void {
			chooseSortingButton.enabled = true;
			Artifact.currentTypeOrder = type;
			if(type == "levelhigh") {
				p.artifacts.sort(Artifact.orderLevelHigh);
			} else if(type == "levellow") {
				p.artifacts.sort(Artifact.orderLevelLow);
			} else if(type == "statcountasc") {
				p.artifacts.sort(Artifact.orderStatCountAsc);
			} else if(type == "statcountdesc") {
				p.artifacts.sort(Artifact.orderStatCountDesc);
			} else {
				p.artifacts.sort(Artifact.orderStat);
			}
			cargoContainer.removeChildren(0,-1,true);
			cargoBoxes.length = 0;
			drawArtifactsInCargo();
		}
		
		private function onRecycle(e:TouchEvent) : void {
			if(markedForRecycle.length == 0) {
				recycleButton.enabled = true;
				return;
			}
			if(g.myCargo.isFull) {
				g.showErrorDialog(Localize.t("Your cargo compressor is overloaded!"));
				return;
			}
			var _local3:Message = g.createMessage("bulkRecycle");
			for each(var _local2 in markedForRecycle) {
				_local3.add(_local2.id);
			}
			g.rpcMessage(_local3,onRecycleMessage);
			g.showModalLoadingScreen("Recycling, please wait... \n\n <font size=\'12\'>This might take a couple of minutes</font>");
		}
		
		private function onRecycleMessage(m:Message) : void {
			var success:Boolean;
			var j:int;
			var i:int;
			var reason:String;
			var a:Artifact;
			var cargoBox:ArtifactCargoBox;
			var recycleBox:LootPopupMessage;
			var junk:String;
			var amount:int;
			var lootItem:LootItem;
			g.hideModalLoadingScreen();
			success = m.getBoolean(0);
			j = 0;
			if(!success) {
				reason = m.getString(1);
				g.showErrorDialog("Recycle failed, " + reason);
				return;
			}
			i = 0;
			while(i < markedForRecycle.length) {
				a = markedForRecycle[i];
				p.artifactCount -= 1;
				for each(cargoBox in cargoBoxes) {
					if(cargoBox.a == a) {
						cargoBox.setEmpty();
						break;
					}
				}
				j = 0;
				while(j < p.artifacts.length) {
					if(a == p.artifacts[j]) {
						p.artifacts.splice(j,1);
						break;
					}
					j++;
				}
				i++;
			}
			if(p.artifactCount < p.artifactLimit) {
				g.hud.hideArtifactLimitText();
			}
			recycleBox = new LootPopupMessage();
			g.addChildToOverlay(recycleBox,true);
			i = 1;
			j = 0;
			while(i < m.length) {
				junk = m.getString(i);
				amount = m.getInt(i + 1);
				g.myCargo.addItem("Commodities",junk,amount);
				lootItem = new LootItem("Commodities",junk,amount);
				lootItem.y = j * 40;
				recycleBox.addItem(lootItem);
				i += 2;
				j++;
			}
			recycleBox.addEventListener("close",function(param1:Event):void {
				g.removeChildFromOverlay(recycleBox,true);
				toggleRecycle();
			});
			markedForRecycle.splice(0,markedForRecycle.length);
		}
		
		private function onActiveRemoved(e:Event) : void {
			var _local4:ArtifactBox = e.target as ArtifactBox;
			var _local2:Artifact = _local4.a;
			if(!g.me.isLanded && !g.me.inSafeZone) {
				g.showErrorDialog(Localize.t("Artifacts can only be changed inside the safe zones."));
				return;
			}
			_local4.setEmpty();
			p.toggleArtifact(_local2);
			reloadStats();
			if(selectedUpgradeBox != null && selectedUpgradeBox.a == _local4.a) {
				return;
			}
			for each(var _local3 in cargoBoxes) {
				if(_local3.a == _local2) {
					_local3.stateNormal();
					break;
				}
			}
		}
		
		private function onCrewSelected(e:Event) : void {
			selectedCrewMember = e.target as CrewDisplayBoxNew;
			if(selectedUpgradeBox != null) {
				upgradeButton.enabled = true;
			}
		}
		
		private function onUpgradeArtifact(e:Event) : void {
			var _local2:Artifact = selectedUpgradeBox.a;
			var _local4:Number = _local2.level;
			var _local5:Number = _local2.level - 50;
			var _local6:Number = _local2.level - 75;
			if(_local4 > 50) {
				_local4 = 50;
			}
			if(_local5 > 25) {
				_local5 = 25;
			}
			if(_local5 < 0) {
				_local5 = 0;
			}
			if(_local6 < 0) {
				_local6 = 0;
			}
			var _local3:Number = 5 * Math.pow(1.075,_local4) * Math.pow(1.05,_local5) * (1 + 0.02 * _local6) * (60) * 1000;
			if(_local3 > 500 * 24 * 60 * 60) {
				_local3 = 43200000;
			}
			g.showConfirmDialog(Localize.t("The upgrade will be finished in") + ": \n\n<font color=\'#ffaa88\'>" + Util.getFormattedTime(_local3) + "</font>",confirmUpgrade);
			upgradeButton.enabled = true;
		}
		
		private function confirmUpgrade() : void {
			if(selectedUpgradeBox == null) {
				selectedCrewMember = null;
				upgradeButton.enabled = false;
				g.showErrorDialog("Something went wrong, please try again. No resources or flux were taken from your account",true);
				return;
			}
			g.showModalLoadingScreen("Starting upgrade...");
			selectedUpgradeBox.setNotSelected();
			selectedUpgradeBox.touchable = false;
			selectedCrewMember.touchable = false;
			var _local1:Message = g.createMessage("startUpgradeArtifact");
			_local1.add(selectedUpgradeBox.a.id,selectedCrewMember.key);
			g.rpcMessage(_local1,startedUpgrade);
			upgradeButton.enabled = false;
		}
		
		private function startedUpgrade(m:Message) : void {
			var _local2:CrewMember = null;
			if(m.getBoolean(0)) {
				selectedUpgradeBox.a.upgrading = true;
				selectedUpgradeBox.update();
				_local2 = selectedCrewMember.crewMember;
				_local2.artifact = selectedUpgradeBox.a.id;
				_local2.artifactEnd = m.getNumber(1);
				selectedCrewMember.setSelected(false);
				Game.trackEvent("actions","started artifact upgrade",p.level.toString(),CreditManager.getCostArtifactUpgrade(g,_local2.artifactEnd));
			} else if(m.length > 1) {
				g.showErrorDialog(m.getString(1));
			}
			selectedUpgradeBox.touchable = true;
			selectedCrewMember.touchable = true;
			selectedCrewMember = null;
			selectedUpgradeBox = null;
			g.hideModalLoadingScreen();
		}
		
		private function onUpgradeArtifactComplete(e:Event = null) : void {
			var _local2:CrewDisplayBoxNew = e.target as CrewDisplayBoxNew;
			sendArtifactComplete(_local2.crewMember);
		}
		
		private function onLoadUpgradeArtifactComplete(crewMembersThatCompletedUpgrade:Vector.<CrewMember>, i:int = 0) : void {
			if(i >= crewMembersThatCompletedUpgrade.length) {
				return;
			}
			sendArtifactComplete(crewMembersThatCompletedUpgrade[i],function():void {
				onLoadUpgradeArtifactComplete(crewMembersThatCompletedUpgrade,i + 1);
			});
		}
		
		private function sendArtifactComplete(crewMember:CrewMember, finishedCallback:Function = null) : void {
			var artifactKey:String = crewMember.artifact;
			var crewKey:String = crewMember.key;
			var m:Message = g.createMessage("completeUpgradeArtifact");
			m.add(artifactKey,crewKey);
			g.showModalLoadingScreen("Waiting for result...");
			g.rpcMessage(m,function(param1:Message):void {
				g.hideModalLoadingScreen();
				artifactUpgradeComplete(param1,finishedCallback);
			});
		}
		
		private function artifactUpgradeComplete(m:Message, finishedCallback:Function = null) : void {
			var soundManager:ISound;
			if(m.getBoolean(0)) {
				soundManager = SoundLocator.getService();
				soundManager.play("7zeIcPFb-UWzgtR_3nrZ8Q",null,function():void {
					var isActive:Boolean;
					var newLevel:int;
					var diffLevel:int;
					var container:Sprite;
					var overlay:Quad;
					var artBox:ArtifactBox;
					var box:Box;
					var upgradeText:TextBitmap;
					var crewSkillText:TextBitmap;
					var levelText:TextBitmap;
					var hh:Number;
					var i:int;
					var statText:TextField;
					var stat:ArtifactStat;
					var newValue:Number;
					var diff:Number;
					var closeButton:Button;
					var acBox:ArtifactCargoBox;
					var aBox:ArtifactBox;
					var cm:CrewMember = p.getCrewMember(m.getString(1));
					var newSkillPoints:int = m.getInt(2);
					var a:Artifact = p.getArtifactById(m.getString(3));
					cm.skillPoints += newSkillPoints;
					isActive = p.isActiveArtifact(a);
					if(isActive) {
						p.toggleArtifact(a,false);
					}
					newLevel = m.getInt(4);
					diffLevel = newLevel - a.level;
					diffLevel = int(diffLevel <= 0 ? 1 : diffLevel);
					a.level = newLevel;
					a.upgraded += 1;
					a.upgrading = false;
					container = new Sprite();
					g.addChildToOverlay(container);
					overlay = new Quad(g.stage.stageWidth,g.stage.stageHeight,0);
					overlay.alpha = 0.4;
					container.addChild(overlay);
					artBox = new ArtifactBox(g,a);
					artBox.update();
					box = new Box(3 * 60,80 + a.stats.length * 25 + artBox.height + 60,"highlight");
					box.x = g.stage.stageWidth / 2 - box.width / 2;
					box.y = g.stage.stageHeight / 2 - box.height / 2;
					container.addChild(box);
					artBox.x = box.width / 2 - artBox.width / 2 - 20;
					box.addChild(artBox);
					upgradeText = new TextBitmap();
					upgradeText.format.color = 0xaaaaaa;
					upgradeText.y = artBox.height + 20;
					upgradeText.text = Localize.t("Upgrade Result");
					upgradeText.x = 90;
					upgradeText.center();
					box.addChild(upgradeText);
					crewSkillText = new TextBitmap();
					crewSkillText.format.color = 0xffffff;
					crewSkillText.text = Localize.t("Crew Skill") + " +" + newSkillPoints;
					crewSkillText.size = 14;
					crewSkillText.x = 90;
					crewSkillText.y = upgradeText.y + upgradeText.height + 10;
					crewSkillText.center();
					box.addChild(crewSkillText);
					levelText = new TextBitmap();
					levelText.format.color = 0xffffff;
					levelText.text = Localize.t("strength") + " +" + diffLevel;
					levelText.size = 18;
					levelText.x = 90;
					levelText.y = crewSkillText.y + crewSkillText.height + 10;
					levelText.center();
					levelText.visible = false;
					box.addChild(levelText);
					TweenMax.delayedCall(1,function():void {
						soundManager.play("F3RA7-UJ6EKLT6WeJyKq-w");
						levelText.visible = true;
						TweenMax.from(levelText,1,{
							"scaleX":2,
							"scaleY":2,
							"alpha":0
						});
					});
					hh = levelText.y + levelText.height + 10;
					i = 0;
					while(i < a.stats.length) {
						statText = new TextField(box.width,16,"",new TextFormat("DAIDRR",13,a.getColor()));
						stat = a.stats[i];
						newValue = m.getNumber(5 + i);
						diff = newValue - stat.value;
						stat.value = newValue;
						statText.text = ArtifactStat.parseTextFromStatType(stat.type,diff,stat.isUnique);
						statText.isHtmlText = true;
						statText.x = -20;
						statText.y = i * 25 + hh;
						box.addChild(statText);
						TweenMax.from(statText,1,{
							"scaleX":0.5,
							"scaleY":0.5,
							"alpha":0
						});
						i++;
					}
					closeButton = new Button(function():void {
						g.removeChildFromOverlay(container,true);
						if(finishedCallback != null) {
							finishedCallback();
						}
					},Localize.t("close"));
					closeButton.x = 90 - closeButton.width / 2;
					closeButton.y = box.height - 60;
					box.addChild(closeButton);
					cm.artifact = "";
					cm.artifactEnd = 0;
					if(isActive) {
						p.toggleArtifact(a,false);
					}
					for each(acBox in cargoBoxes) {
						if(acBox.a == a) {
							acBox.showHint();
						}
						acBox.setNotSelected();
					}
					for each(aBox in activeSlots) {
						if(aBox.a == a) {
							aBox.update();
						}
					}
					reloadStats();
				});
			} else {
				if(m.length > 1) {
					g.showErrorDialog(m.getString(1));
				}
				if(finishedCallback != null) {
					finishedCallback();
				}
			}
			selectedUpgradeBox = null;
		}
	}
}

