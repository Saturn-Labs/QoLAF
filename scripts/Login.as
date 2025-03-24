package {
	import com.adobe.crypto.MD5;
	import com.greensock.TweenMax;
	import com.hurlant.crypto.rsa.RSAKey;
	import com.hurlant.util.Hex;
	import com.hurlant.util.der.PEM;
	import core.credits.SalesManager;
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.FadeScreen;
	import core.hud.components.ImageButton;
	import core.hud.components.LoginButton;
	import core.hud.components.LoginInput;
	import core.hud.components.SaleSticker;
	import core.hud.components.Text;
	import core.hud.components.dialogs.PopupMessage;
	import core.login.ConnectEvent;
	import core.login.ConnectStatus;
	import core.login.GuestName;
	import core.login.RecoverDialog;
	import core.login.RegisterDialog2;
	import core.login.ServiceRoomSelector;
	import core.scene.Game;
	import data.DataLocator;
	import data.DataManager;
	import debug.Console;
	import facebook.FB;
	import feathers.core.FocusManager;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import generics.Localize;
	import generics.Util;
	import io.InputLocator;
	import io.InputManager;
	import joinRoom.JoinRoomLocator;
	import joinRoom.JoinRoomManager;
	import playerio.Client;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	import playerio.PlayerIORegistrationError;
	import sound.SoundLocator;
	import sound.SoundManager;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	import startSetup.IStartSetup;
	import startSetup.StartSetup;
	import startSetup.StartSetupE;
	import startSetup.StartSetupLocator;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class Login extends Sprite {
		public static const DEV_SERVER:String = "";
		
		public static const CLIENT_VERSION:int = 1380;
		
		public static const SERVER_ROOM_TYPE:String = "game";
		
		public static const SERVICE_ROOM_TYPE:String = "service";
		
		public static const MENU_WIDTH:int = 760;
		
		public static const MENU_HEIGHT:int = 600;
		
		public static const START_SOLAR_SYSTEM:String = "HrAjOBivt0SHPYtxKyiB_Q";
		
		public static const STATE_PASSWORD_RECOVER:String = "password_recover";
		
		public static const STATE_LOGIN:String = "site";
		
		public static const STATE_REGISTER:String = "register";
		
		public static const STATE_FACEBOOK:String = "facebook";
		
		public static const STATE_KONGREGATE:String = "kongregate";
		
		public static const STATE_MOUSEBREAKER:String = "mousebreaker";
		
		public static const STATE_SPILGAMES:String = "spilgames";
		
		public static const STATE_ARMORGAMES:String = "armorgames";
		
		public static const STATE_GAMESAMBA:String = "gamesamba";
		
		public static const STATE_Y8:String = "y8";
		
		public static const STATE_STEAM:String = "steam";
		
		public static const STATE_DESKTOP:String = "desktop";
		
		public static const STATE_PSN:String = "psn";
		
		public static const TERMS_OF_SERVICE_VERSION:int = 3;
		
		public static const ERROR_SCREEN:Boolean = false;
		
		public static const ALLOW_MOUSE_AIM:Boolean = true;
		
		public static const ALLOW_CUSTOM_ROTATION_SPEED:Boolean = true;
		
		public static var isNewPlayer:Boolean = false;
		
		public static var fbAppId:String = "102658826485517";
		
		public static var gameId:String = "rymdenrunt-k9qmg7cvt0ylialudmldvg";
		
		public static var kongregateApiPath:String = "https://www.kongregate.com/flash/API_AS3_Local.swf";
		
		public static var partnerId:String = "";
		
		public static var transferId:String = null;
		
		public static var transferCode:String = "";
		
		public static var origin:String = "";
		
		public static var useSecure:Boolean = false;
		
		public static var hasFacebookLiked:Boolean = false;
		
		public static var currentState:String;
		
		public static var START_SETUP_IS_ACTIVE:Boolean = false;
		
		public static var START_SETUP_IS_DONE:Boolean = false;
		
		public static var isSaleSpinner:Boolean = false;
		
		public static var client:Client;
		
		public static var fadeScreen:FadeScreen;
		
		private static var instance:Login;
		
		public static var kongregate:Object = null;
		
		public var bar2:String = "Verdana_ttf$767177d9989c7323c60db8a483bd906b-639850078";
		
		public var ba3:String = "Russo_One_ttf$106c15525f996d3d73a9291202e5dc2e1347241993";
		
		private var textureManager:TextureManager;
		
		private var soundManager:SoundManager;
		
		private var isLoggedIn:Boolean;
		
		private var background:Image;
		
		private var container:Sprite = new Sprite();
		
		private var logoContainer:Sprite = new Sprite();
		
		private var effectContainer:Sprite = new Sprite();
		
		private var registerDialog:RegisterDialog2;
		
		private var recoverDialog:RecoverDialog;
		
		private var exitButton:LoginButton;
		
		private var enterPressed:Boolean;
		
		private var mySharedObject:SharedObject;
		
		private var connectStatus:ConnectStatus;
		
		private var assets:AssetManager;
		
		private var joinData:Object = {};
		
		private var playerInfo:Object = {};
		
		private var preload:Preload;
		
		private var bgWidth:Number;
		
		private var bgHeight:Number;
		
		private var loginContainer:Sprite;
		
		private var emailInput:LoginInput;
		
		private var passwordInput:LoginInput;
		
		private var y8str1:String = "";
		
		private var y8str2:String = "";
		
		private var joinRoomManager:JoinRoomManager;
		
		private var serviceRoomSelector:ServiceRoomSelector;
		
		private var theStartSetup:IStartSetup;
		
		private var effects:Vector.<Image> = new Vector.<Image>();
		
		private var effectTweens:Vector.<TweenMax> = new Vector.<TweenMax>();
		
		public function Login() {
			super();
			instance = this;
			PlayerIO.useSecureApiRequests = true;
			Localize.cacheLanguageData();
			Starling.current.stage.color = 0;
			Starling.current.nativeStage.color = 0;
		}
		
		public static function submitKongregateStat(stat:String, value:int) : void {
			if(kongregate == null) {
				return;
			}
			kongregate.stats.submit(stat,value);
		}
		
		public static function setDevServer(client:Client) : void {
			Console.write("setDevServer");
		}
		
		public static function hideStartSetup() : void {
			if(!instance) {
				return;
			}
			if(!instance.theStartSetup) {
				return;
			}
			StartSetup.hideProgressText(Localize.t("Game starting..."));
			TweenMax.to(instance.theStartSetup,15,{
				"alpha":0,
				"onComplete":function():void {
					instance.removeChild(instance.theStartSetup.sprite,true);
				}
			});
		}
		
		public function start() : void {
			if(stage) {
				loadAssets();
			} else {
				addEventListener("addedToStage",loadAssets);
			}
		}
		
		private function loadAssets(event:starling.events.Event = null) : void {
			if(hasEventListener("addedToStage",loadAssets)) {
				removeEventListener("addedToStage",loadAssets);
			}
			assets = Game.assets;
			assets.verbose = false;
			assets.useMipMaps = false;
			assets.keepFontXmls = true;
			assets.enqueue(EmbeddedAssets);
			assets.loadQueue(function(param1:Number):void {
				if(param1 == 1) {
					init();
				}
			});
		}
		
		private function init() : void {
			var saleSticker:SaleSticker;
			var logo:Image;
			var pId:String;
			var errorScreen:Box;
			var errorText:Text;
			var idi:IDI;
			if(hasEventListener("addedToStage")) {
				removeEventListener("addedToStage",init);
			}
			stage.addEventListener("resize",resize);
			gameId = RymdenRunt.parameters.sitebox_gameid || gameId;
			fbAppId = RymdenRunt.parameters.fb_application_id || fbAppId;
			transferId = RymdenRunt.parameters.querystring_transferId || null;
			transferCode = RymdenRunt.parameters.querystring_transferCode || null;
			kongregateApiPath = RymdenRunt.parameters.kongregate_api_path || kongregateApiPath;
			origin = RymdenRunt.origin || origin;
			background = new Image(assets.getTexture("astroflux_wide"));
			bgWidth = background.width;
			bgHeight = background.height;
			addChild(background);
			if(SalesManager.isSalePeriod()) {
				saleSticker = new SaleSticker("Halloween","Sale","Special",14942208,assets.getTexture("sale_sticker"),assets.getTexture("fb_sale_lg"));
				saleSticker.x = -20;
				saleSticker.y = 2 * 60;
				container.addChild(saleSticker);
			}
			addChild(container);
			logo = new Image(assets.getTexture("logo"));
			logoContainer.addChild(logo);
			addChild(effectContainer);
			addChild(logoContainer);
			if(!RymdenRunt.isDesktop) {
				try {
					ExternalInterface.addCallback("fbLike",onFBLike);
					ExternalInterface.marshallExceptions = true;
				}
				catch(error:Error) {
				}
				Security.loadPolicyFile("https://playerio-a.akamaihd.net/rymdenrunt-k9qmg7cvt0ylialudmldvg/crossdomain.xml");
				try {
					Security.allowDomain("*");
					Security.allowInsecureDomain("*");
				}
				catch(e:*) {
				}
			}
			mySharedObject = SharedObject.getLocal("AstrofluxLogin");
			pId = RymdenRunt.parameters.partnerId;
			if(pId != null) {
				partnerId = pId;
			}
			connectStatus = new ConnectStatus();
			connectStatus.x = 205;
			connectStatus.y = 290;
			container.addChild(connectStatus);
			FocusManager.setEnabledForStage(stage,true);
			if(RymdenRunt.isDesktop && RymdenRunt.info.origin == "steam") {
				currentState = "steam";
				connectSteam();
				addExitButton();
			} else if(RymdenRunt.isDesktop && RymdenRunt.info.origin == "desktop") {
				currentState = "site";
				loginForm();
				recoverForm();
				registerForm();
				addExitButton();
			} else if(RymdenRunt.parameters.fb_access_token) {
				useSecure = true;
				currentState = "facebook";
				connectFacebook();
			} else if(RymdenRunt.parameters.kongregate_api_path) {
				currentState = "kongregate";
				useSecure = true;
				loadKongregate();
			} else if(RymdenRunt.parameters.pio$affiliate == "mousebreaker") {
				currentState = "mousebreaker";
				useSecure = false;
				connectMousebreaker();
			} else if(RymdenRunt.parameters.querystring_a10_token) {
				currentState = "spilgames";
				useSecure = false;
				connectA10();
			} else if(RymdenRunt.parameters.querystring_user_id) {
				currentState = "armorgames";
				useSecure = false;
				connectArmorGames();
			} else if(RymdenRunt.parameters.querystring_usertoken) {
				currentState = "psn";
				useSecure = true;
				connectPSN();
			} else if(RymdenRunt.parameters.origin == "y8") {
				currentState = "y8";
				idi = new IDI(function(param1:*, param2:*, param3:*):void {
					useSecure = false;
					connectY8(param1,param2,param3);
				});
				Starling.current.nativeOverlay.addChild(idi);
			} else {
				useSecure = false;
				currentState = "site";
				loginForm();
				recoverForm();
				registerForm();
			}
			Game.trackPageView("preload");
			resize();
		}
		
		private function connectPSN() : void {
			var token:String = RymdenRunt.parameters.querystring_usertoken;
			ExternalInterface.call("console.log","token: " + token);
			try {
				PlayerIO.authenticate(Starling.current.nativeStage,gameId,"publishingnetwork",{"userToken":token},null,function(param1:Client):void {
					ExternalInterface.call("console.log","success");
					handleConnect(param1);
				},handleError);
			}
			catch(e:Error) {
				ExternalInterface.call("console.log","WHAAAT");
				updateStatus(e.message);
			}
		}
		
		private function resize(e:starling.events.Event = null) : void {
			var _local2:int = stage.stageWidth;
			var _local3:int = stage.stageHeight;
			if(background == null) {
				return;
			}
			container.x = _local2 / 2 - 760 / 2;
			container.y = _local3 / 2 - 10 * 60 / 2;
			logoContainer.x = _local2 / 2 - logoContainer.width / 2;
			logoContainer.y = 20;
			scaleBackground();
			if(_local3 > 500) {
				logoContainer.y = background.y + 80;
			}
			centerLogin();
			removeEffects();
			Starling.juggler.removeDelayedCalls(addParticleFlow);
			Starling.juggler.delayCall(addParticleFlow,1);
		}
		
		private function centerLogin() : void {
			var _local1:int = 0;
			if(RymdenRunt.isDesktop) {
				_local1 = 40;
			}
			if(loginContainer) {
				loginContainer.x = stage.stageWidth / 2 - loginContainer.width / 2;
				loginContainer.y = logoContainer.y + logoContainer.height + 80 + _local1;
			}
			if(registerDialog) {
				registerDialog.x = stage.stageWidth / 2 - registerDialog.width / 2;
				registerDialog.y = logoContainer.y + logoContainer.height + 40 + _local1;
			}
			if(recoverDialog) {
				recoverDialog.x = stage.stageWidth / 2 - recoverDialog.width / 2;
				recoverDialog.y = logoContainer.y + logoContainer.height + 80 + _local1;
			}
			if(exitButton) {
				exitButton.x = stage.stageWidth - exitButton.width - 20;
				exitButton.y = stage.stageHeight - exitButton.height - 20;
			}
			if(serviceRoomSelector) {
				serviceRoomSelector.x = stage.stageWidth / 2 - serviceRoomSelector.width / 2;
				serviceRoomSelector.y = stage.stageHeight / 5;
			}
		}
		
		private function scaleBackground() : void {
			background.x = 0;
			background.width = stage.stageWidth;
			background.height = background.width * bgHeight / bgWidth;
			if(background.width > bgWidth) {
				background.width = bgWidth;
				background.height = bgHeight;
				background.x = stage.stageWidth / 2 - background.width / 2;
			}
			if(background.height < stage.stageHeight) {
				background.y = stage.stageHeight / 2 - background.height / 2;
			} else {
				background.y = 0;
			}
		}
		
		private function loginForm() : void {
			var loginButton:LoginButton;
			var registerButton:LoginButton;
			var loginFB:ImageButton;
			var recover:TextField;
			Localize.setLocale(RymdenRunt.parameters.querystring_locale);
			loginContainer = new Sprite();
			addChild(loginContainer);
			stage.addEventListener("keyDown",onKeyPress);
			stage.addEventListener("keyUp",onKeyUp);
			enterPressed = false;
			emailInput = new LoginInput("EMAIL");
			loginContainer.addChild(emailInput);
			passwordInput = new LoginInput("PASSWORD");
			passwordInput.setPrevious(emailInput);
			passwordInput.input.displayAsPassword = true;
			loginContainer.addChild(passwordInput);
			loginButton = new LoginButton("login",onConnectSimple);
			loginButton.y = passwordInput.y + passwordInput.height + 10;
			loginContainer.addChild(loginButton);
			registerButton = new LoginButton("register",function():void {
				Game.trackPageView("openregdialog");
				setState("register");
			},325961);
			registerButton.y = loginButton.y;
			registerButton.x = loginContainer.width - registerButton.width;
			loginContainer.addChild(registerButton);
			if(!RymdenRunt.isDesktop) {
				loginFB = new ImageButton(connectFacebookPopup,assets.getTexture("fb_login"));
				loginFB.y = registerButton.y + registerButton.height + 20;
				loginFB.x = loginContainer.width / 2 - loginFB.width / 2;
			}
			recover = new TextField(200,20,"",new TextFormat("DAIDRR",12,7434094));
			recover.text = "<u>" + Localize.t("Forgot password?") + "</u>";
			recover.isHtmlText = true;
			recover.x = loginContainer.width / 2 - recover.width / 2;
			recover.y = RymdenRunt.isDesktop ? registerButton.y + registerButton.height + 40 : loginFB.y + loginFB.height + 40;
			recover.touchable = true;
			recover.useHandCursor = true;
			recover.addEventListener("touch",onRecoverTouch);
			loginContainer.addChild(recover);
			emailInput.text = mySharedObject.data.email != null ? mySharedObject.data.email : "";
			if(emailInput.text != "") {
				passwordInput.input.setFocus();
			}
		}
		
		private function onRecoverTouch(e:TouchEvent) : void {
			if(e.getTouch(this,"ended")) {
				setState("password_recover");
			}
		}
		
		private function registerForm() : void {
			registerDialog = new RegisterDialog2(this);
			registerDialog.visible = false;
			registerDialog.addEventListener("fbConnect",onRegisterSimple);
			registerDialog.addEventListener("connectStatus",onConnectStatus);
			addChild(registerDialog);
		}
		
		private function recoverForm() : void {
			recoverDialog = new RecoverDialog(this);
			recoverDialog.visible = false;
			addChild(recoverDialog);
		}
		
		private function addExitButton() : void {
			exitButton = new LoginButton("exit",function():void {
				RymdenRunt.instance.dispatchEvent(new flash.events.Event("exitgame"));
			},0xffffff,4871260);
			addChild(exitButton);
		}
		
		public function setState(state:String) : void {
			hideLogin();
			currentState = state;
			Starling.current.nativeStage.focus = null;
			if(state === "site") {
				loginContainer.visible = true;
			} else if(state === "register") {
				registerDialog.visible = true;
			} else if(state === "password_recover") {
				recoverDialog.visible = true;
			}
		}
		
		private function hideLogin() : void {
			recoverDialog.visible = false;
			registerDialog.visible = false;
			loginContainer.visible = false;
		}
		
		private function handleLoginError(error:PlayerIOError) : void {
			if(error.message.indexOf("password") != -1) {
				passwordInput.error = error.message;
			} else {
				emailInput.error = error.message;
			}
			connectStatus.visible = false;
			setState("site");
		}
		
		private function onRegisterSimple(e:ConnectEvent) : void {
			joinData["name"] = e.joinData["name"];
			addSiteRef();
			handleConnect(e.client);
		}
		
		private function updateStatus(label:String) : void {
			connectStatus.text = label;
			connectStatus.visible = true;
		}
		
		private function onConnectStatus(e:ConnectEvent) : void {
			connectStatus.update(e);
			if(connectStatus.visible) {
				hideLogin();
			} else {
				loginContainer.visible = true;
			}
		}
		
		private function getY8Str1(id:String) : String {
			return id;
		}
		
		private function getY8Str2(id:String) : String {
			return MD5.hash(id);
		}
		
		private function tryCreateNewUserY8(error:PlayerIOError) : void {
			updateStatus("Creating userdata");
			addSiteRef();
			if(error.message == "The user does not exist") {
				PlayerIO.quickConnect.simpleRegister(Starling.current.nativeStage,Login.gameId,y8str1,y8str2,"",null,null,null,"y8",["segment:y8"],handleConnectY8,handleError);
			} else {
				handleError(error);
			}
		}
		
		private function connectY8(name:String, id:String, email:String) : void {
			updateStatus("Authenticating with ID.net");
			joinData["name"] = name;
			addSiteRef();
			y8str1 = getY8Str1(id);
			y8str2 = getY8Str2(id);
			PlayerIO.quickConnect.simpleConnect(Starling.current.nativeStage,Login.gameId,y8str1,y8str2,["segment:y8"],handleConnectY8,tryCreateNewUserY8);
		}
		
		private function decrypt(userToken:String) : String {
			var _local3:String = "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEApvkQAoRKn7x3zwotivQkeClfvnp/oFzskj/eIghYLRplHqbz\n2XJoWg4ZM9mSqQNPtToh60FhxmXwTPjWDCzQb3fbCeQuYb6cJlwRcNNva+QDpDC2\ngF1QUNOmv3mIwJw/b478YsoEu5zRhHb1/fH86w8rS7qXoztv2pUJNxkTQCpUdCP2\na+Tqkhe6qLKywUSVOqG99E2kkCBJvXvno3Cw1emnDk8ib2k595U92lxca36+oBrv\nwcVMXkwfWmsYkkZbYqoqTC8oC1siRHFLrS5otNaF3k4N8YMs6NUa8mSWy7qUvxGk\n2M5ZckUkG/P4Q+0n+s6/uelvnF8jkEjVJzaSqwIDAQABAoIBAGI1bjA8xXOss79o\nGh93uBehJjpv7K9S2KawwCO+SrbEpqNfyV+lhjEpx7MSjsuwMerDNX4c57h87tkn\nJybkGPjnQ0NPHeTJ6yg40N1Oz2NjKq0hJcbcm8fepV5Lyp6XiExCirpEXoJHG4jR\nO6DQ+1T6iBmzt0sAQ6sKK/BnZEZBat0R7wcCno4J5mjn9DiJuqWmBgCJHNf3U8qB\n+yMqpvGCVG0hvuQySnZr5r1RZwIqjAvv3K9QlUOyUGiHwFTEkoSB9Mxhv4COZLWc\n5fdoIbnAD/sn4sl3rrHX5FUFGMUWXnvLixzzn9SBSkRSzDqG/P/Ex7BqX47wtOhS\nNnwgpdkCgYEA5q9vNOhRF2sHZxoxVtI6haGjUMjTZK6PDvIwv+B423cRxpwHBrzp\n0Chqudy6VXZ/67bqi6XbiljZE/si2ZDRloOO6xe5oeNHkO06eaFOrPeTO5o3EaTn\nhVy/cc8L6CLeVK4orNWO8HxoJCMq//hWH0IYcOSx7GD9Cc7WG/AskG0CgYEAuUvG\n60f3zhMGLPPQp5uBjjr4JWoEcdRS0tHlgArrtLHKY4jrp8E7wS08o3Lo4WPvBd9h\naZ6+a4EDNIdtbm1nTipXiLii2DvQnZf+1Lo4HuugdIrtGX+aXyQQyOx0JSvfCSls\nNP71jd8fdCScNEpEVXTA9s78qHlWbSLjPaA3MHcCgYEA4srRKxPHPZ20znFa1n+i\nl2Q9Opvl8FMJRGlo8gtO5nzeVgNpiP9LY6GIo6fU7VauFuBjIN3zw8TrzhAVyA3v\nb+lxJcHSd80Ju/ruhUvIHJbeAjfwMgGMuHlhohMrIpK9QEVkqd7fQ6EbhYOpr7PH\nf72sZ7j/D2SfAPh/WUI7ndUCgYBSsb7UwgmVrmfTJ/y20G/BSg/0opvZMSjFbWc+\n/aCzw6TPRwvkkhhY3hdx2paUAEVsGYUf3fidgbYse0QbRDgWak8mdUA3wHoZ2vuf\ndHwXUJELcfTerFP4od/by6sJ68peDF5+SErORgWDj9Mmgv58JN75Rub7SSuJCUjg\n99+pgQKBgE4LB4DYXhS+PMBkxUjvGZfyViKuQLWmc7Jnu8hBYZ5olRB7NewC8v/E\ndJePzuC5KKolakLh16p7c05w9OCF/eEmXPe8kcOzzKdq2M/bF8UoMRthzeXuVcv0\n4gYM0zua4/NbG9r3DouSEjdVzHDKplZZScicZoXDO6u21aSn9quD\n-----END RSA PRIVATE KEY-----";
			var _local6:RSAKey = PEM.readRSAPrivateKey(_local3);
			var _local5:ByteArray = Hex.toArray(Hex.fromString(userToken));
			var _local4:ByteArray = new ByteArray();
			_local6.decrypt(_local5,_local4,_local5.length);
			return Hex.toString(Hex.fromArray(_local4));
		}
		
		private function onConnectSimple(e:TouchEvent = null) : void {
			var _local3:String = Util.trimUsername(emailInput.text);
			var _local2:String = Util.trimUsername(passwordInput.text);
			emailInput.error = "";
			passwordInput.error = "";
			hideLogin();
			updateStatus(Localize.t("Connecting to Server"));
			mySharedObject.data.email = _local3;
			mySharedObject.flush();
			PlayerIO.quickConnect.simpleConnect(Starling.current.nativeStage,gameId,_local3,_local2,handleConnect,handleLoginError);
		}
		
		private function addSiteRef() : void {
			joinData["origin"] = RymdenRunt.origin;
		}
		
		private function connectFacebookPopup(sender:ImageButton) : void {
			hideLogin();
			updateStatus(Localize.t("Connecting to") + " Facebook");
			PlayerIO.quickConnect.facebookOAuthConnectPopup(Starling.current.nativeStage,gameId,"_blank",[],partnerId,handleConnectFacebookPopup,handleError);
		}
		
		private function loadKongregate() : void {
			var request:URLRequest;
			var loader:Loader;
			updateStatus(Localize.t("Connecting to") + " Kongregate");
			Security.allowDomain(kongregateApiPath);
			Security.allowDomain("*");
			request = new URLRequest(kongregateApiPath);
			loader = new Loader();
			loader.load(request);
			Starling.current.nativeStage.addChild(loader);
			loader.contentLoaderInfo.addEventListener("complete",(function():* {
				var onLoad:Function;
				return onLoad = function(param1:flash.events.Event):void {
					loader.contentLoaderInfo.removeEventListener("complete",onLoad);
					connectKongregate(param1);
				};
			})());
		}
		
		private function connectKongregate(e:flash.events.Event = null) : void {
			var guestButton:Button;
			kongregate = e.target.content;
			kongregate.services.connect();
			if(kongregate.services.isGuest()) {
				updateStatus(Localize.t("Welcome Guest!"));
				guestButton = new Button(function(param1:TouchEvent):void {
					kongregate.services.showRegistrationBox();
					kongregate.services.addEventListener("login",connectKongregate);
					updateStatus(Localize.t("Waiting for Login"));
				},Localize.t("Play Now!"),"positive",20,"font20");
				guestButton.x = 760 / 2 - guestButton.width / 2;
				guestButton.y = 10 * 60 - guestButton.height - 2 * 60;
				container.addChild(guestButton);
			} else {
				joinData["name"] = kongregate.services.getUsername();
				PlayerIO.quickConnect.kongregateConnect(Starling.current.nativeStage,gameId,kongregate.services.getUserId(),kongregate.services.getGameAuthToken(),handleConnect,handleError);
			}
		}
		
		private function connectMousebreaker() : void {
			var mLoader:URLLoader;
			var popup:PopupMessage;
			var mRequest:URLRequest;
			updateStatus(Localize.t("Connecting to") + " Mousebreaker");
			mLoader = new URLLoader();
			mLoader.dataFormat = "text";
			if(RymdenRunt.parameters.token == null) {
				popup = new PopupMessage("Close");
				popup.text = Localize.t("Please login on mousebreaker and reload the game.");
				addChild(popup);
				updateStatus(Localize.t("Please Login and Reload."));
				return;
			}
			mRequest = new URLRequest("http://api.playerio.com/clientintegrations/mousebreaker/auth?game=4&token=" + RymdenRunt.parameters.token);
			mRequest.method = "GET";
			mLoader.addEventListener("complete",(function():* {
				var onLoad:Function;
				return onLoad = function(param1:flash.events.Event):void {
					mLoader.removeEventListener("complete",onLoad);
					var _local2:Array = (param1.target.data as String).split("\n");
					PlayerIO.connect(Starling.current.nativeStage,gameId,"public",_local2[0],_local2[1],"mousebreaker",handleConnect,handleError);
				};
			})());
			mLoader.load(mRequest);
		}
		
		private function connectA10() : void {
			var token:String;
			var request:URLRequest;
			var loader:URLLoader;
			updateStatus(Localize.t("Connecting to") + " A10");
			joinData["name"] = RymdenRunt.parameters.querystring_a10_name;
			token = RymdenRunt.parameters.querystring_a10_token;
			request = new URLRequest("http://api.playerio.com/clientintegrations/spilgames/auth?gameid=" + gameId + "&token=" + token);
			request.method = "GET";
			loader = new URLLoader();
			loader.dataFormat = "text";
			loader.addEventListener("complete",(function():* {
				var onLoad:Function;
				return onLoad = function(param1:flash.events.Event):void {
					loader.removeEventListener("complete",onLoad);
					var _local2:Array = (param1.target.data as String).split("\n");
					PlayerIO.connect(Starling.current.nativeStage,gameId,"public",_local2[0],_local2[1],"spilgames",handleConnect,handleError);
				};
			})());
			loader.load(request);
		}
		
		private function connectArmorGames() : void {
			var token:String;
			var userId:String;
			var request:URLRequest;
			var loader:URLLoader;
			updateStatus(Localize.t("Connecting to") + " Armor Games");
			token = RymdenRunt.parameters.querystring_auth_token;
			userId = RymdenRunt.parameters.querystring_user_id;
			request = new URLRequest("http://api.playerio.com/clientintegrations/armorgames/auth?gameid=" + gameId + "&userid=" + userId + "&authtoken=" + token);
			request.method = "GET";
			loader = new URLLoader();
			loader.dataFormat = "text";
			loader.addEventListener("complete",(function():* {
				var onLoad:Function;
				return onLoad = function(param1:flash.events.Event):void {
					loader.removeEventListener("complete",onLoad);
					var _local2:Array = (param1.target.data as String).split("\n");
					var _local3:String = _local2[0];
					joinData["name"] = _local3.slice(5);
					PlayerIO.connect(Starling.current.nativeStage,gameId,"public",_local3,_local2[1],"armorgames",handleConnect,handleError);
				};
			})());
			loader.load(request);
		}
		
		private function connectFacebook() : void {
			updateStatus(Localize.t("Connecting to") + " Facebook");
			PlayerIO.quickConnect.facebookOAuthConnect(Starling.current.nativeStage,gameId,RymdenRunt.parameters.fb_access_token,Login.partnerId,function(param1:Client, param2:String = ""):void {
				handleConnectFacebook(param1,RymdenRunt.parameters.fb_access_token);
			},handleError);
		}
		
		private function connectSteam() : void {
			updateStatus(Localize.t("Connecting to") + " Steam");
			try {
				PlayerIO.authenticate(Starling.current.nativeStage,gameId,"steam",{
					"steamAppId":RymdenRunt.info.appId,
					"steamSessionTicket":RymdenRunt.info.ticket
				},null,handleConnectSteam,handleError);
			}
			catch(e:Error) {
				updateStatus(e.message);
			}
		}
		
		private function handleConnectFacebookPopup(client:Client, token:String, facebookId:String) : void {
			handleConnectFacebook(client,token);
		}
		
		private function handleConnectFacebook(client:Client, token:String) : void {
			FB.init({
				"access_token":token,
				"debug":true
			});
			FB.api("/v2.2/me?fields=first_name,friends,locale&",function(param1:Object):void {
				var _local2:int = 0;
				joinData.name = param1.first_name;
				joinData.friends = [];
				var _local3:Array = [];
				if(param1.friends && param1.friends.data) {
					_local3 = param1.friends.data;
				}
				_local2 = 0;
				while(_local2 < _local3.length) {
					joinData.friends.push("fb" + _local3[_local2].id);
					_local2++;
				}
				joinData["fbLike"] = false;
				hasFacebookLiked = false;
				handleConnect(client);
			});
		}
		
		private function handleConnectSteam(client:Client) : void {
			updateStatus("Connected to SteamInfo");
			handleConnect(client);
		}
		
		private function handleConnectY8(client:Client) : void {
			handleConnect(client);
		}
		
		private function handleConnect(client:Client) : void {
			RymdenRunt.initTimeStamp();
			if(isLoggedIn) {
				return;
			}
			isLoggedIn = true;
			Console.write("Connected to player.io");
			connectStatus.visible = false;
			stage.removeEventListener("keyDown",onKeyPress);
			stage.removeEventListener("keyUp",onKeyUp);
			var _local2:DataManager = new DataManager(client);
			DataLocator.register(_local2);
			textureManager = new TextureManager(client);
			TextureLocator.register(textureManager);
			soundManager = new SoundManager(client);
			SoundLocator.register(soundManager);
			InputLocator.register(new InputManager(stage));
			Login.client = client;
			try {
				ExternalInterface.call("onLogin");
			}
			catch(e:Error) {
			}
			preload = new Preload(container);
			preload.addEventListener("preloadComplete",preloadComplete);
			preload.loadData();
		}
		
		private function handleError(error:PlayerIOError) : void {
			var _local2:PlayerIORegistrationError = null;
			updateStatus("error");
			if(currentState == "steam") {
				updateStatus("STEAM " + Localize.t("Error!"));
				updateStatus(error.message);
			} else if(currentState == "facebook") {
				updateStatus("Facebook " + Localize.t("Error!"));
			} else if(currentState == "kongregate") {
				updateStatus("Kongregate " + Localize.t("Error!"));
			} else if(currentState == "mousebreaker") {
				updateStatus("Mousebreaker " + Localize.t("Error!"));
			} else if(currentState == "spilgames") {
				updateStatus(Localize.t("Connection Error!"));
			} else if(currentState == "armorgames") {
				updateStatus("Armor Games " + Localize.t("Error!"));
			} else if(currentState == "psn") {
				updateStatus("PSN " + Localize.t("Error!"));
				ExternalInterface.call("console.log","error: " + error);
			} else if(currentState == "y8" || currentState == "gamesamba") {
				if(error is PlayerIORegistrationError) {
					_local2 = error as PlayerIORegistrationError;
					if(_local2.emailError != null) {
						updateStatus(_local2.emailError);
					} else if(_local2.passwordError != null) {
						updateStatus(_local2.passwordError);
					} else if(_local2.usernameError != null) {
						updateStatus(_local2.usernameError);
					} else {
						updateStatus(_local2.message);
					}
				} else {
					updateStatus(error.message);
				}
			} else {
				setState("site");
				connectStatus.visible = false;
			}
		}
		
		private function preloadComplete(e:starling.events.Event) : void {
			var mouseDialog:GuestName;
			preload.removeEventListener("preloadComplete",preloadComplete);
			if(currentState == "steam") {
				joinData["name"] = Util.trimUsername(RymdenRunt.info.name);
				joinServiceRoom();
			} else if(currentState == "mousebreaker") {
				mouseDialog = new GuestName("Mouse-");
				mouseDialog.x = stage.stageWidth / 2 - mouseDialog.width / 2 + 20;
				mouseDialog.y = stage.stageHeight / 2 - mouseDialog.height / 2 + 20;
				stage.addChild(mouseDialog);
				mouseDialog.addEventListener("nameEntered",function(param1:starling.events.Event):void {
					stage.removeChild(mouseDialog);
					mouseDialog.removeEventListeners();
					joinData["name"] = Util.trimUsername(param1.data as String);
					joinServiceRoom();
				});
			} else {
				joinServiceRoom();
			}
		}
		
		private function joinServiceRoom() : void {
			setDevServer(client);
			joinRoomManager = new JoinRoomManager(client,stage,joinData,this);
			JoinRoomLocator.register(joinRoomManager);
			joinRoomManager.init();
			joinRoomManager.addEventListener("joinedServiceRoom",onJoinedServiceRoom);
		}
		
		public function selectServiceRoom(rooms:Array, callback:*) : void {
			serviceRoomSelector = new ServiceRoomSelector(rooms,callback);
			addChild(serviceRoomSelector);
			centerLogin();
			TweenMax.to(logoContainer,1,{"y":-logoContainer.height});
		}
		
		private function onJoinedServiceRoom(e:starling.events.Event) : void {
			joinRoomManager.removeEventListener("joinedServiceRoom",onJoinedServiceRoom);
			playerInfo = e.data;
			removeLoginScreen();
			submitKongregateStats();
			soundManager.musicVolume = playerInfo.musicVolume;
			soundManager.effectVolume = playerInfo.effectVolume;
			if(playerInfo.level == 0) {
				initStartSetup();
			} else {
				joinGameRoom();
			}
		}
		
		private function removeLoginScreen() : void {
			Console.write("removeLoginScreen");
			new AstroTheme();
			Button.loadTheme();
			Box.loadTheme();
			TextField.unregisterBitmapFont("font13");
			TextField.registerBitmapFont(new BitmapFont(textureManager.getTextureGUIByTextureName("font13"),assets.getXml("font13")),"font13");
			removeEmbeddedAssets();
			removeEffects();
			loginContainer = null;
			background = null;
			recoverDialog = null;
			registerDialog = null;
			logoContainer = null;
			container = null;
			removeChildren(0,-1,true);
			stage.removeEventListener("resize",resize);
			if(currentState == "site") {
				stage.removeEventListener("keyDown",onKeyPress);
				stage.removeEventListener("keyUp",onKeyUp);
			}
		}
		
		private function submitKongregateStats() : void {
			if(currentState != "kongregate") {
				return;
			}
			Login.submitKongregateStat("Experience",playerInfo.xp);
			Login.submitKongregateStat("Level",playerInfo.level);
			Login.submitKongregateStat("Enemy Kills",playerInfo.enemyKills);
			Login.submitKongregateStat("Player Kills",playerInfo.playerKills);
			Login.submitKongregateStat("Suicides",playerInfo.suicides);
			Login.submitKongregateStat("Troons",playerInfo.troons);
			Login.submitKongregateStat("Boss Encounters",playerInfo.bossEncounters);
			Login.submitKongregateStat("Enemy Encounters",playerInfo.enemyEncounters);
			Login.submitKongregateStat("Explored Planets",playerInfo.exploredPlanets);
		}
		
		private function initStartSetup() : void {
			Login.isNewPlayer = true;
			var _local1:String = playerInfo.split;
			if(transferId) {
				_local1 = "A";
			}
			joinData["split"] = _local1;
			Game.trackEvent("AB Splits","player flow",_local1 + ": start ");
			_local1 = "B";
			if(_local1 == "A") {
				Login.START_SETUP_IS_DONE = true;
				theStartSetup = new StartSetup();
				Login.START_SETUP_IS_ACTIVE = false;
				theStartSetup.sprite.visible = false;
				addChild(theStartSetup.sprite);
				onStartSetupComplete();
			} else if(_local1 == "B") {
				theStartSetup = new StartSetup();
				if(stage.stageHeight < 550) {
					theStartSetup.sprite.y -= 30;
				}
				theStartSetup.sprite.addEventListener("complete",onStartSetupComplete);
				addChild(theStartSetup.sprite);
			} else if(_local1 == "H") {
				Login.START_SETUP_IS_DONE = true;
				theStartSetup = new StartSetup();
				Login.START_SETUP_IS_ACTIVE = false;
				theStartSetup.sprite.visible = false;
				addChild(theStartSetup.sprite);
				onStartSetupComplete();
			} else if(_local1 == "F") {
				Login.START_SETUP_IS_DONE = true;
				theStartSetup = new StartSetup();
				Login.START_SETUP_IS_ACTIVE = false;
				theStartSetup.sprite.visible = false;
				addChild(theStartSetup.sprite);
				onStartSetupComplete();
			} else if(_local1 == "G") {
				theStartSetup = new StartSetupE();
				if(stage.stageHeight < 550) {
					theStartSetup.sprite.y -= 30;
				}
				theStartSetup.sprite.addEventListener("complete",onStartSetupComplete);
				addChild(theStartSetup.sprite);
			} else if(_local1 == "I") {
				theStartSetup = new StartSetupE();
				if(stage.stageHeight < 550) {
					theStartSetup.sprite.y -= 30;
				}
				theStartSetup.sprite.addEventListener("complete",onStartSetupComplete);
				addChild(theStartSetup.sprite);
			}
			theStartSetup.joinName = joinData["name"];
			StartSetupLocator.register(theStartSetup);
		}
		
		private function onStartSetupComplete(e:starling.events.Event = null) : void {
			Login.START_SETUP_IS_DONE = true;
			theStartSetup.sprite.removeEventListener("complete",onStartSetupComplete);
			joinData["startSetupSkin"] = theStartSetup.skin;
			var _local2:String = playerInfo.split + " " + theStartSetup.split;
			playerInfo.split = _local2;
			joinData["split"] = _local2;
			Game.trackEvent("AB Splits","player flow",playerInfo.split + ": ship selected ");
			joinData["pvpDisabled"] = !theStartSetup.pvp;
			joinGameRoom();
		}
		
		private function joinGameRoom() : void {
			fadeScreen = new FadeScreen(stage);
			fadeScreen.show();
			joinRoomManager.joinCurrentSolarSystem();
		}
		
		private function removeEmbeddedAssets() : void {
			assets.removeTexture("astroflux_wide",true);
			assets.removeTexture("fb_login",true);
			assets.removeTexture("logo",true);
			assets.removeTexture("logoGlow",true);
			assets.removeTexture("fluff",true);
			assets.removeTexture("star",true);
			assets.removeTexture("button_normal",true);
			assets.removeTexture("button_highlight",true);
			assets.removeTexture("button_positive",true);
			assets.removeTexture("button_warning",true);
			assets.removeTexture("box_highlight",true);
			assets.removeTexture("box_normal",true);
			assets.removeTexture("sale_sticker",true);
			assets.removeTexture("fb_sale_lg",true);
			assets.removeTexture("font13",true);
			assets.removeXml("font13",true);
		}
		
		private function onKeyUp(e:KeyboardEvent) : void {
			if(e.keyCode == 13) {
				enterPressed = false;
			}
		}
		
		private function onKeyPress(e:KeyboardEvent) : void {
			if(e.keyCode == 13 && !enterPressed) {
				enterPressed = true;
				switch(currentState) {
					case "site":
						onConnectSimple();
						break;
					case "password_recover":
						recoverDialog.onRecover();
						break;
					case "register":
						registerDialog.onRegisterSimple();
				}
			}
		}
		
		private function onFBLike() : void {
			joinData["fbLike"] = true;
			hasFacebookLiked = true;
		}
		
		private function addParticleFlow() : void {
			var _local2:int = 0;
			var _local3:Image = null;
			var _local1:Texture = assets.getTexture("star");
			var _local4:Array = [15907921,6210749,14305875];
			_local2 = 0;
			while(_local2 < 100) {
				_local3 = new Image(_local1);
				_local3.blendMode = "add";
				_local3.x = 0;
				_local3.y = 0;
				_local3.alpha = 0.4;
				_local3.color = _local4[Math.floor(Math.random() * _local4.length)];
				addParticleTween(_local3);
				effectContainer.x = stage.stageWidth / 2;
				effectContainer.y = logoContainer.y + logoContainer.height / 2;
				effectContainer.addChildAt(_local3,0);
				effects.push(_local3);
				_local2++;
			}
		}
		
		private function addParticleTween(glowImage:Image) : void {
			var tween:TweenMax = TweenMax.to(glowImage,5 + Math.random(),{
				"delay":5 * Math.random(),
				"x":glowImage.x + 350 - 700 * Math.random(),
				"y":glowImage.y + 200 - 400 * Math.random(),
				"alpha":0,
				"onComplete":function():void {
					tween.restart();
				}
			});
			effectTweens.push(tween);
		}
		
		public function removeEffects() : void {
			var _local2:int = 0;
			var _local1:Image = null;
			_local2 = 0;
			while(_local2 < effects.length) {
				_local1 = effects[_local2];
				effectContainer.removeChild(_local1);
				effectTweens[_local2].kill();
				_local2++;
			}
			effectTweens.length = 0;
			effects.length = 0;
			TweenMax.killAll();
		}
	}
}

