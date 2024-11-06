package core.queue
{
	import core.hud.components.dialogs.QueuePopupMessage;
	import core.scene.Game;
	import sound.ISound;
	import sound.SoundLocator;

	public class QueueInfoHolder
	{
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
		public function QueueInfoHolder(param1:Game, param2:String)
		{
			super();
			this.g = param1;
			this.type = param2;
			isWaiting = false;
			isInQueue = false;
			isReady = false;
			accepted = false;
			startTime = 0;
		}

		public function update():void
		{
			if (acceptPopup != null)
			{
				acceptPopup.updateTime(getTimeout());
			}
		}

		public function getTime():String
		{
			var _loc2_:Number = (g.time - startTime) / 1000;
			if (startTime == 0)
			{
				return "0:00";
			}
			var _loc1_:int = _loc2_;
			var _loc3_:int = _loc1_ % 60;
			_loc1_ = (_loc1_ - _loc3_) / 60;
			if (_loc3_ < 10)
			{
				return _loc1_ + ":0" + _loc3_;
			}
			return _loc1_ + ":" + _loc3_;
		}

		public function getTimeout():String
		{
			var _loc1_:int = (startTime + TIMELIMIT * 1000 - g.time) / 1000;
			if (_loc1_ < 0)
			{
				if (acceptPopup != null)
				{
					acceptPopup.accept();
					acceptPopup = null;
				}
				isWaiting = true;
				isInQueue = false;
				isReady = false;
				accepted = false;
				return "00";
			}
			if (_loc1_ < 10)
			{
				return "0" + _loc1_;
			}
			return _loc1_.toString();
		}

		public function createAcceptPopup():void
		{
			var soundManager:ISound;
			if (g.isLeaving)
			{
				return;
			}
			acceptPopup = new QueuePopupMessage(type);
			acceptPopup.setPopupText(getTimeout());
			soundManager = SoundLocator.getService();
			soundManager.preCacheSound("MFyIFZhNA0mso-deTlOpYg", function():void
				{
					soundManager.play("MFyIFZhNA0mso-deTlOpYg");
				});
			acceptPopup.addEventListener("accept", function():void
				{
					isWaiting = true;
					accepted = true;
					g.sendToServiceRoom("acceptMatch", type);
					acceptPopup.removeEventListeners();
					g.removeChildFromOverlay(acceptPopup, true);
					acceptPopup = null;
					Game.trackEvent("pvp", "queue", "accepted", g.me.level);
				});
			acceptPopup.addEventListener("close", function():void
				{
					acceptPopup.removeEventListeners();
					g.sendToServiceRoom("declineMatch", type);
					isWaiting = false;
					isInQueue = false;
					isReady = false;
					accepted = false;
					startTime = 0;
					g.removeChildFromOverlay(acceptPopup, true);
					acceptPopup = null;
					Game.trackEvent("pvp", "queue", "declined", g.me.level);
				});
			g.addChildToOverlay(acceptPopup);
			if (g.hud)
			{
				g.hud.resize();
			}
		}
	}
}
