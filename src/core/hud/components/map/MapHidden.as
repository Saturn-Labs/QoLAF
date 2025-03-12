package core.hud.components.map
{
	import core.scene.Game;
	import core.solarSystem.Body;
	import starling.display.Sprite;
	
	public class MapHidden extends MapBodyBase
	{
		public function MapHidden(param1:Game, param2:Sprite, param3:Body)
		{
			super(param1, param2, param3);
			addOrbits();
		}
	}
}
