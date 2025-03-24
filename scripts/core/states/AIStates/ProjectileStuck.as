package core.states.AIStates {
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.Ship;
	import core.states.IState;
	import core.states.StateMachine;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	
	public class ProjectileStuck implements IState {
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
		
		public function ProjectileStuck(m:Game, p:Projectile, target:Unit) {
			super();
			this.m = m;
			this.p = p;
			pos = p.course.pos;
			stuckUnit = target;
			p.target = target;
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
			if(p.isHeal || p.unit.factions.length > 0) {
				this.isEnemy = false;
			} else {
				this.isEnemy = p.unit.type == "enemyShip" || p.unit.type == "turret";
			}
		}
		
		public function enter() : void {
		}
		
		public function execute() : void {
			var _local1:Number = NaN;
			if(!stuckUnit.alive) {
				p.destroy();
			}
			_local1 = Util.clampRadians(stuckUnit.rotation - stuckAngle);
			p.course.rotation = startAngle + _local1;
			pos.x = stuckUnit.pos.x + Math.cos(_local1) * stuckOffset.x - Math.sin(_local1) * stuckOffset.y;
			pos.y = stuckUnit.pos.y + Math.sin(_local1) * stuckOffset.x + Math.cos(_local1) * stuckOffset.y;
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "ProjectileStuck";
		}
	}
}

