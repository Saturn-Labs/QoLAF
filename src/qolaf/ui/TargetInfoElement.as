package qolaf.ui 
{
	import core.scene.Game;
	import feathers.controls.Label;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.display.DisplayObject;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	/**
	 * @author rydev
	 */
	public class TargetInfoElement extends DisplayObjectContainer 
	{
		private var game:Game;
		public var targetName:Label;
		
		public function TargetInfoElement(game:Game) 
		{
			this.game = game;
			width = 370;
			height = 90;
			
			targetName = new Label();
			targetName.width = 370;
			targetName.height = 20;
			targetName.styleName = "target_info";

			
			targetName.alignPivot(Align.CENTER, Align.TOP);
			targetName.x = targetName.y = 0;
			
			addChild(targetName);
		}
		
		public function Update():void 
		{
			x = game.stage.stageWidth / 2.0;
			y = 120;
		}
	}
}