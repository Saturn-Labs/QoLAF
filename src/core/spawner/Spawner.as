package core.spawner
{
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

	public class Spawner extends Unit
	{
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
		private var aiHardenedShieldEffect:Vector.<Emitter>;

		private var deadTextures:Vector.<Texture>;

		public function Spawner(param1:Game)
		{
			aiHardenedShieldEffect = new Vector.<Emitter>();
			canvas = param1.canvasSpawners;
			super(param1);
			alive = false;
			turrets = new Vector.<Turret>();
			dotTimers = new Vector.<TweenMax>();
			deadTextures = TextureManager.BASIC_TEXTURES;
		}

		override public function update():void
		{
			if (hp <= 0)
			{
				alive = false;
			}
			var _loc1_:* = parentObj is Boss;
			if (_loc1_)
			{
				_pos.x = offset.x * Math.cos(parentObj.rotation) - offset.y * Math.sin(parentObj.rotation) + parentObj.pos.x;
				_pos.y = offset.x * Math.sin(parentObj.rotation) + offset.y * Math.cos(parentObj.rotation) + parentObj.pos.y;
				rotation = parentObj.rotation + angleOffset;
			}
			if (alive && active)
			{
				if (_loc1_)
				{
					for each (var _loc4_:* in triggers)
					{
						_loc4_.tryActivateTrigger(this, Boss(parentObj));
					}
				}
				if (parentObj is Body)
				{
					super.updateHealthBars();
				}
				super.regenerateShield();
				for each (var _loc3_:* in turrets)
				{
					_loc3_.update();
				}
				if (lastDmgText != null)
				{
					lastDmgText.x = _pos.x;
					lastDmgText.y = _pos.y - 25 + lastDmgTextOffset;
					lastDmgTextOffset += lastDmgText.speed.y * 33 / 1000;
					if (lastDmgTime < g.time - 1000)
					{
						lastDmgTextOffset = 0;
						lastDmgText = null;
					}
				}
				if (!_loc1_)
				{
					if (initialHardenedShield && aiHardenedShieldEffect.length == 0)
					{
						hardenShield();
					}
					if (!initialHardenedShield && aiHardenedShieldEffect.length > 0)
					{
						for each (var _loc2_:* in aiHardenedShieldEffect)
						{
							_loc2_.killEmitter();
						}
						aiHardenedShieldEffect.splice(0, aiHardenedShieldEffect.length);
					}
				}
				if (lastHealText != null)
				{
					lastHealText.x = _pos.x;
					lastHealText.y = _pos.y - 10 + lastHealTextOffset;
					lastHealTextOffset += lastHealText.speed.y * 33 / 1000;
					if (lastHealTime < g.time - 1000)
					{
						lastHealTextOffset = 0;
						lastHealText = null;
					}
				}
				super.update();
			}
		}

		public function updatePos(param1:Number):void
		{
			var _loc2_:Number = g.time;
			var _loc5_:Number = orbitAngle + angleVelocity * 33 / 1000 * (_loc2_ - param1);
			var _loc3_:Number = orbitRadius * Math.cos(_loc5_);
			var _loc4_:Number = orbitRadius * Math.sin(_loc5_);
			_pos.x = _loc3_ + parentObj.x;
			_pos.y = _loc4_ + parentObj.y;
			rotation = -rotationSpeed * Math.atan2(_pos.x - parentObj.x, _pos.y - parentObj.y) + 3.141592653589793 / 2 + Util.sign(angleVelocity) * 3.141592653589793 / 2;
		}

		public function addTurrets(param1:Object):void
		{
			var _loc2_:* = this;
			var _loc3_:Array = param1.turrets;
			if (_loc3_.length > 0)
			{
				for each (var _loc4_:* in _loc3_)
				{
					createTurret(_loc4_, _loc2_);
				}
			}
		}

		private function createTurret(param1:Object, param2:Spawner):void
		{
			if (this.parentObj is Boss)
			{
				return;
			}
			var _loc3_:Turret = TurretFactory.createTurret(param1, param1.turret, g);
			_loc3_.offset = new Point(param1.xpos, param1.ypos);
			_loc3_.startAngle = Util.degreesToRadians(param1.angle);
			_loc3_.syncId = param1.id;
			_loc3_.parentObj = param2;
			_loc3_.alive = true;
			_loc3_.rotation = _loc3_.startAngle;
			_loc3_.name = param1.name;
			_loc3_.factions = factions;
			g.unitManager.add(_loc3_, g.canvasTurrets, false);
			param2.turrets.push(_loc3_);
			_loc3_.stateMachine.changeState(new AITurret(g, _loc3_));
		}

		override public function destroy(param1:Boolean = true):void
		{
			var _loc3_:ISound = null;
			if (imgObj != null)
			{
				changeStateTextures(deadTextures);
			}
			if (this.parentObj is Boss)
			{
				super.destroy(param1);
				return;
			}
			for each (var _loc2_:* in turrets)
			{
				_loc2_.destroy(_loc2_.alive);
			}
			super.destroy(param1);
			if (parentObj is Body)
			{
				if (g.camera.isCircleOnScreen(x, y, radius))
				{
					_loc3_ = SoundLocator.getService();
					if (param1)
					{
						if (isMech())
						{
							_loc3_.play("5psyX2Y9e0m39q43L_uEGg");
						}
						else
						{
							_loc3_.play(explosionSound);
						}
					}
				}
				Body(parentObj).setSpawnersCleared(param1);
			}
		}

		public function rebuild():void
		{
			hp = hpMax;
			shieldHp = shieldHpMax;
			if (parentObj is Boss)
			{
				tryAdjustUberStats(parentObj as Boss);
			}
			else
			{
				tryAdjustUberStats(null);
			}
			if (imgObj != null)
			{
				changeStateTextures(_textures, imgObj.animateOnStart);
			}
			for each (var _loc1_:* in turrets)
			{
				_loc1_.rebuild();
			}
			if (parentObj != null && parentObj is Body)
			{
				Body(parentObj).spawnersCleared = false;
			}
			alive = true;
		}

		public function tryAdjustUberStats(param1:Boss):void
		{
			var _loc3_:Number = NaN;
			var _loc2_:Object = g.dataManager.loadKey("Spawners", objKey);
			level = _loc2_.level;
			if (param1 != null)
			{
				level = param1.level;
			}
			if (g.isSystemTypeSurvival() && !hidden && level < g.hud.uberStats.uberLevel)
			{
				_loc3_ = g.hud.uberStats.CalculateUberRankFromLevel(level);
				uberDifficulty = g.hud.uberStats.CalculateUberDifficultyFromRank(g.hud.uberStats.uberRank - _loc3_, level);
				uberLevelFactor = 1 + (g.hud.uberStats.uberLevel - level) / 100;
				if (param1 != null)
				{
					uberDifficulty *= g.hud.uberStats.uberRank / 2 + 1;
				}
				hp = hpMax = _loc2_.hp * uberDifficulty;
				shieldHp = shieldHpMax = _loc2_.shieldHp * uberDifficulty;
				xp = _loc2_.xp * uberLevelFactor;
				level = g.hud.uberStats.uberLevel;
			}
		}

		public function hardenShield():void
		{
			aiHardenedShieldEffect = EmitterFactory.create("uWIxfxRAgUm6ThgrRFnixw", g, pos.x, pos.y, this, true);
		}

		override public function switchTexturesByObj(param1:Object, param2:String = "texture_main_NEW.png"):void
		{
			super.switchTexturesByObj(param1, param2);
			var _loc3_:ITextureManager = TextureLocator.getService();
			if (imgObj != null)
			{
				deadTextures = _loc3_.getTexturesMainByTextureName(imgObj.textureName.replace("active", "dead"));
			}
		}

		protected function changeStateTextures(param1:Vector.<Texture>, param2:Boolean = false):void
		{
			if (param1 == null)
			{
				throw new TypeError("Texture can not be null.");
			}
			Starling.juggler.remove(_mc);
			swapFrames(_mc, param1);
			_mc.fps = imgObj.animationDelay;
			_mc.readjustSize();
			if (param2)
			{
				Starling.juggler.add(_mc);
			}
			_mc.pivotX = _mc.texture.width / 2;
			_mc.pivotY = _mc.texture.height / 2;
		}

		public function isMech():Boolean
		{
			return spawnerType == "mech";
		}

		override public function get type():String
		{
			return "spawner";
		}
	}
}
