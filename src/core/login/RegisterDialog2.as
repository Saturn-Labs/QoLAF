package core.login
{
	import core.hud.components.LoginButton;
	import core.hud.components.LoginInput;
	import flash.net.SharedObject;
	import generics.Localize;
	import playerio.Client;
	import playerio.PlayerIO;
	import playerio.PlayerIORegistrationError;
	import starling.core.Starling;
	import starling.display.Sprite;
	
	public class RegisterDialog2 extends Sprite
	{
		private var registerBox:Sprite;
		
		private var mySharedObject:SharedObject;
		
		private var username:String;
		
		private var client:Client;
		
		private var registerButton:LoginButton;
		
		private var emailInput:LoginInput;
		
		private var nameInput:LoginInput;
		
		private var passwordInput:LoginInput;
		
		private var passwordConfirmInput:LoginInput;
		
		public function RegisterDialog2(param1:Login)
		{
			var cancelButton:LoginButton;
			var login:Login = param1;
			super();
			registerBox = new Sprite();
			emailInput = new LoginInput(Localize.t("Email"));
			registerBox.addChild(emailInput);
			nameInput = new LoginInput(Localize.t("Name"));
			nameInput.setPrevious(emailInput);
			registerBox.addChild(nameInput);
			passwordInput = new LoginInput(Localize.t("Password"));
			passwordInput.setPrevious(nameInput);
			passwordInput.input.displayAsPassword = true;
			registerBox.addChild(passwordInput);
			passwordConfirmInput = new LoginInput(Localize.t("Password again"));
			passwordConfirmInput.setPrevious(passwordInput);
			passwordConfirmInput.input.displayAsPassword = true;
			registerBox.addChild(passwordConfirmInput);
			registerButton = new LoginButton(Localize.t("Confirm"), onRegisterSimple, 325961);
			registerButton.y = passwordConfirmInput.y + 70;
			registerBox.addChild(registerButton);
			cancelButton = new LoginButton(Localize.t("Cancel"), function():void
			{
				Starling.current.nativeStage.focus = null;
				login.setState("site");
			});
			cancelButton.x = registerBox.width - cancelButton.width;
			cancelButton.y = registerButton.y;
			registerBox.addChild(cancelButton);
			addChild(registerBox);
		}
		
		public function onRegisterSimple():void
		{
			var _loc2_:String = trim(emailInput.text);
			var _loc4_:String = trim(nameInput.text);
			var _loc5_:String = trim(passwordInput.text);
			var _loc1_:String = trim(passwordConfirmInput.text);
			emailInput.error = "";
			nameInput.error = "";
			passwordInput.error = "";
			passwordConfirmInput.error = "";
			var _loc3_:Boolean = false;
			if (_loc2_.length == 0 || !isValidEmail(_loc2_))
			{
				emailInput.error = Localize.t("Invalid");
				_loc3_ = true;
			}
			if (_loc4_.length < 3)
			{
				nameInput.error = Localize.t("Too short").replace("[n]", 3);
				_loc3_ = true;
			}
			if (_loc5_.length < 4)
			{
				passwordInput.error = Localize.t("Too short").replace("[n]", 4);
				_loc3_ = true;
			}
			else if (_loc5_.toLowerCase() == _loc4_.toLowerCase())
			{
				passwordInput.error = Localize.t("Too simple");
				_loc3_ = true;
			}
			else if (_loc5_ != _loc1_)
			{
				passwordConfirmInput.error = Localize.t("Don't match");
				_loc3_ = true;
			}
			if (emailInput.error.length != 0 || passwordInput.error.length != 0 || nameInput.error.length != 0)
			{
				registerButton.enabled = true;
				return;
			}
			if (_loc3_)
			{
				registerButton.enabled = true;
			}
			username = _loc4_;
			updateStatus(Localize.t("Creating new user..."));
			if (client != null)
			{
				handleConnect(client);
			}
			else
			{
				register(_loc2_, _loc5_);
			}
		}
		
		private function register(param1:String, param2:String):void
		{
			mySharedObject = SharedObject.getLocal("AstrofluxLogin");
			mySharedObject.data.email = param1;
			mySharedObject.flush();
			var _loc3_:Date = new Date();
			PlayerIO.quickConnect.simpleRegister(Starling.current.nativeStage, Login.gameId, _loc3_.getTime().toString(), param2, param1, null, null, null, Login.partnerId, RymdenRunt.partnerSegmentArray, handleConnect, handleRegError);
		}
		
		private function updateStatus(param1:String = ""):void
		{
			var _loc2_:ConnectEvent = new ConnectEvent("connectStatus", true);
			_loc2_.message = param1;
			dispatchEvent(_loc2_);
		}
		
		private function handleConnect(param1:Client):void
		{
			this.client = param1;
			Starling.current.nativeStage.focus = null;
			emailInput.text = "";
			nameInput.text = "";
			passwordInput.text = "";
			passwordConfirmInput.text = "";
			removeChild(emailInput);
			removeChild(nameInput);
			removeChild(passwordInput);
			removeChild(passwordConfirmInput);
			var _loc2_:ConnectEvent = new ConnectEvent("fbConnect");
			_loc2_.client = param1;
			_loc2_.joinData["name"] = username;
			dispatchEvent(_loc2_);
		}
		
		private function handleRegError(param1:PlayerIORegistrationError):void
		{
			updateStatus();
			emailInput.error = param1.emailError;
			passwordInput.error = param1.passwordError;
			registerButton.enabled = true;
		}
		
		private function isValidEmail(param1:String):Boolean
		{
			var _loc2_:RegExp = /^[0-9a-zA-Z][-._a-zA-Z0-9]*@([0-9a-zA-Z][-._0-9a-zA-Z]*\.)+[a-zA-Z]/;
			return _loc2_.test(param1);
		}
		
		private function trim(param1:String):String
		{
			return param1.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
		}
	}
}
