package core.deathLine {
	import core.hud.components.Line;
	import core.scene.Game;
	import flash.geom.Point;
	
	public class DeathLine extends Line {
		private var g:Game;
		
		public var nextDistanceCalculation:Number = -1;
		
		private var distanceToCamera:Number = 0;
		
		public var id:String = "";
		
		public function DeathLine(g:Game, color:uint = 16777215, alpha:Number = 1) {
			super("line2");
			init("line2",6,color,alpha,true);
			this.g = g;
			this.visible = false;
		}
		
		public function update() : void {
			if(nextDistanceCalculation <= 0) {
				updateIsNear();
			} else {
				nextDistanceCalculation -= 33;
			}
		}
		
		public function updateIsNear() : void {
			if(g.me.ship == null) {
				return;
			}
			var _local2:Point = g.camera.getCameraCenter();
			var _local1:Number = x - _local2.x;
			var _local4:Number = y - _local2.y;
			var _local6:Number = toX - _local2.x;
			var _local5:Number = toY - _local2.y;
			var _local7:Number = g.stage.stageWidth;
			distanceToCamera = Math.sqrt(Math.min(_local1 * _local1 + _local4 * _local4,_local6 * _local6 + _local5 * _local5));
			var _local3:Number = distanceToCamera - _local7;
			nextDistanceCalculation = _local3 / (10 * 60) * 1000;
			visible = distanceToCamera < _local7;
		}
		
		public function lineIntersection(x3:Number, y3:Number, x4:Number, y4:Number, targetRadius:Number) : Boolean {
			var _local17:Number = toY - y;
			var _local15:Number = x - toX;
			var _local19:Number = y4 - y3;
			var _local18:Number = x3 - x4;
			var _local13:Number = _local17 * _local18 - _local19 * _local15;
			if(_local13 == 0) {
				return false;
			}
			var _local14:Number = _local17 * x + _local15 * y;
			var _local16:Number = _local19 * x3 + _local18 * y3;
			var _local22:Number = (_local18 * _local14 - _local15 * _local16) / _local13;
			var _local7:Number = (_local17 * _local16 - _local19 * _local14) / _local13;
			var _local21:Number = Math.min(x,toX);
			var _local11:Number = Math.max(x,toX);
			var _local20:Number = Math.min(y,toY);
			var _local9:Number = Math.max(y,toY);
			if(_local22 < _local21 - targetRadius || _local22 > _local11 + targetRadius || _local7 < _local20 - targetRadius || _local7 > _local9 + targetRadius) {
				return false;
			}
			var _local12:Number = Math.min(x3,x4);
			var _local8:Number = Math.max(x3,x4);
			var _local10:Number = Math.min(y3,y4);
			var _local6:Number = Math.max(y3,y4);
			if(_local22 < _local12 - targetRadius || _local22 > _local8 + targetRadius || _local7 < _local10 - targetRadius || _local7 > _local6 + targetRadius) {
				return false;
			}
			return true;
		}
		
		public function lineIntersection2(px:Number, py:Number, x4:Number, y4:Number, targetRadius:Number) : Boolean {
			var _local15:Number = Math.min(x,toX);
			var _local7:Number = Math.max(x,toX);
			var _local13:Number = Math.min(y,toY);
			var _local6:Number = Math.max(y,toY);
			if(px < _local15 - targetRadius || px > _local7 + targetRadius || py < _local13 - targetRadius || py > _local6 + targetRadius) {
				return false;
			}
			var _local10:Number = toX - x;
			var _local11:Number = toY - y;
			var _local14:Number = Math.sqrt(_local10 * _local10 + _local11 * _local11);
			_local10 /= _local14;
			_local11 /= _local14;
			var _local8:Number = x - px;
			var _local12:Number = y - py;
			var _local16:Number = _local8 * _local10 + _local12 * _local11;
			var _local9:Number = Math.sqrt(Math.pow(_local8 - _local16 * _local10,2) + Math.pow(_local12 - _local16 * _local11,2));
			return _local9 < targetRadius;
		}
	}
}

