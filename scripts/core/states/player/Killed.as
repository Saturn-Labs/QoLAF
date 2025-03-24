package core.states.player {
	import core.credits.CreditManager;
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.player.Player;
	import core.scene.Game;
	import core.states.IState;
	import core.states.StateMachine;
	import core.states.gameStates.RoamingState;
	import core.states.gameStates.ShopState;
	import core.weapon.Damage;
	import flash.geom.Point;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.filters.GlowFilter;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class Killed implements IState {
		public static var killedTime:Number;
		
		public static var killedPosition:Point = new Point(0,0);
		
		private var player:Player;
		
		private var g:Game;
		
		private var m:Message;
		
		private var sm:StateMachine;
		
		private var q:Quad;
		
		private var box:Box;
		
		private var deathInfo:TextField;
		
		private var dropInfo:TextField;
		
		private var respawnText:TextField;
		
		private var uberText:TextField;
		
		private var upperScaleLimit:Number = 1.1;
		
		private var lowerScaleLimit:Number = 0.9;
		
		private var limitIterator:Number = 0.02;
		
		public function Killed(player:Player, g:Game, m:Message) {
			super();
			this.player = player;
			this.g = g;
			this.m = m;
		}
		
		private function teleport(m:Message) : void {
			if(m.getBoolean(0)) {
				Game.trackEvent("used flux","teleport","teleport to death",CreditManager.getCostTeleportToDeath());
			} else {
				g.showErrorDialog(m.getString(1));
			}
		}
		
		public function enter() : void {
			var killerText:String;
			var mod:String;
			var lostXpText:String;
			var xpProtectionButton:Button;
			var teleportToDeathButton:Button;
			var lostXpInfo:TextField;
			var dropText:String;
			var dropDict:Object;
			var prop:String;
			var i:int;
			var amount:int;
			var prop2:String;
			var cargoProtectionButton:Button;
			if(player.isMe) {
				killedPosition = player.ship.pos.clone();
				if(killedPosition.x != 0 && killedPosition.y != 0) {
					killedTime = g.time;
				}
			}
			player.spree = 0;
			player.ship.destroy();
			player.ship = null;
			if(player.mirror != null) {
				player.mirror.destroy(false);
				player.mirror = null;
			}
			if(!player.isMe) {
				return;
			}
			g.camera.focusTarget = killedPosition;
			if(!g.gameStateMachine.inState(RoamingState)) {
				g.gameStateMachine.revertState();
			}
			if(g.hud.healthAndShield != null) {
				g.hud.healthAndShield.stopLowHPWarningEffect();
			}
			g.hud.update();
			g.killed();
			g.hud.show = false;
			box = new Box(8 * 60,280,"normal",0,20);
			killerText = m.getString(1);
			mod = m.getString(2);
			if(mod == "sun") {
				killerText = "<FONT COLOR=\'#666666\'>Cause of Death</FONT>\n<FONT SIZE=\'20\' COLOR=\'#ff4444\'>TOO HOT TO HANDLE</FONT>";
			} else if(killerText == player.name) {
				killerText = "<FONT COLOR=\'#666666\'>Cause of Death</FONT>\n<FONT SIZE=\'20\' COLOR=\'#ff4444\'>SUICIDE</FONT>";
			} else {
				killerText = "<FONT COLOR=\'#666666\'>Killed by</FONT>\n<FONT SIZE=\'20\' COLOR=\'#ff4444\'>" + killerText + "</FONT>";
			}
			killerText = killerText + "\n" + Damage.TYPE_HTML[m.getInt(4)] + " damage";
			deathInfo = new TextField(280,10,"",new TextFormat("DAIDRR"));
			deathInfo.autoSize = "vertical";
			deathInfo.format.color = 0xffffff;
			deathInfo.isHtmlText = true;
			deathInfo.text = killerText;
			deathInfo.format.horizontalAlign = "left";
			box.addChild(deathInfo);
			lostXpText = "";
			if(g.solarSystem.isPvpSystemInEditor) {
				lostXpText += "";
			} else if(player.hasXpProtection()) {
				lostXpText += "\n\n<FONT COLOR=\'#666666\'>" + Localize.t("Lost XP") + "</FONT>\n0 " + Localize.t("XP") + "\n<FONT COLOR=\'#88ff88\'>" + Localize.t("protection active") + "</FONT>";
			} else {
				lostXpText += "\n\n<FONT COLOR=\'#666666\'>" + Localize.t("Lost XP") + "</FONT>\n-" + m.getString(3) + " " + Localize.t("XP");
				xpProtectionButton = new Button(function(param1:Event):void {
					g.enterState(new ShopState(g,"xpProtection"));
				},Localize.t("Get XP protection"));
			}
			teleportToDeathButton = new Button(function(param1:Event):void {
				var e:Event = param1;
				g.creditManager.refresh(function():void {
					var confirmBuyWithFlux:CreditBuyBox = new CreditBuyBox(g,CreditManager.getCostTeleportToDeath(),Localize.t("Are you sure you want to teleport?"));
					g.addChildToOverlay(confirmBuyWithFlux);
					confirmBuyWithFlux.addEventListener("accept",function():void {
						g.rpc("buyTeleportToDeath",teleport,player.id);
						confirmBuyWithFlux.removeEventListeners();
						g.removeChildFromOverlay(confirmBuyWithFlux,true);
					});
					confirmBuyWithFlux.addEventListener("close",function():void {
						confirmBuyWithFlux.removeEventListeners();
						g.removeChildFromOverlay(confirmBuyWithFlux,true);
					});
				});
			},"Teleport to killed location","buy");
			teleportToDeathButton.x = deathInfo.x;
			teleportToDeathButton.y = deathInfo.y + deathInfo.height + teleportToDeathButton.height * 0.5;
			box.addChild(teleportToDeathButton);
			lostXpInfo = new TextField(280,10,"",new TextFormat("DAIDRR"));
			lostXpInfo.autoSize = "vertical";
			lostXpInfo.isHtmlText = true;
			lostXpInfo.format.color = 0xffffff;
			lostXpInfo.y = deathInfo.height + teleportToDeathButton.height;
			lostXpInfo.text = lostXpText;
			lostXpInfo.format.horizontalAlign = "left";
			box.addChild(lostXpInfo);
			if(xpProtectionButton != null) {
				xpProtectionButton.x = lostXpInfo.x;
				xpProtectionButton.y = lostXpInfo.y + lostXpInfo.height + xpProtectionButton.height * 0.5;
				box.addChild(xpProtectionButton);
			}
			if(g.isSystemTypeSurvival()) {
				Game.trackEvent("Survival","Death","Rank " + g.hud.uberStats.uberRank,g.me.level);
			}
			if(!g.solarSystem.isPvpSystemInEditor) {
				dropText = "<FONT COLOR=\'#666666\'>" + Localize.t("Lost Cargo") + "</FONT>\n";
				dropDict = {};
				prop = "";
				i = 5;
				while(i < m.length) {
					prop = m.getString(i);
					amount = m.getInt(i + 8);
					if(!dropDict.hasOwnProperty(prop)) {
						dropDict[prop] = amount;
					} else {
						var _local2:String = prop;
						var _local3:* = dropDict[_local2] + amount;
						dropDict[_local2] = _local3;
					}
					i += 9;
				}
				for(prop2 in dropDict) {
					dropText += prop2 + " x" + dropDict[prop2] + "\n";
				}
				if(prop == "") {
					dropText += Localize.t("None");
				}
				if(player.isCargoProtectionActive()) {
					dropText += "\n<FONT COLOR=\'#88ff88\'>" + Localize.t("protection active") + "</FONT>";
				} else {
					g.myCargo.removeAllJunk();
				}
				dropInfo = new TextField(200,10,"",new TextFormat("DAIDRR"));
				dropInfo.autoSize = "vertical";
				dropInfo.format.color = 0xffffff;
				dropInfo.isHtmlText = true;
				dropInfo.text = dropText;
				dropInfo.x = 330;
				dropInfo.format.horizontalAlign = "left";
				box.addChild(dropInfo);
				if(!player.isCargoProtectionActive() && prop != "") {
					cargoProtectionButton = new Button(function(param1:Event):void {
						g.enterState(new ShopState(g,"cargoProtection"));
					},Localize.t("Get cargo protection"));
					cargoProtectionButton.x = dropInfo.x;
					cargoProtectionButton.y = dropInfo.height + cargoProtectionButton.height / 2;
					box.addChild(cargoProtectionButton);
				}
			}
			q = new Quad(g.stage.stageWidth,g.stage.stageHeight,0);
			q.alpha = 0.5;
			g.addChild(q);
			g.addResizeListener(resize);
			g.addChild(box);
			respawnText = new TextField(10,10,"",new TextFormat("DAIDRR",52));
			respawnText.autoSize = "bothDirections";
			respawnText.text = Math.round(player.respawnNextReady - g.time).toString();
			respawnText.filter = new GlowFilter(0xffffff,1,10);
			respawnText.x = box.width / 2;
			respawnText.y = box.height - 60;
			respawnText.format.horizontalAlign = "center";
			respawnText.format.color = 0xffffff;
			respawnText.alignPivot();
			box.addChild(respawnText);
			uberText = new TextField(10,10,"",new TextFormat("DAIDRR",52));
			uberText.autoSize = "bothDirections";
			uberText.text = "";
			uberText.filter = new GlowFilter(0xffffff,1,10);
			uberText.x = box.width / 2;
			uberText.y = box.height + 30;
			uberText.format.horizontalAlign = "center";
			uberText.format.color = 0xffffff;
			uberText.alignPivot();
			box.addChild(uberText);
			resize();
		}
		
		private function resize(e:Event = null) : void {
			q.width = g.stage.stageWidth;
			q.height = g.stage.stageHeight;
			box.y = g.stage.stageHeight / 6;
			box.x = g.stage.stageWidth / 2 - 225;
		}
		
		public function execute() : void {
			var _local2:int = 0;
			var _local1:String = null;
			if(player.isMe) {
				if(respawnText.scaleX <= lowerScaleLimit) {
					limitIterator *= -1;
				} else if(respawnText.scaleX >= upperScaleLimit) {
					limitIterator *= -1;
				}
				if(player.respawnNextReady - g.time < 1000) {
					if(!g.solarSystem.isPvpSystemInEditor) {
						respawnText.text = "Press SPACE to respawn";
						respawnText.format.size = 20;
						if(g.isSystemTypeSurvival()) {
							_local2 = g.hud.uberStats.getMyLives();
							if(_local2 == 0) {
								respawnText.text = "Press SPACE to leave";
							}
						}
					} else {
						respawnText.text = "";
					}
					respawnText.alignPivot();
				} else {
					_local1 = Math.round(0.001 * (player.respawnNextReady - g.time)).toString();
					if(_local1 != respawnText.text) {
						respawnText.text = _local1;
						respawnText.alignPivot();
					}
				}
				if(g.isSystemTypeSurvival()) {
					_local2 = g.hud.uberStats.getMyLives();
					if(_local2 == 0) {
						uberText.text = "Game Over";
					} else if(_local2 == 1) {
						uberText.text = _local2 + " life left";
					} else {
						uberText.text = _local2 + " lives left";
					}
					uberText.alignPivot();
				}
				uberText.scaleX += limitIterator;
				uberText.scaleY += limitIterator;
				respawnText.scaleX += limitIterator;
				respawnText.scaleY += limitIterator;
			}
		}
		
		public function exit() : void {
			if(player.isMe) {
				if(uberText) {
					if(uberText.filter) {
						uberText.filter.dispose();
					}
					uberText.filter = null;
				}
				if(respawnText) {
					if(respawnText.filter) {
						respawnText.filter.dispose();
					}
					respawnText.filter = null;
				}
				g.removeChild(box,true);
				g.removeChild(q,true);
				g.removeResizeListener(resize);
				g.respawned();
				g.hud.show = true;
				g.messageLog.visible = true;
			}
		}
		
		public function get type() : String {
			return "Killed";
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
	}
}

