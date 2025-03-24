package core.text {
	import core.scene.Game;
	import flash.geom.Point;
	
	public class TextHandler {
		public var texts:Vector.<TextParticle>;
		
		private var inactiveTexts:Vector.<TextParticle>;
		
		private var g:Game;
		
		public function TextHandler(g:Game) {
			super();
			this.inactiveTexts = g.textManager.inactiveTexts;
			this.g = g;
			texts = new Vector.<TextParticle>();
		}
		
		public function update() : void {
			var _local2:int = 0;
			var _local1:TextParticle = null;
			var _local4:Number = NaN;
			var _local3:int = int(texts.length);
			_local2 = _local3 - 1;
			while(_local2 > -1) {
				_local1 = texts[_local2];
				if(!_local1.alive) {
					remove(_local1,_local2);
				} else {
					_local1.update();
					_local1.x += _local1.speed.x * 33 / 1000;
					_local1.y += _local1.speed.y * 33 / 1000;
					_local4 = _local1.ttl / _local1.maxTtl;
					if(_local4 <= 0.5) {
						_local1.alpha = _local4;
					}
				}
				_local2--;
			}
		}
		
		public function add(text:String, pos:Point, speed:Point, ttl:Number = 400, color:uint = 16777215, size:Number = 20, fixed:Boolean = false, align:String = "center", blendMode:String = "normal") : TextParticle {
			var _local11:TextParticle = null;
			if(inactiveTexts.length > 0) {
				_local11 = inactiveTexts.pop();
			} else {
				_local11 = texts.shift();
				_local11.reset();
			}
			_local11.scaleX = _local11.scaleY = 1;
			_local11.ttl = ttl;
			_local11.maxTtl = ttl;
			var _local10:String = "font13";
			if(size > 18) {
				_local10 = "font26";
			}
			_local11.width = 800;
			_local11.height = 100;
			_local11.format.font = _local10;
			_local11.format.size = size;
			_local11.format.color = color;
			_local11.text = text;
			_local11.height = _local11.textBounds.height + 42;
			_local11.width = _local11.textBounds.width + 45;
			_local11.touchable = false;
			_local11.blendMode = "normal";
			if(align == "center") {
				_local11.pivotX = _local11.width / 2;
			} else if(align == "right") {
				_local11.pivotX = _local11.width;
			}
			_local11.x = pos.x;
			_local11.y = pos.y;
			_local11.speed = speed;
			_local11.fixed = fixed;
			_local11.alive = true;
			texts.push(_local11);
			if(fixed) {
				g.addChild(_local11);
			} else {
				g.canvasTexts.addChild(_local11);
			}
			return _local11;
		}
		
		public function remove(t:TextParticle, index:int) : void {
			t.reset();
			texts.splice(index,1);
			inactiveTexts.push(t);
			if(t.fixed) {
				g.removeChild(t);
			} else {
				g.canvasTexts.removeChild(t);
			}
		}
		
		public function dispose() : void {
			for each(var _local1 in texts) {
				if(_local1.fixed) {
					g.removeChild(_local1);
				} else {
					g.canvasTexts.removeChild(_local1);
				}
				_local1.dispose();
			}
			texts = null;
			inactiveTexts = null;
		}
	}
}

