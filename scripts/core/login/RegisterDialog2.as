package core.login {
	import core.hud.components.LoginButton;
	import core.hud.components.LoginInput;
	import flash.net.SharedObject;
	import generics.Localize;
	import playerio.Client;
	import playerio.PlayerIO;
	import playerio.PlayerIORegistrationError;
	import starling.core.Starling;
	import starling.display.Sprite;
	
	public class RegisterDialog2 extends Sprite {
		private var registerBox:Sprite;
		
		private var mySharedObject:SharedObject;
		
		private var username:String;
		
		private var client:Client;
		
		private var registerButton:LoginButton;
		
		private var emailInput:LoginInput;
		
		private var nameInput:LoginInput;
		
		private var passwordInput:LoginInput;
		
		private var passwordConfirmInput:LoginInput;
		
		public function RegisterDialog2(login:Login) {
			var cancelButton:LoginButton;
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
			registerButton = new LoginButton(Localize.t("Confirm"),onRegisterSimple,325961);
			registerButton.y = passwordConfirmInput.y + 70;
			registerBox.addChild(registerButton);
			cancelButton = new LoginButton(Localize.t("Cancel"),function():void {
				Starling.current.nativeStage.focus = null;
				login.setState("site");
			});
			cancelButton.x = registerBox.width - cancelButton.width;
			cancelButton.y = registerButton.y;
			registerBox.addChild(cancelButton);
			addChild(registerBox);
		}
		
		public function onRegisterSimple() : void {
			var _local5:String = trim(emailInput.text);
			var _local3:String = trim(nameInput.text);
			var _local1:String = trim(passwordInput.text);
			var _local2:String = trim(passwordConfirmInput.text);
			emailInput.error = "";
			nameInput.error = "";
			passwordInput.error = "";
			passwordConfirmInput.error = "";
			var _local4:Boolean = false;
			if(_local5.length == 0 || !isValidEmail(_local5)) {
				emailInput.error = Localize.t("Invalid");
				_local4 = true;
			}
			if(_local3.length < 3) {
				nameInput.error = Localize.t("Too short").replace("[n]",3);
				_local4 = true;
			}
			if(_local1.length < 4) {
				passwordInput.error = Localize.t("Too short").replace("[n]",4);
				_local4 = true;
			} else if(_local1.toLowerCase() == _local3.toLowerCase()) {
				passwordInput.error = Localize.t("Too simple");
				_local4 = true;
			} else if(_local1 != _local2) {
				passwordConfirmInput.error = Localize.t("Don\'t match");
				_local4 = true;
			}
			if(emailInput.error.length != 0 || passwordInput.error.length != 0 || nameInput.error.length != 0) {
				registerButton.enabled = true;
				return;
			}
			if(_local4) {
				registerButton.enabled = true;
			}
			username = _local3;
			updateStatus(Localize.t("Creating new user..."));
			if(client != null) {
				handleConnect(client);
			} else {
				register(_local5,_local1);
			}
		}
		
		private function register(email:String, password:String) : void {
			mySharedObject = SharedObject.getLocal("AstrofluxLogin");
			mySharedObject.data.email = email;
			mySharedObject.flush();
			var _local3:Date = new Date();
			PlayerIO.quickConnect.simpleRegister(Starling.current.nativeStage,Login.gameId,_local3.getTime().toString(),password,email,null,null,null,Login.partnerId,RymdenRunt.partnerSegmentArray,handleConnect,handleRegError);
		}
		
		private function updateStatus(message:String = "") : void {
			var _local2:ConnectEvent = new ConnectEvent("connectStatus",true);
			_local2.message = message;
			dispatchEvent(_local2);
		}
		
		private function handleConnect(client:Client) : void {
			this.client = client;
			Starling.current.nativeStage.focus = null;
			emailInput.text = "";
			nameInput.text = "";
			passwordInput.text = "";
			passwordConfirmInput.text = "";
			removeChild(emailInput);
			removeChild(nameInput);
			removeChild(passwordInput);
			removeChild(passwordConfirmInput);
			var _local2:ConnectEvent = new ConnectEvent("fbConnect");
			_local2.client = client;
			_local2.joinData["name"] = username;
			dispatchEvent(_local2);
		}
		
		private function handleRegError(e:PlayerIORegistrationError) : void {
			updateStatus();
			emailInput.error = e.emailError;
			passwordInput.error = e.passwordError;
			registerButton.enabled = true;
		}
		
		private function isValidEmail(email:String) : Boolean {
			var _local2:RegExp = /^[0-9a-zA-Z][-._a-zA-Z0-9]*@([0-9a-zA-Z][-._0-9a-zA-Z]*\.)+[a-zA-Z]/;
			return _local2.test(email);
		}
		
		private function trim(s:String) : String {
			return s.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm,"$2");
		}
	}
}

