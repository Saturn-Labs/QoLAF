package core.hud.components.map {
	import core.deathLine.DeathLine;
	import core.hud.components.Line;
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class MapDeathLine {
		private var line:Line;
		
		private var scale:Number = 0.4;
		
		private var g:Game;
		
		public function MapDeathLine(g:Game, container:Sprite, deathLine:DeathLine, color:uint) {
			super();
			this.g = g;
			this.line = g.linePool.getLine();
			this.line.init("line1",3,color);
			this.line.x = deathLine.x;
			this.line.y = deathLine.y;
			this.line.x = deathLine.x * Map.SCALE;
			this.line.y = deathLine.y * Map.SCALE;
			this.line.lineTo(deathLine.toX * Map.SCALE,deathLine.toY * Map.SCALE);
			container.addChild(this.line);
		}
		
		public function update() : void {
		}
		
		public function dispose() : void {
			if(g.linePool != null) {
				g.linePool.removeLine(line);
			}
		}
	}
}

