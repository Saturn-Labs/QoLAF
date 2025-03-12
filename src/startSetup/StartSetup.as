package startSetup
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Expo;
	import core.hud.components.Button;
	import core.hud.components.ScreenTextField;
	import core.hud.components.Text;
	import core.parallax.ParallaxManager;
	import data.DataLocator;
	import data.IDataManager;
	import flash.utils.getTimer;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.filters.DropShadowFilter;
	import starling.filters.GlowFilter;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class StartSetup extends Sprite implements IStartSetup
	{
		private var _skin:String = "hiTDnI9Ex0iLeFAktBnX0w";
		private var _pvp:Boolean = false;
		private var _split:String = "";
		public var _joinName:String = "";
		private var textureManager:ITextureManager;
		
		private var dataManager:IDataManager;
		
		private var confirmButton:Button;
		
		private var pvpButton:Button;
		
		private var stf:ScreenTextField;
		
		private var description:Text;
		
		private var space:Sprite;
		
		private var timeAdjust:Number = 1;
		private const SELECT_PVP:Boolean = false;
		private var skipWakeUpCaptain:Boolean = true;
		private var skinStats:StartShipBaseStats;
		
		private var pickShipButton1:PickButton;
		
		private var pickShipButton2:PickButton;
		
		private var pickShipButton3:PickButton;
		
		private var pm:ParallaxManager;
		
		private var soundManager:ISound;
		
		private var speedUpSpace:Boolean = false;
		private var freezeSpace:Boolean = false;
		private var logBook:Text;
		
		private var textIndex:int = 0;
		private var shakeTween1:TweenMax;
		
		private var shakeTween2:TweenMax;
		
		private var ships:Array;
		
		private var isRunning:Boolean;
		
		private var _progressText:Text;
		
		private var _timer:Date;
		
		private var _timeStart:int;
		
		public function StartSetup()
		{
			space = new Sprite();
			ships = new Array(3);
			_progressText = new Text();
			_timer = new Date();
			super();
			Login.START_SETUP_IS_ACTIVE = true;
			textureManager = TextureLocator.getService();
			dataManager = DataLocator.getService();
			if (stage)
			{
				initSelectShip();
			}
			else
			{
				addEventListener("addedToStage", initSelectShip);
			}
		}
		
		public static function showProgressText(param1:String):void
		{
			var _loc3_:IStartSetup = StartSetupLocator.getService();
			if (!_loc3_)
			{
				return;
			}
			if (!_loc3_.timer)
			{
				_loc3_.timeStart = getTimer();
			}
			if (!Login.START_SETUP_IS_ACTIVE)
			{
				return;
			}
			_loc3_.progressText.color = 16777215;
			var _loc2_:Number = getTimer() - _loc3_.timeStart;
			_loc2_ /= 100;
			_loc3_.progressText.text = param1;
			_loc3_.progressText.x = _loc3_.getStage.stageWidth / 2;
			_loc3_.progressText.y = _loc3_.getStage.stageHeight - 40;
			_loc3_.progressText.pivotX = _loc3_.progressText.width / 2;
			_loc3_.progressText.pivotY = _loc3_.progressText.height / 2;
			if (_loc3_.sprite.contains(_loc3_.progressText))
			{
				return;
			}
			_loc3_.sprite.addChild(_loc3_.progressText);
		}
		
		public static function hideProgressText(param1:String):void
		{
			var s:String = param1;
			var instance:IStartSetup = StartSetupLocator.getService();
			TweenMax.to(instance.progressText, 1, {"y": -100, "alpha": 0, "onComplete": function():void
			{
				instance.sprite.removeChild(instance.progressText);
			}});
		}
		
		public function get skin():String
		{
			return _skin;
		}
		
		public function get pvp():Boolean
		{
			return _pvp;
		}
		
		public function get split():String
		{
			return _split;
		}
		
		private function initSelectShip(param1:Event = null):void
		{
			var dataManager:IDataManager;
			var obj:Object;
			var e:Event = param1;
			removeEventListener("addedToStage", initSelectShip);
			if (Login.START_SETUP_IS_DONE)
			{
				return;
			}
			soundManager = SoundLocator.getService();
			soundManager.preCacheSound("z3gJhEGBNk-cdQCSQ0-AKA");
			soundManager.preCacheSound("IOO5z1CeyESgoUp0yIuIPQ");
			removeChildren(0, -1, true);
			dataManager = DataLocator.getService();
			obj = dataManager.loadKey("SolarSystems", "HrAjOBivt0SHPYtxKyiB_Q");
			pm = new ParallaxManager(null, space, true);
			addChild(space);
			pm.load(obj, function():void
			{
				var d:DisplayObject;
				pm.randomize();
				pm.refresh();
				isRunning = true;
				run();
				for each (d in pm.nebulas)
				{
					TweenMax.to(d, 1 / timeAdjust, {"alpha": 1});
				}
				selectEscapeVessel();
				confirmButton = new Button(function():void
				{
					sleepCaptain();
				}, "Go now!", "positive", 18);
			});
		}
		
		private function playWarningSound():void
		{
			if (!speedUpSpace)
			{
				soundManager.play("z3gJhEGBNk-cdQCSQ0-AKA", null);
			}
		}
		
		private function sleepCaptain():void
		{
			removeChild(confirmButton);
			soundManager.play("IOO5z1CeyESgoUp0yIuIPQ");
			TweenMax.to(stf, 0.5, {"y": 100, "onComplete": function():void
			{
				TweenMax.to(description, 0.5, {"y": -100, "onComplete": function():void
				{
					removeChild(description, true);
				}});
				TweenMax.to(pickShipButton1, 0.5, {"y": -100, "onComplete": function():void
				{
					removeChild(pickShipButton1, true);
				}});
				TweenMax.to(pickShipButton2, 0.5, {"y": -100, "onComplete": function():void
				{
					removeChild(pickShipButton2, true);
				}});
				TweenMax.to(pickShipButton3, 0.5, {"y": -100, "onComplete": function():void
				{
					removeChild(pickShipButton3, true);
				}});
				TweenMax.to(skinStats, 0.5, {"y": -100, "onComplete": function():void
				{
					removeChild(skinStats, true);
				}});
				stopShake();
				speedUpSpace = true;
				freezeSpace = false;
				TweenMax.delayedCall(3 / timeAdjust, function():void
				{
					TweenMax.to(stf, 1 / timeAdjust, {"y": -100, "alpha": 0});
				});
				startGameFriendly();
			}});
		}
		
		private function wakeUpCaptain():void
		{
			speedUpSpace = false;
			freezeSpace = false;
			pm.randomize();
			TweenMax.to(space, 3 / timeAdjust, {"alpha": 1});
			confirmButton.text = "Uh, ok.";
			confirmButton.enabled = true;
			confirmButton.callback = startGameFriendly;
			removeChild(confirmButton);
			logBook = new Text();
			logBook.width = 500;
			logBook.wordWrap = true;
			logBook.height = 250;
			logBook.x = stage.stageWidth / 2;
			logBook.y = 100;
			logBook.font = "Verdana";
			logBook.color = 16777215;
			logBook.size = 13;
			logBook.pivotX = logBook.width / 2;
			logBook.alpha = 0;
			logBook.text = "We've been forced to abandon our beloved and peaceful home planet Homerus. They have destroyed everything. \n\nThree of us managed to escape in one of the emergency vessels before the alien invasion. We expect to be travelling for 3 years to reach Hyperion, the closest star system. \n\nI hope we make it there. \n\nAzuron, December 12, year 2149.\nCaptain " + _joinName;
			if (!RymdenRunt.isBuggedFlashVersion)
			{
				logBook.filter = new GlowFilter(3725567);
			}
			addChild(logBook);
			TweenMax.to(logBook, 2.5 / timeAdjust, {"alpha": 1, "delay": 1, "onComplete": function():void
			{
				confirmButton.y -= 60;
				addChild(confirmButton);
			}});
		}
		
		private function run():void
		{
			if (!isRunning)
			{
				return;
			}
			if (speedUpSpace)
			{
				pm.cx += 2;
			}
			else
			{
				pm.cx = 3;
				pm.cy = 2;
			}
			if (freezeSpace)
			{
				pm.cx = 0;
				pm.cy = 0;
			}
			pm.update();
			pm.draw();
			TweenMax.delayedCall(0.05, run);
		}
		
		private function addAnimatedText(param1:String, param2:Number, param3:Number, param4:int = 0, param5:int = 0, param6:String = "", param7:int = 32, param8:uint = 16777215, param9:uint = 16777215, param10:Number = 0):void
		{
			if (stf != null && contains(stf))
			{
				stf.onAnimationFinished();
				removeChild(stf);
			}
			stf = new ScreenTextField(800, 100, param2, param8, param9, param10);
			stf.id = param6;
			stf.paragraphInitTime = 200;
			stf.pageReadTime = param3;
			stf.paragraphReadTime = 480;
			stf.format.size = param7;
			stf.y = param5;
			if (param4 == -1)
			{
				param4 = stf.getFullWidth(param1, param7);
				param4 = param4 / 2;
			}
			stf.x = stage.stageWidth / 2 - param4;
			addChild(stf);
			stf.start([[param1]]);
			stf.addEventListener("animationFinished", onAnimationFinished);
			textIndex++;
		}
		
		private function shakeTween(param1:DisplayObject, param2:int = 100000):void
		{
			shakeTween1 = TweenMax.to(param1, 0.1, {"repeat": param2 - 1, "y": param1.y + (1 + Math.random() * 10), "x": param1.x + (1 + Math.random() * 10), "delay": 0.1, "ease": Expo.easeInOut});
			shakeTween2 = TweenMax.to(param1, 0.1, {"y": param1.y, "x": param1.x, "delay": (param2 + 1) * 0.1, "ease": Expo.easeInOut});
		}
		
		private function stopShake():void
		{
			if (shakeTween1)
			{
				shakeTween1.kill();
			}
			if (shakeTween2)
			{
				shakeTween2.kill();
			}
			shakeTween1 = null;
			shakeTween2 = null;
		}
		
		protected function onAnimationFinished(param1:Object):void
		{
			if (contains(stf))
			{
				removeChild(stf);
			}
			if (stf.id == "emergency")
			{
				addAnimatedText("We are under attack!", 3000, 1100, -1, 120, "underAttack", 42, 11541783, 13567494);
			}
			else if (stf.id == "underAttack")
			{
				selectEscapeVessel();
			}
			else if (stf.id != "selectShip")
			{
				if (stf.id == "3years")
				{
					if (skipWakeUpCaptain)
					{
						return startGameFriendly();
					}
					resetStf();
					addAnimatedText("You wake up and read the Captain's log", 3000, 2100, -1, 120, "wakeUp", 24);
					stf.format.size = 20;
					stf.x += 40;
					TweenMax.delayedCall(3 / timeAdjust, wakeUpCaptain);
				}
			}
		}
		
		private function selectEscapeVessel():void
		{
			addAnimatedText("Quick! Select escape vessel:", 10000, 21000, -1, 100, "selectShip", 26, 16777215, 16777215, 10000);
			TweenMax.delayedCall(1 / timeAdjust, addShips);
			soundManager.preCacheSound("_BsBOsabf0WbIWdzrshcNg");
		}
		
		private function addShips():void
		{
			freezeSpace = true;
			pickShipButton1 = new PickButton("player_aerodeck", function():void
			{
				changeSkin("hiTDnI9Ex0iLeFAktBnX0w", pickShipButton1);
			});
			pickShipButton2 = new PickButton("player_tramsnitter", function():void
			{
				changeSkin("Ijt0GhS0hkS09bixHLNEYg", pickShipButton2);
			});
			pickShipButton3 = new PickButton("player_pixi", function():void
			{
				changeSkin("tx2VGh3l-U2Krrb4jmasjw", pickShipButton3);
			});
			fillShipsArray();
			ships[1].x = stage.stageWidth / 2;
			ships[0].x = ships[1].x - 130;
			ships[2].x = ships[1].x + 130;
			pickShipButton1.y = 240;
			pickShipButton2.y = 240;
			pickShipButton3.y = 240;
			addChild(pickShipButton1);
			addChild(pickShipButton2);
			addChild(pickShipButton3);
			pickShipButton1.alpha = 0;
			pickShipButton2.alpha = 0;
			pickShipButton3.alpha = 0;
			pickShipButton1.deselect();
			pickShipButton2.deselect();
			pickShipButton3.deselect();
			TweenMax.to(pickShipButton1, 0.6 / timeAdjust, {"alpha": 1});
			TweenMax.to(pickShipButton2, 0.6 / timeAdjust, {"alpha": 1, "delay": 0.3 / timeAdjust});
			TweenMax.to(pickShipButton3, 0.6 / timeAdjust, {"alpha": 1, "delay": 0.6 / timeAdjust});
		}
		
		private function fillShipsArray(param1:int = 0):void
		{
			var _loc2_:PickButton = null;
			var _loc4_:int = 0;
			if (param1 == 3)
			{
				return;
			}
			var _loc3_:Number = Math.random();
			if (_loc3_ < 0.3333333333333333)
			{
				_loc2_ = pickShipButton1;
			}
			else if (_loc3_ < 0.6666666666666666)
			{
				_loc2_ = pickShipButton2;
			}
			else
			{
				_loc2_ = pickShipButton3;
			}
			_loc4_ = 0;
			while (_loc4_ <= param1)
			{
				if (ships[_loc4_] == _loc2_)
				{
					return fillShipsArray(param1);
				}
				_loc4_++;
			}
			ships[param1] = _loc2_;
			param1++;
			fillShipsArray(param1);
		}
		
		private function resetStf():void
		{
			stf.onAnimationFinished();
			stf.createFadeOutPage("")(null);
		}
		
		private function changeSkin(param1:String, param2:PickButton):void
		{
			var obj:Object;
			var skin:String = param1;
			var button:PickButton = param2;
			stf.stop();
			pickShipButton1.deselect();
			pickShipButton2.deselect();
			pickShipButton3.deselect();
			button.select();
			if (!contains(description))
			{
				description = new Text();
				description.size = 13;
				addChild(description);
				description.y = 135;
				if (!RymdenRunt.isBuggedFlashVersion)
				{
					description.filter = new DropShadowFilter();
				}
				description.color = 16698179;
				description.x = stage.stageWidth / 2;
				addChild(confirmButton);
				confirmButton.x = stage.stageWidth / 2;
				confirmButton.y = 480;
				confirmButton.pivotX = confirmButton.width / 2;
				confirmButton.pivotY = confirmButton.height / 2;
				confirmButton.alpha = 0;
				TweenMax.to(confirmButton, 2, {"alpha": 1});
			}
			description.scaleX = 0;
			description.alpha = 0;
			this._skin = skin;
			removeChild(skinStats);
			obj = dataManager.loadKey("Skins", skin);
			if (button == pickShipButton1)
			{
				description.text = obj.description;
				skinStats = new StartShipBaseStats(obj, 2);
			}
			else if (button == pickShipButton2)
			{
				description.text = obj.description;
				skinStats = new StartShipBaseStats(obj, 2);
			}
			else
			{
				description.text = obj.description;
				skinStats = new StartShipBaseStats(obj, 2);
			}
			description.pivotX = description.width / 2;
			TweenMax.to(description, 0.5 / timeAdjust, {"alpha": 1, "scaleX": 1});
			TweenMax.to(skinStats, 0.5 / timeAdjust, {"alpha": 0, "onComplete": function():void
			{
				skinStats.x = stage.stageWidth / 2 - skinStats.width / 2;
				skinStats.y = 300;
				skinStats.alpha = 0;
				addChild(skinStats);
				TweenMax.to(skinStats, 0.01, {"alpha": 1, "onComplete": function():void
				{
				}});
			}});
			addAnimatedText(obj.name, 3000, 0, -1, 70, obj.name, 32, 16777215, 16777215, 4000);
		}
		
		public function get timer():Date
		{
			return _timer;
		}
		
		public function set timeStart(param1:int):void
		{
			_timeStart = param1;
		}
		
		public function get timeStart():int
		{
			return _timeStart;
		}
		
		public function get progressText():Text
		{
			return _progressText;
		}
		
		public function get sprite():Sprite
		{
			return this;
		}
		
		public function set joinName(param1:String):void
		{
			_joinName = param1;
		}
		
		public function get getStage():Stage
		{
			return stage;
		}
		
		private function logBookRead(param1:Event):void
		{
			TweenMax.to(logBook, 3, {"alpha": 0});
		}
		
		private function startGameFriendly(param1:Event = null):void
		{
			Login.START_SETUP_IS_DONE = true;
			dispatchEventWith("complete");
			confirmButton.visible = false;
			if (logBook != null)
			{
				TweenMax.to(logBook, 3, {"alpha": 0});
			}
		}
		
		private function startGameHostile(param1:Event = null):void
		{
			Login.START_SETUP_IS_DONE = true;
			_pvp = true;
			dispatchEventWith("complete");
			pvpButton.visible = false;
			confirmButton.visible = false;
			TweenMax.to(logBook, 3, {"alpha": 0});
		}
	}
}
