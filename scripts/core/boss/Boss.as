package core.boss {
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
	
	public class Boss extends GameObject {
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
		
		public var stateMachine:StateMachine = new StateMachine();
		
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
		
		public var factions:Vector.<String> = new Vector.<String>();
		
		public var uberDifficulty:Number = 0;
		
		public var uberLevelFactor:Number = 0;
		
		private var teleportDestinationImage:Image;
		
		private var teleportChannelImage:Image;
		
		public function Boss(g:Game) {
			super();
			canvas = g.canvasBosses;
			turrets = new Vector.<Turret>();
			spawners = new Vector.<Spawner>();
			bossComponents = new Vector.<BossComponent>();
			allComponents = new Vector.<Unit>();
			stateMachine = new StateMachine();
			course = new Heading();
			waypoints = new Vector.<Waypoint>();
			this.g = g;
			distanceToCamera = 0;
		}
		
		public function startTeleportEffect() : void {
			teleportDestinationImage = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???","qqq") + "_mini"));
			teleportDestinationImage.scaleX = teleportDestinationImage.scaleY = bossRadius * 2 / teleportDestinationImage.width;
			teleportDestinationImage.x = teleportExitPoint.x;
			teleportDestinationImage.y = teleportExitPoint.y;
			teleportDestinationImage.pivotX = teleportDestinationImage.texture.width / 2;
			teleportDestinationImage.pivotY = teleportDestinationImage.texture.height / 2;
			teleportDestinationImage.blendMode = "add";
			teleportDestinationImage.color = 0xff4444;
			TweenMax.fromTo(teleportDestinationImage,0.2,{"alpha":0.8},{
				"alpha":0.2,
				"yoyo":true,
				"repeat":-1
			});
			g.addChildToCanvas(teleportDestinationImage);
			teleportChannelImage = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???","qqq") + "_mini"));
			teleportChannelImage.scaleX = teleportChannelImage.scaleY = bossRadius * 2 / teleportChannelImage.width * 1.6;
			teleportChannelImage.x = this.x;
			teleportChannelImage.y = this.y;
			teleportChannelImage.pivotX = teleportChannelImage.texture.width / 2;
			teleportChannelImage.pivotY = teleportChannelImage.texture.height / 2;
			teleportChannelImage.blendMode = "add";
			teleportChannelImage.color = 0xff4444;
			TweenMax.fromTo(teleportChannelImage,(teleportExitTime - g.time) / 1000 / 3,{
				"alpha":0,
				"scaleX":teleportChannelImage.scaleX,
				"scaleY":teleportChannelImage.scaleY
			},{
				"alpha":0.8,
				"scaleX":teleportChannelImage.scaleX / 1.6,
				"scaleY":teleportChannelImage.scaleY / 1.6,
				"repeat":3,
				"onComplete":function():void {
					g.removeChildFromCanvas(teleportChannelImage);
				}
			});
			g.addChildToCanvas(teleportChannelImage);
		}
		
		public function endTeleportEffect() : void {
			var splashImage1:Image;
			var splashImage2:Image;
			var splashImage3:Image;
			TweenMax.killTweensOf(teleportDestinationImage);
			g.removeChildFromCanvas(teleportDestinationImage);
			splashImage1 = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???","qqq") + "_mini"));
			splashImage1.scaleX = splashImage1.scaleY = bossRadius * 2 / splashImage1.width;
			splashImage1.x = teleportExitPoint.x;
			splashImage1.y = teleportExitPoint.y;
			splashImage1.pivotX = splashImage1.texture.width / 2;
			splashImage1.pivotY = splashImage1.texture.height / 2;
			splashImage1.blendMode = "add";
			splashImage1.color = 0xff4444;
			g.addChildToCanvas(splashImage1);
			TweenMax.fromTo(splashImage1,0.3,{
				"scaleX":splashImage1.scaleX,
				"scaleY":splashImage1.scaleY,
				"alpha":0.6
			},{
				"scaleX":splashImage1.scaleX * 2,
				"scaleY":splashImage1.scaleY * 2,
				"alpha":0,
				"onComplete":function():void {
					g.removeChildFromCanvas(splashImage1);
				}
			});
			splashImage2 = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???","qqq") + "_mini"));
			splashImage2.scaleX = splashImage2.scaleY = bossRadius * 2 / splashImage2.width;
			splashImage2.x = teleportExitPoint.x;
			splashImage2.y = teleportExitPoint.y;
			splashImage2.pivotX = splashImage2.texture.width / 2;
			splashImage2.pivotY = splashImage2.texture.height / 2;
			splashImage2.blendMode = "add";
			splashImage2.color = 0xff4444;
			g.addChildToCanvas(splashImage2);
			TweenMax.fromTo(splashImage2,0.4,{
				"scaleX":splashImage2.scaleX,
				"scaleY":splashImage2.scaleY,
				"alpha":0.6
			},{
				"scaleX":splashImage2.scaleX * 2,
				"scaleY":splashImage2.scaleY * 2,
				"alpha":0,
				"onComplete":function():void {
					g.removeChildFromCanvas(splashImage2);
				}
			});
			splashImage3 = new Image(TextureLocator.getService().getTextureMainByTextureName(name.toLowerCase().replace("???","qqq") + "_mini"));
			splashImage3.scaleX = splashImage3.scaleY = bossRadius * 2 / splashImage3.width;
			splashImage3.x = teleportExitPoint.x;
			splashImage3.y = teleportExitPoint.y;
			splashImage3.pivotX = splashImage3.texture.width / 2;
			splashImage3.pivotY = splashImage3.texture.height / 2;
			splashImage3.blendMode = "add";
			splashImage3.color = 0xff4444;
			g.addChildToCanvas(splashImage3);
			TweenMax.fromTo(splashImage3,0.6,{
				"scaleX":splashImage3.scaleX,
				"scaleY":splashImage3.scaleY,
				"alpha":0.6
			},{
				"scaleX":splashImage3.scaleX * 2,
				"scaleY":splashImage3.scaleY * 2,
				"alpha":0,
				"onComplete":function():void {
					g.removeChildFromCanvas(splashImage3);
				}
			});
		}
		
		override public function update() : void {
			var _local1:Point = null;
			var _local3:Point = null;
			if(!alive || awaitingActivation) {
				return;
			}
			if(g.me.ship != null) {
				_local1 = this.pos;
				_local3 = g.me.ship.pos;
				distanceToCameraX = _local1.x - _local3.x;
				distanceToCameraY = _local1.y - _local3.y;
				distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			}
			if(nextDistanceCalculation <= 0) {
				updateIsNear();
			} else {
				nextDistanceCalculation -= 33;
			}
			stateMachine.update();
			var _local4:int = 0;
			hp = 0;
			for each(var _local2 in allComponents) {
				_local2.update();
				if(_local2.alive && _local2.essential) {
					hp += _local2.hp + _local2.shieldHp;
					_local4++;
				}
				if((!_local2.alive || !_local2.active) && !(_local2 is Spawner)) {
					_local2.visible = false;
				}
			}
		}
		
		private function updateIsNear() : void {
			var _local2:Number = g.stage.stageWidth;
			distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			var _local1:Number = distanceToCamera - _local2;
			nextDistanceCalculation = _local1 / (10 * 60) * 100;
			if(nextDistanceCalculation > 5000) {
				nextDistanceCalculation = 5000;
			}
			if(distanceToCamera < _local2) {
				if(isAddedToCanvas) {
					return;
				}
				addToCanvas();
			} else {
				if(!isAddedToCanvas) {
					return;
				}
				removeFromCanvas();
			}
		}
		
		override public function removeFromCanvas() : void {
			isAddedToCanvas = false;
			for each(var _local1 in allComponents) {
				_local1.removeFromCanvas();
			}
		}
		
		override public function addToCanvas() : void {
			isAddedToCanvas = true;
			for each(var _local1 in allComponents) {
				_local1.addToCanvas();
			}
		}
		
		public function addFactions() : void {
			for each(var _local1 in allComponents) {
				_local1.factions = factions;
			}
		}
		
		public function updateHeading(heading:Heading) : void {
			var _local10:Number = NaN;
			var _local11:Number = NaN;
			var _local12:Number = NaN;
			var _local13:Number = NaN;
			var _local2:Number = NaN;
			var _local5:Number = NaN;
			var _local14:Number = NaN;
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local6:Number = NaN;
			var _local8:Number = NaN;
			var _local7:Number = NaN;
			var _local9:int = 33;
			aiRemoveError(heading);
			oldAngle = course.rotation;
			if(angleTargetPos != null) {
				if(holonomic || rotationForced) {
					heading.rotation = Math.atan2(angleTargetPos.y - course.pos.y,angleTargetPos.x - course.pos.x);
				} else {
					_local10 = Math.atan2(angleTargetPos.y - course.pos.y,angleTargetPos.x - course.pos.x);
					_local11 = Util.angleDifference(course.rotation,_local10 + 3.141592653589793);
					_local12 = rotationSpeed * _local9 / 1000;
					if(_local11 > 0 && _local11 < 3.141592653589793 - _local12) {
						heading.rotation += _local12;
						heading.rotation = Util.clampRadians(heading.rotation);
					} else if(_local11 <= 0 && _local11 > -3.141592653589793 + _local12) {
						heading.rotation -= _local12;
						heading.rotation = Util.clampRadians(heading.rotation);
					} else {
						heading.rotation = Util.clampRadians(_local10);
					}
				}
			}
			if(heading.accelerate) {
				if(angleTargetPos != null && (holonomic || rotationForced)) {
					_local2 = pos.x - angleTargetPos.x;
					_local5 = pos.y - angleTargetPos.y;
					_local14 = _local2 * _local2 + _local5 * _local5;
					if(_local14 > 1.1025 * (targetRange * targetRange)) {
						_local13 = 1;
					} else if(_local14 < 0.9025 * (targetRange * targetRange)) {
						_local13 = -1;
					} else {
						_local13 = 0;
						heading.speed.x = 0.98 * heading.speed.x;
						heading.speed.y = 0.98 * heading.speed.y;
					}
				} else {
					_local13 = 1;
				}
				_local3 = heading.speed.x;
				_local4 = heading.speed.y;
				_local3 += _local13 * (Math.cos(heading.rotation) * acceleration * 0.5 * Math.pow(_local9,2));
				_local4 += _local13 * (Math.sin(heading.rotation) * acceleration * 0.5 * Math.pow(_local9,2));
				if(_local3 * _local3 + _local4 * _local4 <= speed * speed) {
					heading.speed.x = _local3;
					heading.speed.y = _local4;
				} else {
					_local6 = Math.sqrt(_local3 * _local3 + _local4 * _local4);
					_local8 = _local3 / _local6 * speed;
					_local7 = _local4 / _local6 * speed;
					heading.speed.x = _local8;
					heading.speed.y = _local7;
				}
			}
			heading.speed.x -= 0.009 * heading.speed.x;
			heading.speed.y -= 0.009 * heading.speed.y;
			heading.pos.x += heading.speed.x * _local9 / 1000;
			heading.pos.y += heading.speed.y * _local9 / 1000;
			heading.time += _local9;
			if(holonomic || rotationForced) {
				course.rotation = oldAngle;
			}
			aiAddError(heading);
		}
		
		public function calcHpMax() : void {
			hp = 0;
			hpMax = 0;
			for each(var _local1 in allComponents) {
				if(_local1.essential) {
					hp += _local1.hp + _local1.shieldHp;
					hpMax += _local1.hpMax + _local1.shieldHpMax;
				}
			}
		}
		
		private function aiAddError(heading:Heading) : void {
			var _local2:Number = NaN;
			var _local4:Number = NaN;
			var _local3:Number = NaN;
			if(error != null) {
				_local2 = g.time;
				_local4 = (convergeTime - (_local2 - convergeStartTime)) / convergeTime;
				_local3 = 3 * _local4 * _local4 - 2 * _local4 * _local4 * _local4;
				if(_local4 > 0) {
					heading.pos.x += _local3 * error.x;
					heading.pos.y += _local3 * error.y;
					heading.rotation += _local3 * errorAngle;
					errorOldTime = _local2;
				} else {
					error = null;
					errorOldTime = 0;
				}
			}
		}
		
		private function aiRemoveError(heading:Heading) : void {
			var _local3:Number = NaN;
			var _local2:Number = NaN;
			if(error != null && errorOldTime != 0) {
				_local3 = (convergeTime - (errorOldTime - convergeStartTime)) / convergeTime;
				_local2 = 3 * _local3 * _local3 - 2 * _local3 * _local3 * _local3;
				heading.pos.x -= _local2 * error.x;
				heading.pos.y -= _local2 * error.y;
				heading.rotation -= _local2 * errorAngle;
			}
		}
		
		public function setConvergeTarget(t:Heading) : void {
			error = new Point(course.pos.x - t.pos.x,course.pos.y - t.pos.y);
			errorAngle = Util.angleDifference(course.rotation,t.rotation);
			convergeStartTime = g.time;
			course.speed = t.speed;
			course.pos = t.pos;
			course.rotation = t.rotation;
			course.time = t.time;
			aiAddError(course);
		}
		
		public function overrideConvergeTarget(posx:Number, posy:Number) : void {
			error = null;
			errorAngle = 0;
			errorOldTime = 0;
			convergeStartTime = g.time;
			course.pos.x = posx;
			course.pos.y = posy;
			course.time = g.time;
		}
		
		public function destroy() : void {
			var _local2:Turret = null;
			var _local1:Spawner = null;
			var _local4:ISound = null;
			alive = false;
			for each(var _local3 in allComponents) {
				_local3.destroy(_local3.alive);
				_local3.alive = false;
				_local3.active = false;
				_local3.visible = false;
				if(_local3 is Turret) {
					_local2 = _local3 as Turret;
					if(_local2.weapon != null) {
						_local2.weapon.fire = false;
					}
					_local2.visible = false;
					g.turretManager.removeTurret(_local2);
				}
				if(_local3 is Spawner) {
					_local1 = _local3 as Spawner;
					_local3.destroy();
					g.spawnManager.removeSpawner(_local1);
				}
				g.unitManager.remove(_local3);
			}
			if(g.camera.isCircleOnScreen(pos.x,pos.y,radius)) {
				if(explosionSound != "") {
					_local4 = SoundLocator.getService();
					_local4.play(explosionSound);
				}
				if(explosionEffect != "") {
					EmitterFactory.create(explosionEffect,g,pos.x,pos.y,null,true);
				}
			}
		}
		
		public function getComponent(id:int) : Unit {
			for each(var _local2 in allComponents) {
				if(_local2.syncId == id) {
					return _local2;
				}
			}
			return null;
		}
		
		override public function draw() : void {
			if(awaitingActivation) {
				return;
			}
			for each(var _local1 in allComponents) {
				_local1.draw();
			}
		}
	}
}

