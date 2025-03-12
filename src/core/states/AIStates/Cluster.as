package core.states.AIStates
{
	import core.projectile.Projectile;
	import core.projectile.ProjectileFactory;
	import core.scene.Game;
	import core.states.IState;
	import generics.Util;
	
	public class Cluster extends ProjectileBullet implements IState
	{
		protected var newProjectile:Projectile;
		
		private var clusterAngle:Number;
		
		public function Cluster(param1:Game, param2:Projectile)
		{
			super(param1, param2);
		}
		
		override public function enter():void
		{
			clusterAngle = Util.degreesToRadians(p.clusterAngle);
			super.enter();
		}
		
		override public function execute():void
		{
			var _loc4_:Number = NaN;
			var _loc5_:int = 0;
			var _loc1_:Projectile = null;
			var _loc3_:Number = NaN;
			var _loc2_:Number = 33;
			if (p.ttl - 1 < _loc2_ && p.clusterNrOfSplits > 0)
			{
				_loc4_ = clusterAngle;
				if (p.clusterNrOfProjectiles > 1)
				{
					_loc4_ = Math.floor(p.clusterNrOfProjectiles / 2) * clusterAngle;
					if (p.clusterNrOfProjectiles % 2 == 0)
					{
						_loc4_ -= clusterAngle / 2;
					}
				}
				_loc5_ = 0;
				while (_loc5_ < p.clusterNrOfProjectiles)
				{
					_loc1_ = ProjectileFactory.create(p.clusterProjectile, m, p.unit, p.weapon);
					if (_loc1_ == null)
					{
						return;
					}
					_loc1_.course.copy(p.course);
					_loc1_.course.rotation -= _loc4_;
					_loc3_ = p.course.speed.length;
					_loc1_.course.speed.x = Math.cos(_loc1_.course.rotation) * _loc3_;
					_loc1_.course.speed.y = Math.sin(_loc1_.course.rotation) * _loc3_;
					_loc1_.clusterNrOfSplits = p.clusterNrOfSplits - 1;
					m.projectileManager.activateProjectile(_loc1_);
					if (p.clusterNrOfProjectiles > 4)
					{
						_loc1_.ttl = 0.6 * p.ttlMax;
					}
					else
					{
						_loc1_.ttl = p.ttlMax;
					}
					_loc1_.numberOfHits = 1;
					_loc4_ -= clusterAngle;
					_loc5_++;
				}
			}
			super.execute();
		}
	}
}
