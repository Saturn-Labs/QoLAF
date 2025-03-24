package playerio {
	import playerio.generated.Notifications;
	import playerio.generated.PlayerIOError;
	import playerio.generated.messages.Notification;
	import playerio.generated.messages.NotificationsEndpoint;
	import playerio.generated.messages.NotificationsEndpointId;
	import playerio.utils.Converter;
	import playerio.utils.HTTPChannel;
	import playerio.utils.Utilities;
	
	public class Notifications extends playerio.generated.Notifications {
		private var _version:String;
		
		private var _myNotifications:Array;
		
		public function Notifications(channel:HTTPChannel, client:Client) {
			super(channel,client);
		}
		
		public function get myNotifications() : Array {
			if(_myNotifications == null) {
				throw new playerio.generated.PlayerIOError("Cannot access \'myNotifications\' before refresh() is called.",playerio.PlayerIOError.NotificationsNotLoaded.errorID);
			}
			return _myNotifications;
		}
		
		public function refresh(callback:Function, errorCallback:Function) : void {
			_notificationsRefresh(_version,function(param1:String, param2:Array):void {
				refreshed(param1,param2);
				if(callback != null) {
					callback();
				}
			},errorCallback);
		}
		
		private function refreshed(version:String, notificationEndpointArray:Array) : void {
			var _local5:int = 0;
			var _local3:NotificationEndpoint = null;
			var _local4:Array = [];
			if(this._version != version) {
				this._version = version;
				if(notificationEndpointArray != null) {
					_local5 = 0;
					while(_local5 < notificationEndpointArray.length) {
						_local3 = new NotificationEndpoint();
						_local3._internal_initialize(notificationEndpointArray[_local5]);
						_local4.push(_local3);
						_local5++;
					}
				}
				this._myNotifications = _local4;
			}
		}
		
		public function registerEndpoints(endpointType:String, identifier:String, configuration:Object, enabled:Boolean, callback:Function, errorCallback:Function) : void {
			var newEndpoint:NotificationsEndpoint;
			var current:NotificationEndpoint = get(endpointType,identifier);
			if(current == null || current.endabled != enabled || !areEqual(current.configuration,configuration)) {
				newEndpoint = createChannelNotificationEndpoint(endpointType,identifier,configuration,enabled);
				_notificationsRegisterEndpoints(_version,[newEndpoint],function(param1:String, param2:Array):void {
					refreshed(param1,param2);
					if(callback != null) {
						callback();
					}
				},errorCallback);
			} else if(callback != null) {
				callback();
			}
		}
		
		public function send(notifications:Array, callback:Function, errorCallback:Function) : void {
			if(notifications.length > 0) {
				_notificationsSend(convertNotification(notifications),callback,errorCallback);
			} else if(callback != null) {
				callback();
			}
		}
		
		public function toggleEndpoints(endpoints:Array, enable:Boolean, callback:Function, errorCallback:Function) : void {
			var ids:Array = convertNotificationEndpoint(endpoints);
			if(ids.length > 0) {
				_notificationsToggleEndpoints(this._version,ids,enable,function(param1:String, param2:Array):void {
					refreshed(param1,param2);
					if(callback != null) {
						callback();
					}
				},errorCallback);
			} else if(callback != null) {
				callback();
			}
		}
		
		public function deleteEndpoints(endpoints:Array, callback:Function, errorCallback:Function) : void {
			var ids:Array = convertNotificationEndpoint(endpoints);
			if(ids.length > 0) {
				_notificationsDeleteEndpoints(this._version,ids,function(param1:String, param2:Array):void {
					refreshed(param1,param2);
					if(callback != null) {
						callback();
					}
				},errorCallback);
			} else if(callback != null) {
				callback();
			}
		}
		
		private function createChannelNotificationEndpoint(endpointType:String, identifier:String, configuration:Object, enabled:Boolean) : NotificationsEndpoint {
			var _local5:NotificationsEndpoint = new NotificationsEndpoint();
			_local5.configuration = Converter.toKeyValueArray(configuration);
			_local5.type = endpointType;
			_local5.identifier = identifier;
			_local5.enabled = enabled;
			return _local5;
		}
		
		private function get(endpointType:String, identifier:String) : NotificationEndpoint {
			return _myNotifications == null ? null : Utilities.find(_myNotifications,function(param1:NotificationEndpoint):Boolean {
				if(param1.identifier == identifier && param1.type == endpointType) {
					return true;
				}
				return false;
			}) as NotificationEndpoint;
		}
		
		private function areEqual(a:Object, b:Object) : Boolean {
			if(Utilities.countKeys(a) == Utilities.countKeys(b)) {
				for(var _local3 in a) {
					if(a[_local3] != b[_local3]) {
						return false;
					}
				}
				return true;
			}
			return false;
		}
		
		private function convertNotification(notifications:Array) : Array {
			var _local5:int = 0;
			var _local2:playerio.generated.messages.Notification = null;
			var _local3:playerio.Notification = null;
			var _local4:Array = [];
			_local5 = 0;
			while(_local5 < notifications.length) {
				_local2 = new playerio.generated.messages.Notification();
				_local3 = notifications[_local5] as playerio.Notification;
				_local2.data = Converter.getObjectProperties(_local3.data);
				_local2.recipient = _local3.recipientUserId;
				_local2.endpointType = _local3.endpointType;
				_local4.push(_local2);
				_local5++;
			}
			return _local4;
		}
		
		private function convertNotificationEndpoint(endpoints:Array) : Array {
			var _local4:int = 0;
			var _local3:NotificationsEndpointId = null;
			var _local2:Array = [];
			if(endpoints == null) {
				return _local2;
			}
			_local4 = 0;
			while(_local4 < endpoints.length) {
				_local3 = new NotificationsEndpointId();
				_local3.identifier = (endpoints[_local4] as NotificationEndpoint).identifier;
				_local3.type = (endpoints[_local4] as NotificationEndpoint).type;
				_local2.push(_local3);
				_local4++;
			}
			return _local2;
		}
	}
}

