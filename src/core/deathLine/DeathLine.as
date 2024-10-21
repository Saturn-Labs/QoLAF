package core.deathLine
{
	import core.hud.components.Line;
	import core.scene.Game;
	import flash.geom.Point;
	
	public class DeathLine extends Line
	{
		private var g:Game;
		
		public var nextDistanceCalculation:Number = -1;
		
		private var distanceToCamera:Number = 0;
		
		public var id:String = "";
		
		public function DeathLine(param1:Game, param2:uint = 16777215, param3:Number = 1)
		{
			super("line2");
			init("line2", 6, param2, param3, true);
			this.g = param1;
			this.visible = false;
		}
		
		public function update():void
		{
			if (nextDistanceCalculation <= 0)
			{
				updateIsNear();
			}
			else
			{
				nextDistanceCalculation -= 33;
			}
		}
		
		public function updateIsNear():void
		{
			if (g.me.ship == null)
			{
				return;
			}
			var _loc5_:Point = g.camera.getCameraCenter();
			var _loc6_:Number = x - _loc5_.x;
			var _loc7_:Number = y - _loc5_.y;
			var _loc4_:Number = toX - _loc5_.x;
			var _loc2_:Number = toY - _loc5_.y;
			var _loc3_:Number = g.stage.stageWidth;
			distanceToCamera = Math.sqrt(Math.min(_loc6_ * _loc6_ + _loc7_ * _loc7_, _loc4_ * _loc4_ + _loc2_ * _loc2_));
			var _loc1_:Number = distanceToCamera - _loc3_;
			nextDistanceCalculation = _loc1_ / 600 * 1000;
			visible = distanceToCamera < _loc3_;
		}
		
		public function lineIntersection(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number):Boolean
		{
			var _loc7_:Number = toY - y;
			var _loc20_:Number = x - toX;
			var _loc6_:Number = param4 - param2;
			var _loc9_:Number = param1 - param3;
			var _loc10_:Number = _loc7_ * _loc9_ - _loc6_ * _loc20_;
			if (_loc10_ == 0)
			{
				return false;
			}
			var _loc18_:Number = _loc7_ * x + _loc20_ * y;
			var _loc19_:Number = _loc6_ * param1 + _loc9_ * param2;
			var _loc11_:Number = (_loc9_ * _loc18_ - _loc20_ * _loc19_) / _loc10_;
			var _loc8_:Number = (_loc7_ * _loc19_ - _loc6_ * _loc18_) / _loc10_;
			var _loc14_:Number = Math.min(x, toX);
			var _loc13_:Number = Math.max(x, toX);
			var _loc15_:Number = Math.min(y, toY);
			var _loc12_:Number = Math.max(y, toY);
			if (_loc11_ < _loc14_ - param5 || _loc11_ > _loc13_ + param5 || _loc8_ < _loc15_ - param5 || _loc8_ > _loc12_ + param5)
			{
				return false;
			}
			var _loc22_:Number = Math.min(param1, param3);
			var _loc17_:Number = Math.max(param1, param3);
			var _loc21_:Number = Math.min(param2, param4);
			var _loc16_:Number = Math.max(param2, param4);
			if (_loc11_ < _loc22_ - param5 || _loc11_ > _loc17_ + param5 || _loc8_ < _loc21_ - param5 || _loc8_ > _loc16_ + param5)
			{
				return false;
			}
			return true;
		}
		
		public function lineIntersection2(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number):Boolean
		{
			var _loc13_:Number = Math.min(x, toX);
			var _loc9_:Number = Math.max(x, toX);
			var _loc14_:Number = Math.min(y, toY);
			var _loc8_:Number = Math.max(y, toY);
			if (param1 < _loc13_ - param5 || param1 > _loc9_ + param5 || param2 < _loc14_ - param5 || param2 > _loc8_ + param5)
			{
				return false;
			}
			var _loc12_:Number = toX - x;
			var _loc11_:Number = toY - y;
			var _loc10_:Number = Math.sqrt(_loc12_ * _loc12_ + _loc11_ * _loc11_);
			_loc12_ /= _loc10_;
			_loc11_ /= _loc10_;
			var _loc6_:Number = x - param1;
			var _loc7_:Number = y - param2;
			var _loc15_:Number = _loc6_ * _loc12_ + _loc7_ * _loc11_;
			var _loc16_:Number = Math.sqrt(Math.pow(_loc6_ - _loc15_ * _loc12_, 2) + Math.pow(_loc7_ - _loc15_ * _loc11_, 2));
			return _loc16_ < param5;
		}
	}
}
