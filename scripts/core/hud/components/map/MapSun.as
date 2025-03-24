package core.hud.components.map {
	import core.scene.Game;
	import core.solarSystem.Body;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class MapSun extends MapBodyBase {
		public function MapSun(g:Game, container:Sprite, body:Body) {
			super(g,container,body);
			layer.touchable = false;
			addImage();
			addOrbits();
			init();
		}
		
		private function addImage() : void {
			layer.touchable = false;
			var _local2:Texture = textureManager.getTextureGUIByTextureName("map_sun.png");
			radius = _local2.width / 2;
			var _local1:Image = new Image(_local2);
			if(body.name == "Black Hole") {
				_local1.color = 0x6600ff;
			}
			layer.addChild(_local1);
		}
	}
}

