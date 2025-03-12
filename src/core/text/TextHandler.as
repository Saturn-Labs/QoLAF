package core.text
{
	import core.scene.Game;
	import flash.geom.Point;
	
	public class TextHandler
	{
		public var texts:Vector.<TextParticle>;
		
		private var inactiveTexts:Vector.<TextParticle>;
		
		private var g:Game;
		
		public function TextHandler(param1:Game)
		{
			super();
			this.inactiveTexts = param1.textManager.inactiveTexts;
			this.g = param1;
			texts = new Vector.<TextParticle>();
		}
		
		public function update():void
		{
			var _loc4_:int = 0;
			var _loc1_:TextParticle = null;
			var _loc2_:Number = NaN;
			var _loc3_:int = int(texts.length);
			_loc4_ = _loc3_ - 1;
			while (_loc4_ > -1)
			{
				_loc1_ = texts[_loc4_];
				if (!_loc1_.alive)
				{
					remove(_loc1_, _loc4_);
				}
				else
				{
					_loc1_.update();
					_loc1_.x += _loc1_.speed.x * 33 / 1000;
					_loc1_.y += _loc1_.speed.y * 33 / 1000;
					_loc2_ = _loc1_.ttl / _loc1_.maxTtl;
					if (_loc2_ <= 0.5)
					{
						_loc1_.alpha = _loc2_;
					}
				}
				_loc4_--;
			}
		}
		
		public function add(param1:String, param2:Point, param3:Point, param4:Number = 400, param5:uint = 16777215, param6:Number = 20, param7:Boolean = false, param8:String = "center", param9:String = "normal"):TextParticle
		{
			var _loc11_:TextParticle = null;
			if (inactiveTexts.length > 0)
			{
				_loc11_ = inactiveTexts.pop();
			}
			else
			{
				_loc11_ = texts.shift();
				_loc11_.reset();
			}
			_loc11_.scaleX = _loc11_.scaleY = 1;
			_loc11_.ttl = param4;
			_loc11_.maxTtl = param4;
			var _loc10_:String = "font13";
			if (param6 > 18)
			{
				_loc10_ = "font26";
			}
			_loc11_.width = 800;
			_loc11_.height = 100;
			_loc11_.format.font = _loc10_;
			_loc11_.format.size = param6;
			_loc11_.format.color = param5;
			_loc11_.text = param1;
			_loc11_.height = _loc11_.textBounds.height + 42;
			_loc11_.width = _loc11_.textBounds.width + 45;
			_loc11_.touchable = false;
			_loc11_.blendMode = "normal";
			if (param8 == "center")
			{
				_loc11_.pivotX = _loc11_.width / 2;
			}
			else if (param8 == "right")
			{
				_loc11_.pivotX = _loc11_.width;
			}
			_loc11_.x = param2.x;
			_loc11_.y = param2.y;
			_loc11_.speed = param3;
			_loc11_.fixed = param7;
			_loc11_.alive = true;
			texts.push(_loc11_);
			if (param7)
			{
				g.addChild(_loc11_);
			}
			else
			{
				g.canvasTexts.addChild(_loc11_);
			}
			return _loc11_;
		}
		
		public function remove(param1:TextParticle, param2:int):void
		{
			param1.reset();
			texts.splice(param2, 1);
			inactiveTexts.push(param1);
			if (param1.fixed)
			{
				g.removeChild(param1);
			}
			else
			{
				g.canvasTexts.removeChild(param1);
			}
		}
		
		public function dispose():void
		{
			for each (var _loc1_:* in texts)
			{
				if (_loc1_.fixed)
				{
					g.removeChild(_loc1_);
				}
				else
				{
					g.canvasTexts.removeChild(_loc1_);
				}
				_loc1_.dispose();
			}
			texts = null;
			inactiveTexts = null;
		}
	}
}
