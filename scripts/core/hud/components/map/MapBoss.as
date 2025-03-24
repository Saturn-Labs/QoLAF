package core.hud.components.map {
	import core.boss.Boss;
	import starling.display.Image;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class MapBoss {
		private var boss:Boss;
		
		private var scale:Number = 0.4;
		
		private var layer:Sprite = new Sprite();
		
		private var scull:Image;
		
		public function MapBoss(container:Sprite, boss:Boss) {
			super();
			this.boss = boss;
			container.addChild(layer);
			layer.touchable = false;
			var _local3:ITextureManager = TextureLocator.getService();
			scull = new Image(_local3.getTextureGUIByTextureName("radar_boss.png"));
			scull.color = 0xff4444;
			layer.addChild(scull);
		}
		
		public function update() : void {
			scull.visible = boss.alive;
			layer.x = boss.pos.x * Map.SCALE - layer.width / 2;
			layer.y = boss.pos.y * Map.SCALE - layer.height / 2;
		}
	}
}

