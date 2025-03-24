package core.states.gameStates {
	import core.hud.components.Button;
	import core.hud.components.ScreenTextField;
	import core.scene.Game;
	import core.solarSystem.Body;
	import starling.events.Event;
	
	public class LandedLore extends LandedState {
		public function LandedLore(g:Game, body:Body) {
			super(g,body,body.name);
		}
		
		override public function enter() : void {
			var _local2:int = 0;
			var _local3:Array = null;
			super.enter();
			var _local1:Array = (body.obj.lore as String).replace("\"","").split("**");
			_local2 = 0;
			while(_local2 < _local1.length) {
				_local3 = _local1[_local2].split("*");
				_local1[_local2] = _local3;
				_local2++;
			}
			runLore(0,_local1);
			RymdenRunt.s.nativeStage.frameRate = 60;
			loadCompleted();
		}
		
		private function runLore(i:int, s:Array) : void {
			var stf:ScreenTextField = new ScreenTextField(500);
			stf.textArray = [s[i]];
			stf.start(null,false);
			stf.x = 140;
			stf.y = 100;
			stf.pageReadTime = 50 * 60 * 60;
			addChild(stf);
			i++;
			stf.addEventListener("beforeFadeOut",(function():* {
				var r:Function;
				return r = function(param1:Event):void {
					var nextButton:Button;
					var e:Event = param1;
					stf.removeEventListener("beforeFadeOut",r);
					if(i > s.length - 1) {
						return;
					}
					nextButton = new Button(function():void {
						stf.stop();
						stf.doFadeOut();
						stf.addEventListener("pageFinished",(function():* {
							var r:Function;
							return r = function(param1:Event):void {
								stf.removeEventListener("pageFinished",r);
								runLore(i,s);
								removeChild(stf);
								removeChild(nextButton);
							};
						})());
					},"Continue");
					nextButton.x = 340;
					nextButton.y = 500;
					addChild(nextButton);
				};
			})());
		}
	}
}

