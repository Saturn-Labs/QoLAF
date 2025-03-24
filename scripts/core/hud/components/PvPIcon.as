package core.hud.components {
	import core.scene.Game;
	import generics.Localize;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class PvPIcon extends DisplayObjectContainer {
		private var g:Game;
		
		public function PvPIcon(g:Game) {
			super();
			this.g = g;
		}
		
		public function load() : void {
			if(!g.isSystemPvPEnabled()) {
				return;
			}
			var _local1:ITextureManager = TextureLocator.getService();
			addChild(new Image(_local1.getTextureGUIByTextureName("pvp")));
			new ToolTip(g,this,"<FONT COLOR=\'#44FF44\'>" + Localize.t("PvP enabled for all players.") + "</FONT>");
		}
	}
}

