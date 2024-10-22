package core.hud.components.map
{
	import core.boss.Boss;
	import flash.display.Bitmap;
	import starling.display.Image;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import starling.textures.Texture;
	import starling.display.Sprite;
	import starling.display.Quad;
	import starling.textures.TextureSmoothing;
	import starling.filters.GlowFilter;
	import starling.events.Event;
	
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
			bossImage = new Image(textureManager.getTextureByTextureName(boss.name.toLowerCase().replace(" ", "_") + "_mini", "texture_main_NEW.png"));
			bossImage.scale = 0.75;
			bossImage.textureSmoothing = TextureSmoothing.TRILINEAR;
			hasIcon = true;
			bossImage.alignPivot();
			bossImage.addEventListener(Event.ADDED_TO_STAGE, iconAddedToStage);
			parent.addChild(bossImage);
			parent.setChildIndex(bossImage, parent.numChildren - 1);
		}
		
		private function iconAddedToStage(event: Event): void {
			bossImage.removeEventListener(Event.ADDED_TO_STAGE, iconAddedToStage);
			var glowFilter:GlowFilter = new GlowFilter();
			glowFilter.color = 0xFF0000;
			glowFilter.alpha = 1;
			glowFilter.blur = 5;

			bossImage.filter = glowFilter;
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
