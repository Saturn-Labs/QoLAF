package core.projectile {
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
	
	public class ProjectileFactory {
		public function ProjectileFactory() {
			super();
		}
		
		public static function create(key:String, g:Game, u:Unit, w:Weapon, course:Heading = null) : Projectile {
			var _local6:Point = null;
			var _local7:Number = NaN;
			var _local10:Number = NaN;
			var _local8:Number = NaN;
			var _local13:ISound = null;
			if(u == null) {
				return null;
			}
			if(w == null) {
				return null;
			}
			if(g.me.ship == null && w.ttl < 2000) {
				return null;
			}
			if(u.movieClip != g.camera.focusTarget) {
				if(isNaN(u.pos.x)) {
					return null;
				}
				if(course != null) {
					_local6 = g.camera.getCameraCenter().subtract(course.pos);
				} else {
					_local6 = g.camera.getCameraCenter().subtract(u.pos);
				}
				_local7 = _local6.x * _local6.x + _local6.y * _local6.y;
				_local10 = 450;
				if(w.global && _local7 > 10 * 60 * 60 * 1000) {
					return null;
				}
				_local8 = 0;
				if(w.type == "instant") {
					_local8 = w.range;
				} else {
					_local8 = (Math.abs(w.speed) + _local10) * 0.001 * w.ttl + 500;
				}
				if(_local7 > _local8 * _local8) {
					return null;
				}
			}
			var _local14:IDataManager = DataLocator.getService();
			var _local12:Object = _local14.loadKey("Projectiles",key);
			var _local11:Projectile = g.projectileManager.getProjectile();
			if(w.maxProjectiles > 0) {
				w.projectiles.push(_local11);
				if(w.projectiles.length > w.maxProjectiles) {
					w.projectiles[0].destroy(false);
				}
			}
			_local11.name = _local12.name;
			_local11.useShipSystem = w.useShipSystem;
			_local11.unit = u;
			if(u is EnemyShip || u is Turret) {
				_local11.isEnemy = true;
			} else if(u is PlayerShip) {
				_local11.ps = u as PlayerShip;
			}
			_local11.weapon = w;
			if(w.dmg.type == 6) {
				_local11.isHeal = true;
			} else {
				_local11.isHeal = false;
			}
			_local11.debuffType = w.debuffType;
			_local11.collisionRadius = _local12.collisionRadius;
			_local11.ttl = w.ttl;
			_local11.ttlMax = w.ttl;
			_local11.numberOfHits = w.numberOfHits;
			_local11.speedMax = w.speed;
			_local11.rotationSpeedMax = w.rotationSpeed;
			_local11.acceleration = w.acceleration;
			_local11.dmgRadius = w.dmgRadius;
			_local11.course.speed.x = u.speed.x;
			_local11.course.speed.y = u.speed.y;
			_local11.alive = true;
			_local11.randomAngle = w.randomAngle;
			_local11.wave = _local12.wave;
			w.waveDirection = w.waveDirection == 1 ? -1 : 1;
			_local11.waveDirection = w.waveDirection;
			_local11.waveAmplitude = _local12.waveAmplitude;
			_local11.waveFrequency = _local12.waveFrequency;
			_local11.boomerangReturnTime = _local12.boomerangReturnTime;
			_local11.boomerangReturning = false;
			_local11.clusterProjectile = _local12.clusterProjectile;
			_local11.clusterNrOfProjectiles = _local12.clusterNrOfProjectiles;
			_local11.clusterNrOfSplits = _local12.clusterNrOfSplits;
			_local11.clusterAngle = _local12.clusterAngle;
			_local11.aiDelayedAcceleration = _local12.aiDelayedAcceleration;
			_local11.aiDelayedAccelerationTime = _local12.aiDelayedAccelerationTime;
			_local11.switchTexturesByObj(_local12);
			_local11.blendMode = _local12.blendMode;
			if(_local12.hasOwnProperty("aiAlwaysExplode")) {
				_local11.aiAlwaysExplode = _local12.aiAlwaysExplode;
			}
			if(_local12.ribbonTrail) {
				_local11.ribbonTrail = g.ribbonTrailPool.getRibbonTrail();
				_local11.hasRibbonTrail = true;
				_local11.ribbonTrail.color = _local12.ribbonColor;
				_local11.ribbonTrail.movingRatio = _local12.ribbonSpeed;
				_local11.ribbonTrail.alphaRatio = _local12.ribbonAlpha;
				_local11.ribbonThickness = _local12.ribbonThickness;
				_local11.ribbonTrail.blendMode = "add";
				_local11.ribbonTrail.texture = TextureLocator.getService().getTextureMainByTextureName(_local12.ribbonTexture || "ribbon_trail");
				_local11.ribbonTrail.followTrailSegmentsLine(_local11.followingRibbonSegmentLine);
				_local11.ribbonTrail.isPlaying = false;
				_local11.ribbonTrail.visible = false;
				_local11.useRibbonOffset = _local12.useRibbonOffset;
			}
			var _local9:Boolean = w.reloadTime < 60 && Math.random() < 0.4;
			if(_local12.thrustEffect != null && !_local9) {
				_local11.thrustEmitters = EmitterFactory.create(_local12.thrustEffect,g,u.pos.x,u.pos.y,_local11,true);
			}
			_local11.forcedRotation = _local12.forcedRotation;
			if(_local11.forcedRotation) {
				_local11.forcedRotationAngle = Math.random() * 2 * 3.141592653589793 - 3.141592653589793;
				_local11.forcedRotationSpeed = _local12.forcedRotationSpeed;
			}
			_local11.explosionSound = _local12.explosionSound;
			if(_local12.explosionSound != null) {
				_local13 = SoundLocator.getService();
				_local13.preCacheSound(_local12.explosionSound);
			}
			_local11.explosionEffect = _local12.explosionEffect;
			_local11.stateMachine.changeState(AIStateFactory.createProjectileAI(_local12,g,_local11));
			return _local11;
		}
	}
}

