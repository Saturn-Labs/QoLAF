package core.hud.components.pvp
{
	import com.greensock.TweenMax;
	import core.scene.Game;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;

	public class DominationZone
	{
		private var textureManager:ITextureManager;
		public var zoneRadius:Number = 250;
		public var id:int;
		public var name:String = "";
		public var ownerTeam:int;
		public var capCounter:int;
		public var nrTeam:Vector.<int>;

		private var g:Game;
		private var friendlyZone:Image;
		private var neutralZone:Image;
		private var enemyZone:Image;
		private var img:Image;
		public var friendlyColor:uint = 255;
		public var neutralColor:uint = 16777215;
		public var enemyColor:uint = 16711680;
		public var x:int;
		public var y:int;
		private var oldCapCounter:int = 0;
		public var status:int = 0;
		public const STATUS_IDLE:int = 0;

		public const STATUS_MY_TEAM_ASSAULTING:int = 1;

		public const STATUS_OPPONENT_TEAM_ASSAULTING:int = 2;

		public function DominationZone(param1:Game, param2:Object, param3:int)
		{
			nrTeam = new Vector.<int>();
			super();
			textureManager = TextureLocator.getService();
			this.g = param1;
			this.id = param3;
			nrTeam.push(0);
			nrTeam.push(0);
			this.x = param2.x;
			this.y = param2.y;
			friendlyZone = createZoneImg(param2, friendlyColor, "friendly");
			neutralZone = createZoneImg(param2, neutralColor, "neutral");
			enemyZone = createZoneImg(param2, enemyColor, "enemy");
			img = new Image(textureManager.getTextureByTextureName("piratebay", "texture_body.png"));
			img.x = neutralZone.x - img.width / 2;
			img.y = neutralZone.y - img.height / 2 + 8;
			img.alpha = 1;
			this.g.addChildToCanvasAt(img, 6);
			neutralZone.alpha = 0.25;
			this.g.addChildToCanvasAt(neutralZone, 7);
			friendlyZone.alpha = 1;
			friendlyZone.scaleX = 0;
			friendlyZone.scaleY = 0;
			this.g.addChildToCanvasAt(friendlyZone, 8);
			enemyZone.alpha = 1;
			enemyZone.scaleX = 0;
			enemyZone.scaleY = 0;
			this.g.addChildToCanvasAt(enemyZone, 9);
			if (param3 == 3)
			{
				name = "Alpha Station";
			}
			else if (param3 == 1)
			{
				name = "Beta Station";
			}
			else if (param3 == 2)
			{
				name = "Gamma Station";
			}
			else if (param3 == 3)
			{
				name = "Delta Station";
			}
			else
			{
				name = "Epsilon Station";
			}
		}

		public function updateZone():void
		{
			if (g.me == null)
			{
				return;
			}
			var _loc2_:int = g.me.team;
			var _loc1_:Number = Math.abs(capCounter / 10);
			if (_loc2_ == 0 && capCounter < 0 || _loc2_ == 1 && capCounter > 0)
			{
				TweenMax.to(enemyZone, 1, {"scaleX": 0});
				TweenMax.to(enemyZone, 1, {"scaleY": 0});
				TweenMax.to(friendlyZone, 1, {"scaleX": _loc1_});
				TweenMax.to(friendlyZone, 1, {"scaleY": _loc1_});
			}
			else if (_loc2_ == 0 && capCounter > 0 || _loc2_ == 1 && capCounter < 0)
			{
				TweenMax.to(friendlyZone, 1, {"scaleX": 0});
				TweenMax.to(friendlyZone, 1, {"scaleY": 0});
				TweenMax.to(enemyZone, 1, {"scaleX": _loc1_});
				TweenMax.to(enemyZone, 1, {"scaleY": _loc1_});
			}
			else
			{
				TweenMax.to(enemyZone, 1, {"scaleX": 0});
				TweenMax.to(enemyZone, 1, {"scaleY": 0});
				TweenMax.to(friendlyZone, 1, {"scaleX": 0});
				TweenMax.to(friendlyZone, 1, {"scaleY": 0});
			}
			if (_loc2_ == 0)
			{
				if (oldCapCounter == -10 && capCounter == -9)
				{
					g.textManager.createPvpText("The enemy team is assaulting " + name + "!", 0, 40, 16733525);
					status = 2;
				}
				if (oldCapCounter == 10 && capCounter == 9)
				{
					g.textManager.createPvpText("Your team is assulting " + name + "!", 0, 40, 5592575);
					status = 1;
				}
				if (oldCapCounter == 9 && capCounter == 10)
				{
					g.textManager.createPvpText("The enemy team have captured " + name + "!", 0, 40, 16733525);
					status = 0;
				}
				if (oldCapCounter == -9 && capCounter == -10)
				{
					g.textManager.createPvpText("Your team have captured " + name + "!", 0, 40, 5592575);
					status = 0;
				}
			}
			if (_loc2_ == 1)
			{
				if (oldCapCounter == -10 && capCounter == -9)
				{
					g.textManager.createPvpText("Your team is assaulting " + name + "!", 0, 40, 5592575);
					status = 1;
				}
				if (oldCapCounter == 10 && capCounter == 9)
				{
					g.textManager.createPvpText("The enemy team is assaulting " + name + "!", 0, 40, 16733525);
					status = 2;
				}
				if (oldCapCounter == -9 && capCounter == -10)
				{
					g.textManager.createPvpText("The enemy team have captured " + name + "!", 0, 40, 16733525);
					status = 0;
				}
				if (oldCapCounter == 9 && capCounter == 10)
				{
					g.textManager.createPvpText("Your team have captured " + name + "!", 0, 40, 5592575);
					status = 0;
				}
			}
			oldCapCounter = capCounter;
		}

		public function getMiniZone():Image
		{
			var _loc8_:Image = null;
			var _loc1_:* = 0;
			_loc1_ = 16777215;
			var _loc5_:Sprite = new Sprite();
			_loc5_.graphics.lineStyle(1, _loc1_, 0.2);
			var _loc7_:String = "radial";
			var _loc3_:Array = [0, _loc1_];
			var _loc4_:Array = [0, 0.6];
			var _loc6_:Array = [0, 255];
			var _loc2_:Matrix = new Matrix();
			_loc2_.createGradientBox(40, 40, 0, -20, -20);
			_loc5_.graphics.beginGradientFill(_loc7_, _loc3_, _loc4_, _loc6_, _loc2_);
			_loc5_.graphics.drawCircle(0, 0, 20);
			_loc5_.graphics.endFill();
			_loc8_ = TextureManager.imageFromSprite(_loc5_, name);
			_loc8_.x = x;
			_loc8_.y = y;
			_loc8_.pivotX = _loc8_.width / 2;
			_loc8_.pivotY = _loc8_.height / 2;
			_loc8_.scaleX = 1;
			_loc8_.scaleY = 1;
			_loc8_.alpha = 1;
			_loc8_.blendMode = "add";
			return _loc8_;
		}

		private function createZoneImg(param1:Object, param2:uint, param3:String):Image
		{
			var _loc10_:Image = null;
			var _loc7_:Sprite = new Sprite();
			_loc7_.graphics.lineStyle(1, param2, 0.2);
			var _loc9_:String = "radial";
			var _loc5_:Array = [0, param2];
			var _loc6_:Array = [0, 0.6];
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
