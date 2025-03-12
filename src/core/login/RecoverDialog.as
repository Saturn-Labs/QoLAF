package core.login
{
	import core.hud.components.LoginButton;
	import core.hud.components.LoginInput;
	import core.hud.components.dialogs.PopupMessage;
	import generics.Localize;
	import generics.Util;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class RecoverDialog extends Sprite
	{
		private var recoverEmail:LoginInput;
		
		private var recoverButton:LoginButton;
		
		private var cancelButton:LoginButton;
		
		private var login:Login;
		
		public function RecoverDialog(param1:Login)
		{
			var login:Login = param1;
			super();
			this.login = login;
			recoverEmail = new LoginInput("EMAIL");
			addChild(recoverEmail);
			recoverButton = new LoginButton(Localize.t("Recover"), onRecover, 325961);
			recoverButton.y = recoverEmail.y + 70;
			addChild(recoverButton);
			cancelButton = new LoginButton(Localize.t("Cancel"), function():void
			{
				login.setState("site");
			});
			cancelButton.x = recoverEmail.width - cancelButton.width;
			cancelButton.y = recoverButton.y;
			addChild(cancelButton);
		}
		
		public function onRecover():void
		{
			var user:String = Util.trimUsername(recoverEmail.text);
			if (user.length == 0)
			{
				recoverEmail.error = Localize.t("Enter email address");
				return;
			}
			recoverButton.enabled = false;
			recoverEmail.error = "";
			PlayerIO.quickConnect.simpleRecoverPassword(Login.gameId, user, function():void
			{
				var recoverPopup:PopupMessage = new PopupMessage();
				recoverPopup.text = Localize.t("Email with instruction has been sent.");
				login.addChild(recoverPopup);
				recoverPopup.addEventListener("close", (function():*
				{
					var onClose:Function;
					return onClose = function(param1:Event):void
					{
						login.removeChild(recoverPopup, true);
						login.setState("site");
						recoverButton.enabled = true;
					};
				})());
			}, function(param1:PlayerIOError):void
			{
				recoverEmail.error = param1.message;
				recoverButton.enabled = true;
			});
		}
	}
}
