package core.hud.components
{
	import com.greensock.TweenMax;
	import core.scene.Game;
	import starling.display.Image;
	import starling.events.TouchEvent;
	import textures.TextureLocator;
	
	public class ButtonNewMission extends ButtonHud
	{
		private var g:Game;
		
		private var tween:TweenMax;
		
		private var hintArrow:Image;
		
		public function ButtonNewMission(param1:Function, param2:Game)
		{
			super(param1, "button_new_mission.png");
			this.g = param2;
			hintArrow = new Image(TextureLocator.getService().getTextureGUIByTextureName("hint_arrow.png"));
			hintArrow.blendMode = "screen";
			addChild(hintArrow);
			removeChild(hintNewContainer);
			hintArrow.y = -80;
			hintArrow.x = 35;
			hintArrow.visible = false;
			hintArrow.color = 16755336;
		}
		
		public function show():void
		{
			if (tween != null)
			{
				tween.kill();
			}
			visible = true;
			tween = TweenMax.fromTo(this, 2, {"x": g.stage.stageWidth}, {"x": g.stage.stageWidth - width, "onComplete": fadeInOut});
			hintArrow.visible = false;
		}
		
		override public function click(param1:TouchEvent = null):void
		{
			super.click(param1);
			if (tween != null)
			{
				tween.kill();
				tween = null;
			}
			alpha = 1;
			visible = false;
			hintArrow.visible = false;
		}
		
		private function fadeInOut():void
		{
			if (tween != null)
			{
				tween.kill();
			}
			alpha = 1;
			hintArrow.alpha = 0;
			TweenMax.to(hintArrow, 3, {"alpha": 1});
			hintArrow.visible = true;
			tween = TweenMax.to(this, 1.5, {"alpha": 0.35, "yoyo": false, "repeat": -1, "onUpdate": function():void
			{
				hintArrow.y = -120 + alpha * 60;
			}});
		}
		
		public function hide():void
		{
			if (tween != null)
			{
				tween.kill();
			}
			alpha = 1;
			visible = false;
			hintArrow.visible = false;
		}
		
		override public function dispose():void
		{
			if (tween != null)
			{
				tween.kill();
			}
			super.dispose();
		}
	}
}
