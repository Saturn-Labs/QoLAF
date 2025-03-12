package core.hud.components.map
{
	import core.boss.Boss;
	import starling.display.Image;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class MapBoss
	{
		private var boss:Boss;
		
		private var scale:Number = 0.4;
		private var layer:Sprite;
		
		private var scull:Image;
		
		public function MapBoss(param1:Sprite, param2:Boss)
		{
			layer = new Sprite();
			super();
			this.boss = param2;
			param1.addChild(layer);
			layer.touchable = false;
			var _loc3_:ITextureManager = TextureLocator.getService();
			scull = new Image(_loc3_.getTextureGUIByTextureName("radar_boss.png"));
			scull.color = 16729156;
			layer.addChild(scull);
		}
		
		public function update():void
		{
			scull.visible = boss.alive;
			layer.x = boss.pos.x * Map.SCALE - layer.width / 2;
			layer.y = boss.pos.y * Map.SCALE - layer.height / 2;
		}
	}
}
