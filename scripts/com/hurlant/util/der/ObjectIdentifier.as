package com.hurlant.util.der {
	import flash.utils.ByteArray;
	
	public class ObjectIdentifier implements IAsn1Type {
		private var type:uint;
		
		private var len:uint;
		
		private var oid:Array;
		
		public function ObjectIdentifier(type:uint, length:uint, b:*) {
			super();
			this.type = type;
			this.len = length;
			if(b is ByteArray) {
				parse(b as ByteArray);
			} else {
				if(!(b is String)) {
					throw new Error("Invalid call to new ObjectIdentifier");
				}
				generate(b as String);
			}
		}
		
		private function generate(s:String) : void {
			oid = s.split(".");
		}
		
		private function parse(b:ByteArray) : void {
			var _local3:* = false;
			var _local5:uint = b.readUnsignedByte();
			var _local2:Array = [];
			_local2.push(uint(_local5 / 40));
			_local2.push(uint(_local5 % 40));
			var _local4:uint = 0;
			while(b.bytesAvailable > 0) {
				_local5 = b.readUnsignedByte();
				_local3 = (_local5 & 0x80) == 0;
				_local5 &= 127;
				_local4 = _local4 * 128 + _local5;
				if(_local3) {
					_local2.push(_local4);
					_local4 = 0;
				}
			}
			oid = _local2;
		}
		
		public function getLength() : uint {
			return len;
		}
		
		public function getType() : uint {
			return type;
		}
		
		public function toDER() : ByteArray {
			var _local4:int = 0;
			var _local3:int = 0;
			var _local2:Array = [];
			_local2[0] = oid[0] * 40 + oid[1];
			_local4 = 2;
			while(_local4 < oid.length) {
				_local3 = parseInt(oid[_local4]);
				if(_local3 < 128) {
					_local2.push(_local3);
				} else if(_local3 < 0x4000) {
					_local2.push(_local3 >> 7 | 0x80);
					_local2.push(_local3 & 0x7F);
				} else if(_local3 < 0x200000) {
					_local2.push(_local3 >> 14 | 0x80);
					_local2.push(_local3 >> 7 & 0x7F | 0x80);
					_local2.push(_local3 & 0x7F);
				} else {
					if(_local3 >= 0x10000000) {
						throw new Error("OID element bigger than we thought. :(");
					}
					_local2.push(_local3 >> 21 | 0x80);
					_local2.push(_local3 >> 14 & 0x7F | 0x80);
					_local2.push(_local3 >> 7 & 0x7F | 0x80);
					_local2.push(_local3 & 0x7F);
				}
				_local4++;
			}
			len = _local2.length;
			if(type == 0) {
				type = 6;
			}
			_local2.unshift(len);
			_local2.unshift(type);
			var _local1:ByteArray = new ByteArray();
			_local4 = 0;
			while(_local4 < _local2.length) {
				_local1[_local4] = _local2[_local4];
				_local4++;
			}
			return _local1;
		}
		
		public function toString() : String {
			return DER.indent + oid.join(".");
		}
		
		public function dump() : String {
			return "OID[" + type + "][" + len + "][" + toString() + "]";
		}
	}
}

