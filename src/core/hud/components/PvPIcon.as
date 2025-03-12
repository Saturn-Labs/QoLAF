package core.hud.components
{
	import core.scene.Game;
	import generics.Localize;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class PvPIcon extends DisplayObjectContainer
	{
		private var g:Game;
		
		public function PvPIcon(param1:Game)
		{
			super();
			this.g = param1;
		}
		
		public function load():void
		{
			if (!g.isSystemPvPEnabled())
			{
				return;
			}
			var _loc1_:ITextureManager = TextureLocator.getService();
			addChild(new Image(_loc1_.getTextureGUIByTextureName("pvp")));
			new ToolTip(g, this, "<FONT COLOR='#44FF44'>" + Localize.t("PvP enabled for all players.") + "</FONT>");
		}
	}
}
