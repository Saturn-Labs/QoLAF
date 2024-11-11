package startSetup
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import core.hud.components.Text;
	import starling.display.Quad;
	import starling.display.Sprite;

	public class StartShipBaseStats extends Sprite
	{
		private var skinObj:Object;
		private var speed:int;
		private var tweenDelay:Number = 0.7;
		public function StartShipBaseStats(param1:Object, param2:int)
		{
			super();
			this.skinObj = param1;
			this.speed = param2;
			var _loc4_:int = 7;
			var _loc3_:int = 27;
			addStat("statHealth", "Health", _loc4_);
			_loc4_ += _loc3_;
			addStat("statArmor", "Armor", _loc4_);
			_loc4_ += _loc3_;
			addStat("statShield", "Shield", _loc4_);
			_loc4_ += _loc3_;
			addStat("statShieldRegen", "Speed", _loc4_);
			_loc4_ += _loc3_;
			addWeapon(_loc4_);
		}

		private function addWeapon(param1:int):void
		{
			var _loc5_:int = 0;
			var _loc3_:Object = null;
			var _loc4_:Text = null;
			var _loc2_:Text = null;
			_loc5_ = 0;
			while (_loc5_ < skinObj.upgrades.length - 1)
			{
				_loc3_ = skinObj.upgrades[_loc5_];
				if (_loc3_.table == "Weapons")
				{
					_loc4_ = new Text();
					_loc4_.y = param1;
					_loc4_.text = "WEAPON:";
					_loc4_.size = 12;
					_loc4_.color = 16689475;
					addChild(_loc4_);
					_loc2_ = new Text();
					_loc2_.y = param1;
					_loc2_.x = 114;
					_loc2_.text = _loc3_.name.toUpperCase();
					_loc2_.size = 12;
					_loc2_.color = 54271;
					addChild(_loc2_);
					return;
				}
				_loc5_++;
			}
		}

		private function addStat(param1:String, param2:String, param3:int):void
		{
			var _loc6_:int = 0;
			var _loc7_:int = 0;
			var _loc5_:Quad = null;
			var _loc4_:Text = new Text();
			_loc4_.y = param3;
			_loc4_.text = param2.toUpperCase() + ":";
			_loc4_.size = 12;
			_loc4_.color = 16689475;
			addChild(_loc4_);
			if (param2 == "Speed")
			{
				_loc6_ = speed;
			}
			else
			{
				_loc6_ = int(skinObj[param1]);
			}
			_loc7_ = 0;
			while (_loc7_ < 10)
			{
				_loc5_ = new Quad(12, 12, 54271);
				_loc5_.alpha = 0.2;
				if (_loc6_ > _loc7_)
				{
					TweenMax.to(_loc5_, 1, {
								"alpha": 0.7,
								"delay": tweenDelay,
								"ease": Elastic.easeInOut
							});
					tweenDelay += 0.07;
				}
				_loc5_.y = param3 + 3;
				_loc5_.x = 114 + _loc7_ * 16;
				addChild(_loc5_);
				_loc7_++;
			}
		}
	}
}
