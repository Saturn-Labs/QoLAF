package core.states.gameStates {
	import core.credits.CreditManager;
	import core.hud.components.ShopItemBar;
	import core.hud.components.Text;
	import core.hud.components.cargo.Cargo;
	import core.scene.Game;
	import core.solarSystem.Body;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class LandedWeaponFactory extends LandedState {
		private var shopItemBars:Vector.<ShopItemBar> = new Vector.<ShopItemBar>();
		
		private var myCargo:Cargo;
		
		private var container:ScrollContainer;
		
		private var infoContainer:Sprite = new Sprite();
		
		private var hasBought:Boolean = false;
		
		private var fluxCost:int;
		
		public function LandedWeaponFactory(g:Game, body:Body, startMusic:Boolean = true) {
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
			_local2.text = Localize.t("Produce a weapon with minerals or Flux.");
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
			var _local4:int = 0;
			var _local2:Object = null;
			var _local1:String = null;
			var _local6:String = null;
			var _local3:ShopItemBar = null;
			var _local7:Array = body.obj.shopItems;
			if(_local7 == null || _local7.length == 0) {
				g.showErrorDialog(Localize.t("This weapon factory is not operational."));
				return;
			}
			var _local5:int = 0;
			_local4 = 0;
			while(_local4 < _local7.length) {
				_local2 = _local7[_local4];
				_local1 = _local2.item;
				_local6 = _local2.table;
				if(_local2.available) {
					_local3 = new ShopItemBar(g,infoContainer,_local2,fluxCost);
					_local3.x = 0;
					_local3.y = 60 * _local5;
					_local3.addEventListener("select",onSelect);
					_local3.addEventListener("bought",bought);
					shopItemBars.push(_local3);
					container.addChild(_local3);
					_local5++;
				}
				_local4++;
			}
			loadCompleted();
			g.tutorial.showShopAdvice();
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

