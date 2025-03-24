package playerio.utils {
	import flash.system.Capabilities;
	
	public class Utilities {
		public static var clientAPI:String = "as3";
		
		public function Utilities() {
			super();
		}
		
		public static function getSystemInfo() : Object {
			var _local2:int = 0;
			var _local3:Array = ["cpuArchitecture","isDebugger","language","manufacturer","os","pixelAspectRatio","playerType","screenDPI","screenResolutionX","screenResolutionY","touchscreenType","version"];
			var _local1:Object = {};
			_local2 = 0;
			while(_local2 < _local3.length) {
				if(Capabilities[_local3[_local2]]) {
					_local1[_local3[_local2]] = Capabilities[_local3[_local2]].toString();
				}
				_local2++;
			}
			return _local1;
		}
		
		public static function getSystemInfoString() : String {
			var _local3:Object = getSystemInfo();
			var _local1:Array = [];
			for(var _local2 in _local3) {
				_local1.push(_local2 + ":" + _local3[_local2]);
			}
			return _local1.join("@|@");
		}
		
		public static function countKeys(dictionary:Object) : int {
			var _local2:int = 0;
			for(var _local3 in dictionary) {
				_local2++;
			}
			return _local2;
		}
		
		public static function find(array:Array, predicate:Function) : Object {
			var _local3:int = 0;
			_local3 = 0;
			while(_local3 < array.length) {
				if(predicate(array[_local3])) {
					return array[_local3];
				}
				_local3++;
			}
			return null;
		}
		
		public static function converter(array:Array, converter:Function) : Array {
			var _local4:int = 0;
			var _local3:Array = [];
			_local4 = 0;
			while(_local4 < array.length) {
				_local3.push(converter(array[_local4]));
				_local4++;
			}
			return _local3;
		}
	}
}

