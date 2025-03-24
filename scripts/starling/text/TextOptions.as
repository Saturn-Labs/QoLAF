package starling.text {
	import flash.text.StyleSheet;
	import starling.core.Starling;
	
	public class TextOptions {
		private var _wordWrap:Boolean;
		
		private var _autoScale:Boolean;
		
		private var _autoSize:String;
		
		private var _isHtmlText:Boolean;
		
		private var _textureScale:Number;
		
		private var _textureFormat:String;
		
		private var _styleSheet:StyleSheet;
		
		public function TextOptions(wordWrap:Boolean = true, autoScale:Boolean = false) {
			super();
			_wordWrap = wordWrap;
			_autoScale = autoScale;
			_autoSize = "none";
			_textureScale = Starling.contentScaleFactor;
			_textureFormat = "bgrPacked565";
			_isHtmlText = false;
		}
		
		public function copyFrom(options:TextOptions) : void {
			_wordWrap = options._wordWrap;
			_autoScale = options._autoScale;
			_autoSize = options._autoSize;
			_isHtmlText = options._isHtmlText;
			_textureScale = options._textureScale;
			_textureFormat = options._textureFormat;
			_styleSheet = options._styleSheet;
		}
		
		public function clone() : TextOptions {
			var _local1:TextOptions = new TextOptions();
			_local1.copyFrom(this);
			return _local1;
		}
		
		public function get wordWrap() : Boolean {
			return _wordWrap;
		}
		
		public function set wordWrap(value:Boolean) : void {
			_wordWrap = value;
		}
		
		public function get autoSize() : String {
			return _autoSize;
		}
		
		public function set autoSize(value:String) : void {
			_autoSize = value;
		}
		
		public function get autoScale() : Boolean {
			return _autoScale;
		}
		
		public function set autoScale(value:Boolean) : void {
			_autoScale = value;
		}
		
		public function get isHtmlText() : Boolean {
			return _isHtmlText;
		}
		
		public function set isHtmlText(value:Boolean) : void {
			_isHtmlText = value;
		}
		
		public function get styleSheet() : StyleSheet {
			return _styleSheet;
		}
		
		public function set styleSheet(value:StyleSheet) : void {
			_styleSheet = value;
		}
		
		public function get textureScale() : Number {
			return _textureScale;
		}
		
		public function set textureScale(value:Number) : void {
			_textureScale = value;
		}
		
		public function get textureFormat() : String {
			return _textureFormat;
		}
		
		public function set textureFormat(value:String) : void {
			_textureFormat = value;
		}
	}
}

