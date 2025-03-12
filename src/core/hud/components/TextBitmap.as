package core.hud.components
{
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class TextBitmap extends TextField
	{
		public function TextBitmap(param1:int = 0, param2:int = 0, param3:String = "", param4:int = 13)
		{
			var _loc5_:String = null;
			if (param4 < 18)
			{
				_loc5_ = "font13";
			}
			else if (param4 < 23)
			{
				_loc5_ = "font20";
			}
			else
			{
				_loc5_ = "font26";
			}
			super(800, param4 + 4, param3, new TextFormat(_loc5_, param4, 16777215));
			this.x = param1;
			this.y = param2;
			this.autoScale = true;
			if (param3 != null)
			{
				this.batchable = param3.length < 16 && format.font == "font13";
			}
			autoWidth();
		}
		
		override public function set text(param1:String):void
		{
			if (super.text == param1)
			{
				return;
			}
			if (text != null)
			{
				this.batchable = text.length < 16 && format.font == "font13";
			}
			width = 800;
			super.text = param1;
			autoWidth();
		}
		
		public function autoWidth():void
		{
			this.width = this.textBounds.width + 4;
			if (format.horizontalAlign == "right")
			{
				alignRight();
			}
		}
		
		public function set size(param1:int):void
		{
			this.width = 800;
			this.height = param1 + 4;
			if (param1 < 18)
			{
				format.font = "font13";
			}
			else if (param1 < 22)
			{
				format.font = "font20";
			}
			else
			{
				format.font = "font26";
			}
			this.format.size = param1;
			autoWidth();
		}
		
		public function get size():int
		{
			return this.format.size;
		}
		
		public function alignRight():void
		{
			pivotX = this.textBounds.width + 4;
			format.horizontalAlign = "right";
		}
		
		public function alignLeft():void
		{
			pivotX = 0;
			format.horizontalAlign = "left";
		}
		
		public function center():void
		{
			pivotX = textBounds.width / 2;
			pivotY = textBounds.height / 2;
		}
	}
}
