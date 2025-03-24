package core.states.gameStates {
	import core.hud.components.Button;
	import core.hud.components.ToolTip;
	import core.hud.components.WarpGateFriendLocationSelector;
	import core.hud.components.starMap.StarMap;
	import core.scene.Game;
	import core.solarSystem.Body;
	import data.DataLocator;
	import debug.Console;
	import generics.Localize;
	import joinRoom.IJoinRoomManager;
	import joinRoom.JoinRoomLocator;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	
	public class LandedWarpGate extends LandedState {
		private var starMap:StarMap;
		
		private var warpJumpButton:Button;
		
		private var uberJumpButton:Button;
		
		private var pressedWarpJump:Boolean = false;
		
		private var uberInfo:TextField = new TextField(4 * 60,10,"");
		
		private var friendLocationSelector:WarpGateFriendLocationSelector;
		
		public function LandedWarpGate(g:Game, body:Body) {
			super(g,body,body.name);
			starMap = new StarMap(g,690,530,true);
			starMap.y = 35;
			starMap.x = 35;
		}
		
		override public function enter() : void {
			super.enter();
			g.myCargo.redraw(function():void {
				starMap.load(function():void {
					starMap.addEventListener("allowWarpJump",onAllowWarpJump);
					starMap.addEventListener("disallowWarpJump",onDisallowWarpJump);
					addChild(starMap);
					warpJumpButton = new Button(function(param1:TouchEvent):void {
						warpJump();
					},Localize.t("WARP JUMP"),"positive");
					warpJumpButton.size = 14;
					warpJumpButton.visible = false;
					warpJumpButton.y = 60;
					warpJumpButton.x = 555;
					addChild(warpJumpButton);
					uberInfo.autoSize = "vertical";
					uberInfo.format.color = 0xffffff;
					uberInfo.format.horizontalAlign = "left";
					uberInfo.width = 4 * 60;
					uberInfo.text = "Play co-op with your clan members and fight against classical enemies and bosses to gain access to potentially the best artifacts in the game. Difficulty and enemy level will increase for each completed rank and you only have 3 lives each, thus sustain is more important than ever.";
					uberJumpButton = new Button(null,"WARP JUMP : Rank 1 ","positive");
					uberJumpButton.size = 14;
					uberJumpButton.visible = false;
					uberJumpButton.y = warpJumpButton.y;
					uberJumpButton.x = warpJumpButton.x + uberJumpButton.width - 40;
					uberJumpButton.alignPivot("right");
					new ToolTip(g,uberJumpButton,"Only clan members that are alive can participate in Survival instances.",null,"warp");
					uberInfo.x = warpJumpButton.x - 450;
					uberInfo.y = warpJumpButton.y + warpJumpButton.height + 140;
					uberInfo.visible = false;
					addChild(uberJumpButton);
					addChild(uberInfo);
					if(me.clanId == "") {
						uberJumpButton.enabled = false;
					}
					DataLocator.getService().loadKeyFromBigDB("Clans",g.me.clanId,function(param1:Object):void {
						var obj:Object = param1;
						var rank:int = int(obj["rankic3w-BxdMU6qWhX9t3_EaA"]);
						rank = int(!!rank ? rank : 1);
						uberJumpButton.callback = function(param1:TouchEvent):void {
							var _local3:int = 0;
							var _local6:Number = Number(obj["timeic3w-BxdMU6qWhX9t3_EaA"]);
							var _local2:Object = obj["livesic3w-BxdMU6qWhX9t3_EaA"];
							if(_local2 != null) {
								_local3 = 0;
								for(var _local5 in _local2) {
									_local3 += _local2[_local5];
								}
								if(_local3 > 0 && _local2[g.me.id] == 0 && _local6 > g.time - 24 * 60 * 60 * 1000) {
									g.showMessageDialog("You have 0 lives left. Please try again when they are finished.");
									return;
								}
							}
							var _local4:IJoinRoomManager = JoinRoomLocator.getService();
							Console.write("Rank: " + rank);
							_local4.desiredRoomId = "U_" + g.me.clanId;
							Console.write("DesiredRoom: " + _local4.desiredRoomId);
							_local4.desiredSystemType = "survival";
							executeWarpJump();
							Game.trackEvent("Survival","Join","Level " + g.me.level,g.me.level);
						};
						uberJumpButton.text = Localize.t("WARP JUMP : Rank " + rank);
						uberJumpButton.x = warpJumpButton.x + uberJumpButton.width - 40;
					});
					loadCompleted();
					g.tutorial.showWarpGateAdvice();
					if(g.me.level > 7) {
						g.tutorial.showForumAdvice();
					}
				});
			});
		}
		
		private function warpJump() : void {
			if(g.me.isWarpJumping) {
				return;
			}
			if(StarMap.selectedSolarSystem.type == "regular") {
				showFriendLocationSelector();
			} else {
				executeWarpJump();
			}
		}
		
		private function showFriendLocationSelector() : void {
			if(friendLocationSelector != null) {
				g.removeChildFromOverlay(friendLocationSelector);
			}
			friendLocationSelector = new WarpGateFriendLocationSelector(onFriendSelector);
			g.addChildToOverlay(friendLocationSelector);
		}
		
		private function onFriendSelector(doWarp:Boolean) : void {
			var joinRoomManager:IJoinRoomManager;
			g.removeChildFromOverlay(friendLocationSelector);
			friendLocationSelector = null;
			if(!doWarp) {
				warpJumpButton.enabled = true;
				return;
			}
			joinRoomManager = JoinRoomLocator.getService();
			joinRoomManager.tryWarpJumpToFriend(g.me,StarMap.selectedSolarSystem.key,executeWarpJump,function(param1:String):void {
				g.showErrorDialog(param1);
				warpJumpButton.enabled = true;
			});
		}
		
		private function executeWarpJump() : void {
			g.send("warpJump",StarMap.selectedSolarSystem.key,starMap.selectedWarpPath.key);
			pressedWarpJump = true;
			warpJumpButton.enabled = false;
			uberJumpButton.enabled = false;
		}
		
		override public function leave(e:TouchEvent = null) : void {
			if(pressedWarpJump) {
				return;
			}
			super.leave(e);
		}
		
		private function onAllowWarpJump(e:Event) : void {
			warpJumpButton.visible = true;
			uberJumpButton.visible = false;
			uberInfo.visible = false;
			if(StarMap.selectedSolarSystem.key == "ic3w-BxdMU6qWhX9t3_EaA") {
				warpJumpButton.visible = false;
				uberJumpButton.visible = true;
				uberInfo.visible = true;
			}
		}
		
		private function onDisallowWarpJump(e:Event) : void {
			warpJumpButton.visible = false;
			uberJumpButton.visible = false;
			uberInfo.visible = false;
		}
		
		override public function exit(callback:Function) : void {
			starMap.removeEventListener("allowWarpJump",onAllowWarpJump);
			starMap.removeEventListener("disallowWarpJump",onDisallowWarpJump);
			ToolTip.disposeType("warp");
			super.exit(callback);
		}
	}
}

