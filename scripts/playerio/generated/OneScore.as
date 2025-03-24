package playerio.generated {
	import flash.events.EventDispatcher;
	import playerio.Client;
	import playerio.generated.messages.OneScoreAddArgs;
	import playerio.generated.messages.OneScoreAddError;
	import playerio.generated.messages.OneScoreAddOutput;
	import playerio.generated.messages.OneScoreLoadArgs;
	import playerio.generated.messages.OneScoreLoadError;
	import playerio.generated.messages.OneScoreLoadOutput;
	import playerio.generated.messages.OneScoreRefreshArgs;
	import playerio.generated.messages.OneScoreRefreshError;
	import playerio.generated.messages.OneScoreRefreshOutput;
	import playerio.generated.messages.OneScoreSetArgs;
	import playerio.generated.messages.OneScoreSetError;
	import playerio.generated.messages.OneScoreSetOutput;
	import playerio.utils.HTTPChannel;
	
	public class OneScore extends EventDispatcher {
		protected var channel:HTTPChannel;
		
		protected var client:Client;
		
		public function OneScore(channel:HTTPChannel, client:Client) {
			super();
			this.channel = channel;
			this.client = client;
		}
		
		protected function _oneScoreRefresh(callback:Function = null, errorHandler:Function = null) : void {
			var input:OneScoreRefreshArgs = new OneScoreRefreshArgs();
			var output:OneScoreRefreshOutput = new OneScoreRefreshOutput();
			channel.Request(6 * 60,input,output,new OneScoreRefreshError(),function(param1:OneScoreRefreshOutput):void {
				if(callback != null) {
					try {
						callback(param1.oneScore);
					}
					catch(e:Error) {
						client.handleCallbackError("OneScore.oneScoreRefresh",e);
						throw e;
					}
				}
			},function(param1:OneScoreRefreshError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _oneScoreSet(score:int, callback:Function = null, errorHandler:Function = null) : void {
			var input:OneScoreSetArgs = new OneScoreSetArgs(score);
			var output:OneScoreSetOutput = new OneScoreSetOutput();
			channel.Request(354,input,output,new OneScoreSetError(),function(param1:OneScoreSetOutput):void {
				if(callback != null) {
					try {
						callback(param1.oneScore);
					}
					catch(e:Error) {
						client.handleCallbackError("OneScore.oneScoreSet",e);
						throw e;
					}
				}
			},function(param1:OneScoreSetError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _oneScoreAdd(score:int, callback:Function = null, errorHandler:Function = null) : void {
			var input:OneScoreAddArgs = new OneScoreAddArgs(score);
			var output:OneScoreAddOutput = new OneScoreAddOutput();
			channel.Request(357,input,output,new OneScoreAddError(),function(param1:OneScoreAddOutput):void {
				if(callback != null) {
					try {
						callback(param1.oneScore);
					}
					catch(e:Error) {
						client.handleCallbackError("OneScore.oneScoreAdd",e);
						throw e;
					}
				}
			},function(param1:OneScoreAddError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _oneScoreLoad(userIds:Array, callback:Function = null, errorHandler:Function = null) : void {
			var input:OneScoreLoadArgs = new OneScoreLoadArgs(userIds);
			var output:OneScoreLoadOutput = new OneScoreLoadOutput();
			channel.Request(351,input,output,new OneScoreLoadError(),function(param1:OneScoreLoadOutput):void {
				if(callback != null) {
					try {
						callback(param1.oneScores);
					}
					catch(e:Error) {
						client.handleCallbackError("OneScore.oneScoreLoad",e);
						throw e;
					}
				}
			},function(param1:OneScoreLoadError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
	}
}

