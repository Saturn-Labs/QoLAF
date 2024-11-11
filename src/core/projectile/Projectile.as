package core.projectile
{
	import core.GameObject;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.states.StateMachine;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import extensions.RibbonSegment;
	import extensions.RibbonTrail;
	import flash.geom.Point;
	import movement.Heading;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.core.Starling;
	import textures.ITextureManager;
	import textures.TextureLocator;

	public class Projectile extends GameObject
	{
		private static const DT:Number = 33;

		private static const DTxDT_HALF:Number = Math.pow(33, 2) * 0.5;

		public var numberOfHits:int;
		public var alive:Boolean;
		public var ttl:int;
		public var ttlMax:int;
		public var speed:Point;
		public var speedMax:Number;
		public var rotationSpeedMax:Number;
		public var acceleration:Number;
		public var stateMachine:StateMachine;
		public var unit:Unit;
		public var weapon:Weapon;
		public var dmgRadius:int;
		public var wave:Boolean;
		public var waveDirection:int;
		public var waveAmplitude:Number;
		public var waveFrequency:Number;
		public var clusterProjectile:String;
		public var clusterNrOfSplits:int;
		public var clusterNrOfProjectiles:int;
		public var clusterAngle:Number;
		public var aiAlwaysExplode:Boolean;
		public var oldPos:Point;
		public var boomerangReturnTime:int;
		public var boomerangReturning:Boolean;
		public var direction:int;
		public var ps:PlayerShip;
		public var range:Number;
		public var debuffType:int;
		public var target:Unit;
		public var targetProjectile:Projectile;
		public var error:Point;
		public var convergenceTime:int;
		public var convergenceCounter:int;
		public var collisionRadius:Number;
		public var useShipSystem:Boolean;
		public var course:Heading;
		public var thrustEmitters:Vector.<Emitter>;

		public var randomAngle:Boolean;
		public var explosionEffect:String;
		public var explosionSound:String;
		public var isVisible:Boolean = false;
		public var isEnemy:Boolean;
		public var isHeal:Boolean;
		public var aiStuck:Boolean;
		public var aiStuckDuration:int;
		public var aiTargetSelf:Boolean;
		public var aiDelayedAcceleration:Boolean;
		public var aiDelayedAccelerationTime:int = 0;
		private var g:Game;
		public var ai:String;
		public var errorRot:Number;
		public var hasRibbonTrail:Boolean = false;
		public var useRibbonOffset:Boolean = false;
		public var ribbonThickness:Number = 0;
		public var ribbonTrail:RibbonTrail;
		private var followingRibbonSegment:RibbonSegment;
		public var followingRibbonSegmentLine:Vector.<RibbonSegment>;

		private var hasDoneFirstUpdate:Boolean = false;
		private var tempVx:Number = 0;
		private var tempVy:Number = 0;
		public function Projectile(param1:Game)
		{
			speed = new Point();
			oldPos = new Point();
			course = new Heading();
			followingRibbonSegment = new RibbonSegment();
			followingRibbonSegmentLine = new <RibbonSegment>[followingRibbonSegment];
			super();
			canvas = param1.canvasProjectiles;
			target = null;
			stateMachine = new StateMachine();
			this.g = param1;
			alive = false;
			ttl = 0;
			thrustEmitters = new Vector.<Emitter>();
		}

		override public function update():void
		{
			var _loc2_:Point = null;
			var _loc1_:* = false;
			stateMachine.update();
			if (weapon.maxProjectiles == 0)
			{
				ttl -= 33;
				if (ttl <= 0 && !aiAlwaysExplode)
				{
					destroy(false);
				}
			}
			else if ((unit == null || !unit.alive) && !isEnemy)
			{
				destroy(false);
			}
			if (alive)
			{
				_pos.x = course.pos.x;
				_pos.y = course.pos.y;
				if (!randomAngle)
				{
					_rotation = course.rotation;
				}
				_loc2_ = g.camera.getCameraCenter();
				distanceToCameraX = _pos.x - _loc2_.x;
				distanceToCameraY = _pos.y - _loc2_.y;
				_loc1_ = distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY < g.stage.stageWidth * g.stage.stageWidth;
				if (isVisible && !_loc1_)
				{
					isVisible = false;
					if (ribbonTrail != null)
					{
						ribbonTrail.isPlaying = false;
					}
				}
				else if (!isVisible && _loc1_)
				{
					isVisible = true;
					if (ribbonTrail != null)
					{
						ribbonTrail.isPlaying = true;
					}
				}
				updateRibbonTrail();
			}
			if (!hasDoneFirstUpdate)
			{
				draw();
				hasDoneFirstUpdate = true;
			}
			super.update();
		}

		private function updateRibbonTrail():void
		{
			var _loc3_:Number = NaN;
			var _loc1_:Number = NaN;
			var _loc6_:* = NaN;
			var _loc7_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc2_:Number = NaN;
			if (!ribbonTrail)
			{
				return;
			}
			if (!ribbonTrail.isPlaying)
			{
				return;
			}
			if (!isVisible)
			{
				return;
			}
			var _loc4_:Number = Math.atan2(course.speed.y, course.speed.x) + 3.141592653589793;
			if (useRibbonOffset)
			{
				_loc3_ = 0;
				_loc1_ = -radius;
				_loc6_ = _loc1_;
				_loc7_ = 0;
				if (_loc1_ != 0)
				{
					_loc7_ = Math.atan(_loc3_ / _loc1_);
				}
				_loc5_ = Math.cos(_rotation + _loc7_) * _loc6_;
				_loc2_ = Math.sin(_rotation + _loc7_) * _loc6_;
				followingRibbonSegment.setTo2(_pos.x + _loc5_, _pos.y + _loc2_, ribbonThickness, _loc4_);
			}
			else
			{
				followingRibbonSegment.setTo2(_pos.x, _pos.y, ribbonThickness, _loc4_);
			}
			ribbonTrail.advanceTime(33);
		}

		public function fastforward():void
		{
			if (course.time + 10000 >= g.time)
			{
				while (course.time < g.time && alive)
				{
					stateMachine.update();
					ttl -= 33;
					if (alive)
					{
						_pos.x = course.pos.x;
						_pos.y = course.pos.y;
						_rotation = course.rotation;
					}
				}
			}
		}

		public function updateHeading(param1:Heading):void
		{
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			if (!useShipSystem)
			{
				if (acceleration != 0)
				{
					tempVx = param1.speed.x;
					tempVy = param1.speed.y;
					if (wave)
					{
						_loc2_ = waveAmplitude / 3 * Math.sin(waveFrequency * (ttlMax - ttl)) * waveDirection;
						tempVx += Math.cos(param1.rotation + _loc2_) * acceleration * DTxDT_HALF;
						tempVy += Math.sin(param1.rotation + _loc2_) * acceleration * DTxDT_HALF;
					}
					else
					{
						tempVx += Math.cos(param1.rotation) * acceleration * DTxDT_HALF;
						tempVy += Math.sin(param1.rotation) * acceleration * DTxDT_HALF;
					}
					if (tempVx * tempVx + tempVy * tempVy <= speedMax * speedMax)
					{
						param1.speed.x = tempVx;
						param1.speed.y = tempVy;
					}
					else
					{
						_loc3_ = Math.sqrt(tempVx * tempVx + tempVy * tempVy);
						param1.speed.x = speedMax * tempVx / _loc3_;
						param1.speed.y = speedMax * tempVy / _loc3_;
					}
				}
				param1.speed.x -= weapon.friction * param1.speed.x + 0.009 * param1.speed.x;
				param1.speed.y -= weapon.friction * param1.speed.y + 0.009 * param1.speed.y;
			}
			param1.pos.x += 0.001 * param1.speed.x * 33;
			param1.pos.y += 0.001 * param1.speed.y * 33;
			param1.time += 33;
		}

		public function explode(param1:Boolean = false, param2:Unit = null):void
		{
			var _loc3_:* = undefined;
			var _loc4_:* = null;
			var _loc5_:ISound = null;
			if (param1 || g.camera.isCircleOnScreen(pos.x, pos.y, radius))
			{
				if (explosionEffect != null)
				{
					if (dmgRadius > 25 || unit != null && unit.nextHitEffectReady < g.time && Game.highSettings)
					{
						unit.nextHitEffectReady = g.time + 50;
						_loc3_ = EmitterFactory.create(explosionEffect, g, pos.x, pos.y, param2, true);
						if (param1)
						{
							for each (_loc4_ in _loc3_)
							{
								_loc4_.global = true;
							}
						}
						if (explosionSound != null)
						{
							_loc5_ = SoundLocator.getService();
							_loc5_.play(explosionSound);
						}
					}
				}
			}
		}

		public function destroy(param1:Boolean = true):void
		{
			var _loc2_:int = 0;
			if (weapon.maxProjectiles > 0)
			{
				_loc2_ = int(weapon.projectiles.indexOf(this));
				weapon.projectiles.splice(_loc2_, 1);
			}
			if (param1)
			{
				this.explode(false, null);
			}
			for each (var _loc3_:* in thrustEmitters)
			{
				_loc3_.killEmitter();
			}
			alive = false;
			if (stateMachine.inState("Instant"))
			{
				stateMachine.update();
			}
		}

		public function ignite():void
		{
			var _loc1_:int = 0;
			_loc1_ = 0;
			while (_loc1_ < thrustEmitters.length)
			{
				thrustEmitters[_loc1_].play();
				_loc1_++;
			}
		}

		public function disable():void
		{
			if (ai == "mine")
			{
				switchTextures(imgObj.textureName.replace("active", "disabled"));
			}
		}

		public function activate():void
		{
			if (ai == "mine")
			{
				switchTextures(imgObj.textureName);
				Starling.juggler.add(_mc);
			}
		}

		private function switchTextures(param1:String):void
		{
			var _loc2_:ITextureManager = TextureLocator.getService();
			_textures = _loc2_.getTexturesMainByTextureName(param1);
			swapFrames(_mc, _textures);
		}

		public function tryAddRibbonTrail():void
		{
			if (hasRibbonTrail)
			{
				ribbonTrail.resetAllTo(_pos.x, _pos.y, _pos.x, _pos.y, 0.85);
				updateRibbonTrail();
			}
		}

		override public function addToCanvas():void
		{
			isAddedToCanvas = true;
			if (imgObj == null)
			{
				return;
			}
		}

		override public function removeFromCanvas():void
		{
			isAddedToCanvas = false;
			if (imgObj == null)
			{
				return;
			}
		}

		override public function reset():void
		{
			g.emitterManager.clean(this);
			id = 0;
			ttl = 0;
			numberOfHits = 0;
			ttlMax = 0;
			speedMax = 0;
			dmgRadius = 0;
			oldPos.x = 0;
			oldPos.y = 0;
			isEnemy = false;
			isHeal = false;
			aiAlwaysExplode = false;
			course.reset();
			speed.x = 0;
			speed.y = 0;
			name = null;
			rotationSpeedMax = 0;
			acceleration = 0;
			unit = null;
			target = null;
			thrustEmitters = null;
			explosionEffect = "";
			explosionSound = "";
			useShipSystem = false;
			randomAngle = false;
			boomerangReturning = false;
			boomerangReturnTime = 0;
			debuffType = -1;
			direction = 0;
			aiTargetSelf = false;
			aiStuck = false;
			aiStuckDuration = 0;
			errorRot = 0;
			aiDelayedAcceleration = false;
			aiDelayedAccelerationTime = 0;
			wave = false;
			waveDirection = 1;
			waveAmplitude = 0;
			waveFrequency = 0;
			hasRibbonTrail = false;
			ribbonThickness = 0;
			useRibbonOffset = false;
			if (ribbonTrail)
			{
				g.ribbonTrailPool.removeRibbonTrail(ribbonTrail);
				ribbonTrail.resetAllTo(0, 0, 0, 0, 0);
				ribbonTrail.isPlaying = false;
				ribbonTrail.visible = false;
				ribbonTrail = null;
			}
			clusterProjectile = "";
			clusterNrOfProjectiles = 0;
			clusterNrOfSplits = 0;
			clusterAngle = 0;
			hasDoneFirstUpdate = false;
			isVisible = false;
			ai = null;
			weapon = null;
			collisionRadius = 0;
			alive = false;
			error = null;
			errorRot = 0;
			super.reset();
		}
	}
}
