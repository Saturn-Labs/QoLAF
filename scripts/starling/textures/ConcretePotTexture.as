package starling.textures {
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import starling.core.Starling;
	import starling.utils.MathUtil;
	import starling.utils.execute;
	
	internal class ConcretePotTexture extends ConcreteTexture {
		private static var sMatrix:Matrix = new Matrix();
		
		private static var sRectangle:Rectangle = new Rectangle();
		
		private static var sOrigin:Point = new Point();
		
		private var _textureReadyCallback:Function;
		
		public function ConcretePotTexture(base:flash.display3D.textures.Texture, format:String, width:int, height:int, mipMapping:Boolean, premultipliedAlpha:Boolean, optimizedForRenderTexture:Boolean = false, scale:Number = 1) {
			super(base,format,width,height,mipMapping,premultipliedAlpha,optimizedForRenderTexture,scale);
			if(width != MathUtil.getNextPowerOfTwo(width)) {
				throw new ArgumentError("width must be a power of two");
			}
			if(height != MathUtil.getNextPowerOfTwo(height)) {
				throw new ArgumentError("height must be a power of two");
			}
		}
		
		override public function dispose() : void {
			base.removeEventListener("textureReady",onTextureReady);
			super.dispose();
		}
		
		override protected function createBase() : TextureBase {
			return Starling.context.createTexture(nativeWidth,nativeHeight,format,optimizedForRenderTexture);
		}
		
		override public function uploadBitmapData(data:BitmapData) : void {
			var _local3:* = 0;
			var _local6:* = 0;
			var _local4:int = 0;
			var _local2:BitmapData = null;
			var _local5:Rectangle = null;
			var _local8:Matrix = null;
			potBase.uploadFromBitmapData(data);
			var _local7:BitmapData = null;
			if(data.width != nativeWidth || data.height != nativeHeight) {
				_local7 = new BitmapData(nativeWidth,nativeHeight,true,0);
				_local7.copyPixels(data,data.rect,sOrigin);
				data = _local7;
			}
			if(mipMapping && data.width > 1 && data.height > 1) {
				_local3 = data.width >> 1;
				_local6 = data.height >> 1;
				_local4 = 1;
				_local2 = new BitmapData(_local3,_local6,true,0);
				_local5 = sRectangle;
				_local8 = sMatrix;
				_local8.setTo(0.5,0,0,0.5,0,0);
				while(_local3 >= 1 || _local6 >= 1) {
					_local5.setTo(0,0,_local3,_local6);
					_local2.fillRect(_local5,0);
					_local2.draw(data,_local8,null,null,null,true);
					potBase.uploadFromBitmapData(_local2,_local4++);
					_local8.scale(0.5,0.5);
					_local3 >>= 1;
					_local6 >>= 1;
				}
				_local2.dispose();
			}
			if(_local7) {
				_local7.dispose();
			}
			setDataUploaded();
		}
		
		override public function get isPotTexture() : Boolean {
			return true;
		}
		
		override public function uploadAtfData(data:ByteArray, offset:int = 0, async:* = null) : void {
			var _local4:Boolean = async is Function || async === true;
			if(async is Function) {
				_textureReadyCallback = async as Function;
				base.addEventListener("textureReady",onTextureReady);
			}
			potBase.uploadCompressedTextureFromByteArray(data,offset,_local4);
			setDataUploaded();
		}
		
		private function onTextureReady(event:Event) : void {
			base.removeEventListener("textureReady",onTextureReady);
			execute(_textureReadyCallback,this);
			_textureReadyCallback = null;
		}
		
		private function get potBase() : flash.display3D.textures.Texture {
			return base as flash.display3D.textures.Texture;
		}
	}
}

