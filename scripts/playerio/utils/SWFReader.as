package playerio.utils {
	import flash.geom.*;
	import flash.utils.ByteArray;
	
	public class SWFReader {
		public var compressed:Boolean;
		
		public var version:uint;
		
		public var fileSize:uint;
		
		private var _dimensions:Rectangle = new Rectangle();
		
		private var _tagCallbackBytesIncludesHeader:Boolean = false;
		
		public var frameRate:uint;
		
		public var totalFrames:uint;
		
		public var asVersion:uint;
		
		public var usesNetwork:Boolean;
		
		public var backgroundColor:uint;
		
		public var protectedFromImport:Boolean;
		
		public var debuggerEnabled:Boolean;
		
		public var metadata:XML;
		
		public var recursionLimit:uint;
		
		public var scriptTimeoutLimit:uint;
		
		public var hardwareAcceleration:uint;
		
		public var tagCallback:Function;
		
		public var parsed:Boolean;
		
		public var errorText:String = "";
		
		private var bytes:ByteArray;
		
		private var currentByte:int;
		
		private var bitPosition:int;
		
		private var currentTag:uint;
		
		private var bgColorFound:Boolean;
		
		private const GET_DATA_SIZE:int = 5;
		
		private const TWIPS_TO_PIXELS:Number = 0.05;
		
		private const TAG_HEADER_ID_BITS:int = 6;
		
		private const TAG_HEADER_MAX_SHORT:int = 63;
		
		private const SWF_C:uint = 67;
		
		private const SWF_F:uint = 70;
		
		private const SWF_W:uint = 87;
		
		private const SWF_S:uint = 83;
		
		private const TAG_ID_EOF:uint = 0;
		
		private const TAG_ID_BG_COLOR:uint = 9;
		
		private const TAG_ID_PROTECTED:uint = 24;
		
		private const TAG_ID_DEBUGGER1:uint = 58;
		
		private const TAG_ID_DEBUGGER2:uint = 64;
		
		private const TAG_ID_SCRIPT_LIMITS:uint = 65;
		
		private const TAG_ID_FILE_ATTS:uint = 69;
		
		private const TAG_ID_META:uint = 77;
		
		private const TAG_ID_SHAPE_1:uint = 2;
		
		private const TAG_ID_SHAPE_2:uint = 22;
		
		private const TAG_ID_SHAPE_3:uint = 32;
		
		private const TAG_ID_SHAPE_4:uint = 83;
		
		public function SWFReader(swfBytes:ByteArray = null) {
			super();
			parse(swfBytes);
		}
		
		public function get dimensions() : Rectangle {
			return _dimensions;
		}
		
		public function get width() : uint {
			return uint(_dimensions.width);
		}
		
		public function get height() : uint {
			return uint(_dimensions.height);
		}
		
		public function get tagCallbackBytesIncludesHeader() : Boolean {
			return _tagCallbackBytesIncludesHeader;
		}
		
		public function set tagCallbackBytesIncludesHeader(value:Boolean) : void {
			_tagCallbackBytesIncludesHeader = value;
		}
		
		public function toString() : String {
			var _local2:String = null;
			var _local1:String = null;
			if(parsed) {
				_local2 = compressed ? "compressed" : "uncompressed";
				_local1 = totalFrames > 1 ? "frames" : "frame";
				return "[SWF" + version + " AS" + asVersion + ".0: " + totalFrames + " " + _local1 + " @ " + frameRate + " fps " + _dimensions.width + "x" + _dimensions.height + " " + _local2 + "]";
			}
			return Object.prototype.toString.call(this);
		}
		
		public function parse(swfBytes:ByteArray) : void {
			var _local4:* = 0;
			var _local2:* = 0;
			var _local3:* = 0;
			var _local5:ByteArray = null;
			parseDefaults();
			if(swfBytes == null) {
				parseError("Error: Cannot parse a null value.");
				return;
			}
			parsed = true;
			try {
				bytes = swfBytes;
				bytes.endian = "littleEndian";
				bytes.position = 0;
				_local4 = bytes.readUnsignedByte();
				_local2 = bytes.readUnsignedByte();
				_local3 = bytes.readUnsignedByte();
				if(_local4 != 70 && _local4 != 67 || _local2 != 87 || _local3 != 83) {
					parseError("Error: Invalid SWF header.");
					return;
				}
				compressed = _local4 == 67;
				version = bytes.readUnsignedByte();
				fileSize = bytes.readUnsignedInt();
				if(compressed) {
					_local5 = new ByteArray();
					bytes.readBytes(_local5);
					bytes = _local5;
					bytes.endian = "littleEndian";
					bytes.position = 0;
					_local5 = null;
					bytes.uncompress();
				}
				_dimensions = readRect();
				bytes.position++;
				frameRate = bytes.readUnsignedByte();
				totalFrames = bytes.readUnsignedShort();
			}
			catch(error:Error) {
				parseError(error.message);
				return;
			}
			try {
				while(readTag()) {
				}
			}
			catch(error:Error) {
				parseError(error.message);
				return;
			}
			bytes = null;
		}
		
		private function parseDefaults() : void {
			compressed = false;
			version = 1;
			fileSize = 0;
			_dimensions = new Rectangle();
			frameRate = 12;
			totalFrames = 1;
			metadata = null;
			asVersion = 2;
			usesNetwork = false;
			backgroundColor = 0xffffff;
			protectedFromImport = false;
			debuggerEnabled = true;
			scriptTimeoutLimit = 256;
			recursionLimit = 15;
			hardwareAcceleration = 0;
			errorText = "";
			bgColorFound = false;
		}
		
		private function parseError(message:String = "Unkown error.") : void {
			compressed = false;
			version = 0;
			fileSize = 0;
			_dimensions = new Rectangle();
			frameRate = 0;
			totalFrames = 0;
			metadata = null;
			asVersion = 0;
			usesNetwork = false;
			backgroundColor = 0;
			protectedFromImport = false;
			debuggerEnabled = false;
			scriptTimeoutLimit = 0;
			recursionLimit = 0;
			hardwareAcceleration = 0;
			parsed = false;
			bytes = null;
			errorText = message;
		}
		
		private function paddedHex(value:uint, numChars:int = 6) : String {
			var _local3:String = value.toString(16);
			while(_local3.length < numChars) {
				_local3 = "0" + _local3;
			}
			return "0x" + _local3;
		}
		
		private function readString() : String {
			var _local1:uint = bytes.position;
			try {
				while(bytes[_local1] != 0) {
					_local1++;
				}
			}
			catch(error:Error) {
				return "";
			}
			return bytes.readUTFBytes(_local1 - bytes.position);
		}
		
		private function readRect() : Rectangle {
			nextBitByte();
			var _local2:Rectangle = new Rectangle();
			var _local1:uint = readBits(5);
			_local2.left = readBits(_local1,true) * 0.05;
			_local2.right = readBits(_local1,true) * 0.05;
			_local2.top = readBits(_local1,true) * 0.05;
			_local2.bottom = readBits(_local1,true) * 0.05;
			return _local2;
		}
		
		private function readMatrix() : Matrix {
			var _local1:* = 0;
			nextBitByte();
			var _local2:Matrix = new Matrix();
			if(readBits(1)) {
				_local1 = readBits(5);
				_local2.a = readBits(_local1,true);
				_local2.d = readBits(_local1,true);
			}
			if(readBits(1)) {
				_local1 = readBits(5);
				_local2.b = readBits(_local1,true);
				_local2.c = readBits(_local1,true);
			}
			_local1 = readBits(5);
			_local2.tx = readBits(_local1,true) * 0.05;
			_local2.ty = readBits(_local1,true) * 0.05;
			return _local2;
		}
		
		private function readBits(numBits:uint, signed:Boolean = false) : Number {
			var _local7:* = 0;
			var _local5:* = 0;
			var _local3:* = 0;
			var _local6:Number = 0;
			var _local4:uint = uint(8 - bitPosition);
			if(numBits <= _local4) {
				_local7 = uint((1 << numBits) - 1);
				_local6 = currentByte >> _local4 - numBits & _local7;
				if(numBits == _local4) {
					nextBitByte();
				} else {
					bitPosition += numBits;
				}
			} else {
				_local7 = uint((1 << _local4) - 1);
				_local5 = uint(currentByte & _local7);
				_local3 = uint(numBits - _local4);
				nextBitByte();
				_local6 = _local5 << _local3 | readBits(_local3);
			}
			if(signed && _local6 >> numBits - 1 == 1) {
				_local4 = uint(32 - numBits);
				_local7 = uint((1 << _local4) - 1);
				return _local7 << numBits | _local6;
			}
			return uint(_local6);
		}
		
		private function nextBitByte() : void {
			currentByte = bytes.readByte();
			bitPosition = 0;
		}
		
		private function readTag() : Boolean {
			var _local5:uint = bytes.position;
			var _local3:int = int(bytes.readUnsignedShort());
			currentTag = _local3 >> 6;
			var _local2:uint = uint(_local3 & 0x3F);
			if(_local2 == 63) {
				_local2 = bytes.readUnsignedInt();
			}
			var _local4:uint = bytes.position + _local2;
			var _local1:Boolean = readTagData(_local2,_local5,_local4);
			if(!_local1) {
				return false;
			}
			bytes.position = _local4;
			return true;
		}
		
		private function readTagData(tagLength:uint, start:uint, end:uint) : Boolean {
			var _local4:ByteArray = null;
			if(tagCallback != null) {
				_local4 = new ByteArray();
				if(_tagCallbackBytesIncludesHeader) {
					_local4.writeBytes(bytes,start,end - start);
				} else if(tagLength) {
					_local4.writeBytes(bytes,bytes.position,tagLength);
				}
				_local4.position = 0;
				tagCallback(currentTag,_local4);
			}
			switch(currentTag) {
				case 69:
					nextBitByte();
					readBits(1);
					hardwareAcceleration = readBits(2);
					readBits(1);
					asVersion = readBits(1) && version >= 9 ? 3 : 2;
					readBits(2);
					usesNetwork = readBits(1) == 1;
					break;
				case 77:
					try {
						metadata = new XML(readString());
					}
					catch(error:Error) {
					}
					break;
				case 9:
					if(!bgColorFound) {
						bgColorFound = true;
						backgroundColor = readRGB();
					}
					break;
				case 24:
					protectedFromImport = bytes.readUnsignedByte() != 0;
					break;
				case 58:
					if(version == 5) {
						debuggerEnabled = true;
					}
					break;
				case 64:
					if(version > 5) {
						debuggerEnabled = true;
					}
					break;
				case 65:
					recursionLimit = bytes.readUnsignedShort();
					scriptTimeoutLimit = bytes.readUnsignedShort();
					break;
				case 0:
					return false;
			}
			return true;
		}
		
		private function readRGB() : uint {
			return bytes.readUnsignedByte() << 16 | bytes.readUnsignedByte() << 8 | bytes.readUnsignedByte();
		}
		
		private function readARGB() : uint {
			return bytes.readUnsignedByte() << 24 | bytes.readUnsignedByte() << 16 | bytes.readUnsignedByte() << 8 | bytes.readUnsignedByte();
		}
		
		private function readRGBA() : uint {
			var _local3:uint = bytes.readUnsignedByte();
			var _local2:uint = bytes.readUnsignedByte();
			var _local4:uint = bytes.readUnsignedByte();
			var _local1:uint = bytes.readUnsignedByte();
			return _local1 << 24 | _local3 << 16 | _local2 << 8 | _local4;
		}
	}
}

