package core.states.gameStates
{
	import core.hud.components.Button;
	import core.hud.components.ScreenTextField;
	import core.scene.Game;
	import core.solarSystem.Body;
	import starling.events.Event;
	
	public class LandedLore extends LandedState
	{
		public function LandedLore(param1:Game, param2:Body)
		{
			super(param1, param2, param2.name);
		}
		
		override public function enter():void
		{
			var _loc3_:int = 0;
			var _loc1_:Array = null;
			super.enter();
			var _loc2_:Array = (body.obj.lore as String).replace("\"", "").split("**");
			_loc3_ = 0;
			while (_loc3_ < _loc2_.length)
			{
				_loc1_ = _loc2_[_loc3_].split("*");
				_loc2_[_loc3_] = _loc1_;
				_loc3_++;
			}
			runLore(0, _loc2_);
			RymdenRunt.s.nativeStage.frameRate = 60;
			loadCompleted();
		}
		
		private function runLore(param1:int, param2:Array):void
		{
			var i:int = param1;
			var s:Array = param2;
			var stf:ScreenTextField = new ScreenTextField(500);
			stf.textArray = [s[i]];
			stf.start(null, false);
			stf.x = 140;
			stf.y = 100;
			stf.pageReadTime = 180000;
			addChild(stf);
			i++;
			stf.addEventListener("beforeFadeOut", (function():*
			{
				var r:Function;
				return r = function(param1:Event):void
				{
					var nextButton:Button;
					var e:Event = param1;
					stf.removeEventListener("beforeFadeOut", r);
					if (i > s.length - 1)
					{
						return;
					}
					nextButton = new Button(function():void
					{
						stf.stop();
						stf.doFadeOut();
						stf.addEventListener("pageFinished", (function():*
						{
							var r:Function;
							return r = function(param1:Event):void
							{
								stf.removeEventListener("pageFinished", r);
								runLore(i, s);
								removeChild(stf);
								removeChild(nextButton);
							};
						})());
					}, "Continue");
					nextButton.x = 340;
					nextButton.y = 500;
					addChild(nextButton);
				};
			})());
		}
	}
}
