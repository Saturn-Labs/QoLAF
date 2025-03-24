package core.hud.components.credits {
	import core.hud.components.Button;
	import core.scene.Game;
	import facebook.FB;
	import starling.events.Event;
	
	public class FBInviteUnlock extends Button {
		private var g:Game;
		
		private var nrReq:int;
		
		private var successCallBack:Function;
		
		private var failCallBack:Function;
		
		public function FBInviteUnlock(g:Game, nrReq:int, successCallBack:Function, failCallBack:Function) {
			this.g = g;
			this.nrReq = nrReq;
			this.successCallBack = successCallBack;
			this.failCallBack = failCallBack;
			super(invite,"or Invite " + nrReq + " Friends","highlight");
		}
		
		public function setNrRequired(nrReq:int) : void {
			this.nrReq = nrReq;
			tf.text = "or Invite " + nrReq + " Friends";
		}
		
		public function invite(e:Event) : void {
			var _local2:Object = {};
			_local2.method = "apprequests";
			_local2.message = "Play together with your friends, explore a vast universe, kill epic space monsters!";
			_local2.title = "Come play Astroflux with me!";
			_local2.filters = ["app_non_users"];
			FB.ui(_local2,onUICallback);
		}
		
		private function onUICallback(result:Object) : void {
			if(result == null) {
				failCallBack();
				return;
			}
			var _local2:Array = [];
			_local2 = result.to as Array;
			if(_local2.length >= nrReq) {
				successCallBack();
				Game.trackEvent("FBinvite","unlock invite sent","to " + _local2.length.toString() + " users",_local2.length);
			} else {
				failCallBack();
			}
		}
	}
}

