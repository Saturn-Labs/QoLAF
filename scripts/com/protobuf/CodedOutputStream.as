package com.protobuf {
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput;
	
	public final class CodedOutputStream {
		public static const DEFAULT_BUFFER_SIZE:int = 4096;
		
		public static var LITTLE_ENDIAN_32_SIZE:int = 4;
		
		private var limit:int;
		
		private var position:int;
		
		private var output:IDataOutput;
		
		public function CodedOutputStream(output:IDataOutput) {
			super();
			this.output = output;
			this.limit = 0x1000;
		}
		
		public static function newInstance(output:IDataOutput) : CodedOutputStream {
			return new CodedOutputStream(output);
		}
		
		public static function computeVarint64Size(fieldNumber:int, value:Number) : int {
			return computeTagSize(fieldNumber) + computeRawVarint64Size(value);
		}
		
		public static function computeRawVarint64Size(num:Number) : int {
			if(num < 0) {
				return 10;
			}
			var _local2:int = 1;
			while(num > 128) {
				num = Math.floor(num / 128);
				_local2++;
			}
			return _local2;
		}
		
		public static function computeFieldSize(number:int, value:*, type:int) : int {
			if(value is String) {
				return computeStringSize(number,value as String);
			}
			if(value is Boolean) {
				return computeBoolSize(number,value as Boolean);
			}
			if(value is Number && type == 13) {
				return computeUInt32Size(number,value as uint);
			}
			if(value is Number && type == 5) {
				return computeInt32Size(number,value as int);
			}
			if(value is Number && type == 2) {
				return computeFloatSize(number,value as Number);
			}
			if(value is Number && type == 1) {
				return computeDoubleSize(number,value as Number);
			}
			if(value is Number && type == 3) {
				return computeVarint64Size(number,value as Number);
			}
			if(value is Number) {
				return computeInt32Size(number,value as Number);
			}
			if(value is Message) {
				return value.getSerializedSize();
			}
			throw new InvalidProtocolBufferException("Could not compute size of field, type was not valid");
		}
		
		public static function computeDoubleSize(fieldNumber:int, value:Number) : int {
			return computeTagSize(fieldNumber) + LITTLE_ENDIAN_32_SIZE;
		}
		
		public static function computeFloatSize(fieldNumber:int, value:Number) : int {
			return computeTagSize(fieldNumber) + LITTLE_ENDIAN_32_SIZE;
		}
		
		public static function computeInt32Size(fieldNumber:int, value:int) : int {
			if(value >= 0) {
				return computeTagSize(fieldNumber) + computeRawVarint32Size(value);
			}
			return computeTagSize(fieldNumber) + 10;
		}
		
		public static function computeFixed32Size(fieldNumber:int, value:int) : int {
			return computeTagSize(fieldNumber) + LITTLE_ENDIAN_32_SIZE;
		}
		
		public static function computeBoolSize(fieldNumber:int, value:Boolean) : int {
			return computeTagSize(fieldNumber) + 1;
		}
		
		public static function computeStringSize(fieldNumber:int, value:String) : int {
			var _local3:ByteArray = new ByteArray();
			_local3.writeUTFBytes(value);
			return computeTagSize(fieldNumber) + computeRawVarint32Size(_local3.length) + _local3.length;
		}
		
		public static function computeGroupSize(fieldNumber:int, value:Message) : int {
			return computeTagSize(fieldNumber) * 2 + value.getSerializedSize();
		}
		
		public static function computeMessageSize(fieldNumber:int, value:Message) : int {
			var _local3:int = value.getSerializedSize();
			return computeTagSize(fieldNumber) + computeRawVarint32Size(_local3) + _local3;
		}
		
		public static function computeBytesSize(fieldNumber:int, value:ByteArray) : int {
			var _local3:int = int(value.length);
			return computeTagSize(fieldNumber) + computeRawVarint32Size(_local3) + _local3;
		}
		
		public static function computeUInt32Size(fieldNumber:int, value:int) : int {
			return computeTagSize(fieldNumber) + computeRawVarint32Size(value);
		}
		
		public static function computeEnumSize(fieldNumber:int, value:int) : int {
			return computeTagSize(fieldNumber) + computeRawVarint32Size(value);
		}
		
		public static function computeSFixed32Size(fieldNumber:int, value:int) : int {
			return computeTagSize(fieldNumber) + LITTLE_ENDIAN_32_SIZE;
		}
		
		public static function computeSInt32Size(fieldNumber:int, value:int) : int {
			return computeTagSize(fieldNumber) + computeRawVarint32Size(encodeZigZag32(value));
		}
		
		public static function computeMessageSetExtensionSize(fieldNumber:int, value:Message) : int {
			return computeTagSize(1) * 2 + computeUInt32Size(2,fieldNumber) + computeMessageSize(3,value);
		}
		
		public static function computeRawMessageSetExtensionSize(fieldNumber:int, value:String) : int {
			var _local3:* = null;
			_local3.writeUTFBytes(value);
			return computeTagSize(1) * 2 + computeUInt32Size(2,fieldNumber) + computeBytesSize(3,_local3);
		}
		
		public static function computeTagSize(fieldNumber:int) : int {
			return computeRawVarint32Size(WireFormat.makeTag(fieldNumber,0));
		}
		
		public static function computeRawVarint32Size(value:int) : int {
			if((value & -128) == 0) {
				return 1;
			}
			if((value & -16384) == 0) {
				return 2;
			}
			if((value & -2097152) == 0) {
				return 3;
			}
			if((value & -268435456) == 0) {
				return 4;
			}
			return 5;
		}
		
		public static function encodeZigZag32(n:int) : int {
			return n << 1 ^ n >> 31;
		}
		
		public function writeVariableInt64(fieldNumber:int, value:Number) : void {
			writeTag(fieldNumber,0);
			writeRawVariableInt64(value);
		}
		
		public function writeRawVariableInt64(num:Number) : void {
			var _local3:Array = null;
			var _local9:Array = null;
			var _local8:Number = NaN;
			var _local4:int = 0;
			var _local2:int = 0;
			var _local5:int = 0;
			var _local6:int = 0;
			var _local7:* = 0;
			if(num < 0) {
				num = Math.abs(num);
				_local3 = [0,0,0,0,0,0,0,0,0];
				_local9 = [127,127,127,127,127,127,127,127,127,1];
				_local8 = 0;
				while(num >= 128) {
					_local3[_local8++] = num & 0x7F;
					num = Math.floor(num / 128);
				}
				_local3[_local8++] = num & 0x7F;
				_local4 = 0;
				while(_local4 < _local3.length) {
					_local9[_local4] ^= _local3[_local4];
					_local4++;
				}
				_local9[0]++;
				_local2 = 0;
				while(_local9[_local2] > 127) {
					_local9[_local2] = 0;
					_local9[_local2 + 1]++;
				}
				_local5 = 0;
				while(_local5 < _local9.length - 1) {
					_local9[_local5] |= 128;
					_local5++;
				}
				_local6 = 0;
				while(_local6 < _local9.length) {
					writeRawByte(_local9[_local6]);
					_local6++;
				}
			} else {
				while(num >= 128) {
					_local7 = num & 0x7F | 0x80;
					writeRawByte(_local7);
					num = Math.floor(num / 128);
				}
				writeRawByte(num);
			}
		}
		
		public function writeDouble(fieldNumber:int, value:Number) : void {
			writeTag(fieldNumber,1);
			writeRawDouble(value);
		}
		
		public function writeRawDouble(value:Number) : void {
			var _local2:ByteArray = new ByteArray();
			_local2.writeDouble(value);
			_local2.position = 0;
			var _local10:int = _local2.readByte();
			var _local8:int = _local2.readByte();
			var _local9:int = _local2.readByte();
			var _local6:int = _local2.readByte();
			var _local7:int = _local2.readByte();
			var _local4:int = _local2.readByte();
			var _local5:int = _local2.readByte();
			var _local3:int = _local2.readByte();
			writeRawByte(_local3);
			writeRawByte(_local5);
			writeRawByte(_local4);
			writeRawByte(_local7);
			writeRawByte(_local6);
			writeRawByte(_local9);
			writeRawByte(_local8);
			writeRawByte(_local10);
		}
		
		public function writeFloat(fieldNumber:int, value:Number) : void {
			writeTag(fieldNumber,5);
			writeRawFloat(value);
		}
		
		public function writeRawFloat(value:Number) : void {
			var _local2:ByteArray = new ByteArray();
			_local2.writeFloat(value);
			_local2.position = 0;
			var _local6:int = _local2.readByte();
			var _local4:int = _local2.readByte();
			var _local5:int = _local2.readByte();
			var _local3:int = _local2.readByte();
			writeRawByte(_local3);
			writeRawByte(_local5);
			writeRawByte(_local4);
			writeRawByte(_local6);
		}
		
		public function writeInt32(fieldNumber:int, value:Number) : void {
			writeTag(fieldNumber,0);
			writeRawVarint32(value);
		}
		
		public function writeFixed32(fieldNumber:int, value:int) : void {
			writeTag(fieldNumber,5);
			writeRawLittleEndian32(value);
		}
		
		public function writeBool(fieldNumber:int, value:Boolean) : void {
			writeTag(fieldNumber,0);
			writeRawByte(value ? 1 : 0);
		}
		
		public function writeString(fieldNumber:int, value:String) : void {
			writeTag(fieldNumber,2);
			var _local3:ByteArray = new ByteArray();
			_local3.writeUTFBytes(value);
			writeRawVarint32(_local3.length);
			writeRawBytes(_local3);
		}
		
		public function writeMessage(fieldNumber:int, value:Message) : void {
			writeTag(fieldNumber,2);
			var _local3:ByteArray = new ByteArray();
			value.writeToDataOutput(_local3);
			_local3.position = 0;
			writeRawVarint32(_local3.length);
			output.writeBytes(_local3,0,_local3.length);
		}
		
		public function writeBytes(fieldNumber:int, value:ByteArray) : void {
			writeTag(fieldNumber,2);
			value.position = 0;
			writeRawVarint32(value.length);
			writeRawBytes(value);
		}
		
		public function writeUInt32(fieldNumber:int, value:int) : void {
			writeTag(fieldNumber,0);
			writeRawVarint32(value);
		}
		
		public function writeEnum(fieldNumber:int, value:int) : void {
			writeTag(fieldNumber,0);
			writeRawVarint32(value);
		}
		
		public function writeSFixed32(fieldNumber:int, value:int) : void {
			writeTag(fieldNumber,5);
			writeRawLittleEndian32(value);
		}
		
		public function writeSInt32(fieldNumber:int, value:int) : void {
			writeTag(fieldNumber,0);
			writeRawVarint32(encodeZigZag32(value));
		}
		
		public function writeField(number:int, value:*, type:int) : void {
			if(value is String) {
				writeString(number,value as String);
			} else if(value is Boolean) {
				writeBool(number,value as Boolean);
			} else if(value is Number && type == 13) {
				writeUInt32(number,value as uint);
			} else if(value is int && type == 5) {
				writeInt32(number,value as int);
			} else if(value is Number && type == 2) {
				writeFloat(number,value as Number);
			} else if(value is Number && type == 1) {
				writeDouble(number,value as Number);
			} else if(value is Number && type == 3) {
				writeVariableInt64(number,value as Number);
			} else if(value is Number) {
				writeInt32(number,value as Number);
			} else {
				if(!(value is ByteArray)) {
					throw new InvalidProtocolBufferException("Tried to write primative field type, but type was not valid");
				}
				writeBytes(number,value as ByteArray);
			}
		}
		
		public function writeRawByte(value:int) : void {
			output.writeByte(value);
		}
		
		public function writeRawBytes(value:ByteArray) : void {
			writeRawBytesPartial(value,0,value.length);
		}
		
		public function writeRawBytesPartial(value:ByteArray, offset:int, length:int) : void {
			output.writeBytes(value,offset,length);
		}
		
		public function writeTag(fieldNumber:int, wireType:int) : void {
			writeRawVarint32(WireFormat.makeTag(fieldNumber,wireType));
		}
		
		public function writeRawVarint32(value:int) : void {
			while((value & -128) != 0) {
				writeRawByte(value & 0x7F | 0x80);
				value >>>= 7;
			}
			writeRawByte(value);
		}
		
		public function writeRawLittleEndian32(value:int) : void {
			writeRawByte(value & 0xFF);
			writeRawByte(value >> 8 & 0xFF);
			writeRawByte(value >> 16 & 0xFF);
			writeRawByte(value >> 24 & 0xFF);
		}
	}
}

