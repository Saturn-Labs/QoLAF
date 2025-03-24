package starling.animation {
	import flash.utils.Dictionary;
	import starling.errors.AbstractClassError;
	
	public class Transitions {
		public static const LINEAR:String = "linear";
		
		public static const EASE_IN:String = "easeIn";
		
		public static const EASE_OUT:String = "easeOut";
		
		public static const EASE_IN_OUT:String = "easeInOut";
		
		public static const EASE_OUT_IN:String = "easeOutIn";
		
		public static const EASE_IN_BACK:String = "easeInBack";
		
		public static const EASE_OUT_BACK:String = "easeOutBack";
		
		public static const EASE_IN_OUT_BACK:String = "easeInOutBack";
		
		public static const EASE_OUT_IN_BACK:String = "easeOutInBack";
		
		public static const EASE_IN_ELASTIC:String = "easeInElastic";
		
		public static const EASE_OUT_ELASTIC:String = "easeOutElastic";
		
		public static const EASE_IN_OUT_ELASTIC:String = "easeInOutElastic";
		
		public static const EASE_OUT_IN_ELASTIC:String = "easeOutInElastic";
		
		public static const EASE_IN_BOUNCE:String = "easeInBounce";
		
		public static const EASE_OUT_BOUNCE:String = "easeOutBounce";
		
		public static const EASE_IN_OUT_BOUNCE:String = "easeInOutBounce";
		
		public static const EASE_OUT_IN_BOUNCE:String = "easeOutInBounce";
		
		private static var sTransitions:Dictionary;
		
		public function Transitions() {
			super();
			throw new AbstractClassError();
		}
		
		public static function getTransition(name:String) : Function {
			if(sTransitions == null) {
				registerDefaults();
			}
			return sTransitions[name];
		}
		
		public static function register(name:String, func:Function) : void {
			if(sTransitions == null) {
				registerDefaults();
			}
			sTransitions[name] = func;
		}
		
		private static function registerDefaults() : void {
			sTransitions = new Dictionary();
			register("linear",linear);
			register("easeIn",easeIn);
			register("easeOut",easeOut);
			register("easeInOut",easeInOut);
			register("easeOutIn",easeOutIn);
			register("easeInBack",easeInBack);
			register("easeOutBack",easeOutBack);
			register("easeInOutBack",easeInOutBack);
			register("easeOutInBack",easeOutInBack);
			register("easeInElastic",easeInElastic);
			register("easeOutElastic",easeOutElastic);
			register("easeInOutElastic",easeInOutElastic);
			register("easeOutInElastic",easeOutInElastic);
			register("easeInBounce",easeInBounce);
			register("easeOutBounce",easeOutBounce);
			register("easeInOutBounce",easeInOutBounce);
			register("easeOutInBounce",easeOutInBounce);
		}
		
		protected static function linear(ratio:Number) : Number {
			return ratio;
		}
		
		protected static function easeIn(ratio:Number) : Number {
			return ratio * ratio * ratio;
		}
		
		protected static function easeOut(ratio:Number) : Number {
			var _local2:Number = ratio - 1;
			return _local2 * _local2 * _local2 + 1;
		}
		
		protected static function easeInOut(ratio:Number) : Number {
			return easeCombined(easeIn,easeOut,ratio);
		}
		
		protected static function easeOutIn(ratio:Number) : Number {
			return easeCombined(easeOut,easeIn,ratio);
		}
		
		protected static function easeInBack(ratio:Number) : Number {
			var _local2:Number = 1.70158;
			return Math.pow(ratio,2) * ((_local2 + 1) * ratio - _local2);
		}
		
		protected static function easeOutBack(ratio:Number) : Number {
			var _local3:Number = ratio - 1;
			var _local2:Number = 1.70158;
			return Math.pow(_local3,2) * ((_local2 + 1) * _local3 + _local2) + 1;
		}
		
		protected static function easeInOutBack(ratio:Number) : Number {
			return easeCombined(easeInBack,easeOutBack,ratio);
		}
		
		protected static function easeOutInBack(ratio:Number) : Number {
			return easeCombined(easeOutBack,easeInBack,ratio);
		}
		
		protected static function easeInElastic(ratio:Number) : Number {
			var _local2:Number = NaN;
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			if(ratio == 0 || ratio == 1) {
				return ratio;
			}
			_local2 = 0.3;
			_local3 = _local2 / 4;
			_local4 = ratio - 1;
			return -1 * Math.pow(2,10 * _local4) * Math.sin((_local4 - _local3) * (2 * 3.141592653589793) / _local2);
		}
		
		protected static function easeOutElastic(ratio:Number) : Number {
			var _local2:Number = NaN;
			var _local3:Number = NaN;
			if(ratio == 0 || ratio == 1) {
				return ratio;
			}
			_local2 = 0.3;
			_local3 = _local2 / 4;
			return Math.pow(2,-10 * ratio) * Math.sin((ratio - _local3) * (2 * 3.141592653589793) / _local2) + 1;
		}
		
		protected static function easeInOutElastic(ratio:Number) : Number {
			return easeCombined(easeInElastic,easeOutElastic,ratio);
		}
		
		protected static function easeOutInElastic(ratio:Number) : Number {
			return easeCombined(easeOutElastic,easeInElastic,ratio);
		}
		
		protected static function easeInBounce(ratio:Number) : Number {
			return 1 - easeOutBounce(1 - ratio);
		}
		
		protected static function easeOutBounce(ratio:Number) : Number {
			var _local4:Number = NaN;
			var _local3:Number = 7.5625;
			var _local2:Number = 2.75;
			if(ratio < 1 / _local2) {
				_local4 = _local3 * Math.pow(ratio,2);
			} else if(ratio < 2 / _local2) {
				ratio -= 1.5 / _local2;
				_local4 = _local3 * Math.pow(ratio,2) + 0.75;
			} else if(ratio < 2.5 / _local2) {
				ratio -= 2.25 / _local2;
				_local4 = _local3 * Math.pow(ratio,2) + 0.9375;
			} else {
				ratio -= 2.625 / _local2;
				_local4 = _local3 * Math.pow(ratio,2) + 0.984375;
			}
			return _local4;
		}
		
		protected static function easeInOutBounce(ratio:Number) : Number {
			return easeCombined(easeInBounce,easeOutBounce,ratio);
		}
		
		protected static function easeOutInBounce(ratio:Number) : Number {
			return easeCombined(easeOutBounce,easeInBounce,ratio);
		}
		
		protected static function easeCombined(startFunc:Function, endFunc:Function, ratio:Number) : Number {
			if(ratio < 0.5) {
				return 0.5 * startFunc(ratio * 2);
			}
			return 0.5 * endFunc((ratio - 0.5) * 2) + 0.5;
		}
	}
}

