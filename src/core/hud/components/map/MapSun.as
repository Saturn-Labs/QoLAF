package core.hud.components.map
{
	import core.scene.Game;
	import core.solarSystem.Body;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	public class MapSun extends MapBodyBase
	{
		public function MapSun(param1:Game, param2:Sprite, param3:Body)
		{
			super(param1, param2, param3);
			layer.touchable = false;
			addImage();
			addOrbits();
			init();
		}
		
		private function addImage():void
		{
			layer.touchable = false;
			var _loc1_:Texture = textureManager.getTextureGUIByTextureName("map_sun.png");
			radius = _loc1_.width / 2;
			var _loc2_:Image = new Image(_loc1_);
			if (body.name == "Black Hole")
			{
				_loc2_.color = 6684927;
			}
			layer.addChild(_loc2_);
		}
	}
}
