package core.hud.components.credits
{
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.InputText;
	import core.hud.components.Style;
	import core.hud.components.dialogs.PopupMessage;
	import core.scene.Game;
	import generics.Localize;
	import playerio.Message;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class Redeem extends Sprite
	{
		private var g:Game;
		
		private var input:InputText;
		
		private var box:Box;
		
		private var redeemButton:Button;
		
		private var cancelButton:Button;
		
		private var label:TextField;
		
		public function Redeem(param1:Game)
		{
			box = new Box(220, 80, "highlight", 1, 15);
			super();
			this.g = param1;
			addChild(box);
			label = new TextField(100, 20, Localize.t("Enter your redeem code."), new TextFormat("DAIDRR", 14, 16777215));
			label.x = 10;
			label.autoSize = "bothDirections";
			box.addChild(label);
			input = new InputText(10, label.y + label.height, 200, 20);
			input.restrict = "a-zA-Z0-9\\-";
			box.addChild(input);
			cancelButton = new Button(onCancel, Localize.t("Cancel"), "normal");
			cancelButton.x = box.width - cancelButton.width - 40;
			cancelButton.y = input.y + input.height + 20;
			box.addChild(cancelButton);
			redeemButton = new Button(onRedeem, Localize.t("Redeem"), "buy");
			redeemButton.x = cancelButton.x - redeemButton.width - 10;
			redeemButton.y = cancelButton.y;
			box.addChild(redeemButton);
			addEventListener("addedToStage", stageAddHandler);
		}
		
		private function stageAddHandler(param1:Event):void
		{
			removeEventListener("addedToStage", stageAddHandler);
			stage.addEventListener("resize", redraw);
			redraw();
		}
		
		private function onRedeem(param1:TouchEvent):void
		{
			var _loc3_:String = input.text;
			if (_loc3_ === "")
			{
				redeemButton.enabled = true;
				return;
			}
			var _loc2_:RegExp = /([0-9a-zA-Z]{4})-([0-9a-zA-Z]{4})/;
			if (_loc3_.length === 9 && _loc3_.match(_loc2_).length === 1)
			{
				g.rpc("redeemCode", onRedeemCode, _loc3_);
			}
			else
			{
				g.rpc("redeemPod", onRedeemPod, _loc3_);
			}
		}
		
		private function onRedeemCode(param1:Message):void
		{
			var skin:String;
			var popup:RedeemSuccess;
			var m:Message = param1;
			var i:int = 0;
			var success:Boolean = m.getBoolean(i++);
			if (!success)
			{
				label.text = Localize.t(m.getString(i));
				label.format.color = Style.COLOR_INVALID;
				redeemButton.enabled = true;
				return;
			}
			g.me.tractorBeam = m.getNumber(i++);
			g.me.expBoost = m.getNumber(i++);
			g.me.cargoProtection = m.getNumber(i++);
			g.me.xpProtection = m.getNumber(i++);
			skin = m.getString(i);
			g.me.addNewSkin(skin);
			g.hud.update();
			popup = new RedeemSuccess(g, skin);
			g.addChildToOverlay(popup);
			popup.addEventListener("close", function(param1:Event):void
			{
				popup.removeEventListeners();
				g.removeChildFromOverlay(popup);
			});
			stage.removeEventListener("resize", redraw);
			dispatchEventWith("success");
		}
		
		private function onRedeemPod(param1:Message):void
		{
			var count:int;
			var popup:PopupMessage;
			var m:Message = param1;
			var i:int = 0;
			var success:Boolean = m.getBoolean(i++);
			if (!success)
			{
				label.text = Localize.t(m.getString(i));
				label.format.color = Style.COLOR_INVALID;
				redeemButton.enabled = true;
				return;
			}
			count = m.getInt(i);
			popup = new PopupMessage();
			popup.text = "Congratulations!\n\nYou have received " + count + " pods";
			g.addChildToOverlay(popup);
			popup.addEventListener("close", function(param1:Event):void
			{
				popup.removeEventListeners();
				g.removeChildFromOverlay(popup);
			});
			stage.removeEventListener("resize", redraw);
			dispatchEventWith("success");
			g.rpc("getPodCount", function(param1:Message):void
			{
				g.hud.updatePodCount(param1.getInt(0));
			});
		}
		
		private function onCancel(param1:TouchEvent):void
		{
			stage.removeEventListener("resize", redraw);
			dispatchEventWith("close");
		}
		
		protected function redraw(param1:Event = null):void
		{
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
		}
	}
}
