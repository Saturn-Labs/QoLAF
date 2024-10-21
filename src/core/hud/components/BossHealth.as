package core.hud.components
{
	import core.boss.Boss;
	import core.scene.Game;
	import flash.geom.Point;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class BossHealth extends Sprite
	{
		private static const HP_WIDTH:Number = 600;
		
		private static const BOSS_DISPLAY_RANGE:Number = 1440000;
		
		private static const BOSS_HIDE_RANGE:Number = 5760000;
		
		private var bossHPBarBgr:ScaleImage;
		
		private var bossHPBar:ScaleImage;
		
		private var bossHPText:TextBitmap;
		
		private var bossNameText:TextBitmap;
		
		private var textureManager:ITextureManager;
		
		private var g:Game;
		
		public function BossHealth(param1:Game)
		{
			super();
			this.g = param1;
			textureManager = TextureLocator.getService();
		}
		
		public function load():void
		{
			bossHPBar = new ScaleImage();
			bossHPBar.width = 600;
			bossHPBar.height = 20;
			bossHPBar.color = 16733491;
			bossHPBarBgr = new ScaleImage();
			bossHPBarBgr.width = 600;
			bossHPBarBgr.height = 20;
			bossHPBarBgr.color = 5592371;
			bossHPBarBgr.alpha = 0.5;
			bossHPText = new TextBitmap();
			bossHPText.batchable = true;
			bossHPText.size = 16;
			bossHPText.format.color = 11206570;
			bossHPText.text = "100000/100000";
			bossNameText = new TextBitmap();
			bossNameText.batchable = true;
			bossNameText.size = 18;
			bossNameText.format.color = 11206570;
			bossNameText.text = "Boss name";
			bossHPBarBgr.y = 94;
			bossHPBarBgr.x = g.stage.stageWidth / 2 - 300;
			bossHPBar.y = 94;
			bossHPBar.x = g.stage.stageWidth / 2 - 300;
			bossHPText.y = 92;
			bossHPText.x = g.stage.stageWidth / 2 - bossHPText.width / 2;
			bossNameText.y = 68;
			bossNameText.x = g.stage.stageWidth / 2 - bossNameText.width / 2;
			bossHPBarBgr.alpha = 1;
			bossHPBar.alpha = 0.85;
			bossHPText.alpha = 1;
			bossNameText.alpha = 1;
		}
		
		public function update():void
		{
			var _loc5_:Point = null;
			var _loc1_:Number = NaN;
			var _loc4_:Number = NaN;
			if (g.me == null || g.me.ship == null || g.solarSystem != null && g.solarSystem.key == "DrMy6JjyO0OI0ui7c80bNw")
			{
				return;
			}
			var _loc3_:* = null;
			for each (var _loc2_:* in g.bossManager.bosses)
			{
				_loc5_ = g.me.ship.pos;
				_loc1_ = (_loc5_.x - _loc2_.pos.x) * (_loc5_.x - _loc2_.pos.x) + (_loc5_.y - _loc2_.pos.y) * (_loc5_.y - _loc2_.pos.y);
				if (_loc3_ == null && _loc1_ < 1440000)
				{
					_loc3_ = _loc2_;
					break;
				}
				if (_loc3_ != null && _loc1_ > 5760000)
				{
					_loc3_ = null;
				}
			}
			if ((_loc3_ == null || _loc3_.hp == 0 || _loc3_.awaitingActivation) && contains(bossHPBar))
			{
				removeChild(bossHPBarBgr);
				removeChild(bossHPBar);
				removeChild(bossHPText);
				removeChild(bossNameText);
			}
			else if (_loc3_ != null && _loc3_.hp > 0 && !_loc3_.awaitingActivation)
			{
				if (!contains(bossHPBar))
				{
					addChild(bossHPBarBgr);
					addChild(bossHPBar);
					addChild(bossHPText);
					addChild(bossNameText);
				}
				bossHPBar.width = 600 * _loc3_.hp / _loc3_.hpMax;
				bossHPText.text = _loc3_.hp + " / " + _loc3_.hpMax;
				bossNameText.text = _loc3_.name;
				_loc4_ = g.stage.stageWidth / 2;
				bossHPBarBgr.x = _loc4_ - 300;
				bossHPBar.x = _loc4_ - 300;
				bossHPText.x = _loc4_ - bossHPText.width / 2;
				bossNameText.x = _loc4_ - bossNameText.width / 2;
			}
		}
	}
}
