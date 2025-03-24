package core.hud.components.map {
	import core.hud.components.TextBitmap;
	import core.scene.Game;
	import core.solarSystem.Body;
	import flash.display.Sprite;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.TextureManager;
	
	public class MapEliteArea extends MapBodyBase {
		public function MapEliteArea(g:Game, container:starling.display.Sprite, body:Body) {
			super(g,container,body);
			addImage();
			addOrbits();
			addText();
			layer.touchable = false;
			init();
		}
		
		private function addImage() : void {
			var _local2:Texture = textureManager.getTextureGUIByTextureName("warning.png");
			var _local1:Image = new Image(_local2);
			_local1.x = -_local1.width / 2 - 26;
			_local1.y = 15 + body.labelOffset;
			layer.addChild(_local1);
		}
		
		override protected function addOrbits() : void {
			var _local2:flash.display.Sprite = new flash.display.Sprite();
			_local2.graphics.beginFill(15636992,0.1);
			_local2.graphics.lineStyle(2,15636992,0.3);
			_local2.graphics.drawCircle(2,2,body.warningRadius * Map.SCALE);
			_local2.graphics.endFill();
			var _local1:Image = TextureManager.imageFromSprite(_local2,body.key);
			layer.addChild(_local1);
		}
		
		private function addText() : void {
			var _local1:TextBitmap = new TextBitmap();
			_local1.text = body.name == "Warning" ? "Elite Zone" : body.name;
			_local1.x = -_local1.width / 2 + 20;
			_local1.y = 15 + body.labelOffset;
			_local1.format.color = 15636992;
			_local1.touchable = false;
			layer.addChild(_local1);
		}
	}
}

