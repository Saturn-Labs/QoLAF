package playerio {
	internal class StringForm {
		public function StringForm() {
			super();
		}
		
		internal static function decodeStringDictionary(input:String) : Object {
			var _local2:Object = null;
			var _local6:* = null;
			var _local7:int = 0;
			var _local4:int = 0;
			var _local5:int = 0;
			var _local3:String = null;
			try {
				_local2 = {};
				_local6 = null;
				_local7 = 2;
				while(_local7 < input.length) {
					_local4 = int(input.indexOf(":",_local7));
					_local5 = int(input.substr(_local7,_local4 - _local7));
					_local3 = input.substr(_local4 + 1,_local5);
					_local7 = _local4 + 1 + _local5 + 1;
					if(_local6 == null) {
						_local6 = _local3;
					} else {
						_local2[_local6] = _local3;
						_local6 = null;
					}
				}
				return _local2;
			}
			catch(e:Error) {
				var _local10:* = {"error":e.message};
			}
			return _local10;
		}
		
		internal static function encodeStringDictionary(input:Object) : String {
			var _local2:String = "A";
			if(input != null) {
				for(var _local3 in input) {
					if(input[_local3] != undefined) {
						_local2 += ":";
						_local2 += _local3.length;
						_local2 += ":";
						_local2 += _local3;
						_local2 += ":";
						_local2 += (input[_local3] as String).length;
						_local2 += ":";
						_local2 += input[_local3] as String;
					}
				}
			}
			return _local2;
		}
		
		internal static function decodeStringArray(input:String) : Array {
			var _local6:int = 0;
			var _local4:int = 0;
			var _local5:int = 0;
			var _local3:String = null;
			var _local2:Array = [];
			_local6 = 2;
			while(_local6 < input.length) {
				_local4 = int(input.indexOf(":",_local6));
				_local5 = int(input.substr(_local6,_local4 - _local6));
				_local3 = input.substr(_local4 + 1,_local5);
				_local6 = _local4 + 1 + _local5 + 1;
				_local2.push(_local3);
			}
			return _local2;
		}
	}
}

