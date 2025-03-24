package com.hurlant.util.der {
	import flash.utils.ByteArray;
	
	public class UTCTime implements IAsn1Type {
		protected var type:uint;
		
		protected var len:uint;
		
		public var date:Date;
		
		public function UTCTime(type:uint, len:uint) {
			super();
			this.type = type;
			this.len = len;
		}
		
		public function getLength() : uint {
			return len;
		}
		
		public function getType() : uint {
			return type;
		}
		
		public function setUTCTime(str:String) : void {
			var _local4:uint = parseInt(str.substr(0,2));
			if(_local4 < 50) {
				_local4 += 2000;
			} else {
				_local4 += 1900;
			}
			var _local2:uint = parseInt(str.substr(2,2));
			var _local5:uint = parseInt(str.substr(4,2));
			var _local3:uint = parseInt(str.substr(6,2));
			var _local6:uint = parseInt(str.substr(8,2));
			date = new Date(_local4,_local2 - 1,_local5,_local3,_local6);
		}
		
		public function toString() : String {
			return DER.indent + "UTCTime[" + type + "][" + len + "][" + date + "]";
		}
		
		public function toDER() : ByteArray {
			return null;
		}
	}
}

