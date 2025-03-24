package playerio {
	import playerio.generated.GameRequests;
	import playerio.generated.PlayerIOError;
	import playerio.generated.messages.WaitingGameRequest;
	import playerio.utils.HTTPChannel;
	import playerio.utils.Utilities;
	
	public class GameRequests extends playerio.generated.GameRequests {
		private var _waitingRequests:Array;
		
		public function GameRequests(channel:HTTPChannel, client:Client) {
			super(channel,client);
		}
		
		public function get waitingRequests() : Array {
			if(_waitingRequests == null) {
				throw new playerio.generated.PlayerIOError("Cannot access requests before refresh() has been called.",playerio.PlayerIOError.GameRequestsNotLoaded.errorID);
			}
			return _waitingRequests;
		}
		
		public function send(requestType:String, requestData:Object, recipients:Array, callback:Function, errorCallback:Function) : void {
			_gameRequestsSend(requestType,requestData,recipients,callback,errorCallback);
		}
		
		public function refresh(callback:Function, errorCallback:Function) : void {
			_gameRequestsRefresh(null,function(param1:Array, param2:Boolean, param3:Array):void {
				read(param1,param2);
				if(callback != null) {
					callback();
				}
			},errorCallback);
		}
		
		public function remove(requests:Array, callback:Function, errorCallback:Function) : void {
			_gameRequestsDelete(requestArrayToRequestIdArray(requests),function(param1:Array, param2:Boolean):void {
				read(param1,param2);
				if(callback != null) {
					callback();
				}
			},errorCallback);
		}
		
		public function showSendDialog(requestType:String, requestData:Object, callback:Function) : void {
			var args:Object = {};
			args["requestType"] = requestType;
			args["requestData"] = StringForm.encodeStringDictionary(requestData);
			PublishingNetwork._internal_showDialog("sendgamerequest",args,channel,function(param1:Object):void {
				var _local2:GameRequestSendDialogResult = null;
				if(callback != null) {
					_local2 = new GameRequestSendDialogResult();
					_local2._internal_initialize(param1["recipients"] != undefined ? StringForm.decodeStringArray(param1["recipients"]) : [],param1["recipientCountExternal"] != undefined ? int(param1["recipientCountExternal"]) : 0);
					callback(_local2);
				}
			});
		}
		
		private function requestArrayToRequestIdArray(requests:Array) : Array {
			var _local3:int = 0;
			var _local2:Array = [];
			_local3 = 0;
			while(_local3 < requests.length) {
				_local2.push((requests[_local3] as GameRequest)._internal_id);
				_local3++;
			}
			return _local2;
		}
		
		private function read(requests:Array, moreRequestsWaiting:Boolean) : Boolean {
			var i:int;
			var item:WaitingGameRequest;
			var gr:GameRequest;
			var anyNew:Boolean = false;
			var array:Array = [];
			if(requests != null) {
				i = 0;
				while(i < requests.length) {
					item = requests[i];
					gr = new GameRequest();
					gr._internal_initialize(item);
					array.push(gr);
					if(_waitingRequests != null) {
						anyNew = anyNew || Utilities.find(_waitingRequests,function(param1:GameRequest):Boolean {
							return param1._internal_id == item.id;
						}) == null;
					}
					i++;
				}
			}
			this._waitingRequests = array;
			return anyNew;
		}
	}
}

