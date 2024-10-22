package
{
	import flash.utils.getTimer;
	import playerio.Client;
	import playerio.Connection;
	import playerio.Message;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class Clock extends EventDispatcher
	{
		public static const CLOCK_READY:String = "clockReady";
		
		private var connection:Connection;
		
		private var client:Client;
		
		private var deltas:Array;
		
		private var responsePending:Boolean;
		
		private var lockedInServerTime:Boolean;
		
		private var timeRequestSent:Number;
		
		private var syncTimeDelta:Number = 0;
		
		private var maxDeltas:Number;
		
		private var latencyError:Number;
		
		public var latency:Number;
		
		private var beginning:Number;
		
		public function Clock(param1:Connection, param2:Client)
		{
			super();
			this.connection = param1;
			this.client = param2;
			maxDeltas = 10;
			beginning = getTimer();
		}
		
		public function start():void
		{
			deltas = [];
			lockedInServerTime = false;
			responsePending = false;
			connection.addMessageHandler("serverTime", onServerTime);
			requestServerTime();
		}
		
		private function requestServerTime():void
		{
			if (!responsePending)
			{
				connection.send("timeRequest", client.connectUserId);
				responsePending = true;
				timeRequestSent = getTimer();
			}
		}
		
		private function onServerTime(param1:Message):void
		{
			responsePending = false;
			var _loc2_:Number = param1.getNumber(0);
			addTimeDelta(timeRequestSent, getTimer(), _loc2_);
			if (deltas.length == maxDeltas)
			{
				dispatchEvent(new Event("clockReady"));
				connection.removeMessageHandler("serverTime", onServerTime);
			}
			else
			{
				requestServerTime();
			}
		}
		
		public function getServerTime():Number
		{
			var _loc1_:Number = getTimer();
			return _loc1_ + syncTimeDelta;
		}
		
		public function addTimeDelta(param1:Number, param2:Number, param3:Number):void
		{
			var _loc5_:Number = (param2 - param1) / 2;
			var _loc7_:Number = param3 - param2;
			var _loc4_:Number = _loc7_ + _loc5_;
			var _loc6_:TimeDelta = new TimeDelta(_loc5_, _loc4_);
			deltas.push(_loc6_);
			if (deltas.length > maxDeltas)
			{
				deltas.shift();
			}
			recalculate();
		}
		
		private function recalculate():void
		{
			var _loc2_:Number = NaN;
			var _loc3_:Array = deltas.slice(0);
			_loc3_.sort(compare);
			var _loc1_:Number = determineMedian(_loc3_);
			pruneOutliers(_loc3_, _loc1_, 1.5);
			latency = determineAverageLatency(_loc3_);
			if (!lockedInServerTime)
			{
				_loc2_ = determineAverage(_loc3_);
				syncTimeDelta = Math.round(_loc2_);
				lockedInServerTime = deltas.length == maxDeltas;
			}
		}
		
		private function determineAverage(param1:Array):Number
		{
			var _loc4_:Number = NaN;
			var _loc3_:TimeDelta = null;
			var _loc2_:Number = 0;
			_loc4_ = 0;
			while (_loc4_ < param1.length)
			{
				_loc3_ = param1[_loc4_];
				_loc2_ += _loc3_.timeSyncDelta;
				_loc4_++;
			}
			return _loc2_ / param1.length;
		}
		
		private function determineAverageLatency(param1:Array):Number
		{
			var _loc5_:Number = NaN;
			var _loc3_:TimeDelta = null;
			var _loc2_:Number = 0;
			_loc5_ = 0;
			while (_loc5_ < param1.length)
			{
				_loc3_ = param1[_loc5_];
				_loc2_ += _loc3_.latency;
				_loc5_++;
			}
			var _loc4_:Number = _loc2_ / param1.length;
			latencyError = Math.abs(TimeDelta(param1[param1.length - 1]).latency - _loc4_);
			return _loc4_;
		}
		
		private function pruneOutliers(param1:Array, param2:Number, param3:Number):void
		{
			var _loc5_:Number = NaN;
			var _loc4_:TimeDelta = null;
			var _loc6_:Number = param2 * param3;
			_loc5_ = param1.length - 1;
			while (_loc5_ >= 0)
			{
				_loc4_ = param1[_loc5_];
				if (_loc4_.latency <= _loc6_)
				{
					break;
				}
				param1.splice(_loc5_, 1);
				_loc5_--;
			}
		}
		
		private function determineMedian(param1:Array):Number
		{
			var _loc2_:Number = NaN;
			if (param1.length % 2 == 0)
			{
				_loc2_ = param1.length / 2 - 1;
				return (param1[_loc2_].latency + param1[_loc2_ + 1].latency) / 2;
			}
			_loc2_ = Math.floor(param1.length / 2);
			return param1[_loc2_].latency;
		}
		
		private function compare(param1:TimeDelta, param2:TimeDelta):Number
		{
			if (param1.latency < param2.latency)
			{
				return -1;
			}
			if (param1.latency > param2.latency)
			{
				return 1;
			}
			return 0;
		}
		
		public function get time():Number
		{
			var _loc1_:Number = getTimer();
			return _loc1_ + syncTimeDelta;
		}
		
		public function get elapsedTime():Number
		{
			return getTimer() - beginning;
		}
	}
}
