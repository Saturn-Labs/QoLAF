package core.hud.components
{
	import core.weapon.Damage;
	import flash.display.Sprite;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.TextureManager;

	public class ShopItemBarStats extends starling.display.Sprite
	{
		private static const BAR_WIDTH:Number = 18;

		private static const BAR_HEIGHT:Number = 14;

		private var bar:Texture;
		private var barFull:Texture;
		private var compact:Boolean;
		public function ShopItemBarStats(param1:Object, param2:Boolean = false)
		{
			super();
			this.compact = param2;
			var _loc4_:flash.display.Sprite = new flash.display.Sprite();
			_loc4_.graphics.beginFill(5592405);
			_loc4_.graphics.drawRoundRect(0, 0, 18 + 4, 14 + 4, 4);
			_loc4_.graphics.endFill();
			bar = TextureManager.textureFromDisplayObject(_loc4_, "weapon_bar");
			var _loc3_:flash.display.Sprite = new flash.display.Sprite();
			_loc3_.graphics.beginFill(5592405);
			_loc3_.graphics.drawRoundRect(0, 0, 18 + 4, 14 + 4, 4);
			_loc3_.graphics.beginFill(5635925);
			_loc3_.graphics.drawRoundRect(2, 2, 18, 14, 4);
			_loc3_.graphics.endFill();
			barFull = TextureManager.textureFromDisplayObject(_loc3_, "weapon_bar_full");
			_loc4_ = null;
			var _loc5_:int = 0;
			if (!param2)
			{
				addText("Damage (" + Damage.TYPE[param1.damageType] + ")", 60);
				addBar(param1.descriptionDmg, 80);
				addText("Range", 100);
				addBar(param1.descriptionRange, 120);
				addText("Refire", 140);
				addBar(param1.descriptionRefire, 160);
				addText("Power", 180);
				addBar(param1.descriptionHeat, 200);
				_loc5_ = 210;
			}
			addText("Difficulty", 10 + _loc5_);
			addBar(param1.descriptionDifficulty, 10 + _loc5_ + 20);
			addText("Speciality: \n" + param1.description, 10 + _loc5_ + 60);
		}

		private function addBar(param1:int, param2:Number):void
		{
			var _loc3_:Image = null;
			var _loc4_:int = 0;
			_loc4_ = 0;
			while (_loc4_ < 10)
			{
				if (_loc4_ < param1)
				{
					_loc3_ = new Image(barFull);
				}
				else
				{
					_loc3_ = new Image(bar);
				}
				_loc3_.x = _loc4_ * (_loc3_.width + 4);
				_loc3_.y = param2;
				addChild(_loc3_);
				_loc4_++;
			}
		}

		private function addText(param1:String, param2:Number):void
		{
			var _loc3_:Text = new Text();
			_loc3_.text = param1;
			_loc3_.width = 300;
			_loc3_.wordWrap = true;
			_loc3_.color = 11184810;
			_loc3_.y = param2;
			_loc3_.visible = true;
			_loc3_.size = 10;
			addChild(_loc3_);
		}
	}
}
