package starling.text {
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.utils.Dictionary;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.MeshBatch;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.rendering.Painter;
	import starling.styles.MeshStyle;
	import starling.utils.RectangleUtil;
	import starling.utils.SystemUtil;
	
	public class TextField extends DisplayObjectContainer {
		private static const COMPOSITOR_DATA_NAME:String = "starling.display.TextField.compositors";
		
		private static var sDefaultTextureFormat:String = "bgraPacked4444";
		
		private static var sMatrix:Matrix = new Matrix();
		
		private static var sDefaultCompositor:ITextCompositor = new TrueTypeCompositor();
		
		private static var sStringCache:Dictionary = new Dictionary();
		
		private var _text:String;
		
		private var _options:TextOptions;
		
		private var _format:TextFormat;
		
		private var _textBounds:Rectangle;
		
		private var _hitArea:Rectangle;
		
		private var _compositor:ITextCompositor;
		
		private var _requiresRecomposition:Boolean;
		
		private var _border:DisplayObjectContainer;
		
		private var _meshBatch:MeshBatch;
		
		private var _style:MeshStyle;
		
		private var _helperFormat:TextFormat = new TextFormat();
		
		public function TextField(width:int, height:int, text:String = "", format:TextFormat = null) {
			super();
			_text = !!text ? text : "";
			_hitArea = new Rectangle(0,0,width,height);
			_requiresRecomposition = true;
			_compositor = sDefaultCompositor;
			_options = new TextOptions();
			_format = !!format ? format.clone() : new TextFormat();
			_format.addEventListener("change",setRequiresRecomposition);
			_meshBatch = new MeshBatch();
			_meshBatch.touchable = false;
			_meshBatch.pixelSnapping = true;
			addChild(_meshBatch);
		}
		
		public static function get defaultTextureFormat() : String {
			return sDefaultTextureFormat;
		}
		
		public static function set defaultTextureFormat(value:String) : void {
			sDefaultTextureFormat = value;
		}
		
		public static function get defaultCompositor() : ITextCompositor {
			return sDefaultCompositor;
		}
		
		public static function set defaultCompositor(value:ITextCompositor) : void {
			sDefaultCompositor = value;
		}
		
		public static function updateEmbeddedFonts() : void {
			SystemUtil.updateEmbeddedFonts();
		}
		
		public static function registerCompositor(compositor:ITextCompositor, name:String) : void {
			if(name == null) {
				throw new ArgumentError("name must not be null");
			}
			compositors[convertToLowerCase(name)] = compositor;
		}
		
		public static function unregisterCompositor(name:String, dispose:Boolean = true) : void {
			name = convertToLowerCase(name);
			if(dispose && compositors[name] != undefined) {
				compositors[name].dispose();
			}
			delete compositors[name];
		}
		
		public static function getCompositor(name:String) : ITextCompositor {
			return compositors[convertToLowerCase(name)];
		}
		
		public static function registerBitmapFont(bitmapFont:BitmapFont, name:String = null) : String {
			if(name == null) {
				name = bitmapFont.name;
			}
			registerCompositor(bitmapFont,name);
			return name;
		}
		
		public static function unregisterBitmapFont(name:String, dispose:Boolean = true) : void {
			unregisterCompositor(name,dispose);
		}
		
		public static function getBitmapFont(name:String) : BitmapFont {
			return getCompositor(name) as BitmapFont;
		}
		
		private static function get compositors() : Dictionary {
			var _local1:Dictionary = Starling.painter.sharedData["starling.display.TextField.compositors"] as Dictionary;
			if(_local1 == null) {
				_local1 = new Dictionary();
				Starling.painter.sharedData["starling.display.TextField.compositors"] = _local1;
			}
			return _local1;
		}
		
		private static function convertToLowerCase(string:String) : String {
			var _local2:String = sStringCache[string];
			if(_local2 == null) {
				_local2 = string.toLowerCase();
				sStringCache[string] = _local2;
			}
			return _local2;
		}
		
		override public function dispose() : void {
			_format.removeEventListener("change",setRequiresRecomposition);
			_compositor.clearMeshBatch(_meshBatch);
			super.dispose();
		}
		
		override public function render(painter:Painter) : void {
			if(_requiresRecomposition) {
				recompose();
			}
			super.render(painter);
		}
		
		private function recompose() : void {
			var _local1:String = null;
			var _local2:ITextCompositor = null;
			if(_requiresRecomposition) {
				_compositor.clearMeshBatch(_meshBatch);
				_local1 = _format.font;
				_local2 = getCompositor(_local1);
				if(_local2 == null && _local1 == "mini") {
					_local2 = new BitmapFont();
					registerCompositor(_local2,_local1);
				}
				_compositor = !!_local2 ? _local2 : sDefaultCompositor;
				updateText();
				updateBorder();
				_requiresRecomposition = false;
			}
		}
		
		private function updateText() : void {
			var _local1:Number = _hitArea.width;
			var _local3:Number = _hitArea.height;
			var _local2:TextFormat = _helperFormat;
			_local2.copyFrom(_format);
			if(isHorizontalAutoSize && !_options.isHtmlText) {
				_local1 = 100000;
			}
			if(isVerticalAutoSize) {
				_local3 = 100000;
			}
			_meshBatch.x = _meshBatch.y = 0;
			_options.textureScale = Starling.contentScaleFactor;
			_options.textureFormat = sDefaultTextureFormat;
			_compositor.fillMeshBatch(_meshBatch,_local1,_local3,_text,_local2,_options);
			if(_style) {
				_meshBatch.style = _style;
			}
			if(_options.autoSize != "none") {
				_textBounds = _meshBatch.getBounds(_meshBatch,_textBounds);
				if(isHorizontalAutoSize) {
					_meshBatch.x = _textBounds.x = -_textBounds.x;
					_hitArea.width = _textBounds.width;
					_textBounds.x = 0;
				}
				if(isVerticalAutoSize) {
					_meshBatch.y = _textBounds.y = -_textBounds.y;
					_hitArea.height = _textBounds.height;
					_textBounds.y = 0;
				}
			} else {
				_textBounds = null;
			}
		}
		
		private function updateBorder() : void {
			if(_border == null) {
				return;
			}
			var _local4:Number = _hitArea.width;
			var _local6:Number = _hitArea.height;
			var _local1:Quad = _border.getChildAt(0) as Quad;
			var _local3:Quad = _border.getChildAt(1) as Quad;
			var _local5:Quad = _border.getChildAt(2) as Quad;
			var _local2:Quad = _border.getChildAt(3) as Quad;
			_local1.width = _local4;
			_local1.height = 1;
			_local5.width = _local4;
			_local5.height = 1;
			_local2.width = 1;
			_local2.height = _local6;
			_local3.width = 1;
			_local3.height = _local6;
			_local3.x = _local4 - 1;
			_local5.y = _local6 - 1;
			_local1.color = _local3.color = _local5.color = _local2.color = _format.color;
		}
		
		protected function setRequiresRecomposition() : void {
			_requiresRecomposition = true;
			setRequiresRedraw();
		}
		
		private function get isHorizontalAutoSize() : Boolean {
			return _options.autoSize == "horizontal" || _options.autoSize == "bothDirections";
		}
		
		private function get isVerticalAutoSize() : Boolean {
			return _options.autoSize == "vertical" || _options.autoSize == "bothDirections";
		}
		
		public function get textBounds() : Rectangle {
			if(_requiresRecomposition) {
				recompose();
			}
			if(_textBounds == null) {
				_textBounds = _meshBatch.getBounds(this);
			}
			return _textBounds.clone();
		}
		
		override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle {
			if(_requiresRecomposition) {
				recompose();
			}
			getTransformationMatrix(targetSpace,sMatrix);
			return RectangleUtil.getBounds(_hitArea,sMatrix,out);
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			if(!visible || !touchable || !hitTestMask(localPoint)) {
				return null;
			}
			if(_hitArea.containsPoint(localPoint)) {
				return this;
			}
			return null;
		}
		
		override public function set width(value:Number) : void {
			_hitArea.width = value / (scaleX || 1);
			setRequiresRecomposition();
		}
		
		override public function set height(value:Number) : void {
			_hitArea.height = value / (scaleY || 1);
			setRequiresRecomposition();
		}
		
		public function get text() : String {
			return _text;
		}
		
		public function set text(value:String) : void {
			if(value == null) {
				value = "";
			}
			if(_text != value) {
				_text = value;
				setRequiresRecomposition();
			}
		}
		
		public function get format() : TextFormat {
			return _format;
		}
		
		public function set format(value:TextFormat) : void {
			if(value == null) {
				throw new ArgumentError("format cannot be null");
			}
			_format.copyFrom(value);
		}
		
		public function get border() : Boolean {
			return _border != null;
		}
		
		public function set border(value:Boolean) : void {
			var _local2:int = 0;
			if(value && _border == null) {
				_border = new Sprite();
				addChild(_border);
				_local2 = 0;
				while(_local2 < 4) {
					_border.addChild(new Quad(1,1));
					_local2++;
				}
				updateBorder();
			} else if(!value && _border != null) {
				_border.removeFromParent(true);
				_border = null;
			}
		}
		
		public function get autoScale() : Boolean {
			return _options.autoScale;
		}
		
		public function set autoScale(value:Boolean) : void {
			if(_options.autoScale != value) {
				_options.autoScale = value;
				setRequiresRecomposition();
			}
		}
		
		public function get autoSize() : String {
			return _options.autoSize;
		}
		
		public function set autoSize(value:String) : void {
			if(_options.autoSize != value) {
				_options.autoSize = value;
				setRequiresRecomposition();
			}
		}
		
		public function get wordWrap() : Boolean {
			return _options.wordWrap;
		}
		
		public function set wordWrap(value:Boolean) : void {
			if(value != _options.wordWrap) {
				_options.wordWrap = value;
				setRequiresRecomposition();
			}
		}
		
		public function get batchable() : Boolean {
			return _meshBatch.batchable;
		}
		
		public function set batchable(value:Boolean) : void {
			_meshBatch.batchable = value;
		}
		
		public function get isHtmlText() : Boolean {
			return _options.isHtmlText;
		}
		
		public function set isHtmlText(value:Boolean) : void {
			if(_options.isHtmlText != value) {
				_options.isHtmlText = value;
				setRequiresRecomposition();
			}
		}
		
		public function get styleSheet() : StyleSheet {
			return _options.styleSheet;
		}
		
		public function set styleSheet(value:StyleSheet) : void {
			_options.styleSheet = value;
			setRequiresRecomposition();
		}
		
		public function get pixelSnapping() : Boolean {
			return _meshBatch.pixelSnapping;
		}
		
		public function set pixelSnapping(value:Boolean) : void {
			_meshBatch.pixelSnapping = value;
		}
		
		public function get style() : MeshStyle {
			return _meshBatch.style;
		}
		
		public function set style(value:MeshStyle) : void {
			_meshBatch.style = _style = value;
			setRequiresRecomposition();
		}
	}
}

