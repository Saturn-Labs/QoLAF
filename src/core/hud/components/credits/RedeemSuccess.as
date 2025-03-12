package core.hud.components.credits
{
	import core.hud.components.Style;
	import core.hud.components.dialogs.PopupMessage;
	import core.scene.Game;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class RedeemSuccess extends PopupMessage
	{
		private var container:Sprite;
		
		private var g:Game;
		
		public function RedeemSuccess(param1:Game, param2:String)
		{
			var _loc11_:int = 0;
			var _loc10_:int = 0;
			var _loc8_:Image = null;
			container = new Sprite();
			super();
			this.g = param1;
			var _loc5_:TextField = new TextField(100, 20, "Congratulations you have received\n7 days of", new TextFormat("DAIDRR", 14, Style.COLOR_YELLOW));
			_loc5_.autoSize = "bothDirections";
			container.addChild(_loc5_);
			var _loc9_:Array = ["ti_tractor_beam", "ti_xp_boost", "ti_xp_protection", "ti_cargo_protection"];
			var _loc3_:Array = ["Tractor beam", "XP boost", "XP protection", "Cargo protection"];
			_loc11_ = 0;
			_loc10_ = 0;
			while (_loc11_ < 4)
			{
				_loc10_ = _loc11_ * 30 + 50;
				_loc8_ = new Image(param1.textureManager.getTextureGUIByTextureName(_loc9_[_loc11_]));
				_loc8_.scaleX = _loc8_.scaleY = 0.5;
				_loc8_.y = _loc10_;
				container.addChild(_loc8_);
				_loc5_ = new TextField(100, _loc8_.height, Localize.t(_loc3_[_loc11_]));
				_loc5_.format.color = 16777215;
				_loc5_.autoSize = "horizontal";
				_loc5_.x = 30;
				_loc5_.y = _loc8_.y;
				container.addChild(_loc5_);
				_loc11_++;
			}
			_loc5_ = new TextField(100, 20, Localize.t("And and new ship has \nbeen added to your fleet."), new TextFormat("DAIDRR", 14, Style.COLOR_YELLOW));
			_loc5_.y = _loc10_ + 50;
			_loc5_.autoSize = "bothDirections";
			container.addChild(_loc5_);
			var _loc6_:Object = param1.dataManager.loadKey("Skins", param2);
			var _loc7_:Object = param1.dataManager.loadKey("Ships", _loc6_.ship);
			var _loc4_:Object = param1.dataManager.loadKey("Images", _loc7_.bitmap);
			_loc8_ = new Image(param1.textureManager.getTextureMainByTextureName(_loc4_.textureName + "1"));
			_loc8_.y = _loc5_.y + _loc5_.height + 10;
			container.addChild(_loc8_);
			_loc5_ = new TextField(100, _loc8_.height, _loc6_.name);
			_loc5_.x = _loc8_.width + 5;
			_loc5_.y = _loc8_.y;
			_loc5_.format.color = 16777215;
			_loc5_.autoSize = "horizontal";
			container.addChild(_loc5_);
			container.x = 10;
			box.addChild(container);
			this.textField.height = container.height;
		}
		
		override protected function redraw(param1:Event = null):void
		{
			if (stage == null)
			{
				return;
			}
			var _loc2_:int = container.width + 25;
			closeButton.y = Math.round(container.height + 25);
			closeButton.x = Math.round(_loc2_ / 2 - closeButton.width / 2);
			var _loc3_:int = closeButton.y + closeButton.height - 3;
			box.width = _loc2_;
			box.height = _loc3_;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
	}
}
