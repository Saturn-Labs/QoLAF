package core.hud.components.credits {
	import core.hud.components.Text;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CreditLabel extends Text {
		private var fluxIcon:Image;
		
		public function CreditLabel() {
			super();
			var _local1:ITextureManager = TextureLocator.getService();
			fluxIcon = new Image(_local1.getTextureGUIByTextureName("credit_small.png"));
			fluxIcon.visible = false;
			addChild(fluxIcon);
		}
		
		override public function set text(value:String) : void {
			super.text = value;
			if(fluxIcon) {
				fluxIcon.visible = true;
				fluxIcon.x = this.width + 5;
			}
			draw();
		}
		
		override protected function draw() : void {
			super.draw();
			if(_hAlign == H_ALIGN_RIGHT && finalLayer != null) {
				fluxIcon.x = finalLayer.x + finalLayer.width + 5;
			}
		}
	}
}

