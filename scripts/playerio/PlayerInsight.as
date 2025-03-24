package playerio {
	import playerio.generated.PlayerIOError;
	import playerio.generated.PlayerInsight;
	import playerio.generated.messages.KeyValuePair;
	import playerio.generated.messages.PlayerInsightEvent;
	import playerio.generated.messages.PlayerInsightState;
	import playerio.utils.HTTPChannel;
	
	public class PlayerInsight extends playerio.generated.PlayerInsight {
		private var _state:PlayerInsightState = null;
		
		public function PlayerInsight(channel:HTTPChannel, client:Client, state:PlayerInsightState) {
			this._state = state;
			super(channel,client);
		}
		
		public function get playersOnline() : int {
			if(_state.playersOnline == -1) {
				throw new playerio.generated.PlayerIOError("The current connection does not have the rights required to read the playersonline variable.",3);
			}
			return _state.playersOnline;
		}
		
		public function getSegment(segmentGroup:String) : String {
			var _local2:int = 0;
			var _local3:KeyValuePair = null;
			_local2 = 0;
			while(_local2 < _state.segments.length) {
				_local3 = _state.segments[_local2];
				if(_local3.key == segmentGroup) {
					return _local3.value;
				}
				_local2++;
			}
			return null;
		}
		
		public function refresh(callback:Function = null, errorHandler:Function = null) : void {
			_playerInsightRefresh(function(param1:PlayerInsightState):void {
				_state = param1;
				if(callback != null) {
					callback();
				}
			},errorHandler);
		}
		
		public function setSegments(segments:Array, callback:Function = null, errorHandler:Function = null) : void {
			_playerInsightSetSegments(segments,function(param1:PlayerInsightState):void {
				_state = param1;
				if(callback != null) {
					callback();
				}
			},errorHandler);
		}
		
		public function trackInvitedBy(invitingUserId:String, invitationChannel:String, callback:Function = null, errorHandler:Function = null) : void {
			_playerInsightTrackInvitedBy(invitingUserId,invitationChannel,callback,errorHandler);
		}
		
		public function trackEvents(events:Array, callback:Function = null, errorHandler:Function = null) : void {
			var _local5:int = 0;
			var _local6:PlayerInsightEvent = null;
			var _local4:Array = [];
			_local5 = 0;
			while(_local5 < events.length) {
				_local6 = new PlayerInsightEvent();
				_local6.eventType = events[_local5];
				_local6.value = events[_local5 + 1];
				_local4.push(_local6);
				_local5 += 2;
			}
			_playerInsightTrackEvents(_local4,callback,errorHandler);
		}
		
		public function trackExternalPayment(currency:String, amount:int, callback:Function = null, errorHandler:Function = null) : void {
			_playerInsightTrackExternalPayment(currency,amount,callback,errorHandler);
		}
	}
}

