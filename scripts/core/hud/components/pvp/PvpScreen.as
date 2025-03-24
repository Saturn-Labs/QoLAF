package core.hud.components.pvp {
	import core.hud.components.ButtonExpandableHud;
	import core.scene.Game;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class PvpScreen extends Sprite {
		public static var WIDTH:Number = 698;
		
		public static var HEIGHT:Number = 538;
		
		private var bgr:Image;
		
		private var closeButton:ButtonExpandableHud;
		
		public var g:Game;
		
		public function PvpScreen(g:Game) {
			super();
			this.g = g;
		}
		
		public function load() : void {
			var textureManager:ITextureManager = TextureLocator.getService();
			bgr = new Image(textureManager.getTextureGUIByTextureName("map_bgr.png"));
			addChild(bgr);
			closeButton = new ButtonExpandableHud(function():void {
				dispatchEvent(new Event("close"));
			},"close");
			closeButton.x = 760 - 46 - closeButton.width;
			closeButton.y = 0;
			addChild(closeButton);
		}
		
		public function unload() : void {
		}
		
		public function update() : void {
		}
	}
}

