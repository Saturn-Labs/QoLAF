package starling.textures {
	import flash.display.BitmapData;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.TextureBase;
	import starling.core.Starling;
	
	internal class ConcreteRectangleTexture extends ConcreteTexture {
		public function ConcreteRectangleTexture(base:RectangleTexture, format:String, width:int, height:int, premultipliedAlpha:Boolean, optimizedForRenderTexture:Boolean = false, scale:Number = 1) {
			super(base,format,width,height,false,premultipliedAlpha,optimizedForRenderTexture,scale);
		}
		
		override public function uploadBitmapData(data:BitmapData) : void {
			rectangleBase.uploadFromBitmapData(data);
			setDataUploaded();
		}
		
		override protected function createBase() : TextureBase {
			return Starling.context.createRectangleTexture(nativeWidth,nativeHeight,format,optimizedForRenderTexture);
		}
		
		private function get rectangleBase() : RectangleTexture {
			return base as RectangleTexture;
		}
	}
}

