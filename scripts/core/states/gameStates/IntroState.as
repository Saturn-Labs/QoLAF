package core.states.gameStates {
	import com.greensock.TweenMax;
	import core.hud.components.Box;
	import core.hud.components.ScreenTextField;
	import core.hud.components.Style;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import debug.Console;
	import flash.geom.Point;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class IntroState extends PlayState {
		private var ship:PlayerShip;
		
		private var hyperDriveEngaged:Boolean = true;
		
		private var overlay:Sprite = new Sprite();
		
		private var stf:ScreenTextField = new ScreenTextField(450,800,20000);
		
		private var box:Box;
		
		private var countdownText:TextField;
		
		private var countdownTime:Number;
		
		private var startX:Number = 0;
		
		private var startY:Number = 0;
		
		public function IntroState(g:Game) {
			super(g);
			g.canvasBackground.alpha = 0;
		}
		
		override public function enter() : void {
			var s:String;
			Console.write("Entered intro");
			Login.START_SETUP_IS_ACTIVE = false;
			g.hud.hideFullScreenHint();
			Game.trackEvent("AB Splits","player flow",g.me.split + ": intro start");
			Console.write("g.me.split" + g.me.split);
			super.enter();
			ship = g.me.ship;
			s = g.me.split.charAt(0);
			if(s == "F" || s == "G") {
				g.canvasBackground.alpha = 1;
				enterRoaming();
				g.focusGameObject(ship,true);
				Login.hideStartSetup();
				return;
			}
			ship.hideStats();
			g.messageLog.visible = false;
			startX = ship.pos.x;
			startY = ship.pos.y;
			ship.pos.x = startX - 200 * 60;
			g.camera.update();
			g.focusGameObject(ship);
			soundManager.preCacheSound("_BsBOsabf0WbIWdzrshcNg",function():void {
				ship.enterIntro(startX,startY);
				ship.engine.accelerate();
				stf.x = 100;
				stf.y = 100;
				soundManager.stopAll();
				soundManager.play("_BsBOsabf0WbIWdzrshcNg");
				TweenMax.to(g.canvasBackground,5,{"alpha":1});
				stf.start([["Initializing...","Arrival at Antor System","Sleep stasis deactivated...","Life support.............................. 100%","Weapons.................................... 100%","Shields...................................... 100%","Coffee is ready."]]);
				overlay.addChild(stf);
				g.addChildToOverlay(overlay);
				var _local1:TextField = new TextField(200,30);
				_local1.x = g.stage.stageWidth / 2 + 10;
				_local1.y = g.stage.stageHeight - 170;
				_local1.format.size = 14;
				_local1.alignPivot();
				_local1.format.color = 0x686868;
				_local1.text = "Game starts in:";
				_local1.format.font = "DAIDRR";
				overlay.addChild(_local1);
				_local1 = new TextField(200,30);
				_local1.x = g.stage.stageWidth - 40;
				_local1.y = 40;
				_local1.format.size = 14;
				_local1.format.font = "DAIDRR";
				_local1.format.color = 0xcccccc;
				_local1.text = "Press ESC to skip";
				_local1.alpha = 0.8;
				_local1.pivotX = _local1.width;
				overlay.addChild(_local1);
				stf.addEventListener("animationFinished",onAnimationFinished);
				countdownText = new TextField(200,100,"",new TextFormat("DAIDRR",80,Style.COLOR_DARK_GREEN));
				countdownText.blendMode = "screen";
				countdownText.pivotX = countdownText.width / 2;
				countdownText.pivotY = countdownText.height / 2;
				countdownText.x = g.stage.stageWidth / 2;
				countdownText.y = g.stage.stageHeight - 100;
				countdownTime = 24;
				countdownText.alpha = 1;
				countdownText.scaleX = 1;
				countdownText.scaleY = 1;
				overlay.addChild(countdownText);
				countdown();
				loadCompleted();
				Login.hideStartSetup();
				g.hud.show = false;
			},"voice");
		}
		
		private function countdown() : void {
			if(countdownTime < 0) {
				TweenMax.to(countdownText,0.5,{
					"scaleX":20,
					"scaleY":20,
					"alpha":0,
					"onComplete":function():void {
						overlay.removeChild(countdownText,true);
						countdownText = null;
					}
				});
				return;
			}
			countdownText.alpha = 0;
			countdownText.scaleX = 2;
			countdownText.scaleY = 2;
			if(countdownTime > -1) {
				soundManager.play("3hVYqbNNSUWoDGk_pK1BdQ");
				countdownText.text = "" + countdownTime;
			}
			TweenMax.to(countdownText,0.3,{
				"scaleX":1,
				"scaleY":1
			});
			TweenMax.to(countdownText,0.9,{"alpha":1});
			countdownTime--;
			TweenMax.delayedCall(1,countdown);
		}
		
		private function onAnimationFinished(e:Event) : void {
			stf.visible = false;
		}
		
		override public function execute() : void {
			if(g.isLeaving) {
				return;
			}
			if(g.me.isWarpJumping) {
				return;
			}
			if(input.isKeyPressed(13) || input.isKeyPressed(27)) {
				stf.stop();
				g.removeChildFromOverlay(overlay,true);
				soundManager.stop("_BsBOsabf0WbIWdzrshcNg");
				ship.pos = new Point(startX,startY);
				ship.engine.idle();
				enterRoaming();
				g.focusGameObject(ship,true);
				Game.trackEvent("player flow","intro finished","tried to press esc");
				return;
			}
			if(ship.x > startX - 20) {
				Game.trackEvent("player flow","intro finished","viewed all");
				ship.engine.idle();
				enterRoaming();
			}
			super.execute();
		}
		
		private function enterRoaming() : void {
			if(g.isLeaving) {
				return;
			}
			if(g.me.isWarpJumping) {
				return;
			}
			ship.enterRoaming();
			g.removeChildFromOverlay(overlay,true);
			TweenMax.delayedCall(2,function():void {
				g.tutorial.showIntroTutorial();
			});
			g.focusGameObject(g.me.ship,g.solarSystem.isPvpSystemInEditor);
			g.enterState(new RoamingState(g));
		}
		
		override public function exit(callback:Function) : void {
			stf.removeEventListener("animationFinished",onAnimationFinished);
			Game.trackEvent("AB Splits","player flow",g.me.split + ": intro exit ");
			g.messageLog.visible = true;
			g.hud.initMissionsButtons();
			g.hud.showFullScreenHint();
			super.exit(callback);
		}
	}
}

