package extensions {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.sampler.getSize;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import starling.utils.Color;
	
	public class PixelHitArea {
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
		
		public function PixelHitArea(bitmap:Bitmap, bitmapSampling:Number = 1, name:String = "") {
			var _local4:* = 0;
			super();
			var _local6:int = getTimer();
			if(name == "") {
				name = "_hit#" + id;
				id++;
			}
			PixelHitArea.registerHitArea(this,name);
			this.width = bitmap.width;
			this.height = bitmap.height;
			this.scaleBitmapData = bitmapSampling;
			if(bitmapSampling > 1 || bitmapSampling < 0.1) {
				throw new Error("Incorrect bitmap sampling, correct range is 0.1 - 1");
			}
			var _local7:BitmapData = new BitmapData(Math.ceil(bitmap.width * bitmapSampling),Math.ceil(bitmap.height * bitmapSampling),true,0);
			_local7 = bitmap.bitmapData.clone();
			bitmapSampling < 1 ? _local7.draw(bitmap.bitmapData,new Matrix(bitmapSampling,0,0,bitmapSampling,0,0)) : (_local7);
			this.sampleWidth = _local7.width;
			this.sampleHeight = _local7.height;
			tempData = _local7.getVector(_local7.rect);
			alphaData = new Vector.<uint>(Math.ceil(sampleWidth * sampleHeight / 4),true);
			var _local5:uint = 0;
			_local4 = 0;
			while(_local4 < alphaData.length) {
				alphaData[_local4] = getAlpha(_local5) << 24 | getAlpha(_local5 + 1) << 16 | getAlpha(_local5 + 2) << 8 | getAlpha(_local5 + 3);
				_local5 += 4;
				_local4++;
			}
			tempData = null;
			_local7.dispose();
			_local7 = null;
			createTime = getTimer() - _local6;
		}
		
		private static function registerHitArea(hitArea:PixelHitArea, name:String) : void {
			if(hitAreas == null) {
				hitAreas = new Dictionary();
			}
			if(hitAreas[name] != null) {
				throw new Error("PixelTouch: hitArea name duplicate");
			}
			hitAreas[name] = hitArea;
		}
		
		public static function disposeHitArea(hitArea:PixelHitArea) : void {
			for(var _local2 in hitAreas) {
				if(hitAreas[_local2] == hitArea) {
					hitArea.dispose();
					hitAreas[_local2] = null;
				}
			}
		}
		
		public static function dispose() : void {
			var _local2:PixelHitArea = null;
			for(var _local1 in hitAreas) {
				_local2 = hitAreas[_local1];
				if(_local2) {
					_local2.dispose();
					hitAreas[_local1] = null;
				}
			}
			hitAreas = null;
			id = 0;
		}
		
		public static function getHitArea(name:String) : PixelHitArea {
			if(hitAreas[name]) {
				return hitAreas[name];
			}
			throw new Error("HitArea " + name + " not found");
		}
		
		public static function getDebugInfo() : String {
			var _local6:PixelHitArea = null;
			var _local3:Number = NaN;
			var _local2:String = "HitArea memory size:\r";
			var _local4:Number = 0;
			var _local5:Number = 0;
			for(var _local1 in hitAreas) {
				_local6 = hitAreas[_local1];
				if(_local6) {
					_local3 = _local6.getMemorySize() / 1024 / 1024;
					_local4 += _local3;
					_local5 += _local6.getCreatTime();
					_local2 += _local1 + ":\t" + _local3.toFixed(2) + " mb \t";
					_local2 += "create time:\t" + _local6.createTime + " ms\r";
				}
			}
			_local2 += "-----------------------\r";
			return _local2 + ("total:\t\t" + _local4.toFixed(2) + " mb \t\t\t" + _local5 + " ms");
		}
		
		private function getAlpha(index:uint) : uint {
			return index < tempData.length ? Color.getAlpha(tempData[index]) : 0;
		}
		
		public function getAlphaPixel(x:uint, y:uint) : uint {
			var _local5:Number = (Math.floor(y * scaleBitmapData) * sampleWidth + Math.floor(x * scaleBitmapData)) / 4;
			var _local3:Number = _local5 % Math.floor(_local5);
			var _local4:uint = alphaData[Math.floor(_local5)];
			if(_local3 == 0) {
				return Color.getAlpha(_local4);
			}
			if(_local3 == 0.25) {
				return Color.getRed(_local4);
			}
			if(_local3 == 0.5) {
				return Color.getGreen(_local4);
			}
			if(_local3 == 0.75) {
				return Color.getBlue(_local4);
			}
			return 0;
		}
		
		public function dispose() : void {
			alphaData = null;
			disposed = true;
		}
		
		public function getMemorySize() : Number {
			return !!alphaData ? getSize(alphaData) : 0;
		}
		
		public function getCreatTime() : Number {
			return createTime;
		}
		
		public function get disposed() : Boolean {
			return _disposed;
		}
		
		public function set disposed(value:Boolean) : void {
			_disposed = value;
		}
	}
}

