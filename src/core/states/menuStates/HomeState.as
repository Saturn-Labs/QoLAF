package core.states.menuStates
{
	import com.greensock.TweenMax;
	import core.clan.PlayerClanLogo;
	import core.credits.CreditManager;
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.hud.components.dialogs.PopupInputMessage;
	import core.hud.components.shipMenu.ArtifactSelector;
	import core.hud.components.shipMenu.CrewSelector;
	import core.hud.components.shipMenu.WeaponSelector;
	import core.player.FleetObj;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.ShipFactory;
	import core.states.DisplayState;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Localize;
	import generics.Util;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;

	public class HomeState extends DisplayState
	{
		private const COLUMN_WIDTH:int = 280;

		private var dataManager:IDataManager;
		private var infoContainer:Box;
		private var shipContainer:Box;
		private var weaponsContainer:Box;
		private var artifactsContainer:Box;
		private var crewContainer:Box;
		private var p:Player;
		private var shipImage:MovieClip;
		public function HomeState(param1:Game, param2:Player)
		{
			super(param1, HomeState);
			this.p = param2;
			dataManager = DataLocator.getService();
		}

		private static function addStat(param1:int, param2:int, param3:String, param4:String, param5:Sprite):int
		{
			var _loc7_:TextBitmap = new TextBitmap(param1, param2, param3);
			_loc7_.format.color = 6710886;
			param5.addChild(_loc7_);
			var _loc6_:TextBitmap = new TextBitmap(param1, _loc7_.y + _loc7_.height, param4);
			param5.addChild(_loc6_);
			return _loc7_.x + _loc7_.width;
		}

		override public function enter():void
		{
			var weaponsLabel:TextBitmap;
			var weaponSelector:WeaponSelector;
			var upgradeButton:Button;
			var artifactLabel:TextBitmap;
			var artifactsButton:Button;
			var artifactSelector:ArtifactSelector;
			var crewLabel:TextBitmap;
			var crewButton:Button;
			var crewSelector:CrewSelector;
			super.enter();
			loadShipInfo();
			loadPlayerInfo();
			weaponsContainer = new Box(280, 70, "light", 0.5, 20);
			weaponsContainer.x = shipContainer.x;
			weaponsContainer.y = shipContainer.y + shipContainer.height + 20;
			addChild(weaponsContainer);
			weaponsLabel = new TextBitmap(0, -3, Localize.t("Weapons"));
			weaponsLabel.format.color = 16689475;
			weaponsContainer.addChild(weaponsLabel);
			weaponSelector = new WeaponSelector(g, p);
			weaponSelector.y = weaponsLabel.y + weaponsLabel.height + 15;
			weaponSelector.addEventListener("changeWeapon", function(param1:Event):void
				{
					sm.changeState(new ChangeWeaponState(g, p, param1.data as int));
				});
			weaponsContainer.addChild(weaponSelector);
			upgradeButton = new Button(function():void
				{
					sm.changeState(new UpgradesState(g, p));
				}, Localize.t("Upgrades").toLowerCase());
			upgradeButton.x = 280 + 10 - upgradeButton.width;
			upgradeButton.y = -10;
			weaponsContainer.addChild(upgradeButton);
			artifactsContainer = new Box(280, 70, "light", 0.5, 20);
			artifactsContainer.x = shipContainer.x;
			artifactsContainer.y = weaponsContainer.y + 130;
			addChild(artifactsContainer);
			artifactLabel = new TextBitmap(0, -3, Localize.t("Artifacts"));
			artifactLabel.format.color = 16689475;
			artifactsContainer.addChild(artifactLabel);
			artifactsButton = new Button(function():void
				{
					sm.changeState(new ArtifactState2(g, p));
				}, Localize.t("Artifacts").toLowerCase());
			artifactsButton.x = 280 + 10 - artifactsButton.width;
			artifactsButton.y = -10;
			artifactsContainer.addChild(artifactsButton);
			artifactSelector = new ArtifactSelector(g, p);
			artifactSelector.y = artifactLabel.y + artifactLabel.height + 15;
			artifactSelector.addEventListener("artifactSelected", function(param1:Event):void
				{
					sm.changeState(new ArtifactState2(g, p));
				});
			artifactsContainer.addChild(artifactSelector);
			crewContainer = new Box(280, 70, "light", 0.5, 20);
			crewContainer.x = infoContainer.x;
			crewContainer.y = infoContainer.y + infoContainer.height + 20;
			addChild(crewContainer);
			crewLabel = new TextBitmap(0, -3, Localize.t("Crew"));
			crewLabel.format.color = 16689475;
			crewContainer.addChild(crewLabel);
			crewButton = new Button(function():void
				{
					sm.changeState(new CrewStateNew(g));
				}, Localize.t("Manage").toLowerCase());
			crewButton.x = 280 + 10 - crewButton.width;
			crewButton.y = -5;
			crewContainer.addChild(crewButton);
			crewSelector = new CrewSelector(g, p);
			crewSelector.y = crewLabel.y + crewLabel.height + 15;
			crewSelector.addEventListener("crewSelected", function(param1:Event):void
				{
					sm.changeState(new CrewStateNew(g));
				});
			crewContainer.addChild(crewSelector);
		}

		private function loadShipInfo():void
		{
			shipContainer = new Box(280, 164, "light", 0.5, 20);
			shipContainer.x = 70;
			shipContainer.y = 70;
			addChild(shipContainer);
			var _loc1_:Sprite = new Sprite();
			_loc1_.width = shipContainer.width;
			_loc1_.height = shipContainer.height;
			shipContainer.addChild(_loc1_);
			addStat(0, 55, Localize.t("health"), p.ship.hpMax.toString(), _loc1_);
			addStat(70, 55, Localize.t("armor"), p.ship.armorThreshold.toString(), _loc1_);
			addStat(140, 55, Localize.t("shield"), p.ship.shieldHpMax.toString(), _loc1_);
			addStat(0, 104, Localize.t("health regen"), p.ship.hpRegen.toString(), _loc1_);
			addStat(140, 104, Localize.t("shield regen"), (1.75 * (p.ship.shieldRegen + p.ship.shieldRegenBonus)).toFixed(0), _loc1_);
			drawShip();
		}

		private function loadPlayerInfo():void
		{
			infoContainer = new Box(280, 190, "light", 0.5, 20);
			infoContainer.x = 410;
			infoContainer.y = 70;
			addChild(infoContainer);
			var _loc14_:PlayerClanLogo = new PlayerClanLogo(g, g.me);
			_loc14_.x = 334;
			_loc14_.y = 60;
			addChild(_loc14_);
			var _loc2_:Image = new Image(textureManager.getTextureGUIByTextureName("clan_logo3.png"));
			_loc2_.y = 21;
			_loc2_.color = 16711680;
			_loc2_.x = 0;
			_loc2_.scaleX = _loc2_.scaleY = 0.25;
			_loc2_.rotation = -0.5 * 3.141592653589793;
			infoContainer.addChild(_loc2_);
			var _loc12_:TextBitmap = new TextBitmap();
			_loc12_.text = Util.formatAmount(g.me.rating);
			_loc12_.x = _loc2_.x + _loc2_.width + 10;
			_loc12_.y = 0;
			_loc12_.size = 13;
			_loc12_.format.color = 15985920;
			infoContainer.addChild(_loc12_);
			var _loc8_:TextBitmap = new TextBitmap(50, 12, "Rank " + g.me.ranking.toString(), 13);
			_loc8_.format.color = 16777215;
			_loc8_.x = _loc2_.x;
			_loc8_.y = _loc12_.y + 24;
			infoContainer.addChild(_loc8_);
			var _loc3_:Image = new Image(textureManager.getTextureGUIByTextureName("troon.png"));
			_loc3_.x = _loc2_.x + 100;
			_loc3_.y = 0;
			infoContainer.addChild(_loc3_);
			var _loc6_:String = Localize.t("Troons give bonus stats to your ship if its above <FONT COLOR='#FFFFFF'>200 000</FONT>.");
			new ToolTip(g, _loc3_, _loc6_, null, "HomeState");
			var _loc4_:TextBitmap = new TextBitmap(280, 0, p.troons.toString());
			_loc4_.x = _loc3_.x + _loc3_.width + 5;
			infoContainer.addChild(_loc4_);
			var _loc9_:TextBitmap = new TextBitmap(280, 0, p.level.toString(), 40);
			_loc9_.alignRight();
			infoContainer.addChild(_loc9_);
			var _loc5_:TextBitmap = new TextBitmap(280 - _loc9_.width, 22, "level ");
			_loc5_.format.color = 6710886;
			_loc5_.alignRight();
			infoContainer.addChild(_loc5_);
			var _loc13_:Number = 0;
			var _loc10_:Number = 0;
			var _loc15_:IDataManager = DataLocator.getService();
			var _loc11_:Object = _loc15_.loadTable("BodyAreas");
			for (var _loc7_:* in _loc11_)
			{
				if (g.me.hasExploredArea(_loc7_))
				{
					_loc13_++;
				}
				_loc10_++;
			}
			var _loc1_:Number = _loc13_ / _loc10_ * 100;
			addStat(0, 55, Localize.t("explored"), _loc1_.toFixed(2) + "%", infoContainer);
			addStat(165, 55, Localize.t("experience"), p.xp + "/" + p.levelXpMax, infoContainer);
			addStat(0, 104, Localize.t("enemy kills"), p.enemyKills.toString(), infoContainer);
			addStat(165, 104, Localize.t("player kills"), p.playerKills.toString(), infoContainer);
			addStat(0, 153, Localize.t("solarsystem"), g.solarSystem.name, infoContainer);
			addStat(165, 153, Localize.t("galaxy"), g.solarSystem.galaxy, infoContainer);
		}

		override public function get type():String
		{
			return "HomeState";
		}

		private function drawShip():void
		{
			var xx:int;
			var supporterImage:Image;
			var playerName:TextBitmap;
			var skin:Object = dataManager.loadKey("Skins", p.activeSkin);
			var fleetObj:FleetObj = p.getActiveFleetObj();
			var ship:Object = dataManager.loadKey("Ships", skin.ship);
			var obj2:Object = dataManager.loadKey("Images", ship.bitmap);
			shipImage = new MovieClip(textureManager.getTexturesMainByTextureName(obj2.textureName));
			shipImage.readjustSize();
			shipImage.pivotX = shipImage.width / 2;
			shipImage.pivotY = shipImage.height / 2;
			shipImage.y = 0;
			shipImage.x = shipImage.width / 2;
			shipContainer.addChild(shipImage);
			shipImage.filter = ShipFactory.createPlayerShipColorMatrixFilter(fleetObj);
			xx = 15;
			if (g.me.hasSupporter())
			{
				supporterImage = new Image(textureManager.getTextureGUIByTextureName("icon_supporter.png"));
				supporterImage.x = shipImage.x + shipImage.width + 5;
				supporterImage.y = Math.round(shipImage.height / 2) - supporterImage.height / 2;
				shipContainer.addChild(supporterImage);
				xx = 20;
			}
			playerName = new TextBitmap(shipImage.x + shipImage.width + xx, Math.round(shipImage.y) - 10, p.name, 22);
			playerName.useHandCursor = true;
			new ToolTip(g, playerName, Localize.t("Click to change name."), null, "HomeState");
			playerName.addEventListener("touch", function(param1:TouchEvent):void
				{
					var popup:PopupInputMessage;
					var e:TouchEvent = param1;
					if (e.getTouch(playerName, "ended"))
					{
						popup = new PopupInputMessage(Localize.t("Change Name for [flux] Flux").replace("[flux]", CreditManager.getCostChangeName(p.name)));
						popup.input.restrict = "a-zA-Z0-9\\-_";
						popup.input.maxChars = 15;
						popup.addEventListener("accept", function(param1:Event):void
							{
								var e:Event = param1;
								g.creditManager.refresh(function():void
									{
										var confirmBuyWithFlux:CreditBuyBox = new CreditBuyBox(g, CreditManager.getCostChangeName(p.name), Localize.t("Are you sure you want to change name?"));
										g.addChildToOverlay(confirmBuyWithFlux);
										confirmBuyWithFlux.addEventListener("accept", function(param1:Event):void
											{
												var e:Event = param1;
												g.rpc("changeName", function(param1:Message):void
													{
														if (param1.getBoolean(0))
														{
															p.name = popup.text;
															playerName.text = p.name;
															TweenMax.fromTo(playerName, 1, {
																		"scaleX": 2,
																		"scaleY": 2
																	}, {
																		"scaleX": 1,
																		"scaleY": 1
																	});
															SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
															g.creditManager.refresh();
														}
														else
														{
															g.showErrorDialog(param1.getString(1), false);
														}
													}, popup.text);
												confirmBuyWithFlux.removeEventListeners();
											});
										confirmBuyWithFlux.addEventListener("close", function(param1:Event):void
											{
												confirmBuyWithFlux.removeEventListeners();
												g.removeChildFromOverlay(confirmBuyWithFlux, true);
											});
										popup.removeEventListeners();
										g.removeChildFromOverlay(popup);
									});
							});
						popup.addEventListener("close", function(param1:Event):void
							{
								popup.removeEventListeners();
								g.removeChildFromOverlay(popup);
							});
						g.addChildToOverlay(popup);
					}
				});
			shipContainer.addChild(playerName);
		}

		override public function exit():void
		{
			ToolTip.disposeType("HomeState");
			removeChild(infoContainer, true);
			removeChild(shipContainer, true);
			removeChild(weaponsContainer, true);
			removeChild(artifactsContainer, true);
			removeChild(crewContainer, true);
			super.exit();
		}
	}
}
