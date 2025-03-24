package core.hud.components.map {
	import core.scene.Game;
	import core.solarSystem.Body;
	import starling.display.Image;
	import starling.display.Sprite;
	
	public class MapStation extends MapBodyBase {
		public function MapStation(g:Game, container:Sprite, body:Body) {
			super(g,container,body);
			layer.useHandCursor = true;
			container.addChild(text);
			addImage();
			addText();
			init();
		}
		
		private function addImage() : void {
			var _local2:String = body.type.toLowerCase().replace(" ","");
			var _local1:Image = new Image(textureManager.getTextureGUIByTextureName("map_" + _local2));
			_local1.color = body.typeColor;
			imgSelected = new Image(textureManager.getTextureGUIByTextureName("map_" + _local2 + "_selected"));
			imgSelected.color = body.selectedTypeColor;
			imgHover = new Image(textureManager.getTextureGUIByTextureName("map_" + _local2 + "_hover"));
			imgHover.color = body.selectedTypeColor;
			radius = _local1.width / 2;
			layer.addChild(_local1);
		}
		
		private function addText() : void {
			text.size = 11;
			text.format.color = body.color;
			text.text = body.name;
		}
	}
}

