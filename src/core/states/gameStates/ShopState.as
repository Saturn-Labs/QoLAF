package core.states.gameStates
{
	import core.scene.Game;
	import starling.events.Event;
	
	public class ShopState extends PlayState
	{
		public static const STATE_XP_BOOST:String = "xpBoost";
		public static const STATE_TRACTOR_BEAM:String = "tractorBeam";
		public static const STATE_XP_PROTECTION:String = "xpProtection";
		public static const STATE_CARGO_PROTECTION:String = "cargoProtection";
		public static const STATE_SUPPORTER_PACKAGE:String = "supporterPackage";
		public static const STATE_POWER_PACKAGE:String = "powerPackage";
		public static const STATE_MEGA_PACKAGE:String = "megaPackage";
		public static const STATE_BEGINNER_PACKAGE:String = "beginnerPackage";
		public static const STATE_PODS:String = "podPackage";
		private var shop:Shop;
		
		public function ShopState(param1:Game, param2:String = "")
		{
			super(param1);
			if (param2 == "")
			{
				if (!param1.me.beginnerPackage && param1.me.level < 30)
				{
					param2 = "beginnerPackage";
				}
				else if (!param1.me.hasSupporter())
				{
					param2 = "supporterPackage";
				}
				else if (!param1.me.powerPackage)
				{
					param2 = "powerPackage";
				}
				else if (!param1.me.megaPackage)
				{
					param2 = "megaPackage";
				}
				else
				{
					param2 = "podPackage";
				}
			}
			shop = new Shop(param1, param2);
		}
		
		override public function enter():void
		{
			super.enter();
			drawBlackBackground();
			addChild(shop);
			shop.load(function():void
			{
				loadCompleted();
				g.hud.show = false;
				shop.addEventListener("close", function(param1:Event):void
				{
					sm.revertState();
				});
			});
		}
		
		override public function execute():void
		{
			if (!loaded)
			{
				return;
			}
			if (keybinds.isEscPressed || keybinds.isInputPressed(1))
			{
				sm.revertState();
				return;
			}
			shop.update();
		}
		
		override public function exit(param1:Function):void
		{
			shop.removeEventListeners();
			shop.exit();
			super.exit(param1);
		}
	}
}
