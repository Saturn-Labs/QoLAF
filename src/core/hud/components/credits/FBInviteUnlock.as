package core.hud.components.credits
{
	import core.hud.components.Button;
	import core.scene.Game;
	import facebook.FB;
	import starling.events.Event;
	
	public class FBInviteUnlock extends Button
	{
		private var g:Game;
		
		private var nrReq:int;
		
		private var successCallBack:Function;
		
		private var failCallBack:Function;
		
		public function FBInviteUnlock(param1:Game, param2:int, param3:Function, param4:Function)
		{
			this.g = param1;
			this.nrReq = param2;
			this.successCallBack = param3;
			this.failCallBack = param4;
			super(invite, "or Invite " + param2 + " Friends", "highlight");
		}
		
		public function setNrRequired(param1:int):void
		{
			this.nrReq = param1;
			tf.text = "or Invite " + param1 + " Friends";
		}
		
		public function invite(param1:Event):void
		{
			var _loc2_:Object = {};
			_loc2_.method = "apprequests";
			_loc2_.message = "Play together with your friends, explore a vast universe, kill epic space monsters!";
			_loc2_.title = "Come play Astroflux with me!";
			_loc2_.filters = ["app_non_users"];
			FB.ui(_loc2_, onUICallback);
		}
		
		private function onUICallback(param1:Object):void
		{
			if (param1 == null)
			{
				failCallBack();
				return;
			}
			var _loc2_:Array = [];
			_loc2_ = param1.to as Array;
			if (_loc2_.length >= nrReq)
			{
				successCallBack();
				Game.trackEvent("FBinvite", "unlock invite sent", "to " + _loc2_.length.toString() + " users", _loc2_.length);
			}
			else
			{
				failCallBack();
			}
		}
	}
}
