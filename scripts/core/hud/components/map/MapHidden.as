package core.hud.components.map {
	import core.scene.Game;
	import core.solarSystem.Body;
	import starling.display.Sprite;
	
	public class MapHidden extends MapBodyBase {
		public function MapHidden(g:Game, container:Sprite, body:Body) {
			super(g,container,body);
			addOrbits();
		}
	}
}

