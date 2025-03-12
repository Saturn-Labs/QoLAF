package core.hud.components
{
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
	
	public class Text extends DisplayObjectContainer
	{
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
		
		private var layer:Bitmap;
		
		protected var tf:TextField;
		
		private var format:TextFormat;
		
		protected var _hAlign:int;
		
		private var _vAlign:int;
		
		private var _centerVertical:Boolean = false;
		private var oldText:String = "";
		public function Text(param1:int = 0, param2:int = 0, param3:Boolean = false, param4:String = "DAIDRR")
		{
			layer = new Bitmap();
			_hAlign = H_ALIGN_LEFT;
			_vAlign = V_ALIGN_TOP;
			super();
			tf = new TextField();
			tf.embedFonts = true;
			tf.wordWrap = param3;
			tf.antiAliasType = "advanced";
			tf.selectable = false;
			tf.multiline = true;
			format = new TextFormat();
			format.font = param4;
			format.leading = LEADING;
			format.color = 16777215;
			format.size = 10;
			tf.defaultTextFormat = format;
			touchable = false;
			this.x = param1;
			this.y = param2;
			addEventListener("removedFromStage", clean);
		}
		
		public function set glow(param1:Boolean):void
		{
			var _loc2_:GlowFilter = null;
			if (param1)
			{
				_loc2_ = new GlowFilter(GLOW_COLOR, 0.5, 3, 3, 2, 4);
				layer.filters = [_loc2_];
			}
			else
			{
				layer.filters = [];
			}
		}
		
		public function glowIn(param1:uint, param2:Number = 1, param3:int = 6, param4:int = 2):void
		{
			var _loc5_:GlowFilter = new GlowFilter(param1, param2, param3, param3, param4, 4);
			layer.filters = [_loc5_];
		}
		
		public function centerPivot():void
		{
			pivotX = width / 2;
			pivotY = height / 2;
		}
		
		public function center():void
		{
			if (_hAlign == H_ALIGN_CENTER && _vAlign == V_ALIGN_MIDDLE)
			{
				return;
			}
			_hAlign = H_ALIGN_CENTER;
			_vAlign = V_ALIGN_MIDDLE;
			draw();
		}
		
		public function alignRight():void
		{
			if (_hAlign == H_ALIGN_RIGHT)
			{
				return;
			}
			_hAlign = H_ALIGN_RIGHT;
			draw();
		}
		
		public function alignLeft():void
		{
			if (_hAlign == H_ALIGN_LEFT)
			{
				return;
			}
			_hAlign = H_ALIGN_LEFT;
			draw();
		}
		
		public function alignCenter():void
		{
			if (_hAlign == H_ALIGN_CENTER)
			{
				return;
			}
			_hAlign = H_ALIGN_CENTER;
			draw();
		}
		
		public function alignTop():void
		{
			if (_vAlign == V_ALIGN_TOP)
			{
				return;
			}
			_vAlign = V_ALIGN_TOP;
			draw();
		}
		
		public function alignMiddle():void
		{
			if (_vAlign == V_ALIGN_MIDDLE)
			{
				return;
			}
			_vAlign = V_ALIGN_MIDDLE;
			draw();
		}
		
		public function alignBottom():void
		{
			if (_vAlign == V_ALIGN_BOTTOM)
			{
				return;
			}
			_vAlign = V_ALIGN_BOTTOM;
			draw();
		}
		
		public function set sharpness(param1:int):void
		{
			if (tf.sharpness == param1)
			{
				return;
			}
			tf.sharpness = param1;
			draw();
		}
		
		public function set size(param1:Number):void
		{
			if (format.size == param1)
			{
				return;
			}
			format.size = param1;
			defaultTextFormat = format;
		}
		
		public function get size():Number
		{
			return format.size as Number;
		}
		
		public function set color(param1:uint):void
		{
			if (param1 == format.color)
			{
				return;
			}
			format.color = param1;
			defaultTextFormat = format;
		}
		
		public function get color():uint
		{
			return format.color as uint;
		}
		
		override public function set width(param1:Number):void
		{
			if (tf.width == param1)
			{
				return;
			}
			tf.width = param1;
			draw();
		}
		
		override public function get width():Number
		{
			return tf.width;
		}
		
		public function set font(param1:String):void
		{
			if (format.font == param1)
			{
				return;
			}
			format.font = param1;
			defaultTextFormat = format;
		}
		
		public function set bold(param1:Boolean):void
		{
			if (format.bold == param1)
			{
				return;
			}
			format.bold = param1;
			defaultTextFormat = format;
		}
		
		public function set wordWrap(param1:Boolean):void
		{
			if (tf.wordWrap == param1)
			{
				return;
			}
			tf.wordWrap = param1;
			if (param1)
			{
				tf.multiline = true;
			}
			else
			{
				tf.multiline = false;
			}
			draw();
		}
		
		override public function set height(param1:Number):void
		{
			if (param1 == tf.height)
			{
				return;
			}
			tf.height = param1;
			draw();
		}
		
		override public function get height():Number
		{
			return tf.textHeight;
		}
		
		public function set htmlText(param1:String):void
		{
			if (oldText == param1)
			{
				return;
			}
			tf.htmlText = param1 == null ? "" : param1;
			oldText = param1;
			var _loc2_:int = tf.textHeight;
			if (!tf.wordWrap)
			{
				tf.width = tf.textWidth + 5;
			}
			else
			{
				_loc2_ += LEADING;
			}
			tf.height = _loc2_;
			draw();
		}
		
		public function get htmlText():String
		{
			return tf.htmlText;
		}
		
		public function set text(param1:String):void
		{
			if (oldText == param1)
			{
				return;
			}
			oldText = param1;
			tf.text = param1 == null ? "" : param1;
			var _loc2_:int = tf.textHeight;
			if (!tf.wordWrap)
			{
				tf.width = tf.textWidth + 5;
			}
			else
			{
				_loc2_ += LEADING;
			}
			tf.height = _loc2_;
			draw();
		}
		
		override public function set x(param1:Number):void
		{
			super.x = Math.floor(param1);
		}
		
		override public function set y(param1:Number):void
		{
			super.y = Math.floor(param1);
		}
		
		public function get text():String
		{
			return tf.text;
		}
		
		public function set defaultTextFormat(param1:TextFormat):void
		{
			tf.defaultTextFormat = param1;
			var _loc2_:String = text;
			oldText = "";
			text = _loc2_;
		}
		
		protected function draw():void
		{
			var bd:BitmapData;
			if (!hasEventListener("removedFromStage"))
			{
				addEventListener("removedFromStage", clean);
			}
			if (tf.text == null || tf.text == "")
			{
				return;
			}
			if (tf.width > 0 && tf.height > 0)
			{
				if (finalLayer != null)
				{
					removeChild(finalLayer);
					finalLayer.dispose();
					finalLayer = null;
					texture.dispose();
					texture = null;
				}
				bd = new BitmapData(tf.width, tf.height, true, BACKGROUND_COLOR);
				bd.lock();
				bd.draw(tf, tf.transform.matrix, tf.transform.colorTransform, tf.blendMode, null, true);
				bd.unlock();
				if (layer.filters.length > 0)
				{
					bd.applyFilter(bd, bd.rect, new Point(), layer.filters[0]);
				}
				if (texture)
				{
					texture.dispose();
					texture = null;
				}
				texture = Texture.fromBitmapData(bd, false);
				bd.dispose();
				texture.root.onRestore = function():void
				{
					var _loc1_:BitmapData = new BitmapData(tf.width, tf.height, true, BACKGROUND_COLOR);
					_loc1_.lock();
					_loc1_.draw(tf, tf.transform.matrix, tf.transform.colorTransform, tf.blendMode, null, true);
					_loc1_.unlock();
					try
					{
						texture.root.uploadBitmapData(_loc1_);
					}
					catch (e:Error)
					{
						trace("Texture restoration failed: " + e.message);
					}
					_loc1_.dispose();
				};
				finalLayer = new Image(texture);
				if (_hAlign == H_ALIGN_CENTER)
				{
					finalLayer.x = -tf.width / 2;
				}
				else if (_hAlign == H_ALIGN_LEFT)
				{
					finalLayer.x = 0;
				}
				else if (_hAlign == H_ALIGN_RIGHT)
				{
					finalLayer.x = -tf.width;
				}
				if (_vAlign == V_ALIGN_MIDDLE)
				{
					finalLayer.y = -tf.height / 2 + LEADING / 2;
				}
				else if (_vAlign == V_ALIGN_TOP)
				{
					finalLayer.y = 0;
				}
				else if (_vAlign == V_ALIGN_BOTTOM)
				{
					finalLayer.y = -tf.height + LEADING / 2;
				}
				addChild(finalLayer);
			}
		}
		
		public function clean(param1:Event = null):void
		{
			removeEventListeners();
			tf.text = "";
			tf.htmlText = "";
			if (texture)
			{
				texture.dispose();
			}
			dispose();
		}
	}
}
