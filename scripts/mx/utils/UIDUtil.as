package mx.utils {
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import mx.core.IPropertyChangeNotifier;
	import mx.core.IUIComponent;
	import mx.core.IUID;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class UIDUtil {
		mx_internal static const VERSION:String = "4.6.0.23201";
		
		private static const ALPHA_CHAR_CODES:Array = [48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70];
		
		private static var uidDictionary:Dictionary = new Dictionary(true);
		
		public function UIDUtil() {
			super();
		}
		
		public static function createUID() : String {
			var _local3:int = 0;
			var _local4:int = 0;
			var _local1:Array = new Array(36);
			var _local2:int = 0;
			_local3 = 0;
			while(_local3 < 8) {
				var _local7:*;
				_local1[_local7 = _local2++] = ALPHA_CHAR_CODES[Math.floor(Math.random() * 16)];
				_local3++;
			}
			_local3 = 0;
			while(_local3 < 3) {
				_local1[_local7 = _local2++] = 45;
				_local4 = 0;
				while(_local4 < 4) {
					var _local8:*;
					_local1[_local8 = _local2++] = ALPHA_CHAR_CODES[Math.floor(Math.random() * 16)];
					_local4++;
				}
				_local3++;
			}
			_local1[_local7 = _local2++] = 45;
			var _local5:Number = Number(new Date().getTime());
			var _local6:String = ("0000000" + _local5.toString(16).toUpperCase()).substr(-8);
			_local3 = 0;
			while(_local3 < 8) {
				_local1[_local8 = _local2++] = _local6.charCodeAt(_local3);
				_local3++;
			}
			_local3 = 0;
			while(_local3 < 4) {
				_local1[_local8 = _local2++] = ALPHA_CHAR_CODES[Math.floor(Math.random() * 16)];
				_local3++;
			}
			return String.fromCharCode.apply(null,_local1);
		}
		
		public static function fromByteArray(ba:ByteArray) : String {
			var _local2:Array = null;
			var _local3:uint = 0;
			var _local4:uint = 0;
			var _local5:int = 0;
			if(ba != null && ba.length >= 16 && ba.bytesAvailable >= 16) {
				_local2 = new Array(36);
				_local3 = 0;
				_local4 = 0;
				while(_local4 < 16) {
					if(_local4 == 4 || _local4 == 6 || _local4 == 8 || _local4 == 10) {
						var _local6:*;
						_local2[_local6 = _local3++] = 45;
					}
					_local5 = ba.readByte();
					_local2[_local6 = _local3++] = ALPHA_CHAR_CODES[(_local5 & 0xF0) >>> 4];
					var _local7:*;
					_local2[_local7 = _local3++] = ALPHA_CHAR_CODES[_local5 & 0x0F];
					_local4++;
				}
				return String.fromCharCode.apply(null,_local2);
			}
			return null;
		}
		
		public static function isUID(uid:String) : Boolean {
			var _local2:uint = 0;
			var _local3:Number = NaN;
			if(uid != null && uid.length == 36) {
				_local2 = 0;
				while(_local2 < 36) {
					_local3 = Number(uid.charCodeAt(_local2));
					if(_local2 == 8 || _local2 == 13 || _local2 == 18 || _local2 == 23) {
						if(_local3 != 45) {
							return false;
						}
					} else if(_local3 < 48 || _local3 > 70 || _local3 > 57 && _local3 < 65) {
						return false;
					}
					_local2++;
				}
				return true;
			}
			return false;
		}
		
		public static function toByteArray(uid:String) : ByteArray {
			var _local2:ByteArray = null;
			var _local3:uint = 0;
			var _local4:String = null;
			var _local5:uint = 0;
			var _local6:uint = 0;
			if(isUID(uid)) {
				_local2 = new ByteArray();
				_local3 = 0;
				while(_local3 < uid.length) {
					_local4 = uid.charAt(_local3);
					if(_local4 != "-") {
						_local5 = getDigit(_local4);
						_local3++;
						_local6 = getDigit(uid.charAt(_local3));
						_local2.writeByte((_local5 << 4 | _local6) & 0xFF);
					}
					_local3++;
				}
				_local2.position = 0;
				return _local2;
			}
			return null;
		}
		
		public static function getUID(item:Object) : String {
			var result:String = null;
			var xitem:XML = null;
			var nodeKind:String = null;
			var notificationFunction:Function = null;
			result = null;
			if(item == null) {
				return result;
			}
			if(item is IUID) {
				result = IUID(item).uid;
				if(result == null || result.length == 0) {
					result = createUID();
					IUID(item).uid = result;
				}
			} else if(item is IPropertyChangeNotifier && !(item is IUIComponent)) {
				result = IPropertyChangeNotifier(item).uid;
				if(result == null || result.length == 0) {
					result = createUID();
					IPropertyChangeNotifier(item).uid = result;
				}
			} else {
				if(item is String) {
					return item as String;
				}
				try {
					if(item is XMLList && item.length == 1) {
						item = item[0];
					}
					if(item is XML) {
						xitem = XML(item);
						nodeKind = xitem.nodeKind();
						if(nodeKind == "text" || nodeKind == "attribute") {
							return xitem.toString();
						}
						notificationFunction = xitem.notification();
						if(!(notificationFunction is Function)) {
							notificationFunction = XMLNotifier.mx_internal::initializeXMLForNotification();
							xitem.setNotification(notificationFunction);
						}
						if(notificationFunction["uid"] == undefined) {
							result = notificationFunction["uid"] = createUID();
						}
						result = notificationFunction["uid"];
					} else {
						if("mx_internal_uid" in item) {
							return item.mx_internal_uid;
						}
						if("uid" in item) {
							return item.uid;
						}
						result = uidDictionary[item];
						if(!result) {
							result = createUID();
							try {
								item.mx_internal_uid = result;
							}
							catch(e:Error) {
								uidDictionary[item] = result;
							}
						}
					}
				}
				catch(e:Error) {
					result = item.toString();
				}
			}
			return result;
		}
		
		private static function getDigit(hex:String) : uint {
			switch(hex) {
				case "A":
				case "a":
					return 10;
				case "B":
				case "b":
					return 11;
				case "C":
				case "c":
					return 12;
				case "D":
				case "d":
					return 13;
				case "E":
				case "e":
					return 14;
				case "F":
				case "f":
					return 15;
				default:
					return new uint(hex);
			}
		}
	}
}

