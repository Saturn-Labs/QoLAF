package core.hud.components
{
	import generics.Util;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class TopPvPPlayersList extends Sprite
	{
		private static var topPvpPlayersList:Array;
		
		private var textureManager:ITextureManager;
		
		public function TopPvPPlayersList()
		{
			super();
			textureManager = TextureLocator.getService();
		}
		
		public function showHighscore(param1:Message):void
		{
			var _loc3_:int = 0;
			var _loc2_:Object = null;
			topPvpPlayersList = [];
			_loc3_ = 0;
			while (_loc3_ < param1.length)
			{
				_loc2_ = {};
				_loc2_.rank = param1.getInt(_loc3_);
				_loc2_.name = param1.getString(_loc3_ + 1);
				_loc2_.key = param1.getString(_loc3_ + 2);
				_loc2_.level = param1.getInt(_loc3_ + 3);
				_loc2_.clan = param1.getString(_loc3_ + 4);
				_loc2_.value = param1.getNumber(_loc3_ + 5);
				topPvpPlayersList.push(_loc2_);
				_loc3_ += 6;
			}
			drawTopPvpPlayers();
		}
		
		private function drawTopPvpPlayers():void
		{
			var _loc2_:int = 0;
			var _loc1_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < topPvpPlayersList.length)
			{
				drawPlayerObject(topPvpPlayersList[_loc2_], _loc2_, this);
				_loc1_ = int(topPvpPlayersList[_loc2_].rank);
				_loc2_++;
			}
		}
		
		private function drawPlayerObject(param1:Object, param2:int, param3:Sprite):void
		{
			var _loc6_:Quad = null;
			var _loc8_:Image = null;
			var _loc10_:int = param2 * 45;
			if (Login.client.connectUserId == param1.key)
			{
				_loc6_ = new Quad(670, 40, 4342338);
			}
			else
			{
				_loc6_ = new Quad(670, 40, 2171169);
			}
			_loc6_.y = _loc10_;
			_loc10_ += 10;
			var _loc4_:TextBitmap = new TextBitmap();
			_loc4_.text = topPvpPlayersList[param2].rank;
			_loc4_.size = 14;
			_loc4_.y = _loc10_;
			_loc4_.x = 10;
			var _loc7_:TextBitmap = new TextBitmap();
			_loc7_.text = param1.name;
			_loc7_.y = _loc10_;
			_loc7_.size = 14;
			_loc7_.format.color = 16729156;
			_loc7_.x = _loc4_.x + _loc4_.width + 10;
			var _loc5_:TextBitmap = new TextBitmap();
			_loc5_.text = "(Lv. " + param1.level + ")";
			_loc5_.y = _loc10_;
			_loc5_.size = 14;
			_loc5_.format.color = 16729156;
			_loc5_.x = _loc7_.x + _loc7_.width + 10;
			var _loc9_:TextBitmap = new TextBitmap();
			_loc9_.text = Util.formatAmount(Math.floor(param1.value));
			_loc9_.y = _loc10_;
			_loc9_.size = 14;
			_loc9_.format.color = Style.COLOR_YELLOW;
			_loc9_.x = 610 - _loc9_.width - 10;
			_loc8_ = new Image(textureManager.getTextureGUIByTextureName("clan_logo3.png"));
			_loc8_.y = _loc10_ + 20;
			_loc8_.color = 16711680;
			_loc8_.x = _loc9_.x + _loc9_.width + 10;
			_loc8_.scaleX = _loc8_.scaleY = 0.25;
			_loc8_.rotation = -0.5 * 3.141592653589793;
			param3.addChild(_loc6_);
			param3.addChild(_loc4_);
			param3.addChild(_loc7_);
			param3.addChild(_loc5_);
			param3.addChild(_loc9_);
			param3.addChild(_loc8_);
		}
	}
}
