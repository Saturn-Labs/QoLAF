package core.unit {
	import com.greensock.TweenMax;
	import core.GameObject;
	import core.boss.Boss;
	import core.boss.Trigger;
	import core.group.Group;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.EnemyShip;
	import core.ship.PlayerShip;
	import core.spawner.Spawner;
	import core.states.StateMachine;
	import core.text.TextParticle;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.filters.ColorMatrixFilter;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Unit extends GameObject {
		private static const HP_MAXWIDTH:int = 20;
		
		private static const HP_MINWIDTH:int = 10;
		
		private static const HP_MAXWIDTH_PVP:int = 50;
		
		private var damageFilter:ColorMatrixFilter;
		
		private var healFilter:ColorMatrixFilter;
		
		protected var hpBar:Image;
		
		protected var shieldBar:Image;
		
		private var _bodyName:String;
		
		public var syncId:int;
		
		public var parentObj:GameObject;
		
		public var disableHealEndtime:Number;
		
		public var slowDownEndtime:Number;
		
		public var slowDown:Number;
		
		public var nextHitEffectReady:Number = 0;
		
		public var lastDmgText:TextParticle;
		
		public var lastDmgTextOffset:int;
		
		public var lastDmgTime:Number;
		
		public var lastDmg:int;
		
		public var lastHealText:TextParticle;
		
		public var lastHealTextOffset:int;
		
		public var lastHealTime:Number;
		
		public var lastHeal:int;
		
		public var team:int;
		
		public var stateMachine:StateMachine;
		
		public var hasDmgBoost:Boolean;
		
		public var dmgBoostCD:int;
		
		public var dmgBoostNextRdy:Number;
		
		public var dmgBoostEndTime:Number;
		
		public var dmgBoostDuration:int;
		
		public var dmgBoostCost:Number;
		
		public var usingDmgBoost:Boolean;
		
		public var dmgBoostBonus:Number;
		
		public var alive:Boolean;
		
		public var uberDifficulty:Number;
		
		public var uberLevelFactor:Number;
		
		public var hp:int;
		
		private var _hpMax:int;
		
		public var armorThreshold:int;
		
		public var armorThresholdBase:int;
		
		public var shieldHp:int;
		
		protected var _shieldHpMax:int;
		
		public var xp:int;
		
		public var level:int;
		
		public var collisionRadius:Number;
		
		public var explosionEffect:String;
		
		public var explosionSound:String;
		
		public var shieldRegen:int;
		
		public var shieldRegenBase:int;
		
		public var shieldRegenCounter:int = 0;
		
		public var shieldRegenDuration:int = 1000;
		
		public var shieldRegenBonus:Number = 1;
		
		public var hpRegen:Number;
		
		public var hpRegenCounter:int;
		
		public var hpRegenDuration:int = 1000;
		
		public var invulnerable:Boolean = false;
		
		public var essential:Boolean = true;
		
		public var resistances:Vector.<Number>;
		
		private var barMaxWidth:int = 0;
		
		private var isFlashing:Boolean = false;
		
		protected var g:Game;
		
		private var _speed:Point;
		
		public var weaponPos:Point;
		
		public var enginePos:Point;
		
		public var group:Group;
		
		public var factions:Vector.<String>;
		
		public var isHostile:Boolean;
		
		public var dotTimers:Vector.<TweenMax>;
		
		public var dotEffect:String;
		
		public var obj:Object;
		
		public var active:Boolean = true;
		
		public var hideIfInactive:Boolean;
		
		public var triggersToActivte:int = 1;
		
		public var triggers:Vector.<Trigger>;
		
		public var lastBulletLocal:Number = 0;
		
		public var lastBulletGlobal:Number = 0;
		
		public var lastBulletTargetList:Vector.<Unit> = null;
		
		public var isBossUnit:Boolean = false;
		
		public var forceupdate:Boolean;
		
		public var originalFilter:ColorMatrixFilter;
		
		public var owner:PlayerShip = null;
		
		public var isInjured:Boolean = false;
		
		private var miniBarsAreAddedToCanvas:Boolean = false;
		
		public function Unit(g:Game) {
			var _local2:int = 0;
			stateMachine = new StateMachine();
			factions = new Vector.<String>();
			this.g = g;
			_speed = new Point();
			enginePos = new Point();
			weaponPos = new Point();
			resistances = new Vector.<Number>();
			_local2 = 0;
			while(_local2 < 5) {
				resistances.push(0);
				_local2++;
			}
			var _local3:ITextureManager = TextureLocator.getService();
			hpBar = new Image(_local3.getTextureMainByTextureName("scale_image"));
			hpBar.scale9Grid = new Rectangle(1,1,8,8);
			hpBar.height = 3;
			hpBar.width = 50;
			hpBar.color = 0x55ff55;
			hpBar.visible = false;
			shieldBar = new Image(_local3.getTextureMainByTextureName("scale_image"));
			shieldBar.scale9Grid = new Rectangle(1,1,8,8);
			shieldBar.height = 3;
			shieldBar.width = 50;
			shieldBar.color = 0x3377ff;
			shieldBar.visible = false;
			dotTimers = new Vector.<TweenMax>();
			triggers = new Vector.<Trigger>();
			if(healFilter == null) {
				healFilter = new ColorMatrixFilter();
				healFilter.adjustBrightness(0.5);
				damageFilter = new ColorMatrixFilter();
				damageFilter.adjustBrightness(0.5);
			}
			super();
		}
		
		override public function update() : void {
			if(nextDistanceCalculation <= 0) {
				updateIsNear();
			} else {
				nextDistanceCalculation -= 33;
			}
			super.update();
		}
		
		private function updateIsNear() : void {
			if(g.me.ship == null || g.me.ship == this || isBossUnit && !(this is EnemyShip)) {
				return;
			}
			var _local3:Point = this.pos;
			var _local1:Point = g.camera.getCameraCenter();
			distanceToCameraX = _local3.x - _local1.x;
			distanceToCameraY = _local3.y - _local1.y;
			var _local4:Number = g.stage.stageWidth;
			distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			var _local2:Number = distanceToCamera - _local4;
			nextDistanceCalculation = _local2 / (10 * 60) * 100;
			if(nextDistanceCalculation > 5000) {
				nextDistanceCalculation = 5000;
			}
			if(distanceToCamera < _local4) {
				if(isAddedToCanvas) {
					return;
				}
				addToCanvasForReal();
			} else {
				forceupdate = true;
				if(!isAddedToCanvas) {
					return;
				}
				removeFromCanvas();
			}
		}
		
		public function updateHealthBars() : void {
			if(miniBarsAreAddedToCanvas) {
				hpBar.visible = true;
				shieldBar.visible = true;
				hpBar.width = barMaxWidth * hp / _hpMax;
				if(hpBar.width > barMaxWidth) {
					hpBar.width = barMaxWidth;
				}
				shieldBar.width = barMaxWidth * shieldHp / _shieldHpMax;
				if(shieldBar.width > barMaxWidth) {
					shieldBar.width = barMaxWidth;
				}
				if(shieldBar.width <= 0) {
					shieldBar.visible = false;
				}
				hpBar.color = 0x55ff55;
				shieldBar.color = 0x3377ff;
			}
			if(hp == _hpMax && shieldHp == _shieldHpMax) {
				isInjured = false;
			}
		}
		
		public function set shieldHpMax(value:int) : void {
			_shieldHpMax = value;
			if(shieldHp > value) {
				shieldHp = value;
			}
			adjustMiniHealthBar();
		}
		
		public function set hpMax(value:int) : void {
			_hpMax = value;
			if(hp > value) {
				hp = value;
			}
			adjustMiniHealthBar();
		}
		
		private function adjustMiniHealthBar() : void {
			if(g.solarSystem.isPvpSystemInEditor) {
				barMaxWidth = 50;
			} else {
				barMaxWidth = 10 + 0.1 * (_hpMax + _shieldHpMax);
				if(barMaxWidth > 20) {
					barMaxWidth = 20;
				}
			}
		}
		
		public function get hpMax() : int {
			return _hpMax;
		}
		
		public function get shieldHpMax() : int {
			return _shieldHpMax;
		}
		
		public function regenerateShield() : void {
			if(alive && shieldHp < _shieldHpMax) {
				if(shieldRegenCounter >= shieldRegenDuration) {
					shieldRegenCounter = 0;
					shieldHp += int(1.5 * (shieldRegen + shieldRegenBonus));
					if(shieldHp > _shieldHpMax) {
						shieldHp = _shieldHpMax;
					}
				}
				shieldRegenCounter += 33;
			}
		}
		
		public function regenerateHP() : void {
			if(alive && hp < _hpMax) {
				if(hpRegenCounter >= hpRegenDuration) {
					hpRegenCounter = 0;
					hp += int(hpRegen);
					if(hp > hpMax) {
						hp = _hpMax;
					}
				}
				hpRegenCounter += 33;
			}
		}
		
		public function canBeDamage(attacker:Unit, p:Projectile) : Boolean {
			var _local3:int = 0;
			var _local6:int = 0;
			var _local7:String = null;
			var _local4:int = 0;
			var _local5:int = 0;
			var _local9:PlayerShip = null;
			var _local10:* = this;
			if(p.isHeal) {
				if(attacker == this) {
					return false;
				}
				if(_local10.owner != null) {
					_local10 = owner;
				}
				if(attacker.owner != null) {
					attacker = attacker.owner;
				}
				if(g.solarSystem.isPvpSystemInEditor && this.isHostile && attacker.isHostile && attacker.team != -1 && this.team != -1) {
					if(attacker.team == this.team) {
						return true;
					}
					return false;
				}
				if(attacker is PlayerShip && _local10 is PlayerShip) {
					return true;
				}
				_local3 = int(_local10.factions.length);
				_local6 = int(attacker.factions.length);
				var _local8:String = "";
				_local4 = 0;
				while(_local4 < _local3) {
					_local7 = _local10.factions[_local4];
					_local5 = 0;
					while(_local5 < _local6) {
						_local8 = attacker.factions[_local5];
						if(_local7 == _local8) {
							return false;
						}
						_local5++;
					}
					_local4++;
				}
				if(!(attacker is PlayerShip) && _local10 is PlayerShip) {
					return true;
				}
				return false;
			}
			if(attacker == this || this.owner != null && this.owner == attacker) {
				return false;
			}
			if(_local10.owner != null) {
				_local10 = owner;
			}
			if(attacker.owner != null) {
				attacker = attacker.owner;
			}
			if(g.solarSystem.isPvpSystemInEditor && this.isHostile && attacker.isHostile && attacker.team != -1 && this.team != -1) {
				if(attacker.team == this.team) {
					return false;
				}
				return true;
			}
			if(!_local10.alive || _local10.invulnerable || !_local10.isHostile && !attacker.isHostile || attacker.group != null && _local10.group != null && (attacker.group.id == _local10.group.id && !g.solarSystem.isPvpSystemInEditor)) {
				return false;
			}
			if(_local10 is PlayerShip) {
				_local9 = _local10 as PlayerShip;
				if(_local9.player.invulnarable) {
					return false;
				}
				if(attacker is PlayerShip) {
					return true;
				}
			}
			_local3 = int(_local10.factions.length);
			_local6 = int(attacker.factions.length);
			_local7 = "";
			_local8 = "";
			_local4 = 0;
			while(_local4 < _local3) {
				_local7 = _local10.factions[_local4];
				_local5 = 0;
				while(_local5 < _local6) {
					_local8 = attacker.factions[_local5];
					if(_local7 == _local8) {
						return false;
					}
					_local5++;
				}
				_local4++;
			}
			return true;
		}
		
		public function takeDamage(dmg:int) : void {
			if(!isAddedToCanvas) {
				return;
			}
			if(dmg == 0) {
				return;
			}
			isInjured = true;
			if(dmg < 0) {
				damageFlash(dmg,false,true);
			} else if(shieldHp >= dmg) {
				damageFlash(dmg,false);
			} else {
				damageFlash(dmg);
			}
			g.textManager.createDmgText(dmg,this);
		}
		
		private function damageFlash(dmg:int, hpDamage:Boolean = true, heal:Boolean = false) : void {
			if(RymdenRunt.isBuggedFlashVersion) {
				return;
			}
			if(isFlashing) {
				return;
			}
			isFlashing = true;
			if(heal) {
				_mc.filter = healFilter;
			} else {
				_mc.filter = damageFilter;
			}
			_mc.filter.cache();
			TweenMax.delayedCall(0.08,function():void {
				isFlashing = false;
				_mc.filter = originalFilter == null ? null : originalFilter;
				if(_mc.filter) {
					_mc.filter.cache();
				}
			});
		}
		
		public function doDOTEffect(dotDuration:int, dotEffect:String, dotType:int = -1, dotText:String = "") : void {
			var _local8:* = undefined;
			var _local5:TweenMax = null;
			if(dotEffect == null || !alive || !isAddedToCanvas) {
				return;
			}
			if(dotType == 5) {
				if(shieldRegenCounter > -dotDuration * 1000) {
					shieldRegenCounter = -dotDuration * 1000;
				}
			}
			if(dotType == 6) {
				if(disableHealEndtime < g.time) {
					disableHealEndtime = g.time + dotDuration * 1000;
				}
			}
			if(dotType == 11) {
				if(disableHealEndtime < g.time) {
					disableHealEndtime = g.time + dotDuration * 1000;
				}
				if(shieldRegenCounter > -dotDuration * 1000) {
					shieldRegenCounter = -dotDuration * 1000;
				}
			}
			if(dotType == 12) {
				trace("Slowdown: dotDuration");
				if(!(this is PlayerShip)) {
					if(slowDownEndtime < g.time) {
						slowDown = 0.5;
						slowDownEndtime = g.time + dotDuration * 1000;
					}
				}
			}
			if(dotTimers.length > 0 && dotTimers[0]._active && this.dotEffect == dotEffect) {
				for each(var _local6 in dotTimers) {
					_local6.restart();
				}
			} else {
				for each(var _local9 in dotTimers) {
					_local9.seek(_local9.totalDuration(),false);
				}
				dotTimers.splice(0,-1);
				_local8 = EmitterFactory.create(dotEffect,g,pos.x,pos.y,this,true);
				for each(var _local7 in _local8) {
					_local5 = TweenMax.to(_local7,dotDuration,{
						"startAlpha":0.1,
						"onComplete":removeDot(_local7)
					});
					dotTimers.push(_local5);
				}
				this.dotEffect = dotEffect;
			}
			if(dotText != "" && this == g.me.ship) {
				g.textManager.createDebuffText(dotText,this);
			}
		}
		
		override public function switchTexturesByObj(obj:Object, textureAtlas:String = "texture_main_NEW.png") : void {
			super.switchTexturesByObj(obj);
		}
		
		private function removeDot(e:Emitter) : Function {
			return function():void {
				e.killEmitter();
			};
		}
		
		public function activate() : void {
			active = true;
			alive = true;
			hp = _hpMax;
			shieldHp = _shieldHpMax;
			for each(var _local1 in triggers) {
				_local1.reEnable();
			}
		}
		
		public function destroy(explode:Boolean = true) : void {
			var _local3:ISound = null;
			alive = false;
			if(explode) {
				hp = 0;
				shieldHp = 0;
				if(g.camera.isCircleOnScreen(x,y,radius)) {
					EmitterFactory.create(explosionEffect,g,pos.x,pos.y,null,true);
					_local3 = SoundLocator.getService();
					_local3.play(explosionSound);
				}
			}
			if(parentObj is Boss) {
				for each(var _local4 in triggers) {
					_local4.tryActivateTrigger(this,Boss(parentObj));
				}
				if(!(this is Spawner)) {
					visible = false;
				}
			}
			for each(var _local2 in dotTimers) {
				_local2.seek(_local2.totalDuration(),false);
			}
			g.emitterManager.clean(this);
		}
		
		override public function draw() : void {
			var _local1:Number = pos.x;
			var _local2:Number = pos.y;
			var _local4:Number = _mc.pivotX * _mc.scaleX;
			var _local3:Number = _mc.pivotY * _mc.scaleY;
			if(alive && g.solarSystem.isPvpSystemInEditor) {
				hpBar.height = 3;
				hpBar.y = _local2 + _local3 + 10;
				hpBar.x = _local1;
				shieldBar.height = 3;
				shieldBar.x = _local1;
				shieldBar.y = _local2 + _local3 + 7;
				if(!miniBarsAreAddedToCanvas) {
					canvas.addChild(hpBar);
					canvas.addChild(shieldBar);
					miniBarsAreAddedToCanvas = true;
				}
			} else if(alive && isInjured) {
				hpBar.height = 2;
				hpBar.y = _local2 + _local3 + 9;
				hpBar.x = _local1;
				shieldBar.height = 2;
				shieldBar.x = _local1;
				shieldBar.y = _local2 + _local3 + 7;
				if(isAddedToCanvas && !miniBarsAreAddedToCanvas && !isBossUnit) {
					canvas.addChild(hpBar);
					canvas.addChild(shieldBar);
					miniBarsAreAddedToCanvas = true;
				}
			} else if(miniBarsAreAddedToCanvas) {
				canvas.removeChild(hpBar);
				canvas.removeChild(shieldBar);
				miniBarsAreAddedToCanvas = false;
			}
			super.draw();
		}
		
		public function get speed() : Point {
			return _speed;
		}
		
		public function set speed(value:Point) : void {
			_speed = value;
		}
		
		override public function reset() : void {
			var _local1:int = 0;
			syncId = -1;
			team = -1;
			active = true;
			hideIfInactive = false;
			alive = false;
			essential = false;
			invulnerable = false;
			owner = null;
			hp = 100;
			hpMax = 100;
			armorThreshold = 0;
			armorThresholdBase = 0;
			shieldHp = 0;
			shieldHpMax = 0;
			shieldRegen = 0;
			shieldRegenBase = 0;
			shieldRegenCounter = 0;
			shieldRegenDuration = 1000;
			shieldRegenBonus = 1;
			disableHealEndtime = 0;
			slowDownEndtime = 0;
			explosionEffect = "";
			collisionRadius = 15;
			hasDmgBoost = false;
			usingDmgBoost = false;
			dmgBoostCD = 0;
			dmgBoostDuration = 0;
			dmgBoostEndTime = 0;
			dmgBoostNextRdy = 0;
			dmgBoostCost = 0;
			dmgBoostBonus = 0;
			dotTimers.splice(0,-1);
			dotEffect = null;
			_local1 = 0;
			while(_local1 < 5) {
				resistances[_local1] = 0;
				_local1++;
			}
			group = null;
			factions = new Vector.<String>();
			isHostile = false;
			hpRegen = 0;
			hpRegenCounter = 0;
			hpRegenDuration = 1000;
			speed.x = 0;
			speed.y = 0;
			x = 0;
			y = 0;
			lastDmgText = null;
			lastDmgTextOffset = 0;
			lastDmgTime = 0;
			lastDmg = 0;
			lastHealText = null;
			lastHealTextOffset = 0;
			lastHealTime = 0;
			lastHeal = 0;
			_bodyName = null;
			_name = null;
			if(originalFilter != null) {
				originalFilter.dispose();
				originalFilter = null;
			}
			stateMachine = new StateMachine();
			enginePos.x = 0;
			enginePos.y = 0;
			weaponPos.x = 0;
			weaponPos.y = 0;
			super.reset();
			lastBulletLocal = 0;
			lastBulletGlobal = 0;
			lastBulletTargetList = new Vector.<Unit>();
			miniBarsAreAddedToCanvas = false;
			isInjured = false;
			nextDistanceCalculation = -1;
			isBossUnit = false;
			hpBar.visible = true;
			shieldBar.visible = true;
			uberDifficulty = 0;
			uberLevelFactor = 0;
			level = 0;
			xp = 0;
			g.emitterManager.clean(this);
			triggers.splice(0,-1);
			triggersToActivte = 1;
		}
		
		public function get type() : String {
			return "Unit, unidentified type!";
		}
		
		public function toString() : String {
			return "[ Name: " + _name + " Body name: " + _bodyName + " Type: " + type + " ]";
		}
		
		public function set bodyName(value:String) : void {
			_bodyName = value;
		}
		
		public function get bodyName() : String {
			return _bodyName;
		}
		
		public function addToCanvasForReal() : void {
			super.addToCanvas();
		}
		
		override public function removeFromCanvas() : void {
			if(!isAddedToCanvas) {
				return;
			}
			super.removeFromCanvas();
			if(miniBarsAreAddedToCanvas) {
				canvas.removeChild(hpBar);
				canvas.removeChild(shieldBar);
				miniBarsAreAddedToCanvas = false;
			}
		}
		
		public function hasFaction(faction:String) : Boolean {
			for each(var _local2 in factions) {
				if(_local2 == faction) {
					return true;
				}
			}
			return false;
		}
	}
}

