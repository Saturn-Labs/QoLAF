package core.hud.components.credits
{
	import core.hud.components.Button;
	import core.scene.Game;
	import facebook.FB;
	import playerio.Message;
	import starling.events.Event;
	
	public class FBInvite extends Button
	{
		private var g:Game;
		
		public function FBInvite(param1:Game)
		{
			this.g = param1;
			super(invite, "Invite friends", "positive");
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
			var _loc3_:Message = null;
			var _loc5_:int = 0;
			var _loc2_:String = null;
			if (param1 == null)
			{
				return;
			}
			var _loc4_:Array = [];
			_loc4_ = param1.to as Array;
			if (_loc4_.length > 0)
			{
				_loc3_ = g.createMessage("FBinvitedUsers");
				_loc5_ = 0;
				while (_loc5_ < _loc4_.length)
				{
					_loc2_ = _loc4_[_loc5_];
					_loc2_ = "fb" + _loc2_;
					_loc3_.add(_loc2_);
					_loc5_++;
				}
				g.sendMessage(_loc3_);
				Game.trackEvent("FBinvite", "invite sent", "to " + _loc4_.length.toString() + " users", _loc4_.length);
			}
		}
	}
}
