package core.hud.components {
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class TextBitmap extends TextField {
		public function TextBitmap(x:int = 0, y:int = 0, text:String = "", fontSize:int = 13) {
			var _local5:String = null;
			if(fontSize < 18) {
				_local5 = "font13";
			} else if(fontSize < 23) {
				_local5 = "font20";
			} else {
				_local5 = "font26";
			}
			super(800,fontSize + 4,text,new TextFormat(_local5,fontSize,0xffffff));
			this.x = x;
			this.y = y;
			this.autoScale = true;
			if(text != null) {
				this.batchable = text.length < 16 && format.font == "font13";
			}
			autoWidth();
		}
		
		override public function set text(value:String) : void {
			if(super.text == value) {
				return;
			}
			if(text != null) {
				this.batchable = text.length < 16 && format.font == "font13";
			}
			width = 800;
			super.text = value;
			autoWidth();
		}
		
		public function autoWidth() : void {
			this.width = this.textBounds.width + 4;
			if(format.horizontalAlign == "right") {
				alignRight();
			}
		}
		
		public function set size(value:int) : void {
			this.width = 800;
			this.height = value + 4;
			if(value < 18) {
				format.font = "font13";
			} else if(value < 22) {
				format.font = "font20";
			} else {
				format.font = "font26";
			}
			this.format.size = value;
			autoWidth();
		}
		
		public function get size() : int {
			return this.format.size;
		}
		
		public function alignRight() : void {
			pivotX = this.textBounds.width + 4;
			format.horizontalAlign = "right";
		}
		
		public function alignLeft() : void {
			pivotX = 0;
			format.horizontalAlign = "left";
		}
		
		public function center() : void {
			pivotX = textBounds.width / 2;
			pivotY = textBounds.height / 2;
		}
	}
}

