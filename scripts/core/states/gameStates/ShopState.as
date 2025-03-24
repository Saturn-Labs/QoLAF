package core.states.gameStates {
	import core.scene.Game;
	import starling.events.Event;
	
	public class ShopState extends PlayState {
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
		
		public function ShopState(g:Game, state:String = "") {
			super(g);
			if(state == "") {
				if(!g.me.beginnerPackage && g.me.level < 30) {
					state = "beginnerPackage";
				} else if(!g.me.hasSupporter()) {
					state = "supporterPackage";
				} else if(!g.me.powerPackage) {
					state = "powerPackage";
				} else if(!g.me.megaPackage) {
					state = "megaPackage";
				} else {
					state = "podPackage";
				}
			}
			shop = new Shop(g,state);
		}
		
		override public function enter() : void {
			super.enter();
			drawBlackBackground();
			addChild(shop);
			shop.load(function():void {
				loadCompleted();
				g.hud.show = false;
				shop.addEventListener("close",function(param1:Event):void {
					sm.revertState();
				});
			});
		}
		
		override public function execute() : void {
			if(!loaded) {
				return;
			}
			if(keybinds.isEscPressed || keybinds.isInputPressed(1)) {
				sm.revertState();
				return;
			}
			shop.update();
		}
		
		override public function exit(callback:Function) : void {
			shop.removeEventListeners();
			shop.exit();
			super.exit(callback);
		}
	}
}

