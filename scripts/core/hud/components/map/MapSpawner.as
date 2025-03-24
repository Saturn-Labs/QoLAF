package core.hud.components.map {
	import core.hud.components.Style;
	import core.spawner.Spawner;
	import starling.display.Image;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class MapSpawner {
		private var spawner:Spawner;
		
		private var scale:Number = 0.4;
		
		private var layer:Image;
		
		public function MapSpawner(container:Sprite, spawner:Spawner) {
			super();
			this.spawner = spawner;
			var _local3:ITextureManager = TextureLocator.getService();
			layer = new Image(_local3.getTextureGUIByTextureName("map_spawner.png"));
			if(spawner.hasFaction("AF")) {
				layer.color = Style.COLOR_FRIENDLY;
			} else {
				layer.color = 13124676;
			}
			layer.touchable = false;
			container.addChild(layer);
		}
		
		public function update() : void {
			layer.visible = spawner.alive;
			layer.x = spawner.pos.x * Map.SCALE - layer.width / 2;
			layer.y = spawner.pos.y * Map.SCALE - layer.height / 2;
		}
	}
}

