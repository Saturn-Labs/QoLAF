package com.hurlant.util.der {
	import flash.utils.ByteArray;
	
	public dynamic class Sequence extends Array implements IAsn1Type {
		protected var type:uint;
		
		protected var len:uint;
		
		public function Sequence(type:uint = 48, length:uint = 0) {
			super();
			this.type = type;
			this.len = length;
		}
		
		public function getLength() : uint {
			return len;
		}
		
		public function getType() : uint {
			return type;
		}
		
		public function toDER() : ByteArray {
			var _local3:int = 0;
			var _local1:IAsn1Type = null;
			var _local2:ByteArray = new ByteArray();
			_local3 = 0;
			while(_local3 < length) {
				_local1 = this[_local3];
				if(_local1 == null) {
					_local2.writeByte(5);
					_local2.writeByte(0);
				} else {
					_local2.writeBytes(_local1.toDER());
				}
				_local3++;
			}
			return DER.wrapDER(type,_local2);
		}
		
		public function toString() : String {
			var _local4:int = 0;
			var _local2:Boolean = false;
			var _local1:String = DER.indent;
			DER.indent += "    ";
			var _local3:String = "";
			_local4 = 0;
			while(_local4 < length) {
				if(this[_local4] != null) {
					_local2 = false;
					for(var _local5 in this) {
						if(_local4.toString() != _local5 && this[_local4] == this[_local5]) {
							_local3 += _local5 + ": " + this[_local4] + "\n";
							_local2 = true;
							break;
						}
					}
					if(!_local2) {
						_local3 += this[_local4] + "\n";
					}
				}
				_local4++;
			}
			DER.indent = _local1;
			return DER.indent + "Sequence[" + type + "][" + len + "][\n" + _local3 + "\n" + _local1 + "]";
		}
		
		public function findAttributeValue(oid:String) : IAsn1Type {
			var _local5:* = undefined;
			var _local3:* = undefined;
			var _local4:ObjectIdentifier = null;
			for each(var _local2 in this) {
				if(_local2 is Set) {
					_local5 = _local2[0];
					if(_local5 is Sequence) {
						_local3 = _local5[0];
						if(_local3 is ObjectIdentifier) {
							_local4 = _local3 as ObjectIdentifier;
							if(_local4.toString() == oid) {
								return _local5[1] as IAsn1Type;
							}
						}
					}
				}
			}
			return null;
		}
	}
}

