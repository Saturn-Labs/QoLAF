package core.hud.components.radar
{
	import core.GameObject;
	import core.scene.Game;
	import core.solarSystem.Body;

	public class Compas
	{
		public static const WIDTH:Number = 700;

		public static const HEIGHT:Number = 450;

		private var arrows:Vector.<TargetArrow>;

		private var g:Game;
		public function Compas(param1:Game)
		{
			arrows = new Vector.<TargetArrow>();
			this.g = param1;
			super();
		}

		public function update():void
		{
			if (g.me.ship == null)
			{
				return;
			}
			for each (var _loc1_:* in arrows)
			{
				_loc1_.update();
			}
		}

		public function removeArrow(param1:GameObject):void
		{
			var _loc3_:int = 0;
			var _loc2_:TargetArrow = null;
			_loc3_ = arrows.length - 1;
			while (_loc3_ > -1)
			{
				_loc2_ = arrows[_loc3_];
				if (_loc2_.target == param1)
				{
					arrows.splice(_loc3_, 1);
					g.removeChildFromCanvas(_loc2_, true);
				}
				_loc3_--;
			}
		}

		public function addArrow(param1:GameObject, param2:uint):TargetArrow
		{
			var _loc3_:TargetArrow = new TargetArrow(g, param1, param2);
			arrows.push(_loc3_);
			g.addChildToCanvas(_loc3_);
			return _loc3_;
		}

		public function hasTarget(param1:GameObject):Boolean
		{
			for each (var _loc2_:* in arrows)
			{
				if (_loc2_.target == param1)
				{
					return true;
				}
			}
			return false;
		}

		public function addHintArrow(param1:String):void
		{
			clear();
			var _loc3_:Vector.<Body> = g.bodyManager.bodies;
			for each (var _loc2_:* in _loc3_)
			{
				if (_loc2_.type == param1)
				{
					addArrow(_loc2_, 8978312).activate();
				}
			}
		}

		public function addHintArrowByKey(param1:String):void
		{
			clear();
			var _loc3_:Vector.<Body> = g.bodyManager.bodies;
			for each (var _loc2_:* in _loc3_)
			{
				if (_loc2_.key == param1)
				{
					addArrow(_loc2_, 8978312).activate();
				}
			}
		}

		public function clearType(param1:String):void
		{
			var _loc2_:Body = null;
			var _loc4_:int = 0;
			var _loc3_:TargetArrow = null;
			_loc4_ = arrows.length - 1;
			while (_loc4_ > -1)
			{
				_loc3_ = arrows[_loc4_];
				if (_loc3_.target is Body)
				{
					_loc2_ = _loc3_.target as Body;
					if (_loc2_.type == param1)
					{
						g.removeChildFromCanvas(_loc3_);
						arrows.splice(_loc4_, 1);
					}
				}
				_loc4_--;
			}
		}

		public function clear():void
		{
			for each (var _loc1_:* in arrows)
			{
				_loc1_.deactivate();
				g.removeChildFromCanvas(_loc1_);
			}
			arrows.length = 0;
		}
	}
}
