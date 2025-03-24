package playerio {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import playerio.generated.PlayerIOError;
	import playerio.generated.messages.ServerEndpoint;
	import playerio.utils.BinarySerializer;
	
	public class Connection {
		private static var connections:Array = [];
		
		private static const encodeChars:Array = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9","+","/"];
		
		private static const decodeChars:Array = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,62,-1,-1,-1,63,52,53,54,55,56,57,58,59,60,61,-1,-1,-1,-1,-1,-1,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,-1,-1,-1,-1,-1,-1,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,-1,-1,-1,-1,-1];
		
		private var socket:Socket;
		
		private var serializer:BinarySerializer;
		
		private var messageHandlers:Array = [];
		
		private var disconnectHandlers:Array = [];
		
		private var errorHandler:Function;
		
		private var client:Client;
		
		private var devserver:String;
		
		private var callback:Function;
		
		public var roomId:String;
		
		private var debugArr:ByteArray = new ByteArray();
		
		private var sendDebugInfo:Boolean = true;
		
		private var messagesReceived:int = 0;
		
		public function Connection(client:Client, roomId:String, key:String, endpoints:Array, joinData:Object, callback:Function, errorHandler:Function, devserver:String) {
			super();
			connections.push(this);
			this.client = client;
			this.roomId = roomId;
			this.errorHandler = errorHandler;
			this.devserver = devserver;
			this.callback = callback;
			serializer = new BinarySerializer();
			serializer.addEventListener("onMessage",handleMessage);
			if(endpoints.length > 1 && endpoints[0].port == 80) {
				endpoints.push(endpoints.shift());
			}
			doConnect(key,joinData,endpoints);
		}
		
		public static function encode(data:ByteArray) : String {
			var _local2:* = 0;
			var _local7:Array = [];
			var _local6:int = 0;
			var _local5:int = 0;
			var _local3:int = data.length % 3;
			var _local4:int = data.length - _local3;
			while(_local6 < _local4) {
				_local2 = data[_local6++] << 16 | data[_local6++] << 8 | data[_local6++];
				_local7[_local5++] = encodeChars[_local2 >> 18] + encodeChars[_local2 >> 12 & 0x3F] + encodeChars[_local2 >> 6 & 0x3F] + encodeChars[_local2 & 0x3F];
			}
			if(_local3 == 1) {
				_local2 = int(data[_local6++]);
				_local7[_local5++] = encodeChars[_local2 >> 2] + encodeChars[(_local2 & 3) << 4] + "==";
			} else if(_local3 == 2) {
				_local2 = data[_local6++] << 8 | data[_local6++];
				_local7[_local5++] = encodeChars[_local2 >> 10] + encodeChars[_local2 >> 4 & 0x3F] + encodeChars[(_local2 & 0x0F) << 2] + "=";
			}
			return _local7.join("");
		}
		
		private function doConnect(key:String, joinData:Object, endpoints:Array) : void {
			var tempSS:Socket;
			var serverInfo:Array;
			var endpoint:ServerEndpoint = endpoints.shift() as ServerEndpoint;
			var hadConnection:Boolean = false;
			var disposed:Boolean = false;
			if(devserver != null) {
				serverInfo = devserver.split(":");
				tempSS = new Socket(serverInfo[0],serverInfo[1]);
			} else {
				tempSS = new Socket(endpoint.address,endpoint.port);
			}
			tempSS.addEventListener("close",function():void {
				if(disposed) {
					return;
				}
				for each(var _local1 in disconnectHandlers) {
					try {
						_local1();
					}
					catch(e:Error) {
						client.handleCallbackError("Connection.addDisconnectHandler",e);
						throw e;
					}
				}
			});
			tempSS.addEventListener("connect",function(param1:Event):void {
				if(disposed) {
					try {
						tempSS.close();
					}
					catch(e:Error) {
					}
					return;
				}
				socket = tempSS;
				hadConnection = true;
				tempSS.writeByte(0);
				tempSS.flush();
				var _local3:Message = createMessage("join",key);
				for(var _local2 in joinData) {
					_local3.add(_local2.toString());
					_local3.add(joinData[_local2].toString());
				}
				sendMessage(_local3);
			});
			tempSS.addEventListener("ioError",function(param1:IOErrorEvent):void {
				disposed = true;
				try {
					tempSS.close();
				}
				catch(e:Error) {
				}
				if(devserver) {
					throwError("Unable to connect to development server on " + devserver + ". Is the development server running?",1);
				} else if(endpoints.length != 0 && !hadConnection) {
					doConnect(key,joinData,endpoints);
				} else {
					throwError("Unable to connect to player.io multiplayer server due to IO Error [" + param1.text + "]",1);
				}
			});
			tempSS.addEventListener("securityError",function(param1:SecurityErrorEvent):void {
				disposed = true;
				try {
					tempSS.close();
				}
				catch(e:Error) {
				}
				if(!hadConnection) {
					if(endpoints.length != 0 && !hadConnection) {
						doConnect(key,joinData,endpoints);
					} else {
						throwError("Unable to connect to player.io multiplayer server due to Security Error [" + param1.text + "]",1);
					}
				}
			});
			tempSS.addEventListener("socketData",function():void {
				var _local2:int = 0;
				var _local1:int = 0;
				if(disposed) {
					try {
						tempSS.close();
					}
					catch(e:Error) {
					}
					return;
				}
				var _local3:int = int(tempSS.bytesAvailable);
				_local2 = 0;
				while(_local2 < _local3) {
					_local1 = int(tempSS.readUnsignedByte());
					if(debugArr.length < 102400) {
						debugArr.writeByte(_local1);
					} else {
						sendDebugInfo = false;
					}
					try {
						serializer.AddByte(_local1);
					}
					catch(e:Error) {
						if(sendDebugInfo) {
							client.handleSystemError("Unable to deserialize multiplayer message",e,{"binary":encode(debugArr)});
						}
						throw e;
					}
					_local2++;
				}
			});
		}
		
		public function addMessageHandler(type:String, handler:Function) : void {
			messageHandlers.push(new MessageHandler(type,handler));
		}
		
		public function removeMessageHandler(type:String, handler:Function) : void {
			var _local3:int = 0;
			var _local4:MessageHandler = null;
			_local3 = 0;
			while(_local3 < messageHandlers.length) {
				_local4 = messageHandlers[_local3] as MessageHandler;
				if(_local4.type == type && _local4.handler == handler) {
					messageHandlers.splice(_local3,1);
					return;
				}
				_local3++;
			}
		}
		
		public function disconnect() : void {
			if(socket && socket.connected) {
				socket.close();
			}
		}
		
		public function addDisconnectHandler(handler:Function) : void {
			disconnectHandlers.push(handler);
		}
		
		public function removeDisconnectHandler(handler:Function) : void {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < disconnectHandlers.length) {
				if(disconnectHandlers[_local2] == handler) {
					disconnectHandlers.splice(_local2,1);
					return;
				}
				_local2++;
			}
		}
		
		public function get connected() : Boolean {
			return socket.connected;
		}
		
		public function createMessage(type:String, ... rest) : Message {
			var _local3:int = 0;
			var _local4:Message = new Message(type);
			_local3 = 0;
			while(_local3 < rest.length) {
				_local4.add(rest[_local3]);
				_local3++;
			}
			return _local4;
		}
		
		public function send(type:String, ... rest) : void {
			var _local3:int = 0;
			var _local4:Message = new Message(type);
			_local3 = 0;
			while(_local3 < rest.length) {
				_local4.add(rest[_local3]);
				_local3++;
			}
			sendMessage(_local4);
		}
		
		public function sendMessage(m:Message) : void {
			var _local2:ByteArray = null;
			if(socket && socket.connected) {
				_local2 = serializer.SerializeMessage(m as Message);
				_local2.position = 0;
				socket.writeBytes(_local2,0,_local2.length);
				socket.flush();
			} else {
				throwError("Unable to send data to server when disconnected from server",2);
			}
		}
		
		private function handleMessage(e:MessageEvent) : void {
			var _local5:playerio.generated.PlayerIOError = null;
			var _local4:int = 0;
			var _local6:MessageHandler = null;
			var _local3:Array = null;
			var _local2:int = 0;
			messagesReceived++;
			if(e.message.type == "playerio.joinresult") {
				if(e.message.getBoolean(0)) {
					try {
						callback(this);
					}
					catch(e:Error) {
						client.handleCallbackError("Connection.connect",e);
						throw e;
					}
				} else {
					_local5 = new playerio.generated.PlayerIOError(e.message.getString(2),e.message.getInt(1));
					if(errorHandler == null) {
						throw _local5;
					}
					errorHandler(_local5);
				}
			} else {
				_local4 = 0;
				while(_local4 < messageHandlers.length) {
					_local6 = messageHandlers[_local4] as MessageHandler;
					if(_local6.type == e.message.type || _local6.type == null || _local6.type == "*") {
						_local3 = [e.message];
						_local2 = 0;
						while(_local2 < e.message.length && _local2 < _local6.handler.length - 1) {
							_local3.push(e.message.getObject(_local2));
							_local2++;
						}
						try {
							_local6.handler.apply(_local6.handler,_local3);
						}
						catch(e:Error) {
							client.handleCallbackError("Connection.addMessageHandler(\"" + _local6.type + "\")",e);
							throw e;
						}
					}
					_local4++;
				}
			}
		}
		
		private function throwError(error:String, type:int) : void {
			var _local3:playerio.generated.PlayerIOError = new playerio.generated.PlayerIOError(error,type);
			if(errorHandler != null) {
				errorHandler(_local3);
				return;
			}
			client.handleCallbackErrorVerbose("Error occurred while talking to player.io multiplayer servers.",_local3);
			throw _local3;
		}
	}
}

class MessageHandler {
	public var type:String;
	
	public var handler:Function;
	
	public function MessageHandler(type:String, handler:Function) {
		super();
		this.type = type;
		this.handler = handler;
	}
}
