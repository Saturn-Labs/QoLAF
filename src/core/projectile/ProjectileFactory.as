package core.projectile
{
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.states.AIStates.AIStateFactory;
	import core.turret.Turret;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import data.DataLocator;
	import data.IDataManager;
	import flash.geom.Point;
	import movement.Heading;
	import sound.ISound;
	import sound.SoundLocator;
	import textures.TextureLocator;
	
	public class ProjectileFactory
	{
		public function ProjectileFactory()
		{
			super();
		}
		
		public static function create(param1:String, param2:Game, param3:Unit, param4:Weapon, param5:Heading = null):Projectile
		{
			var _loc7_:Point = null;
			var _loc12_:Number = NaN;
			var _loc9_:Number = NaN;
			var _loc13_:Number = NaN;
			var _loc6_:ISound = null;
			if (param3 == null)
			{
				return null;
			}
			if (param4 == null)
			{
				return null;
			}
			if (param2.me.ship == null && param4.ttl < 2000)
			{
				return null;
			}
			if (param3.movieClip != param2.camera.focusTarget)
			{
				if (isNaN(param3.pos.x))
				{
					return null;
				}
				if (param5 != null)
				{
					_loc7_ = param2.camera.getCameraCenter().subtract(param5.pos);
				}
				else
				{
					_loc7_ = param2.camera.getCameraCenter().subtract(param3.pos);
				}
				_loc12_ = _loc7_.x * _loc7_.x + _loc7_.y * _loc7_.y;
				_loc9_ = 450;
				if (param4.global && _loc12_ > 36000000)
				{
					return null;
				}
				_loc13_ = 0;
				if (param4.type == "instant")
				{
					_loc13_ = param4.range;
				}
				else
				{
					_loc13_ = (Math.abs(param4.speed) + _loc9_) * 0.001 * param4.ttl + 500;
				}
				if (_loc12_ > _loc13_ * _loc13_)
				{
					return null;
				}
			}
			var _loc14_:IDataManager = DataLocator.getService();
			var _loc11_:Object = _loc14_.loadKey("Projectiles", param1);
			var _loc10_:Projectile = param2.projectileManager.getProjectile();
			if (param4.maxProjectiles > 0)
			{
				param4.projectiles.push(_loc10_);
				if (param4.projectiles.length > param4.maxProjectiles)
				{
					param4.projectiles[0].destroy(false);
				}
			}
			_loc10_.name = _loc11_.name;
			_loc10_.useShipSystem = param4.useShipSystem;
			_loc10_.unit = param3;
			if (param3 is EnemyShip || param3 is Turret)
			{
				_loc10_.isEnemy = true;
			}
			else if (param3 is PlayerShip)
			{
				_loc10_.ps = param3 as PlayerShip;
			}
			_loc10_.weapon = param4;
			if (param4.dmg.type == 6)
			{
				_loc10_.isHeal = true;
			}
			else
			{
				_loc10_.isHeal = false;
			}
			_loc10_.debuffType = param4.debuffType;
			_loc10_.collisionRadius = _loc11_.collisionRadius;
			_loc10_.ttl = param4.ttl;
			_loc10_.ttlMax = param4.ttl;
			_loc10_.numberOfHits = param4.numberOfHits;
			_loc10_.speedMax = param4.speed;
			_loc10_.rotationSpeedMax = param4.rotationSpeed;
			_loc10_.acceleration = param4.acceleration;
			_loc10_.dmgRadius = param4.dmgRadius;
			_loc10_.course.speed.x = param3.speed.x;
			_loc10_.course.speed.y = param3.speed.y;
			_loc10_.alive = true;
			_loc10_.randomAngle = param4.randomAngle;
			_loc10_.wave = _loc11_.wave;
			param4.waveDirection = param4.waveDirection == 1 ? -1 : 1;
			_loc10_.waveDirection = param4.waveDirection;
			_loc10_.waveAmplitude = _loc11_.waveAmplitude;
			_loc10_.waveFrequency = _loc11_.waveFrequency;
			_loc10_.boomerangReturnTime = _loc11_.boomerangReturnTime;
			_loc10_.boomerangReturning = false;
			_loc10_.clusterProjectile = _loc11_.clusterProjectile;
			_loc10_.clusterNrOfProjectiles = _loc11_.clusterNrOfProjectiles;
			_loc10_.clusterNrOfSplits = _loc11_.clusterNrOfSplits;
			_loc10_.clusterAngle = _loc11_.clusterAngle;
			_loc10_.aiDelayedAcceleration = _loc11_.aiDelayedAcceleration;
			_loc10_.aiDelayedAccelerationTime = _loc11_.aiDelayedAccelerationTime;
			_loc10_.switchTexturesByObj(_loc11_);
			_loc10_.blendMode = _loc11_.blendMode;
			if (_loc11_.hasOwnProperty("aiAlwaysExplode"))
			{
				_loc10_.aiAlwaysExplode = _loc11_.aiAlwaysExplode;
			}
			if (_loc11_.ribbonTrail)
			{
				_loc10_.ribbonTrail = param2.ribbonTrailPool.getRibbonTrail();
				_loc10_.hasRibbonTrail = true;
				_loc10_.ribbonTrail.color = _loc11_.ribbonColor;
				_loc10_.ribbonTrail.movingRatio = _loc11_.ribbonSpeed;
				_loc10_.ribbonTrail.alphaRatio = _loc11_.ribbonAlpha;
				_loc10_.ribbonThickness = _loc11_.ribbonThickness;
				_loc10_.ribbonTrail.blendMode = "add";
				_loc10_.ribbonTrail.texture = TextureLocator.getService().getTextureMainByTextureName(_loc11_.ribbonTexture || "ribbon_trail");
				_loc10_.ribbonTrail.followTrailSegmentsLine(_loc10_.followingRibbonSegmentLine);
				_loc10_.ribbonTrail.isPlaying = false;
				_loc10_.ribbonTrail.visible = false;
				_loc10_.useRibbonOffset = _loc11_.useRibbonOffset;
			}
			var _loc8_:Boolean = param4.reloadTime < 60 && Math.random() < 0.4;
			if (_loc11_.thrustEffect != null && !_loc8_)
			{
				_loc10_.thrustEmitters = EmitterFactory.create(_loc11_.thrustEffect, param2, param3.pos.x, param3.pos.y, _loc10_, true);
			}
			_loc10_.forcedRotation = _loc11_.forcedRotation;
			if (_loc10_.forcedRotation)
			{
				_loc10_.forcedRotationAngle = Math.random() * 2 * 3.141592653589793 - 3.141592653589793;
				_loc10_.forcedRotationSpeed = _loc11_.forcedRotationSpeed;
			}
			_loc10_.explosionSound = _loc11_.explosionSound;
			if (_loc11_.explosionSound != null)
			{
				_loc6_ = SoundLocator.getService();
				_loc6_.preCacheSound(_loc11_.explosionSound);
			}
			_loc10_.explosionEffect = _loc11_.explosionEffect;
			_loc10_.stateMachine.changeState(AIStateFactory.createProjectileAI(_loc11_, param2, _loc10_));
			return _loc10_;
		}
	}
}
