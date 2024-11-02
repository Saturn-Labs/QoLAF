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
		
		public function Emitter(param1:Game) {
			var _loc2_:int = 0;
			particles = new Vector.<Particle>();
			inactiveParticles = new Vector.<Particle>();
			this.g = param1;
			super();
			guid = GUID.create();
			_loc2_ = 0;
			while (_loc2_ < POOL_SIZE_MIN) {
				inactiveParticles.push(new Particle());
				_loc2_++;
			}
		}
		
		public static function setLowGraphics():void {
			POOL_SIZE_MIN = 2;
			POOL_SIZE_MAX = 6;
			IS_HIGH_GRAPHICS = false;
		}
		
		public static function setHighGraphics():void {
			POOL_SIZE_MIN = 5;
			POOL_SIZE_MAX = 100;
			IS_HIGH_GRAPHICS = true;
		}
		
		public function set startSize(param1:Number):void {
			_startSize = param1;
			maxSize = Math.max(_startSize, _finishSize);
		}
		
		public function get startSize():Number {
			return _startSize;
		}
		
		public function set finishSize(param1:Number):void {
			_finishSize = param1;
			maxSize = Math.max(_startSize, _finishSize);
		}
		
		public function get finishSize():Number {
			return _finishSize;
		}
		
		public function play():void {
			var _loc2_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc1_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc3_:int = 0;
			timeElapsed = 0;
			isEmitting = true;
			nextDistanceCalculation = -1;
			if (shakeIntensity > 0 && shakeDuration > 0) {
				if (g.me == null || g.me.ship == null) {
					return;
				}
				_loc2_ = posX - g.me.ship.pos.x;
				_loc7_ = posY - g.me.ship.pos.y;
				_loc1_ = _loc2_ * _loc2_ + _loc7_ * _loc7_;
				_loc6_ = 10000;
				if (_loc1_ > _loc6_) {
					return;
				}
				_loc4_ = _loc1_ == 0 ? 1 : _loc1_ / _loc6_;
				_loc5_ = (shakeIntensity - shakeIntensity * _loc4_) / 10;
				_loc3_ = shakeDuration;
				if (_loc5_ > 0.0015) {
					g.camera.shake(_loc5_, _loc3_);
				}
			}
		}
		
		public function stop():void {
			isEmitting = false;
			isOnScreen = false;
			setParticlesInactive();
		}
		
		public function get radius():Number {
			return maxRadius * maxSize;
		}
		
		private function updatePosition():void {
			var _loc1_:Number = NaN;
			var _loc2_:Number = NaN;
			if (!followTarget || target == null) {
				return;
			}
			targetPosX = target.pos.x;
			targetPosY = target.pos.y;
			if (yOffset != 0) {
				_loc1_ = Math.abs(yOffset);
				_loc2_ = Math.atan(yOffset);
				posX = targetPosX + Math.cos(angle + _loc2_) * _loc1_;
				posY = targetPosY + Math.sin(angle + _loc2_) * _loc1_;
				angle = target.rotation + 3.141592653589793;
			} else {
				posX = targetPosX;
				posY = targetPosY;
				angle = target.rotation;
			}
		}
		
		private function updateOnScreen():void {
			forceUpdate = false;
			isOnScreen = canvasTarget != null;
			if (isOnScreen) {
				nextDistanceCalculation = 1000;
				return;
			}
			isOnScreen = g.camera.isCircleOnScreen(this.posX, this.posY, 100);
			if (isOnScreen) {
				nextDistanceCalculation = 1000;
				return;
			}
			var _loc1_:Point = g.camera.getCameraCenter();
			distanceToCameraX = posX - _loc1_.x;
			distanceToCameraY = posY - _loc1_.y;
			distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			nextDistanceCalculation = distanceToCamera;
			if (nextDistanceCalculation > MAX_CALC_DELAY) {
				nextDistanceCalculation = MAX_CALC_DELAY + Math.random() * 200;
			}
			isOnScreen = false;
		}
		
		public function update():void {
			var _loc2_:int = 0;
			if (constantEmitter && !isEmitting) {
				return;
			}
			var _loc1_:int = 33;
			nextDistanceCalculation -= _loc1_;
			if (nextDistanceCalculation <= 0) {
				updatePosition();
				updateOnScreen();
			} else if (isOnScreen || forceUpdate) {
				updatePosition();
			}
			if (!isOnScreen && !global) {
				setParticlesInactive();
				updateTime();
				return;
			}
			if (isEmitting && timeElapsed >= delay) {
				updateParticleCount();
			}
			drawParticels();
			setBatchParent();
			updateTime();
		}
		
		private function updateTime():void {
			if (constantEmitter) {
				return;
			}
			if (isEmitting) {
				timeElapsed += 33;
			}
			if (timeElapsed >= _duration + delay) {
				isEmitting = false;
				if (particles.length == 0) {
					alive = false;
				}
			}
		}
		
		private function get constantEmitter():Boolean {
			return _duration == -1;
		}
		
		private function updateParticleCount():void {
			var _loc6_:int = 0;
			var _loc4_:int = 0;
			var _loc3_:int = 0;
			var _loc2_:int = 33;
			if (!constantEmitter || steadyStream) {
				emittAccum += ppms * _loc2_;
				if (emittAccum >= 1) {
					_loc3_ = emittAccum;
					emittAccum = 0;
				}
			} else {
				_loc3_ = 1;
			}
			var _loc5_:int = int(particles.length);
			var _loc1_:int = int(inactiveParticles.length);
			if (_loc3_ > _loc1_ && _loc5_ + _loc1_ < POOL_SIZE_MAX) {
				_loc4_ = _loc3_ - _loc1_;
				if (_loc4_ + _loc5_ + _loc1_ > POOL_SIZE_MAX) {
					_loc4_ = POOL_SIZE_MAX - (_loc5_ + _loc1_);
				}
				if (_loc4_ > 0) {
					_loc6_ = 0;
					while (_loc6_ < _loc4_) {
						inactiveParticles.push(new Particle());
						_loc6_++;
					}
				}
			}
			_loc4_ = maxParticles - _loc5_;
			_loc6_ = 1;
			while (_loc6_ <= _loc3_) {
				add(_loc6_, _loc4_);
				_loc6_++;
			}
		}
		
		public function drawParticels():void {
			var _loc6_:Particle = null;
			var _loc10_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc12_:Number = NaN;
			var _loc11_:int = 0;
			var _loc9_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc5_:Number = NaN;
			collectiveMeshBatch.clear();
			var _loc1_:int = 33;
			var _loc3_:Number = _loc1_ * 0.001;
			var _loc7_:int = int(particles.length);
			_loc11_ = _loc7_ - 1;
			while (_loc11_ > -1) {
				_loc6_ = particles[_loc11_];
				if (_loc6_.ttl - _loc1_ <= 0) {
					remove(_loc6_, _loc11_);
				} else {
					_loc4_ = _loc6_.rotation;
					_loc8_ = _loc6_.speed * _loc3_;
					_loc9_ = _loc6_.ttl / _loc6_.totalTtl;
					if (!followEmitter) {
						_loc12_ = _loc6_.x;
						_loc10_ = _loc6_.y;
						_loc12_ += Math.cos(_loc4_) * _loc8_;
						_loc10_ += Math.sin(_loc4_) * _loc8_;
						_loc12_ += gravityX * _loc3_;
						_loc10_ += gravityY * _loc3_;
						if (centralGravity) {
							_loc12_ = (_loc12_ - posX) * _loc9_ + posX;
							_loc10_ = (_loc10_ - posY) * _loc9_ + posY;
						}
					} else {
						if (centralGravity) {
							_loc6_.localPosX *= _loc9_;
							_loc6_.localPosY *= _loc9_;
						}
						_loc6_.localPosX += Math.cos(_loc4_) * _loc8_;
						_loc6_.localPosY += Math.sin(_loc4_) * _loc8_;
						_loc12_ = _loc6_.localPosX + posX;
						_loc10_ = _loc6_.localPosY + posY;
						_loc6_.rotation = angle;
					}
					_loc6_.x = _loc12_;
					_loc6_.y = _loc10_;
					_loc2_ = (_loc6_.startSize - _loc6_.finishSize) * _loc9_ + _loc6_.finishSize;
					_loc6_.scaleX = _loc2_;
					_loc6_.scaleY = _loc2_;
					if (_loc6_.ticks % 3 == 0) {
						_loc6_.color = Color.interpolateColor(_startColor, _finishColor, 1 - _loc9_);
					}
					_loc6_.ticks++;
					_loc5_ = (_loc6_.startAlpha - _loc6_.finishAlpha) * _loc9_ + _loc6_.finishAlpha;
					if (useFriction) {
						_loc6_.speed *= 0.98;
					}
					_loc6_.ttl -= _loc1_;
					if (isOnScreen) {
						collectiveMeshBatch.addMesh(_loc6_, null, _loc5_);
					}
					if (IS_HIGH_GRAPHICS && collectiveMeshBatch.numVertices > 800) {
						POOL_SIZE_MIN = 2;
						POOL_SIZE_MAX = 10;
					} else if (IS_HIGH_GRAPHICS && collectiveMeshBatch.numVertices < 400) {
						setHighGraphics();
					}
				}
				_loc11_--;
			}
		}
		
		public function setBatchParent():void {
			if (collectiveMeshBatch.parent != null) {
				return;
			}
			if (canvasTarget) {
				canvasTarget.addChild(collectiveMeshBatch);
			} else {
				g.canvasEffects.addChild(collectiveMeshBatch);
			}
		}
		
		private function add(param1:int = 0, param2:int = 1):void {
			if (particles.length > maxParticles || inactiveParticles.length == 0) {
				return;
			}
			var _loc7_:Particle = inactiveParticles.pop();
			if (_loc7_.texture != _txt) {
				_loc7_.texture = _txt;
			}
			var _loc5_:Number = sourceVarianceY - Math.random() * sourceVarianceY * 2;
			var _loc3_:Number = sourceVarianceX - Math.random() * sourceVarianceX * 2;
			var _loc8_:Number = Math.sqrt(_loc3_ * _loc3_ + _loc5_ * _loc5_);
			var _loc10_:Number = Math.atan2(_loc5_, _loc3_);
			if (uniformDistribution && param2 > 0) {
				_loc7_.rotation = angle + (angleVariance - (param1 / param2 + 0.01 - 0.02 * Math.random()) * angleVariance * 2);
			} else {
				_loc7_.rotation = angle + (angleVariance - Math.random() * angleVariance * 2);
			}
			var _loc9_:Number = angle + _loc10_;
			var _loc6_:Number = Math.cos(_loc9_) * _loc8_;
			var _loc4_:Number = Math.sin(_loc9_) * _loc8_;
			_loc7_.x = posX + _loc6_;
			_loc7_.y = posY + _loc4_;
			_loc7_.localPosX = _loc6_;
			_loc7_.localPosY = _loc4_;
			_loc7_.totalTtl = ttl + (ttlVariance - Math.random() * ttlVariance * 2);
			_loc7_.ttl = _loc7_.totalTtl;
			_loc7_.speed = speed + (speedVariance - Math.random() * speedVariance * 2);
			_loc7_.startSize = startSize + (startSizeVariance - Math.random() * startSizeVariance * 2);
			_loc7_.finishSize = finishSize + (finishSizeVariance - Math.random() * finishSizeVariance * 2);
			_loc7_.startAlpha = startAlpha + (startAlphaVariance - Math.random() * startAlphaVariance * 2);
			_loc7_.finishAlpha = finishAlpha;
			_loc7_.visible = true;
			_loc7_.ticks = 0;
			particles.push(_loc7_);
		}
		
		private function remove(param1:Particle, param2:int):void {
			inactiveParticles.push(param1);
			if (param2 == particles.length - 1) {
				particles.pop();
			} else {
				particles[param2] = particles.pop();
			}
		}
		
		private function setParticlesInactive():void {
			var _loc1_:int = 0;
			if (particles.length == 0) {
				return;
			}
			_loc1_ = 0;
			while (_loc1_ < particles.length) {
				inactiveParticles.push(particles[_loc1_]);
				_loc1_++;
			}
			particles.length = 0;
		}
		
		public function killEmitter():void {
			var _loc1_:int = 0;
			isEmitting = false;
			alive = false;
			_loc1_ = 0;
			while (_loc1_ < particles.length) {
				inactiveParticles.push(particles[_loc1_]);
				_loc1_++;
			}
			particles.length = 0;
			removeFromCollectiveMeshBatch();
		}
		
		private function removeFromCollectiveMeshBatch():void {
			if (collectiveMeshBatch == null) {
				return;
			}
			collectiveMeshBatch.remove(this);
		}
		
		public function dispose():void {
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
			startColor = 16777215;
			finishColor = 16777215;
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
		
		public function set startColor(param1:uint):void {
			_startColor = param1;
			_originalStartColor = param1;
		}
		
		public function get startColor():uint {
			return _startColor;
		}
		
		public function changeHue(param1:Number):void {
			_startColor = Color.HEXHue(_originalStartColor, param1);
			_finishColor = Color.HEXHue(_originalFinishColor, param1);
		}
		
		public function set finishColor(param1:uint):void {
			_finishColor = param1;
			_originalFinishColor = param1;
		}
		
		private function get ppms():Number {
			if (duration != -1) {
				return _maxParticles / duration;
			}
			if (duration == -1 && steadyStream) {
				return _maxParticles / ttl;
			}
			return 1;
		}
		
		public function set duration(param1:int):void {
			_duration = param1;
		}
		
		public function get duration():int {
			return _duration;
		}
		
		public function set maxParticles(param1:int):void {
			if (param1 > POOL_SIZE_MAX) {
				_maxParticles = POOL_SIZE_MAX;
			} else {
				_maxParticles = param1;
			}
		}
		
		public function get maxParticles():int {
			return _maxParticles;
		}
		
		public function fastForward(param1:int):void {
			var _loc2_:int = 0;
			if (!alive) {
				return;
			}
			_loc2_ = 0;
			while (_loc2_ < param1) {
				update();
				_loc2_++;
			}
		}
		
		public function set txt(param1:Texture):void {
			_txt = param1;
			if (param1 != null) {
				maxRadius = Math.max(param1.width, param1.height);
			}
		}
		
		public function get txt():Texture {
			return _txt;
		}
	}
}
