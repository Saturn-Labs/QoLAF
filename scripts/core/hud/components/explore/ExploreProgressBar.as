package core.hud.components.explore {
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
	
	public class ExploreProgressBar extends Sprite {
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
		
		private var timer:Timer = new Timer(1000,1);
		
		private var startTime:Number = 0;
		
		private var finishTime:Number = 0;
		
		private var failTime:Number = 0;
		
		private var barWidth:Number = 452;
		
		private var type:int;
		
		private var loadFinished:Boolean = false;
		
		public function ExploreProgressBar(g:Game, body:Body, finishedCallback:Function, type:int) {
			this.g = g;
			this.body = body;
			this.type = type;
			this.finishedCallback = finishedCallback;
			var _local5:uint = Area.COLORTYPE[type];
			super();
			effectTarget = new GameObject();
			effectCanvas = new Sprite();
			exploreEffect = EmitterFactory.create("9iZrZ9p5nEWqrPhkxTYNgA",g,0,0,effectTarget,true,true,true,effectCanvas);
			for each(var _local6 in exploreEffect) {
				_local6.followEmitter = true;
				_local6.followTarget = true;
				_local6.speed = 2;
				_local6.maxParticles = 20;
				_local6.ttl = 1400;
				_local6.startColor = _local5;
				_local6.startSize = 2;
				_local6.finishSize = 0;
			}
			effectBackground = new Quad(barWidth,17,0);
			addChild(effectBackground);
			effectForeground = new Quad(1,17,_local5);
			exploreText = new Text(width / 2,0,true);
			exploreText.wordWrap = false;
			exploreText.size = 10;
			exploreText.alignCenter();
			exploreText.y = 1;
			if(type == 0) {
				exploreText.color = 0x111111;
			} else {
				exploreText.color = 0x555555;
			}
			if(finished) {
				exploreText.text = "EXPLORE FINISHED!";
			} else {
				exploreText.text = "NOT EXPLORED";
			}
			addChild(exploreText);
			loadFinished = true;
			if(setValueOnFinishedLoad) {
				start(0,0,0);
				setValueAndEffect(onFinishedLoadValue,onFinishedLoadFailed);
			}
			if(startOnFinish) {
				start(startTime,finishTime,failTime);
			}
		}
		
		public function setMax() : void {
			finished = true;
		}
		
		public function start(start:Number, finish:Number, fail:Number) : void {
			Console.write("start");
			startTime = start;
			finishTime = finish;
			failTime = fail;
			if(type == 0) {
				exploreText.color = 0x111111;
			} else {
				exploreText.color = 0x555555;
			}
			if(!loadFinished) {
				startOnFinish = true;
				return;
			}
			finished = false;
			startTime = start;
			finishTime = finish;
			failTime = fail;
			if(!contains(effectForeground)) {
				addChildAt(effectForeground,1);
			}
			addChild(effectCanvas);
			exploring = true;
		}
		
		public function stop() : void {
			finished = true;
			stopEffect();
		}
		
		public function update() : void {
			var _local3:Number = NaN;
			var _local1:Number = NaN;
			var _local2:Number = NaN;
			if(_exploring && !finished) {
				if(failTime < g.time) {
					_local3 = failTime - startTime;
				} else {
					_local3 = g.time - startTime;
				}
				_local1 = finishTime - startTime;
				_local2 = _local3 / _local1;
				setValue(_local2,failTime < g.time);
			}
		}
		
		public function stopEffect() : void {
			for each(var _local1 in exploreEffect) {
				_local1.killEmitter();
			}
		}
		
		public function set exploring(value:Boolean) : void {
			this._exploring = value;
		}
		
		public function setValueAndEffect(v:Number, failed:Boolean = false) : void {
			var _local3:int = 0;
			if(!loadFinished) {
				setValueOnFinishedLoad = true;
				onFinishedLoadValue = v;
				onFinishedLoadFailed = failed;
				return;
			}
			if(!contains(effectForeground)) {
				addChildAt(effectForeground,1);
			}
			if(v > max) {
				v = max;
			}
			value = v;
			finished = true;
			if(failed) {
				_local3 = barWidth * (value / max);
				effectForeground.width = _local3;
				effectTarget.x = _local3 - 1;
				effectTarget.y = 10;
				exploreText.text = "FAILED AT: " + Math.floor(value * 100) + "%";
				if(type == 2) {
					exploreText.color = 0xffffff;
				} else {
					exploreText.color = 0xaa0000;
				}
				exploreText.glow = false;
				return;
			}
			_local3 = barWidth * (value / max);
			effectForeground.width = _local3;
			effectTarget.x = _local3 - 1;
			effectTarget.y = 10;
			exploreText.text = "EXPLORED: " + Math.floor(value * 100) + "%";
			if(type == 0 && value > 0.5) {
				exploreText.color = 0;
			} else {
				exploreText.color = 0xffffff;
			}
		}
		
		private function setValue(v:Number, failed:Boolean = false) : void {
			var _local4:int = 0;
			var _local5:Number = NaN;
			var _local3:Number = NaN;
			if(!loadFinished) {
				return;
			}
			if(v > max) {
				v = max;
			}
			value = v;
			_local4 = barWidth * (value / max);
			effectTarget.x = _local4 - 1;
			effectTarget.y = 10;
			effectForeground.width = _local4;
			exploreText.text = "EXPLORED: " + Math.floor(value * 100) + "%";
			if(type == 0 && value > 0.5) {
				exploreText.color = 0;
			} else {
				exploreText.color = 0xffffff;
			}
			if(value >= max && !finished) {
				Console.write("finished explore");
				finished = true;
				if(type == 0 && value > 0.5) {
					exploreText.color = 0;
				} else {
					exploreText.color = 0xffffff;
				}
				finishedCallback();
			} else if(failed && !finished) {
				Console.write("failed explore");
				_local5 = failTime - startTime;
				_local3 = finishTime - startTime;
				value = _local5 / _local3;
				_local4 = barWidth * (value / max);
				effectTarget.x = _local4 - 1;
				effectTarget.y = 10;
				effectForeground.width = _local4;
				exploreText.text = "FAILED AT: " + Math.floor(value * 100) + "%";
				if(type == 2) {
					exploreText.color = 0xffffff;
				} else {
					exploreText.color = 0xaa0000;
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

