package feathers.system {
	import flash.display.Stage;
	import flash.system.Capabilities;
	
	public class DeviceCapabilities {
		public static var tabletScreenMinimumInches:Number = 5;
		
		public static var screenPixelWidth:Number = NaN;
		
		public static var screenPixelHeight:Number = NaN;
		
		public static var dpi:int = Capabilities.screenDPI;
		
		public function DeviceCapabilities() {
			super();
		}
		
		public static function isTablet(stage:Stage) : Boolean {
			var _local2:* = screenPixelWidth;
			if(_local2 !== _local2) {
				_local2 = stage.fullScreenWidth;
			}
			var _local3:Number = screenPixelHeight;
			if(_local3 !== _local3) {
				_local3 = stage.fullScreenHeight;
			}
			if(_local2 < _local3) {
				_local2 = _local3;
			}
			return _local2 / dpi >= tabletScreenMinimumInches;
		}
		
		public static function isPhone(stage:Stage) : Boolean {
			return !isTablet(stage);
		}
		
		public static function screenInchesX(stage:Stage) : Number {
			var _local2:Number = screenPixelWidth;
			if(_local2 !== _local2) {
				_local2 = stage.fullScreenWidth;
			}
			return _local2 / dpi;
		}
		
		public static function screenInchesY(stage:Stage) : Number {
			var _local2:Number = screenPixelHeight;
			if(_local2 !== _local2) {
				_local2 = stage.fullScreenHeight;
			}
			return _local2 / dpi;
		}
	}
}

