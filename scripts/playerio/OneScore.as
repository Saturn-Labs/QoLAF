package playerio {
	import playerio.generated.OneScore;
	import playerio.generated.messages.OneScoreValue;
	import playerio.utils.HTTPChannel;
	
	public class OneScore extends playerio.generated.OneScore {
		private var _value:playerio.OneScoreValue;
		
		public function OneScore(channel:HTTPChannel, client:Client) {
			super(channel,client);
		}
		
		public function get score() : int {
			if(_value == null) {
				throw new PlayerIOError("Cannot access Score before Refresh() has been called.",PlayerIOError.OneScoreNotLoaded.errorID);
			}
			return _value.score;
		}
		
		public function get percentile() : Number {
			if(_value == null) {
				throw new PlayerIOError("Cannot access Percentile before Refresh() has been called.",PlayerIOError.OneScoreNotLoaded.errorID);
			}
			return _value.percentile;
		}
		
		public function get topRank() : int {
			if(_value == null) {
				throw new PlayerIOError("Cannot access TopRank before Refresh() has been called.",PlayerIOError.OneScoreNotLoaded.errorID);
			}
			return _value.topRank;
		}
		
		private function processOneScoreValue(oneScoreValue:playerio.generated.messages.OneScoreValue, callback:Function = null) : void {
			var _local3:playerio.OneScoreValue = convertOneScoreValue2ClientOneScoreValue(oneScoreValue);
			this._value = _local3;
			if(callback != null) {
				callback();
			}
		}
		
		private function convertOneScoreValue2ClientOneScoreValue(oneScoreValue:playerio.generated.messages.OneScoreValue) : playerio.OneScoreValue {
			var _local2:playerio.OneScoreValue = new playerio.OneScoreValue();
			_local2._internal_initialize(oneScoreValue);
			return _local2;
		}
		
		public function refresh(callback:Function = null, errorHandler:Function = null) : void {
			_oneScoreRefresh(function(param1:playerio.generated.messages.OneScoreValue):void {
				processOneScoreValue(param1,callback);
			},errorHandler);
		}
		
		public function set(score:int, callback:Function = null, errorHandler:Function = null) : void {
			_oneScoreSet(score,function(param1:playerio.generated.messages.OneScoreValue):void {
				processOneScoreValue(param1,callback);
			},errorHandler);
		}
		
		public function add(score:int, callback:Function = null, errorHandler:Function = null) : void {
			_oneScoreAdd(score,function(param1:playerio.generated.messages.OneScoreValue):void {
				processOneScoreValue(param1,callback);
			},errorHandler);
		}
		
		public function load(userIds:Array, callback:Function = null, errorHandler:Function = null) : void {
			_oneScoreLoad(userIds,function(param1:Array):void {
				var _local4:int = 0;
				var _local2:int = 0;
				var _local3:Array = [];
				_local4 = 0;
				while(_local4 < userIds.length) {
					if(_local2 < param1.length && userIds[_local4] == playerio.generated.messages.OneScoreValue(param1[_local2]).userId) {
						_local3.push(convertOneScoreValue2ClientOneScoreValue(param1[_local2]));
						_local2++;
					} else {
						_local3.push(null);
					}
					_local4++;
				}
				if(callback != null) {
					callback(_local3);
				}
			},errorHandler);
		}
	}
}

