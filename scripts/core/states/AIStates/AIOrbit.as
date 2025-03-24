package core.states.AIStates {
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.states.IState;
	import core.states.StateMachine;
	import flash.geom.Point;
	import generics.Util;
	import movement.Heading;
	
	public class AIOrbit implements IState {
		private static const HALF_PI:Number = 1.5707963267948966;
		
		private static const TICK_LENGTH_MS:Number = 0.033;
		
		private static const TICK_LENGTH_W:Number = 30.303030303030305;
		
		private var g:Game;
		
		private var s:EnemyShip;
		
		private var sm:StateMachine;
		
		private var lastCourse:Heading;
		
		private var error:Point;
		
		private var errorAngle:Number;
		
		private var convergeTime:Number = 1000;
		
		private var convergeStartTime:Number;
		
		public function AIOrbit(g:Game, s:EnemyShip, useConverger:Boolean = false) {
			super();
			this.g = g;
			this.s = s;
			error = new Point();
			errorAngle = 0;
			if(useConverger) {
				lastCourse = s.course.clone();
			} else {
				lastCourse = null;
			}
		}
		
		public function enter() : void {
			s.target = null;
			s.setAngleTargetPos(null);
			s.stopShooting();
			s.accelerate = true;
			s.forceupdate = true;
		}
		
		public function execute() : void {
			var _local6:Number = NaN;
			var _local2:Number = NaN;
			var _local8:Point = null;
			if(s.spawner == null || s.spawner.parentObj == null) {
				return;
			}
			if(!s.isAddedToCanvas && !s.forceupdate && !s.spawner.isBossUnit) {
				return;
			}
			s.forceupdate = false;
			var _local3:Point = s.spawner.parentObj.pos;
			var _local1:Number = g.time;
			var _local4:Number = s.orbitAngle + 0.001 * s.angleVelocity * 33 * (_local1 - s.orbitStartTime);
			var _local5:Number = s.orbitRadius * s.ellipseFactor * Math.cos(_local4);
			var _local9:Number = s.orbitRadius * Math.sin(_local4);
			var _local12:Number = s.ellipseAlpha;
			var _local7:Number = _local5 * Math.cos(_local12) - _local9 * Math.sin(_local12) + _local3.x;
			var _local10:Number = _local5 * Math.sin(_local12) + _local9 * Math.cos(_local12) + _local3.y;
			var _local11:Number = 0.5 * (1 - s.orbitRadius / 500);
			if(_local11 > 0.5) {
				_local11 = 0.5;
			} else if(_local11 < 0) {
				_local11 = 0;
			}
			_local6 = -Math.atan2(_local7 - _local3.x,_local10 - _local3.y) - 1.5707963267948966 - Util.sign(s.angleVelocity) * (1.5707963267948966 - _local11);
			if(!s.aiCloak) {
				if(lastCourse != null) {
					error.x = lastCourse.pos.x - _local7;
					error.y = lastCourse.pos.y - _local10;
					errorAngle = Util.angleDifference(lastCourse.rotation,_local6);
					convergeStartTime = _local1;
					lastCourse = null;
				}
				if(error.x != 0 || error.y != 0) {
					_local2 = (convergeTime - (_local1 - convergeStartTime)) / convergeTime;
					if(_local2 > 0) {
						_local7 += _local2 * error.x;
						_local7 = _local7 + _local2 * error.y;
						_local6 += _local2 * errorAngle;
					} else {
						error.x = 0;
						error.y = 0;
					}
				}
				_local8 = s.pos;
				_local8.x = _local7;
				_local8.y = _local10;
			}
			s.rotation = _local6;
			s.engine.update();
			s.updateWeapons();
			s.updateHealthBars();
			s.regenerateShield();
			s.regenerateHP();
		}
		
		public function exit() : void {
			var _local1:Heading = null;
			if(!s.aiCloak) {
				_local1 = new Heading();
				_local1.rotation = s.rotation;
				_local1.pos = s.pos;
				_local1.speed = s.calculateOrbitSpeed();
				_local1.time = g.time;
				s.course = _local1;
			}
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AIOrbit";
		}
	}
}

