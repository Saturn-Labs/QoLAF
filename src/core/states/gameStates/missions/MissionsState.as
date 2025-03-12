package core.states.gameStates.missions
{
	import com.greensock.TweenMax;
	import core.hud.components.ButtonExpandableHud;
	import core.player.Mission;
	import core.scene.Game;
	import core.states.gameStates.PlayState;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class MissionsState extends PlayState
	{
		private var goTo:String;
		
		private var bg:Image;
		
		private var closeButton:ButtonExpandableHud;
		
		private var storyButton:ButtonExpandableHud;
		
		private var dailyButton:ButtonExpandableHud;
		
		private var timedButton:ButtonExpandableHud;
		
		private var activeButton:ButtonExpandableHud;
		
		private var activePage:Sprite;
		
		private var tween:TweenMax;
		
		public function MissionsState(param1:Game, param2:String = "")
		{
			var g:Game = param1;
			var goTo:String = param2;
			super(g);
			this.goTo = goTo;
			bg = new Image(textureManager.getTextureGUIByTextureName("map_bgr.png"));
			timedButton = new ButtonExpandableHud(function():void
			{
				show(MissionsTimed, timedButton);
			}, Localize.t("Timed"));
			dailyButton = new ButtonExpandableHud(function():void
			{
				show(MissionsDaily, dailyButton);
			}, Localize.t("Daily"));
			storyButton = new ButtonExpandableHud(function():void
			{
				show(MissionsStory, storyButton);
			}, Localize.t("Story"));
			closeButton = new ButtonExpandableHud(close, Localize.t("close"));
		}
		
		override public function enter():void
		{
			var daily:Daily;
			var m:Mission;
			var dailyCount:int;
			super.enter();
			g.hud.show = false;
			drawBlackBackground();
			g.hud.hideMissionButtons();
			g.hud.showMissionsButton();
			addChild(bg);
			container.addChild(storyButton);
			container.addChild(dailyButton);
			container.addChild(timedButton);
			container.addChild(closeButton);
			resize();
			for each (daily in g.me.dailyMissions)
			{
				if (daily.complete)
				{
					show(MissionsDaily, dailyButton);
					return;
				}
			}
			for each (m in g.me.missions)
			{
				if (m.finished && m.majorType == "time")
				{
					show(MissionsTimed, timedButton);
					return;
				}
				if (m.finished)
				{
					show(MissionsStory, storyButton);
					return;
				}
			}
			for each (m in g.me.missions)
			{
				if (!m.viewed && m.majorType == "time")
				{
					show(MissionsTimed, timedButton);
					return;
				}
				if (!m.viewed)
				{
					show(MissionsStory, storyButton);
					return;
				}
			}
			dailyCount = int(g.me.dailyMissions.filter(function(param1:Daily, param2:int, param3:Array):Boolean
			{
				return !param1.complete;
			}).length);
			if (g.me.level <= 10)
			{
				show(MissionsStory, storyButton);
			}
			else if (dailyCount > 0)
			{
				show(MissionsDaily, dailyButton);
			}
			else
			{
				show(MissionsTimed, timedButton);
			}
		}
		
		override public function resize(param1:Event = null):void
		{
			super.resize();
			container.x = g.stage.stageWidth / 2 - bg.width / 2;
			container.y = g.stage.stageHeight / 2 - bg.height / 2;
			timedButton.x = 40;
			timedButton.y = 0;
			dailyButton.x = timedButton.x + timedButton.width + 5;
			dailyButton.y = timedButton.y;
			storyButton.x = dailyButton.x + dailyButton.width + 5;
			storyButton.y = dailyButton.y;
			closeButton.y = 0;
			closeButton.x = 760 - 46 - closeButton.width;
		}
		
		override public function execute():void
		{
			updateInput();
			super.execute();
		}
		
		private function updateInput():void
		{
			if (!loaded)
			{
				return;
			}
			checkAccelerate(true);
			if (keybinds.isEscPressed || keybinds.isInputPressed(5))
			{
				close();
			}
			updateCommands();
		}
		
		private function show(param1:Class, param2:ButtonExpandableHud):void
		{
			if (activeButton == param2)
			{
				activeButton.enabled = true;
				return;
			}
			if (activePage)
			{
				container.removeChild(activePage, true);
			}
			activePage = new param1(g);
			activePage.addEventListener("animateCollectReward", animateCollectReward);
			container.addChild(activePage);
			updateButtons(param2);
			loadCompleted();
		}
		
		private function updateButtons(param1:ButtonExpandableHud):void
		{
			storyButton.select = param1 == storyButton;
			dailyButton.select = param1 == dailyButton;
			timedButton.select = param1 == timedButton;
			activeButton = param1;
			activeButton.enabled = true;
		}
		
		private function animateCollectReward(param1:Event):void
		{
			var e:Event = param1;
			clearBackground();
			tween = TweenMax.to(container, 1.5, {"y": -container.height, "onComplete": function():void
			{
				close();
			}});
		}
		
		private function close():void
		{
			if (activePage)
			{
				container.removeChild(activePage, true);
			}
			clearBackground();
			sm.revertState();
		}
	}
}
