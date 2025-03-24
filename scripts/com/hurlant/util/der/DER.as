package com.hurlant.util.der {
	import flash.utils.ByteArray;
	
	public class DER {
		public static var indent:String = "";
		
		public function DER() {
			super();
		}
		
		public static function parse(der:ByteArray, structure:* = null) : IAsn1Type {
			var _local6:* = 0;
			var _local3:ByteArray = null;
			var _local10:int = 0;
			var _local9:Sequence = null;
			var _local18:Array = null;
			var _local19:Object = null;
			var _local15:* = false;
			var _local7:Boolean = false;
			var _local17:String = null;
			var _local20:* = undefined;
			var _local14:int = 0;
			var _local21:ByteArray = null;
			var _local16:IAsn1Type = null;
			var _local12:Set = null;
			var _local11:ByteString = null;
			var _local4:PrintableString = null;
			var _local22:UTCTime = null;
			var _local8:* = int(der.readUnsignedByte());
			var _local5:* = (_local8 & 0x20) != 0;
			_local8 &= 31;
			var _local13:* = int(der.readUnsignedByte());
			if(_local13 >= 128) {
				_local6 = _local13 & 0x7F;
				_local13 = 0;
				while(_local6 > 0) {
					_local13 = _local13 << 8 | der.readUnsignedByte();
					_local6--;
				}
			}
			switch(_local8) {
				case 0:
				case 16:
					_local10 = int(der.position);
					_local9 = new Sequence(_local8,_local13);
					_local18 = structure as Array;
					if(_local18 != null) {
						_local18 = _local18.concat();
					}
					while(der.position < _local10 + _local13) {
						_local19 = null;
						if(_local18 != null) {
							_local19 = _local18.shift();
						}
						if(_local19 != null) {
							while(_local19 && _local19.optional) {
								_local15 = _local19.value is Array;
								_local7 = isConstructedType(der);
								if(_local15 == _local7) {
									break;
								}
								_local9.push(_local19.defaultValue);
								_local9[_local19.name] = _local19.defaultValue;
								_local19 = _local18.shift();
							}
						}
						if(_local19 != null) {
							_local17 = _local19.name;
							_local20 = _local19.value;
							if(_local19.extract) {
								_local14 = getLengthOfNextElement(der);
								_local21 = new ByteArray();
								_local21.writeBytes(der,der.position,_local14);
								_local9[_local17 + "_bin"] = _local21;
							}
							_local16 = DER.parse(der,_local20);
							_local9.push(_local16);
							_local9[_local17] = _local16;
						} else {
							_local9.push(DER.parse(der));
						}
					}
					return _local9;
				case 17:
					_local10 = int(der.position);
					_local12 = new Set(_local8,_local13);
					while(der.position < _local10 + _local13) {
						_local12.push(DER.parse(der));
					}
					return _local12;
				case 2:
					_local3 = new ByteArray();
					der.readBytes(_local3,0,_local13);
					_local3.position = 0;
					return new Integer(_local8,_local13,_local3);
				case 6:
					_local3 = new ByteArray();
					der.readBytes(_local3,0,_local13);
					_local3.position = 0;
					return new ObjectIdentifier(_local8,_local13,_local3);
				default:
					trace("I DONT KNOW HOW TO HANDLE DER stuff of TYPE " + _local8);
				case 3:
					if(der[der.position] == 0) {
						der.position++;
						_local13--;
					}
					break;
				case 4:
					break;
				case 5:
					return null;
				case 19:
					_local4 = new PrintableString(_local8,_local13);
					_local4.setString(der.readMultiByte(_local13,"US-ASCII"));
					return _local4;
				case 34:
				case 20:
					_local4 = new PrintableString(_local8,_local13);
					_local4.setString(der.readMultiByte(_local13,"latin1"));
					return _local4;
				case 23:
					_local22 = new UTCTime(_local8,_local13);
					_local22.setUTCTime(der.readMultiByte(_local13,"US-ASCII"));
					return _local22;
			}
			_local11 = new ByteString(_local8,_local13);
			der.readBytes(_local11,0,_local13);
			return _local11;
		}
		
		private static function getLengthOfNextElement(b:ByteArray) : int {
			var _local4:* = 0;
			var _local2:uint = b.position;
			b.position++;
			var _local3:* = int(b.readUnsignedByte());
			if(_local3 >= 128) {
				_local4 = _local3 & 0x7F;
				_local3 = 0;
				while(_local4 > 0) {
					_local3 = _local3 << 8 | b.readUnsignedByte();
					_local4--;
				}
			}
			_local3 += b.position - _local2;
			b.position = _local2;
			return _local3;
		}
		
		private static function isConstructedType(b:ByteArray) : Boolean {
			var _local2:int = int(b[b.position]);
			return (_local2 & 0x20) != 0;
		}
		
		public static function wrapDER(type:int, data:ByteArray) : ByteArray {
			var _local3:ByteArray = new ByteArray();
			_local3.writeByte(type);
			var _local4:int = int(data.length);
			if(_local4 < 128) {
				_local3.writeByte(_local4);
			} else if(_local4 < 256) {
				_local3.writeByte(129);
				_local3.writeByte(_local4);
			} else if(_local4 < 65536) {
				_local3.writeByte(130);
				_local3.writeByte(_local4 >> 8);
				_local3.writeByte(_local4);
			} else if(_local4 < 0x1000000) {
				_local3.writeByte(131);
				_local3.writeByte(_local4 >> 16);
				_local3.writeByte(_local4 >> 8);
				_local3.writeByte(_local4);
			} else {
				_local3.writeByte(132);
				_local3.writeByte(_local4 >> 24);
				_local3.writeByte(_local4 >> 16);
				_local3.writeByte(_local4 >> 8);
				_local3.writeByte(_local4);
			}
			_local3.writeBytes(data);
			_local3.position = 0;
			return _local3;
		}
	}
}

