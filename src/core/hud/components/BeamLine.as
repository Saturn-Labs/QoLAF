package core.hud.components
{
	import core.scene.Game;
	import starling.display.MeshBatch;
	
	public class BeamLine extends MeshBatch
	{
		private var period:int = 100;
		
		public var nodeFrequence:int;
		
		public var thickness:Number;
		
		public var amplitude:Number;
		
		private var ampFactor:Number;
		
		private var glowWidth:Number;
		
		private var glowColor:Number;
		
		private var _color:uint;
		
		private var lineTexture:String;
		
		private var lines:Vector.<Line>;
		
		private var g:Game;
		
		public function BeamLine(param1:Game)
		{
			lines = new Vector.<Line>();
			super();
			this.g = param1;
		}
		
		public function init(param1:Number = 3, param2:int = 3, param3:Number = 2, param4:uint = 16777215, param5:Number = 1, param6:Number = 3, param7:uint = 16711680, param8:String = "line2"):void
		{
			this.thickness = param1 * 2;
			this.nodeFrequence = param2;
			this.amplitude = param3;
			this.ampFactor = ampFactor;
			this.alpha = param5;
			this.glowWidth = param6;
			this.glowColor = param7;
			this.lineTexture = param8;
			this.blendMode = "add";
			_color = param4;
			this.touchable = true;
		}
		
		public function lineTo(param1:Number, param2:Number, param3:Number = 1):void
		{
			var _loc14_:int = 0;
			var _loc9_:Line = null;
			var _loc8_:int = 0;
			var _loc6_:Line = null;
			var _loc16_:Number = NaN;
			var _loc15_:Number = NaN;
			var _loc5_:Number = param1 - x;
			var _loc13_:Number = param2 - y;
			var _loc4_:Number = _loc5_ * _loc5_ + _loc13_ * _loc13_;
			var _loc10_:Number = Math.sqrt(_loc4_);
			var _loc7_:Number = Math.round(_loc10_ / period * nodeFrequence);
			if (_loc7_ == 0)
			{
				_loc7_ = 1;
			}
			if (_loc7_ > lines.length)
			{
				_loc8_ = _loc7_ - lines.length;
				_loc14_ = 0;
				while (_loc14_ < _loc8_)
				{
					_loc9_ = g.linePool.getLine();
					_loc9_.init(lineTexture, thickness, color, 1, true);
					_loc9_.blendMode = "add";
					lines.push(_loc9_);
					_loc14_++;
				}
			}
			else if (_loc7_ < lines.length)
			{
				_loc14_ = _loc7_;
				while (_loc14_ < lines.length)
				{
					g.linePool.removeLine(lines[_loc14_]);
					_loc14_++;
				}
				lines.length = _loc7_;
			}
			super.clear();
			var _loc12_:* = 0;
			var _loc11_:* = 0;
			_loc14_ = 0;
			while (_loc14_ < lines.length)
			{
				_loc6_ = lines[_loc14_];
				_loc16_ = 2 - Math.abs((_loc7_ / 2 - _loc14_) / _loc7_) * 2;
				_loc6_.x = _loc12_;
				_loc6_.y = _loc11_;
				_loc15_ = (_loc14_ + 1) / _loc7_;
				_loc12_ = _loc5_ * _loc15_ + (amplitude - Math.random() * amplitude * 2) * _loc16_;
				_loc11_ = _loc13_ * _loc15_ + (amplitude - Math.random() * amplitude * 2) * _loc16_;
				if (_loc14_ == _loc7_ - 1)
				{
					_loc12_ = _loc5_;
					_loc11_ = _loc13_;
				}
				_loc6_.lineTo(_loc12_, _loc11_);
				_loc6_.thickness = thickness + param3;
				this.addMesh(_loc6_);
				_loc14_++;
			}
		}
		
		override public function set touchable(param1:Boolean):void
		{
			var _loc3_:int = 0;
			var _loc2_:Line = null;
			_loc3_ = 0;
			while (_loc3_ < lines.length)
			{
				_loc2_ = lines[0];
				_loc2_.touchable = param1;
				_loc3_++;
			}
			super.touchable = param1;
		}
		
		override public function clear():void
		{
			var _loc1_:int = 0;
			super.clear();
			_loc1_ = 0;
			while (_loc1_ < lines.length)
			{
				g.linePool.removeLine(lines[_loc1_]);
				_loc1_++;
			}
			lines.length = 0;
		}
		
		override public function set color(param1:uint):void
		{
			var _loc3_:int = 0;
			var _loc2_:Line = null;
			_loc3_ = 0;
			while (_loc3_ < lines.length)
			{
				_loc2_ = lines[_loc3_];
				_loc2_.color = param1;
				_loc3_++;
			}
			_color = param1;
		}
		
		override public function get color():uint
		{
			return _color;
		}
	}
}
