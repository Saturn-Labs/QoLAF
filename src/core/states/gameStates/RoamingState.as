package core.states.gameStates
{
	import core.hud.components.dialogs.PopupConfirmMessage;
	import core.hud.components.explore.ExploreMap;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.solarSystem.Body;
	import core.states.gameStates.missions.MissionsState;
	import core.states.menuStates.ArtifactState2;
	import core.states.menuStates.CargoState;
	import core.states.menuStates.EncounterState;
	import core.states.menuStates.HomeState;
	
	public class RoamingState extends PlayState
	{
		private var mayLand:Boolean;
		
		private var exitDialog:PopupConfirmMessage;
		
		public function RoamingState(param1:Game)
		{
			super(param1);
		}
		
		override public function enter():void
		{
			super.enter();
			g.messageLog.visible = true;
			ExploreMap.forceSelectAreaKey = null;
			g.hud.show = true;
			if (g.pvpManager != null)
			{
				g.pvpManager.showText();
			}
			loadCompleted();
			g.deathLineManager.forceUpdate();
		}
		
		override public function execute():void
		{
			if (loaded)
			{
				updateInput();
			}
			super.execute();
		}
		
		private function updateInput():void
		{
			var bodies:Vector.<Body>;
			var bodyLen:int;
			var i:int;
			var b:Body;
			var dialog:PopupConfirmMessage;
			var myShip:PlayerShip = g.me.ship;
			if (!me.commandable)
			{
				if (me.respawnReady() && input.isKeyPressed(32))
				{
					g.me.respawnNextReady = 0;
					g.send("respawn");
				}
				return;
			}
			if (!loaded)
			{
				return;
			}
			if (input.isKeyPressed(13))
			{
				g.chatInput.toggleChatMode();
			}
			if (g.chatInput.isActive())
			{
				if (input.isKeyPressed(27))
				{
					g.chatInput.closeChat();
				}
				if (input.isKeyPressed(40))
				{
					g.chatInput.next();
				}
				if (input.isKeyPressed(38))
				{
					g.chatInput.previous();
				}
				checkAccelerate(true);
				return;
			}
			bodies = g.bodyManager.bodies;
			bodyLen = int(bodies.length);
			mayLand = false;
			i = 0;
			while (i < bodyLen)
			{
				b = bodies[i];
				if (b.isPlayerOverMe(me))
				{
					if (b.spawnersCleared)
					{
						g.hud.showLandText(b.name);
						mayLand = true;
						if (keybinds.isInputPressed(10))
						{
							g.send("requestLand", me.ship.course.time, b.key);
							return;
						}
					}
				}
				i++;
			}
			if (!mayLand)
			{
				g.hud.hideLandText();
			}
			if (RymdenRunt.isDesktop && keybinds.isEscPressed)
			{
				if (exitDialog)
				{
					g.removeChildFromOverlay(exitDialog, true);
					exitDialog = null;
				}
				else
				{
					dialog = new PopupConfirmMessage("Exit game", "Keep playing", "positive");
					g.addChildToOverlay(dialog);
					dialog.addEventListener("close", function(param1:Object):void
					{
						g.removeChildFromOverlay(dialog, true);
						exitDialog = null;
					});
					dialog.addEventListener("accept", function(param1:Object):void
					{
						g.removeChildFromOverlay(dialog, true);
						g.exitDesktop();
					});
					exitDialog = dialog;
				}
			}
			else
			{
				if (keybinds.isEscPressed || keybinds.isInputPressed(2))
				{
					g.enterState(new MenuState(g, HomeState));
					return;
				}
				if (keybinds.isInputPressed(7))
				{
					g.enterState(new MenuState(g, CargoState));
					return;
				}
				if (keybinds.isInputPressed(9) && !g.solarSystem.isPvpSystemInEditor)
				{
					g.enterState(new MapState(g));
					return;
				}
				if (keybinds.isInputPressed(5))
				{
					g.enterState(new MissionsState(g));
				}
				else if (keybinds.isInputPressed(6))
				{
					if (g.solarSystem.isPvpSystemInEditor)
					{
						g.enterState(new PvpScreenState(g));
					}
				}
				else
				{
					if (keybinds.isInputPressed(1) && !g.me.guest)
					{
						g.enterState(new ShopState(g));
						return;
					}
					if (keybinds.isInputPressed(4))
					{
						g.enterState(new MenuState(g, EncounterState));
						return;
					}
					if (keybinds.isInputPressed(8))
					{
						g.enterState(new SettingsState(g));
						return;
					}
					if (keybinds.isInputPressed(0))
					{
						g.enterState(new ClanState(g));
						return;
					}
					if (keybinds.isInputPressed(25))
					{
						g.enterState(new PlayerListState(g));
						return;
					}
					if (input.isKeyPressed(78))
					{
						g.dispatchEventWith("KingOfTheZoneSpectateNext");
					}
					else if (keybinds.isInputPressed(3))
					{
						g.enterState(new MenuState(g, ArtifactState2));
						return;
					}
				}
			}
			updateCommands();
		}
		
		override public function exit(param1:Function):void
		{
			if (g.pvpManager != null)
			{
				g.pvpManager.hideText();
			}
			super.exit(param1);
		}
	}
}
