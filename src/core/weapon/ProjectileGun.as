package core.weapon
{
	import core.projectile.Projectile;
	import core.projectile.ProjectileFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.unit.Unit;
	import flash.geom.Point;
	import movement.Heading;
	
	public class ProjectileGun extends Weapon
	{
		public function ProjectileGun(param1:Game)
		{
			super(param1);
		}
		
		override protected function shoot():void
		{
			var _loc1_:PlayerShip = null;
			if (unit is PlayerShip)
			{
				if (hasChargeUp && (projectiles.length < maxProjectiles || maxProjectiles == 0))
				{
					if (unit != null && unit is PlayerShip)
					{
						_loc1_ = unit as PlayerShip;
						if (fireNextTime < g.time)
						{
							if (chargeUpTime == 0)
							{
								if (fireEffect != "")
								{
									_loc1_.startChargeUpEffect(fireEffect);
								}
								else
								{
									_loc1_.startChargeUpEffect();
								}
							}
							chargeUpTime += 33;
							if (_loc1_.player.isMe)
							{
								if (chargeUpTime < chargeUpTimeMax)
								{
									g.hud.powerBar.updateLoadBar(chargeUpTime / chargeUpTimeMax);
								}
								else
								{
									g.hud.powerBar.updateLoadBar(1);
								}
							}
							if (triggerMeleeAnimation)
							{
								(unit as PlayerShip).triggerMeleeTextures(reloadTime / 1000);
							}
						}
						else if (_loc1_.player.isMe)
						{
							g.hud.powerBar.updateLoadBar(0);
							chargeUpTime = 0;
						}
						return;
					}
				}
			}
		}
		
		public function shootSyncedProjectile(param1:int, param2:Unit, param3:Heading, param4:int = -1, param5:Number = 0, param6:Number = 0, param7:Number = 0, param8:Number = 0):void
		{
			var _loc14_:PlayerShip = null;
			var _loc19_:Number = NaN;
			var _loc10_:Number = NaN;
			var _loc18_:Number = NaN;
			if (unit == null)
			{
				return;
			}
			if (fireCallback != null && this.hasChargeUp == true && (projectiles.length + 1 < maxProjectiles || maxProjectiles == 0))
			{
				lastFire = g.time;
				fireNextTime = g.time + reloadTime;
				fireCallback();
			}
			if (unit is PlayerShip)
			{
				_loc14_ = unit as PlayerShip;
				_loc14_.weaponHeat.setHeat(param5);
				if (hasChargeUp && !_loc14_.player.isMe)
				{
					fire = false;
				}
				else if (triggerMeleeAnimation)
				{
					(unit as PlayerShip).triggerMeleeTextures(reloadTime / 1000);
				}
			}
			var _loc13_:Weapon = this;
			var _loc15_:Projectile = ProjectileFactory.create(projectileFunction, g, unit, this);
			if (_loc15_ == null)
			{
				return;
			}
			if (param2 != null)
			{
				_loc15_.target = param2;
			}
			if (name == "Snow Cannon" || name == "Poison Arrow" || name == "Nexar Projector" || name == "Shadow Projector")
			{
				_loc15_.speedMax = param8;
				if (name == "Snow Cannon")
				{
					_loc15_.scaleX = 0.2 + 0.5 * _loc15_.speedMax / 1500;
					_loc15_.scaleY = 0.2 + 0.5 * _loc15_.speedMax / 1500;
				}
			}
			if (param8 != 0)
			{
				if (_loc15_.stateMachine.inState("Instant"))
				{
					_loc15_.range = param8;
					_loc15_.speedMax = 10000;
				}
				else
				{
					_loc15_.speedMax = param8;
				}
			}
			if (param2 != null)
			{
				_loc13_.target = param2;
				_loc19_ = aim();
			}
			else
			{
				_loc19_ = 0;
			}
			var _loc12_:Number = multiNrOfP;
			if (multiNrOfP > 1 && param4 > -1)
			{
				_loc10_ = unit.weaponPos.y + multiOffset * (param4 - 0.5 * (_loc12_ - 1)) / _loc12_;
			}
			else if (param4 > -1)
			{
				_loc10_ = unit.weaponPos.y + 0.25 * multiOffset * (2 * (param4 % 2) - 1);
			}
			else
			{
				_loc10_ = unit.weaponPos.y;
			}
			var _loc9_:Number = unit.weaponPos.x + positionOffsetX;
			var _loc17_:Number = new Point(_loc9_, _loc10_).length;
			var _loc11_:Number = Math.atan2(_loc10_, _loc9_);
			var _loc16_:Number = multiAngleOffset * (param4 - 0.5 * (_loc12_ - 1)) / _loc12_;
			_loc15_.course.pos.x = unit.pos.x + Math.cos(unit.rotation + _loc16_ + _loc11_ + _loc19_) * _loc17_;
			_loc15_.course.pos.y = unit.pos.y + Math.sin(unit.rotation + _loc16_ + _loc11_ + _loc19_) * _loc17_;
			_loc15_.course.pos.x += param6;
			_loc15_.course.pos.y += param7;
			_loc15_.course.rotation = unit.rotation + _loc16_ + _loc19_ + (angleVariance - Math.random() * angleVariance * 2);
			if (fireBackwards)
			{
				_loc15_.course.rotation -= 3.141592653589793;
			}
			if (acceleration == 0)
			{
				_loc15_.course.speed.x = Math.cos(_loc15_.course.rotation) * _loc15_.speedMax;
				_loc15_.course.speed.y = Math.sin(_loc15_.course.rotation) * _loc15_.speedMax;
			}
			else if (multiSpreadStart)
			{
				_loc15_.course.speed.x = _loc15_.unit.speed.x * 0.5;
				_loc15_.course.speed.y = _loc15_.unit.speed.y * 0.5;
				_loc18_ = 10 * (param4 - 0.5 * (_loc12_ - 1)) / _loc12_;
				if (_loc18_ > 0)
				{
					_loc18_ += 10;
				}
				else
				{
					_loc18_ -= 10;
				}
				_loc15_.course.speed.x -= Math.sin(_loc15_.course.rotation) * _loc18_;
				_loc15_.course.speed.y += Math.cos(_loc15_.course.rotation) * _loc18_;
			}
			else
			{
				_loc15_.course.speed.x = unit.speed.x * 0.5;
				_loc15_.course.speed.y = unit.speed.y * 0.5;
			}
			_loc15_.target = param2;
			_loc15_.error = new Point(_loc15_.course.pos.x - param3.pos.x, _loc15_.course.pos.y - param3.pos.y);
			_loc15_.convergenceCounter = 0;
			_loc15_.course = param3;
			_loc15_.convergenceTime = 1000 / 33;
			_loc15_.collisionRadius = 0;
			_loc15_.id = param1;
			g.projectileManager.activateProjectile(_loc15_);
			playFireSound();
		}
	}
}
