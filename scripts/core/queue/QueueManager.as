package core.queue {
	import core.hud.components.dialogs.PopupMessage;
	import core.scene.Game;
	import playerio.Message;
	import starling.events.Event;
	
	public class QueueManager {
		public static const TYPE_PVP:String = "pvp";
		
		public static const TYPE_PVP_DM:String = "pvp dm";
		
		public static const TYPE_PVP_DOMINATION:String = "pvp dom";
		
		public static const TYPE_PVP_ARENA:String = "pvp arena";
		
		public static const TYPE_PVP_ARENA_RANKED:String = "pvp arena ranked";
		
		public static const TYPE_PVP_RANDOM:String = "pvp random";
		
		public static const TYPE_INSTANCE:String = "instance";
		
		public var g:Game;
		
		public var queues:Vector.<QueueInfoHolder>;
		
		public function QueueManager(g:Game) {
			super();
			this.g = g;
			queues = new Vector.<QueueInfoHolder>();
			queues.push(new QueueInfoHolder(g,"pvp random"));
			g.addServiceMessageHandler("QueueJoinSuccess",joinedQueue);
			g.addServiceMessageHandler("QueueJoinFailed",joinFailed);
			g.addServiceMessageHandler("QueueLeaveSuccess",leftQueue);
			g.addServiceMessageHandler("QueueLeaveFailed",leaveFailed);
			g.addServiceMessageHandler("QueueReady",queueReady);
			g.addServiceMessageHandler("JoinMatch",joinMatch);
			g.addServiceMessageHandler("QueueRemoved",removedFromQueue);
			g.rpcServiceRoom("RequestQueueInfo",handleQueueInfo);
		}
		
		public function handleQueueInfo(m:Message) : void {
			var _local4:int = 0;
			var _local6:String = null;
			var _local2:Boolean = false;
			var _local5:Number = NaN;
			var _local3:QueueInfoHolder = null;
			_local4 = 0;
			while(_local4 < m.length - 2) {
				_local6 = m.getString(_local4);
				_local2 = m.getBoolean(_local4 + 1);
				_local5 = m.getNumber(_local4 + 2);
				if(_local2) {
					_local3 = getQueue(_local6);
					_local3.isInQueue = true;
					_local3.isWaiting = false;
					_local3.isReady = false;
					_local3.accepted = false;
					_local3.startTime = _local5;
				}
				_local4 += 3;
			}
		}
		
		public function removedFromAllQueues() : void {
			for each(var _local1 in queues) {
				_local1.isInQueue = false;
				_local1.isWaiting = false;
				_local1.isReady = false;
			}
		}
		
		public function removedFromQueue(m:Message) : void {
			var _local3:String = m.getString(0);
			for each(var _local2 in queues) {
				if(_local2.type == _local3) {
					_local2.isInQueue = false;
					_local2.isWaiting = false;
					_local2.isReady = false;
				}
			}
		}
		
		public function queueReady(m:Message) : void {
			var _local3:int = 0;
			var _local4:String = m.getString(0);
			for each(var _local2 in queues) {
				if(_local2.type == _local4) {
					_local3 = Math.ceil(0.001 * (g.time - _local2.startTime));
					if(_local3 > 0 && _local3 < 1000000) {
						Game.trackEvent("pvp","queue","ready",_local3);
					}
					_local2.startTime = g.time;
					_local2.isInQueue = false;
					_local2.isWaiting = false;
					_local2.isReady = true;
					_local2.createAcceptPopup();
					break;
				}
			}
		}
		
		public function joinMatch(m:Message) : void {
			var _local2:String = m.getString(0);
			var _local4:String = m.getString(1);
			var _local3:String = m.getString(2);
			g.tryJoinMatch(_local4,_local3);
		}
		
		public function joinedQueue(m:Message) : void {
			var errorPopup:PopupMessage;
			var qi:QueueInfoHolder;
			var type:String = m.getString(0);
			var reason:String = m.getString(1);
			var resetOthers:Boolean = m.getBoolean(2);
			if(reason != null && reason != "") {
				errorPopup = new PopupMessage();
				errorPopup.text = reason;
				g.addChildToOverlay(errorPopup);
				errorPopup.addEventListener("close",(function():* {
					var closePopup:Function;
					return closePopup = function(param1:Event):void {
						g.removeChildFromOverlay(errorPopup);
						errorPopup.removeEventListeners();
					};
				})());
			}
			for each(qi in queues) {
				if(qi.type == type) {
					qi.startTime = g.time;
					qi.isInQueue = true;
					qi.isWaiting = false;
					qi.isReady = false;
					qi.accepted = false;
					qi.startTime = g.time;
				}
			}
		}
		
		public function joinFailed(m:Message) : void {
			var errorPopup:PopupMessage;
			var qi:QueueInfoHolder;
			var type:String = m.getString(0);
			var reason:String = m.getString(1);
			if(reason != null && reason != "") {
				errorPopup = new PopupMessage();
				errorPopup.text = reason;
				g.addChildToOverlay(errorPopup);
				errorPopup.addEventListener("close",(function():* {
					var closePopup:Function;
					return closePopup = function(param1:Event):void {
						g.removeChildFromOverlay(errorPopup);
						errorPopup.removeEventListeners();
					};
				})());
			}
			for each(qi in queues) {
				if(qi.type == type) {
					qi.isWaiting = false;
					qi.isInQueue = false;
					qi.accepted = false;
					qi.isReady = false;
					qi.update();
				}
			}
		}
		
		public function update() : void {
			for each(var _local1 in queues) {
				_local1.update();
			}
		}
		
		public function leftQueue(m:Message) : void {
			var _local3:String = m.getString(0);
			for each(var _local2 in queues) {
				if(_local2.type == _local3) {
					_local2.isInQueue = false;
					_local2.isWaiting = false;
					_local2.isReady = false;
				}
			}
		}
		
		public function leaveFailed(m:Message) : void {
			var _local3:String = m.getString(0);
			for each(var _local2 in queues) {
				if(_local2.type == _local3) {
					_local2.isInQueue = false;
					_local2.isWaiting = false;
					_local2.isReady = false;
				}
			}
		}
		
		public function getQueue(type:String) : QueueInfoHolder {
			for each(var _local2 in queues) {
				if(_local2.type == type) {
					return _local2;
				}
			}
			return null;
		}
		
		private function containsQueue(type:String) : Boolean {
			for each(var _local2 in queues) {
				if(_local2.type == type) {
					return true;
				}
			}
			return false;
		}
	}
}

