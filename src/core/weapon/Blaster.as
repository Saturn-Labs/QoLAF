package core.weapon
{
	import core.projectile.Projectile;
	import core.projectile.ProjectileFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import flash.geom.Point;
	
	public class Blaster extends Weapon
	{
		private var nextShot:Number;
		
		public function Blaster(param1:Game)
		{
			super(param1);
		}
		
		override protected function shoot():void
		{
			var _loc2_:PlayerShip = null;
			var _loc3_:Number = NaN;
			var _loc1_:Number = Number(g.time.valueOf());
			while (fireNextTime <= _loc1_)
			{
				if (unit is PlayerShip)
				{
					_loc2_ = unit as PlayerShip;
					if (!_loc2_.weaponHeat.canFire(heatCost))
					{
						fireNextTime += reloadTime;
						return;
					}
				}
				if (_loc1_ - lastFire > reloadTime)
				{
					burstCurrent = 0;
				}
				burstCurrent++;
				if (burstCurrent < burst)
				{
					_loc3_ = burstDelay;
				}
				else
				{
					_loc3_ = reloadTime;
					burstCurrent = 0;
				}
				if (burstCurrent > 0)
				{
					fireNextTime = _loc1_ + 1;
				}
				else if (fireNextTime == 0 || lastFire == 0)
				{
					fireNextTime = _loc1_ + _loc3_ - 33;
				}
				else
				{
					fireNextTime += _loc3_;
				}
				lastFire = _loc1_;
				playFireSound();
				if (sideShooter)
				{
					fireProjectiles(-0.5 * 3.141592653589793);
					fireProjectiles(0.5 * 3.141592653589793);
				}
				else
				{
					fireProjectiles();
				}
			}
		}
		
		private function fireProjectiles(param1:Number = 0):void
		{
			var _loc11_:int = 0;
			var _loc5_:Projectile = null;
			var _loc8_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc10_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc9_:Number = NaN;
			var _loc2_:Weapon = this;
			_loc11_ = 0;
			while (_loc11_ < multiNrOfP)
			{
				_loc5_ = ProjectileFactory.create(projectileFunction, g, unit, _loc2_);
				if (_loc5_ == null)
				{
					return;
				}
				_loc8_ = multiNrOfP;
				_loc4_ = multiOffset * (_loc11_ - 0.5 * (_loc8_ - 1)) / _loc8_ + (positionYVariance - Math.random() * positionYVariance * 2) + unit.weaponPos.y;
				_loc3_ = unit.weaponPos.x + positionOffsetX + (positionXVariance - Math.random() * positionXVariance * 2);
				_loc7_ = new Point(_loc3_, _loc4_).length;
				_loc10_ = Math.atan2(_loc4_, _loc3_);
				_loc6_ = multiAngleOffset * (_loc11_ - 0.5 * (_loc8_ - 1)) / _loc8_;
				_loc9_ = unit.rotation + _loc6_ + _loc10_ + param1;
				_loc5_.course.pos.x = unit.x + Math.cos(_loc9_) * _loc7_;
				_loc5_.course.pos.y = unit.y + Math.sin(_loc9_) * _loc7_;
				_loc5_.course.rotation = unit.rotation + _loc6_ + param1 + (angleVariance - Math.random() * angleVariance * 2);
				if (_loc5_.useShipSystem)
				{
					_loc5_.course.speed.x += Math.cos(_loc5_.course.rotation) * _loc5_.speedMax;
					_loc5_.course.speed.y += Math.sin(_loc5_.course.rotation) * _loc5_.speedMax;
				}
				else if (acceleration == 0)
				{
					_loc5_.course.speed.x = Math.cos(_loc5_.course.rotation) * _loc5_.speedMax;
					_loc5_.course.speed.y = Math.sin(_loc5_.course.rotation) * _loc5_.speedMax;
				}
				if (_loc5_.stateMachine.inState("Instant"))
				{
					_loc5_.range = range * (0.9 + 0.2 * Math.random());
				}
				g.projectileManager.activateProjectile(_loc5_);
				_loc11_++;
			}
		}
	}
}
