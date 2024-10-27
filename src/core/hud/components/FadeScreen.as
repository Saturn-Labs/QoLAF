package core.hud.components
{
	import com.greensock.TweenMax;
	import core.scene.Game;
	import debug.Console;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	import generics.Localize;
	import playerio.Message;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class FadeScreen extends EventDispatcher
	{
		private static var Promotion:Class;
		
		private var fadeTime:int = 150;
		
		private var period:int = 30;
		
		private var currentStep:int = 0;
		
		private var bgrQuad:Quad;
		
		private var screenText:ScreenTextField;
		
		private var screen:Sprite;
		
		private var loadingText:TextBitmap;
		
		private var fadeInSteps:int;
		
		private var fadeOutSteps:int;
		
		private var fadeInTimer:Timer;
		
		private var fadeOutTimer:Timer;
		
		private var loadingImage:Image;
		
		private var loadingImage2:Image;
		
		private var tween:TweenMax;
		
		private var tween2:TweenMax;
		
		private var texts:Array;
		
		private var textsPvp:Array;
		
		private var textureManager:ITextureManager;
		
		private var promotionButton:NativeImageButton;
		
		private var promotionUrl:String = "";
		
		private var topPvpPlayersList:TopPvPPlayersList;
		
		private var stage:Stage;
		
		public function FadeScreen(param1:Stage)
		{
			bgrQuad = new Quad(1000, 1000, 4278190080);
			screenText = new ScreenTextField(720, 160);
			fadeInSteps = fadeTime / period;
			fadeOutSteps = fadeTime / period;
			fadeInTimer = new Timer(period, fadeInSteps);
			fadeOutTimer = new Timer(period, fadeOutSteps);
			texts = [];
			textsPvp = [];
			super();
			this.stage = param1;
			screen = new Sprite();
			screen.visible = false;
			loadingText = new TextBitmap();
			loadingText.size = 12;
			loadingText.text = Localize.t("Loading...");
			loadingText.visible = false;
			textureManager = TextureLocator.getService();
			resize();
			texts.push([[Localize.t("Press C if you want to know how many minerals you have.")]], [[Localize.t("Press X or ESC if you want to see your ship summary.")]], [[Localize.t("Check out the game wiki at wiki.astroflux.net")]], [[Localize.t("Watch out for those pesky comets.")]], [[Localize.t("You can unlock artifact slots in the ship menu.")]], [[Localize.t("Not all offers are good...")]], [[Localize.t("Crew members will increase their skill while exploring.")]], [[Localize.t("News and updates on forum.astroflux.net")]], [[Localize.t("You lose all junk when you die. All your minerals are safe.")]], [[Localize.t("Whatever you do, don't fly into the sun.")]], [[Localize.t("I am busy computing..")]], [[Localize.t("Improve your armor to reduce damage taken by that amount.")]], [[Localize.t("Power regenerates more slowly when the gauge turns red.")]], [[Localize.t("Group up with players and share XP.")]], [[Localize.t("Recycle artifacts and collect minerals.")]], [[Localize.t("Your game is automatically saved.")]], [[Localize.t("Enemies drop 25% more junk in pvp systems.")]], [[Localize.t("Press enter to start chatting.")]]);
			textsPvp.push([[Localize.t("End of season rewards: 100-1000 Flux for the top 500 players!")]], [[Localize.t("Defeting a player with much lower Rating yeilds nothing.")]], [[Localize.t("Match making is based on player Rating.")]], [[Localize.t("A zone with players from both teams doesn't generate points.")]], [[Localize.t("Holding all zones at the same time generates 3x more points.")]], [[Localize.t("The PvP-ladder resets each new month.")]]);
			screen.addChild(bgrQuad);
			var _loc2_:Texture = textureManager.getTextureGUIByTextureName("loading.png");
			loadingImage = new Image(_loc2_);
			loadingImage.pivotX = _loc2_.width * 0.5;
			loadingImage.pivotY = _loc2_.height * 0.5;
			screen.addChild(loadingImage);
			loadingImage2 = new Image(_loc2_);
			loadingImage2.pivotX = _loc2_.width * 0.5;
			loadingImage2.pivotY = _loc2_.height * 0.5;
			loadingImage2.scaleX = 0.5;
			loadingImage2.scaleY = 0.5;
			loadingImage2.alpha = 0;
			screen.addChild(loadingImage2);
			screenText.caretDelay = 15;
			screen.addChild(screenText);
			screen.addChild(loadingText);
			createPromotionButton();
			fadeOutTimer.addEventListener("timer", onFadeOutTimerUpdate);
			fadeOutTimer.addEventListener("timerComplete", onFadeOutTimerComplete);
			fadeInTimer.addEventListener("timer", onFadeInTimerUpdate);
			fadeInTimer.addEventListener("timerComplete", onFadeInTimerComplete);
			param1.addEventListener("resize", resize);
		}
		
		private function createPromotionButton():void
		{
			var bitmap:Bitmap;
			if (promotionUrl.length < 1)
			{
				return;
			}
			bitmap = new Promotion();
			promotionButton = new NativeImageButton(function():void
			{
				var _loc1_:URLRequest = new URLRequest(promotionUrl);
				navigateToURL(_loc1_, "_blank");
			}, bitmap.bitmapData);
			promotionButton.x = stage.stageWidth - promotionButton.width;
			promotionButton.y = stage.stageHeight - promotionButton.height;
			if (promotionUrl.length > 0)
			{
				Starling.current.nativeOverlay.addChild(promotionButton);
			}
		}
		
		private function createCustomPromotionButton(param1:String):void
		{
			var url:URLRequest;
			var img:Loader;
			var imgUrl:String = param1;
			if (imgUrl.length < 1)
			{
				return;
			}
			url = new URLRequest(imgUrl);
			img = new Loader();
			img.load(url);
			img.contentLoaderInfo.addEventListener("complete", function(param1:flash.events.Event):void
			{
				var e:flash.events.Event = param1;
				var bitmap:Bitmap = e.target.content;
				promotionButton = new NativeImageButton(function():void
				{
					var _loc1_:URLRequest = new URLRequest(promotionUrl);
					navigateToURL(_loc1_, "_blank");
				}, bitmap.bitmapData);
				if (promotionButton.width > 300)
				{
					promotionButton.width = 300;
				}
				if (promotionButton.height > 300)
				{
					promotionButton.height = 300;
				}
				promotionButton.x = stage.stageWidth - promotionButton.width;
				promotionButton.y = stage.stageHeight - promotionButton.height;
				if (promotionUrl.length > 0)
				{
					Starling.current.nativeOverlay.addChild(promotionButton);
				}
			});
		}
		
		private function onFadeOutTimerUpdate(param1:TimerEvent):void
		{
			screen.alpha = (fadeOutSteps - currentStep) / fadeOutSteps;
			currentStep++;
		}
		
		public function showHighscore(param1:Message):void
		{
			var _loc2_:Array = textsPvp[Math.floor(Math.random() * (texts.length - 0.1))];
			screenText.start(_loc2_);
			topPvpPlayersList = new TopPvPPlayersList();
			topPvpPlayersList.showHighscore(param1);
			screen.addChild(topPvpPlayersList);
			topPvpPlayersList.x = stage.stageWidth / 2 - topPvpPlayersList.width / 2;
			topPvpPlayersList.y = stage.stageHeight / 2 - topPvpPlayersList.height / 2;
			loadingImage.alpha = 0;
			loadingImage2.alpha = 1;
		}
		
		private function onFadeOutTimerComplete(param1:TimerEvent):void
		{
			screen.alpha = 0;
			if (topPvpPlayersList != null)
			{
				screen.removeChild(topPvpPlayersList);
				topPvpPlayersList.dispose();
				topPvpPlayersList = null;
			}
			screen.visible = false;
			stage.removeChild(screen);
			if (promotionButton != null && Starling.current.nativeOverlay.contains(promotionButton))
			{
				Starling.current.nativeOverlay.removeChild(promotionButton);
			}
			dispatchEvent(new starling.events.Event("fadeOutComplete"));
		}
		
		private function onFadeInTimerUpdate(param1:TimerEvent):void
		{
			screen.alpha = currentStep / fadeInSteps;
			currentStep++;
		}
		
		private function onFadeInTimerComplete(param1:TimerEvent):void
		{
			loadingText.visible = true;
			screen.alpha = 1;
			loadingImage.alpha = 1;
			loadingImage2.alpha = 0;
			dispatchEvent(new starling.events.Event("fadeInComplete"));
		}
		
		public function show():void
		{
			var textArray:Array;
			if (Login.START_SETUP_IS_ACTIVE)
			{
				return;
			}
			loadingImage.visible = true;
			if (!stage.contains(screen))
			{
				stage.addChildAt(screen, 0);
			}
			if (promotionButton != null && !Starling.current.nativeOverlay.contains(promotionButton) && promotionUrl.length > 0)
			{
				Starling.current.nativeOverlay.addChild(promotionButton);
			}
			else if (Game.instance)
			{
				Game.instance.rpcServiceRoom("getPromotionImage", (function():*
				{
					var rpcHandler:Function;
					return rpcHandler = function(param1:Message):void
					{
						promotionUrl = param1.getString(0);
						createCustomPromotionButton(param1.getString(1));
					};
				})());
			}
			loadingText.visible = true;
			textArray = texts[Math.floor(Math.random() * (texts.length - 0.1))];
			screenText.start(textArray);
			screenText.visible = true;
			screen.visible = true;
			fadeOutTimer.stop();
			fadeInTimer.stop();
			fadeOutTimer.reset();
			fadeInTimer.reset();
			screen.alpha = 1;
			currentStep = 0;
			stage.addEventListener("enterFrame", update);
		}
		
		public function fadeIn():void
		{
			Console.write("faaaaaade in fade screen");
			loadingImage.visible = false;
			if (!stage.contains(screen))
			{
				stage.addChildAt(screen, 0);
			}
			if (promotionButton != null && Starling.current.nativeOverlay.contains(promotionButton))
			{
				Starling.current.nativeOverlay.removeChild(promotionButton);
			}
			if (screen.alpha == 1 && screen.visible)
			{
				dispatchEvent(new starling.events.Event("fadeInComplete"));
				return;
			}
			screen.visible = true;
			stage.addEventListener("enterFrame", update);
			fadeOutTimer.stop();
			fadeInTimer.stop();
			fadeOutTimer.reset();
			fadeInTimer.reset();
			screen.alpha = 0;
			currentStep = 0;
			fadeInTimer.start();
		}
		
		public function fadeOut():void
		{
			if (promotionButton != null && Starling.current.nativeOverlay.contains(promotionButton))
			{
				Starling.current.nativeOverlay.removeChild(promotionButton);
			}
			if (!stage.contains(screen))
			{
				return;
			}
			loadingText.visible = false;
			stage.removeEventListener("enterFrame", update);
			screen.alpha = 1;
			currentStep = 0;
			screenText.visible = false;
			fadeOutTimer.stop();
			fadeInTimer.stop();
			fadeOutTimer.reset();
			fadeInTimer.reset();
			fadeOutTimer.start();
		}
		
		private function update(param1:EnterFrameEvent):void
		{
			loadingImage.rotation += 0.002;
			loadingImage.x = stage.stageWidth / 2;
			loadingImage.y = stage.stageHeight / 2;
			loadingImage2.rotation += 0.002;
			loadingImage2.x = stage.stageWidth - loadingImage2.texture.width * 0.25 - 25;
			loadingImage2.y = stage.stageHeight - loadingImage2.texture.height * 0.25 - 25;
		}
		
		public function dispose():void
		{
			Console.write("Disposed screen!");
			fadeOutTimer.removeEventListener("timer", onFadeOutTimerUpdate);
			fadeOutTimer.removeEventListener("timerComplete", onFadeOutTimerComplete);
			fadeInTimer.removeEventListener("timer", onFadeInTimerUpdate);
			fadeInTimer.removeEventListener("timerComplete", onFadeInTimerComplete);
			screen.removeChild(screenText);
			stage.removeChild(screen);
			if (Starling.current.nativeOverlay.contains(promotionButton))
			{
				Starling.current.nativeOverlay.removeChild(promotionButton);
			}
			if (topPvpPlayersList != null)
			{
				topPvpPlayersList.dispose();
				topPvpPlayersList = null;
			}
			stage.removeEventListener("enterFrame", update);
			stage.removeEventListener("resize", resize);
			tween.kill();
			tween2.kill();
			bgrQuad.dispose();
		}
		
		public function repositionScreen(param1:DisplayObjectContainer):void
		{
			param1.addChild(screen);
		}
		
		private function resize(param1:starling.events.Event = null):void
		{
			bgrQuad.width = stage.stageWidth;
			bgrQuad.height = stage.stageHeight;
			screenText.x = 20;
			screenText.y = 40;
			loadingText.x = 20;
			loadingText.y = stage.stageHeight - 40;
			if (promotionButton)
			{
				promotionButton.x = stage.stageWidth - promotionButton.width;
				promotionButton.y = stage.stageHeight - promotionButton.height;
			}
		}
	}
}
