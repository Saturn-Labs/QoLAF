package core.hud.components {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class Text extends DisplayObjectContainer {
		public static var H_ALIGN_LEFT:int = 0;
		
		public static var H_ALIGN_RIGHT:int = 1;
		
		public static var H_ALIGN_CENTER:int = 2;
		
		public static var V_ALIGN_TOP:int = 0;
		
		public static var V_ALIGN_MIDDLE:int = 1;
		
		public static var V_ALIGN_BOTTOM:int = 2;
		
		private static var BACKGROUND_COLOR:uint = 0;
		
		private static var GLOW_COLOR:uint = 16777215;
		
		private static var LEADING:int = 8;
		
		private var texture:Texture;
		
		protected var finalLayer:Image;
		
		private var layer:Bitmap = new Bitmap();
		
		protected var tf:TextField;
		
		private var format:TextFormat;
		
		protected var _hAlign:int = H_ALIGN_LEFT;
		
		private var _vAlign:int = V_ALIGN_TOP;
		
		private var _centerVertical:Boolean = false;
		
		private var oldText:String = "";
		
		public function Text(x:int = 0, y:int = 0, useWordWrap:Boolean = false, fontFamily:String = "DAIDRR") {
			super();
			tf = new TextField();
			tf.embedFonts = true;
			tf.wordWrap = useWordWrap;
			tf.antiAliasType = "advanced";
			tf.selectable = false;
			tf.multiline = true;
			format = new TextFormat();
			format.font = fontFamily;
			format.leading = LEADING;
			format.color = 0xffffff;
			format.size = 10;
			tf.defaultTextFormat = format;
			touchable = false;
			this.x = x;
			this.y = y;
			addEventListener("removedFromStage",clean);
		}
		
		public function set glow(value:Boolean) : void {
			var _local2:GlowFilter = null;
			if(value) {
				_local2 = new GlowFilter(GLOW_COLOR,0.5,3,3,2,4);
				layer.filters = [_local2];
			} else {
				layer.filters = [];
			}
		}
		
		public function glowIn(color:uint, alpha:Number = 1, size:int = 6, strength:int = 2) : void {
			var _local5:GlowFilter = new GlowFilter(color,alpha,size,size,strength,4);
			layer.filters = [_local5];
		}
		
		public function centerPivot() : void {
			pivotX = width / 2;
			pivotY = height / 2;
		}
		
		public function center() : void {
			if(_hAlign == H_ALIGN_CENTER && _vAlign == V_ALIGN_MIDDLE) {
				return;
			}
			_hAlign = H_ALIGN_CENTER;
			_vAlign = V_ALIGN_MIDDLE;
			draw();
		}
		
		public function alignRight() : void {
			if(_hAlign == H_ALIGN_RIGHT) {
				return;
			}
			_hAlign = H_ALIGN_RIGHT;
			draw();
		}
		
		public function alignLeft() : void {
			if(_hAlign == H_ALIGN_LEFT) {
				return;
			}
			_hAlign = H_ALIGN_LEFT;
			draw();
		}
		
		public function alignCenter() : void {
			if(_hAlign == H_ALIGN_CENTER) {
				return;
			}
			_hAlign = H_ALIGN_CENTER;
			draw();
		}
		
		public function alignTop() : void {
			if(_vAlign == V_ALIGN_TOP) {
				return;
			}
			_vAlign = V_ALIGN_TOP;
			draw();
		}
		
		public function alignMiddle() : void {
			if(_vAlign == V_ALIGN_MIDDLE) {
				return;
			}
			_vAlign = V_ALIGN_MIDDLE;
			draw();
		}
		
		public function alignBottom() : void {
			if(_vAlign == V_ALIGN_BOTTOM) {
				return;
			}
			_vAlign = V_ALIGN_BOTTOM;
			draw();
		}
		
		public function set sharpness(value:int) : void {
			if(tf.sharpness == value) {
				return;
			}
			tf.sharpness = value;
			draw();
		}
		
		public function set size(value:Number) : void {
			if(format.size == value) {
				return;
			}
			format.size = value;
			defaultTextFormat = format;
		}
		
		public function get size() : Number {
			return format.size as Number;
		}
		
		public function set color(c:uint) : void {
			if(c == format.color) {
				return;
			}
			format.color = c;
			defaultTextFormat = format;
		}
		
		public function get color() : uint {
			return format.color as uint;
		}
		
		override public function set width(value:Number) : void {
			if(tf.width == value) {
				return;
			}
			tf.width = value;
			draw();
		}
		
		override public function get width() : Number {
			return tf.width;
		}
		
		public function set font(fontName:String) : void {
			if(format.font == fontName) {
				return;
			}
			format.font = fontName;
			defaultTextFormat = format;
		}
		
		public function set bold(value:Boolean) : void {
			if(format.bold == value) {
				return;
			}
			format.bold = value;
			defaultTextFormat = format;
		}
		
		public function set wordWrap(value:Boolean) : void {
			if(tf.wordWrap == value) {
				return;
			}
			tf.wordWrap = value;
			if(value) {
				tf.multiline = true;
			} else {
				tf.multiline = false;
			}
			draw();
		}
		
		override public function set height(value:Number) : void {
			if(value == tf.height) {
				return;
			}
			tf.height = value;
			draw();
		}
		
		override public function get height() : Number {
			return tf.textHeight;
		}
		
		public function set htmlText(value:String) : void {
			if(oldText == value) {
				return;
			}
			tf.htmlText = value == null ? "" : value;
			oldText = value;
			var _local2:int = tf.textHeight;
			if(!tf.wordWrap) {
				tf.width = tf.textWidth + 5;
			} else {
				_local2 += LEADING;
			}
			tf.height = _local2;
			draw();
		}
		
		public function get htmlText() : String {
			return tf.htmlText;
		}
		
		public function set text(value:String) : void {
			if(oldText == value) {
				return;
			}
			oldText = value;
			tf.text = value == null ? "" : value;
			var _local2:int = tf.textHeight;
			if(!tf.wordWrap) {
				tf.width = tf.textWidth + 5;
			} else {
				_local2 += LEADING;
			}
			tf.height = _local2;
			draw();
		}
		
		override public function set x(value:Number) : void {
			super.x = Math.floor(value);
		}
		
		override public function set y(value:Number) : void {
			super.y = Math.floor(value);
		}
		
		public function get text() : String {
			return tf.text;
		}
		
		public function set defaultTextFormat(format:TextFormat) : void {
			tf.defaultTextFormat = format;
			var _local2:String = text;
			oldText = "";
			text = _local2;
		}
		
		protected function draw() : void {
			var bd:BitmapData;
			if(!hasEventListener("removedFromStage")) {
				addEventListener("removedFromStage",clean);
			}
			if(tf.text == null || tf.text == "") {
				return;
			}
			if(tf.width > 0 && tf.height > 0) {
				if(finalLayer != null) {
					removeChild(finalLayer);
					finalLayer.dispose();
					finalLayer = null;
					texture.dispose();
					texture = null;
				}
				bd = new BitmapData(tf.width,tf.height,true,BACKGROUND_COLOR);
				bd.lock();
				bd.draw(tf,tf.transform.matrix,tf.transform.colorTransform,tf.blendMode,null,true);
				bd.unlock();
				if(layer.filters.length > 0) {
					bd.applyFilter(bd,bd.rect,new Point(),layer.filters[0]);
				}
				if(texture) {
					texture.dispose();
					texture = null;
				}
				texture = Texture.fromBitmapData(bd,false);
				bd.dispose();
				texture.root.onRestore = function():void {
					var _local1:BitmapData = new BitmapData(tf.width,tf.height,true,BACKGROUND_COLOR);
					_local1.lock();
					_local1.draw(tf,tf.transform.matrix,tf.transform.colorTransform,tf.blendMode,null,true);
					_local1.unlock();
					try {
						texture.root.uploadBitmapData(_local1);
					}
					catch(e:Error) {
						trace("Texture restoration failed: " + e.message);
					}
					_local1.dispose();
				};
				finalLayer = new Image(texture);
				if(_hAlign == H_ALIGN_CENTER) {
					finalLayer.x = -tf.width / 2;
				} else if(_hAlign == H_ALIGN_LEFT) {
					finalLayer.x = 0;
				} else if(_hAlign == H_ALIGN_RIGHT) {
					finalLayer.x = -tf.width;
				}
				if(_vAlign == V_ALIGN_MIDDLE) {
					finalLayer.y = -tf.height / 2 + LEADING / 2;
				} else if(_vAlign == V_ALIGN_TOP) {
					finalLayer.y = 0;
				} else if(_vAlign == V_ALIGN_BOTTOM) {
					finalLayer.y = -tf.height + LEADING / 2;
				}
				addChild(finalLayer);
			}
		}
		
		public function clean(e:Event = null) : void {
			removeEventListeners();
			tf.text = "";
			tf.htmlText = "";
			if(texture) {
				texture.dispose();
			}
			dispose();
		}
	}
}

