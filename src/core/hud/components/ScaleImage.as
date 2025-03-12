package core.hud.components
{
	import flash.geom.Rectangle;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ScaleImage extends Image
	{
		public function ScaleImage()
		{
			var _loc1_:ITextureManager = TextureLocator.getService();
			super(_loc1_.getTextureGUIByTextureName("scale_image"));
			scale9Grid = new Rectangle(1, 1, 8, 8);
		}
	}
}
