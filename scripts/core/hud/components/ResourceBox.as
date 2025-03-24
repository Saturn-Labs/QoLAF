package core.hud.components {
	import core.hud.components.cargo.CargoItem;
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class ResourceBox extends Sprite {
		private var g:Game;
		
		public function ResourceBox(g:Game) {
			super();
			this.g = g;
		}
		
		public function update() : void {
			var _local2:int = 0;
			removeChildren();
			for each(var _local1 in g.myCargo.minerals) {
				_local1.draw("hud");
				_local1.x = _local2 * 78;
				_local1.y = 1;
				addChild(_local1);
				_local2++;
			}
		}
	}
}

