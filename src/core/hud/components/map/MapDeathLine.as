package core.hud.components.map
{
	import core.deathLine.DeathLine;
	import core.hud.components.Line;
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class MapDeathLine
	{
		private var line:Line;
		
		private var scale:Number = 0.4;
		private var g:Game;
		
		public function MapDeathLine(param1:Game, param2:Sprite, param3:DeathLine, param4:uint)
		{
			super();
			this.g = param1;
			this.line = param1.linePool.getLine();
			this.line.init("line1", 3, param4);
			this.line.x = param3.x;
			this.line.y = param3.y;
			this.line.x = param3.x * Map.SCALE;
			this.line.y = param3.y * Map.SCALE;
			this.line.lineTo(param3.toX * Map.SCALE, param3.toY * Map.SCALE);
			param2.addChild(this.line);
		}
		
		public function update():void
		{
		}
		
		public function dispose():void
		{
			if (g.linePool != null)
			{
				g.linePool.removeLine(line);
			}
		}
	}
}
