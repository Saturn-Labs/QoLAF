package generics
{
	import flash.geom.ColorTransform;
	
	public class Color
	{
		private static const lR:Number = 0.213;
		private static const lG:Number = 0.715;
		private static const lB:Number = 0.072;
		public function Color()
		{
			super();
		}
		
		public static function tintColor(param1:ColorTransform, param2:uint, param3:Number):ColorTransform
		{
			param1.redMultiplier = param1.greenMultiplier = param1.blueMultiplier = 1 - param3;
			param1.redOffset = Math.round(((param2 & 0xFF0000) >> 16) * param3);
			param1.greenOffset = Math.round(((param2 & 0xFF00) >> 8) * param3);
			param1.blueOffset = Math.round((param2 & 0xFF) * param3);
			return param1;
		}
		
		public static function getDesaturationMatrix(param1:Number, param2:Number, param3:Number):Array
		{
			var _loc4_:Array = [];
			_loc4_ = _loc4_.concat([param1, param2, param2, 0, 0]);
			_loc4_ = _loc4_.concat([param2, param1, param2, 0, 0]);
			_loc4_ = _loc4_.concat([param2, param2, param1, 0, 0]);
			return _loc4_.concat([0, 0, 0, param3, 0]);
		}
		
		public static function getColorMatrix(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number):Vector.<Number>
		{
			var _loc6_:Number = param1 * param2;
			var _loc7_:Number = param1 * param3;
			var _loc8_:Number = param1 * param4;
			return new <Number>[_loc6_, _loc7_, _loc8_, 0, 0, _loc6_, _loc7_, _loc8_, 0, 0, _loc6_, _loc7_, _loc8_, 0, 0, 0, 0, 0, param5, 0];
		}
		
		public static function fixColorCode(param1:Object, param2:Boolean = false):uint
		{
			var _loc4_:Number = Number(param1);
			var _loc3_:Number = param2 ? 4294967295 : 16777215;
			return uint(Math.min(Math.max(_loc4_, 0), _loc3_));
		}
		
		public static function HEXtoRGB(param1:uint):Array
		{
			var _loc2_:* = param1 >> 16 & 0xFF;
			var _loc4_:* = param1 >> 8 & 0xFF;
			var _loc3_:* = param1 & 0xFF;
			return [_loc2_, _loc4_, _loc3_];
		}
		
		public static function adjustColor(param1:Number = 0, param2:Number = 0, param3:Number = 0, param4:Number = 0):Vector.<Number>
		{
			var _loc5_:Vector.<Number> = new <Number>[1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
			multiplyMatrix(_loc5_, adjustHue(param4));
			multiplyMatrix(_loc5_, adjustSaturation(param3));
			multiplyMatrix(_loc5_, adjustBrightness(param1));
			multiplyMatrix(_loc5_, adjustContrast(param2));
			return _loc5_;
		}
		
		public static function adjustHue(param1:Number):Vector.<Number>
		{
			param1 = param1 < -1 ? -1 : param1;
			param1 = param1 > 1 ? 1 : param1;
			var _loc2_:Number = 180 * param1 * (3.141592653589793 / 180);
			var _loc4_:Number = Math.cos(_loc2_);
			var _loc3_:Number = Math.sin(_loc2_);
			return new <Number>[0.213 + _loc4_ * (1 - 0.213) + _loc3_ * -0.213, 0.715 + _loc4_ * -0.715 + _loc3_ * -0.715, 0.072 + _loc4_ * -0.072 + _loc3_ * (1 - 0.072), 0, 0, 0.213 + _loc4_ * -0.213 + _loc3_ * 0.143, 0.715 + _loc4_ * (1 - 0.715) + _loc3_ * 0.14, 0.072 + _loc4_ * -0.072 + _loc3_ * -0.283, 0, 0, 0.213 + _loc4_ * -0.213 + _loc3_ * -0.787, 0.715 + _loc4_ * -0.715 + _loc3_ * 0.715, 0.072 + _loc4_ * (1 - 0.072) + _loc3_ * 0.072, 0, 0, 0, 0, 0, 1, 0];
		}
		
		public static function RGBToHex(param1:uint, param2:uint, param3:uint):uint
		{
			return uint(param1 << 16 | param2 << 8 | param3);
		}
		
		public static function HexToRGB(param1:uint):Array
		{
			var _loc5_:Array = [];
			var _loc4_:uint = uint(param1 >> 16 & 0xFF);
			var _loc2_:uint = uint(param1 >> 8 & 0xFF);
			var _loc3_:uint = uint(param1 & 0xFF);
			_loc5_.push(_loc4_, _loc2_, _loc3_);
			return _loc5_;
		}
		
		public static function RGBtoHSV(param1:Number, param2:Number, param3:Number):Array
		{
			var _loc5_:uint = Math.max(param1, param2, param3);
			var _loc4_:uint = Math.min(param1, param2, param3);
			var _loc8_:Number = 0;
			var _loc6_:Number = 0;
			var _loc9_:Number = 0;
			var _loc7_:Array = [];
			if (_loc5_ == _loc4_)
			{
				_loc8_ = 0;
			}
			else if (_loc5_ == param1)
			{
				_loc8_ = (60 * (param2 - param3) / (_loc5_ - _loc4_) + 360) % 360;
			}
			else if (_loc5_ == param2)
			{
				_loc8_ = 60 * (param3 - param1) / (_loc5_ - _loc4_) + 120;
			}
			else if (_loc5_ == param3)
			{
				_loc8_ = 60 * (param1 - param2) / (_loc5_ - _loc4_) + 240;
			}
			_loc9_ = _loc5_;
			if (_loc5_ == 0)
			{
				_loc6_ = 0;
			}
			else
			{
				_loc6_ = (_loc5_ - _loc4_) / _loc5_;
			}
			return [Math.round(_loc8_), Math.round(_loc6_ * 100), Math.round(_loc9_ / 255 * 100)];
		}
		
		public static function HSVtoRGB(param1:Number, param2:Number, param3:Number):Array
		{
			var _loc12_:* = 0;
			var _loc5_:* = 0;
			var _loc6_:* = 0;
			var _loc7_:Array = [];
			var _loc10_:Number = param2 / 100;
			var _loc9_:Number = param3 / 100;
			var _loc8_:int = Math.floor(param1 / 60) % 6;
			var _loc4_:Number = param1 / 60 - Math.floor(param1 / 60);
			var _loc14_:Number = _loc9_ * (1 - _loc10_);
			var _loc13_:Number = _loc9_ * (1 - _loc4_ * _loc10_);
			var _loc11_:Number = _loc9_ * (1 - (1 - _loc4_) * _loc10_);
			switch (_loc8_)
			{
			case 0: 
				_loc12_ = _loc9_;
				_loc5_ = _loc11_;
				_loc6_ = _loc14_;
				break;
			case 1: 
				_loc12_ = _loc13_;
				_loc5_ = _loc9_;
				_loc6_ = _loc14_;
				break;
			case 2: 
				_loc12_ = _loc14_;
				_loc5_ = _loc9_;
				_loc6_ = _loc11_;
				break;
			case 3: 
				_loc12_ = _loc14_;
				_loc5_ = _loc13_;
				_loc6_ = _loc9_;
				break;
			case 4: 
				_loc12_ = _loc11_;
				_loc5_ = _loc14_;
				_loc6_ = _loc9_;
				break;
			case 5: 
				_loc12_ = _loc9_;
				_loc5_ = _loc14_;
				_loc6_ = _loc13_;
			}
			return [Math.round(_loc12_ * 255), Math.round(_loc5_ * 255), Math.round(_loc6_ * 255)];
		}
		
		public static function HEXHue(param1:uint, param2:Number):uint
		{
			var _loc7_:Number = extractRedFromHEX(param1);
			var _loc4_:Number = extractGreenFromHEX(param1);
			var _loc6_:Number = extractBlueFromHEX(param1);
			var _loc8_:Array = RGBtoHSV(_loc7_, _loc4_, _loc6_);
			var _loc10_:Number = Number(_loc8_[0]);
			var _loc5_:Number = Number(_loc8_[1]);
			var _loc3_:Number = Number(_loc8_[2]);
			_loc10_ += Util.radiansToDegrees(param2 * 2);
			if (_loc10_ < 0)
			{
				_loc10_ = 359 - _loc10_;
			}
			else if (_loc10_ > 359)
			{
				_loc10_ -= 359;
			}
			var _loc9_:Array = HSVtoRGB(_loc10_, _loc5_, _loc3_);
			return RGBToHex(_loc9_[0], _loc9_[1], _loc9_[2]);
		}
		
		public static function adjustSaturation(param1:Number):Vector.<Number>
		{
			param1 = param1 < -1 ? -1 : param1;
			param1 = param1 > 1 ? 1 : param1;
			var _loc3_:Number = param1 + 1;
			var _loc6_:Number = 1 - _loc3_;
			var _loc5_:Number = _loc6_ * 0.213;
			var _loc2_:Number = _loc6_ * 0.715;
			var _loc4_:Number = _loc6_ * 0.072;
			return new <Number>[_loc5_ + _loc3_, _loc2_, _loc4_, 0, 0, _loc5_, _loc2_ + _loc3_, _loc4_, 0, 0, _loc5_, _loc2_, _loc4_ + _loc3_, 0, 0, 0, 0, 0, 1, 0];
		}
		
		public static function adjustContrast(param1:Number):Vector.<Number>
		{
			param1 = param1 < -1 ? -1 : param1;
			param1 = param1 > 1 ? 1 : param1;
			var _loc2_:Number = param1 + 1;
			var _loc3_:Number = 128 * (1 - _loc2_);
			return new <Number>[_loc2_, 0, 0, 0, _loc3_, 0, _loc2_, 0, 0, _loc3_, 0, 0, _loc2_, 0, _loc3_, 0, 0, 0, _loc2_, 0];
		}
		
		public static function adjustBrightness(param1:Number):Vector.<Number>
		{
			param1 = param1 < -1 ? -1 : param1;
			param1 = param1 > 1 ? 1 : param1;
			var _loc2_:Number = 255 * param1;
			return new <Number>[1, 0, 0, 0, _loc2_, 0, 1, 0, 0, _loc2_, 0, 0, 1, 0, _loc2_, 0, 0, 0, 1, 0];
		}
		
		protected static function multiplyMatrix(param1:Vector.<Number>, param2:Vector.<Number>):void
		{
			var _loc7_:* = 0;
			var _loc5_:* = 0;
			var _loc6_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc4_:Array = [];
			_loc7_ = 0;
			while (_loc7_ < 4)
			{
				_loc5_ = 0;
				while (_loc5_ < 5)
				{
					_loc4_[_loc5_] = param1[_loc5_ + _loc7_ * 5];
					_loc5_++;
				}
				_loc5_ = 0;
				while (_loc5_ < 5)
				{
					_loc3_ = 0;
					_loc6_ = 0;
					while (_loc6_ < 4)
					{
						_loc3_ += param2[_loc5_ + _loc6_ * 5] * _loc4_[_loc6_];
						_loc6_++;
					}
					param1[_loc5_ + _loc7_ * 5] = _loc3_;
					_loc5_++;
				}
				_loc7_++;
			}
		}
		
		public static function RGBtoHEX(param1:uint, param2:uint, param3:uint):uint
		{
			return param1 << 16 | param2 << 8 | param3;
		}
		
		public static function extractRedFromHEX(param1:uint):uint
		{
			return param1 >> 16 & 0xFF;
		}
		
		public static function extractGreenFromHEX(param1:uint):uint
		{
			return param1 >> 8 & 0xFF;
		}
		
		public static function extractBlueFromHEX(param1:uint):uint
		{
			return param1 & 0xFF;
		}
		
		public static function interpolateColor(param1:uint, param2:uint, param3:Number):uint
		{
			var _loc16_:Number = 1 - param3;
			var _loc13_:uint = uint(param1 >> 24 & 0xFF);
			var _loc14_:uint = uint(param1 >> 16 & 0xFF);
			var _loc8_:uint = uint(param1 >> 8 & 0xFF);
			var _loc5_:uint = uint(param1 & 0xFF);
			var _loc11_:uint = uint(param2 >> 24 & 0xFF);
			var _loc17_:uint = uint(param2 >> 16 & 0xFF);
			var _loc4_:uint = uint(param2 >> 8 & 0xFF);
			var _loc9_:uint = uint(param2 & 0xFF);
			var _loc7_:uint = _loc13_ * _loc16_ + _loc11_ * param3;
			var _loc15_:uint = _loc14_ * _loc16_ + _loc17_ * param3;
			var _loc10_:uint = _loc8_ * _loc16_ + _loc4_ * param3;
			var _loc6_:uint = _loc5_ * _loc16_ + _loc9_ * param3;
			return uint(_loc7_ << 24 | _loc15_ << 16 | _loc10_ << 8 | _loc6_);
		}
	}
}
