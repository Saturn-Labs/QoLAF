package core.hud.components.map
{
	import core.hud.components.pvp.DominationZone;
	import core.scene.Game;
	import starling.display.Image;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;

	public class MapPvpZone extends Sprite
	{
		private var g:Game;
		private var dz:DominationZone;
		private var img:Image;
		private var currentOwner:int;
		private var zone:Image;
		private var lastBlink:Number = 0;
		public function MapPvpZone(param1:Game, param2:DominationZone)
		{
			super();
			this.g = param1;
			this.dz = param2;
			var _loc3_:ITextureManager = TextureLocator.getService();
			var _loc4_:Image = new Image(_loc3_.getTextureByTextureName("piratebay", "texture_body.png"));
			_loc4_.scaleX = 0.1;
			_loc4_.scaleY = 0.1;
			_loc4_.x = -_loc4_.width * 0.5;
			_loc4_.y = -_loc4_.height * 0.5;
			_loc4_.alpha = 1;
			addChild(_loc4_);
			zone = param2.getMiniZone();
			zone.x = 0;
			zone.y = 0;
			currentOwner = -1;
			zone.color = 16777215;
			addChild(zone);
		}

		public function update():void
		{
			if (dz.ownerTeam != currentOwner)
			{
				currentOwner = dz.ownerTeam.valueOf();
				if (currentOwner == -1)
				{
					zone.color = 16777215;
					zone.visible = true;
				}
				else if (currentOwner == g.me.team)
				{
					zone.color = 255;
					zone.visible = true;
				}
				else
				{
					zone.color = 16711680;
					zone.visible = true;
				}
			}
			if (dz.status == 1)
			{
				if (g.time - lastBlink > 500)
				{
					zone.color = 16711680;
					zone.visible = !zone.visible;
					trace("blink1: " + zone.visible);
					lastBlink = g.time;
				}
			}
			else if (dz.status == 2)
			{
				if (g.time - lastBlink > 500)
				{
					zone.color = 255;
					zone.visible = !zone.visible;
					trace("blink2: " + zone.visible);
					lastBlink = g.time;
				}
			}
		}
	}
}
