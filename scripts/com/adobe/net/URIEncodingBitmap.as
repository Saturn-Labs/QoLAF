package com.adobe.net {
	import flash.utils.ByteArray;
	
	public class URIEncodingBitmap extends ByteArray {
		public function URIEncodingBitmap(charsToEscape:String) {
			var _local4:int = 0;
			var _local2:int = 0;
			var _local5:* = 0;
			super();
			var _local3:ByteArray = new ByteArray();
			_local4 = 0;
			while(_local4 < 16) {
				this.writeByte(0);
				_local4++;
			}
			_local3.writeUTFBytes(charsToEscape);
			_local3.position = 0;
			while(_local3.bytesAvailable) {
				_local2 = _local3.readByte();
				if(_local2 <= 127) {
					this.position = _local2 >> 3;
					_local5 = this.readByte();
					_local5 = _local5 | 1 << (_local2 & 7);
					this.position = _local2 >> 3;
					this.writeByte(_local5);
				}
			}
		}
		
		public function ShouldEscape(char:String) : int {
			var _local4:int = 0;
			var _local2:int = 0;
			var _local3:ByteArray = new ByteArray();
			_local3.writeUTFBytes(char);
			_local3.position = 0;
			_local2 = _local3.readByte();
			if(_local2 & 0x80) {
				return 0;
			}
			if(_local2 < 31 || _local2 == 127) {
				return _local2;
			}
			this.position = _local2 >> 3;
			_local4 = this.readByte();
			if(_local4 & 1 << (_local2 & 7)) {
				return _local2;
			}
			return 0;
		}
	}
}

