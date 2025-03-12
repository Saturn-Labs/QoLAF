package core.text
{
	import core.scene.Game;
	import flash.geom.Point;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class TextParticle extends TextField
	{
		public var id:int;
		
		public var alive:Boolean;
		
		public var ttl:int;
		
		public var maxTtl:int;
		
		public var speed:Point;
		
		public var fixed:Boolean;
		
		private var g:Game;
		
		public function TextParticle(param1:int, param2:Game)
		{
			this.g = param2;
			this.id = param1;
			super(800, 16, "", new TextFormat("font13", 13, 16777215));
			autoScale = true;
			batchable = true;
			alive = false;
			ttl = 0;
			speed = new Point();
			blendMode = "add";
		}
		
		public function update():void
		{
			ttl -= 33;
			if (ttl < 0)
			{
				alive = false;
				alpha = 0;
			}
		}
		
		public function reset():void
		{
			alpha = 1;
			text = "reset";
			speed.x = 0;
			speed.y = 0;
			ttl = 0;
			alive = false;
			autoWidth();
		}
		
		override public function set text(param1:String):void
		{
			if (super.text == param1)
			{
				return;
			}
			width = 800;
			super.text = param1;
			autoWidth();
		}
		
		public function autoWidth():void
		{
			this.width = this.textBounds.width + 4;
		}
	}
}
