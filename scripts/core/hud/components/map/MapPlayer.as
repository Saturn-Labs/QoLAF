package core.hud.components.map {
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import core.hud.components.Style;
	import core.hud.components.TextBitmap;
	import core.player.FleetObj;
	import core.player.Player;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.ship.ShipFactory;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.TextureLocator;
	
	public class MapPlayer {
		private var player:Player;
		
		private var scale:Number = 0.35;
		
		private var layer:Image;
		
		private var text:TextBitmap;
		
		private var g:Game;
		
		private var supporterImage:Image;
		
		private var lastTeam:int;
		
		private var isDomination:Boolean;
		
		public function MapPlayer(container:Sprite, player:Player, g:Game, isDomination:Boolean) {
			var ship:PlayerShip;
			var fleetObj:FleetObj;
			var engineHue:Number;
			super();
			this.g = g;
			this.isDomination = isDomination;
			this.lastTeam = player.team;
			ship = player.ship;
			if(player.ship != null) {
				fleetObj = player.getActiveFleetObj();
				layer = new Image(player.ship.texture);
				layer.rotation = ship.rotation;
				layer.pivotX = ship.texture.width * 0.5 * ship.movieClip.scaleX;
				layer.pivotY = ship.texture.height * 0.5 * ship.movieClip.scaleY;
				layer.scaleX = scale;
				layer.scaleY = scale;
				engineHue = !!fleetObj.engineHue ? fleetObj.engineHue : 0;
				layer.filter = ShipFactory.createPlayerShipColorMatrixFilter(fleetObj);
			} else {
				layer = new Image(Texture.empty(1,1));
			}
			layer.touchable = false;
			if(player.hasSupporter()) {
				supporterImage = new Image(TextureLocator.getService().getTextureGUIByTextureName("icon_supporter.png"));
				supporterImage.scaleX = supporterImage.scaleY = 0.5;
				container.addChild(supporterImage);
			}
			text = new TextBitmap();
			text.size = 10;
			text.batchable = true;
			if(player.isMe) {
				text.format.color = 0xffffff;
				text.visible = false;
				if(supporterImage != null) {
					supporterImage.visible = false;
				}
				TweenMax.to(layer,0.5,{
					"startAt":{
						"scaleX":1.5,
						"scaleY":1.5
					},
					"scaleX":scale,
					"scaleY":scale,
					"ease":Circ.easeIn,
					"onComplete":function():void {
						text.visible = true;
						if(supporterImage != null) {
							supporterImage.visible = true;
						}
					}
				});
			} else if(isDomination == false && player.group != null && g.me.group != null && player.group.id == g.me.group.id) {
				text.format.color = Style.COLOR_GROUP;
			} else if(player.isHostile && (player.team == -1 || player.team != g.me.team)) {
				text.format.color = Style.COLOR_HOSTILE;
			} else {
				text.format.color = Style.COLOR_FRIENDLY;
			}
			text.text = player.name;
			text.touchable = false;
			container.addChild(layer);
			container.addChild(text);
			this.player = player;
		}
		
		public function get isMe() : Boolean {
			if(player != null) {
				return player.isMe;
			}
			return false;
		}
		
		public function update() : void {
			if(player == null || player.ship == null || player.ship.landed || player.ship.hp <= 0) {
				layer.visible = false;
				text.visible = false;
				return;
			}
			if(!layer.visible) {
				layer.visible = true;
				text.visible = true;
			}
			draw();
		}
		
		private function draw() : void {
			layer.visible = true;
			layer.x = player.ship.x * Map.SCALE;
			layer.y = player.ship.y * Map.SCALE;
			layer.rotation = player.ship.rotation;
			text.x = layer.x - text.width / 2;
			text.y = layer.y + layer.pivotY * layer.scaleY - layer.pivotY / 5 + 5;
			if(isDomination == true && lastTeam != player.team) {
				if(player.isHostile && player.team != g.me.team) {
					text.format.color = Style.COLOR_HOSTILE;
				} else {
					text.format.color = Style.COLOR_FRIENDLY;
				}
				lastTeam = player.team;
			}
			if(supporterImage != null) {
				supporterImage.x = text.x - 5;
				supporterImage.y = text.y + 3;
			}
		}
		
		public function get width() : Number {
			return layer.width * scale;
		}
		
		public function get height() : Number {
			return layer.height * scale;
		}
		
		public function get x() : Number {
			return layer.x;
		}
		
		public function get y() : Number {
			return layer.y;
		}
		
		public function dispose() : void {
			if(layer && layer.filter) {
				layer.filter.dispose();
				layer.filter = null;
			}
		}
	}
}

