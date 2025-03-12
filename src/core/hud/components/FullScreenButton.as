package core.hud.components
{
	import core.scene.Game;
	import debug.Console;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import starling.core.Starling;
	
	public class FullScreenButton extends Sprite
	{
		private var hoverImage:Sprite;
		
		public function FullScreenButton()
		{
			hoverImage = new Sprite();
			super();
			tabChildren = false;
			tabEnabled = false;
			graphics.beginFill(1842461);
			graphics.lineStyle(1, 4409416);
			graphics.drawRoundRect(0, 0, 22, 25, 4, 4);
			graphics.beginFill(13027014);
			graphics.lineStyle(0, 0);
			graphics.drawRoundRect(3, 8, 16, 12, 2, 2);
			graphics.beginFill(0);
			graphics.drawRoundRect(6, 12, 10, 4, 2, 2);
			graphics.endFill();
			hoverImage.graphics.beginFill(1842461);
			hoverImage.graphics.lineStyle(1, 4409416);
			hoverImage.graphics.drawRoundRect(0, 0, 22, 25, 4, 4);
			hoverImage.graphics.beginFill(13027014);
			hoverImage.graphics.lineStyle(0, 0);
			hoverImage.graphics.drawRoundRect(3, 8, 16, 12, 2, 2);
			hoverImage.graphics.beginFill(0);
			hoverImage.graphics.drawRoundRect(6, 12, 10, 4, 2, 2);
			hoverImage.graphics.endFill();
			hoverImage.blendMode = "add";
			hoverImage.visible = false;
			addChild(hoverImage);
			addEventListener("click", onFullscreen);
			addEventListener("mouseOver", function(param1:MouseEvent):void
			{
				hoverImage.visible = true;
			});
			addEventListener("mouseOut", function(param1:MouseEvent):void
			{
				hoverImage.visible = false;
			});
			this.buttonMode = true;
			this.useHandCursor = true;
		}
		
		public function onFullscreen(param1:MouseEvent):void
		{
			var _loc4_:* = Starling.current.nativeStage.displayState == "fullScreenInteractive";
			_loc4_ = !_loc4_;
			var _loc3_:String = Capabilities.version;
			var _loc7_:Array = _loc3_.split(" ");
			var _loc2_:Array = _loc7_[1].split(",");
			var _loc6_:String = _loc7_[0];
			var _loc5_:Number = Number(_loc2_[0]);
			_loc5_ = _loc5_ + _loc2_[1] / 10;
			if (_loc4_ && _loc5_ >= 1.3)
			{
				Starling.current.nativeStage.displayState = "fullScreenInteractive";
			}
			else if (_loc4_)
			{
				Console.write("You need flash version 11.3");
			}
			else
			{
				Starling.current.nativeStage.displayState = "normal";
			}
			Game.instance.hud.resize();
			Game.instance.hud.removeFullScreenHint();
		}
	}
}
