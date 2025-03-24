package core.hud.components.pvp {
	import core.player.Player;
	import core.scene.Game;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class TeamSafeZone {
		private var textureManager:ITextureManager;
		
		public var zoneRadius:Number = 350;
		
		public var team:int = -1;
		
		private var g:Game;
		
		private var friendlyZone:Image;
		
		private var enemyZone:Image;
		
		private var img:Image;
		
		public var friendlyColor:uint = 255;
		
		public var enemyColor:uint = 16711680;
		
		public var x:int;
		
		public var y:int;
		
		public function TeamSafeZone(g:Game, obj:Object, team:int) {
			super();
			textureManager = TextureLocator.getService();
			this.g = g;
			this.team = team;
			this.x = obj.x;
			this.y = obj.y;
			friendlyZone = createZoneImg(obj,friendlyColor,"tsf_friendly");
			enemyZone = createZoneImg(obj,enemyColor,"tsf_enemy");
			img = new Image(textureManager.getTextureByTextureName("warpGate","texture_body.png"));
			img.x = friendlyZone.x - img.width / 2;
			img.y = friendlyZone.y - img.height / 2 + 8;
			img.alpha = 1;
			enemyZone.alpha = 1;
			this.g.addChildToCanvasAt(enemyZone,7);
			friendlyZone.alpha = 0;
			this.g.addChildToCanvasAt(friendlyZone,8);
			this.g.addChildToCanvasAt(img,9);
		}
		
		public function updateZone() : void {
			var _local2:Number = NaN;
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			if(g.me.team == team) {
				friendlyZone.alpha = 1;
				enemyZone.alpha = 0;
			} else {
				friendlyZone.alpha = 0;
				enemyZone.alpha = 1;
			}
			for each(var _local1 in g.playerManager.players) {
				if(_local1.ship != null && _local1.team > -1 && _local1.team == team) {
					_local2 = _local1.ship.pos.x - x;
					_local3 = _local1.ship.pos.y - y;
					_local4 = _local2 * _local2 + _local3 * _local3;
					if(_local4 < zoneRadius * zoneRadius) {
						_local1.inSafeZone = true;
					}
				}
			}
		}
		
		private function createZoneImg(obj:Object, colour:uint, name:String) : Image {
			var _local6:Image = null;
			var _local5:Sprite = new Sprite();
			_local5.graphics.lineStyle(1,colour,0.2);
			var _local7:String = "radial";
			var _local10:Array = [0,colour];
			var _local8:Array = [0,0.4];
			var _local9:Array = [0,255];
			var _local4:Matrix = new Matrix();
			_local4.createGradientBox(2 * zoneRadius,2 * zoneRadius,0,-zoneRadius,-zoneRadius);
			_local5.graphics.beginGradientFill(_local7,_local10,_local8,_local9,_local4);
			_local5.graphics.drawCircle(0,0,zoneRadius);
			_local5.graphics.endFill();
			_local6 = TextureManager.imageFromSprite(_local5,name);
			_local6.x = x;
			_local6.y = y;
			_local6.pivotX = _local6.width / 2;
			_local6.pivotY = _local6.height / 2;
			_local6.scaleX = 1;
			_local6.scaleY = 1;
			_local6.alpha = 0.25;
			_local6.blendMode = "add";
			return _local6;
		}
	}
}

