package core.hud.components.hangar
{
	import com.greensock.TweenMax;
	import core.hud.components.Text;
	import starling.display.Quad;
	import starling.display.Sprite;

	public class SkinItemBaseStats extends Sprite
	{
		private var skinObj:Object;
		private var tweenDelay:Number = 0;
		public function SkinItemBaseStats(param1:Object)
		{
			super();
			this.skinObj = param1;
			addStat("statHealth", "Health", 23);
			addStat("statArmor", "Armor", 43);
			addStat("statShield", "Shield", 63);
			addStat("statShieldRegen", "S. regen", 83);
		}

		private function addStat(param1:String, param2:String, param3:int):void
		{
			var _loc7_:int = 0;
			var _loc5_:Quad = null;
			var _loc4_:Text = new Text(0, param3, true, "Verdana");
			_loc4_.text = param2 + ":";
			_loc4_.size = 13;
			_loc4_.color = 16777215;
			addChild(_loc4_);
			var _loc6_:int = int(skinObj[param1]);
			_loc7_ = 0;
			while (_loc7_ < 10)
			{
				_loc5_ = new Quad(8, 8, 111062);
				_loc5_.alpha = 0.3;
				if (_loc6_ > _loc7_)
				{
					TweenMax.to(_loc5_, 0.2, {
								"alpha": 1,
								"delay": tweenDelay
							});
					tweenDelay += 0.05;
				}
				_loc5_.y = param3 + 8;
				_loc5_.x = 84 + _loc7_ * 11;
				addChild(_loc5_);
				_loc7_++;
			}
		}
	}
}
