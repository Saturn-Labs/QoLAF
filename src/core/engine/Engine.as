package core.engine
{
	import core.GameObject;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.ship.Ship;
	import extensions.RibbonSegment;
	import extensions.RibbonTrail;
	import flash.geom.Point;
	import generics.Color;
	
	public class Engine extends GameObject
	{
		public var thrustEmitters:Vector.<Emitter>;
		
		public var idleThrustEmitters:Vector.<Emitter>;
		
		public var speed:Number;
		
		private var _rotationSpeed:Number;
		
		public var rotationMod:Number;
		
		public var acceleration:Number;
		
		public var accelerating:Boolean;
		
		private var g:Game;
		
		public var ship:Ship;
		
		public var alive:Boolean;
		
		public var dual:Boolean = false;
		
		public var dualDistance:int = 0;
		
		public var obj:Object;
		
		public var colorHue:Number = 0;
		
		public var ribbonBaseMovingRatio:Number = 1;
		
		public var hasRibbonTrail:Boolean = false;
		
		public var ribbonThickness:Number = 0;
		
		public var ribbonTrail:RibbonTrail;
		
		private var followingRibbonSegment:RibbonSegment;
		
		public var followingRibbonSegmentLine:Vector.<RibbonSegment>;
		
		public function Engine(param1:Game)
		{
			followingRibbonSegment = new RibbonSegment();
			followingRibbonSegmentLine = new <RibbonSegment>[followingRibbonSegment];
			super();
			this.g = param1;
			acceleration = 0;
			speed = 0;
			rotationSpeed = 0;
			rotationMod = 1;
			rotation = 0;
			alive = true;
			ship = null;
			accelerating = false;
		}
		
		override public function update():void
		{
			var _loc6_:Point = null;
			var _loc4_:Number = NaN;
			var _loc1_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc8_:Number = NaN;
			var _loc5_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc2_:Number = NaN;
			if (alive && ship != null && ship.alive)
			{
				_loc6_ = ship.enginePos;
				_loc4_ = _loc6_.y;
				_loc1_ = _loc6_.x;
				_loc7_ = Math.sqrt(_loc1_ * _loc1_ + _loc4_ * _loc4_);
				_loc8_ = 0;
				if (_loc1_ != 0)
				{
					_loc8_ = Math.atan(_loc4_ / _loc1_);
				}
				_rotation = ship.rotation + 3.141592653589793;
				_loc5_ = Math.cos(_rotation + _loc8_) * _loc7_;
				_loc3_ = Math.sin(_rotation + _loc8_) * _loc7_;
				_pos.x = ship.x + _loc5_;
				_pos.y = ship.y + _loc3_;
				if (ribbonTrail && ribbonTrail.isPlaying)
				{
					if (ship.speed.x != 0 || ship.speed.y != 0)
					{
						_loc2_ = Math.atan2(ship.speed.y, ship.speed.x) + 3.141592653589793;
					}
					else
					{
						_loc2_ = ship.rotation + 3.141592653589793;
					}
					followingRibbonSegment.setTo2(_pos.x, _pos.y, ribbonThickness, _loc2_, 1);
					ribbonTrail.advanceTime(33);
				}
			}
		}
		
		public function accelerate():void
		{
			var _loc2_:int = 0;
			var _loc1_:int = 0;
			if (accelerating)
			{
				return;
			}
			if (ribbonTrail)
			{
				ribbonTrail.movingRatio = ribbonBaseMovingRatio;
			}
			accelerating = true;
			if (!thrustEmitters)
			{
				return;
			}
			_loc2_ = 0;
			while (_loc2_ < thrustEmitters.length)
			{
				thrustEmitters[_loc2_].play();
				_loc2_++;
			}
			if (idleThrustEmitters != null)
			{
				_loc1_ = 0;
				while (_loc1_ < idleThrustEmitters.length)
				{
					idleThrustEmitters[_loc1_].stop();
					_loc1_++;
				}
			}
		}
		
		public function idle():void
		{
			var _loc2_:int = 0;
			var _loc1_:int = 0;
			if (!accelerating)
			{
				return;
			}
			if (ribbonTrail)
			{
				ribbonTrail.movingRatio = ribbonBaseMovingRatio * 1.5;
			}
			accelerating = false;
			if (!thrustEmitters)
			{
				return;
			}
			_loc2_ = 0;
			while (_loc2_ < thrustEmitters.length)
			{
				thrustEmitters[_loc2_].stop();
				_loc2_++;
			}
			if (idleThrustEmitters != null)
			{
				_loc1_ = 0;
				while (_loc1_ < idleThrustEmitters.length)
				{
					idleThrustEmitters[_loc1_].play();
					_loc1_++;
				}
			}
		}
		
		public function stop():void
		{
			var _loc2_:int = 0;
			var _loc1_:int = 0;
			if (ribbonTrail)
			{
				ribbonTrail.movingRatio = ribbonBaseMovingRatio * 1.5;
			}
			accelerating = false;
			if (!thrustEmitters)
			{
				return;
			}
			_loc2_ = 0;
			while (_loc2_ < thrustEmitters.length)
			{
				thrustEmitters[_loc2_].stop();
				_loc2_++;
			}
			if (idleThrustEmitters != null)
			{
				_loc1_ = 0;
				while (_loc1_ < idleThrustEmitters.length)
				{
					idleThrustEmitters[_loc1_].stop();
					_loc1_++;
				}
			}
		}
		
		public function destroy():void
		{
			hide();
			reset();
		}
		
		public function hide():void
		{
			var _loc2_:int = 0;
			var _loc1_:int = 0;
			if (hasRibbonTrail)
			{
				ribbonTrail.isPlaying = false;
			}
			if (!thrustEmitters)
			{
				return;
			}
			_loc2_ = 0;
			while (_loc2_ < thrustEmitters.length)
			{
				thrustEmitters[_loc2_].alive = false;
				_loc2_++;
			}
			if (idleThrustEmitters != null)
			{
				_loc1_ = 0;
				while (_loc1_ < idleThrustEmitters.length)
				{
					idleThrustEmitters[_loc1_].alive = false;
					_loc1_++;
				}
			}
			thrustEmitters = null;
			idleThrustEmitters = null;
		}
		
		public function show():void
		{
			var _loc5_:* = undefined;
			var _loc4_:Emitter = null;
			var _loc2_:* = undefined;
			var _loc1_:* = undefined;
			var _loc6_:* = undefined;
			if (hasRibbonTrail)
			{
				ribbonTrail.isPlaying = true;
				resetTrail();
			}
			if (!obj.useEffects || obj.effect == null)
			{
				return;
			}
			if (thrustEmitters != null)
			{
				return;
			}
			var _loc8_:int = 0;
			thrustEmitters = new Vector.<Emitter>();
			if (dual)
			{
				_loc5_ = EmitterFactory.create(obj.effect, g, x, y, this, accelerating);
				_loc8_ = 0;
				while (_loc8_ < _loc5_.length)
				{
					_loc4_ = _loc5_[_loc8_];
					_loc4_.yOffset = dualDistance / 2;
					thrustEmitters.push(_loc4_);
					_loc8_++;
				}
				_loc2_ = EmitterFactory.create(obj.effect, g, x, y, this, accelerating);
				_loc8_ = 0;
				while (_loc8_ < _loc2_.length)
				{
					_loc4_ = _loc2_[_loc8_];
					_loc4_.yOffset = -dualDistance / 2;
					thrustEmitters.push(_loc4_);
					_loc8_++;
				}
			}
			else
			{
				thrustEmitters = EmitterFactory.create(obj.effect, g, x, y, this, accelerating);
			}
			if (obj.changeThrustColors)
			{
				for each (var _loc7_:* in thrustEmitters)
				{
					_loc7_.startColor = Color.HEXHue(obj.thrustStartColor, colorHue);
					_loc7_.finishColor = Color.HEXHue(obj.thrustFinishColor, colorHue);
				}
			}
			else
			{
				for each (_loc7_ in thrustEmitters)
				{
					_loc7_.changeHue(colorHue);
				}
			}
			idleThrustEmitters = new Vector.<Emitter>();
			if (dual)
			{
				_loc1_ = EmitterFactory.create(obj.idleEffect, g, x, y, this, !accelerating);
				_loc8_ = 0;
				while (_loc8_ < _loc1_.length)
				{
					_loc1_[_loc8_].yOffset = dualDistance / 2;
					idleThrustEmitters.push(_loc1_[_loc8_]);
					_loc8_++;
				}
				_loc6_ = EmitterFactory.create(obj.idleEffect, g, x, y, this, !accelerating);
				_loc8_ = 0;
				while (_loc8_ < _loc6_.length)
				{
					_loc6_[_loc8_].yOffset = -dualDistance / 2;
					idleThrustEmitters.push(_loc6_[_loc8_]);
					_loc8_++;
				}
			}
			else
			{
				idleThrustEmitters = EmitterFactory.create(obj.idleEffect, g, x, y, this, !accelerating);
			}
			if (obj.changeIdleThrustColors)
			{
				for each (var _loc3_:* in idleThrustEmitters)
				{
					_loc3_.startColor = Color.HEXHue(obj.idleThrustStartColor, colorHue);
					_loc3_.finishColor = Color.HEXHue(obj.idleThrustFinishColor, colorHue);
				}
			}
			else
			{
				for each (_loc3_ in idleThrustEmitters)
				{
					_loc3_.changeHue(colorHue);
				}
			}
		}
		
		public function get rotationSpeed():Number
		{
			return _rotationSpeed * rotationMod;
		}
		
		public function set rotationSpeed(param1:Number):void
		{
			_rotationSpeed = param1;
		}
		
		public function resetTrail():void
		{
			if (hasRibbonTrail)
			{
				followingRibbonSegment.setTo2(ship.pos.x, ship.pos.y, 2, 0, 1);
				ribbonTrail.resetAllTo(ship.pos.x, ship.pos.y, ship.pos.x, ship.pos.y, 0.85);
				ribbonTrail.advanceTime(33);
			}
		}
		
		override public function reset():void
		{
			thrustEmitters = null;
			idleThrustEmitters = null;
			_rotationSpeed = 0;
			acceleration = 0;
			speed = 0;
			rotationSpeed = 0;
			rotationMod = 1;
			rotation = 0;
			alive = true;
			ship = null;
			accelerating = false;
			ribbonBaseMovingRatio = 1;
			hasRibbonTrail = false;
			ribbonThickness = 0;
			if (ribbonTrail)
			{
				g.ribbonTrailPool.removeRibbonTrail(ribbonTrail);
				ribbonTrail.isPlaying = false;
				ribbonTrail.resetAllTo(0, 0, 0, 0, 0);
				ribbonTrail = null;
			}
		}
	}
}
