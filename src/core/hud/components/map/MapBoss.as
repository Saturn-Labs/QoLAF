package core.hud.components.map
{
	import core.boss.Boss;
	import flash.display.Bitmap;
	import starling.display.Image;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import embeds.qolaf.minimap.bosses.TefatBitmap;
	import starling.textures.Texture;
	import starling.display.Sprite;
	import starling.display.Quad;
	
	public class MapBoss
	{
		private var boss:Boss;
		private var scale:Number = 0.4;
		private var bossImage:Image;
		private var pivotMarker:Quad;
		private var hasIcon:Boolean;
		
		public function MapBoss(parent:Sprite, boss:Boss)
		{
			super();
			this.boss = boss;
			var textureManager:ITextureManager = TextureLocator.getService();
			bossImage = new Image(textureManager.getTextureByTextureName(boss.name.toLowerCase() + "_mini", "texture_main_NEW.png"));
			bossImage.width = bossImage.width / 1.8;
			bossImage.height = bossImage.height / 1.8;
			hasIcon = true;
			bossImage.alignPivot();
			parent.addChild(bossImage);
			parent.setChildIndex(bossImage, parent.numChildren - 1);
		}
		
		public function update():void
		{
			bossImage.visible = boss.alive;
			if (hasIcon) {
				bossImage.rotation = boss.rotation;
			}
			bossImage.x = boss.pos.x * Map.SCALE;
			bossImage.y = boss.pos.y * Map.SCALE;
		}
	}
}
