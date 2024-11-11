package core.hud.components.explore
{
	import core.credits.CreditManager;
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.HudTimer;
	import core.hud.components.TextBitmap;
	import core.hud.components.ToolTip;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.player.CrewMember;
	import core.player.Explore;
	import core.scene.Game;
	import core.solarSystem.Area;
	import core.solarSystem.Body;
	import debug.Console;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import playerio.Message;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;

	public class ExploreArea extends Sprite
	{
		public static var COLOR:uint = 3225899;
		private var min:Number = 0;
		private var max:Number = 1;
		private var value:Number = 0;
		private var _exploring:Boolean = false;
		private var finished:Boolean = false;
		private var failed:Boolean = false;
		private var successfulEvents:int = 0;
		private var totalEvents:int = 0;
		public var lootClaimed:Boolean = false;
		private var confirmInstantExploreBox:CreditBuyBox;
		private var actionButton:Button;
		public var body:Body;
		private var g:Game;
		private var timer:Timer;
		private var startTime:Number = 0;
		private var finishTime:Number = 0;
		private var failTime:Number = 0;
		private var areaTypes:Dictionary;
		private var playerExplores:Dictionary;
		public var areaKey:String;
		public var level:Number;
		public var rewardLevel:Number;
		public var size:int;
		private var areaName:TextBitmap;
		public var type:int;
		public var specialTypes:Array;
		private var teamKey:String = null;
		private var progressBar:ExploreProgressBar;
		private var box:Box;
		private var boxFinished:Box;
		private var exploreMapArea:ExploreMapArea;
		private var exploreTimer:HudTimer;
		private var overlay:Sprite;
		private var exploreStartedCallback:Function = null;
		public function ExploreArea(param1:Game, param2:ExploreMap, param3:Body, param4:String, param5:String, param6:Number, param7:Number, param8:int, param9:int, param10:Array, param11:String, param12:int, param13:Boolean, param14:Boolean, param15:Boolean, param16:Number, param17:Number, param18:Number)
		{
			timer = new Timer(1000, 1);
			this.level = param6;
			this.rewardLevel = param7;
			this.size = param8;
			this.type = param9;
			this.specialTypes = param10;
			this.name = param11;
			this.g = param1;
			this.body = param3;
			this.areaKey = param4;
			this.teamKey = param5;
			this.areaTypes = areaTypes;
			this.playerExplores = playerExplores;
			this.finished = param14;
			this.failed = param13;
			this.successfulEvents = param12;
			this.totalEvents = param8 + 4;
			this.lootClaimed = param15;
			this.failTime = param16;
			this.finishTime = param17;
			this.startTime = param18;
			super();
			var _loc22_:String = "9iZrZ9p5nEWqrPhkxTYNgA";
			var _loc23_:* = 2868903748;
			exploreMapArea = param2.getMapArea(param4);
			if (param9 == 0)
			{
				_loc22_ = "oGIhRDJPa0mDobL-DLecdA";
				_loc23_ = Area.COLORTYPE[0];
			}
			else if (param9 == 1)
			{
				_loc22_ = "xGIhC6OP6k-ynT1KpLQX3w";
				_loc23_ = Area.COLORTYPE[1];
			}
			else if (param9 == 2)
			{
				_loc22_ = "xGIhC6OP6k-ynT1KpLQX3w";
				_loc23_ = Area.COLORTYPE[2];
			}
			box = new Box(610, 60, "light", 0.95, 12);
			addChild(box);
			areaName = new TextBitmap();
			areaName.size = 22;
			areaName.format.color = Area.COLORTYPE[param9];
			areaName.text = param11;
			areaName.x = 4;
			areaName.y = -6;
			addChild(areaName);
			while (areaName.width > 390)
			{
				areaName.size--;
			}
			var _loc20_:ITextureManager = TextureLocator.getService();
			var _loc19_:int = 0;
			addSkillIcon(_loc20_.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SKILLS[param9]), _loc19_, Area.SKILLTYPE[param9]);
			for each (var _loc21_:* in param10)
			{
				_loc19_++;
				addSkillIcon(_loc20_.getTextureGUIByTextureName(CrewDisplayBox.IMAGES_SPECIALS[_loc21_]), _loc19_, Area.SPECIALTYPE[_loc21_]);
			}
			actionButton = new Button(null, "DEPLOY TEAM", "positive");
			actionButton.y = 0;
			actionButton.x = 0;
			actionButton.size = 13;
			actionButton.visible = false;
			addChild(actionButton);
			progressBar = new ExploreProgressBar(param1, param3, progressBarOnComplete, param9);
			progressBar.x = 6;
			progressBar.y = 36;
			addChild(progressBar);
			if (param12 == 0 && param16 == 0)
			{
				handleNotStarted();
			}
			else if (!param15 && param16 < param1.time)
			{
				handleClaimLoot();
			}
			else if (param12 < totalEvents && param16 < param1.time)
			{
				handleFailed();
			}
			else if (param14 && param12 == totalEvents && param16 < param1.time)
			{
				handleFinished();
			}
			else
			{
				resume();
			}
		}

		public function addSkillIcon(param1:Texture, param2:int, param3:String):void
		{
			var _loc5_:Image = new Image(param1);
			_loc5_.x = areaName.x + areaName.width + 10 + 20 * param2;
			_loc5_.y = 4;
			var _loc4_:Sprite = new Sprite();
			_loc4_.addChild(_loc5_);
			new ToolTip(g, _loc4_, param3, null, "skill");
			addChild(_loc4_);
		}

		public function adjustTimeEstimate(param1:Number):Number
		{
			if (successfulEvents > 0)
			{
				param1 = param1 * (totalEvents - successfulEvents) / totalEvents;
			}
			else if (failTime != 0 && failTime > g.time)
			{
				param1 *= 1 - (g.time - startTime) / (finishTime - startTime);
			}
			return param1;
		}

		public function updateExploreObj():void
		{
			var _loc1_:Explore = g.me.getExploreByKey(areaKey);
			if (_loc1_ != null)
			{
				_loc1_.lootClaimed = true;
				_loc1_.finished = true;
				_loc1_.failed = true;
				_loc1_.finished = true;
			}
		}

		public function updateState(param1:Boolean):void
		{
			this.lootClaimed = param1;
			if (successfulEvents < totalEvents)
			{
				failed = true;
			}
			if (successfulEvents == totalEvents)
			{
				finished = true;
			}
			updateExploreObj();
			if (successfulEvents == 0 && !failed && failTime < g.time)
			{
				handleNotStarted();
			}
			else if (!param1 && failTime < g.time)
			{
				handleClaimLoot();
			}
			else if (successfulEvents < totalEvents && failTime < g.time)
			{
				handleFailed();
			}
			else if (finished && successfulEvents == totalEvents && failTime < g.time)
			{
				handleFinished();
			}
			else
			{
				resume();
			}
		}

		private function handleStarted():void
		{
			adjustActionButton();
			actionButton.visible = false;
		}

		private function adjustActionButton():void
		{
			actionButton.x = progressBar.x + progressBar.width + 10;
			actionButton.y = progressBar.y - 6;
			actionButton.visible = true;
		}

		private function progressBarOnComplete():void
		{
			Console.write("progressBarOnComplete");
			actionButton.visible = true;
			actionButton.callback = showRewardScreen;
			if (exploreTimer != null && contains(exploreTimer))
			{
				removeChild(exploreTimer);
			}
			actionButton.text = "CLAIM REWARD";
			adjustActionButton();
			actionButton.enabled = true;
		}

		private function handleClaimLoot():void
		{
			Console.write("handle claim loot");
			progressBarOnComplete();
			progressBar.setValueAndEffect((successfulEvents + 1) / (totalEvents + 1), successfulEvents < totalEvents);
		}

		private function handleFailed():void
		{
			Console.write("handle failed");
			actionButton.visible = true;
			progressBar.setValueAndEffect((successfulEvents + 1) / (totalEvents + 1), true);
			actionButton.callback = showSelectTeam;
			actionButton.text = "DEPLOY TEAM";
			adjustActionButton();
			actionButton.enabled = true;
		}

		private function handleNotStarted():void
		{
			Console.write("hadnle not started");
			actionButton.visible = true;
			progressBar.setValueAndEffect(0);
			actionButton.callback = showSelectTeam;
			actionButton.text = "DEPLOY TEAM";
			adjustActionButton();
			actionButton.enabled = true;
		}

		public function handleFinished():void
		{
			Console.write("handle finished");
			removeChild(actionButton);
			progressBar.setMax();
			boxFinished = new Box(610, 60, "normal", 0.8, 13);
			var _loc1_:TextField = new TextField(610, 60, "EXPLORED!", new TextFormat("font13", 20, 16777215));
			boxFinished.x = 0;
			boxFinished.y = 0;
			addChild(boxFinished);
			addChild(_loc1_);
			removeChild(progressBar);
		}

		private function showSelectTeam(param1:TouchEvent = null):void
		{
			dispatchEvent(new Event("showSelectTeam"));
		}

		public function startExplore(param1:Vector.<CrewDisplayBox>, param2:Function = null):void
		{
			exploreStartedCallback = param2;
			requestStartExplore(param1);
		}

		private function requestStartExplore(param1:Vector.<CrewDisplayBox> = null):void
		{
			if (param1 == null)
			{
				return;
			}
			var _loc2_:String = "";
			for each (var _loc3_:* in param1)
			{
				if (_loc2_ != "")
				{
					_loc2_ += " ";
				}
				_loc2_ += _loc3_.key;
			}
			actionButton.enabled = false;
			g.rpc("startExplore", exploreStarted, areaKey, param1.length, _loc2_);
		}

		private function resume():void
		{
			Console.write("resume");
			progressBar.start(startTime, finishTime, failTime);
			if (exploreTimer != null && contains(exploreTimer))
			{
				exploreTimer.stop();
				removeChild(exploreTimer);
			}
			exploreTimer = new HudTimer(g);
			exploreTimer.start(startTime, finishTime);
			exploreTimer.x = 520;
			exploreTimer.y = 0;
			actionButton.callback = instant;
			actionButton.text = " Speed up! ";
			actionButton.enabled = true;
			adjustActionButton();
			addChild(exploreTimer);
		}

		private function exploreStarted(param1:Message):void
		{
			var _loc2_:Explore = null;
			var _loc4_:int = 0;
			var _loc7_:int = 0;
			var _loc6_:String = null;
			var _loc3_:String = null;
			if (param1.getBoolean(0))
			{
				if (exploreStartedCallback != null)
				{
					exploreStartedCallback();
				}
				g.tutorial.showExploreAdvice2();
				_loc2_ = g.me.getExploreByKey(areaKey);
				if (_loc2_ == null)
				{
					_loc2_ = new Explore();
				}
				startTime = param1.getNumber(1);
				finishTime = param1.getNumber(2);
				failTime = param1.getNumber(3);
				successfulEvents = param1.getNumber(4);
				_loc2_.areaKey = areaKey;
				_loc2_.bodyKey = body.key;
				_loc2_.finished = false;
				_loc2_.failTime = failTime;
				_loc2_.startTime = startTime;
				_loc2_.finishTime = finishTime;
				_loc2_.lootClaimed = false;
				_loc2_.successfulEvents = successfulEvents;
				_loc2_.startEvent = 0;
				g.me.explores.push(_loc2_);
				progressBar.start(startTime, finishTime, failTime);
				if (exploreTimer != null && contains(exploreTimer))
				{
					exploreTimer.stop();
					removeChild(exploreTimer);
				}
				exploreTimer = new HudTimer(g);
				exploreTimer.start(startTime, finishTime);
				exploreTimer.x = 520;
				exploreTimer.y = 0;
				actionButton.callback = instant;
				actionButton.visible = true;
				actionButton.text = " Speed up! ";
				actionButton.enabled = true;
				addChild(exploreTimer);
				if (contains(actionButton))
				{
					removeChild(actionButton);
				}
				addChild(actionButton);
				_loc4_ = param1.getInt(5);
				_loc7_ = 6;
				while (_loc7_ < 7 + (_loc4_ - 1) * 5)
				{
					_loc6_ = param1.getString(_loc7_);
					for each (var _loc5_:* in g.me.crewMembers)
					{
						if (_loc5_.key == _loc6_)
						{
							_loc5_.solarSystem = param1.getString(_loc7_ + 1);
							_loc5_.body = param1.getString(_loc7_ + 2);
							_loc5_.area = param1.getString(_loc7_ + 3);
							_loc5_.fullLocation = param1.getString(_loc7_ + 4);
							break;
						}
					}
					_loc7_ += 5;
				}
				exploreMapArea.explore = _loc2_;
			}
			else
			{
				actionButton.enabled = true;
				_loc3_ = param1.getString(1);
				if (_loc3_ == "occupied")
				{
					g.showErrorDialog("One of crew members is occupied exploring somewhere else.");
					return;
				}
				if (_loc3_ == "injured")
				{
					g.showErrorDialog("One of crew members is injured.");
					return;
				}
				if (_loc3_ == "training")
				{
					g.showErrorDialog("One of crew members is busy training.");
					return;
				}
				if (_loc3_ == "explored")
				{
					g.showErrorDialog("You can't explore this area.");
					return;
				}
			}
		}

		public function update():void
		{
			exploreMapArea.update();
			progressBar.update();
			if (exploreTimer != null)
			{
				exploreTimer.update();
			}
		}

		public function stopEffect():void
		{
			progressBar.stopEffect();
		}

		public function set exploring(param1:Boolean):void
		{
			this._exploring = param1;
		}

		private function showRewardScreen(param1:TouchEvent = null):void
		{
			actionButton.enabled = false;
			dispatchEvent(new Event("showRewardScreen"));
		}

		public function get success():Boolean
		{
			if (finished && lootClaimed)
			{
				return true;
			}
			return false;
		}

		public function get failedValue():Number
		{
			return (failTime - startTime) / (finishTime - startTime);
		}

		private function instantExplore(param1:Message):void
		{
			if (!param1.getBoolean(0))
			{
				actionButton.enabled = true;
				g.showErrorDialog(param1.getString(1));
				return;
			}
			var _loc3_:int = CreditManager.getCostInstant(size);
			Game.trackEvent("used flux", "instant explore", "size " + size, _loc3_);
			SoundLocator.getService().play("7zeIcPFb-UWzgtR_3nrZ8Q");
			g.creditManager.refresh();
			g.showErrorDialog("Explore completed!");
			var _loc2_:Explore = g.me.getExploreByKey(areaKey);
			_loc2_.finishTime = param1.getNumber(1);
			finishTime = _loc2_.finishTime;
			_loc2_.failTime = param1.getNumber(2);
			failTime = _loc2_.failTime;
			_loc2_.successfulEvents = param1.getInt(3);
			successfulEvents = _loc2_.successfulEvents;
			_loc2_.finished = true;
			finished = true;
			_loc2_.lootClaimed = false;
			lootClaimed = false;
			if (contains(exploreTimer))
			{
				exploreTimer.stop();
				removeChild(exploreTimer);
			}
			progressBar.stop();
			progressBar.setValueAndEffect(1, false);
			progressBarOnComplete();
			exploreMapArea.explore = _loc2_;
		}

		private function sendInstant():void
		{
			g.rpc("buyInstantExplore", instantExplore, areaKey);
		}

		private function instant(param1:TouchEvent = null):void
		{
			var e:TouchEvent = param1;
			g.creditManager.refresh(function():void
				{
					var _loc1_:int = CreditManager.getCostInstant(size);
					confirmInstantExploreBox = new CreditBuyBox(g, _loc1_, "Are you sure you want to buy instant explore?");
					g.addChildToOverlay(confirmInstantExploreBox);
					confirmInstantExploreBox.addEventListener("accept", onAccept);
					confirmInstantExploreBox.addEventListener("close", onClose);
				});
		}

		private function onAccept(param1:Event):void
		{
			sendInstant();
			confirmInstantExploreBox.removeEventListener("accept", onAccept);
			confirmInstantExploreBox.removeEventListener("close", onClose);
		}

		private function onClose(param1:Event):void
		{
			actionButton.enabled = true;
			confirmInstantExploreBox.removeEventListener("accept", onAccept);
			confirmInstantExploreBox.removeEventListener("close", onClose);
		}

		private function send(param1:TouchEvent):void
		{
			g.removeChildFromOverlay(overlay);
			actionButton.enabled = true;
			showSelectTeam();
		}

		override public function dispose():void
		{
			if (exploreMapArea)
			{
				exploreMapArea.dispose();
			}
			super.dispose();
		}
	}
}
