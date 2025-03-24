package core.states.AIStates {
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.Ship;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	
	public class MissileStuck implements IState {
		private var m:Game;
		
		private var p:Projectile;
		
		private var sm:StateMachine;
		
		private var isEnemy:Boolean;
		
		private var stuckShip:Ship = null;
		
		private var stuckUnit:Unit = null;
		
		private var stuckOffset:Point;
		
		private var stuckAngle:Number;
		
		private var startAngle:Number;
		
		private var pos:Point;
		
		public function MissileStuck(m:Game, p:Projectile) {
			var _local3:Number = NaN;
			super();
			this.m = m;
			this.p = p;
			pos = p.course.pos;
			stuckUnit = p.target;
			stuckAngle = stuckUnit.rotation;
			var _local4:Point = new Point(pos.x - stuckUnit.pos.x,pos.y - stuckUnit.pos.y);
			var _local5:Number = Number(_local4.length.valueOf());
			if(_local5 > stuckUnit.radius * 0.8) {
				stuckOffset = new Point(stuckUnit.radius * 0.8 * _local4.x / _local5,stuckUnit.radius * 0.8 * _local4.y / _local5);
			} else {
				stuckOffset = _local4;
			}
			startAngle = p.course.rotation;
			p.course.rotation = startAngle;
			p.course.speed.x = 0;
			p.course.speed.y = 0;
			p.acceleration = 0;
			_local4 = pos.clone();
			_local3 = Util.clampRadians(stuckUnit.rotation - stuckAngle);
			p.course.rotation = startAngle + _local3;
			pos.x = stuckUnit.pos.x + Math.cos(_local3) * stuckOffset.x - Math.sin(_local3) * stuckOffset.y;
			pos.y = stuckUnit.pos.y + Math.sin(_local3) * stuckOffset.x + Math.cos(_local3) * stuckOffset.y;
			p.error = new Point(_local4.x - pos.x,_local4.y - pos.y);
			p.convergenceCounter = 0;
			p.convergenceTime = 1000 / 33;
			if(p.isHeal || p.unit.factions.length > 0) {
				this.isEnemy = false;
			} else {
				this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
			}
		}
		
		public function enter() : void {
			p.ttl = p.ttlMax + p.aiStuckDuration * 1000;
		}
		
		public function execute() : void {
			var _local2:Number = NaN;
			var _local1:Number = NaN;
			var _local3:Number = NaN;
			if(!p.aiStuck) {
				p.target = null;
				p.ttl = p.ttlMax;
				p.numberOfHits = 1;
				p.acceleration = p.weapon.acceleration;
				sm.changeState(new Missile(m,p));
				return;
			}
			if(stuckUnit == null || !stuckUnit.alive) {
				return;
			}
			_local2 = Util.clampRadians(stuckUnit.rotation - stuckAngle);
			p.course.rotation = startAngle + _local2;
			pos.x = stuckUnit.pos.x + Math.cos(_local2) * stuckOffset.x - Math.sin(_local2) * stuckOffset.y;
			pos.y = stuckUnit.pos.y + Math.sin(_local2) * stuckOffset.x + Math.cos(_local2) * stuckOffset.y;
			_local1 = 33;
			_local3 = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
			if(_local3 <= 0) {
				p.error = null;
			}
			if(p.error != null) {
				p.convergenceCounter++;
				_local3 = (p.convergenceTime - p.convergenceCounter) / p.convergenceTime;
				pos.x += p.error.x * _local3;
				pos.y += p.error.y * _local3;
			}
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "MissileStuck";
		}
	}
}

