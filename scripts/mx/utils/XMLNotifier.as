package mx.utils {
	import flash.utils.Dictionary;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class XMLNotifier {
		private static var instance:XMLNotifier;
		
		mx_internal static const VERSION:String = "4.6.0.23201";
		
		public function XMLNotifier(x:XMLNotifierSingleton) {
			super();
		}
		
		public static function getInstance() : XMLNotifier {
			if(!instance) {
				instance = new XMLNotifier(new XMLNotifierSingleton());
			}
			return instance;
		}
		
		mx_internal static function initializeXMLForNotification() : Function {
			var notificationFunction:Function = function(currentTarget:Object, ty:String, tar:Object, value:Object, detail:Object):void {
				var _local8:Object = null;
				var _local7:Dictionary = arguments.callee.watched;
				if(_local7 != null) {
					for(_local8 in _local7) {
						IXMLNotifiable(_local8).xmlNotification(currentTarget,ty,tar,value,detail);
					}
				}
			};
			return notificationFunction;
		}
		
		public function watchXML(xml:Object, notifiable:IXMLNotifiable, uid:String = null) : void {
			var _local4:Object = null;
			var _local5:XML = null;
			var _local6:Object = null;
			var _local7:Dictionary = null;
			if(xml is XMLList && xml.length() > 1) {
				for each(_local4 in xml) {
					this.watchXML(_local4,notifiable,uid);
				}
			} else {
				_local5 = XML(xml);
				_local6 = _local5.notification();
				if(!(_local6 is Function)) {
					_local6 = mx_internal::initializeXMLForNotification();
					_local5.setNotification(_local6 as Function);
					if(Boolean(uid) && _local6["uid"] == null) {
						_local6["uid"] = uid;
					}
				}
				if(_local6["watched"] == undefined) {
					_local6["watched"] = _local7 = new Dictionary(true);
				} else {
					_local7 = _local6["watched"];
				}
				_local7[notifiable] = true;
			}
		}
		
		public function unwatchXML(xml:Object, notifiable:IXMLNotifiable) : void {
			var _local3:Object = null;
			var _local4:XML = null;
			var _local5:Object = null;
			var _local6:Dictionary = null;
			if(xml is XMLList && xml.length() > 1) {
				for each(_local3 in xml) {
					this.unwatchXML(_local3,notifiable);
				}
			} else {
				_local4 = XML(xml);
				_local5 = _local4.notification();
				if(!(_local5 is Function)) {
					return;
				}
				if(_local5["watched"] != undefined) {
					_local6 = _local5["watched"];
					delete _local6[notifiable];
				}
			}
		}
	}
}

class XMLNotifierSingleton {
	public function XMLNotifierSingleton() {
		super();
	}
}
