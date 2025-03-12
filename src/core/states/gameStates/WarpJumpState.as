package core.states.gameStates
{
	import com.greensock.TweenMax;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import starling.display.Quad;
	import starling.filters.GlowFilter;
	
	public class WarpJumpState extends PlayState
	{
		private var destination:String;
		
		private var roomId:String;
		
		private var systemType:String;
		
		private var ship:PlayerShip;
		
		private var hyperDriveEngaged:Boolean = false;
		private var flashOverlay:Quad;
		
		private var darkOverlay:Quad;
		
		private var timeout:Number;
		
		public function WarpJumpState(param1:Game, param2:String, param3:String = "", param4:String = "")
		{
			flashOverlay = new Quad(100, 100, 16777215);
			darkOverlay = new Quad(100, 100, 0);
			super(param1);
			this.destination = param2;
			this.systemType = param4;
			this.roomId = param3;
			flashOverlay.alpha = 0;
			darkOverlay.alpha = 0;
			timeout = param1.time + 10000;
		}
		
		override public function enter():void
		{
			super.enter();
			ship = g.me.ship;
			ship.hideStats();
			flashOverlay.width = g.stage.stageWidth;
			flashOverlay.height = g.stage.stageHeight;
			g.addChildToOverlay(flashOverlay);
			darkOverlay.width = g.stage.stageWidth;
			darkOverlay.height = g.stage.stageHeight;
			g.addChildToOverlay(darkOverlay);
			ship.enterWarpJump();
			loadCompleted();
			g.hud.show = false;
		}
		
		override public function execute():void
		{
			if (timeout < g.time)
			{
				warpJump();
			}
			if (ship.speed.length >= 800)
			{
				if (!hyperDriveEngaged)
				{
					g.camera.trackStep = 100;
					g.parallaxManager.glow();
					TweenMax.to(flashOverlay, 2, {"alpha": 1});
					ship.movieClip.filter = new GlowFilter(16777215, 1, 20);
					TweenMax.to(ship.movieClip, 2, {"scaleX": 20, "onUpdate": function():void
					{
					}, "onComplete": function():void
					{
						g.camera.trackStep = 200;
						g.parallaxManager.removeGlow();
						ship.movieClip.filter.dispose();
						ship.movieClip.filter = null;
						TweenMax.to(darkOverlay, 1, {"alpha": 1});
						TweenMax.to(ship.movieClip, 1, {"scaleX": 0, "onUpdate": function():void
						{
						}, "onComplete": warpJump});
					}});
					hyperDriveEngaged = true;
				}
			}
			super.execute();
		}
		
		private function warpJump():void
		{
			g.warpJump(destination, roomId, systemType);
		}
	}
}
