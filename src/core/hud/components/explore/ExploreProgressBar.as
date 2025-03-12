package core.hud.components.explore
{
	import core.GameObject;
	import core.hud.components.Text;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.solarSystem.Body;
	import debug.Console;
	import flash.utils.Timer;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class ExploreProgressBar extends Sprite
	{
		public static var COLOR:uint = 3225899;
		private var min:Number = 0;
		private var max:Number = 1;
		private var value:Number = 0;
		private var _exploring:Boolean = false;
		private var exploreEffect:Vector.<Emitter>;
		
		private var effectForeground:Quad;
		
		private var effectBackground:Quad;
		
		private var effectContainer:Quad;
		
		private var effectTarget:GameObject;
		
		private var effectCanvas:Sprite;
		
		private var finished:Boolean = false;
		private var exploreText:Text;
		
		private var body:Body;
		
		private var g:Game;
		
		private var finishedCallback:Function;
		
		private var setValueOnFinishedLoad:Boolean = false;
		private var onFinishedLoadValue:Number;
		
		private var onFinishedLoadFailed:Boolean;
		
		private var startOnFinish:Boolean = false;
		private var timer:Timer;
		
		private var startTime:Number = 0;
		private var finishTime:Number = 0;
		private var failTime:Number = 0;
		private var barWidth:Number = 452;
		private var type:int;
		
		private var loadFinished:Boolean = false;
		public function ExploreProgressBar(param1:Game, param2:Body, param3:Function, param4:int)
		{
			timer = new Timer(1000, 1);
			this.g = param1;
			this.body = param2;
			this.type = param4;
			this.finishedCallback = param3;
			var _loc6_:uint = Area.COLORTYPE[param4];
			super();
			effectTarget = new GameObject();
			effectCanvas = new Sprite();
			exploreEffect = EmitterFactory.create("9iZrZ9p5nEWqrPhkxTYNgA", param1, 0, 0, effectTarget, true, true, true, effectCanvas);
			for each (var _loc5_:* in exploreEffect)
			{
				_loc5_.followEmitter = true;
				_loc5_.followTarget = true;
				_loc5_.speed = 2;
				_loc5_.maxParticles = 20;
				_loc5_.ttl = 1400;
				_loc5_.startColor = _loc6_;
				_loc5_.startSize = 2;
				_loc5_.finishSize = 0;
			}
			effectBackground = new Quad(barWidth, 17, 0);
			addChild(effectBackground);
			effectForeground = new Quad(1, 17, _loc6_);
			exploreText = new Text(width / 2, 0, true);
			exploreText.wordWrap = false;
			exploreText.size = 10;
			exploreText.alignCenter();
			exploreText.y = 1;
			if (param4 == 0)
			{
				exploreText.color = 1118481;
			}
			else
			{
				exploreText.color = 5592405;
			}
			if (finished)
			{
				exploreText.text = "EXPLORE FINISHED!";
			}
			else
			{
				exploreText.text = "NOT EXPLORED";
			}
			addChild(exploreText);
			loadFinished = true;
			if (setValueOnFinishedLoad)
			{
				start(0, 0, 0);
				setValueAndEffect(onFinishedLoadValue, onFinishedLoadFailed);
			}
			if (startOnFinish)
			{
				start(startTime, finishTime, failTime);
			}
		}
		
		public function setMax():void
		{
			finished = true;
		}
		
		public function start(param1:Number, param2:Number, param3:Number):void
		{
			Console.write("start");
			startTime = param1;
			finishTime = param2;
			failTime = param3;
			if (type == 0)
			{
				exploreText.color = 1118481;
			}
			else
			{
				exploreText.color = 5592405;
			}
			if (!loadFinished)
			{
				startOnFinish = true;
				return;
			}
			finished = false;
			startTime = param1;
			finishTime = param2;
			failTime = param3;
			if (!contains(effectForeground))
			{
				addChildAt(effectForeground, 1);
			}
			addChild(effectCanvas);
			exploring = true;
		}
		
		public function stop():void
		{
			finished = true;
			stopEffect();
		}
		
		public function update():void
		{
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc1_:Number = NaN;
			if (_exploring && !finished)
			{
				if (failTime < g.time)
				{
					_loc2_ = failTime - startTime;
				}
				else
				{
					_loc2_ = g.time - startTime;
				}
				_loc3_ = finishTime - startTime;
				_loc1_ = _loc2_ / _loc3_;
				setValue(_loc1_, failTime < g.time);
			}
		}
		
		public function stopEffect():void
		{
			for each (var _loc1_:* in exploreEffect)
			{
				_loc1_.killEmitter();
			}
		}
		
		public function set exploring(param1:Boolean):void
		{
			this._exploring = param1;
		}
		
		public function setValueAndEffect(param1:Number, param2:Boolean = false):void
		{
			var _loc3_:int = 0;
			if (!loadFinished)
			{
				setValueOnFinishedLoad = true;
				onFinishedLoadValue = param1;
				onFinishedLoadFailed = param2;
				return;
			}
			if (!contains(effectForeground))
			{
				addChildAt(effectForeground, 1);
			}
			if (param1 > max)
			{
				param1 = max;
			}
			value = param1;
			finished = true;
			if (param2)
			{
				_loc3_ = barWidth * (value / max);
				effectForeground.width = _loc3_;
				effectTarget.x = _loc3_ - 1;
				effectTarget.y = 10;
				exploreText.text = "FAILED AT: " + Math.floor(value * 100) + "%";
				if (type == 2)
				{
					exploreText.color = 16777215;
				}
				else
				{
					exploreText.color = 11141120;
				}
				exploreText.glow = false;
				return;
			}
			_loc3_ = barWidth * (value / max);
			effectForeground.width = _loc3_;
			effectTarget.x = _loc3_ - 1;
			effectTarget.y = 10;
			exploreText.text = "EXPLORED: " + Math.floor(value * 100) + "%";
			if (type == 0 && value > 0.5)
			{
				exploreText.color = 0;
			}
			else
			{
				exploreText.color = 16777215;
			}
		}
		
		private function setValue(param1:Number, param2:Boolean = false):void
		{
			var _loc5_:int = 0;
			var _loc3_:Number = NaN;
			var _loc4_:Number = NaN;
			if (!loadFinished)
			{
				return;
			}
			if (param1 > max)
			{
				param1 = max;
			}
			value = param1;
			_loc5_ = barWidth * (value / max);
			effectTarget.x = _loc5_ - 1;
			effectTarget.y = 10;
			effectForeground.width = _loc5_;
			exploreText.text = "EXPLORED: " + Math.floor(value * 100) + "%";
			if (type == 0 && value > 0.5)
			{
				exploreText.color = 0;
			}
			else
			{
				exploreText.color = 16777215;
			}
			if (value >= max && !finished)
			{
				Console.write("finished explore");
				finished = true;
				if (type == 0 && value > 0.5)
				{
					exploreText.color = 0;
				}
				else
				{
					exploreText.color = 16777215;
				}
				finishedCallback();
			}
			else if (param2 && !finished)
			{
				Console.write("failed explore");
				_loc3_ = failTime - startTime;
				_loc4_ = finishTime - startTime;
				value = _loc3_ / _loc4_;
				_loc5_ = barWidth * (value / max);
				effectTarget.x = _loc5_ - 1;
				effectTarget.y = 10;
				effectForeground.width = _loc5_;
				exploreText.text = "FAILED AT: " + Math.floor(value * 100) + "%";
				if (type == 2)
				{
					exploreText.color = 16777215;
				}
				else
				{
					exploreText.color = 11141120;
				}
				exploreText.glow = false;
				_exploring = false;
				finished = true;
				finishedCallback();
				return;
			}
		}
	}
}
