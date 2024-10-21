package core.boss
{
	import com.greensock.TweenMax;
	import core.GameObject;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.spawner.Spawner;
	import core.states.StateMachine;
	import core.turret.Turret;
	import core.unit.Unit;
	import flash.geom.Point;
	import generics.Util;
	import movement.Heading;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import textures.TextureLocator;
	
	public class Boss extends GameObject
	{
		public var alive:Boolean;
		
		public var isHostile:Boolean;
		
		public var key:String;
		
		public var xp:int;
		
		public var level:int;
		
		public var hp:int;
		
		public var hpMax:int;
		
		public var resetTime:Number;
		
		public var respawnTime:Number;
		
		public var speed:Number;
		
		public var acceleration:Number;
		
		public var rotationSpeed:Number;
		
		public var rotationForced:Boolean;
		
		public var targetRange:int;
		
		public var holonomic:Boolean;
		
		public var orbitOrign:Point;
		
		public var orbitRadius:Point;
		
		public var turrets:Vector.<Turret>;
		
		public var spawners:Vector.<Spawner>;
		
		public var bossComponents:Vector.<BossComponent>;
		
		public var allComponents:Vector.<Unit>;
		
		public var target:Unit;
		
		public var angleTargetPos:Point;
		
		public var course:Heading;
		
		public var parentBody:Body;
		
		public var explosionEffect:String;
		
		public var explosionSound:String;
		
		public var bossRadius:int;
		
		public var currentWaypoint:Waypoint = null;
		
		public var waypoints:Vector.<Waypoint>;
		
		public var bodyDestroyStart:Number = 0;
		
		public var bodyDestroyEnd:Number = 0;
		
		public var bodyTarget:Body;
		
		public var awaitingActivation:Boolean;
		
		public var stateMachine:StateMachine;
		
		protected var g:Game;
		
		private var error:Point = null;
		
		private var errorAngle:Number;
		
		private var convergeTime:Number = 1000;
		
		private var convergeStartTime:Number;
		
		private var errorOldTime:Number;
		
		private var oldAngle:Number;
		
		public var teleportExitTime:Number = 0;
		
		public var teleportExitPoint:Point;
		
		public var hpRegen:int;
		
		public var factions:Vector.<String>;
		
		public var uberDifficulty:Number = 0;
		
		public var uberLevelFactor:Number = 0;
		
		private var teleportDestinationImage:Image;
		
		private var teleportChannelImage:Image;
		
		public function Boss(param1:Game)
		{
			stateMachine = new StateMachine();
			factions = new Vector.<String>();
			super();
			canvas = param1.canvasBosses;
			turrets = new Vector.<Turret>();
			spawners = new Vector.<Spawner>();
			bossComponents = new Vector.<BossComponent>();
			allComponents = new Vector.<Unit>();
			stateMachine = new StateMachine();
			course = new Heading();
			waypoints = new Vector.<Waypoint>();
			this.g = param1;
			distanceToCamera = 0;
		}
		
		public function startTeleportEffect():void
		{
			teleportDestinationImage = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???", "qqq") + "_mini"));
			teleportDestinationImage.scaleX = teleportDestinationImage.scaleY = bossRadius * 2 / teleportDestinationImage.width;
			teleportDestinationImage.x = teleportExitPoint.x;
			teleportDestinationImage.y = teleportExitPoint.y;
			teleportDestinationImage.pivotX = teleportDestinationImage.texture.width / 2;
			teleportDestinationImage.pivotY = teleportDestinationImage.texture.height / 2;
			teleportDestinationImage.blendMode = "add";
			teleportDestinationImage.color = 16729156;
			TweenMax.fromTo(teleportDestinationImage, 0.2, {"alpha": 0.8}, {"alpha": 0.2, "yoyo": true, "repeat": -1});
			g.addChildToCanvas(teleportDestinationImage);
			teleportChannelImage = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???", "qqq") + "_mini"));
			teleportChannelImage.scaleX = teleportChannelImage.scaleY = bossRadius * 2 / teleportChannelImage.width * 1.6;
			teleportChannelImage.x = this.x;
			teleportChannelImage.y = this.y;
			teleportChannelImage.pivotX = teleportChannelImage.texture.width / 2;
			teleportChannelImage.pivotY = teleportChannelImage.texture.height / 2;
			teleportChannelImage.blendMode = "add";
			teleportChannelImage.color = 16729156;
			TweenMax.fromTo(teleportChannelImage, (teleportExitTime - g.time) / 1000 / 3, {"alpha": 0, "scaleX": teleportChannelImage.scaleX, "scaleY": teleportChannelImage.scaleY}, {"alpha": 0.8, "scaleX": teleportChannelImage.scaleX / 1.6, "scaleY": teleportChannelImage.scaleY / 1.6, "repeat": 3, "onComplete": function():void
			{
				g.removeChildFromCanvas(teleportChannelImage);
			}});
			g.addChildToCanvas(teleportChannelImage);
		}
		
		public function endTeleportEffect():void
		{
			var splashImage1:Image;
			var splashImage2:Image;
			var splashImage3:Image;
			TweenMax.killTweensOf(teleportDestinationImage);
			g.removeChildFromCanvas(teleportDestinationImage);
			splashImage1 = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???", "qqq") + "_mini"));
			splashImage1.scaleX = splashImage1.scaleY = bossRadius * 2 / splashImage1.width;
			splashImage1.x = teleportExitPoint.x;
			splashImage1.y = teleportExitPoint.y;
			splashImage1.pivotX = splashImage1.texture.width / 2;
			splashImage1.pivotY = splashImage1.texture.height / 2;
			splashImage1.blendMode = "add";
			splashImage1.color = 16729156;
			g.addChildToCanvas(splashImage1);
			TweenMax.fromTo(splashImage1, 0.3, {"scaleX": splashImage1.scaleX, "scaleY": splashImage1.scaleY, "alpha": 0.6}, {"scaleX": splashImage1.scaleX * 2, "scaleY": splashImage1.scaleY * 2, "alpha": 0, "onComplete": function():void
			{
				g.removeChildFromCanvas(splashImage1);
			}});
			splashImage2 = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???", "qqq") + "_mini"));
			splashImage2.scaleX = splashImage2.scaleY = bossRadius * 2 / splashImage2.width;
			splashImage2.x = teleportExitPoint.x;
			splashImage2.y = teleportExitPoint.y;
			splashImage2.pivotX = splashImage2.texture.width / 2;
			splashImage2.pivotY = splashImage2.texture.height / 2;
			splashImage2.blendMode = "add";
			splashImage2.color = 16729156;
			g.addChildToCanvas(splashImage2);
			TweenMax.fromTo(splashImage2, 0.4, {"scaleX": splashImage2.scaleX, "scaleY": splashImage2.scaleY, "alpha": 0.6}, {"scaleX": splashImage2.scaleX * 2, "scaleY": splashImage2.scaleY * 2, "alpha": 0, "onComplete": function():void
			{
				g.removeChildFromCanvas(splashImage2);
			}});
			splashImage3 = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???", "qqq") + "_mini"));
			splashImage3.scaleX = splashImage3.scaleY = bossRadius * 2 / splashImage3.width;
			splashImage3.x = teleportExitPoint.x;
			splashImage3.y = teleportExitPoint.y;
			splashImage3.pivotX = splashImage3.texture.width / 2;
			splashImage3.pivotY = splashImage3.texture.height / 2;
			splashImage3.blendMode = "add";
			splashImage3.color = 16729156;
			g.addChildToCanvas(splashImage3);
			TweenMax.fromTo(splashImage3, 0.6, {"scaleX": splashImage3.scaleX, "scaleY": splashImage3.scaleY, "alpha": 0.6}, {"scaleX": splashImage3.scaleX * 2, "scaleY": splashImage3.scaleY * 2, "alpha": 0, "onComplete": function():void
			{
				g.removeChildFromCanvas(splashImage3);
			}});
		}
		
		override public function update():void
		{
			var _loc4_:Point = null;
			var _loc2_:Point = null;
			if (!alive || awaitingActivation)
			{
				return;
			}
			if (g.me.ship != null)
			{
				_loc4_ = this.pos;
				_loc2_ = g.me.ship.pos;
				distanceToCameraX = _loc4_.x - _loc2_.x;
				distanceToCameraY = _loc4_.y - _loc2_.y;
				distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			}
			if (nextDistanceCalculation <= 0)
			{
				updateIsNear();
			}
			else
			{
				nextDistanceCalculation -= 33;
			}
			stateMachine.update();
			var _loc3_:int = 0;
			hp = 0;
			for each (var _loc1_:* in allComponents)
			{
				_loc1_.update();
				if (_loc1_.alive && _loc1_.essential)
				{
					hp += _loc1_.hp + _loc1_.shieldHp;
					_loc3_++;
				}
				if ((!_loc1_.alive || !_loc1_.active) && !(_loc1_ is Spawner))
				{
					_loc1_.visible = false;
				}
			}
		}
		
		private function updateIsNear():void
		{
			var _loc2_:Number = g.stage.stageWidth;
			distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			var _loc1_:Number = distanceToCamera - _loc2_;
			nextDistanceCalculation = _loc1_ / 600 * 100;
			if (nextDistanceCalculation > 5000)
			{
				nextDistanceCalculation = 5000;
			}
			if (distanceToCamera < _loc2_)
			{
				if (isAddedToCanvas)
				{
					return;
				}
				addToCanvas();
			}
			else
			{
				if (!isAddedToCanvas)
				{
					return;
				}
				removeFromCanvas();
			}
		}
		
		override public function removeFromCanvas():void
		{
			isAddedToCanvas = false;
			for each (var _loc1_:* in allComponents)
			{
				_loc1_.removeFromCanvas();
			}
		}
		
		override public function addToCanvas():void
		{
			isAddedToCanvas = true;
			for each (var _loc1_:* in allComponents)
			{
				_loc1_.addToCanvas();
			}
		}
		
		public function addFactions():void
		{
			for each (var _loc1_:* in allComponents)
			{
				_loc1_.factions = factions;
			}
		}
		
		public function updateHeading(param1:Heading):void
		{
			var _loc9_:Number = NaN;
			var _loc11_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc10_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc14_:Number = NaN;
			var _loc13_:Number = NaN;
			var _loc12_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc2_:int = 33;
			aiRemoveError(param1);
			oldAngle = course.rotation;
			if (angleTargetPos != null)
			{
				if (holonomic || rotationForced)
				{
					param1.rotation = Math.atan2(angleTargetPos.y - course.pos.y, angleTargetPos.x - course.pos.x);
				}
				else
				{
					_loc9_ = Math.atan2(angleTargetPos.y - course.pos.y, angleTargetPos.x - course.pos.x);
					_loc11_ = Util.angleDifference(course.rotation, _loc9_ + 3.141592653589793);
					_loc7_ = rotationSpeed * _loc2_ / 1000;
					if (_loc11_ > 0 && _loc11_ < 3.141592653589793 - _loc7_)
					{
						param1.rotation += _loc7_;
						param1.rotation = Util.clampRadians(param1.rotation);
					}
					else if (_loc11_ <= 0 && _loc11_ > -3.141592653589793 + _loc7_)
					{
						param1.rotation -= _loc7_;
						param1.rotation = Util.clampRadians(param1.rotation);
					}
					else
					{
						param1.rotation = Util.clampRadians(_loc9_);
					}
				}
			}
			if (param1.accelerate)
			{
				if (angleTargetPos != null && (holonomic || rotationForced))
				{
					_loc8_ = pos.x - angleTargetPos.x;
					_loc10_ = pos.y - angleTargetPos.y;
					_loc4_ = _loc8_ * _loc8_ + _loc10_ * _loc10_;
					if (_loc4_ > 1.1025 * (targetRange * targetRange))
					{
						_loc5_ = 1;
					}
					else if (_loc4_ < 0.9025 * (targetRange * targetRange))
					{
						_loc5_ = -1;
					}
					else
					{
						_loc5_ = 0;
						param1.speed.x = 0.98 * param1.speed.x;
						param1.speed.y = 0.98 * param1.speed.y;
					}
				}
				else
				{
					_loc5_ = 1;
				}
				_loc14_ = param1.speed.x;
				_loc13_ = param1.speed.y;
				_loc14_ += _loc5_ * (Math.cos(param1.rotation) * acceleration * 0.5 * Math.pow(_loc2_, 2));
				_loc13_ += _loc5_ * (Math.sin(param1.rotation) * acceleration * 0.5 * Math.pow(_loc2_, 2));
				if (_loc14_ * _loc14_ + _loc13_ * _loc13_ <= speed * speed)
				{
					param1.speed.x = _loc14_;
					param1.speed.y = _loc13_;
				}
				else
				{
					_loc12_ = Math.sqrt(_loc14_ * _loc14_ + _loc13_ * _loc13_);
					_loc6_ = _loc14_ / _loc12_ * speed;
					_loc3_ = _loc13_ / _loc12_ * speed;
					param1.speed.x = _loc6_;
					param1.speed.y = _loc3_;
				}
			}
			param1.speed.x -= 0.009 * param1.speed.x;
			param1.speed.y -= 0.009 * param1.speed.y;
			param1.pos.x += param1.speed.x * _loc2_ / 1000;
			param1.pos.y += param1.speed.y * _loc2_ / 1000;
			param1.time += _loc2_;
			if (holonomic || rotationForced)
			{
				course.rotation = oldAngle;
			}
			aiAddError(param1);
		}
		
		public function calcHpMax():void
		{
			hp = 0;
			hpMax = 0;
			for each (var _loc1_:* in allComponents)
			{
				if (_loc1_.essential)
				{
					hp += _loc1_.hp + _loc1_.shieldHp;
					hpMax += _loc1_.hpMax + _loc1_.shieldHpMax;
				}
			}
		}
		
		private function aiAddError(param1:Heading):void
		{
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			if (error != null)
			{
				_loc2_ = g.time;
				_loc3_ = (convergeTime - (_loc2_ - convergeStartTime)) / convergeTime;
				_loc4_ = 3 * _loc3_ * _loc3_ - 2 * _loc3_ * _loc3_ * _loc3_;
				if (_loc3_ > 0)
				{
					param1.pos.x += _loc4_ * error.x;
					param1.pos.y += _loc4_ * error.y;
					param1.rotation += _loc4_ * errorAngle;
					errorOldTime = _loc2_;
				}
				else
				{
					error = null;
					errorOldTime = 0;
				}
			}
		}
		
		private function aiRemoveError(param1:Heading):void
		{
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			if (error != null && errorOldTime != 0)
			{
				_loc2_ = (convergeTime - (errorOldTime - convergeStartTime)) / convergeTime;
				_loc3_ = 3 * _loc2_ * _loc2_ - 2 * _loc2_ * _loc2_ * _loc2_;
				param1.pos.x -= _loc3_ * error.x;
				param1.pos.y -= _loc3_ * error.y;
				param1.rotation -= _loc3_ * errorAngle;
			}
		}
		
		public function setConvergeTarget(param1:Heading):void
		{
			error = new Point(course.pos.x - param1.pos.x, course.pos.y - param1.pos.y);
			errorAngle = Util.angleDifference(course.rotation, param1.rotation);
			convergeStartTime = g.time;
			course.speed = param1.speed;
			course.pos = param1.pos;
			course.rotation = param1.rotation;
			course.time = param1.time;
			aiAddError(course);
		}
		
		public function overrideConvergeTarget(param1:Number, param2:Number):void
		{
			error = null;
			errorAngle = 0;
			errorOldTime = 0;
			convergeStartTime = g.time;
			course.pos.x = param1;
			course.pos.y = param2;
			course.time = g.time;
		}
		
		public function destroy():void
		{
			var _loc2_:Turret = null;
			var _loc3_:Spawner = null;
			var _loc4_:ISound = null;
			alive = false;
			for each (var _loc1_:* in allComponents)
			{
				_loc1_.destroy(_loc1_.alive);
				_loc1_.alive = false;
				_loc1_.active = false;
				_loc1_.visible = false;
				if (_loc1_ is Turret)
				{
					_loc2_ = _loc1_ as Turret;
					if (_loc2_.weapon != null)
					{
						_loc2_.weapon.fire = false;
					}
					_loc2_.visible = false;
					g.turretManager.removeTurret(_loc2_);
				}
				if (_loc1_ is Spawner)
				{
					_loc3_ = _loc1_ as Spawner;
					_loc1_.destroy();
					g.spawnManager.removeSpawner(_loc3_);
				}
				g.unitManager.remove(_loc1_);
			}
			if (g.camera.isCircleOnScreen(pos.x, pos.y, radius))
			{
				if (explosionSound != "")
				{
					_loc4_ = SoundLocator.getService();
					_loc4_.play(explosionSound);
				}
				if (explosionEffect != "")
				{
					EmitterFactory.create(explosionEffect, g, pos.x, pos.y, null, true);
				}
			}
		}
		
		public function getComponent(param1:int):Unit
		{
			for each (var _loc2_:* in allComponents)
			{
				if (_loc2_.syncId == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		override public function draw():void
		{
			if (awaitingActivation)
			{
				return;
			}
			for each (var _loc1_:* in allComponents)
			{
				_loc1_.draw();
			}
		}
	}
}
