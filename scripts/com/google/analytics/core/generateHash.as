package com.google.analytics.core {
	public function generateHash(input:String) : int {
		var _local4:int = 0;
		var _local5:int = 0;
		var _local2:* = 1;
		var _local3:* = 0;
		if(input != null && input != "") {
			_local2 = 0;
			_local4 = input.length - 1;
			while(_local4 >= 0) {
				_local5 = int(input.charCodeAt(_local4));
				_local2 = (_local2 << 6 & 0x0FFFFFFF) + _local5 + (_local5 << 14);
				_local3 = _local2 & 0x0FE00000;
				if(_local3 != 0) {
					_local2 ^= _local3 >> 21;
				}
				_local4--;
			}
		}
		return _local2;
	}
}

