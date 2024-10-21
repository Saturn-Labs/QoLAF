package core.credits
{
	import core.player.Player;
	import core.scene.Game;
	import playerio.Message;
	import starling.events.EventDispatcher;
	
	public class CreditManager extends EventDispatcher
	{
		public static const COST_SMALL:int = 3;
		
		public static const COST_MEDIUM:int = 6;
		
		public static const RESET_COST:int = 200;
		
		public static const RESET_PACKAGE_COST:int = 1000;
		
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
		
		private static var artifactCosts:Array = [2, 3, 5, 7, 12, 20, 30, 45, 60];
		
		private var g:Game;
		
		private var p:Player;
		
		public function CreditManager(param1:Game)
		{
			super();
			this.g = param1;
			this.p = param1.me;
		}
		
		public static function getCostWeaponFactory(param1:String):int
		{
			switch (param1)
			{
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
		
		public static function getCostWarpPathLicense(param1:String):int
		{
			switch (param1)
			{
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
		
		public static function getCostInstant(param1:int):int
		{
			if (param1 <= 3)
			{
				return 30;
			}
			if (param1 <= 6)
			{
				return 50;
			}
			return 90;
		}
		
		public static function getCostArtifactSlot(param1:int):int
		{
			switch (param1 - 2)
			{
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
		
		public static function getCostWeaponSlot(param1:int):int
		{
			switch (param1 - 3)
			{
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
		
		public static function getCostCrewSlot(param1:int):int
		{
			switch (param1 - 4)
			{
			case 0: 
				return 500;
			case 1: 
				return 1000;
			default: 
				return 0;
			}
		}
		
		public static function getCostCompressor(param1:int):int
		{
			switch (param1 - 1)
			{
			case 0: 
				return 10;
			case 1: 
				return 20;
			case 2: 
				return 50;
			case 3: 
				return 120;
			case 4: 
				return 280;
			case 5: 
				return 500;
			default: 
				return 0;
			}
		}
		
		public static function getCostCrew():int
		{
			return 100;
		}
		
		public static function getCostChangeName(param1:String):int
		{
			if (param1 == "Guest")
			{
				return 0;
			}
			return 100;
		}
		
		public static function getCostSkipMission():int
		{
			return 5;
		}
		
		public static function getCostClan():int
		{
			return 200;
		}
		
		public static function getCostUpgrade(param1:int):int
		{
			switch (param1 - 1)
			{
			case 0: 
				return 100;
			case 1: 
				return 200;
			case 2: 
				return 300;
			case 3: 
				return 400;
			case 4: 
				return 500;
			case 5: 
				return 600;
			default: 
				return 0;
			}
		}
		
		public static function getCostTeleportToFriend():int
		{
			return 3;
		}
		
		public static function getCostTeleportToDeath():int
		{
			return 3;
		}
		
		public static function getCostArtifactSetup():int
		{
			return 200;
		}
		
		public static function getCostPaintJob():int
		{
			return 250;
		}
		
		public static function getCostArtifactUpgrade(param1:Game, param2:Number):int
		{
			var _loc4_:Number = (param2 - param1.time) / 1000 / 60;
			var _loc3_:Number = _loc4_ / 60;
			var _loc5_:int = 0;
			if (_loc3_ < 1)
			{
				if (_loc4_ < 15)
				{
					_loc5_ = 0;
				}
				else if (_loc4_ < 30)
				{
					_loc5_ = 1;
				}
				else if (_loc4_ < 45)
				{
					_loc5_ = 2;
				}
				else
				{
					_loc5_ = 3;
				}
			}
			else if (_loc3_ < 1.5)
			{
				_loc5_ = 3;
			}
			else if (_loc3_ < 2.5)
			{
				_loc5_ = 4;
			}
			else if (_loc3_ < 3.5)
			{
				_loc5_ = 5;
			}
			else if (_loc3_ < 6)
			{
				_loc5_ = 6;
			}
			else if (_loc3_ < 10)
			{
				_loc5_ = 7;
			}
			else if (_loc3_ < 12)
			{
				_loc5_ = 8;
			}
			else
			{
				_loc5_ = 8;
			}
			return artifactCosts[_loc5_];
		}
		
		public static function getCostCrewTraining():int
		{
			return 10;
		}
		
		public static function getCostArtifactCapacityUpgrade(param1:int):int
		{
			switch (param1 - 1)
			{
			case 0: 
				return 600;
			case 1: 
				return 800;
			default: 
				return 1000;
			}
		}
		
		public static function getCostPods():int
		{
			return 45;
		}
		
		public function refresh(param1:Function = null):void
		{
			var callback:Function = param1;
			var oldFlux:int = CreditManager.FLUX;
			g.rpc("getFluxAmount", function(param1:Message):void
			{
				var _loc2_:int = 0;
				FLUX = param1.getInt(0);
				g.hud.updateCredits();
				dispatchEventWith("refresh");
				if (FLUX > oldFlux + 400)
				{
					_loc2_ = CreditManager.FLUX - oldFlux;
				}
				if (callback != null)
				{
					callback();
				}
			});
		}
	}
}
