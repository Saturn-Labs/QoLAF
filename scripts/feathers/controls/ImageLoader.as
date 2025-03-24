package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.skins.IStyleProvider;
	import feathers.utils.display.stageToStarling;
	import feathers.utils.textures.TextureCache;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.RectangleUtil;
	import starling.utils.SystemUtil;
	
	public class ImageLoader extends FeathersControl {
		private static const CONTEXT_LOST_WARNING:String = "ImageLoader: Context lost while processing loaded image, retrying...";
		
		protected static const ATF_FILE_EXTENSION:String = "atf";
		
		protected static var textureQueueHead:ImageLoader;
		
		protected static var textureQueueTail:ImageLoader;
		
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		public static const VERTICAL_ALIGN_TOP:String = "top";
		
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_RECTANGLE:Rectangle = new Rectangle();
		
		private static const HELPER_RECTANGLE2:Rectangle = new Rectangle();
		
		protected static const LOADER_CONTEXT:LoaderContext = new LoaderContext(true);
		
		LOADER_CONTEXT.imageDecodingPolicy = "onLoad";
		
		protected var image:Image;
		
		protected var loader:Loader;
		
		protected var urlLoader:URLLoader;
		
		protected var _lastURL:String;
		
		protected var _originalTextureWidth:Number = NaN;
		
		protected var _originalTextureHeight:Number = NaN;
		
		protected var _currentTextureWidth:Number = NaN;
		
		protected var _currentTextureHeight:Number = NaN;
		
		protected var _currentTexture:Texture;
		
		protected var _isRestoringTexture:Boolean = false;
		
		protected var _texture:Texture;
		
		protected var _isTextureOwner:Boolean = false;
		
		protected var _source:Object;
		
		protected var _textureCache:TextureCache;
		
		protected var _loadingTexture:Texture;
		
		protected var _errorTexture:Texture;
		
		protected var _isLoaded:Boolean = false;
		
		private var _textureScale:Number = 1;
		
		private var _scaleFactor:Number = 1;
		
		private var _textureSmoothing:String = "bilinear";
		
		private var _scale9Grid:Rectangle;
		
		private var _tileGrid:Rectangle;
		
		private var _pixelSnapping:Boolean = true;
		
		private var _color:uint = 16777215;
		
		private var _textureFormat:String = "bgra";
		
		private var _scaleContent:Boolean = true;
		
		private var _maintainAspectRatio:Boolean = true;
		
		private var _scaleMode:String = "showAll";
		
		protected var _horizontalAlign:String = "left";
		
		protected var _verticalAlign:String = "top";
		
		protected var _pendingBitmapDataTexture:BitmapData;
		
		protected var _pendingRawTextureData:ByteArray;
		
		protected var _delayTextureCreation:Boolean = false;
		
		protected var _isInTextureQueue:Boolean = false;
		
		protected var _textureQueuePrevious:ImageLoader;
		
		protected var _textureQueueNext:ImageLoader;
		
		protected var _accumulatedPrepareTextureTime:Number;
		
		protected var _textureQueueDuration:Number = Infinity;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		public function ImageLoader() {
			super();
			this.isQuickHitAreaEnabled = true;
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return ImageLoader.globalStyleProvider;
		}
		
		public function get source() : Object {
			return this._source;
		}
		
		public function set source(value:Object) : void {
			var _local2:Texture = null;
			if(this._source == value) {
				return;
			}
			this._isRestoringTexture = false;
			if(this._isInTextureQueue) {
				this.removeFromTextureQueue();
			}
			if(this._isTextureOwner && value && !(value is Texture)) {
				_local2 = this._texture;
				this._isTextureOwner = false;
			}
			this.cleanupTexture();
			this._source = value;
			if(_local2) {
				this._texture = _local2;
				this._isTextureOwner = true;
			}
			if(this.image) {
				this.image.visible = false;
			}
			this.cleanupLoaders(true);
			this._lastURL = null;
			if(this._source is Texture) {
				this._isLoaded = true;
			} else {
				this._isLoaded = false;
			}
			this.invalidate("data");
		}
		
		public function get textureCache() : TextureCache {
			return this._textureCache;
		}
		
		public function set textureCache(value:TextureCache) : void {
			this._textureCache = value;
		}
		
		public function get loadingTexture() : Texture {
			return this._loadingTexture;
		}
		
		public function set loadingTexture(value:Texture) : void {
			if(this._loadingTexture == value) {
				return;
			}
			this._loadingTexture = value;
			this.invalidate("styles");
		}
		
		public function get errorTexture() : Texture {
			return this._errorTexture;
		}
		
		public function set errorTexture(value:Texture) : void {
			if(this._errorTexture == value) {
				return;
			}
			this._errorTexture = value;
			this.invalidate("styles");
		}
		
		public function get isLoaded() : Boolean {
			return this._isLoaded;
		}
		
		public function get textureScale() : Number {
			return this._textureScale;
		}
		
		public function set textureScale(value:Number) : void {
			if(this._textureScale == value) {
				return;
			}
			this._textureScale = value;
			this.invalidate("size");
		}
		
		public function get scaleFactor() : Number {
			return this._textureScale;
		}
		
		public function set scaleFactor(value:Number) : void {
			if(this._scaleFactor == value) {
				return;
			}
			this._scaleFactor = value;
			this.invalidate("size");
		}
		
		public function get textureSmoothing() : String {
			return this._textureSmoothing;
		}
		
		public function set textureSmoothing(value:String) : void {
			if(this._textureSmoothing == value) {
				return;
			}
			this._textureSmoothing = value;
			this.invalidate("styles");
		}
		
		public function get scale9Grid() : Rectangle {
			return this._scale9Grid;
		}
		
		public function set scale9Grid(value:Rectangle) : void {
			if(this._scale9Grid == value) {
				return;
			}
			this._scale9Grid = value;
			this.invalidate("styles");
		}
		
		public function get tileGrid() : Rectangle {
			return this._tileGrid;
		}
		
		public function set tileGrid(value:Rectangle) : void {
			if(this._tileGrid == value) {
				return;
			}
			this._tileGrid = value;
			this.invalidate("styles");
		}
		
		public function get pixelSnapping() : Boolean {
			return this._pixelSnapping;
		}
		
		public function set pixelSnapping(value:Boolean) : void {
			if(this._pixelSnapping == value) {
				return;
			}
			this._pixelSnapping = value;
			this.invalidate("styles");
		}
		
		public function get color() : uint {
			return this._color;
		}
		
		public function set color(value:uint) : void {
			if(this._color == value) {
				return;
			}
			this._color = value;
			this.invalidate("styles");
		}
		
		public function get textureFormat() : String {
			return this._textureFormat;
		}
		
		public function set textureFormat(value:String) : void {
			if(this._textureFormat == value) {
				return;
			}
			this._textureFormat = value;
			this._lastURL = null;
			this.invalidate("data");
		}
		
		public function get scaleContent() : Boolean {
			return this._scaleContent;
		}
		
		public function set scaleContent(value:Boolean) : void {
			if(this._scaleContent == value) {
				return;
			}
			this._scaleContent = value;
			this.invalidate("layout");
		}
		
		public function get maintainAspectRatio() : Boolean {
			return this._maintainAspectRatio;
		}
		
		public function set maintainAspectRatio(value:Boolean) : void {
			if(this._maintainAspectRatio == value) {
				return;
			}
			this._maintainAspectRatio = value;
			this.invalidate("layout");
		}
		
		public function get scaleMode() : String {
			return this._scaleMode;
		}
		
		public function set scaleMode(value:String) : void {
			if(this._scaleMode == value) {
				return;
			}
			this._scaleMode = value;
			this.invalidate("layout");
		}
		
		public function get horizontalAlign() : String {
			return this._horizontalAlign;
		}
		
		public function set horizontalAlign(value:String) : void {
			if(this._horizontalAlign == value) {
				return;
			}
			this._horizontalAlign = value;
			this.invalidate("styles");
		}
		
		public function get verticalAlign() : String {
			return _verticalAlign;
		}
		
		public function set verticalAlign(value:String) : void {
			if(this._verticalAlign == value) {
				return;
			}
			this._verticalAlign = value;
			this.invalidate("styles");
		}
		
		public function get originalSourceWidth() : Number {
			if(this._originalTextureWidth === this._originalTextureWidth) {
				return this._originalTextureWidth;
			}
			return 0;
		}
		
		public function get originalSourceHeight() : Number {
			if(this._originalTextureHeight === this._originalTextureHeight) {
				return this._originalTextureHeight;
			}
			return 0;
		}
		
		public function get delayTextureCreation() : Boolean {
			return this._delayTextureCreation;
		}
		
		public function set delayTextureCreation(value:Boolean) : void {
			if(this._delayTextureCreation == value) {
				return;
			}
			this._delayTextureCreation = value;
			if(!this._delayTextureCreation) {
				this.processPendingTexture();
			}
		}
		
		public function get textureQueueDuration() : Number {
			return this._textureQueueDuration;
		}
		
		public function set textureQueueDuration(value:Number) : void {
			if(this._textureQueueDuration == value) {
				return;
			}
			var _local2:Number = this._textureQueueDuration;
			this._textureQueueDuration = value;
			if(this._delayTextureCreation) {
				if((this._pendingBitmapDataTexture || this._pendingRawTextureData) && _local2 == Infinity && this._textureQueueDuration < Infinity) {
					this.addToTextureQueue();
				} else if(this._isInTextureQueue && this._textureQueueDuration == Infinity) {
					this.removeFromTextureQueue();
				}
			}
		}
		
		public function get padding() : Number {
			return this._paddingTop;
		}
		
		public function set padding(value:Number) : void {
			this.paddingTop = value;
			this.paddingRight = value;
			this.paddingBottom = value;
			this.paddingLeft = value;
		}
		
		public function get paddingTop() : Number {
			return this._paddingTop;
		}
		
		public function set paddingTop(value:Number) : void {
			if(this._paddingTop == value) {
				return;
			}
			this._paddingTop = value;
			this.invalidate("styles");
		}
		
		public function get paddingRight() : Number {
			return this._paddingRight;
		}
		
		public function set paddingRight(value:Number) : void {
			if(this._paddingRight == value) {
				return;
			}
			this._paddingRight = value;
			this.invalidate("styles");
		}
		
		public function get paddingBottom() : Number {
			return this._paddingBottom;
		}
		
		public function set paddingBottom(value:Number) : void {
			if(this._paddingBottom == value) {
				return;
			}
			this._paddingBottom = value;
			this.invalidate("styles");
		}
		
		public function get paddingLeft() : Number {
			return this._paddingLeft;
		}
		
		public function set paddingLeft(value:Number) : void {
			if(this._paddingLeft == value) {
				return;
			}
			this._paddingLeft = value;
			this.invalidate("styles");
		}
		
		override public function dispose() : void {
			this._isRestoringTexture = false;
			if(this.loader) {
				this.loader.contentLoaderInfo.removeEventListener("complete",loader_completeHandler);
				this.loader.contentLoaderInfo.removeEventListener("progress",loader_progressHandler);
				this.loader.contentLoaderInfo.removeEventListener("ioError",loader_ioErrorHandler);
				this.loader.contentLoaderInfo.removeEventListener("securityError",loader_securityErrorHandler);
				try {
					this.loader.close();
				}
				catch(error:Error) {
				}
				this.loader = null;
			}
			this.cleanupTexture();
			super.dispose();
		}
		
		override protected function draw() : void {
			var _local3:Boolean = this.isInvalid("data");
			var _local2:Boolean = this.isInvalid("layout");
			var _local4:Boolean = this.isInvalid("styles");
			var _local1:Boolean = this.isInvalid("size");
			if(_local3) {
				this.commitData();
			}
			if(_local3 || _local4) {
				this.commitStyles();
			}
			_local1 = this.autoSizeIfNeeded() || _local1;
			if(_local3 || _local2 || _local1 || _local4) {
				this.layout();
			}
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local3:Number = NaN;
			var _local1:Number = NaN;
			var _local4:* = this._explicitWidth !== this._explicitWidth;
			var _local6:* = this._explicitHeight !== this._explicitHeight;
			if(!_local4 && !_local6) {
				return false;
			}
			var _local2:Number = this._explicitWidth;
			if(_local4) {
				if(this._currentTextureWidth === this._currentTextureWidth) {
					_local2 = this._currentTextureWidth * this._textureScale;
					if(this._scaleContent && this._maintainAspectRatio && this._scaleMode !== "none") {
						_local3 = 1;
						if(!_local6) {
							_local3 = this._explicitHeight / (this._currentTextureHeight * this._textureScale);
						} else if(this._explicitMaxHeight < this._currentTextureHeight) {
							_local3 = this._explicitMaxHeight / (this._currentTextureHeight * this._textureScale);
						} else if(this._explicitMinHeight > this._currentTextureHeight) {
							_local3 = this._explicitMinHeight / (this._currentTextureHeight * this._textureScale);
						}
						if(_local3 !== 1) {
							_local2 *= _local3;
						}
					}
				} else {
					_local2 = 0;
				}
				_local2 += this._paddingLeft + this._paddingRight;
			}
			var _local5:Number = this._explicitHeight;
			if(_local6) {
				if(this._currentTextureHeight === this._currentTextureHeight) {
					_local5 = this._currentTextureHeight * this._textureScale;
					if(this._scaleContent && this._maintainAspectRatio && this._scaleMode !== "none") {
						_local1 = 1;
						if(!_local4) {
							_local1 = this._explicitWidth / (this._currentTextureWidth * this._textureScale);
						} else if(this._explicitMaxWidth < this._currentTextureWidth) {
							_local1 = this._explicitMaxWidth / (this._currentTextureWidth * this._textureScale);
						} else if(this._explicitMinWidth > this._currentTextureWidth) {
							_local1 = this._explicitMinWidth / (this._currentTextureWidth * this._textureScale);
						}
						if(_local1 !== 1) {
							_local5 *= _local1;
						}
					}
				} else {
					_local5 = 0;
				}
				_local5 += this._paddingTop + this._paddingBottom;
			}
			return this.saveMeasurements(_local2,_local5,_local2,_local5);
		}
		
		protected function commitData() : void {
			var _local1:String = null;
			if(this._source is Texture) {
				this._lastURL = null;
				this._texture = Texture(this._source);
				this.refreshCurrentTexture();
			} else {
				_local1 = this._source as String;
				if(!_local1) {
					this._lastURL = null;
				} else if(_local1 != this._lastURL) {
					this._lastURL = _local1;
					if(this.findSourceInCache()) {
						return;
					}
					if(isATFURL(_local1)) {
						if(this.loader) {
							this.loader = null;
						}
						if(!this.urlLoader) {
							this.urlLoader = new URLLoader();
							this.urlLoader.dataFormat = "binary";
						}
						this.urlLoader.addEventListener("complete",rawDataLoader_completeHandler);
						this.urlLoader.addEventListener("progress",rawDataLoader_progressHandler);
						this.urlLoader.addEventListener("ioError",rawDataLoader_ioErrorHandler);
						this.urlLoader.addEventListener("securityError",rawDataLoader_securityErrorHandler);
						this.urlLoader.load(new URLRequest(_local1));
						return;
					}
					if(this.urlLoader) {
						this.urlLoader = null;
					}
					if(!this.loader) {
						this.loader = new Loader();
					}
					this.loader.contentLoaderInfo.addEventListener("complete",loader_completeHandler);
					this.loader.contentLoaderInfo.addEventListener("progress",loader_progressHandler);
					this.loader.contentLoaderInfo.addEventListener("ioError",loader_ioErrorHandler);
					this.loader.contentLoaderInfo.addEventListener("securityError",loader_securityErrorHandler);
					this.loader.load(new URLRequest(_local1),LOADER_CONTEXT);
				}
				this.refreshCurrentTexture();
			}
		}
		
		protected function commitStyles() : void {
			if(!this.image) {
				return;
			}
			this.image.textureSmoothing = this._textureSmoothing;
			this.image.color = this._color;
			this.image.scale9Grid = this._scale9Grid;
			this.image.tileGrid = this._tileGrid;
			this.image.pixelSnapping = this._pixelSnapping;
		}
		
		protected function layout() : void {
			var _local1:Number = NaN;
			var _local2:Number = NaN;
			var _local3:Quad = null;
			if(!this.image || !this._currentTexture) {
				return;
			}
			if(this._scaleContent) {
				if(this._maintainAspectRatio) {
					HELPER_RECTANGLE.x = 0;
					HELPER_RECTANGLE.y = 0;
					HELPER_RECTANGLE.width = this._currentTextureWidth * this._textureScale;
					HELPER_RECTANGLE.height = this._currentTextureHeight * this._textureScale;
					HELPER_RECTANGLE2.x = 0;
					HELPER_RECTANGLE2.y = 0;
					HELPER_RECTANGLE2.width = this.actualWidth - this._paddingLeft - this._paddingRight;
					HELPER_RECTANGLE2.height = this.actualHeight - this._paddingTop - this._paddingBottom;
					RectangleUtil.fit(HELPER_RECTANGLE,HELPER_RECTANGLE2,this._scaleMode,false,HELPER_RECTANGLE);
					this.image.x = HELPER_RECTANGLE.x + this._paddingLeft;
					this.image.y = HELPER_RECTANGLE.y + this._paddingTop;
					this.image.width = HELPER_RECTANGLE.width;
					this.image.height = HELPER_RECTANGLE.height;
				} else {
					this.image.x = this._paddingLeft;
					this.image.y = this._paddingTop;
					this.image.width = this.actualWidth - this._paddingLeft - this._paddingRight;
					this.image.height = this.actualHeight - this._paddingTop - this._paddingBottom;
				}
			} else {
				_local1 = this._currentTextureWidth * this._textureScale;
				_local2 = this._currentTextureHeight * this._textureScale;
				if(this._horizontalAlign === "right") {
					this.image.x = this.actualWidth - this._paddingRight - _local1;
				} else if(this._horizontalAlign === "center") {
					this.image.x = this._paddingLeft + (this.actualWidth - this._paddingLeft - this._paddingRight - _local1) / 2;
				} else {
					this.image.x = this._paddingLeft;
				}
				if(this._verticalAlign === "bottom") {
					this.image.y = this.actualHeight - this._paddingBottom - _local2;
				} else if(this._verticalAlign === "middle") {
					this.image.y = this._paddingTop + (this.actualHeight - this._paddingTop - this._paddingBottom - _local2) / 2;
				} else {
					this.image.y = this._paddingTop;
				}
				this.image.width = _local1;
				this.image.height = _local2;
			}
			if((!this._scaleContent || this._maintainAspectRatio && this._scaleMode !== "showAll") && (this.actualWidth != _local1 || this.actualHeight != _local2)) {
				_local3 = this.image.mask as Quad;
				if(_local3 !== null) {
					_local3.x = 0;
					_local3.y = 0;
					_local3.width = this.actualWidth;
					_local3.height = this.actualHeight;
				} else {
					_local3 = new Quad(1,1,0xff00ff);
					_local3.width = this.actualWidth;
					_local3.height = this.actualHeight;
					this.image.mask = _local3;
					this.addChild(_local3);
				}
			} else {
				_local3 = this.image.mask as Quad;
				if(_local3 !== null) {
					_local3.removeFromParent(true);
					this.image.mask = null;
				}
			}
		}
		
		protected function isATFURL(sourceURL:String) : Boolean {
			var _local2:int = int(sourceURL.indexOf("?"));
			if(_local2 >= 0) {
				sourceURL = sourceURL.substr(0,_local2);
			}
			return sourceURL.toLowerCase().lastIndexOf("atf") === sourceURL.length - 3;
		}
		
		protected function refreshCurrentTexture() : void {
			var _local1:Texture = this._isLoaded ? this._texture : null;
			if(!_local1) {
				if(this.loader || this.urlLoader) {
					_local1 = this._loadingTexture;
				} else {
					_local1 = this._errorTexture;
				}
			}
			if(this._currentTexture == _local1) {
				return;
			}
			this._currentTexture = _local1;
			if(!this._currentTexture) {
				if(this.image) {
					this.removeChild(this.image,true);
					this.image = null;
				}
				return;
			}
			var _local2:Rectangle = this._currentTexture.frame;
			if(_local2) {
				this._currentTextureWidth = _local2.width;
				this._currentTextureHeight = _local2.height;
			} else {
				this._currentTextureWidth = this._currentTexture.width;
				this._currentTextureHeight = this._currentTexture.height;
				this._originalTextureWidth = this._currentTexture.nativeWidth;
				this._originalTextureHeight = this._currentTexture.nativeHeight;
			}
			if(!this.image) {
				this.image = new Image(this._currentTexture);
				this.addChild(this.image);
			} else {
				this.image.texture = this._currentTexture;
				this.image.readjustSize();
			}
			this.image.visible = true;
		}
		
		protected function cleanupTexture() : void {
			if(this._texture) {
				if(this._isTextureOwner) {
					this._texture.dispose();
				} else if(this._textureCache && this._source is String) {
					this._textureCache.releaseTexture(this._source as String);
				}
			}
			if(this._pendingBitmapDataTexture) {
				this._pendingBitmapDataTexture.dispose();
			}
			if(this._pendingRawTextureData) {
				this._pendingRawTextureData.clear();
			}
			this._currentTexture = null;
			this._currentTextureWidth = NaN;
			this._currentTextureHeight = NaN;
			this._originalTextureWidth = NaN;
			this._originalTextureHeight = NaN;
			this._pendingBitmapDataTexture = null;
			this._pendingRawTextureData = null;
			this._texture = null;
			this._isTextureOwner = false;
		}
		
		protected function cleanupLoaders(close:Boolean) : void {
			if(this.urlLoader) {
				this.urlLoader.removeEventListener("complete",rawDataLoader_completeHandler);
				this.urlLoader.removeEventListener("progress",rawDataLoader_progressHandler);
				this.urlLoader.removeEventListener("ioError",rawDataLoader_ioErrorHandler);
				this.urlLoader.removeEventListener("securityError",rawDataLoader_securityErrorHandler);
				if(close) {
					try {
						this.urlLoader.close();
					}
					catch(error:Error) {
					}
				}
				this.urlLoader = null;
			}
			if(this.loader) {
				this.loader.contentLoaderInfo.removeEventListener("complete",loader_completeHandler);
				this.loader.contentLoaderInfo.removeEventListener("progress",loader_progressHandler);
				this.loader.contentLoaderInfo.removeEventListener("ioError",loader_ioErrorHandler);
				this.loader.contentLoaderInfo.removeEventListener("securityError",loader_securityErrorHandler);
				if(close) {
					try {
						this.loader.close();
					}
					catch(error:Error) {
					}
				}
				this.loader = null;
			}
		}
		
		protected function findSourceInCache() : Boolean {
			var _local1:String = this._source as String;
			if(this._textureCache && !this._isRestoringTexture && this._textureCache.hasTexture(_local1)) {
				this._texture = this._textureCache.retainTexture(_local1);
				this._isTextureOwner = false;
				this._isRestoringTexture = false;
				this._isLoaded = true;
				this.refreshCurrentTexture();
				this.dispatchEventWith("complete");
				return true;
			}
			return false;
		}
		
		protected function verifyCurrentStarling() : void {
			if(!this.stage || Starling.current.stage === this.stage) {
				return;
			}
			var _local1:Starling = stageToStarling(this.stage);
			_local1.makeCurrent();
		}
		
		protected function replaceBitmapDataTexture(bitmapData:BitmapData) : void {
			var _local2:String = null;
			if(!Starling.current.contextValid) {
				trace("ImageLoader: Context lost while processing loaded image, retrying...");
				setTimeout(replaceBitmapDataTexture,1,bitmapData);
				return;
			}
			if(!SystemUtil.isDesktop && !SystemUtil.isApplicationActive) {
				SystemUtil.executeWhenApplicationIsActive(replaceBitmapDataTexture,bitmapData);
				return;
			}
			this.verifyCurrentStarling();
			if(this.findSourceInCache()) {
				bitmapData.dispose();
				this.invalidate("data");
				return;
			}
			if(!this._texture) {
				this._texture = Texture.empty(bitmapData.width / this._scaleFactor,bitmapData.height / this._scaleFactor,true,false,false,this._scaleFactor,this._textureFormat);
				_local2 = this._source as String;
				this._texture.root.onRestore = this.createTextureOnRestore(this._texture,_local2,this._textureFormat,this._scaleFactor);
				if(this._textureCache) {
					this._textureCache.addTexture(_local2,this._texture,true);
				}
			}
			this._texture.root.uploadBitmapData(bitmapData);
			bitmapData.dispose();
			this._isTextureOwner = this._textureCache === null;
			this._isRestoringTexture = false;
			this._isLoaded = true;
			this.invalidate("data");
			this.dispatchEventWith("complete");
		}
		
		protected function replaceRawTextureData(rawData:ByteArray) : void {
			var _local2:String = null;
			if(!Starling.current.contextValid) {
				trace("ImageLoader: Context lost while processing loaded image, retrying...");
				setTimeout(replaceRawTextureData,1,rawData);
				return;
			}
			if(!SystemUtil.isDesktop && !SystemUtil.isApplicationActive) {
				SystemUtil.executeWhenApplicationIsActive(replaceRawTextureData,rawData);
				return;
			}
			this.verifyCurrentStarling();
			if(this.findSourceInCache()) {
				rawData.clear();
				this.invalidate("data");
				return;
			}
			if(this._texture) {
				this._texture.root.uploadAtfData(rawData);
			} else {
				this._texture = Texture.fromAtfData(rawData,this._scaleFactor);
				_local2 = this._source as String;
				this._texture.root.onRestore = this.createTextureOnRestore(this._texture,_local2,this._textureFormat,this._scaleFactor);
				if(this._textureCache) {
					this._textureCache.addTexture(_local2,this._texture,true);
				}
			}
			rawData.clear();
			this._isTextureOwner = this._textureCache === null;
			this._isRestoringTexture = false;
			this._isLoaded = true;
			this.invalidate("data");
			this.dispatchEventWith("complete");
		}
		
		protected function addToTextureQueue() : void {
			if(!this._delayTextureCreation) {
				throw new IllegalOperationError("Cannot add loader to delayed texture queue if delayTextureCreation is false.");
			}
			if(this._textureQueueDuration == Infinity) {
				throw new IllegalOperationError("Cannot add loader to delayed texture queue if textureQueueDuration is Number.POSITIVE_INFINITY.");
			}
			if(this._isInTextureQueue) {
				throw new IllegalOperationError("Cannot add loader to delayed texture queue more than once.");
			}
			this.addEventListener("removedFromStage",imageLoader_removedFromStageHandler);
			this._isInTextureQueue = true;
			if(textureQueueTail) {
				textureQueueTail._textureQueueNext = this;
				this._textureQueuePrevious = textureQueueTail;
				textureQueueTail = this;
			} else {
				textureQueueHead = this;
				textureQueueTail = this;
				this.preparePendingTexture();
			}
		}
		
		protected function removeFromTextureQueue() : void {
			if(!this._isInTextureQueue) {
				return;
			}
			var _local2:ImageLoader = this._textureQueuePrevious;
			var _local1:ImageLoader = this._textureQueueNext;
			this._textureQueuePrevious = null;
			this._textureQueueNext = null;
			this._isInTextureQueue = false;
			this.removeEventListener("removedFromStage",imageLoader_removedFromStageHandler);
			this.removeEventListener("enterFrame",processTextureQueue_enterFrameHandler);
			if(_local2) {
				_local2._textureQueueNext = _local1;
			}
			if(_local1) {
				_local1._textureQueuePrevious = _local2;
			}
			var _local3:* = textureQueueHead == this;
			var _local4:* = textureQueueTail == this;
			if(_local4) {
				textureQueueTail = _local2;
				if(_local3) {
					textureQueueHead = _local2;
				}
			}
			if(_local3) {
				textureQueueHead = _local1;
				if(_local4) {
					textureQueueTail = _local1;
				}
			}
			if(_local3 && textureQueueHead) {
				textureQueueHead.preparePendingTexture();
			}
		}
		
		protected function preparePendingTexture() : void {
			if(this._textureQueueDuration > 0) {
				this._accumulatedPrepareTextureTime = 0;
				this.addEventListener("enterFrame",processTextureQueue_enterFrameHandler);
			} else {
				this.processPendingTexture();
			}
		}
		
		protected function processPendingTexture() : void {
			var _local1:BitmapData = null;
			var _local2:ByteArray = null;
			if(this._pendingBitmapDataTexture) {
				_local1 = this._pendingBitmapDataTexture;
				this._pendingBitmapDataTexture = null;
				this.replaceBitmapDataTexture(_local1);
			}
			if(this._pendingRawTextureData) {
				_local2 = this._pendingRawTextureData;
				this._pendingRawTextureData = null;
				this.replaceRawTextureData(_local2);
			}
			if(this._isInTextureQueue) {
				this.removeFromTextureQueue();
			}
		}
		
		protected function createTextureOnRestore(texture:Texture, source:String, format:String, scaleFactor:Number) : Function {
			return function():void {
				if(_texture === texture) {
					texture_onRestore();
					return;
				}
				var _local1:ImageLoader = new ImageLoader();
				_local1.source = source;
				_local1._texture = texture;
				_local1._textureFormat = format;
				_local1._scaleFactor = scaleFactor;
				_local1.validate();
				_local1.addEventListener("complete",onRestore_onComplete);
			};
		}
		
		protected function onRestore_onComplete(event:starling.events.Event) : void {
			var _local2:ImageLoader = ImageLoader(event.currentTarget);
			_local2._isTextureOwner = false;
			_local2._texture = null;
			_local2.dispose();
		}
		
		protected function texture_onRestore() : void {
			this._isRestoringTexture = true;
			this._lastURL = null;
			this._isLoaded = false;
			this.invalidate("data");
		}
		
		protected function processTextureQueue_enterFrameHandler(event:EnterFrameEvent) : void {
			this._accumulatedPrepareTextureTime += event.passedTime;
			if(this._accumulatedPrepareTextureTime >= this._textureQueueDuration) {
				this.removeEventListener("enterFrame",processTextureQueue_enterFrameHandler);
				this.processPendingTexture();
			}
		}
		
		protected function imageLoader_removedFromStageHandler(event:starling.events.Event) : void {
			if(this._isInTextureQueue) {
				this.removeFromTextureQueue();
			}
		}
		
		protected function loader_completeHandler(event:flash.events.Event) : void {
			var _local3:Bitmap = Bitmap(this.loader.content);
			this.cleanupLoaders(false);
			var _local2:BitmapData = _local3.bitmapData;
			var _local4:Boolean = this._texture && this._texture.nativeWidth === _local2.width && this._texture.nativeHeight === _local2.height && this._texture.scale === this._scaleFactor && this._texture.format === this._textureFormat;
			if(!_local4) {
				this.cleanupTexture();
			}
			if(this._delayTextureCreation && !this._isRestoringTexture) {
				this._pendingBitmapDataTexture = _local2;
				if(this._textureQueueDuration < Infinity) {
					this.addToTextureQueue();
				}
			} else {
				this.replaceBitmapDataTexture(_local2);
			}
		}
		
		protected function loader_progressHandler(event:ProgressEvent) : void {
			this.dispatchEventWith("progress",false,event.bytesLoaded / event.bytesTotal);
		}
		
		protected function loader_ioErrorHandler(event:IOErrorEvent) : void {
			this.cleanupLoaders(false);
			this.cleanupTexture();
			this.invalidate("data");
			this.dispatchEventWith("error",false,event);
			this.dispatchEventWith("ioError",false,event);
		}
		
		protected function loader_securityErrorHandler(event:SecurityErrorEvent) : void {
			this.cleanupLoaders(false);
			this.cleanupTexture();
			this.invalidate("data");
			this.dispatchEventWith("error",false,event);
			this.dispatchEventWith("securityError",false,event);
		}
		
		protected function rawDataLoader_completeHandler(event:flash.events.Event) : void {
			var _local2:ByteArray = ByteArray(this.urlLoader.data);
			this.cleanupLoaders(false);
			if(!this._isRestoringTexture) {
				this.cleanupTexture();
			}
			if(this._delayTextureCreation && !this._isRestoringTexture) {
				this._pendingRawTextureData = _local2;
				if(this._textureQueueDuration < Infinity) {
					this.addToTextureQueue();
				}
			} else {
				this.replaceRawTextureData(_local2);
			}
		}
		
		protected function rawDataLoader_progressHandler(event:ProgressEvent) : void {
			this.dispatchEventWith("progress",false,event.bytesLoaded / event.bytesTotal);
		}
		
		protected function rawDataLoader_ioErrorHandler(event:ErrorEvent) : void {
			this.cleanupLoaders(false);
			this.cleanupTexture();
			this.invalidate("data");
			this.dispatchEventWith("error",false,event);
			this.dispatchEventWith("ioError",false,event);
		}
		
		protected function rawDataLoader_securityErrorHandler(event:ErrorEvent) : void {
			this.cleanupLoaders(false);
			this.cleanupTexture();
			this.invalidate("data");
			this.dispatchEventWith("error",false,event);
			this.dispatchEventWith("securityError",false,event);
		}
	}
}

