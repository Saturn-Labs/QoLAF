package com.protobuf {
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	public class CodedInputStream {
		private static const DEFAULT_RECURSION_LIMIT:int = 64;
		
		private static const DEFAULT_SIZE_LIMIT:int = 67108864;
		
		private var bufferSize:int;
		
		private var bufferSizeAfterLimit:int = 0;
		
		private var bufferPos:int = 0;
		
		private var input:IDataInput;
		
		private var lastTag:int = 0;
		
		private var sizeLimit:int = 67108864;
		
		public function CodedInputStream(input:IDataInput) {
			super();
			this.bufferSize = 0;
			this.input = input;
		}
		
		public static function newInstance(input:IDataInput) : CodedInputStream {
			return new CodedInputStream(input);
		}
		
		public static function decodeZigZag32(n:int) : int {
			return n >>> 1 ^ -(n & 1);
		}
		
		public function readTag() : int {
			if(input.bytesAvailable != 0) {
				lastTag = readRawVarint32();
			} else {
				lastTag = 0;
			}
			return lastTag;
		}
		
		public function checkLastTagWas(value:int) : void {
			if(lastTag != value) {
				throw InvalidProtocolBufferException.invalidEndTag();
			}
		}
		
		public function skipField(tag:int) : Boolean {
			switch(WireFormat.getTagWireType(tag)) {
				case 0:
					while(input.readUnsignedByte() >= 128) {
					}
					return true;
				case 2:
					skipRawBytes(readRawVarint32());
					return true;
				case 3:
					skipMessage();
					checkLastTagWas(WireFormat.makeTag(WireFormat.getTagFieldNumber(tag),4));
					return true;
				case 4:
					return false;
				case 5:
					readRawLittleEndian32();
					return true;
				default:
					throw InvalidProtocolBufferException.invalidWireType();
			}
		}
		
		public function skipMessage() : void {
			var _local1:int = 0;
			do {
				_local1 = readTag();
			}
			while(!(_local1 == 0 || !skipField(_local1)));
			
		}
		
		public function readDouble() : Number {
			var _local2:int = readRawByte();
			var _local4:int = readRawByte();
			var _local3:int = readRawByte();
			var _local6:int = readRawByte();
			var _local5:int = readRawByte();
			var _local8:int = readRawByte();
			var _local7:int = readRawByte();
			var _local9:int = readRawByte();
			var _local1:ByteArray = new ByteArray();
			_local1.writeByte(_local9);
			_local1.writeByte(_local7);
			_local1.writeByte(_local8);
			_local1.writeByte(_local5);
			_local1.writeByte(_local6);
			_local1.writeByte(_local3);
			_local1.writeByte(_local4);
			_local1.writeByte(_local2);
			_local1.position = 0;
			return _local1.readDouble();
		}
		
		public function readFloat() : Number {
			var _local2:int = readRawByte();
			var _local4:int = readRawByte();
			var _local3:int = readRawByte();
			var _local5:int = readRawByte();
			var _local1:ByteArray = new ByteArray();
			_local1.writeByte(_local5);
			_local1.writeByte(_local3);
			_local1.writeByte(_local4);
			_local1.writeByte(_local2);
			_local1.position = 0;
			return _local1.readFloat();
		}
		
		public function readInt32() : int {
			return readRawVarint32();
		}
		
		public function readFixed32() : int {
			return readRawLittleEndian32();
		}
		
		public function readBool() : Boolean {
			return readRawVarint32() != 0;
		}
		
		public function readString() : String {
			var _local1:int = readRawVarint32();
			return new String(readRawBytes(_local1));
		}
		
		public function readBytes() : ByteArray {
			var _local1:int = readRawVarint32();
			return readRawBytes(_local1);
		}
		
		public function readUInt32() : int {
			return readRawVarint32();
		}
		
		public function readEnum() : int {
			return readRawVarint32();
		}
		
		public function readSFixed32() : int {
			return readRawLittleEndian32();
		}
		
		public function readSInt32() : int {
			return decodeZigZag32(readRawVarint32());
		}
		
		public function readPrimitiveField(type:int) : Object {
			switch(type - 1) {
				case 0:
					return readDouble();
				case 1:
					return readFloat();
				case 2:
					return readInt64();
				case 4:
					return readInt32();
				case 6:
					return readFixed32();
				case 7:
					return readBool();
				case 8:
					return readString();
				case 11:
					return readBytes();
				case 12:
					return readUInt32();
				case 13:
					return readEnum();
				case 14:
					return readSFixed32();
				case 16:
					return readSInt32();
				default:
					trace("Unknown primative field type: " + type);
					return null;
			}
		}
		
		public function readInt64() : Number {
			var _local2:int = 0;
			var _local4:int = 0;
			var _local7:int = 0;
			var _local6:Number = Number(input.readUnsignedByte());
			var _local9:int = 0;
			var _local8:Array = [];
			while(_local6 >= 128) {
				_local8[_local9++] = _local6 & 0x7F;
				_local6 = Number(input.readUnsignedByte());
			}
			_local8[_local9++] = _local6;
			var _local5:Boolean = false;
			if(_local8.length == 10) {
				_local5 = true;
				_local8.pop();
				_local8[0]--;
				_local2 = 0;
				while(_local8[_local2] < 0) {
					_local8[_local2] = 127;
					_local8[_local2 + 1]--;
				}
				_local4 = 0;
				while(_local4 < _local8.length) {
					_local8[_local4] = 0x7F ^ _local8[_local4];
					_local4++;
				}
			}
			var _local1:Number = 0;
			var _local3:Number = 1;
			_local7 = 0;
			while(_local7 < _local8.length) {
				_local1 += _local8[_local7] * _local3;
				_local3 *= 128;
				_local7++;
			}
			return _local5 ? -_local1 : _local1;
		}
		
		public function readRawVarint32() : int {
			var _local3:int = 0;
			var _local2:int = readRawByte();
			if(_local2 >= 0) {
				return _local2;
			}
			var _local1:* = _local2 & 0x7F;
			_local2 = readRawByte();
			if(_local2 >= 0) {
				_local1 |= _local2 << 7;
			} else {
				_local1 |= (_local2 & 0x7F) << 7;
				_local2 = readRawByte();
				if(_local2 >= 0) {
					_local1 |= _local2 << 14;
				} else {
					_local1 |= (_local2 & 0x7F) << 14;
					_local2 = readRawByte();
					if(_local2 >= 0) {
						_local1 |= _local2 << 21;
					} else {
						_local1 |= (_local2 & 0x7F) << 21;
						_local1 |= (_local2 = readRawByte()) << 28;
						if(_local2 < 0) {
							_local3 = 0;
							while(_local3 < 5) {
								if(readRawByte() >= 0) {
									return _local1;
								}
								_local3++;
							}
							throw InvalidProtocolBufferException.malformedVarint();
						}
					}
				}
			}
			return _local1;
		}
		
		public function readRawLittleEndian32() : int {
			var _local1:int = readRawByte();
			var _local3:int = readRawByte();
			var _local2:int = readRawByte();
			var _local4:int = readRawByte();
			return _local1 & 0xFF | (_local3 & 0xFF) << 8 | (_local2 & 0xFF) << 16 | (_local4 & 0xFF) << 24;
		}
		
		public function readRawByte() : int {
			return input.readByte();
		}
		
		public function readRawBytes(size:int) : ByteArray {
			if(size < 0) {
				throw InvalidProtocolBufferException.negativeSize();
			}
			var _local2:ByteArray = new ByteArray();
			if(size != 0) {
				input.readBytes(_local2,0,size);
			}
			return _local2;
		}
		
		public function skipRawBytes(size:int) : void {
			readRawBytes(size);
		}
	}
}

