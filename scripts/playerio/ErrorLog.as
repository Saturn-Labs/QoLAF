package playerio {
	import playerio.generated.ErrorLog;
	import playerio.utils.HTTPChannel;
	
	public class ErrorLog extends playerio.generated.ErrorLog {
		public function ErrorLog(channel:HTTPChannel, client:Client) {
			super(channel,client);
		}
		
		public function writeError(error:String, details:String, stacktrace:String, extraData:Object, callback:Function = null, errorHandler:Function = null) : void {
			_writeError("AS3",error,details,stacktrace,extraData,callback,errorHandler);
		}
		
		internal function _internal_writeSystemError(error:String, details:String, stacktrace:String, extraData:Object, callback:Function = null, errorHandler:Function = null) : void {
			_writeError("[@SYSTEMERRORLOG@]AS3 Library",error,details,stacktrace,extraData,callback,errorHandler);
		}
	}
}

