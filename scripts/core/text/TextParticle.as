package core.text {
	import core.scene.Game;
	import flash.geom.Point;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class TextParticle extends TextField {
		public var id:int;
		
		public var alive:Boolean;
		
		public var ttl:int;
		
		public var maxTtl:int;
		
		public var speed:Point;
		
		public var fixed:Boolean;
		
		private var g:Game;
		
		public function TextParticle(id:int, g:Game) {
			this.g = g;
			this.id = id;
			super(800,16,"",new TextFormat("font13",13,0xffffff));
			autoScale = true;
			batchable = true;
			alive = false;
			ttl = 0;
			speed = new Point();
			blendMode = "add";
		}
		
		public function update() : void {
			ttl -= 33;
			if(ttl < 0) {
				alive = false;
				alpha = 0;
			}
		}
		
		public function reset() : void {
			alpha = 1;
			text = "reset";
			speed.x = 0;
			speed.y = 0;
			ttl = 0;
			alive = false;
			autoWidth();
		}
		
		override public function set text(value:String) : void {
			if(super.text == value) {
				return;
			}
			width = 800;
			super.text = value;
			autoWidth();
		}
		
		public function autoWidth() : void {
			this.width = this.textBounds.width + 4;
		}
	}
}

