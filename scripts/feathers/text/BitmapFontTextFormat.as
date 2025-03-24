package feathers.text {
	import starling.text.BitmapFont;
	import starling.text.TextField;
	
	public class BitmapFontTextFormat {
		public var font:BitmapFont;
		
		public var color:uint;
		
		public var size:Number;
		
		public var letterSpacing:Number = 0;
		
		public var align:String = "left";
		
		public var leading:Number;
		
		public var isKerningEnabled:Boolean = true;
		
		public function BitmapFontTextFormat(font:Object, size:Number = NaN, color:uint = 16777215, align:String = "left", leading:Number = 0) {
			super();
			if(font is String) {
				font = TextField.getBitmapFont(font as String);
			}
			if(!(font is BitmapFont)) {
				throw new ArgumentError("BitmapFontTextFormat font must be a BitmapFont instance or a String representing the name of a registered bitmap font.");
			}
			this.font = BitmapFont(font);
			this.size = size;
			this.color = color;
			this.align = align;
			this.leading = leading;
		}
		
		public function get fontName() : String {
			return !!this.font ? this.font.name : null;
		}
	}
}

