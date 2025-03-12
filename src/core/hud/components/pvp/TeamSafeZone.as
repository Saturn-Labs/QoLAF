package core.hud.components.pvp
{
	import core.player.Player;
	import core.scene.Game;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class TeamSafeZone
	{
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
		
		public function TeamSafeZone(param1:Game, param2:Object, param3:int)
		{
			super();
			textureManager = TextureLocator.getService();
			this.g = param1;
			this.team = param3;
			this.x = param2.x;
			this.y = param2.y;
			friendlyZone = createZoneImg(param2, friendlyColor, "tsf_friendly");
			enemyZone = createZoneImg(param2, enemyColor, "tsf_enemy");
			img = new Image(textureManager.getTextureByTextureName("warpGate", "texture_body.png"));
			img.x = friendlyZone.x - img.width / 2;
			img.y = friendlyZone.y - img.height / 2 + 8;
			img.alpha = 1;
			enemyZone.alpha = 1;
			this.g.addChildToCanvasAt(enemyZone, 7);
			friendlyZone.alpha = 0;
			this.g.addChildToCanvasAt(friendlyZone, 8);
			this.g.addChildToCanvasAt(img, 9);
		}
		
		public function updateZone():void
		{
			var _loc1_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc4_:Number = NaN;
			if (g.me.team == team)
			{
				friendlyZone.alpha = 1;
				enemyZone.alpha = 0;
			}
			else
			{
				friendlyZone.alpha = 0;
				enemyZone.alpha = 1;
			}
			for each (var _loc3_:* in g.playerManager.players)
			{
				if (_loc3_.ship != null && _loc3_.team > -1 && _loc3_.team == team)
				{
					_loc1_ = _loc3_.ship.pos.x - x;
					_loc2_ = _loc3_.ship.pos.y - y;
					_loc4_ = _loc1_ * _loc1_ + _loc2_ * _loc2_;
					if (_loc4_ < zoneRadius * zoneRadius)
					{
						_loc3_.inSafeZone = true;
					}
				}
			}
		}
		
		private function createZoneImg(param1:Object, param2:uint, param3:String):Image
		{
			var _loc10_:Image = null;
			var _loc7_:Sprite = new Sprite();
			_loc7_.graphics.lineStyle(1, param2, 0.2);
			var _loc9_:String = "radial";
			var _loc5_:Array = [0, param2];
			var _loc6_:Array = [0, 0.4];
			var _loc8_:Array = [0, 255];
			var _loc4_:Matrix = new Matrix();
			_loc4_.createGradientBox(2 * zoneRadius, 2 * zoneRadius, 0, -zoneRadius, -zoneRadius);
			_loc7_.graphics.beginGradientFill(_loc9_, _loc5_, _loc6_, _loc8_, _loc4_);
			_loc7_.graphics.drawCircle(0, 0, zoneRadius);
			_loc7_.graphics.endFill();
			_loc10_ = TextureManager.imageFromSprite(_loc7_, param3);
			_loc10_.x = x;
			_loc10_.y = y;
			_loc10_.pivotX = _loc10_.width / 2;
			_loc10_.pivotY = _loc10_.height / 2;
			_loc10_.scaleX = 1;
			_loc10_.scaleY = 1;
			_loc10_.alpha = 0.25;
			_loc10_.blendMode = "add";
			return _loc10_;
		}
	}
}
