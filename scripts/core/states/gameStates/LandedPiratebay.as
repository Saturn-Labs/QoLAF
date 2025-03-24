package core.states.gameStates {
	import core.credits.CreditManager;
	import core.hud.components.ShopItemBar;
	import core.hud.components.Text;
	import core.hud.components.cargo.Cargo;
	import core.player.FleetObj;
	import core.scene.Game;
	import core.solarSystem.Body;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class LandedPiratebay extends LandedState {
		private var shopItemBars:Vector.<ShopItemBar> = new Vector.<ShopItemBar>();
		
		private var myCargo:Cargo;
		
		private var container:ScrollContainer;
		
		private var infoContainer:Sprite = new Sprite();
		
		private var hasBought:Boolean = false;
		
		private var fluxCost:int;
		
		public function LandedPiratebay(g:Game, body:Body, startMusic:Boolean = true) {
			super(g,body,body.name);
			fluxCost = CreditManager.getCostWeaponFactory(body.obj.payVaultItem);
			myCargo = g.myCargo;
		}
		
		override public function enter() : void {
			super.enter();
			container = new ScrollContainer();
			container.width = 640;
			container.height = 400;
			container.x = 60;
			container.y = 140;
			addChild(container);
			infoContainer.x = 380;
			infoContainer.y = 140;
			addChild(infoContainer);
			var _local1:Text = new Text();
			_local1.text = body.name;
			_local1.size = 26;
			_local1.x = 60;
			_local1.y = 50;
			addChild(_local1);
			var _local2:Text = new Text();
			_local2.text = Localize.t("Copy one of your weapons with minerals or Flux.");
			_local2.color = 0xaaaaaa;
			_local2.x = 60;
			_local2.y = _local1.y + _local1.height + 10;
			addChild(_local2);
			cargoRecieved();
		}
		
		override public function execute() : void {
			super.execute();
		}
		
		private function cargoRecieved() : void {
			var _local3:int = 0;
			var _local1:Object = null;
			var _local2:ShopItemBar = null;
			var _local5:Array = body.obj.shopItems;
			if(g.me.fleet.length == 1) {
				g.showErrorDialog(Localize.t("You need more than one ship and multiple weapons to use the piratebay."));
				loadCompleted();
				return;
			}
			if(_local5 == null || _local5.length == 0) {
				g.showErrorDialog(Localize.t("This piratebay is of no use to you."));
				loadCompleted();
				return;
			}
			var _local4:int = 0;
			_local3 = 0;
			while(_local3 < _local5.length) {
				_local1 = _local5[_local3];
				if(hasWeaponInFleet(_local1.item)) {
					if(_local1.available) {
						_local2 = new ShopItemBar(g,infoContainer,_local1,fluxCost);
						_local2.x = 0;
						_local2.y = 60 * _local4;
						_local2.addEventListener("select",onSelect);
						_local2.addEventListener("bought",bought);
						shopItemBars.push(_local2);
						container.addChild(_local2);
						_local4++;
					}
				}
				_local3++;
			}
			loadCompleted();
		}
		
		private function hasWeaponInFleet(weaponKey:String) : Boolean {
			for each(var _local3 in g.me.fleet) {
				for each(var _local2 in _local3.weapons) {
					if(_local2.weapon == weaponKey) {
						return true;
					}
				}
			}
			return false;
		}
		
		private function onSelect(e:TouchEvent) : void {
			var _local2:ShopItemBar = e.target as ShopItemBar;
			for each(var _local3 in shopItemBars) {
				if(_local3 != _local2) {
					_local3.deselect();
				}
			}
		}
		
		private function bought(e:Event) : void {
			for each(var _local2 in shopItemBars) {
				_local2.update();
			}
			hasBought = true;
		}
		
		override public function exit(callback:Function) : void {
			if(hasBought) {
				g.tutorial.showChangeWeapon();
			}
			for each(var _local2 in shopItemBars) {
				_local2.removeEventListener("bought",bought);
				_local2.removeEventListener("select",onSelect);
			}
			super.exit(callback);
		}
	}
}

