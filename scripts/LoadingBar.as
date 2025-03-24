package {
	import core.hud.components.TextBitmap;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class LoadingBar extends Sprite {
		private var status:TextBitmap;
		
		private var percent:TextField;
		
		public function LoadingBar(x:Number, y:Number) {
			super();
			this.x = x;
			this.y = y;
			status = new TextBitmap();
			status.y = 45;
			status.size = 20;
			addChild(status);
			percent = new TextField(500,70,"",new TextFormat("DAIDRR",50,0xffffff));
			percent.y = -25;
			percent.blendMode = "add";
			addChild(percent);
		}
		
		public function update(status:String, percent:int) : void {
			this.status.text = status;
			this.percent.text = percent.toString() + "%";
			this.status.x = -this.status.width / 2;
			this.percent.x = -this.percent.width / 2;
		}
	}
}

