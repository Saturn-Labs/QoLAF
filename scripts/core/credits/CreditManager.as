package core.credits {
	import core.player.Player;
	import core.scene.Game;
	import playerio.Message;
	import starling.events.EventDispatcher;
	
	public class CreditManager extends EventDispatcher {
		public static const COST_SMALL:int = 3;
		
		public static const COST_MEDIUM:int = 6;
		
		public static const RESET_COST:int = 20;
		
		public static const RESET_PACKAGE_COST:int = 100;
		
		public static const INSTANTEXPLORE_COST_SMALL:int = 30;
		
		public static const INSTANTEXPLORE_COST_MEDIUM:int = 50;
		
		public static const INSTANTEXPLORE_COST_LARGE:int = 90;
		
		public static const TYPE_DAILY:String = "daily";
		
		public static const TYPE_MISSION:String = "missions";
		
		public static const TYPE_LEVEL:String = "level";
		
		public static const TYPE_LANDED:String = "planetLanded";
		
		public static const TYPE_CLEARED:String = "planetCleared";
		
		public static const TYPE_FBLIKE:String = "fbLike";
		
		public static const TYPE_INVITE_1:String = "InviteRewardFlux1";
		
		public static const TYPE_INVITE_2:String = "InviteRewardFlux2";
		
		public static const TYPE_PVP:String = "pvp";
		
		public static var FLUX:int = 0;
		
		private static var artifactCosts:Array = [2,3,5,7,12,20,30,45,60];
		
		private var g:Game;
		
		private var p:Player;
		
		public function CreditManager(g:Game) {
			super();
			this.g = g;
			this.p = g.me;
		}
		
		public static function getCostWeaponFactory(payVaultItem:String) : int {
			switch(payVaultItem) {
				case "Weapon Hyperion":
					return 20;
				case "Weapon Kapello":
					return 30;
				case "Weapon Durian":
					return 50;
				case "Weapon Arrenius":
					return 100;
				case "Weapon Kritillian":
					return 150;
				case "Weapon Vibrilian":
					return 200;
				case "Weapon Sarkinon":
					return 400;
				case "Weapon Cynapsian":
					return 800;
				case "Piratebay":
					return 950;
				default:
					return 10000;
			}
		}
		
		public static function getCostWarpPathLicense(payVaultItem:String) : int {
			switch(payVaultItem) {
				case "Warp Path Arrenius_Kritillian":
					return 125;
				case "Warp Path Durian_Arrenius":
					return 75;
				case "Warp Path Kapello_Durian":
					return 25;
				case "Warp Path Kritillian_X":
					return 125;
				case "Warp Path Mitrillion_Vibrilian":
					return 200;
				case "Warp Path x_Mitrillion":
					return 150;
				case "Warp Path Vibrilian_Sarkinon":
					return 250;
				case "Warp Path Vibrilian_Fulzar":
					return 450;
				default:
					return 0;
			}
		}
		
		public static function getCostInstant(size:int) : int {
			if(size <= 3) {
				return 30;
			}
			if(size <= 6) {
				return 50;
			}
			return 90;
		}
		
		public static function getCostArtifactSlot(number:int) : int {
			switch(number - 2) {
				case 0:
					return 70;
				case 1:
					return 200;
				case 2:
					return 450;
				case 3:
					return 950;
				default:
					return 0;
			}
		}
		
		public static function getCostWeaponSlot(number:int) : int {
			switch(number - 3) {
				case 0:
					return 20;
				case 1:
					return 150;
				case 2:
					return 250;
				default:
					return 0;
			}
		}
		
		public static function getCostCrewSlot(number:int) : int {
			switch(number - 4) {
				case 0:
					return 500;
				case 1:
					return 1000;
				default:
					return 0;
			}
		}
		
		public static function getCostCompressor(level:int) : int {
			switch(level - 1) {
				case 0:
					return 10;
				case 1:
					return 20;
				case 2:
					return 50;
				case 3:
					return 2 * 60;
				case 4:
					return 280;
				case 5:
					return 500;
				default:
					return 0;
			}
		}
		
		public static function getCostCrew() : int {
			return 100;
		}
		
		public static function getCostChangeName(currentName:String) : int {
			if(currentName == "Guest") {
				return 0;
			}
			return 100;
		}
		
		public static function getCostSkipMission() : int {
			return 5;
		}
		
		public static function getCostClan() : int {
			return 200;
		}
		
		public static function getCostUpgrade(level:int) : int {
			switch(level - 1) {
				case 0:
					return 100;
				case 1:
					return 200;
				case 2:
					return 5 * 60;
				case 3:
					return 400;
				case 4:
					return 500;
				case 5:
					return 10 * 60;
				default:
					return 0;
			}
		}
		
		public static function getCostTeleportToFriend() : int {
			return 3;
		}
		
		public static function getCostTeleportToDeath() : int {
			return 3;
		}
		
		public static function getCostArtifactSetup() : int {
			return 200;
		}
		
		public static function getCostPaintJob() : int {
			return Game.instance.me.hasSupporter() ? 0 : 250;
		}
		
		public static function getCostArtifactUpgrade(g:Game, endTime:Number) : int {
			var _local5:Number = (endTime - g.time) / 1000 / (60);
			var _local3:Number = _local5 / (60);
			var _local4:int = 0;
			if(_local3 < 1) {
				if(_local5 < 15) {
					_local4 = 0;
				} else if(_local5 < 30) {
					_local4 = 1;
				} else if(_local5 < 45) {
					_local4 = 2;
				} else {
					_local4 = 3;
				}
			} else if(_local3 < 1.5) {
				_local4 = 3;
			} else if(_local3 < 2.5) {
				_local4 = 4;
			} else if(_local3 < 3.5) {
				_local4 = 5;
			} else if(_local3 < 6) {
				_local4 = 6;
			} else if(_local3 < 10) {
				_local4 = 7;
			} else if(_local3 < 12) {
				_local4 = 8;
			} else {
				_local4 = 8;
			}
			return artifactCosts[_local4];
		}
		
		public static function getCostCrewTraining() : int {
			return 10;
		}
		
		public static function getCostArtifactCapacityUpgrade(level:int) : int {
			switch(level - 1) {
				case 0:
					return 10 * 60;
				case 1:
					return 800;
				default:
					return 1000;
			}
		}
		
		public static function getCostPods() : int {
			return 45;
		}
		
		public function refresh(callback:Function = null) : void {
			var oldFlux:int = CreditManager.FLUX;
			g.rpc("getFluxAmount",function(param1:Message):void {
				var _local2:int = 0;
				FLUX = param1.getInt(0);
				g.hud.updateCredits();
				dispatchEventWith("refresh");
				if(FLUX > oldFlux + 400) {
					_local2 = CreditManager.FLUX - oldFlux;
				}
				if(callback != null) {
					callback();
				}
			});
		}
	}
}

