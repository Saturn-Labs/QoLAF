package core.weapon {
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
	
	public class Weapon extends GameObject {
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
		
		public function Weapon(g:Game) {
			super();
			chargeUpTime = 0;
			heatCost = 0;
			this.g = g;
		}
		
		public function init(obj:Object, techLevel:int, eliteTechLevel:int = -1, eliteTech:String = "") : void {
			var _local6:int = 0;
			var _local5:ISound = null;
			this.type = obj.type;
			name = obj.name;
			if(obj.hasOwnProperty("damageType")) {
				_local6 = int(obj.damageType);
			}
			dmg = new Damage(obj.dmg,_local6);
			if(obj.hasOwnProperty("shieldVamp")) {
				shieldVamp = obj.shieldVamp;
			} else {
				shieldVamp = 0;
			}
			if(obj.hasOwnProperty("healthVamp")) {
				healthVamp = obj.healthVamp;
			} else {
				healthVamp = 0;
			}
			if(obj.hasOwnProperty("burst")) {
				burst = obj.burst;
			} else {
				burst = 1;
			}
			if(obj.hasOwnProperty("burstDelay")) {
				burstDelay = obj.burstDelay;
			} else {
				burstDelay = 30;
			}
			if(obj.hasOwnProperty("debuffType") && Boolean(obj.hasOwnProperty("dot")) && Boolean(obj.hasOwnProperty("dotDamageType")) && Boolean(obj.hasOwnProperty("dotDuration"))) {
				debuffType = obj.debuffType;
				debuffValue = new Damage(obj.dot,obj.dotDamageType);
				debuffDuration = obj.dotDuration;
				if(obj.hasOwnProperty("dotEffect")) {
					debuffEffect = obj.dotEffect;
				}
			} else if(this is Cloak) {
				debuffType = -1;
				debuffDuration = obj.dotDuration;
				debuffValue = new Damage(0,0);
				debuffEffect = "";
			} else {
				debuffType = -1;
				debuffValue = new Damage(0,1);
				debuffDuration = 0;
			}
			debuffType2 = -1;
			debuffValue2 = new Damage(0,1);
			debuffDuration2 = 0;
			if(obj.hasOwnProperty("heatCost")) {
				heatCost = Number(obj.heatCost) / 1000;
			} else {
				heatCost = 0;
			}
			if(obj.hasOwnProperty("numberOfHits")) {
				numberOfHits = obj.numberOfHits;
			} else {
				numberOfHits = 1;
			}
			speed = obj.speed;
			reloadTime = obj.reloadTime;
			ttl = obj.ttl;
			acceleration = obj.acceleration;
			rotationSpeed = obj.rotationSpeed;
			positionYVariance = obj.positionVariance;
			if(obj.hasOwnProperty("positionXVariance")) {
				positionXVariance = obj.positionXVariance;
			} else {
				positionXVariance = 0;
			}
			if(obj.hasOwnProperty("multiSideFire")) {
				sideShooter = obj.multiSideFire;
			} else {
				sideShooter = false;
			}
			if(obj.hasOwnProperty("positionOffset")) {
				positionOffsetX = obj.positionOffset;
			}
			if(obj.hasOwnProperty("positionOffsetY")) {
				positionOffsetY = obj.positionOffsetY;
			}
			if(obj.hasOwnProperty("friction")) {
				friction = obj.friction;
			}
			maxProjectiles = obj.maxProjectiles;
			if(maxProjectiles > 0) {
				ttl = 2 * 60 * 1000;
			}
			multiNrOfP = obj.multiNrOfP;
			multiOffset = obj.multiOffset;
			multiAngleOffset = Util.degreesToRadians(obj.multiAngleOffset);
			angleVariance = obj.angleVariance;
			if(obj.hasOwnProperty("aimArc")) {
				aimArc = obj.aimArc;
			}
			fireSound = obj.fireSound;
			if(fireSound != null) {
				_local5 = SoundLocator.getService();
				_local5.preCacheSound(fireSound);
			}
			hasTechTree = obj.hasTechTree;
			if(obj.hasOwnProperty("multiSpreadStart")) {
				multiSpreadStart = obj.multiSpreadStart;
			} else {
				multiSpreadStart = false;
			}
			if(obj.hasOwnProperty("radius")) {
				dmgRadius = obj.radius;
			} else {
				dmgRadius = 0;
			}
			range = obj.range;
			if(hasTechTree) {
				techIconFileName = obj.techIcon;
				level = techLevel;
				if(techLevel > 0) {
					addTechStats(obj,techLevel);
				}
				if(eliteTechLevel > 0) {
					addEliteTechStats(obj,eliteTechLevel,eliteTech);
				}
				triggerMeleeAnimation = obj.triggerMeleeAnimation;
			}
			if(this is Cloak) {
				reloadTime += 3 * debuffDuration * 1000;
				trace("weapon init cloak reloadtime: " + reloadTime);
			}
			global = obj.global;
		}
		
		public function addDebuff(type:int, duration:int, value:Damage, effect:String) : void {
			if(debuffType == -1) {
				debuffType = type;
				debuffDuration = duration;
				debuffEffect = effect;
				debuffValue = value;
				return;
			}
			if(debuffType == type && debuffValue.type == value.type) {
				debuffEffect = effect;
				debuffValue.addBaseDmg(value.dmg());
				return;
			}
			if(debuffType2 == -1) {
				debuffType2 = type;
				debuffDuration2 = duration;
				debuffEffect2 = effect;
				debuffValue2 = value;
			}
		}
		
		public function removeDebuff(type:int, value:Damage) : void {
			if(debuffType == type && debuffValue.type == value.type) {
				if(Math.abs(debuffValue.dmg() - value.dmg()) < 0.01) {
					debuffType = -1;
					debuffDuration = 0;
					debuffEffect = "";
					debuffValue = new Damage(0,1);
				} else {
					debuffValue.addBaseDmg(-value.dmg());
				}
			}
			if(debuffType2 == type && debuffValue2.type == value.type) {
				debuffType2 = -1;
				debuffDuration2 = 0;
				debuffEffect2 = "";
				debuffValue2 = new Damage(0,1);
			}
		}
		
		public function getDescription(isBeam:Boolean) : String {
			var _local3:String = null;
			var _local2:PetSpawner = null;
			_local3 = Localize.t("<FONT COLOR=\'#8888ff\'>[name], lvl [level]</FONT>\n").replace("[name]",name).replace("[level]",level);
			_local3 += dmg.damageText();
			if(multiNrOfP > 1) {
				_local3 += Localize.t("Fires <FONT COLOR=\'#eeeeee\'>[nrp]</FONT>x projectiles\n").replace("[nrp]",multiNrOfP);
			}
			if(!isBeam && name != "Acid Spray" && name != "Flamethrower") {
				_local3 += Localize.t("Fires <FONT COLOR=\'#eeeeee\'>[rps]</FONT> rounds per second.\n").replace("[rps]",(1000 * multiNrOfP / reloadTime).toFixed(1));
			}
			if(multiNrOfP == 0) {
				_local3 += Localize.t("Damage per second: <FONT COLOR=\'#eeeeee\'>[dps]</FONT>\n").replace("[dps]",(dmg.dmg() * burst * 1000 / (reloadTime + (burst - 1) * 33)).toFixed(1));
			} else {
				_local3 += Localize.t("Damage per second: <FONT COLOR=\'#eeeeee\'>[dps]</FONT>\n").replace("[dps]",(dmg.dmg() * burst * multiNrOfP * 1000 / (reloadTime + (burst - 1) * 33)).toFixed(1));
			}
			if(shieldVamp > 0 || healthVamp > 0) {
				_local3 += "\n";
				if(shieldVamp > 0) {
					_local3 += Localize.t("<FONT COLOR=\'#4444ff\'>Steals [shieldVamp]% of damage done to enemy shields</FONT>\n").replace("[shieldVamp]",shieldVamp);
				}
				if(healthVamp > 0) {
					_local3 += Localize.t("<FONT COLOR=\'#ff4444\'>Steals [healthVamp]% of damage done to enemy health</FONT>\n").replace("[healthVamp]",healthVamp);
				}
			}
			if(debuffType > -1 || debuffType2 > -1) {
				_local3 += Localize.t("\nDebuff:\n");
				if(debuffDuration > 0) {
					_local3 += Debuff.debuffText(debuffType,debuffDuration,debuffValue);
				}
				if(debuffDuration2 > 0) {
					_local3 += Debuff.debuffText(debuffType2,debuffDuration2,debuffValue2);
				}
			}
			if(this is PetSpawner) {
				_local2 = this as PetSpawner;
				_local3 += Localize.t("\nMax number of Pets: [maxPets]").replace("[maxPets]",_local2.maxPets);
			}
			if(specialCondition != null && specialCondition != "") {
				_local3 += Localize.t("\nDeals <FONT COLOR=\'#eeeeee\'>" + specialBonusPercentage.toString() + "%</FONT> more damage if target is afflicted by " + specialCondition + ".");
			}
			return _local3;
		}
		
		private function addTechStats(obj:Object, techLevel:int) : void {
			var _local12:Object = null;
			var _local6:int = 0;
			if(techLevel > 6) {
				techLevel = 6;
			}
			var _local5:int = 100;
			var _local10:int = 100;
			var _local3:int = 100;
			var _local4:int = 100;
			var _local11:int = 100;
			var _local9:int = 100;
			var _local7:int = 100;
			var _local8:int = 100;
			_local6 = 0;
			while(_local6 < techLevel) {
				_local12 = obj.techLevels[_local6];
				_local5 += _local12.incDmg;
				if(debuffValue != null && Boolean(_local12.hasOwnProperty("dot"))) {
					debuffValue.addBaseDmg(_local12.dot);
				}
				if(_local12.hasOwnProperty("dotDuration")) {
					debuffDuration += _local12.dotDuration;
				}
				_local10 += _local12.incReloadRate;
				_local3 += _local12.incRange;
				_local4 += _local12.incSpeed;
				_local11 += _local12.incAcceleration;
				_local9 += _local12.incSpread;
				_local7 += _local12.incRotationSpeed;
				if(_local12.hasOwnProperty("incAimArc")) {
					_local8 += _local12.incAimArc;
				}
				if(_local12.hasOwnProperty("radius")) {
					dmgRadius += _local12.radius;
				}
				if(_local12.hasOwnProperty("radius")) {
					maxProjectiles += _local12.incMaxProjectiles;
				}
				if(_local6 == techLevel - 1) {
					if(_local12.hasOwnProperty("heatCost")) {
						heatCost = Number(_local12.heatCost) / 1000;
					}
					if(_local12.hasOwnProperty("numberOfHits")) {
						numberOfHits = _local12.numberOfHits;
					}
					if(_local12.hasOwnProperty("shieldVamp")) {
						shieldVamp = _local12.shieldVamp;
					}
					if(_local12.hasOwnProperty("healthVamp")) {
						healthVamp = _local12.healthVamp;
					}
					positionYVariance = _local12.positionVariance;
				}
				multiNrOfP += _local12.incMultiNrOfP;
				multiOffset += _local12.incMultiOffset;
				multiAngleOffset += Util.degreesToRadians(_local12.incMultiAngleOffset);
				_local6++;
			}
			dmg.setBaseDmg(dmg.dmg() * _local5 / 100);
			speed = speed * _local4 / 100;
			range = range * _local3 / 100;
			reloadTime = reloadTime * 100 / _local10;
			ttl = ttl * _local3 / 100;
			acceleration = acceleration * _local11 / 100;
			aimArc = aimArc * _local8 / 100;
			rotationSpeed = rotationSpeed * _local7 / 100;
		}
		
		private function addEliteTechStats(obj:Object, eliteTechLevel:int, eliteTech:String) : void {
			EliteTechs.addWeaponEliteTechs(this,obj,eliteTechLevel,eliteTech);
		}
		
		override public function update() : void {
			if(_fire && unit.isAddedToCanvas) {
				if(fireCallback != null && this.hasChargeUp == false) {
					fireCallback();
				}
				pos.x = unit.x;
				pos.y = unit.y;
				shoot();
			}
		}
		
		protected function shoot() : void {
			throw new IllegalOperationError("Abstract method must be overriden");
		}
		
		public function set fire(value:Boolean) : void {
			var _local2:PlayerShip = null;
			if(hasChargeUp && chargeUpTime > 0 && unit is PlayerShip) {
				_local2 = unit as PlayerShip;
				_local2.killChargeUpEffect();
				if(_local2.player.isMe) {
					g.hud.powerBar.updateLoadBar(0);
				}
			}
			if(g.time - lastFire > reloadTime) {
				lastFire = 0;
				burstCurrent = 0;
			}
			chargeUpTime = 0;
			_fire = value;
		}
		
		public function get fire() : Boolean {
			return _fire;
		}
		
		public function destroy() : void {
			alive = false;
		}
		
		public function playFireSound() : void {
			var _local1:Point = g.camera.getCameraCenter();
			var _local4:Number = _local1.x - unit.x;
			var _local3:Number = _local1.y - unit.y;
			if(_local4 * _local4 + _local3 * _local3 > 250000) {
				return;
			}
			var _local2:ISound = SoundLocator.getService();
			_local2.play(fireSound);
		}
		
		public function inRange(target:Unit) : Boolean {
			if(target == null) {
				return false;
			}
			if(!inAimAngle(target)) {
				return false;
			}
			var _local3:Number = unit.pos.x - target.pos.x;
			var _local2:Number = unit.pos.y - target.pos.y;
			var _local4:Number = _local3 * _local3 + _local2 * _local2 - target.collisionRadius;
			return _local4 <= range * range;
		}
		
		public function aim() : Number {
			var _local8:EnemyShip = null;
			if(target == null || unit == null) {
				return 0;
			}
			if(unit == target) {
				return unit.rotation;
			}
			var _local5:Point = target.speed;
			if(target is EnemyShip) {
				_local8 = target as EnemyShip;
				if(_local8.stateMachine.inState("AIOrbit")) {
					_local5 = _local8.calculateOrbitSpeed();
				}
			}
			var _local6:Number = target.pos.x - unit.pos.x;
			var _local3:Number = target.pos.y - unit.pos.y;
			var _local1:Number = Math.sqrt(_local6 * _local6 + _local3 * _local3);
			_local6 /= _local1;
			_local3 /= _local1;
			var _local7:Number = _local1 / (speed - Util.dotProduct(target.speed.x,target.speed.y,_local6,_local3));
			var _local4:Number = target.pos.x + _local5.x * _local7;
			var _local2:Number = target.pos.y + _local5.y * _local7;
			return Math.atan2(_local2 - unit.pos.y,_local4 - unit.pos.x) - unit.rotation;
		}
		
		private function inAimAngle(target:Unit) : Boolean {
			var _local3:Number = NaN;
			var _local7:int = 0;
			var _local2:Number = NaN;
			var _local4:Number = NaN;
			var _local5:Number = NaN;
			var _local6:Number = NaN;
			if(this is SmartGun) {
				_local3 = aimArc;
			} else {
				_local3 = angleVariance;
			}
			_local7 = 0;
			while(_local7 < 4) {
				_local2 = 0;
				_local4 = 0;
				if(_local7 == 0) {
					_local4 = -target.collisionRadius;
				}
				if(_local7 == 1) {
					_local4 = target.collisionRadius;
				}
				if(_local7 == 2) {
					_local2 = -target.collisionRadius;
				}
				if(_local7 == 3) {
					_local2 = target.collisionRadius;
				}
				_local5 = Math.atan2(target.pos.y - unit.pos.y + _local2,target.pos.x - unit.pos.x + _local4);
				_local6 = Util.angleDifference(unit.rotation,_local5);
				if(Math.abs(_local6) < _local3) {
					return true;
				}
				_local7++;
			}
			return false;
		}
		
		override public function draw() : void {
		}
		
		public function setActive(s:PlayerShip, value:Boolean) : Boolean {
			if(value && s.activeWeapons < s.unlockedWeaponSlots) {
				active = value;
				s.activeWeapons++;
				return true;
			}
			if(!value) {
				active = value;
				s.activeWeapons--;
				return true;
			}
			return false;
		}
		
		override public function reset() : void {
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

