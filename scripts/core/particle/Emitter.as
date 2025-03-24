package core.particle {
	import core.GameObject;
	import core.scene.Game;
	import flash.geom.Point;
	import generics.Color;
	import generics.GUID;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class Emitter {
		public static var POOL_SIZE_MIN:int = 5;
		
		public static var POOL_SIZE_MAX:int = 100;
		
		public static var IS_HIGH_GRAPHICS:Boolean = true;
		
		public var name:String;
		
		private var _txt:Texture;
		
		public var speed:Number;
		
		public var speedVariance:Number;
		
		public var sourceVarianceX:Number = 0;
		
		public var sourceVarianceY:Number = 0;
		
		public var gravityX:Number = 0;
		
		public var gravityY:Number = 0;
		
		public var useFriction:Boolean;
		
		public var alive:Boolean;
		
		public var angle:Number;
		
		public var posX:Number = 0;
		
		public var posY:Number = 0;
		
		public var steadyStream:Boolean;
		
		public var followEmitter:Boolean;
		
		public var followTarget:Boolean;
		
		public var target:GameObject;
		
		public var targetPosX:Number = 0;
		
		public var targetPosY:Number = 0;
		
		public var global:Boolean;
		
		public var delay:Number;
		
		public var ttl:int;
		
		public var ttlVariance:int;
		
		private var _startSize:Number;
		
		public var startSizeVariance:Number;
		
		private var _finishSize:Number;
		
		public var finishSizeVariance:Number;
		
		public var angleVariance:Number;
		
		public var uniformDistribution:Boolean;
		
		public var centralGravity:Boolean;
		
		private var maxRadius:Number;
		
		private var maxSize:Number;
		
		public var startAlpha:Number;
		
		public var startAlphaVariance:Number;
		
		public var finishAlpha:Number;
		
		public var startBlendMode:String;
		
		public var finishBlendMode:String;
		
		public var shakeIntensity:Number = 0;
		
		public var shakeDuration:Number = 0;
		
		public var key:String;
		
		public var guid:String;
		
		public var xOffset:int = 0;
		
		public var yOffset:int = 0;
		
		public var canvasTarget:Sprite;
		
		public var oldImageKey:String = "";
		
		private var _maxParticles:int;
		
		private var _duration:int;
		
		public var isEmitting:Boolean;
		
		private var timeElapsed:int = 0;
		
		private var emittAccum:Number = 0;
		
		private var g:Game;
		
		public var particles:Vector.<Particle>;
		
		private var inactiveParticles:Vector.<Particle>;
		
		public var collectiveMeshBatch:CollectiveMeshBatch;
		
		public var isOnScreen:Boolean = false;
		
		public var forceUpdate:Boolean;
		
		public var distanceToCamera:int = 0;
		
		public var distanceToCameraX:int = 0;
		
		public var distanceToCameraY:int = 0;
		
		public var nextDistanceCalculation:int = -1;
		
		private var MAX_CALC_DELAY:int = 5000;
		
		private var _startColor:uint = 0;
		
		private var _originalStartColor:uint = 0;
		
		private var _finishColor:uint = 0;
		
		private var _originalFinishColor:uint = 0;
		
		public function Emitter(g:Game) {
			var _local2:int = 0;
			particles = new Vector.<Particle>();
			inactiveParticles = new Vector.<Particle>();
			this.g = g;
			super();
			guid = GUID.create();
			_local2 = 0;
			while(_local2 < POOL_SIZE_MIN) {
				inactiveParticles.push(new Particle());
				_local2++;
			}
		}
		
		public static function setLowGraphics() : void {
			POOL_SIZE_MIN = 2;
			POOL_SIZE_MAX = 6;
			IS_HIGH_GRAPHICS = false;
		}
		
		public static function setHighGraphics() : void {
			POOL_SIZE_MIN = 5;
			POOL_SIZE_MAX = 100;
			IS_HIGH_GRAPHICS = true;
		}
		
		public function set startSize(value:Number) : void {
			_startSize = value;
			maxSize = Math.max(_startSize,_finishSize);
		}
		
		public function get startSize() : Number {
			return _startSize;
		}
		
		public function set finishSize(value:Number) : void {
			_finishSize = value;
			maxSize = Math.max(_startSize,_finishSize);
		}
		
		public function get finishSize() : Number {
			return _finishSize;
		}
		
		public function play() : void {
			var _local1:Number = NaN;
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local5:Number = NaN;
			var _local7:Number = NaN;
			var _local2:Number = NaN;
			var _local6:int = 0;
			timeElapsed = 0;
			isEmitting = true;
			nextDistanceCalculation = -1;
			if(shakeIntensity > 0 && shakeDuration > 0) {
				if(g.me == null || g.me.ship == null) {
					return;
				}
				_local1 = posX - g.me.ship.pos.x;
				_local3 = posY - g.me.ship.pos.y;
				_local4 = _local1 * _local1 + _local3 * _local3;
				_local5 = 10000;
				if(_local4 > _local5) {
					return;
				}
				_local7 = _local4 == 0 ? 1 : _local4 / _local5;
				_local2 = (shakeIntensity - shakeIntensity * _local7) / 10;
				_local6 = shakeDuration;
				if(_local2 > 0.0015) {
					g.camera.shake(_local2,_local6);
				}
			}
		}
		
		public function stop() : void {
			isEmitting = false;
			isOnScreen = false;
			setParticlesInactive();
		}
		
		public function get radius() : Number {
			return maxRadius * maxSize;
		}
		
		private function updatePosition() : void {
			var _local2:Number = NaN;
			var _local1:Number = NaN;
			if(!followTarget || target == null) {
				return;
			}
			targetPosX = target.pos.x;
			targetPosY = target.pos.y;
			if(yOffset != 0) {
				_local2 = Math.abs(yOffset);
				_local1 = Math.atan(yOffset);
				posX = targetPosX + Math.cos(angle + _local1) * _local2;
				posY = targetPosY + Math.sin(angle + _local1) * _local2;
				angle = target.rotation + 3.141592653589793;
			} else {
				posX = targetPosX;
				posY = targetPosY;
				angle = target.rotation;
			}
		}
		
		private function updateOnScreen() : void {
			forceUpdate = false;
			isOnScreen = canvasTarget != null;
			if(isOnScreen) {
				nextDistanceCalculation = 1000;
				return;
			}
			isOnScreen = g.camera.isCircleOnScreen(this.posX,this.posY,100);
			if(isOnScreen) {
				nextDistanceCalculation = 1000;
				return;
			}
			var _local1:Point = g.camera.getCameraCenter();
			distanceToCameraX = posX - _local1.x;
			distanceToCameraY = posY - _local1.y;
			distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			nextDistanceCalculation = distanceToCamera;
			if(nextDistanceCalculation > MAX_CALC_DELAY) {
				nextDistanceCalculation = MAX_CALC_DELAY + Math.random() * 200;
			}
			isOnScreen = false;
		}
		
		public function update() : void {
			var _local2:int = 0;
			if(constantEmitter && !isEmitting) {
				return;
			}
			var _local1:int = 33;
			nextDistanceCalculation -= _local1;
			if(nextDistanceCalculation <= 0) {
				updatePosition();
				updateOnScreen();
			} else if(isOnScreen || forceUpdate) {
				updatePosition();
			}
			if(!isOnScreen && !global) {
				setParticlesInactive();
				updateTime();
				return;
			}
			if(isEmitting && timeElapsed >= delay) {
				updateParticleCount();
			}
			drawParticels();
			setBatchParent();
			updateTime();
		}
		
		private function updateTime() : void {
			if(constantEmitter) {
				return;
			}
			if(isEmitting) {
				timeElapsed += 33;
			}
			if(timeElapsed >= _duration + delay) {
				isEmitting = false;
				if(particles.length == 0) {
					alive = false;
				}
			}
		}
		
		private function get constantEmitter() : Boolean {
			return _duration == -1;
		}
		
		private function updateParticleCount() : void {
			var _local4:int = 0;
			var _local5:int = 0;
			var _local2:int = 0;
			var _local1:int = 33;
			if(!constantEmitter || steadyStream) {
				emittAccum += ppms * _local1;
				if(emittAccum >= 1) {
					_local2 = emittAccum;
					emittAccum = 0;
				}
			} else {
				_local2 = 1;
			}
			var _local3:int = int(particles.length);
			var _local6:int = int(inactiveParticles.length);
			if(_local2 > _local6 && _local3 + _local6 < POOL_SIZE_MAX) {
				_local5 = _local2 - _local6;
				if(_local5 + _local3 + _local6 > POOL_SIZE_MAX) {
					_local5 = POOL_SIZE_MAX - (_local3 + _local6);
				}
				if(_local5 > 0) {
					_local4 = 0;
					while(_local4 < _local5) {
						inactiveParticles.push(new Particle());
						_local4++;
					}
				}
			}
			_local5 = maxParticles - _local3;
			_local4 = 1;
			while(_local4 <= _local2) {
				add(_local4,_local5);
				_local4++;
			}
		}
		
		public function drawParticels() : void {
			var _local2:Particle = null;
			var _local8:Number = NaN;
			var _local4:Number = NaN;
			var _local12:Number = NaN;
			var _local6:Number = NaN;
			var _local9:int = 0;
			var _local11:Number = NaN;
			var _local10:Number = NaN;
			var _local5:Number = NaN;
			collectiveMeshBatch.clear();
			var _local1:int = 33;
			var _local7:Number = _local1 * 0.001;
			var _local3:int = int(particles.length);
			_local9 = _local3 - 1;
			while(_local9 > -1) {
				_local2 = particles[_local9];
				if(_local2.ttl - _local1 <= 0) {
					remove(_local2,_local9);
				} else {
					_local4 = _local2.rotation;
					_local12 = _local2.speed * _local7;
					_local11 = _local2.ttl / _local2.totalTtl;
					if(!followEmitter) {
						_local6 = _local2.x;
						_local8 = _local2.y;
						_local6 += Math.cos(_local4) * _local12;
						_local8 += Math.sin(_local4) * _local12;
						_local6 += gravityX * _local7;
						_local8 += gravityY * _local7;
						if(centralGravity) {
							_local6 = (_local6 - posX) * _local11 + posX;
							_local8 = (_local8 - posY) * _local11 + posY;
						}
					} else {
						if(centralGravity) {
							_local2.localPosX *= _local11;
							_local2.localPosY *= _local11;
						}
						_local2.localPosX += Math.cos(_local4) * _local12;
						_local2.localPosY += Math.sin(_local4) * _local12;
						_local6 = _local2.localPosX + posX;
						_local8 = _local2.localPosY + posY;
						_local2.rotation = angle;
					}
					_local2.x = _local6;
					_local2.y = _local8;
					_local10 = (_local2.startSize - _local2.finishSize) * _local11 + _local2.finishSize;
					_local2.scaleX = _local10;
					_local2.scaleY = _local10;
					if(_local2.ticks % 3 == 0) {
						_local2.color = Color.interpolateColor(_startColor,_finishColor,1 - _local11);
					}
					_local2.ticks++;
					_local5 = (_local2.startAlpha - _local2.finishAlpha) * _local11 + _local2.finishAlpha;
					if(useFriction) {
						_local2.speed *= 0.98;
					}
					_local2.ttl -= _local1;
					if(isOnScreen) {
						collectiveMeshBatch.addMesh(_local2,null,_local5);
					}
					if(IS_HIGH_GRAPHICS && collectiveMeshBatch.numVertices > 800) {
						POOL_SIZE_MIN = 2;
						POOL_SIZE_MAX = 10;
					} else if(IS_HIGH_GRAPHICS && collectiveMeshBatch.numVertices < 400) {
						setHighGraphics();
					}
				}
				_local9--;
			}
		}
		
		public function setBatchParent() : void {
			if(collectiveMeshBatch.parent != null) {
				return;
			}
			if(canvasTarget) {
				canvasTarget.addChild(collectiveMeshBatch);
			} else {
				g.canvasEffects.addChild(collectiveMeshBatch);
			}
		}
		
		private function add(i:int = 0, maxNewParts:int = 1) : void {
			if(particles.length > maxParticles || inactiveParticles.length == 0) {
				return;
			}
			var _local3:Particle = inactiveParticles.pop();
			if(_local3.texture != _txt) {
				_local3.texture = _txt;
			}
			var _local7:Number = sourceVarianceY - Math.random() * sourceVarianceY * 2;
			var _local6:Number = sourceVarianceX - Math.random() * sourceVarianceX * 2;
			var _local10:Number = Math.sqrt(_local6 * _local6 + _local7 * _local7);
			var _local9:Number = Math.atan2(_local7,_local6);
			if(uniformDistribution && maxNewParts > 0) {
				_local3.rotation = angle + (angleVariance - (i / maxNewParts + 0.01 - 0.02 * Math.random()) * angleVariance * 2);
			} else {
				_local3.rotation = angle + (angleVariance - Math.random() * angleVariance * 2);
			}
			var _local8:Number = angle + _local9;
			var _local4:Number = Math.cos(_local8) * _local10;
			var _local5:Number = Math.sin(_local8) * _local10;
			_local3.x = posX + _local4;
			_local3.y = posY + _local5;
			_local3.localPosX = _local4;
			_local3.localPosY = _local5;
			_local3.totalTtl = ttl + (ttlVariance - Math.random() * ttlVariance * 2);
			_local3.ttl = _local3.totalTtl;
			_local3.speed = speed + (speedVariance - Math.random() * speedVariance * 2);
			_local3.startSize = startSize + (startSizeVariance - Math.random() * startSizeVariance * 2);
			_local3.finishSize = finishSize + (finishSizeVariance - Math.random() * finishSizeVariance * 2);
			_local3.startAlpha = startAlpha + (startAlphaVariance - Math.random() * startAlphaVariance * 2);
			_local3.finishAlpha = finishAlpha;
			_local3.visible = true;
			_local3.ticks = 0;
			particles.push(_local3);
		}
		
		private function remove(p:Particle, index:int) : void {
			inactiveParticles.push(p);
			if(index == particles.length - 1) {
				particles.pop();
			} else {
				particles[index] = particles.pop();
			}
		}
		
		private function setParticlesInactive() : void {
			var _local1:int = 0;
			if(particles.length == 0) {
				return;
			}
			_local1 = 0;
			while(_local1 < particles.length) {
				inactiveParticles.push(particles[_local1]);
				_local1++;
			}
			particles.length = 0;
		}
		
		public function killEmitter() : void {
			var _local1:int = 0;
			isEmitting = false;
			alive = false;
			_local1 = 0;
			while(_local1 < particles.length) {
				inactiveParticles.push(particles[_local1]);
				_local1++;
			}
			particles.length = 0;
			removeFromCollectiveMeshBatch();
		}
		
		private function removeFromCollectiveMeshBatch() : void {
			if(collectiveMeshBatch == null) {
				return;
			}
			collectiveMeshBatch.remove(this);
		}
		
		public function dispose() : void {
			sourceVarianceX = 0;
			sourceVarianceY = 0;
			ttl = 200;
			duration = -1;
			maxParticles = 100;
			speed = 0;
			speedVariance = 0;
			gravityX = 0;
			gravityY = 0;
			useFriction = true;
			ttlVariance = 0;
			startSize = 1;
			startSizeVariance = 0;
			finishSize = 0;
			finishSizeVariance = 0;
			angleVariance = 0;
			startColor = 0xffffff;
			finishColor = 0xffffff;
			startAlpha = 1;
			finishAlpha = 0;
			startAlphaVariance = 0;
			startBlendMode = "add";
			finishBlendMode = "add";
			steadyStream = false;
			followEmitter = false;
			followTarget = false;
			global = false;
			delay = 0;
			canvasTarget = null;
			target = null;
			targetPosX = 0;
			targetPosY = 0;
			shakeIntensity = 0;
			shakeDuration = 0;
			distanceToCamera = 0;
			distanceToCameraX = 0;
			distanceToCameraY = 0;
			isOnScreen = false;
			nextDistanceCalculation = -1;
			xOffset = 0;
			yOffset = 0;
			isEmitting = false;
			alive = false;
			angle = 0;
			collectiveMeshBatch = null;
		}
		
		public function set startColor(c:uint) : void {
			_startColor = c;
			_originalStartColor = c;
		}
		
		public function changeHue(r:Number) : void {
			_startColor = Color.HEXHue(_originalStartColor,r);
			_finishColor = Color.HEXHue(_originalFinishColor,r);
		}
		
		public function set finishColor(c:uint) : void {
			_finishColor = c;
			_originalFinishColor = c;
		}
		
		private function get ppms() : Number {
			if(duration != -1) {
				return _maxParticles / duration;
			}
			if(duration == -1 && steadyStream) {
				return _maxParticles / ttl;
			}
			return 1;
		}
		
		public function set duration(d:int) : void {
			_duration = d;
		}
		
		public function get duration() : int {
			return _duration;
		}
		
		public function set maxParticles(count:int) : void {
			if(count > POOL_SIZE_MAX) {
				_maxParticles = POOL_SIZE_MAX;
			} else {
				_maxParticles = count;
			}
		}
		
		public function get maxParticles() : int {
			return _maxParticles;
		}
		
		public function fastForward(ticks:int) : void {
			var _local2:int = 0;
			if(!alive) {
				return;
			}
			_local2 = 0;
			while(_local2 < ticks) {
				update();
				_local2++;
			}
		}
		
		public function set txt(t:Texture) : void {
			_txt = t;
			if(t != null) {
				maxRadius = Math.max(t.width,t.height);
			}
		}
		
		public function get txt() : Texture {
			return _txt;
		}
	}
}

