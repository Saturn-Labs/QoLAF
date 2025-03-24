package core.states.AIStates {
	import core.projectile.Projectile;
	import core.projectile.ProjectileFactory;
	import core.scene.Game;
	import core.states.IState;
	import generics.Util;
	
	public class Cluster extends ProjectileBullet implements IState {
		protected var newProjectile:Projectile;
		
		private var clusterAngle:Number;
		
		public function Cluster(g:Game, p:Projectile) {
			super(g,p);
		}
		
		override public function enter() : void {
			clusterAngle = Util.degreesToRadians(p.clusterAngle);
			super.enter();
		}
		
		override public function execute() : void {
			var _local3:Number = NaN;
			var _local4:int = 0;
			var _local2:Projectile = null;
			var _local5:Number = NaN;
			var _local1:Number = 33;
			if(p.ttl - 1 < _local1 && p.clusterNrOfSplits > 0) {
				_local3 = clusterAngle;
				if(p.clusterNrOfProjectiles > 1) {
					_local3 = Math.floor(p.clusterNrOfProjectiles / 2) * clusterAngle;
					if(p.clusterNrOfProjectiles % 2 == 0) {
						_local3 -= clusterAngle / 2;
					}
				}
				_local4 = 0;
				while(_local4 < p.clusterNrOfProjectiles) {
					_local2 = ProjectileFactory.create(p.clusterProjectile,m,p.unit,p.weapon);
					if(_local2 == null) {
						return;
					}
					_local2.course.copy(p.course);
					_local2.course.rotation -= _local3;
					_local5 = p.course.speed.length;
					_local2.course.speed.x = Math.cos(_local2.course.rotation) * _local5;
					_local2.course.speed.y = Math.sin(_local2.course.rotation) * _local5;
					_local2.clusterNrOfSplits = p.clusterNrOfSplits - 1;
					m.projectileManager.activateProjectile(_local2);
					if(p.clusterNrOfProjectiles > 4) {
						_local2.ttl = 0.6 * p.ttlMax;
					} else {
						_local2.ttl = p.ttlMax;
					}
					_local2.numberOfHits = 1;
					_local3 -= clusterAngle;
					_local4++;
				}
			}
			super.execute();
		}
	}
}

