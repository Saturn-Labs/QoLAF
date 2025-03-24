package playerio.utils {
	import com.protobuf.Message;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	
	public class HTTPChannel {
		private var useSSL:Boolean = false;
		
		private var _token:String = "";
		
		private var _headers:Array = [];
		
		public function HTTPChannel(useSecureApiRequests:Boolean = false) {
			super();
			this.useSSL = useSecureApiRequests;
		}
		
		private function get endpoint() : String {
			return this.useSSL ? "https://api.playerio.com/api" : "http://api.playerio.com/api";
		}
		
		public function set headers(urlRequestHeaders:Array) : void {
			_headers = urlRequestHeaders;
		}
		
		public function Request(RPCMethod:int, messageInput:Message, messageOutput:Message, messageError:Message, success:Function, error:Function) : void {
			var r:URLRequest;
			var b:ByteArray;
			var tba:ByteArray;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = "binary";
			loader.addEventListener("complete",function(param1:Event):void {
				var _local3:int = 0;
				var _local4:ByteArray = loader.data;
				_local4.position = 0;
				if(_local4.readUnsignedByte() != 0) {
					_local3 = int(_local4.readUnsignedShort());
					_token = _local4.readUTFBytes(_local3);
				}
				var _local2:int = int(_local4.readUnsignedByte());
				if(_local2 == 0) {
					messageError.readFromDataOutput(_local4);
					error(messageError);
				} else if(_local2 == 1) {
					messageOutput.readFromDataOutput(_local4);
					success(messageOutput);
				}
			});
			loader.addEventListener("ioError",function(param1:IOErrorEvent):void {
				try {
					(messageError as Object).message = "[PlayerIOError] " + param1.text;
				}
				catch(e:Error) {
				}
				error(messageError);
			});
			loader.addEventListener("securityError",function(param1:SecurityError):void {
				try {
					(messageError as Object).message = "[PlayerIOError] " + param1.message;
				}
				catch(e:Error) {
				}
				error(messageError);
			});
			r = new URLRequest(this.endpoint + "/" + RPCMethod);
			r.requestHeaders = _headers;
			r.method = "POST";
			if(_token != "") {
				r.requestHeaders = [new URLRequestHeader("playertoken",_token)];
			}
			b = new ByteArray();
			messageInput.writeToDataOutput(b);
			if(b.length == 0) {
				tba = new ByteArray();
				tba.writeByte(8);
				tba.writeByte(0);
				r.data = tba;
			} else {
				r.data = b;
			}
			loader.load(r);
		}
		
		public function set token(t:String) : void {
			_token = t;
		}
		
		public function get token() : String {
			return _token;
		}
	}
}

