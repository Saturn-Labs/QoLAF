package com.google.analytics.debug {
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Info extends Label {
		private var _timer:Timer;
		
		public function Info(text:String = "", timeout:uint = 3000) {
			super(text,"uiInfo",Style.infoColor,Align.top,true);
			if(timeout > 0) {
				this._timer = new Timer(timeout,1);
				this._timer.start();
				this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onComplete,false,0,true);
			}
		}
		
		public function close() : void {
			if(parent != null) {
				parent.removeChild(this);
			}
		}
		
		override public function onLink(event:TextEvent) : void {
			switch(event.text) {
				case "hide":
					this.close();
			}
		}
		
		public function onComplete(event:TimerEvent) : void {
			this.close();
		}
	}
}

