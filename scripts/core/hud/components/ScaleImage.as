package core.hud.components {
	import flash.geom.Rectangle;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ScaleImage extends Image {
		public function ScaleImage() {
			var _local1:ITextureManager = TextureLocator.getService();
			super(_local1.getTextureGUIByTextureName("scale_image"));
			scale9Grid = new Rectangle(1,1,8,8);
		}
	}
}

