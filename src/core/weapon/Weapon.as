package core.weapon
{
	import core.GameObject;
	import core.player.EliteTechs;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.unit.Unit;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import generics.Localize;
	import generics.Util;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class Weapon extends GameObject
	{
		public static const TYPE_FLEE:int = 0;
		public static const TYPE_ANTIPROJECTILE:int = 1;
		public var type:String;
		
		public var dmg:Damage;
		
		public var debuffType:int;
		
		public var debuffDuration:int;
		
		public var debuffValue:Damage;
		
		public var debuffEffect:String;
		
		public var debuffType2:int;
		
		public var debuffDuration2:int;
		
		public var debuffValue2:Damage;
		
		public var debuffEffect2:String;
		
		public var fireEffect:String;
		
		public var dmgRadius:int;
		
		public var numberOfHits:int;
		
		public var reloadTime:Number;
		
		public var speed:Number;
		
		public var acceleration:Number;
		
		public var ttl:int;
		
		public var projectileFunction:String;
		
		public var range:Number;
		
		public var friction:Number;
		
		public var angleVariance:Number;
		
		public var positionYVariance:Number;
		
		public var positionXVariance:Number;
		
		public var sideShooter:Boolean;
		
		public var positionOffsetX:Number;
		
		public var positionOffsetY:Number;
		
		public var maxProjectiles:int;
		
		public var projectiles:Vector.<Projectile>;
		
		public var multiNrOfP:int;
		
		public var multiOffset:Number;
		
		public var multiAngleOffset:Number;
		
		public var multiSpreadStart:Boolean;
		
		public var fireSound:String;
		
		public var alive:Boolean;
		
		public var fireNextTime:Number;
		
		public var rotationSpeed:Number;
		
		public var unit:Unit;
		
		public var target:Unit;
		
		public var hasTechTree:Boolean;
		
		public var key:String;
		
		public var useShipSystem:Boolean;
		
		public var randomAngle:Boolean;
		
		public var techIconFileName:String;
		
		public var specialCondition:String;
		
		public var specialBonusPercentage:Number;
		
		public var waveDirection:int;
		
		public var isMissileWeapon:Boolean;
		
		public var fireBackwards:Boolean;
		
		public var aimArc:Number;
		
		public var level:int;
		
		public var heatCost:Number;
		
		public var shieldVamp:Number;
		
		public var healthVamp:Number;
		
		public var burst:int;
		
		public var burstDelay:Number;
		
		public var burstCurrent:int;
		
		public var active:Boolean;
		
		public var hotkey:int;
		
		public var hasChargeUp:Boolean;
		
		public var chargeUpTimeMax:Number;
		
		protected var g:Game;
		
		protected var _fire:Boolean;
		
		public var chargeUpTime:Number;
		
		public var lastFire:Number = 0;
		public var global:Boolean = false;
		public var triggerMeleeAnimation:Boolean = false;
		public var fireCallback:Function;
		
		public function Weapon(param1:Game)
		{
			super();
			chargeUpTime = 0;
			heatCost = 0;
			this.g = param1;
		}
		
		public function init(param1:Object, param2:int, param3:int = -1, param4:String = ""):void
		{
			var _loc5_:int = 0;
			var _loc6_:ISound = null;
			this.type = param1.type;
			name = param1.name;
			if (param1.hasOwnProperty("damageType"))
			{
				_loc5_ = int(param1.damageType);
			}
			dmg = new Damage(param1.dmg, _loc5_);
			if (param1.hasOwnProperty("shieldVamp"))
			{
				shieldVamp = param1.shieldVamp;
			}
			else
			{
				shieldVamp = 0;
			}
			if (param1.hasOwnProperty("healthVamp"))
			{
				healthVamp = param1.healthVamp;
			}
			else
			{
				healthVamp = 0;
			}
			if (param1.hasOwnProperty("burst"))
			{
				burst = param1.burst;
			}
			else
			{
				burst = 1;
			}
			if (param1.hasOwnProperty("burstDelay"))
			{
				burstDelay = param1.burstDelay;
			}
			else
			{
				burstDelay = 30;
			}
			if (param1.hasOwnProperty("debuffType") && Boolean(param1.hasOwnProperty("dot")) && Boolean(param1.hasOwnProperty("dotDamageType")) && Boolean(param1.hasOwnProperty("dotDuration")))
			{
				debuffType = param1.debuffType;
				debuffValue = new Damage(param1.dot, param1.dotDamageType);
				debuffDuration = param1.dotDuration;
				if (param1.hasOwnProperty("dotEffect"))
				{
					debuffEffect = param1.dotEffect;
				}
			}
			else
			{
				debuffType = -1;
				debuffValue = new Damage(0, 1);
				debuffDuration = 0;
			}
			debuffType2 = -1;
			debuffValue2 = new Damage(0, 1);
			debuffDuration2 = 0;
			if (param1.hasOwnProperty("heatCost"))
			{
				heatCost = Number(param1.heatCost) / 1000;
			}
			else
			{
				heatCost = 0;
			}
			if (param1.hasOwnProperty("numberOfHits"))
			{
				numberOfHits = param1.numberOfHits;
			}
			else
			{
				numberOfHits = 1;
			}
			speed = param1.speed;
			reloadTime = param1.reloadTime;
			ttl = param1.ttl;
			acceleration = param1.acceleration;
			rotationSpeed = param1.rotationSpeed;
			positionYVariance = param1.positionVariance;
			if (param1.hasOwnProperty("positionXVariance"))
			{
				positionXVariance = param1.positionXVariance;
			}
			else
			{
				positionXVariance = 0;
			}
			if (param1.hasOwnProperty("multiSideFire"))
			{
				sideShooter = param1.multiSideFire;
			}
			else
			{
				sideShooter = false;
			}
			if (param1.hasOwnProperty("positionOffset"))
			{
				positionOffsetX = param1.positionOffset;
			}
			if (param1.hasOwnProperty("positionOffsetY"))
			{
				positionOffsetY = param1.positionOffsetY;
			}
			if (param1.hasOwnProperty("friction"))
			{
				friction = param1.friction;
			}
			maxProjectiles = param1.maxProjectiles;
			if (maxProjectiles > 0)
			{
				ttl = 120000;
			}
			multiNrOfP = param1.multiNrOfP;
			multiOffset = param1.multiOffset;
			multiAngleOffset = Util.degreesToRadians(param1.multiAngleOffset);
			angleVariance = param1.angleVariance;
			if (param1.hasOwnProperty("aimArc"))
			{
				aimArc = param1.aimArc;
			}
			fireSound = param1.fireSound;
			if (fireSound != null)
			{
				_loc6_ = SoundLocator.getService();
				_loc6_.preCacheSound(fireSound);
			}
			hasTechTree = param1.hasTechTree;
			if (param1.hasOwnProperty("multiSpreadStart"))
			{
				multiSpreadStart = param1.multiSpreadStart;
			}
			else
			{
				multiSpreadStart = false;
			}
			if (param1.hasOwnProperty("radius"))
			{
				dmgRadius = param1.radius;
			}
			else
			{
				dmgRadius = 0;
			}
			range = param1.range;
			if (hasTechTree)
			{
				techIconFileName = param1.techIcon;
				level = param2;
				if (param2 > 0)
				{
					addTechStats(param1, param2);
				}
				if (param3 > 0)
				{
					addEliteTechStats(param1, param3, param4);
				}
				triggerMeleeAnimation = param1.triggerMeleeAnimation;
			}
			if (this is Cloak)
			{
				reloadTime += 3 * debuffDuration * 1000;
			}
			global = param1.global;
		}
		
		public function addDebuff(param1:int, param2:int, param3:Damage, param4:String):void
		{
			if (debuffType == -1)
			{
				debuffType = param1;
				debuffDuration = param2;
				debuffEffect = param4;
				debuffValue = param3;
			}
			else if (debuffType == param1 && debuffValue.type == param3.type)
			{
				debuffEffect = param4;
				debuffValue.addBaseDmg(param3.dmg());
			}
			else
			{
				debuffType2 = param1;
				debuffDuration2 = param2;
				debuffEffect2 = param4;
				debuffValue2 = param3;
			}
		}
		
		public function getDescription(param1:Boolean):String
		{
			var _loc2_:String = null;
			var _loc3_:PetSpawner = null;
			_loc2_ = Localize.t("<FONT COLOR='#8888ff'>[name], lvl [level]</FONT>\n").replace("[name]", name).replace("[level]", level);
			_loc2_ += dmg.damageText();
			if (multiNrOfP > 1)
			{
				_loc2_ += Localize.t("Fires <FONT COLOR='#eeeeee'>[nrp]</FONT>x projectiles\n").replace("[nrp]", multiNrOfP);
			}
			if (!param1 && name != "Acid Spray" && name != "Flamethrower")
			{
				_loc2_ += Localize.t("Fires <FONT COLOR='#eeeeee'>[rps]</FONT> rounds per second.\n").replace("[rps]", (1000 * multiNrOfP / reloadTime).toFixed(1));
			}
			if (multiNrOfP == 0)
			{
				_loc2_ += Localize.t("Damage per second: <FONT COLOR='#eeeeee'>[dps]</FONT>\n").replace("[dps]", (dmg.dmg() * burst * 1000 / (reloadTime + (burst - 1) * 33)).toFixed(1));
			}
			else
			{
				_loc2_ += Localize.t("Damage per second: <FONT COLOR='#eeeeee'>[dps]</FONT>\n").replace("[dps]", (dmg.dmg() * burst * multiNrOfP * 1000 / (reloadTime + (burst - 1) * 33)).toFixed(1));
			}
			if (shieldVamp > 0 || healthVamp > 0)
			{
				_loc2_ += "\n";
				if (shieldVamp > 0)
				{
					_loc2_ += Localize.t("<FONT COLOR='#4444ff'>Steals [shieldVamp]% of damage done to enemy shields</FONT>\n").replace("[shieldVamp]", shieldVamp);
				}
				if (healthVamp > 0)
				{
					_loc2_ += Localize.t("<FONT COLOR='#ff4444'>Steals [healthVamp]% of damage done to enemy health</FONT>\n").replace("[healthVamp]", healthVamp);
				}
			}
			if (debuffDuration > 0)
			{
				_loc2_ += Localize.t("\nDebuff:\n");
				_loc2_ += Debuff.debuffText(debuffType, debuffDuration, debuffValue);
				if (debuffDuration2 > 0)
				{
					_loc2_ += Debuff.debuffText(debuffType2, debuffDuration2, debuffValue2);
				}
			}
			if (this is PetSpawner)
			{
				_loc3_ = this as PetSpawner;
				_loc2_ += Localize.t("\nMax number of Pets: [maxPets]").replace("[maxPets]", _loc3_.maxPets);
			}
			if (specialCondition != null && specialCondition != "")
			{
				_loc2_ += Localize.t("\nDeals <FONT COLOR='#eeeeee'>" + specialBonusPercentage.toString() + "%</FONT> more damage if target is afflicted by " + specialCondition + ".");
			}
			return _loc2_;
		}
		
		private function addTechStats(param1:Object, param2:int):void
		{
			var _loc11_:Object = null;
			var _loc12_:int = 0;
			if (param2 > 6)
			{
				param2 = 6;
			}
			var _loc6_:int = 100;
			var _loc10_:int = 100;
			var _loc4_:int = 100;
			var _loc7_:int = 100;
			var _loc3_:int = 100;
			var _loc5_:int = 100;
			var _loc9_:int = 100;
			var _loc8_:int = 100;
			_loc12_ = 0;
			while (_loc12_ < param2)
			{
				_loc11_ = param1.techLevels[_loc12_];
				_loc6_ += _loc11_.incDmg;
				if (debuffValue != null && Boolean(_loc11_.hasOwnProperty("dot")))
				{
					debuffValue.addBaseDmg(_loc11_.dot);
				}
				if (_loc11_.hasOwnProperty("dotDuration"))
				{
					debuffDuration += _loc11_.dotDuration;
				}
				_loc10_ += _loc11_.incReloadRate;
				_loc4_ += _loc11_.incRange;
				_loc7_ += _loc11_.incSpeed;
				_loc3_ += _loc11_.incAcceleration;
				_loc5_ += _loc11_.incSpread;
				_loc9_ += _loc11_.incRotationSpeed;
				if (_loc11_.hasOwnProperty("incAimArc"))
				{
					_loc8_ += _loc11_.incAimArc;
				}
				if (_loc11_.hasOwnProperty("radius"))
				{
					dmgRadius += _loc11_.radius;
				}
				if (_loc11_.hasOwnProperty("radius"))
				{
					maxProjectiles += _loc11_.incMaxProjectiles;
				}
				if (_loc12_ == param2 - 1)
				{
					if (_loc11_.hasOwnProperty("heatCost"))
					{
						heatCost = Number(_loc11_.heatCost) / 1000;
					}
					if (_loc11_.hasOwnProperty("numberOfHits"))
					{
						numberOfHits = _loc11_.numberOfHits;
					}
					if (_loc11_.hasOwnProperty("shieldVamp"))
					{
						shieldVamp = _loc11_.shieldVamp;
					}
					if (_loc11_.hasOwnProperty("healthVamp"))
					{
						healthVamp = _loc11_.healthVamp;
					}
					positionYVariance = _loc11_.positionVariance;
				}
				multiNrOfP += _loc11_.incMultiNrOfP;
				multiOffset += _loc11_.incMultiOffset;
				multiAngleOffset += Util.degreesToRadians(_loc11_.incMultiAngleOffset);
				_loc12_++;
			}
			dmg.setBaseDmg(dmg.dmg() * _loc6_ / 100);
			speed = speed * _loc7_ / 100;
			range = range * _loc4_ / 100;
			reloadTime = reloadTime * 100 / _loc10_;
			ttl = ttl * _loc4_ / 100;
			acceleration = acceleration * _loc3_ / 100;
			aimArc = aimArc * _loc8_ / 100;
			rotationSpeed = rotationSpeed * _loc9_ / 100;
		}
		
		private function addEliteTechStats(param1:Object, param2:int, param3:String):void
		{
			EliteTechs.addWeaponEliteTechs(this, param1, param2, param3);
		}
		
		override public function update():void
		{
			if (_fire && unit.isAddedToCanvas)
			{
				if (fireCallback != null && this.hasChargeUp == false)
				{
					fireCallback();
				}
				pos.x = unit.x;
				pos.y = unit.y;
				shoot();
			}
		}
		
		protected function shoot():void
		{
			throw new IllegalOperationError("Abstract method must be overriden");
		}
		
		public function set fire(param1:Boolean):void
		{
			var _loc2_:PlayerShip = null;
			if (hasChargeUp && chargeUpTime > 0 && unit is PlayerShip)
			{
				_loc2_ = unit as PlayerShip;
				_loc2_.killChargeUpEffect();
				if (_loc2_.player.isMe)
				{
					g.hud.powerBar.updateLoadBar(0);
				}
			}
			if (g.time - lastFire > reloadTime)
			{
				lastFire = 0;
				burstCurrent = 0;
			}
			chargeUpTime = 0;
			_fire = param1;
		}
		
		public function get fire():Boolean
		{
			return _fire;
		}
		
		public function destroy():void
		{
			alive = false;
		}
		
		public function playFireSound():void
		{
			var _loc3_:Point = g.camera.getCameraCenter();
			var _loc1_:Number = _loc3_.x - unit.x;
			var _loc2_:Number = _loc3_.y - unit.y;
			if (_loc1_ * _loc1_ + _loc2_ * _loc2_ > 250000)
			{
				return;
			}
			var _loc4_:ISound = SoundLocator.getService();
			_loc4_.play(fireSound);
		}
		
		public function inRange(param1:Unit):Boolean
		{
			if (param1 == null)
			{
				return false;
			}
			if (!inAimAngle(param1))
			{
				return false;
			}
			var _loc3_:Number = unit.pos.x - param1.pos.x;
			var _loc4_:Number = unit.pos.y - param1.pos.y;
			var _loc2_:Number = _loc3_ * _loc3_ + _loc4_ * _loc4_ - param1.collisionRadius;
			return _loc2_ <= range * range;
		}
		
		public function aim():Number
		{
			var _loc8_:EnemyShip = null;
			if (target == null || unit == null)
			{
				return 0;
			}
			if (unit == target)
			{
				return unit.rotation;
			}
			var _loc4_:Point = target.speed;
			if (target is EnemyShip)
			{
				_loc8_ = target as EnemyShip;
				if (_loc8_.stateMachine.inState("AIOrbit"))
				{
					_loc4_ = _loc8_.calculateOrbitSpeed();
				}
			}
			var _loc5_:Number = target.pos.x - unit.pos.x;
			var _loc6_:Number = target.pos.y - unit.pos.y;
			var _loc7_:Number = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
			_loc5_ /= _loc7_;
			_loc6_ /= _loc7_;
			var _loc3_:Number = _loc7_ / (speed - Util.dotProduct(target.speed.x, target.speed.y, _loc5_, _loc6_));
			var _loc1_:Number = target.pos.x + _loc4_.x * _loc3_;
			var _loc2_:Number = target.pos.y + _loc4_.y * _loc3_;
			return Math.atan2(_loc2_ - unit.pos.y, _loc1_ - unit.pos.x) - unit.rotation;
		}
		
		private function inAimAngle(param1:Unit):Boolean
		{
			var _loc4_:Number = NaN;
			var _loc7_:int = 0;
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc5_:Number = NaN;
			if (this is SmartGun)
			{
				_loc4_ = aimArc;
			}
			else
			{
				_loc4_ = angleVariance;
			}
			_loc7_ = 0;
			while (_loc7_ < 4)
			{
				_loc2_ = 0;
				_loc3_ = 0;
				if (_loc7_ == 0)
				{
					_loc3_ = -param1.collisionRadius;
				}
				if (_loc7_ == 1)
				{
					_loc3_ = param1.collisionRadius;
				}
				if (_loc7_ == 2)
				{
					_loc2_ = -param1.collisionRadius;
				}
				if (_loc7_ == 3)
				{
					_loc2_ = param1.collisionRadius;
				}
				_loc6_ = Math.atan2(param1.pos.y - unit.pos.y + _loc2_, param1.pos.x - unit.pos.x + _loc3_);
				_loc5_ = Util.angleDifference(unit.rotation, _loc6_);
				if (Math.abs(_loc5_) < _loc4_)
				{
					return true;
				}
				_loc7_++;
			}
			return false;
		}
		
		override public function draw():void
		{
		}
		
		public function setActive(param1:PlayerShip, param2:Boolean):Boolean
		{
			if (param2 && param1.activeWeapons < param1.unlockedWeaponSlots)
			{
				active = param2;
				param1.activeWeapons++;
				return true;
			}
			if (!param2)
			{
				active = param2;
				param1.activeWeapons--;
				return true;
			}
			return false;
		}
		
		override public function reset():void
		{
			projectileFunction = null;
			active = true;
			hotkey = 0;
			unit = null;
			dmg = null;
			dmgRadius = 0;
			debuffValue = null;
			debuffDuration = 0;
			debuffType = -1;
			debuffValue2 = null;
			debuffDuration2 = 0;
			debuffType2 = -1;
			fireBackwards = false;
			specialCondition = null;
			specialBonusPercentage = 0;
			numberOfHits = 0;
			reloadTime = 0;
			fireNextTime = 0;
			speed = 0;
			acceleration = 0;
			friction = 0;
			range = 0;
			ttl = 0;
			rotation = 0;
			heatCost = 0;
			maxProjectiles = 0;
			projectiles = new Vector.<Projectile>();
			multiNrOfP = 1;
			sideShooter = false;
			multiOffset = 0;
			multiAngleOffset = 0;
			name = null;
			type = null;
			angleVariance = 0;
			positionYVariance = 0;
			positionXVariance = 0;
			positionOffsetX = 0;
			positionOffsetY = 0;
			rotationSpeed = 0;
			aimArc = 0;
			fireSound = "";
			_fire = false;
			target = null;
			debuffEffect = null;
			useShipSystem = false;
			randomAngle = false;
			isMissileWeapon = false;
			waveDirection = 1;
			global = false;
			super.reset();
		}
	}
}
