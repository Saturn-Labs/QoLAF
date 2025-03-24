package core.hud.components {
	import core.weapon.Damage;
	import flash.display.Sprite;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.TextureManager;
	
	public class ShopItemBarStats extends starling.display.Sprite {
		private static const BAR_WIDTH:Number = 18;
		
		private static const BAR_HEIGHT:Number = 14;
		
		private var bar:Texture;
		
		private var barFull:Texture;
		
		private var compact:Boolean;
		
		public function ShopItemBarStats(obj:Object, compact:Boolean = false) {
			super();
			this.compact = compact;
			var _local3:flash.display.Sprite = new flash.display.Sprite();
			_local3.graphics.beginFill(0x555555);
			_local3.graphics.drawRoundRect(0,0,18 + 4,14 + 4,4);
			_local3.graphics.endFill();
			bar = TextureManager.textureFromDisplayObject(_local3,"weapon_bar");
			var _local5:flash.display.Sprite = new flash.display.Sprite();
			_local5.graphics.beginFill(0x555555);
			_local5.graphics.drawRoundRect(0,0,18 + 4,14 + 4,4);
			_local5.graphics.beginFill(0x55ff55);
			_local5.graphics.drawRoundRect(2,2,18,14,4);
			_local5.graphics.endFill();
			barFull = TextureManager.textureFromDisplayObject(_local5,"weapon_bar_full");
			_local3 = null;
			var _local4:int = 0;
			if(!compact) {
				addText("Damage (" + Damage.TYPE[obj.damageType] + ")",60);
				addBar(obj.descriptionDmg,80);
				addText("Range",100);
				addBar(obj.descriptionRange,2 * 60);
				addText("Refire",140);
				addBar(obj.descriptionRefire,160);
				addText("Power",3 * 60);
				addBar(obj.descriptionHeat,200);
				_local4 = 210;
			}
			addText("Difficulty",10 + _local4);
			addBar(obj.descriptionDifficulty,10 + _local4 + 20);
			addText("Speciality: \n" + obj.description,10 + _local4 + 60);
		}
		
		private function addBar(n:int, y:Number) : void {
			var _local3:Image = null;
			var _local4:int = 0;
			_local4 = 0;
			while(_local4 < 10) {
				if(_local4 < n) {
					_local3 = new Image(barFull);
				} else {
					_local3 = new Image(bar);
				}
				_local3.x = _local4 * (_local3.width + 4);
				_local3.y = y;
				addChild(_local3);
				_local4++;
			}
		}
		
		private function addText(s:String, y:Number) : void {
			var _local3:Text = new Text();
			_local3.text = s;
			_local3.width = 5 * 60;
			_local3.wordWrap = true;
			_local3.color = 0xaaaaaa;
			_local3.y = y;
			_local3.visible = true;
			_local3.size = 10;
			addChild(_local3);
		}
	}
}

