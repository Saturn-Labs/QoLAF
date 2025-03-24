package core.player {
	import core.hud.components.Button;
	import core.hud.components.Text;
	import core.scene.Game;
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class Invite extends Sprite {
		public var id:String;
		
		public var invited:Player;
		
		public var inviter:Player;
		
		private var acceptInviteButton:Button;
		
		private var cancelInviteButton:Button;
		
		private var inviteText:Text = new Text();
		
		private var bgrQuad:Quad = new Quad(100,100,2852126720);
		
		public function Invite(g:Game, id:String, invited:Player, inviter:Player) {
			super();
			this.id = id;
			this.invited = invited;
			this.inviter = inviter;
			inviteText.text = inviter.name + " invited you to his group.";
			addChild(inviteText);
			acceptInviteButton = new Button(function():void {
				g.groupManager.acceptGroupInvite(id);
			},"Accept");
			acceptInviteButton.size = 8;
			acceptInviteButton.y = inviteText.height + 10;
			addChild(acceptInviteButton);
			cancelInviteButton = new Button(function():void {
				g.groupManager.cancelGroupInvite(id);
			},"Decline");
			cancelInviteButton.x = acceptInviteButton.width + 10;
			cancelInviteButton.size = 8;
			cancelInviteButton.y = acceptInviteButton.y;
			addChild(cancelInviteButton);
			bgrQuad.x = -20;
			bgrQuad.y = -20;
			bgrQuad.width = inviteText.width + 40;
			bgrQuad.height = acceptInviteButton.y + acceptInviteButton.height + 40;
			addChild(bgrQuad);
		}
	}
}

