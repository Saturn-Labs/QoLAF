package core.boss {
	import com.greensock.TweenMax;
	import core.GameObject;
	import core.particle.Emitter;
	import core.scene.Game;
	import core.unit.Unit;
	import flash.geom.Point;
	
	public class BossComponent extends Unit {
		public var offset:Point;
		
		public var imageOffset:Point;
		
		public var imageScale:Number;
		
		public var imageAngle:Number;
		
		public var imageRotationSpeed:Number;
		
		public var imageRotationSpeedCurrent:Number = 0;
		
		public var imageRotationMax:Number;
		
		public var imageRotationMin:Number;
		
		public var imagePivotPoint:Point;
		
		private var currentAngleOffset:Number = 0;
		
		public var effect:Vector.<Emitter> = new Vector.<Emitter>();
		
		public var effectX:int = 0;
		
		public var effectY:int = 0;
		
		public var effectTarget:GameObject = new GameObject();
		
		public function BossComponent(g:Game) {
			triggers = new Vector.<Trigger>();
			dotTimers = new Vector.<TweenMax>();
			super(g);
		}
		
		override public function update() : void {
			if(!active || !alive) {
				return;
			}
			_pos.x = offset.x * Math.cos(parentObj.rotation) - offset.y * Math.sin(parentObj.rotation) + parentObj.x;
			_pos.y = offset.x * Math.sin(parentObj.rotation) + offset.y * Math.cos(parentObj.rotation) + parentObj.y;
			if(imageRotationSpeedCurrent < imageRotationSpeed) {
				imageRotationSpeedCurrent += 0.05 * imageRotationSpeed;
			} else {
				imageRotationSpeedCurrent -= 0.05 * imageRotationSpeed;
			}
			currentAngleOffset += imageRotationSpeedCurrent * 33 / 1000;
			_rotation = parentObj.rotation + currentAngleOffset + imageAngle;
			effectTarget.rotation = _rotation;
			effectTarget.x = effectX * Math.cos(_rotation) - effectY * Math.sin(_rotation) + _pos.x;
			effectTarget.y = effectX * Math.sin(_rotation) + effectY * Math.cos(_rotation) + _pos.y;
			if(parentObj is Boss) {
				for each(var _local1 in triggers) {
					_local1.tryActivateTrigger(this,Boss(parentObj));
				}
			}
			super.update();
		}
		
		override public function destroy(explode:Boolean = true) : void {
			for each(var _local2 in effect) {
				_local2.killEmitter();
			}
			super.destroy(explode);
		}
		
		override public function reset() : void {
			effect.splice(0,effect.length);
			g.emitterManager.clean(effectTarget);
			effectX = 0;
			effectY = 0;
			super.reset();
		}
	}
}

