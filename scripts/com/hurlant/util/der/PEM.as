package com.hurlant.util.der {
	import com.hurlant.crypto.rsa.RSAKey;
	import com.hurlant.util.Base64;
	import flash.utils.ByteArray;
	
	public class PEM {
		private static const RSA_PRIVATE_KEY_HEADER:String = "-----BEGIN RSA PRIVATE KEY-----";
		
		private static const RSA_PRIVATE_KEY_FOOTER:String = "-----END RSA PRIVATE KEY-----";
		
		private static const RSA_PUBLIC_KEY_HEADER:String = "-----BEGIN PUBLIC KEY-----";
		
		private static const RSA_PUBLIC_KEY_FOOTER:String = "-----END PUBLIC KEY-----";
		
		private static const CERTIFICATE_HEADER:String = "-----BEGIN CERTIFICATE-----";
		
		private static const CERTIFICATE_FOOTER:String = "-----END CERTIFICATE-----";
		
		public function PEM() {
			super();
		}
		
		public static function readRSAPrivateKey(str:String) : RSAKey {
			var _local3:Array = null;
			var _local2:ByteArray = extractBinary("-----BEGIN RSA PRIVATE KEY-----","-----END RSA PRIVATE KEY-----",str);
			if(_local2 == null) {
				return null;
			}
			var _local4:* = DER.parse(_local2);
			if(_local4 is Array) {
				_local3 = _local4 as Array;
				return new RSAKey(_local3[1],_local3[2].valueOf(),_local3[3],_local3[4],_local3[5],_local3[6],_local3[7],_local3[8]);
			}
			return null;
		}
		
		public static function readRSAPublicKey(str:String) : RSAKey {
			var _local3:Array = null;
			var _local2:ByteArray = extractBinary("-----BEGIN PUBLIC KEY-----","-----END PUBLIC KEY-----",str);
			if(_local2 == null) {
				return null;
			}
			var _local4:* = DER.parse(_local2);
			if(_local4 is Array) {
				_local3 = _local4 as Array;
				if(_local3[0][0].toString() != "1.2.840.113549.1.1.1") {
					return null;
				}
				_local4 = DER.parse(_local3[1]);
				if(_local4 is Array) {
					_local3 = _local4 as Array;
					return new RSAKey(_local3[0],_local3[1]);
				}
				return null;
			}
			return null;
		}
		
		public static function readCertIntoArray(str:String) : ByteArray {
			return extractBinary("-----BEGIN CERTIFICATE-----","-----END CERTIFICATE-----",str);
		}
		
		private static function extractBinary(header:String, footer:String, str:String) : ByteArray {
			var _local5:int = int(str.indexOf(header));
			if(_local5 == -1) {
				return null;
			}
			_local5 += header.length;
			var _local6:int = int(str.indexOf(footer));
			if(_local6 == -1) {
				return null;
			}
			var _local4:String = str.substring(_local5,_local6);
			_local4 = _local4.replace(/\s/gm,"");
			return Base64.decodeToByteArray(_local4);
		}
	}
}

