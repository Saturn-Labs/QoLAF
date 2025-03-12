package core.states.gameStates
{
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
	
	public class LandedWeaponFactory extends LandedState
	{
		private var shopItemBars:Vector.<ShopItemBar>;
		
		private var myCargo:Cargo;
		
		private var container:ScrollContainer;
		
		private var infoContainer:Sprite;
		
		private var hasBought:Boolean = false;
		private var fluxCost:int;
		
		public function LandedWeaponFactory(param1:Game, param2:Body, param3:Boolean = true)
		{
			shopItemBars = new Vector.<ShopItemBar>();
			infoContainer = new Sprite();
			super(param1, param2, param2.name);
			fluxCost = CreditManager.getCostWeaponFactory(param2.obj.payVaultItem);
			myCargo = param1.myCargo;
		}
		
		override public function enter():void
		{
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
			var _loc2_:Text = new Text();
			_loc2_.text = body.name;
			_loc2_.size = 26;
			_loc2_.x = 60;
			_loc2_.y = 50;
			addChild(_loc2_);
			var _loc1_:Text = new Text();
			_loc1_.text = Localize.t("Produce a weapon with minerals or Flux.");
			_loc1_.color = 11184810;
			_loc1_.x = 60;
			_loc1_.y = _loc2_.y + _loc2_.height + 10;
			addChild(_loc1_);
			cargoRecieved();
		}
		
		override public function execute():void
		{
			super.execute();
		}
		
		private function cargoRecieved():void
		{
			var _loc7_:int = 0;
			var _loc4_:Object = null;
			var _loc3_:String = null;
			var _loc5_:String = null;
			var _loc1_:ShopItemBar = null;
			var _loc2_:Array = body.obj.shopItems;
			if (_loc2_ == null || _loc2_.length == 0)
			{
				g.showErrorDialog(Localize.t("This weapon factory is not operational."));
				return;
			}
			var _loc6_:int = 0;
			_loc7_ = 0;
			while (_loc7_ < _loc2_.length)
			{
				_loc4_ = _loc2_[_loc7_];
				_loc3_ = _loc4_.item;
				_loc5_ = _loc4_.table;
				if (_loc4_.available)
				{
					_loc1_ = new ShopItemBar(g, infoContainer, _loc4_, fluxCost);
					_loc1_.x = 0;
					_loc1_.y = 60 * _loc6_;
					_loc1_.addEventListener("select", onSelect);
					_loc1_.addEventListener("bought", bought);
					shopItemBars.push(_loc1_);
					container.addChild(_loc1_);
					_loc6_++;
				}
				_loc7_++;
			}
			loadCompleted();
			g.tutorial.showShopAdvice();
		}
		
		private function onSelect(param1:TouchEvent):void
		{
			var _loc2_:ShopItemBar = param1.target as ShopItemBar;
			for each (var _loc3_:* in shopItemBars)
			{
				if (_loc3_ != _loc2_)
				{
					_loc3_.deselect();
				}
			}
		}
		
		private function bought(param1:Event):void
		{
			for each (var _loc2_:* in shopItemBars)
			{
				_loc2_.update();
			}
			hasBought = true;
		}
		
		override public function exit(param1:Function):void
		{
			if (hasBought)
			{
				g.tutorial.showChangeWeapon();
			}
			for each (var _loc2_:* in shopItemBars)
			{
				_loc2_.removeEventListener("bought", bought);
				_loc2_.removeEventListener("select", onSelect);
			}
			super.exit(param1);
		}
	}
}
