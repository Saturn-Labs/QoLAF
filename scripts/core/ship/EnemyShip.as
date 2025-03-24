package core.ship {
	import com.greensock.TweenMax;
	import core.hud.components.Style;
	import core.hud.components.TextBitmap;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.spawner.Spawner;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import movement.Heading;
	import starling.filters.ColorMatrixFilter;
	
	public class EnemyShip extends Ship {
		public static const RARE_TYPE_NORMAL:int = 0;
		
		public static const RARE_TYPE_DEFENDER:int = 1;
		
		public static const RARE_TYPE_ATTACKER:int = 2;
		
		public static const RARE_TYPE_SPEEDER:int = 3;
		
		public static const RARE_TYPE_LEGENDARY:int = 4;
		
		public static const RARE_TYPE_UNIQUE:int = 5;
		
		public static const RARE_TYPE_PET:int = 6;
		
		public static const RIGHT:int = 1;
		
		public static const LEFT:int = -1;
		
		public var aggroRange:int;
		
		public var chaseRange:int;
		
		public var aimSkill:Number;
		
		public var stopWhenClose:Boolean;
		
		public var observer:Boolean;
		
		public var visionRange:int;
		
		public var nextTurnDir:int;
		
		public var flee:Boolean;
		
		public var fleeLifeTreshhold:int;
		
		public var fleeDuration:int;
		
		public var fleeClose:int;
		
		public var sniper:Boolean;
		
		public var sniperMinRange:Number;
		
		public var teleport:Boolean;
		
		private var kamikazeFilter:ColorMatrixFilter;
		
		private var kamikazeStarted:Boolean;
		
		public var kamikaze:Boolean;
		
		public var kamikazeLifeTreshhold:int;
		
		public var kamikazeDmg:int;
		
		public var kamikazeRadius:int;
		
		public var kamikazeTtl:int;
		
		public var kamikazeHoming:Boolean;
		
		public var kamikazeEffect:String = "-Gx9QanEEUKc1ADl5B6nxg";
		
		public var kamikazeWhenClose:Boolean;
		
		public var melee:Boolean;
		
		public var meleeCharge:Boolean;
		
		public var meleeChargeSpeedBonus:Number;
		
		public var meleeChargeDuration:int;
		
		public var meleeChargeCoolDown:int;
		
		public var meleeCanGrab:Boolean;
		
		public var meleeStuck:Boolean;
		
		public var meleeOffset:Point;
		
		public var meleeTargetStartAngle:Number;
		
		public var meleeTargetAngleDiff:Number;
		
		public var meleeChargeEndTime:Number;
		
		public var oldSpeed:Number;
		
		public var oldTurningSpeed:Number;
		
		public var alwaysFire:Boolean;
		
		public var orbitSpawner:Boolean;
		
		public var hasOrbitData:Boolean = false;
		
		public var spawner:Spawner;
		
		public var angleVelocity:Number;
		
		public var orbitAngle:Number;
		
		public var orbitRadius:Number;
		
		public var ellipseFactor:Number;
		
		public var ellipseAlpha:Number;
		
		public var orbitStartTime:Number;
		
		public var aiCloak:Boolean;
		
		public var aiHardenShield:Boolean;
		
		public var aiHardenShieldDuration:Number;
		
		public var aiHardenShieldEndtime:Number;
		
		private var aiHardenedShieldEffect:Vector.<Emitter> = new Vector.<Emitter>();
		
		public var rareType:int = 0;
		
		public var target:Unit;
		
		public var weaponRanges:Vector.<WeaponRange> = new Vector.<WeaponRange>();
		
		public var escapeWeapon:Weapon;
		
		public var antiProjectileWeapon:Weapon;
		
		public var chargeEffect:Vector.<Emitter> = new Vector.<Emitter>();
		
		private var AFName:TextBitmap;
		
		private var rareEmitters:Vector.<Emitter> = new Vector.<Emitter>();
		
		private var sign:int = 1;
		
		public function EnemyShip(g:Game) {
			canvas = g.canvasEnemyShips;
			super(g);
		}
		
		public function stopShooting() : void {
			for each(var _local1 in weapons) {
				_local1.fire = false;
			}
		}
		
		override public function addToCanvas() : void {
			addAFName();
			super.addToCanvas();
		}
		
		override public function addToCanvasForReal() : void {
			addAFName();
			rareEmitters = EmitterFactory.createRareType(g,this,this.rareType);
			super.addToCanvasForReal();
		}
		
		override public function removeFromCanvas() : void {
			if(hasFaction("AF") && AFName != null) {
				g.canvasTexts.removeChild(AFName);
			}
			for each(var _local1 in rareEmitters) {
				_local1.killEmitter();
			}
			rareEmitters.length = 0;
			super.removeFromCanvas();
		}
		
		private function addAFName() : void {
			if(owner != null) {
				if(AFName == null) {
					AFName = new TextBitmap();
					AFName.text = name;
					AFName.batchable = true;
					AFName.center();
					AFName.blendMode = "add";
				}
				if(owner == g.me.ship) {
					AFName.format.color = Style.COLOR_LIGHT_GREEN;
				} else if(g.isSystemTypeDeathMatch()) {
					AFName.format.color = Style.COLOR_HOSTILE;
				} else if(g.isSystemTypeDomination()) {
					AFName.format.color = owner.team == g.me.team ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
				} else if(g.isSystemPvPEnabled()) {
					AFName.format.color = owner.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_HOSTILE;
				} else {
					AFName.format.color = owner.group == g.me.group ? Style.COLOR_LIGHT_GREEN : Style.COLOR_FRIENDLY;
				}
				g.canvasTexts.addChild(AFName);
			} else if(hasFaction("AF")) {
				if(AFName == null) {
					AFName = new TextBitmap();
					AFName.text = name;
					AFName.format.color = Style.COLOR_FRIENDLY;
					AFName.center();
				}
				g.canvasTexts.addChild(AFName);
			}
		}
		
		override public function update() : void {
			if(aiHardenShield && aiHardenShieldEndtime < g.time) {
				aiHardenShield = false;
				for each(var _local1 in aiHardenedShieldEffect) {
					_local1.killEmitter();
				}
			}
			super.update();
		}
		
		public function cloakStart() : void {
			TweenMax.to(_mc,1,{
				"alpha":0,
				"onComplete":function():void {
					course.pos.x = 2411242;
					course.pos.y = 8942522;
					clearConvergeTarget();
					aiCloak = true;
				}
			});
		}
		
		public function cloakEnd(heading:Heading) : void {
			course = heading;
			TweenMax.to(_mc,1,{"alpha":1});
			clearConvergeTarget();
			aiCloak = false;
			addToCanvasForReal();
		}
		
		public function hardenShield() : void {
			aiHardenShield = true;
			aiHardenShieldEndtime = g.time + aiHardenShieldDuration;
			aiHardenedShieldEffect = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw",g,pos.x,pos.y,this,true);
		}
		
		public function startKamikaze() : void {
			kamikazeStarted = true;
			if(kamikazeFilter == null) {
				kamikazeFilter = new ColorMatrixFilter();
				kamikazeFilter.invert();
			}
			runKamikazeEffect();
		}
		
		private function runKamikazeEffect(kamikazeSteps:int = -1) : void {
			if(kamikazeSteps == -1) {
				kamikazeSteps = kamikazeTtl * 2 * 2 * 2;
			}
			TweenMax.delayedCall(0.125,function():void {
				if(!kamikazeStarted) {
					return;
				}
				kamikazeSteps--;
				if(sign > 0) {
					_mc.blendMode = "add";
					_mc.filter = kamikazeFilter;
					_mc.filter.cache();
				} else {
					_mc.blendMode = "normal";
					_mc.filter = null;
				}
				sign *= -1;
				if(kamikazeSteps > 0 || kamikazeWhenClose) {
					runKamikazeEffect(kamikazeSteps);
				} else {
					_mc.filter = null;
				}
			});
		}
		
		override public function destroy(explode:Boolean = true) : void {
			if(stateMachine.inState("AITeleport") || stateMachine.inState("AITeleportEntry") || stateMachine.inState("AITeleportExit")) {
				stateMachine.exitCurrent();
			}
			if(kamikazeStarted) {
				EmitterFactory.create(kamikazeEffect,g,pos.x,pos.y,null,true);
			}
			super.destroy(explode);
		}
		
		public function set roll(value:Boolean) : void {
			if(course != null) {
				course.roll = value;
			}
		}
		
		public function get roll() : Boolean {
			if(course != null) {
				return course.roll;
			}
			return false;
		}
		
		public function calculateOrbitSpeed() : Point {
			var _local1:Number = g.time;
			var _local4:Number = orbitAngle + angleVelocity * 33 / 1000 * (_local1 - orbitStartTime);
			var _local5:Number = orbitRadius * ellipseFactor * Math.cos(_local4);
			var _local3:Number = orbitRadius * Math.sin(_local4);
			var _local2:Number = orbitAngle + angleVelocity * 33 / 1000 * (_local1 - 33 - orbitStartTime);
			_local5 -= orbitRadius * ellipseFactor * Math.cos(_local2);
			_local3 -= orbitRadius * Math.sin(_local2);
			return new Point((_local5 * Math.cos(ellipseAlpha) - _local3 * Math.sin(ellipseAlpha)) * 1000 / 33,(_local5 * Math.sin(ellipseAlpha) + _local3 * Math.cos(ellipseAlpha)) * 1000 / 33);
		}
		
		override public function reset() : void {
			weaponRanges.splice(0,weaponRanges.length);
			escapeWeapon = null;
			xp = 0;
			level = 1;
			aggroRange = 0;
			chaseRange = 0;
			teleport = false;
			observer = false;
			visionRange = 0;
			stopWhenClose = true;
			flee = false;
			fleeLifeTreshhold = 0;
			fleeDuration = 0;
			fleeClose = 0;
			kamikazeStarted = false;
			kamikaze = false;
			kamikazeLifeTreshhold = 0;
			kamikazeTtl = 0;
			kamikazeDmg = 0;
			kamikazeRadius = 0;
			kamikazeHoming = false;
			kamikazeWhenClose = false;
			aiHardenShieldEndtime = 0;
			aiHardenShield = false;
			nextTurnDir = 1;
			if(kamikazeFilter) {
				kamikazeFilter.dispose();
				kamikazeFilter = null;
			}
			melee = false;
			meleeCharge = false;
			meleeChargeSpeedBonus = 0;
			meleeChargeDuration = 0;
			meleeChargeCoolDown = 0;
			meleeCanGrab = false;
			meleeStuck = false;
			meleeTargetStartAngle = 0;
			meleeTargetAngleDiff = 0;
			meleeChargeEndTime = 0;
			oldSpeed = 0;
			oldTurningSpeed = 0;
			sniper = false;
			sniperMinRange = 0;
			orbitSpawner = false;
			hasOrbitData = false;
			angleVelocity = 0;
			orbitAngle = 0;
			orbitRadius = 0;
			orbitStartTime = 0;
			ellipseAlpha = 0;
			ellipseFactor = 0;
			AFName = null;
			rareType = 0;
			super.reset();
		}
		
		override public function draw() : void {
			if(AFName != null) {
				AFName.x = x;
				AFName.y = y - 30;
			}
			super.draw();
		}
		
		override public function get type() : String {
			return "enemyShip";
		}
	}
}

