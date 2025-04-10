package core.hud.components.map {
	import core.hud.components.pvp.DominationZone;
	import core.scene.Game;
	import starling.display.Image;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class MapPvpZone extends Sprite {
		private var g:Game;
		private var dz:DominationZone;
		private var img:Image;
		private var currentOwner:int;
		private var zone:Image;
		private var lastBlink:Number = 0;
		
		public function MapPvpZone(g:Game, dz:DominationZone) {
			super();
			this.g = g;
			this.dz = dz;
			var _local3:ITextureManager = TextureLocator.getService();
			var _local4:Image = new Image(_local3.getTextureByTextureName("piratebay","texture_body.png"));
			_local4.scaleX = 0.1;
			_local4.scaleY = 0.1;
			_local4.x = -_local4.width * 0.5;
			_local4.y = -_local4.height * 0.5;
			_local4.alpha = 1;
			addChild(_local4);
			zone = dz.getMiniZone();
			zone.x = 0;
			zone.y = 0;
			currentOwner = -1;
			zone.color = 0xffffff;
			addChild(zone);
		}
		
		public function update() : void {
			if(dz.ownerTeam != currentOwner) {
				currentOwner = dz.ownerTeam.valueOf();
				if(currentOwner == -1) {
					zone.color = 0xffffff;
					zone.visible = true;
				} else if(currentOwner == g.me.team) {
					zone.color = 255;
					zone.visible = true;
				} else {
					zone.color = 0xff0000;
					zone.visible = true;
				}
			}
			if(dz.status == 1) {
				if(g.time - lastBlink > 500) {
					zone.color = 0xff0000;
					zone.visible = !zone.visible;
					trace("blink1: " + zone.visible);
					lastBlink = g.time;
				}
			} else if(dz.status == 2) {
				if(g.time - lastBlink > 500) {
					zone.color = 255;
					zone.visible = !zone.visible;
					trace("blink2: " + zone.visible);
					lastBlink = g.time;
				}
			}
		}
	}
}

