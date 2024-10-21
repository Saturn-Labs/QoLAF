package core.drops
{
	import com.greensock.TweenMax;
	import core.GameObject;
	import core.hud.components.BeamLine;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import flash.geom.Point;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class Drop extends GameObject
	{
		public var key:String;
		
		public var collisionRadius:Number;
		
		public var speed:Point;
		
		public var size:int;
		
		public var quantity:int;
		
		public var expireTime:Number;
		
		public var tractorBeamPlayer:Player;
		
		public var effect:Vector.<Emitter>;
		
		public var expired:Boolean;
		
		protected var _picked:Boolean;
		
		protected var g:Game;
		
		private var fadeTween:TweenMax = null;
		
		private var randAngleSpeed:Number;
		
		private var beamLine:BeamLine;
		
		public var obj:Object;
		
		public function Drop(param1:Game)
		{
			speed = new Point();
			super();
			this.g = param1;
			canvas = param1.canvasDrops;
			beamLine = param1.beamLinePool.getLine();
			beamLine.init(1, 3, 3, 11184895, 0.6, 3, 6724095);
			randAngleSpeed = Math.random() / 12;
		}
		
		public function pickup(param1:Player, param2:Message, param3:int):Boolean
		{
			var _loc4_:PlayerShip = null;
			var _loc5_:Point = null;
			var _loc6_:ISound = null;
			if (_picked)
			{
				return true;
			}
			if (tractorBeamPlayer != null && tractorBeamPlayer.ship != null && tractorBeamPlayer.ship.course != null)
			{
				_loc4_ = tractorBeamPlayer.ship;
				_loc5_ = new Point(_loc4_.course.pos.x - pos.x, _loc4_.course.pos.y - pos.y);
				if (_loc5_.x * _loc5_.x + _loc5_.y * _loc5_.y > _loc4_.collisionRadius * _loc4_.collisionRadius)
				{
					return false;
				}
			}
			_picked = true;
			if (param1.isMe)
			{
				_loc6_ = SoundLocator.getService();
				_loc6_.play("05TMoG1kxEiXVZJ_OPhD_A");
				param1.checkPickupMessage(param2, param3);
			}
			expire();
			return true;
		}
		
		override public function update():void
		{
			tractorBeamUpdate();
			pos.x += speed.x;
			pos.y += speed.y;
			speed.x *= 0.9;
			speed.y *= 0.9;
			if (isAddedToCanvas && !fadeTween && expireTime - g.time < 10000 && expireTime != 0)
			{
				fadeTween = TweenMax.fromTo(this, 0.4, {"alpha": 1}, {"alpha": 0.4, "yoyo": true, "repeat": -1});
			}
			if (g.time > expireTime && expireTime != 0)
			{
				expire();
			}
			rotation += randAngleSpeed;
			if (nextDistanceCalculation <= 0)
			{
				updateIsNear();
			}
			else
			{
				nextDistanceCalculation -= 33;
			}
		}
		
		public function updateIsNear():void
		{
			if (g.me.ship == null)
			{
				return;
			}
			var _loc4_:Point = this.pos;
			var _loc3_:Point = g.camera.getCameraCenter();
			distanceToCameraX = _loc4_.x - _loc3_.x;
			distanceToCameraY = _loc4_.y - _loc3_.y;
			var _loc2_:Number = g.stage.stageWidth;
			distanceToCamera = Math.sqrt(distanceToCameraX * distanceToCameraX + distanceToCameraY * distanceToCameraY);
			var _loc1_:Number = distanceToCamera - _loc2_;
			nextDistanceCalculation = _loc1_ / 300 * 1000;
			if (distanceToCamera < _loc2_)
			{
				if (isAddedToCanvas)
				{
					return;
				}
				addToCanvasForReal();
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
		
		public function addToCanvasForReal():void
		{
			if (!effect && !expired)
			{
				effect = EmitterFactory.create(obj.effect, g, pos.x, pos.y, this, true);
				if (key == "ZhiKr_lV5ka9I-Fio7APMg")
				{
					effect[0].play();
				}
			}
			g.hud.radar.add(this);
			addToCanvas();
		}
		
		public function tractorBeamUpdate():void
		{
			if (!isAddedToCanvas || tractorBeamPlayer == null || tractorBeamPlayer.ship == null || tractorBeamPlayer.ship.course == null)
			{
				beamLine.visible = false;
				return;
			}
			beamLine.visible = true;
			var _loc5_:PlayerShip = tractorBeamPlayer.ship;
			var _loc8_:Number = _loc5_.course.pos.x - pos.x;
			var _loc9_:Number = _loc5_.course.pos.y - pos.y;
			var _loc3_:Number = Math.sqrt(_loc8_ * _loc8_ + _loc9_ * _loc9_);
			var _loc2_:Number = _loc8_ / _loc3_;
			var _loc4_:Number = _loc9_ / _loc3_;
			var _loc1_:Number = 33;
			var _loc6_:Number = _loc5_.speed.length * _loc1_ / 1000;
			var _loc7_:Number = _loc6_ + 5;
			speed.x = _loc2_ * _loc7_;
			speed.y = _loc4_ * _loc7_;
		}
		
		public function expire():void
		{
			if (effect)
			{
				for each (var _loc1_:* in effect)
				{
					_loc1_.killEmitter();
				}
			}
			if (fadeTween != null)
			{
				fadeTween.kill();
			}
			_picked = false;
			expired = true;
		}
		
		override public function reset():void
		{
			collisionRadius = 0;
			speed.x = 0;
			speed.y = 0;
			g.emitterManager.clean(this);
			effect = null;
			name = "";
			key = "";
			obj = null;
			id = 0;
			_picked = false;
			expired = false;
			expireTime = 0;
			if (fadeTween != null)
			{
				fadeTween.kill();
			}
			fadeTween = null;
			tractorBeamPlayer = null;
			beamLine.clear();
			g.beamLinePool.removeLine(beamLine);
			super.reset();
		}
		
		override public function draw():void
		{
			drawBeamEffect();
			super.draw();
		}
		
		private function drawBeamEffect():void
		{
			if (!isAddedToCanvas || tractorBeamPlayer == null || tractorBeamPlayer.ship == null || beamLine == null)
			{
				return;
			}
			if (tractorBeamPlayer.isTractorBeamActive())
			{
				beamLine.color = 12551935;
				beamLine.nodeFrequence = 6;
				beamLine.amplitude = 4;
			}
			else
			{
				beamLine.color = 16777215;
				beamLine.nodeFrequence = 3;
				beamLine.amplitude = 3;
			}
			var _loc1_:Point = tractorBeamPlayer.ship.pos;
			if (Math.abs(_loc1_.x - this.pos.x) > 200)
			{
				return;
			}
			if (Math.abs(_loc1_.y - this.pos.y) > 200)
			{
				return;
			}
			beamLine.x = this.pos.x;
			beamLine.y = this.pos.y;
			beamLine.lineTo(_loc1_.x, _loc1_.y);
		}
		
		override public function addToCanvas():void
		{
			canvas.addChild(beamLine);
			super.addToCanvas();
		}
		
		override public function removeFromCanvas():void
		{
			var _loc1_:int = 0;
			if (effect)
			{
				_loc1_ = 0;
				while (_loc1_ < effect.length)
				{
					effect[_loc1_].alive = false;
					_loc1_++;
				}
				effect = null;
			}
			canvas.removeChild(beamLine);
			g.hud.radar.remove(this);
			super.removeFromCanvas();
		}
	}
}
