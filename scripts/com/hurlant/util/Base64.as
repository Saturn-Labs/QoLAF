package com.hurlant.util {
	import flash.utils.ByteArray;
	
	public class Base64 {
		private static const BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
		
		public static const version:String = "1.0.0";
		
		public function Base64() {
			super();
			throw new Error("Base64 class is static container only");
		}
		
		public static function encode(data:String) : String {
			var _local2:ByteArray = new ByteArray();
			_local2.writeUTFBytes(data);
			return encodeByteArray(_local2);
		}
		
		public static function encodeByteArray(data:ByteArray) : String {
			var _local4:Array = null;
			var _local5:* = 0;
			var _local6:* = 0;
			var _local7:* = 0;
			var _local2:String = "";
			var _local3:Array = new Array(4);
			data.position = 0;
			while(data.bytesAvailable > 0) {
				_local4 = [];
				_local5 = 0;
				while(_local5 < 3 && data.bytesAvailable > 0) {
					_local4[_local5] = data.readUnsignedByte();
					_local5++;
				}
				_local3[0] = (_local4[0] & 0xFC) >> 2;
				_local3[1] = (_local4[0] & 3) << 4 | _local4[1] >> 4;
				_local3[2] = (_local4[1] & 0x0F) << 2 | _local4[2] >> 6;
				_local3[3] = _local4[2] & 0x3F;
				_local6 = _local4.length;
				while(_local6 < 3) {
					_local3[_local6 + 1] = 64;
					_local6++;
				}
				_local7 = 0;
				while(_local7 < _local3.length) {
					_local2 += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=".charAt(_local3[_local7]);
					_local7++;
				}
			}
			return _local2;
		}
		
		public static function decode(data:String) : String {
			var _local2:ByteArray = decodeToByteArray(data);
			return _local2.readUTFBytes(_local2.length);
		}
		
		public static function decodeToByteArray(data:String) : ByteArray {
			var _local5:* = 0;
			var _local6:* = 0;
			var _local7:* = 0;
			var _local2:ByteArray = new ByteArray();
			var _local4:Array = new Array(4);
			var _local3:Array = new Array(3);
			_local5 = 0;
			while(_local5 < data.length) {
				_local6 = 0;
				while(_local6 < 4 && _local5 + _local6 < data.length) {
					_local4[_local6] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=".indexOf(data.charAt(_local5 + _local6));
					_local6++;
				}
				_local3[0] = (_local4[0] << 2) + ((_local4[1] & 0x30) >> 4);
				_local3[1] = ((_local4[1] & 0x0F) << 4) + ((_local4[2] & 0x3C) >> 2);
				_local3[2] = ((_local4[2] & 3) << 6) + _local4[3];
				_local7 = 0;
				while(_local7 < _local3.length) {
					if(_local4[_local7 + 1] == 64) {
						break;
					}
					_local2.writeByte(_local3[_local7]);
					_local7++;
				}
				_local5 += 4;
			}
			_local2.position = 0;
			return _local2;
		}
	}
}

