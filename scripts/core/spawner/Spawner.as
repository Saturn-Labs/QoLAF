package core.spawner {
	import com.greensock.TweenMax;
	import core.boss.Boss;
	import core.boss.Trigger;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.states.AIStates.AITurret;
	import core.turret.Turret;
	import core.turret.TurretFactory;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.core.Starling;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class Spawner extends Unit {
		public static const TYPE_ORGANIC:String = "organic";
		
		public static const TYPE_MECH:String = "mech";
		
		public static const TYPE_ABSTRACT:String = "abstract";
		
		public var spawnerType:String;
		
		public var orbitRadius:int;
		
		public var orbitAngle:Number = 0;
		
		public var angleVelocity:Number = 0;
		
		public var rotationSpeed:Number = 0;
		
		public var angleOffset:Number = 0;
		
		public var hidden:Boolean;
		
		public var innerRadius:int;
		
		public var outerRadius:int;
		
		public var key:String;
		
		public var objKey:String;
		
		public var offset:Point;
		
		public var turrets:Vector.<Turret>;
		
		public var imageOffset:Point;
		
		public var imageScale:Number;
		
		public var initialHardenedShield:Boolean = false;
		
		private var aiHardenedShieldEffect:Vector.<Emitter> = new Vector.<Emitter>();
		
		private var deadTextures:Vector.<Texture>;
		
		public function Spawner(g:Game) {
			canvas = g.canvasSpawners;
			super(g);
			alive = false;
			turrets = new Vector.<Turret>();
			dotTimers = new Vector.<TweenMax>();
			deadTextures = TextureManager.BASIC_TEXTURES;
		}
		
		override public function update() : void {
			if(hp <= 0) {
				alive = false;
			}
			var _local1:* = parentObj is Boss;
			if(_local1) {
				_pos.x = offset.x * Math.cos(parentObj.rotation) - offset.y * Math.sin(parentObj.rotation) + parentObj.pos.x;
				_pos.y = offset.x * Math.sin(parentObj.rotation) + offset.y * Math.cos(parentObj.rotation) + parentObj.pos.y;
				rotation = parentObj.rotation + angleOffset;
			}
			if(alive && active) {
				if(_local1) {
					for each(var _local4 in triggers) {
						_local4.tryActivateTrigger(this,Boss(parentObj));
					}
				}
				if(parentObj is Body) {
					super.updateHealthBars();
				}
				super.regenerateShield();
				for each(var _local2 in turrets) {
					_local2.update();
				}
				if(lastDmgText != null) {
					lastDmgText.x = _pos.x;
					lastDmgText.y = _pos.y - 25 + lastDmgTextOffset;
					lastDmgTextOffset += lastDmgText.speed.y * 33 / 1000;
					if(lastDmgTime < g.time - 1000) {
						lastDmgTextOffset = 0;
						lastDmgText = null;
					}
				}
				if(!_local1) {
					if(initialHardenedShield && aiHardenedShieldEffect.length == 0) {
						hardenShield();
					}
					if(!initialHardenedShield && aiHardenedShieldEffect.length > 0) {
						for each(var _local3 in aiHardenedShieldEffect) {
							_local3.killEmitter();
						}
						aiHardenedShieldEffect.splice(0,aiHardenedShieldEffect.length);
					}
				}
				if(lastHealText != null) {
					lastHealText.x = _pos.x;
					lastHealText.y = _pos.y - 10 + lastHealTextOffset;
					lastHealTextOffset += lastHealText.speed.y * 33 / 1000;
					if(lastHealTime < g.time - 1000) {
						lastHealTextOffset = 0;
						lastHealText = null;
					}
				}
				super.update();
			}
		}
		
		public function updatePos(startTime:Number) : void {
			var _local2:Number = g.time;
			var _local3:Number = orbitAngle + angleVelocity * 33 / 1000 * (_local2 - startTime);
			var _local4:Number = orbitRadius * Math.cos(_local3);
			var _local5:Number = orbitRadius * Math.sin(_local3);
			_pos.x = _local4 + parentObj.x;
			_pos.y = _local5 + parentObj.y;
			rotation = -rotationSpeed * Math.atan2(_pos.x - parentObj.x,_pos.y - parentObj.y) + 3.141592653589793 / 2 + Util.sign(angleVelocity) * 3.141592653589793 / 2;
		}
		
		public function addTurrets(obj:Object) : void {
			var _local3:* = this;
			var _local2:Array = obj.turrets;
			if(_local2.length > 0) {
				for each(var _local4 in _local2) {
					createTurret(_local4,_local3);
				}
			}
		}
		
		private function createTurret(turretObj:Object, s:Spawner) : void {
			if(this.parentObj is Boss) {
				return;
			}
			var _local3:Turret = TurretFactory.createTurret(turretObj,turretObj.turret,g);
			_local3.offset = new Point(turretObj.xpos,turretObj.ypos);
			_local3.startAngle = Util.degreesToRadians(turretObj.angle);
			_local3.syncId = turretObj.id;
			_local3.parentObj = s;
			_local3.alive = true;
			_local3.rotation = _local3.startAngle;
			_local3.name = turretObj.name;
			_local3.factions = factions;
			g.unitManager.add(_local3,g.canvasTurrets,false);
			s.turrets.push(_local3);
			_local3.stateMachine.changeState(new AITurret(g,_local3));
		}
		
		override public function destroy(explode:Boolean = true) : void {
			var _local3:ISound = null;
			if(imgObj != null) {
				changeStateTextures(deadTextures);
			}
			if(this.parentObj is Boss) {
				super.destroy(explode);
				return;
			}
			for each(var _local2 in turrets) {
				_local2.destroy(_local2.alive);
			}
			super.destroy(explode);
			if(parentObj is Body) {
				if(g.camera.isCircleOnScreen(x,y,radius)) {
					_local3 = SoundLocator.getService();
					if(explode) {
						if(isMech()) {
							_local3.play("5psyX2Y9e0m39q43L_uEGg");
						} else {
							_local3.play(explosionSound);
						}
					}
				}
				Body(parentObj).setSpawnersCleared(explode);
			}
		}
		
		public function rebuild() : void {
			hp = hpMax;
			shieldHp = shieldHpMax;
			if(parentObj is Boss) {
				tryAdjustUberStats(parentObj as Boss);
			} else {
				tryAdjustUberStats(null);
			}
			if(imgObj != null) {
				changeStateTextures(_textures,imgObj.animateOnStart);
			}
			for each(var _local1 in turrets) {
				_local1.rebuild();
			}
			if(parentObj != null && parentObj is Body) {
				Body(parentObj).spawnersCleared = false;
			}
			alive = true;
		}
		
		public function tryAdjustUberStats(b:Boss) : void {
			var _local2:Number = NaN;
			var _local3:Object = g.dataManager.loadKey("Spawners",objKey);
			level = _local3.level;
			if(b != null) {
				level = b.level;
			}
			if(g.isSystemTypeSurvival() && !hidden && level < g.hud.uberStats.uberLevel) {
				_local2 = g.hud.uberStats.CalculateUberRankFromLevel(level);
				uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _local2,level);
				uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - level) / 100;
				if(b != null) {
					uberDifficulty *= g.hud.uberStats.uberRank / 2 + 1;
				}
				hp = hpMax = _local3.hp * uberDifficulty;
				shieldHp = shieldHpMax = _local3.shieldHp * uberDifficulty;
				xp = _local3.xp * uberLevelFactor;
				level = g.hud.uberStats.uberLevel;
			}
		}
		
		public function hardenShield() : void {
			aiHardenedShieldEffect = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw",g,pos.x,pos.y,this,true);
		}
		
		override public function switchTexturesByObj(obj:Object, textureAtlas:String = "texture_main_NEW.png") : void {
			super.switchTexturesByObj(obj,textureAtlas);
			var _local3:ITextureManager = TextureLocator.getService();
			if(imgObj != null) {
				deadTextures = _local3.getTexturesMainByTextureName(imgObj.textureName.replace("active","dead"));
			}
		}
		
		protected function changeStateTextures(textures:Vector.<Texture>, animate:Boolean = false) : void {
			if(textures == null) {
				throw new TypeError("Texture can not be null.");
			}
			Starling.juggler.remove(_mc);
			swapFrames(_mc,textures);
			_mc.fps = imgObj.animationDelay;
			_mc.readjustSize();
			if(animate) {
				Starling.juggler.add(_mc);
			}
			_mc.pivotX = _mc.texture.width / 2;
			_mc.pivotY = _mc.texture.height / 2;
		}
		
		public function isMech() : Boolean {
			return spawnerType == "mech";
		}
		
		override public function get type() : String {
			return "spawner";
		}
	}
}

