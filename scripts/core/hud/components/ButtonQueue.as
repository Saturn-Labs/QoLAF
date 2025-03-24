package core.hud.components {
	import core.queue.QueueInfoHolder;
	import core.scene.Game;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	
	public class ButtonQueue extends Sprite {
		private var joinQueue:Button;
		
		private var leaveQueue:Button;
		
		private var acceptQueue:Button;
		
		private var tmpButton:Button;
		
		private var type:String;
		
		private var queueInfo:QueueInfoHolder;
		
		private var g:Game;
		
		public function ButtonQueue(g:Game, type:String, qi:QueueInfoHolder, avilable:Boolean = true) {
			this.g = g;
			this.type = type;
			queueInfo = qi;
			super();
			if(!avilable) {
				touchable = false;
				joinQueue = new Button(join,Localize.t("Currently Unavailable"),"negative");
			} else if(type == "pvp arena" && g.me.level < 80) {
				touchable = false;
				joinQueue = new Button(join,Localize.t("Requries lvl 80"),"negative");
			} else if(g.me.level < 1) {
				touchable = false;
				joinQueue = new Button(join,Localize.t("Requries lvl 1"),"negative");
			} else if(g.me.level > 150) {
				touchable = false;
				joinQueue = new Button(join,Localize.t("Stop cheating!"),"negative");
			} else {
				joinQueue = new Button(join,Localize.t("Join Queue!"),"positive");
			}
			leaveQueue = new Button(leave,"In Queue: xx, Leave?","positive");
			acceptQueue = new Button(accept,"Match Ready: xx, Accept?","positive");
			tmpButton = new Button(wait,Localize.t("Waiting..."),"negative");
			tmpButton.touchable = false;
			joinQueue.width = 200;
			leaveQueue.width = 200;
			acceptQueue.width = 200;
			tmpButton.width = 200;
			updateStatus();
		}
		
		public function update() : void {
			updateStatus();
		}
		
		private function updateStatus() : void {
			if(queueInfo == null) {
				return;
			}
			if(queueInfo.isWaiting) {
				if(queueInfo.accepted) {
					tmpButton.text = Localize.t("Waiting for others...");
				} else {
					tmpButton.text = Localize.t("Waiting...");
				}
				if(contains(joinQueue)) {
					removeChild(joinQueue);
				}
				if(contains(leaveQueue)) {
					removeChild(leaveQueue);
				}
				if(contains(acceptQueue)) {
					removeChild(acceptQueue);
				}
				if(!contains(tmpButton)) {
					addChild(tmpButton);
				}
			} else if(!queueInfo.isInQueue && !queueInfo.isReady) {
				if(!contains(joinQueue)) {
					addChild(joinQueue);
				}
				if(contains(leaveQueue)) {
					removeChild(leaveQueue);
				}
				if(contains(acceptQueue)) {
					removeChild(acceptQueue);
				}
				if(contains(tmpButton)) {
					removeChild(tmpButton);
				}
				joinQueue.enabled = true;
			} else if(queueInfo.isInQueue && !queueInfo.isReady) {
				leaveQueue.text = "(" + queueInfo.getTime() + ") " + Localize.t("In Queue, Leave?");
				if(contains(joinQueue)) {
					removeChild(joinQueue);
				}
				if(!contains(leaveQueue)) {
					addChild(leaveQueue);
				}
				if(contains(acceptQueue)) {
					removeChild(acceptQueue);
				}
				if(contains(tmpButton)) {
					removeChild(tmpButton);
				}
				leaveQueue.enabled = true;
			} else {
				acceptQueue.text = "(" + queueInfo.getTimeout() + ") " + Localize.t("Match Ready, Join?");
				if(contains(joinQueue)) {
					removeChild(joinQueue);
				}
				if(contains(leaveQueue)) {
					removeChild(leaveQueue);
				}
				if(!contains(acceptQueue)) {
					addChild(acceptQueue);
				}
				if(contains(tmpButton)) {
					removeChild(tmpButton);
				}
				acceptQueue.enabled = true;
			}
		}
		
		private function join(e:TouchEvent) : void {
			g.queueManager.removedFromAllQueues();
			queueInfo.isWaiting = true;
			updateStatus();
			g.sendToServiceRoom("tryJoinQueue",type);
			Game.trackEvent("pvp","queue","joined",g.me.level);
		}
		
		private function leave(e:TouchEvent) : void {
			queueInfo.isWaiting = true;
			updateStatus();
			g.sendToServiceRoom("tryLeaveQueue",type);
		}
		
		private function accept(e:TouchEvent) : void {
			queueInfo.isWaiting = true;
			queueInfo.accepted = true;
			updateStatus();
			g.sendToServiceRoom("acceptMatch",type);
		}
		
		private function wait(e:TouchEvent) : void {
		}
	}
}

