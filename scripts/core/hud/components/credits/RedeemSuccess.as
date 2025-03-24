package core.hud.components.credits {
	import core.hud.components.Style;
	import core.hud.components.dialogs.PopupMessage;
	import core.scene.Game;
	import generics.Localize;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class RedeemSuccess extends PopupMessage {
		private var container:Sprite;
		
		private var g:Game;
		
		public function RedeemSuccess(g:Game, skin:String) {
			var _local8:int = 0;
			var _local9:int = 0;
			var _local3:Image = null;
			container = new Sprite();
			super();
			this.g = g;
			var _local10:TextField = new TextField(100,20,"Congratulations you have received\n7 days of",new TextFormat("DAIDRR",14,Style.COLOR_YELLOW));
			_local10.autoSize = "bothDirections";
			container.addChild(_local10);
			var _local4:Array = ["ti_tractor_beam","ti_xp_boost","ti_xp_protection","ti_cargo_protection"];
			var _local5:Array = ["Tractor beam","XP boost","XP protection","Cargo protection"];
			_local8 = 0;
			_local9 = 0;
			while(_local8 < 4) {
				_local9 = _local8 * 30 + 50;
				_local3 = new Image(g.textureManager.getTextureGUIByTextureName(_local4[_local8]));
				_local3.scaleX = _local3.scaleY = 0.5;
				_local3.y = _local9;
				container.addChild(_local3);
				_local10 = new TextField(100,_local3.height,Localize.t(_local5[_local8]));
				_local10.format.color = 0xffffff;
				_local10.autoSize = "horizontal";
				_local10.x = 30;
				_local10.y = _local3.y;
				container.addChild(_local10);
				_local8++;
			}
			_local10 = new TextField(100,20,Localize.t("And and new ship has \nbeen added to your fleet."),new TextFormat("DAIDRR",14,Style.COLOR_YELLOW));
			_local10.y = _local9 + 50;
			_local10.autoSize = "bothDirections";
			container.addChild(_local10);
			var _local6:Object = g.dataManager.loadKey("Skins",skin);
			var _local11:Object = g.dataManager.loadKey("Ships",_local6.ship);
			var _local7:Object = g.dataManager.loadKey("Images",_local11.bitmap);
			_local3 = new Image(g.textureManager.getTextureMainByTextureName(_local7.textureName + "1"));
			_local3.y = _local10.y + _local10.height + 10;
			container.addChild(_local3);
			_local10 = new TextField(100,_local3.height,_local6.name);
			_local10.x = _local3.width + 5;
			_local10.y = _local3.y;
			_local10.format.color = 0xffffff;
			_local10.autoSize = "horizontal";
			container.addChild(_local10);
			container.x = 10;
			box.addChild(container);
			this.textField.height = container.height;
		}
		
		override protected function redraw(e:Event = null) : void {
			if(stage == null) {
				return;
			}
			var _local2:int = container.width + 25;
			closeButton.y = Math.round(container.height + 25);
			closeButton.x = Math.round(_local2 / 2 - closeButton.width / 2);
			var _local3:int = closeButton.y + closeButton.height - 3;
			box.width = _local2;
			box.height = _local3;
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
	}
}

