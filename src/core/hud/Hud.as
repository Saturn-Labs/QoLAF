package core.hud
{
	import com.greensock.TweenMax;
	import core.hud.components.BossHealth;
	import core.hud.components.Button;
	import core.hud.components.ButtonCargo;
	import core.hud.components.ButtonClan;
	import core.hud.components.ButtonHud;
	import core.hud.components.ButtonMissions;
	import core.hud.components.ButtonNewMission;
	import core.hud.components.ButtonPlayers;
	import core.hud.components.ButtonPvPMenu;
	import core.hud.components.ButtonPvPQuickMatch;
	import core.hud.components.BuyFluxButton;
	import core.hud.components.Experience;
	import core.hud.components.FullScreenButton;
	import core.hud.components.HealthAndShield;
	import core.hud.components.PodButton;
	import core.hud.components.PowerBar;
	import core.hud.components.PvPIcon;
	import core.hud.components.ResourceBox;
	import core.hud.components.ShopIcons;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.hud.components.UberStats;
	import core.hud.components.hotkeys.Abilities;
	import core.hud.components.hotkeys.WeaponHotkeys;
	import core.hud.components.radar.Compas;
	import core.hud.components.radar.Radar;
	import core.player.Mission;
	import core.player.Player;
	import core.scene.Game;
	import core.scene.SceneBase;
	import core.ship.PlayerShip;
	import core.states.gameStates.ClanState;
	import core.states.gameStates.LeaderBoardState2;
	import core.states.gameStates.MapState;
	import core.states.gameStates.MenuState;
	import core.states.gameStates.PlayerListState;
	import core.states.gameStates.PodState;
	import core.states.gameStates.PvpScreenState;
	import core.states.gameStates.RoamingState;
	import core.states.gameStates.SettingsState;
	import core.states.gameStates.ShopState;
	import core.states.gameStates.missions.Daily;
	import core.states.gameStates.missions.MissionsState;
	import core.states.menuStates.ArtifactState2;
	import core.states.menuStates.CargoState;
	import core.states.menuStates.EncounterState;
	import core.states.menuStates.HomeState;
	import data.KeyBinds;
	import generics.Localize;
	import playerio.Message;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MeshBatch;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Hud
	{
		private var g:Game;
		
		private var container:Sprite;
		
		private var shipButton:ButtonHud;
		
		private var mapButton:ButtonHud;
		
		public var cargoButton:ButtonCargo;
		
		public var resourceBox:ResourceBox;
		
		private var podButton:PodButton;
		
		private var settingsButton:ButtonHud;
		
		private var shopButton:Button;
		
		public var buyFluxButton:BuyFluxButton;
		
		public var clanButton:ButtonClan;
		
		private var newMissionsButton:ButtonNewMission;
		
		public var missionsButton:ButtonMissions;
		
		public var artifactsButton:ButtonHud;
		
		public var leaderboardButton:ButtonHud;
		
		public var encountersButton:ButtonHud;
		
		public var salesButton:Button;
		
		public var pvpMenuButton:ButtonPvPMenu;
		
		public var pvpQuickMatchButton:ButtonPvPQuickMatch;
		
		public var healthAndShield:HealthAndShield;
		
		public var powerBar:PowerBar;
		
		public var bossHealth:BossHealth;
		
		public var weaponHotkeys:WeaponHotkeys;
		
		public var radar:Radar;
		
		private var shopIcons:ShopIcons;
		
		private var pvpIcon:PvPIcon;
		
		private var textureManager:ITextureManager;
		
		public var abilities:Abilities;
		
		public var compas:Compas;
		
		public var playerListButton:ButtonPlayers;
		
		private var bgr:MeshBatch;
		
		private var experience:Experience;
		
		private var landText:TextBitmap;
		
		private var safeZoneText:TextBitmap;
		
		private var repairText:TextBitmap;
		
		private var hintMapText:TextBitmap;
		
		public var uberStats:UberStats;
		
		private var artifactLimitText:TextBitmap;
		
		private var loadComplete:Boolean = false;
		
		private var fullScreenButton:FullScreenButton;
		
		private var isShowingNewMissionsButton:Boolean = false;
		
		private var hintMapFlashCounter:int = 0;
		
		private var fullScreenHintImage:Image;
		
		private var artifactTween:TweenMax;
		
		private var showUtilityTexts:Boolean = true;
		
		public function Hud(param1:Game)
		{
			container = new Sprite();
			bgr = new MeshBatch();
			landText = new TextBitmap();
			safeZoneText = new TextBitmap();
			repairText = new TextBitmap();
			artifactLimitText = new TextBitmap();
			fullScreenButton = new FullScreenButton();
			super();
			this.g = param1;
			healthAndShield = new HealthAndShield(param1);
			powerBar = new PowerBar(param1);
			bossHealth = new BossHealth(param1);
			weaponHotkeys = new WeaponHotkeys(param1);
			radar = new Radar(param1);
			experience = new Experience(param1);
			abilities = new Abilities(param1);
			compas = new Compas(param1);
			shopIcons = new ShopIcons(param1);
			pvpIcon = new PvPIcon(param1);
			uberStats = new UberStats(param1);
			textureManager = TextureLocator.getService();
		}
		
		public function load():void
		{
			var keyBinds:KeyBinds;
			var message:Message;
			container.addChild(bgr);
			healthAndShield.load();
			powerBar.load();
			bossHealth.load();
			weaponHotkeys.load();
			radar.load();
			experience.load();
			shopIcons.load();
			pvpIcon.load();
			safeZoneText.format.color = 11184895;
			safeZoneText.size = 26;
			safeZoneText.text = Localize.t("Safe Zone (weapons disabled)");
			safeZoneText.visible = false;
			safeZoneText.blendMode = "add";
			safeZoneText.touchable = false;
			repairText.format.color = 11206570;
			repairText.size = 22;
			repairText.text = Localize.t("(Repairing Ship)");
			repairText.visible = false;
			repairText.blendMode = "add";
			repairText.touchable = false;
			repairText.batchable = true;
			keyBinds = SceneBase.settings.keybinds;
			landText.text = Localize.t("Press [key] to land on").replace("[key]", keyBinds.getKeyChar(10)) + " ";
			landText.size = 16;
			landText.format.color = 11206570;
			landText.x = 380 - landText.width / 2;
			landText.y = 150;
			landText.touchable = false;
			landText.blendMode = "add";
			landText.visible = false;
			artifactLimitText.text = Localize.t("Artifact Limit!");
			artifactLimitText.format.color = 16729156;
			artifactLimitText.x = 160;
			artifactLimitText.size = 18;
			artifactLimitText.y = g.stage.stageHeight - 60;
			artifactLimitText.touchable = false;
			artifactLimitText.batchable = true;
			artifactLimitText.blendMode = "add";
			artifactLimitText.visible = false;
			mapButton = new ButtonHud(function():void
			{
				if (g.gameStateMachine.inState(MapState))
				{
					g.enterState(new RoamingState(g));
				}
				else
				{
					g.enterState(new MapState(g));
				}
			}, "button_map.png");
			shipButton = new ButtonHud(function():void
			{
				g.enterState(new MenuState(g, HomeState));
			}, "button_ship.png");
			cargoButton = new ButtonCargo(g, function():void
			{
				g.enterState(new MenuState(g, CargoState));
			});
			podButton = new PodButton(function():void
			{
				g.enterState(new PodState(g));
			}, "--", "highlight", 17);
			podButton.autoEnableAfterClick = true;
			podButton.visible = !g.me.guest;
			message = g.createMessage("getPodCount");
			g.rpcMessage(message, function(param1:Message):void
			{
				updatePodCount(param1.getInt(0));
			});
			artifactsButton = new ButtonHud(function():void
			{
				g.enterState(new MenuState(g, ArtifactState2));
			}, "button_artifacts.png");
			buyFluxButton = new BuyFluxButton(g);
			buyFluxButton.visible = !g.me.guest;
			shopButton = new Button(function():void
			{
				g.enterState(new ShopState(g));
			}, Localize.t("Shop"), "buy");
			shopButton.autoEnableAfterClick = true;
			shopButton.visible = !g.me.guest;
			clanButton = new ButtonClan(function():void
			{
				g.enterState(new ClanState(g));
			}, g);
			clanButton.visible = !g.me.guest;
			newMissionsButton = new ButtonNewMission(function():void
			{
				if (g.me.isDeveloper || g.me.isModerator || g.me.id == "fb100002203869719")
				{
					g.enterState(new MissionsState(g));
				}
				else
				{
					g.enterState(new MissionsState(g));
				}
			}, g);
			missionsButton = new ButtonMissions(function():void
			{
				if (g.me.isDeveloper || g.me.isModerator || g.me.id == "fb100002203869719")
				{
					g.enterState(new MissionsState(g));
				}
				else
				{
					g.enterState(new MissionsState(g));
				}
			});
			abilities.load();
			settingsButton = new ButtonHud(function():void
			{
				g.enterState(new SettingsState(g));
			}, "button_settings.png");
			encountersButton = new ButtonHud(function():void
			{
				g.enterState(new MenuState(g, EncounterState));
			}, "button_encounters.png");
			leaderboardButton = new ButtonHud(function():void
			{
				g.enterState(new LeaderBoardState2(g));
			}, "button_leaderboard.png");
			salesButton = new Button(function():void
			{
				g.tryOpenSaleSpinner();
				salesButton.enabled = true;
			}, "Sale!", "buy");
			if (g.me.guest == true || !g.me.hasCorrectTOSVersion)
			{
				salesButton.visible = false;
			}
			else
			{
				salesButton.visible = true;
			}
			playerListButton = new ButtonPlayers(function():void
			{
				g.enterState(new PlayerListState(g));
			});
			pvpMenuButton = new ButtonPvPMenu(function():void
			{
				g.enterState(new PvpScreenState(g));
			}, Localize.t("PvP"));
			pvpQuickMatchButton = new ButtonPvPQuickMatch(g, "pvp random", g.queueManager.getQueue("pvp random"), true);
			new ToolTip(g, mapButton, Localize.t("Solar system map <FONT COLOR='#44FF44'>[key]</FONT>").replace("[key]", keyBinds.getKeyChar(9)));
			new ToolTip(g, shipButton, Localize.t("Ship <FONT COLOR='#44FF44'>[key]</FONT>").replace("[key]", keyBinds.getKeyChar(2)));
			new ToolTip(g, cargoButton, Localize.t("Cargo bay <FONT COLOR='#44FF44'>[key]</FONT>").replace("[key]", keyBinds.getKeyChar(7)));
			new ToolTip(g, artifactsButton, Localize.t("Artifacts <FONT COLOR='#44FF44'>[key]</FONT>").replace("[key]", keyBinds.getKeyChar(3)));
			new ToolTip(g, settingsButton, Localize.t("Settings <FONT COLOR='#44FF44'>[key]</FONT>").replace("[key]", keyBinds.getKeyChar(8)));
			new ToolTip(g, buyFluxButton, Localize.t("Flux is necessary to get <FONT COLOR='#ffffff'>new ships</FONT> and is also used to gain <FONT COLOR='#ffffff'>upgrades</FONT> and other <FONT COLOR='#ffffff'>advantages</FONT> in the game."));
			new ToolTip(g, shopButton, Localize.t("Shop <FONT COLOR='#44FF44'>[key]</FONT>\nHere you can get cool <FONT COLOR='#ffffff'>packages</FONT> and <FONT COLOR='#ffffff'>boosts</FONT> that will make the game more fun!").replace("[key]", keyBinds.getKeyChar(1)));
			new ToolTip(g, playerListButton, Localize.t("Players <FONT COLOR='#44FF44'>[key]</FONT>").replace("[key]", keyBinds.getKeyChar(25)));
			new ToolTip(g, leaderboardButton, Localize.t("Leaderboard"));
			new ToolTip(g, missionsButton, Localize.t("Missions <FONT COLOR='#44FF44'>[key]</FONT>").replace("[key]", keyBinds.getKeyChar(5)));
			new ToolTip(g, encountersButton, Localize.t("Alien Encounters <FONT COLOR='#44FF44'>[key]</FONT>").replace("[key]", keyBinds.getKeyChar(4)));
			new ToolTip(g, pvpMenuButton, Localize.t("Queue up for pvp \nmatches and view \npvp statistics <FONT COLOR='#44FF44'>[key]</FONT>").replace("[key]", keyBinds.getKeyChar(6)));
			new ToolTip(g, pvpQuickMatchButton, "<FONT COLOR='#88FF88'>" + Localize.t("Play a PvP match.") + "</FONT>\n\n" + "<FONT COLOR='#FFFFFF'>" + Localize.t("Domination") + "</FONT>\n" + Localize.t("This gamemode is team based and requires you to capture zones in order to win.") + "\n\n" + "<FONT COLOR='#FFFFFF'>" + Localize.t("Deathmatch") + "</FONT>\n" + Localize.t("This is a free for all gamemode where the player with most kills win.") + "\n\n" + "<FONT COLOR='#FFFFFF'>" + Localize.t("Rewards") + "</FONT>\n" + Localize.t("By participating you will gain resources, experience and artifacts! Rewards are based on your own skill, but also your teams performance in Domination.") + "\n\n" + "<FONT COLOR='#FFFFFF'>" + Localize.t("Match Making") + "</FONT>\n" + Localize.t("The matchmaker tries to find players and teams that have equal rating. There is also a split between levels:") + " 1-9, 10-19, 20-39, 40-79, 80-120\n");
			new ToolTip(g, podButton, Localize.t("Click here to purchase or open your pods."));
			resourceBox = new ResourceBox(g);
			g.myCargo.reloadCargoFromServer(function():void
			{
				resourceBox.update();
				cargoButton.update();
			});
			if (g.solarSystem.isPvpSystemInEditor)
			{
				pvpQuickMatchButton.visible = false;
				radar.visible = false;
				shopIcons.visible = false;
				buyFluxButton.visible = false;
				shopButton.visible = false;
				missionsButton.visible = false;
				newMissionsButton.visible = false;
				clanButton.visible = false;
				mapButton.visible = false;
				resourceBox.visible = false;
				cargoButton.visible = false;
				encountersButton.visible = false;
			}
			else
			{
				pvpMenuButton.visible = false;
			}
			if (g.isSystemTypeSurvival())
			{
				container.addChild(uberStats);
			}
			container.addChild(healthAndShield);
			container.addChild(bossHealth);
			container.addChild(powerBar);
			container.addChild(radar);
			container.addChild(experience);
			container.addChild(weaponHotkeys);
			container.addChild(abilities);
			container.addChild(shopIcons);
			container.addChild(podButton);
			if (g.isSystemPvPEnabled())
			{
				container.addChild(pvpIcon);
			}
			container.addChild(mapButton);
			container.addChild(shipButton);
			container.addChild(artifactsButton);
			container.addChild(encountersButton);
			container.addChild(settingsButton);
			container.addChild(leaderboardButton);
			container.addChild(cargoButton);
			if (!g.solarSystem.isPvpSystemInEditor)
			{
				container.addChild(missionsButton);
			}
			if (!g.solarSystem.isPvpSystemInEditor)
			{
				container.addChild(newMissionsButton);
			}
			container.addChild(pvpMenuButton);
			container.addChild(pvpQuickMatchButton);
			if (g.salesManager.isSale())
			{
				container.addChild(salesButton);
			}
			container.addChild(clanButton);
			container.addChild(buyFluxButton);
			container.addChild(shopButton);
			container.addChild(playerListButton);
			container.addChild(resourceBox);
			if (showUtilityTexts)
			{
				container.addChild(safeZoneText);
				container.addChild(repairText);
				container.addChild(landText);
			}
			container.addChild(artifactLimitText);
			if (g.me.artifactCount >= g.me.artifactLimit)
			{
				showArtifactLimitText();
			}
			g.addChild(container);
			show = false;
			if (g.me.level <= 2)
			{
				hintMapText = new TextBitmap();
				hintMapText.text = Localize.t("Press [key] for map").replace("[key]", keyBinds.getKeyChar(9));
				hintMapText.format.color = 16777028;
				hintMapText.x = 140;
				hintMapText.y = g.stage.stageHeight - 135;
				hintMapText.alpha = 0.8;
				hintMapText.blendMode = "add";
				container.addChild(hintMapText);
			}
			Starling.current.nativeOverlay.addChild(fullScreenButton);
			g.addResizeListener(resize);
			loadComplete = true;
			resize();
		}
		
		public function initMissionsButtons():void
		{
			var m:Mission;
			var daily:Daily;
			if (isShowingNewMissionsButton)
			{
				return;
			}
			hideMissionButtons();
			for each (m in g.me.missions)
			{
				if (m.viewed == false)
				{
					if (m.missionTypeKey == "s1l0zM-6lkq9l1jlGDBy4w")
					{
						TweenMax.delayedCall(10, function():void
						{
							showNewMissionsButton();
						});
						return;
					}
					showNewMissionsButton();
					return;
				}
			}
			if (g.me.missions.length > 0)
			{
				showMissionsButton();
			}
			for each (m in g.me.missions)
			{
				if (m.finished == true)
				{
					missionsButton.hintFinished();
					return;
				}
			}
			for each (daily in g.me.dailyMissions)
			{
				if (daily.complete)
				{
					missionsButton.hintFinished();
				}
			}
		}
		
		public function showNewMissionsButton():void
		{
			if (newMissionsButton.visible)
			{
				return;
			}
			isShowingNewMissionsButton = true;
			TweenMax.delayedCall(1.5, function():void
			{
				missionsButton.hide();
				newMissionsButton.show();
				g.textManager.createNewMissionArrivedText();
				isShowingNewMissionsButton = false;
			});
		}
		
		public function showMissionsButton():void
		{
			newMissionsButton.visible = false;
			missionsButton.visible = true;
		}
		
		public function hideMissionButtons():void
		{
			newMissionsButton.visible = false;
			missionsButton.visible = false;
			newMissionsButton.hide();
		}
		
		public function set show(param1:Boolean):void
		{
			if (!SceneBase.settings.showHud)
			{
				param1 = false;
			}
			if (param1)
			{
				cargoButton.update();
				resourceBox.update();
			}
			fullScreenButton.visible = param1;
			container.visible = param1;
		}
		
		public function get show():Boolean
		{
			return container.visible;
		}
		
		public function hideMapHint():void
		{
			if (hintMapText == null)
			{
				return;
			}
			container.removeChild(hintMapText);
			hintMapText = null;
			if (mapButton.filter)
			{
				mapButton.filter.dispose();
				mapButton.filter = null;
			}
		}
		
		public function update():void
		{
			if (!g.solarSystem.isPvpSystemInEditor)
			{
				radar.update();
			}
			weaponHotkeys.update();
			abilities.update();
			compas.update();
			experience.update();
			shopIcons.update();
			if (hintMapText != null)
			{
				hintMapFlashCounter++;
				if (hintMapFlashCounter % 100 == 1)
				{
					mapButton.flash();
				}
			}
			pvpQuickMatchButton.update();
			playerListButton.text = g.playerManager.players.length.toString();
			var _loc2_:Player = g.me;
			if (_loc2_ == null)
			{
				return;
			}
			var _loc1_:PlayerShip = _loc2_.ship;
			if (_loc1_ == null)
			{
				return;
			}
			if (_loc2_.inSafeZone)
			{
				safeZoneText.visible = true;
				if (_loc1_.hp < _loc1_.hpMax || _loc1_.shieldHp < _loc1_.shieldHpMax)
				{
					repairText.visible = true;
				}
				else
				{
					repairText.visible = false;
				}
			}
			else
			{
				repairText.visible = false;
				safeZoneText.visible = false;
			}
		}
		
		public function resize(param1:Event = null):void
		{
			if (!loadComplete)
			{
				return;
			}
			var _loc7_:Texture = textureManager.getTextureGUIByTextureName("hud_bottom_spacer.png");
			var _loc11_:Texture = textureManager.getTextureGUIByTextureName("hud_radar.png");
			var _loc4_:Texture = textureManager.getTextureGUIByTextureName("hud_bottom_middle.png");
			var _loc9_:Texture = textureManager.getTextureGUIByTextureName("hud_bottom_right.png");
			var _loc17_:Image = new Image(_loc11_);
			_loc17_.y = g.stage.stageHeight - _loc11_.height;
			var _loc13_:int = 0;
			if (g.stage.stageWidth < 1000)
			{
				_loc13_ = 35;
			}
			var _loc14_:Image = new Image(_loc4_);
			_loc14_.y = g.stage.stageHeight - _loc4_.height;
			_loc14_.x = g.stage.stageWidth / 2 - _loc14_.width / 2 + _loc13_;
			var _loc2_:Image = new Image(_loc9_);
			_loc2_.y = g.stage.stageHeight - _loc9_.height;
			_loc2_.x = g.stage.stageWidth - _loc9_.width;
			var _loc15_:Image = new Image(_loc7_);
			_loc15_.y = g.stage.stageHeight - _loc7_.height;
			_loc15_.width = g.stage.stageWidth;
			_loc15_.height = _loc7_.height;
			var _loc5_:Texture = textureManager.getTextureGUIByTextureName("hud_top_spacer.png");
			var _loc6_:Texture = textureManager.getTextureGUIByTextureName("hud_top_left.png");
			var _loc18_:Texture = textureManager.getTextureGUIByTextureName("hud_top_right.png");
			var _loc8_:Texture = textureManager.getTextureGUIByTextureName("hud_right_side.png");
			var _loc10_:Image = new Image(_loc6_);
			_loc10_.y = 10;
			var _loc3_:Image = new Image(_loc18_);
			_loc3_.y = 10;
			_loc3_.x = g.stage.stageWidth - _loc3_.width;
			var _loc16_:Image = new Image(_loc8_);
			_loc16_.y = 41;
			_loc16_.x = g.stage.stageWidth - _loc16_.width;
			var _loc12_:Image = new Image(_loc5_);
			_loc12_.y = 10;
			_loc12_.width = g.stage.stageWidth;
			_loc12_.height = _loc5_.height;
			bgr.clear();
			bgr.addMesh(_loc15_);
			if (!g.solarSystem.isPvpSystemInEditor)
			{
				bgr.addMesh(_loc17_);
			}
			bgr.addMesh(_loc14_);
			bgr.addMesh(_loc2_);
			bgr.addMesh(_loc12_);
			bgr.addMesh(_loc10_);
			if (!g.solarSystem.isPvpSystemInEditor)
			{
				bgr.addMesh(_loc3_);
			}
			bgr.addMesh(_loc16_);
			bgr.y = 0;
			bgr.touchable = false;
			mapButton.x = 117;
			mapButton.y = g.stage.stageHeight - 36;
			artifactsButton.x = 162;
			artifactsButton.y = g.stage.stageHeight - 36;
			shipButton.x = 187;
			shipButton.y = g.stage.stageHeight - 36;
			encountersButton.x = 212;
			encountersButton.y = g.stage.stageHeight - 36;
			cargoButton.x = 237;
			cargoButton.y = encountersButton.y;
			clanButton.x = 272;
			clanButton.y = encountersButton.y;
			if (g.solarSystem.isPvpSystemInEditor)
			{
				shipButton.x += 18;
				artifactsButton.x += 18;
				cargoButton.x += 18;
				clanButton.x += 18;
			}
			resourceBox.x = g.stage.stageWidth - 305;
			resourceBox.y = 16;
			buyFluxButton.x = g.stage.stageWidth - 315 - buyFluxButton.width;
			buyFluxButton.y = 16;
			shopButton.x = g.stage.stageWidth - 315 - buyFluxButton.width - 5 - shopButton.width;
			shopButton.y = 16;
			podButton.x = g.stage.stageWidth - 315 - buyFluxButton.width - 5 - shopButton.width - 5 - podButton.width - 5;
			podButton.y = 16;
			abilities.x = g.stage.stageWidth - 50;
			abilities.y = 66;
			experience.x = 0;
			experience.y = 0;
			if (g.stage.stageWidth < 1000)
			{
				powerBar.scaleX = 0.9;
				powerBar.x = g.stage.stageWidth / 2 - 147 + _loc13_ + 20;
				powerBar.y = g.stage.stageHeight - 31;
			}
			else
			{
				powerBar.scaleX = 1;
				powerBar.x = g.stage.stageWidth / 2 - 147 + _loc13_;
				powerBar.y = g.stage.stageHeight - 31;
			}
			healthAndShield.x = g.stage.stageWidth / 2 + 23 + _loc13_;
			healthAndShield.y = g.stage.stageHeight - 42;
			uberStats.y = 66;
			uberStats.x = abilities.x - 100;
			shopIcons.x = healthAndShield.x + 136;
			shopIcons.y = g.stage.stageHeight - shopIcons.height - 12;
			pvpIcon.x = g.stage.stageWidth / 2 - 10 + _loc13_;
			pvpIcon.y = g.stage.stageHeight - 36;
			fullScreenButton.x = g.stage.stageWidth - 130;
			fullScreenButton.y = g.stage.stageHeight - 36;
			settingsButton.x = g.stage.stageWidth - 105;
			settingsButton.y = g.stage.stageHeight - 36;
			leaderboardButton.x = g.stage.stageWidth - 80;
			leaderboardButton.y = g.stage.stageHeight - 36;
			missionsButton.x = g.stage.stageWidth - missionsButton.width + 2;
			missionsButton.y = g.stage.stageHeight - 64;
			newMissionsButton.x = g.stage.stageWidth - newMissionsButton.width - 5;
			newMissionsButton.y = g.stage.stageHeight - 64;
			salesButton.x = g.stage.stageWidth - salesButton.width - 5;
			salesButton.y = g.stage.stageHeight - 64 - 32;
			pvpMenuButton.x = g.stage.stageWidth - pvpMenuButton.width - 5;
			pvpMenuButton.y = g.stage.stageHeight - 64;
			pvpQuickMatchButton.x = 141;
			pvpQuickMatchButton.y = g.stage.stageHeight - 115;
			playerListButton.x = g.stage.stageWidth - 55;
			playerListButton.y = g.stage.stageHeight - 36;
			safeZoneText.x = g.stage.stageWidth / 2 - safeZoneText.width / 2;
			safeZoneText.y = g.stage.stageHeight / 2 + 180;
			repairText.x = g.stage.stageWidth / 2 - repairText.width / 2;
			repairText.y = g.stage.stageHeight / 2 + 210;
			landText.x = g.stage.stageWidth / 2 - landText.width / 2;
			landText.y = g.stage.stageHeight - g.stage.stageHeight / 3;
			radar.x = 16.5;
			radar.y = g.stage.stageHeight - 20.5 - radar.radius * 2;
			if (fullScreenHintImage != null)
			{
				fullScreenHintImage.x = g.stage.stageWidth - 2 - fullScreenHintImage.width;
				fullScreenHintImage.y = g.stage.stageHeight - 36 - fullScreenHintImage.height;
			}
			if (hintMapText)
			{
				hintMapText.y = g.stage.stageHeight - 135;
			}
		}
		
		public function removeFullScreenHint():void
		{
			if (fullScreenHintImage != null)
			{
				g.removeChildFromOverlay(fullScreenHintImage);
				fullScreenHintImage = null;
			}
		}
		
		public function showArtifactLimitText():void
		{
			artifactLimitText.visible = true;
			artifactsButton.hintNew();
			artifactsButton.flash();
			if (artifactTween != null)
			{
				artifactTween.kill();
			}
			artifactTween = TweenMax.fromTo(artifactLimitText, 1, {"alpha": 1}, {"alpha": 0, "repeat": -1});
		}
		
		public function hideArtifactLimitText():void
		{
			if (artifactTween != null)
			{
				artifactTween.kill();
				artifactTween = null;
			}
			artifactLimitText.visible = false;
		}
		
		public function hideFullScreenHint():void
		{
			if (fullScreenHintImage == null)
			{
				return;
			}
			fullScreenHintImage.visible = false;
		}
		
		public function showFullScreenHint():void
		{
			if (fullScreenHintImage == null)
			{
				return;
			}
			fullScreenHintImage.visible = true;
			TweenMax.delayedCall(60, removeFullScreenHint);
		}
		
		public function updateCredits():void
		{
			buyFluxButton.updateCredits();
		}
		
		private function clean(param1:Event = null):void
		{
			g.removeResizeListener(resize);
		}
		
		public function get isLoaded():Boolean
		{
			return loadComplete;
		}
		
		public function removeUtilityTexts():void
		{
			showUtilityTexts = false;
			container.removeChild(landText);
			container.removeChild(repairText);
			container.removeChild(safeZoneText);
		}
		
		public function hideLandText():void
		{
			landText.visible = false;
		}
		
		public function showLandText(param1:String = ""):void
		{
			if (landText.visible)
			{
				return;
			}
			var _loc2_:KeyBinds = SceneBase.settings.keybinds;
			landText.text = Localize.t("Press [key] to land on").replace("[key]", _loc2_.getKeyChar(10)) + " " + param1;
			landText.visible = true;
		}
		
		public function updatePodCount(param1:int):void
		{
			podButton.text = param1.toString();
			resize();
		}
		
		public function dispose():void
		{
			clean();
			g.removeChild(container, true);
			radar.dispose();
			shipButton = null;
			mapButton = null;
			cargoButton = null;
			settingsButton = null;
			buyFluxButton = null;
			newMissionsButton = null;
			missionsButton = null;
			artifactsButton = null;
			leaderboardButton = null;
			clanButton = null;
			encountersButton = null;
			healthAndShield = null;
			podButton = null;
			powerBar = null;
			bossHealth = null;
			weaponHotkeys = null;
			radar = null;
			shopIcons = null;
			textureManager = null;
			abilities = null;
			compas = null;
			salesButton = null;
			playerListButton = null;
			bgr.dispose();
			bgr = null;
			experience = null;
			resourceBox = null;
			safeZoneText.dispose();
			repairText.dispose();
			landText.dispose();
		}
	}
}
