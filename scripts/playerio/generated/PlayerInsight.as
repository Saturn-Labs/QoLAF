package playerio.generated {
	import flash.events.EventDispatcher;
	import playerio.Client;
	import playerio.generated.messages.PlayerInsightRefreshArgs;
	import playerio.generated.messages.PlayerInsightRefreshError;
	import playerio.generated.messages.PlayerInsightRefreshOutput;
	import playerio.generated.messages.PlayerInsightSessionKeepAliveArgs;
	import playerio.generated.messages.PlayerInsightSessionKeepAliveError;
	import playerio.generated.messages.PlayerInsightSessionKeepAliveOutput;
	import playerio.generated.messages.PlayerInsightSessionStopArgs;
	import playerio.generated.messages.PlayerInsightSessionStopError;
	import playerio.generated.messages.PlayerInsightSessionStopOutput;
	import playerio.generated.messages.PlayerInsightSetSegmentsArgs;
	import playerio.generated.messages.PlayerInsightSetSegmentsError;
	import playerio.generated.messages.PlayerInsightSetSegmentsOutput;
	import playerio.generated.messages.PlayerInsightTrackEventsArgs;
	import playerio.generated.messages.PlayerInsightTrackEventsError;
	import playerio.generated.messages.PlayerInsightTrackEventsOutput;
	import playerio.generated.messages.PlayerInsightTrackExternalPaymentArgs;
	import playerio.generated.messages.PlayerInsightTrackExternalPaymentError;
	import playerio.generated.messages.PlayerInsightTrackExternalPaymentOutput;
	import playerio.generated.messages.PlayerInsightTrackInvitedByArgs;
	import playerio.generated.messages.PlayerInsightTrackInvitedByError;
	import playerio.generated.messages.PlayerInsightTrackInvitedByOutput;
	import playerio.utils.HTTPChannel;
	
	public class PlayerInsight extends EventDispatcher {
		protected var channel:HTTPChannel;
		
		protected var client:Client;
		
		public function PlayerInsight(channel:HTTPChannel, client:Client) {
			super();
			this.channel = channel;
			this.client = client;
		}
		
		protected function _playerInsightRefresh(callback:Function = null, errorHandler:Function = null) : void {
			var input:PlayerInsightRefreshArgs = new PlayerInsightRefreshArgs();
			var output:PlayerInsightRefreshOutput = new PlayerInsightRefreshOutput();
			channel.Request(301,input,output,new PlayerInsightRefreshError(),function(param1:PlayerInsightRefreshOutput):void {
				if(callback != null) {
					try {
						callback(param1.state);
					}
					catch(e:Error) {
						client.handleCallbackError("PlayerInsight.playerInsightRefresh",e);
						throw e;
					}
				}
			},function(param1:PlayerInsightRefreshError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _playerInsightSetSegments(segments:Array, callback:Function = null, errorHandler:Function = null) : void {
			var input:PlayerInsightSetSegmentsArgs = new PlayerInsightSetSegmentsArgs(segments);
			var output:PlayerInsightSetSegmentsOutput = new PlayerInsightSetSegmentsOutput();
			channel.Request(304,input,output,new PlayerInsightSetSegmentsError(),function(param1:PlayerInsightSetSegmentsOutput):void {
				if(callback != null) {
					try {
						callback(param1.state);
					}
					catch(e:Error) {
						client.handleCallbackError("PlayerInsight.playerInsightSetSegments",e);
						throw e;
					}
				}
			},function(param1:PlayerInsightSetSegmentsError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _playerInsightTrackInvitedBy(invitingUserId:String, invitationChannel:String, callback:Function = null, errorHandler:Function = null) : void {
			var input:PlayerInsightTrackInvitedByArgs = new PlayerInsightTrackInvitedByArgs(invitingUserId,invitationChannel);
			var output:PlayerInsightTrackInvitedByOutput = new PlayerInsightTrackInvitedByOutput();
			channel.Request(307,input,output,new PlayerInsightTrackInvitedByError(),function(param1:PlayerInsightTrackInvitedByOutput):void {
				if(callback != null) {
					try {
						callback();
					}
					catch(e:Error) {
						client.handleCallbackError("PlayerInsight.playerInsightTrackInvitedBy",e);
						throw e;
					}
				}
			},function(param1:PlayerInsightTrackInvitedByError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _playerInsightTrackEvents(events:Array, callback:Function = null, errorHandler:Function = null) : void {
			var input:PlayerInsightTrackEventsArgs = new PlayerInsightTrackEventsArgs(events);
			var output:PlayerInsightTrackEventsOutput = new PlayerInsightTrackEventsOutput();
			channel.Request(311,input,output,new PlayerInsightTrackEventsError(),function(param1:PlayerInsightTrackEventsOutput):void {
				if(callback != null) {
					try {
						callback();
					}
					catch(e:Error) {
						client.handleCallbackError("PlayerInsight.playerInsightTrackEvents",e);
						throw e;
					}
				}
			},function(param1:PlayerInsightTrackEventsError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _playerInsightTrackExternalPayment(currency:String, amount:int, callback:Function = null, errorHandler:Function = null) : void {
			var input:PlayerInsightTrackExternalPaymentArgs = new PlayerInsightTrackExternalPaymentArgs(currency,amount);
			var output:PlayerInsightTrackExternalPaymentOutput = new PlayerInsightTrackExternalPaymentOutput();
			channel.Request(314,input,output,new PlayerInsightTrackExternalPaymentError(),function(param1:PlayerInsightTrackExternalPaymentOutput):void {
				if(callback != null) {
					try {
						callback();
					}
					catch(e:Error) {
						client.handleCallbackError("PlayerInsight.playerInsightTrackExternalPayment",e);
						throw e;
					}
				}
			},function(param1:PlayerInsightTrackExternalPaymentError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		public function playerInsightSessionKeepAlive(callback:Function = null, errorHandler:Function = null) : void {
			var input:PlayerInsightSessionKeepAliveArgs = new PlayerInsightSessionKeepAliveArgs();
			var output:PlayerInsightSessionKeepAliveOutput = new PlayerInsightSessionKeepAliveOutput();
			channel.Request(317,input,output,new PlayerInsightSessionKeepAliveError(),function(param1:PlayerInsightSessionKeepAliveOutput):void {
				if(callback != null) {
					try {
						callback();
					}
					catch(e:Error) {
						client.handleCallbackError("PlayerInsight.playerInsightSessionKeepAlive",e);
						throw e;
					}
				}
			},function(param1:PlayerInsightSessionKeepAliveError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		public function playerInsightSessionStop(callback:Function = null, errorHandler:Function = null) : void {
			var input:PlayerInsightSessionStopArgs = new PlayerInsightSessionStopArgs();
			var output:PlayerInsightSessionStopOutput = new PlayerInsightSessionStopOutput();
			channel.Request(320,input,output,new PlayerInsightSessionStopError(),function(param1:PlayerInsightSessionStopOutput):void {
				if(callback != null) {
					try {
						callback();
					}
					catch(e:Error) {
						client.handleCallbackError("PlayerInsight.playerInsightSessionStop",e);
						throw e;
					}
				}
			},function(param1:PlayerInsightSessionStopError):void {
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

