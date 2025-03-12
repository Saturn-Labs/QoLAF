package
{
	import core.hud.components.TextBitmap;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class LoadingBar extends Sprite
	{
		private var status:TextBitmap;
		
		private var percent:TextField;
		
		public function LoadingBar(param1:Number, param2:Number)
		{
			super();
			this.x = param1;
			this.y = param2;
			status = new TextBitmap();
			status.y = 45;
			status.size = 20;
			addChild(status);
			percent = new TextField(500, 70, "", new TextFormat("DAIDRR", 50, 16777215));
			percent.y = -25;
			percent.blendMode = "add";
			addChild(percent);
		}
		
		public function update(param1:String, param2:int):void
		{
			this.status.text = param1;
			this.percent.text = param2.toString() + "%";
			this.status.x = -this.status.width / 2;
			this.percent.x = -this.percent.width / 2;
		}
	}
}
