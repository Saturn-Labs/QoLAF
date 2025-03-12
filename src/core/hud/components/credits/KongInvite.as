package core.hud.components.credits
{
	import core.hud.components.Button;
	import core.scene.Game;
	import starling.events.Event;
	
	public class KongInvite extends Button
	{
		private var g:Game;
		
		public function KongInvite(param1:Game)
		{
			this.g = param1;
			super(invite, "Invite friends", "positive");
		}
		
		public function invite(param1:Event):void
		{
			Login.kongregate.services.showInvitationBox({"content": "Come try Astroflux! An awesome space-shooter MMORPG!", "kv_params": {"kv_id": "something"}});
			Game.trackEvent("KONGinvite", "invite sent", "to x users", 1);
		}
	}
}
