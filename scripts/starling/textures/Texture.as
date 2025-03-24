package starling.textures {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.display3D.textures.VideoTexture;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.net.NetStream;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import starling.core.Starling;
	import starling.errors.AbstractClassError;
	import starling.errors.MissingContextError;
	import starling.errors.NotSupportedError;
	import starling.rendering.VertexData;
	import starling.utils.MathUtil;
	import starling.utils.MatrixUtil;
	import starling.utils.SystemUtil;
	
	public class Texture {
		private static var sDefaultOptions:TextureOptions = new TextureOptions();
		
		private static var sRectangle:Rectangle = new Rectangle();
		
		private static var sMatrix:Matrix = new Matrix();
		
		private static var sPoint:Point = new Point();
		
		public function Texture() {
			super();
			if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.textures::Texture") {
				throw new AbstractClassError();
			}
		}
		
		public static function fromData(data:Object, options:TextureOptions = null) : starling.textures.Texture {
			if(data is Bitmap) {
				data = (data as Bitmap).bitmapData;
			}
			if(options == null) {
				options = sDefaultOptions;
			}
			if(data is Class) {
				return fromEmbeddedAsset(data as Class,options.mipMapping,options.optimizeForRenderToTexture,options.scale,options.format,options.forcePotTexture);
			}
			if(data is BitmapData) {
				return fromBitmapData(data as BitmapData,options.mipMapping,options.optimizeForRenderToTexture,options.scale,options.format,options.forcePotTexture);
			}
			if(data is ByteArray) {
				return fromAtfData(data as ByteArray,options.scale,options.mipMapping,options.onReady);
			}
			throw new ArgumentError("Unsupported \'data\' type: " + getQualifiedClassName(data));
		}
		
		public static function fromTextureBase(base:TextureBase, width:int, height:int, options:TextureOptions = null) : ConcreteTexture {
			if(options == null) {
				options = sDefaultOptions;
			}
			if(base is flash.display3D.textures.Texture) {
				return new ConcretePotTexture(base as flash.display3D.textures.Texture,options.format,width,height,options.mipMapping,options.premultipliedAlpha,options.optimizeForRenderToTexture,options.scale);
			}
			if(base is RectangleTexture) {
				return new ConcreteRectangleTexture(base as RectangleTexture,options.format,width,height,options.premultipliedAlpha,options.optimizeForRenderToTexture,options.scale);
			}
			if(base is VideoTexture) {
				return new ConcreteVideoTexture(base as VideoTexture,options.scale);
			}
			throw new ArgumentError("Unsupported \'base\' type: " + getQualifiedClassName(base));
		}
		
		public static function fromEmbeddedAsset(assetClass:Class, mipMapping:Boolean = false, optimizeForRenderToTexture:Boolean = false, scale:Number = 1, format:String = "bgra", forcePotTexture:Boolean = false) : starling.textures.Texture {
			var texture:starling.textures.Texture;
			var asset:Object = new assetClass();
			if(asset is Bitmap) {
				texture = starling.textures.Texture.fromBitmap(asset as Bitmap,mipMapping,optimizeForRenderToTexture,scale,format,forcePotTexture);
				texture.root.onRestore = function():void {
					texture.root.uploadBitmap(new assetClass());
				};
			} else {
				if(!(asset is ByteArray)) {
					throw new ArgumentError("Invalid asset type: " + getQualifiedClassName(asset));
				}
				texture = starling.textures.Texture.fromAtfData(asset as ByteArray,scale,mipMapping,null);
				texture.root.onRestore = function():void {
					texture.root.uploadAtfData(new assetClass());
				};
			}
			asset = null;
			return texture;
		}
		
		public static function fromBitmap(bitmap:Bitmap, generateMipMaps:Boolean = false, optimizeForRenderToTexture:Boolean = false, scale:Number = 1, format:String = "bgra", forcePotTexture:Boolean = false) : starling.textures.Texture {
			return fromBitmapData(bitmap.bitmapData,generateMipMaps,optimizeForRenderToTexture,scale,format,forcePotTexture);
		}
		
		public static function fromBitmapData(data:BitmapData, generateMipMaps:Boolean = false, optimizeForRenderToTexture:Boolean = false, scale:Number = 1, format:String = "bgra", forcePotTexture:Boolean = false) : starling.textures.Texture {
			var texture:starling.textures.Texture = starling.textures.Texture.empty(data.width / scale,data.height / scale,true,generateMipMaps,optimizeForRenderToTexture,scale,format,forcePotTexture);
			texture.root.uploadBitmapData(data);
			texture.root.onRestore = function():void {
				texture.root.uploadBitmapData(data);
			};
			return texture;
		}
		
		public static function fromAtfData(data:ByteArray, scale:Number = 1, useMipMaps:Boolean = true, async:Function = null, premultipliedAlpha:Boolean = false) : starling.textures.Texture {
			var atfData:AtfData;
			var nativeTexture:flash.display3D.textures.Texture;
			var concreteTexture:ConcreteTexture;
			var context:Context3D = Starling.context;
			if(context == null) {
				throw new MissingContextError();
			}
			atfData = new AtfData(data);
			nativeTexture = context.createTexture(atfData.width,atfData.height,atfData.format,false);
			concreteTexture = new ConcretePotTexture(nativeTexture,atfData.format,atfData.width,atfData.height,useMipMaps && atfData.numTextures > 1,premultipliedAlpha,false,scale);
			concreteTexture.uploadAtfData(data,0,async);
			concreteTexture.onRestore = function():void {
				concreteTexture.uploadAtfData(data,0);
			};
			return concreteTexture;
		}
		
		public static function fromNetStream(stream:NetStream, scale:Number = 1, onComplete:Function = null) : starling.textures.Texture {
			if(stream.client == stream && !("onMetaData" in stream)) {
				stream.client = {"onMetaData":function(param1:Object):void {
				}};
			}
			return fromVideoAttachment("NetStream",stream,scale,onComplete);
		}
		
		public static function fromCamera(camera:Camera, scale:Number = 1, onComplete:Function = null) : starling.textures.Texture {
			return fromVideoAttachment("Camera",camera,scale,onComplete);
		}
		
		private static function fromVideoAttachment(type:String, attachment:Object, scale:Number, onComplete:Function) : starling.textures.Texture {
			var context:Context3D;
			var base:VideoTexture;
			var texture:ConcreteTexture;
			if(!SystemUtil.supportsVideoTexture) {
				throw new NotSupportedError("Video Textures are not supported on this platform");
			}
			context = Starling.context;
			if(context == null) {
				throw new MissingContextError();
			}
			base = context.createVideoTexture();
			texture = new ConcreteVideoTexture(base,scale);
			texture.attachVideo(type,attachment,onComplete);
			texture.onRestore = function():void {
				texture.root.attachVideo(type,attachment);
			};
			return texture;
		}
		
		public static function fromColor(width:Number, height:Number, color:uint = 16777215, alpha:Number = 1, optimizeForRenderToTexture:Boolean = false, scale:Number = -1, format:String = "bgra", forcePotTexture:Boolean = false) : starling.textures.Texture {
			var texture:starling.textures.Texture = starling.textures.Texture.empty(width,height,true,false,optimizeForRenderToTexture,scale,format,forcePotTexture);
			texture.root.clear(color,alpha);
			texture.root.onRestore = function():void {
				texture.root.clear(color,alpha);
			};
			return texture;
		}
		
		public static function empty(width:Number, height:Number, premultipliedAlpha:Boolean = true, mipMapping:Boolean = false, optimizeForRenderToTexture:Boolean = false, scale:Number = -1, format:String = "bgra", forcePotTexture:Boolean = false) : starling.textures.Texture {
			var _local11:int = 0;
			var _local10:int = 0;
			var _local13:TextureBase = null;
			var _local14:ConcreteTexture = null;
			if(scale <= 0) {
				scale = Starling.contentScaleFactor;
			}
			var _local15:Context3D = Starling.context;
			if(_local15 == null) {
				throw new MissingContextError();
			}
			var _local16:Number = width * scale;
			var _local9:Number = height * scale;
			var _local12:Boolean = !forcePotTexture && !mipMapping && Starling.current.profile != "baselineConstrained" && format.indexOf("compressed") == -1;
			if(_local12) {
				_local10 = Math.ceil(_local16 - 1e-9);
				_local11 = Math.ceil(_local9 - 1e-9);
				_local13 = _local15.createRectangleTexture(_local10,_local11,format,optimizeForRenderToTexture);
				_local14 = new ConcreteRectangleTexture(_local13 as RectangleTexture,format,_local10,_local11,premultipliedAlpha,optimizeForRenderToTexture,scale);
			} else {
				_local10 = MathUtil.getNextPowerOfTwo(_local16);
				_local11 = MathUtil.getNextPowerOfTwo(_local9);
				_local13 = _local15.createTexture(_local10,_local11,format,optimizeForRenderToTexture);
				_local14 = new ConcretePotTexture(_local13 as flash.display3D.textures.Texture,format,_local10,_local11,mipMapping,premultipliedAlpha,optimizeForRenderToTexture,scale);
			}
			_local14.onRestore = _local14.clear;
			if(_local10 - _local16 < 0.001 && _local11 - _local9 < 0.001) {
				return _local14;
			}
			return new SubTexture(_local14,new Rectangle(0,0,width,height),true);
		}
		
		public static function fromTexture(texture:starling.textures.Texture, region:Rectangle = null, frame:Rectangle = null, rotated:Boolean = false, scaleModifier:Number = 1) : starling.textures.Texture {
			return new SubTexture(texture,region,false,frame,rotated,scaleModifier);
		}
		
		public static function get maxSize() : int {
			var _local2:Starling = Starling.current;
			var _local1:String = !!_local2 ? _local2.profile : "baseline";
			if(_local1 == "baseline" || _local1 == "baselineConstrained") {
				return 2048;
			}
			return 0x1000;
		}
		
		public function dispose() : void {
		}
		
		public function setupVertexPositions(vertexData:VertexData, vertexID:int = 0, attrName:String = "position", bounds:Rectangle = null) : void {
			var _local5:Number = NaN;
			var _local6:Number = NaN;
			var _local8:Rectangle = this.frame;
			var _local7:Number = this.width;
			var _local9:Number = this.height;
			if(_local8) {
				sRectangle.setTo(-_local8.x,-_local8.y,_local7,_local9);
			} else {
				sRectangle.setTo(0,0,_local7,_local9);
			}
			vertexData.setPoint(vertexID,attrName,sRectangle.left,sRectangle.top);
			vertexData.setPoint(vertexID + 1,attrName,sRectangle.right,sRectangle.top);
			vertexData.setPoint(vertexID + 2,attrName,sRectangle.left,sRectangle.bottom);
			vertexData.setPoint(vertexID + 3,attrName,sRectangle.right,sRectangle.bottom);
			if(bounds) {
				_local5 = bounds.width / frameWidth;
				_local6 = bounds.height / frameHeight;
				if(_local5 != 1 || _local6 != 1 || bounds.x != 0 || bounds.y != 0) {
					sMatrix.identity();
					sMatrix.scale(_local5,_local6);
					sMatrix.translate(bounds.x,bounds.y);
					vertexData.transformPoints(attrName,sMatrix,vertexID,4);
				}
			}
		}
		
		public function setupTextureCoordinates(vertexData:VertexData, vertexID:int = 0, attrName:String = "texCoords") : void {
			setTexCoords(vertexData,vertexID,attrName,0,0);
			setTexCoords(vertexData,vertexID + 1,attrName,1,0);
			setTexCoords(vertexData,vertexID + 2,attrName,0,1);
			setTexCoords(vertexData,vertexID + 3,attrName,1,1);
		}
		
		public function localToGlobal(u:Number, v:Number, out:Point = null) : Point {
			if(out == null) {
				out = new Point();
			}
			if(this == root) {
				out.setTo(u,v);
			} else {
				MatrixUtil.transformCoords(transformationMatrixToRoot,u,v,out);
			}
			return out;
		}
		
		public function globalToLocal(u:Number, v:Number, out:Point = null) : Point {
			if(out == null) {
				out = new Point();
			}
			if(this == root) {
				out.setTo(u,v);
			} else {
				sMatrix.identity();
				sMatrix.copyFrom(transformationMatrixToRoot);
				sMatrix.invert();
				MatrixUtil.transformCoords(sMatrix,u,v,out);
			}
			return out;
		}
		
		public function setTexCoords(vertexData:VertexData, vertexID:int, attrName:String, u:Number, v:Number) : void {
			localToGlobal(u,v,sPoint);
			vertexData.setPoint(vertexID,attrName,sPoint.x,sPoint.y);
		}
		
		public function getTexCoords(vertexData:VertexData, vertexID:int, attrName:String = "texCoords", out:Point = null) : Point {
			if(out == null) {
				out = new Point();
			}
			vertexData.getPoint(vertexID,attrName,out);
			return globalToLocal(out.x,out.y,out);
		}
		
		public function get frame() : Rectangle {
			return null;
		}
		
		public function get frameWidth() : Number {
			return !!frame ? frame.width : width;
		}
		
		public function get frameHeight() : Number {
			return !!frame ? frame.height : height;
		}
		
		public function get width() : Number {
			return 0;
		}
		
		public function get height() : Number {
			return 0;
		}
		
		public function get nativeWidth() : Number {
			return 0;
		}
		
		public function get nativeHeight() : Number {
			return 0;
		}
		
		public function get scale() : Number {
			return 1;
		}
		
		public function get base() : TextureBase {
			return null;
		}
		
		public function get root() : ConcreteTexture {
			return null;
		}
		
		public function get format() : String {
			return "bgra";
		}
		
		public function get mipMapping() : Boolean {
			return false;
		}
		
		public function get premultipliedAlpha() : Boolean {
			return false;
		}
		
		public function get transformationMatrix() : Matrix {
			return null;
		}
		
		public function get transformationMatrixToRoot() : Matrix {
			return null;
		}
	}
}

