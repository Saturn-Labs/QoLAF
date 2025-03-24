package playerio.generated {
	import flash.events.EventDispatcher;
	import playerio.Client;
	import playerio.generated.messages.WriteErrorArgs;
	import playerio.generated.messages.WriteErrorError;
	import playerio.generated.messages.WriteErrorOutput;
	import playerio.utils.Converter;
	import playerio.utils.HTTPChannel;
	
	public class ErrorLog extends EventDispatcher {
		protected var channel:HTTPChannel;
		
		protected var client:Client;
		
		public function ErrorLog(channel:HTTPChannel, client:Client) {
			super();
			this.channel = channel;
			this.client = client;
		}
		
		protected function _writeError(source:String, error:String, details:String, stacktrace:String, extraData:Object, callback:Function = null, errorHandler:Function = null) : void {
			var input:WriteErrorArgs = new WriteErrorArgs(source,error,details,stacktrace,Converter.toKeyValueArray(extraData));
			var output:WriteErrorOutput = new WriteErrorOutput();
			channel.Request(50,input,output,new WriteErrorError(),function(param1:WriteErrorOutput):void {
				if(callback != null) {
					callback();
				}
			},function(param1:WriteErrorError):void {
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

