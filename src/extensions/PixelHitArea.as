package extensions
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.sampler.getSize;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import starling.utils.Color;

	public class PixelHitArea
	{
		private static var hitAreas:Dictionary;
		private static var id:int = 0;
		public var width:Number;
		public var height:Number;
		public var name:String;
		public var scaleBitmapData:Number;
		private var sampleWidth:uint;
		private var sampleHeight:uint;
		private var alphaData:Vector.<uint>;

		private var tempData:Vector.<uint>;

		private var createTime:int;
		private var _disposed:Boolean;
		public function PixelHitArea(param1:Bitmap, param2:Number = 1, param3:String = "")
		{
			var _loc7_:* = 0;
			super();
			var _loc4_:int = getTimer();
			if (param3 == "")
			{
				param3 = "_hit#" + id;
				id++;
			}
			PixelHitArea.registerHitArea(this, param3);
			this.width = param1.width;
			this.height = param1.height;
			this.scaleBitmapData = param2;
			if (param2 > 1 || param2 < 0.1)
			{
				throw new Error("Incorrect bitmap sampling, correct range is 0.1 - 1");
			}
			var _loc5_:BitmapData = new BitmapData(Math.ceil(param1.width * param2), Math.ceil(param1.height * param2), true, 0);
			_loc5_ = param1.bitmapData.clone();
			param2 < 1 ? _loc5_.draw(param1.bitmapData, new Matrix(param2, 0, 0, param2, 0, 0)) : (_loc5_);
			this.sampleWidth = _loc5_.width;
			this.sampleHeight = _loc5_.height;
			tempData = _loc5_.getVector(_loc5_.rect);
			alphaData = new Vector.<uint>(Math.ceil(sampleWidth * sampleHeight / 4), true);
			var _loc6_:uint = 0;
			_loc7_ = 0;
			while (_loc7_ < alphaData.length)
			{
				alphaData[_loc7_] = getAlpha(_loc6_) << 24 | getAlpha(_loc6_ + 1) << 16 | getAlpha(_loc6_ + 2) << 8 | getAlpha(_loc6_ + 3);
				_loc6_ += 4;
				_loc7_++;
			}
			tempData = null;
			_loc5_.dispose();
			_loc5_ = null;
			createTime = getTimer() - _loc4_;
		}

		private static function registerHitArea(param1:PixelHitArea, param2:String):void
		{
			if (hitAreas == null)
			{
				hitAreas = new Dictionary();
			}
			if (hitAreas[param2] != null)
			{
				throw new Error("PixelTouch: hitArea name duplicate");
			}
			hitAreas[param2] = param1;
		}

		public static function disposeHitArea(param1:PixelHitArea):void
		{
			for (var _loc2_:* in hitAreas)
			{
				if (hitAreas[_loc2_] == param1)
				{
					param1.dispose();
					hitAreas[_loc2_] = null;
				}
			}
		}

		public static function dispose():void
		{
			var _loc2_:PixelHitArea = null;
			for (var _loc1_:* in hitAreas)
			{
				_loc2_ = hitAreas[_loc1_];
				if (_loc2_)
				{
					_loc2_.dispose();
					hitAreas[_loc1_] = null;
				}
			}
			hitAreas = null;
			id = 0;
		}

		public static function getHitArea(param1:String):PixelHitArea
		{
			if (hitAreas[param1])
			{
				return hitAreas[param1];
			}
			throw new Error("HitArea " + param1 + " not found");
		}

		public static function getDebugInfo():String
		{
			var _loc5_:PixelHitArea = null;
			var _loc4_:Number = NaN;
			var _loc2_:String = "HitArea memory size:\r";
			var _loc1_:Number = 0;
			var _loc6_:Number = 0;
			for (var _loc3_:* in hitAreas)
			{
				_loc5_ = hitAreas[_loc3_];
				if (_loc5_)
				{
					_loc4_ = _loc5_.getMemorySize() / 1024 / 1024;
					_loc1_ += _loc4_;
					_loc6_ += _loc5_.getCreatTime();
					_loc2_ += _loc3_ + ":\t" + _loc4_.toFixed(2) + " mb \t";
					_loc2_ += "create time:\t" + _loc5_.createTime + " ms\r";
				}
			}
			_loc2_ += "-----------------------\r";
			return _loc2_ + ("total:\t\t" + _loc1_.toFixed(2) + " mb \t\t\t" + _loc6_ + " ms");
		}

		private function getAlpha(param1:uint):uint
		{
			return param1 < tempData.length ? Color.getAlpha(tempData[param1]) : 0;
		}

		public function getAlphaPixel(param1:uint, param2:uint):uint
		{
			var _loc3_:Number = (Math.floor(param2 * scaleBitmapData) * sampleWidth + Math.floor(param1 * scaleBitmapData)) / 4;
			var _loc4_:Number = _loc3_ % Math.floor(_loc3_);
			var _loc5_:uint = alphaData[Math.floor(_loc3_)];
			if (_loc4_ == 0)
			{
				return Color.getAlpha(_loc5_);
			}
			if (_loc4_ == 0.25)
			{
				return Color.getRed(_loc5_);
			}
			if (_loc4_ == 0.5)
			{
				return Color.getGreen(_loc5_);
			}
			if (_loc4_ == 0.75)
			{
				return Color.getBlue(_loc5_);
			}
			return 0;
		}

		public function dispose():void
		{
			alphaData = null;
			disposed = true;
		}

		public function getMemorySize():Number
		{
			return !!alphaData ? getSize(alphaData) : 0;
		}

		public function getCreatTime():Number
		{
			return createTime;
		}

		public function get disposed():Boolean
		{
			return _disposed;
		}

		public function set disposed(param1:Boolean):void
		{
			_disposed = param1;
		}
	}
}
