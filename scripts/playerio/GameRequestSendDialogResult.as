package playerio {
	public class GameRequestSendDialogResult {
		private var _recipientCountExternal:int;
		
		private var _recipients:Array;
		
		public function GameRequestSendDialogResult() {
			super();
		}
		
		internal function _internal_initialize(recipients:Array, recipientCountExternal:int) : void {
			this._recipientCountExternal = recipientCountExternal;
			this._recipients = recipients;
		}
		
		public function get recipients() : Array {
			return _recipients;
		}
	}
}

