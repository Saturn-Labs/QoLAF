package core.queue {
	import core.hud.components.dialogs.QueuePopupMessage;
	import core.scene.Game;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class QueueInfoHolder {
		private static var TIMELIMIT:int = 20;
		
		private var g:Game;
		
		public var type:String;
		
		public var startTime:Number;
		
		public var avgTime:Number;
		
		public var isWaiting:Boolean;
		
		public var isInQueue:Boolean;
		
		public var isReady:Boolean;
		
		public var accepted:Boolean;
		
		public var roomId:String;
		
		public var solarSystem:String;
		
		private var acceptPopup:QueuePopupMessage;
		
		public function QueueInfoHolder(g:Game, type:String) {
			super();
			this.g = g;
			this.type = type;
			isWaiting = false;
			isInQueue = false;
			isReady = false;
			accepted = false;
			startTime = 0;
		}
		
		public function update() : void {
			if(acceptPopup != null) {
				acceptPopup.updateTime(getTimeout());
			}
		}
		
		public function getTime() : String {
			var _local3:Number = (g.time - startTime) / 1000;
			if(startTime == 0) {
				return "0:00";
			}
			var _local2:int = _local3;
			var _local1:int = _local2 % (60);
			_local2 = (_local2 - _local1) / (60);
			if(_local1 < 10) {
				return _local2 + ":0" + _local1;
			}
			return _local2 + ":" + _local1;
		}
		
		public function getTimeout() : String {
			var _local1:int = (startTime + TIMELIMIT * 1000 - g.time) / 1000;
			if(_local1 < 0) {
				if(acceptPopup != null) {
					acceptPopup.accept();
					acceptPopup = null;
				}
				isWaiting = true;
				isInQueue = false;
				isReady = false;
				accepted = false;
				return "00";
			}
			if(_local1 < 10) {
				return "0" + _local1;
			}
			return _local1.toString();
		}
		
		public function createAcceptPopup() : void {
			var soundManager:ISound;
			if(g.isLeaving) {
				return;
			}
			acceptPopup = new QueuePopupMessage(type);
			acceptPopup.setPopupText(getTimeout());
			soundManager = SoundLocator.getService();
			soundManager.preCacheSound("MFyIFZhNA0mso-deTlOpYg",function():void {
				soundManager.play("MFyIFZhNA0mso-deTlOpYg");
			});
			acceptPopup.addEventListener("accept",function():void {
				isWaiting = true;
				accepted = true;
				g.sendToServiceRoom("acceptMatch",type);
				acceptPopup.removeEventListeners();
				g.removeChildFromOverlay(acceptPopup,true);
				acceptPopup = null;
				Game.trackEvent("pvp","queue","accepted",g.me.level);
			});
			acceptPopup.addEventListener("close",function():void {
				acceptPopup.removeEventListeners();
				g.sendToServiceRoom("declineMatch",type);
				isWaiting = false;
				isInQueue = false;
				isReady = false;
				accepted = false;
				startTime = 0;
				g.removeChildFromOverlay(acceptPopup,true);
				acceptPopup = null;
				Game.trackEvent("pvp","queue","declined",g.me.level);
			});
			g.addChildToOverlay(acceptPopup);
			if(g.hud) {
				g.hud.resize();
			}
		}
	}
}

