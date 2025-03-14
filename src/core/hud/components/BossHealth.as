package core.hud.components {
	import core.boss.Boss;
	import core.scene.Game;
	import flash.geom.Point;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class BossHealth extends Sprite {
		private static const HP_WIDTH:Number = 600;
		private static const BOSS_DISPLAY_RANGE:Number = 1440000;
		private static const BOSS_HIDE_RANGE:Number = 5760000;
		private var bossHPBarBgr:ScaleImage;
		private var bossHPBar:ScaleImage;
		private var bossHPText:TextBitmap;
		private var bossNameText:TextBitmap;
		private var textureManager:ITextureManager;
		private var g:Game;
		
		public function BossHealth(g:Game) {
			super();
			this.g = g;
			textureManager = TextureLocator.getService();
		}
		
		public function load() : void {
			bossHPBar = new ScaleImage();
			bossHPBar.width = 10 * 60;
			bossHPBar.height = 20;
			bossHPBar.color = 0xff5533;
			bossHPBarBgr = new ScaleImage();
			bossHPBarBgr.width = 10 * 60;
			bossHPBarBgr.height = 20;
			bossHPBarBgr.color = 0x555533;
			bossHPBarBgr.alpha = 0.5;
			bossHPText = new TextBitmap();
			bossHPText.batchable = true;
			bossHPText.size = 16;
			bossHPText.format.color = 0xaaffaa;
			bossHPText.text = "100000/100000";
			bossNameText = new TextBitmap();
			bossNameText.batchable = true;
			bossNameText.size = 18;
			bossNameText.format.color = 0xaaffaa;
			bossNameText.text = "Boss name";
			bossHPBarBgr.y = 94;
			bossHPBarBgr.x = g.stage.stageWidth / 2 - 5 * 60;
			bossHPBar.y = 94;
			bossHPBar.x = g.stage.stageWidth / 2 - 5 * 60;
			bossHPText.y = 92;
			bossHPText.x = g.stage.stageWidth / 2 - bossHPText.width / 2;
			bossNameText.y = 68;
			bossNameText.x = g.stage.stageWidth / 2 - bossNameText.width / 2;
			bossHPBarBgr.alpha = 1;
			bossHPBar.alpha = 0.85;
			bossHPText.alpha = 1;
			bossNameText.alpha = 1;
		}
		
		public function update() : void {
			var _local5:Point = null;
			var _local1:Number = NaN;
			var _local4:Number = NaN;
			if(g.me == null || g.me.ship == null || g.solarSystem != null && g.solarSystem.key == "DrMy6JjyO0OI0ui7c80bNw") {
				return;
			}
			var _local3:* = null;
			for each(var _local2:* in g.bossManager.bosses) {
				_local5 = g.me.ship.pos;
				_local1 = (_local5.x - _local2.pos.x) * (_local5.x - _local2.pos.x) + (_local5.y - _local2.pos.y) * (_local5.y - _local2.pos.y);
				if(_local3 == null && _local1 < 400 * 60 * 60) {
					_local3 = _local2;
					break;
				}
				if(_local3 != null && _local1 > 5760000) {
					_local3 = null;
				}
			}
			if((_local3 == null || _local3.hp == 0 || _local3.awaitingActivation) && contains(bossHPBar)) {
				removeChild(bossHPBarBgr);
				removeChild(bossHPBar);
				removeChild(bossHPText);
				removeChild(bossNameText);
			} else if(_local3 != null && _local3.hp > 0 && !_local3.awaitingActivation) {
				if(!contains(bossHPBar)) {
					addChild(bossHPBarBgr);
					addChild(bossHPBar);
					addChild(bossHPText);
					addChild(bossNameText);
				}
				bossHPBar.width = 10 * 60 * _local3.hp / _local3.hpMax;
				bossHPText.text = _local3.hp + " / " + _local3.hpMax;
				bossNameText.text = _local3.name;
				_local4 = g.stage.stageWidth / 2;
				bossHPBarBgr.x = _local4 - 5 * 60;
				bossHPBar.x = _local4 - 5 * 60;
				bossHPText.x = _local4 - bossHPText.width / 2;
				bossNameText.x = _local4 - bossNameText.width / 2;
			}
		}
	}
}

