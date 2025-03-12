package core.hud.components.dialogs
{
	import core.hud.components.Button;
	import core.hud.components.PriceCommodities;
	import core.scene.Game;
	import playerio.Message;
	import starling.events.Event;
	
	public class PopupBuyMessage extends PopupConfirmMessage
	{
		public static const BOUGHT_WITH_FLUX:String = "fluxBuy";
		private var priceMinerals:Vector.<PriceCommodities>;
		
		private var fluxButton:Button;
		
		private var g:Game;
		
		public function PopupBuyMessage(param1:Game)
		{
			priceMinerals = new Vector.<PriceCommodities>();
			super("Buy");
			this.g = param1;
			this.confirmButton.visible = false;
		}
		
		public function addCost(param1:PriceCommodities):void
		{
			priceMinerals.push(param1);
			if (!g.myCargo.hasCommodities(param1.item, param1.amount))
			{
				confirmButton.enabled = false;
			}
			box.addChild(param1);
			this.confirmButton.visible = true;
			redraw();
		}
		
		public function addBuyForFluxButton(param1:int, param2:int, param3:String, param4:String):void
		{
			var fluxCost:int = param1;
			var slot:int = param2;
			var rpcName:String = param3;
			var buyMessage:String = param4;
			fluxButton = new Button(function():void
			{
				g.creditManager.refresh(function():void
				{
					onBuyForFlux(fluxCost, slot, rpcName, buyMessage);
				});
			}, "Buy for " + fluxCost + " Flux", "buy");
			fluxButton.autoEnableAfterClick = true;
			box.addChild(fluxButton);
			redraw();
		}
		
		private function onBuyForFlux(param1:int, param2:int, param3:String, param4:String):void
		{
			var fluxCost:int = param1;
			var slot:int = param2;
			var rpcName:String = param3;
			var buyMessage:String = param4;
			var creditBuyBox:CreditBuyBox = new CreditBuyBox(g, fluxCost, buyMessage);
			g.addChildToOverlay(creditBuyBox);
			creditBuyBox.addEventListener("accept", function(param1:Event):void
			{
				var e:Event = param1;
				g.rpc(rpcName, function(param1:Message):void
				{
					if (param1.getBoolean(0))
					{
						g.creditManager.refresh();
						dispatchEventWith("fluxBuy");
					}
					else
					{
						g.showErrorDialog(param1.getString(1), true);
						g.removeChildFromOverlay(creditBuyBox, true);
					}
				}, slot);
			});
			creditBuyBox.addEventListener("close", function(param1:Event):void
			{
				g.removeChildFromOverlay(creditBuyBox, true);
			});
		}
		
		override protected function redraw(param1:Event = null):void
		{
			var _loc8_:int = 0;
			var _loc4_:PriceCommodities = null;
			var _loc6_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc7_:int = 0;
			var _loc3_:Object = null;
			var _loc5_:int = 0;
			try
			{
				if (g == null || g.stage == null || box == null)
				{
					return;
				}
				_loc5_++;
				_loc8_ = 0;
				while (_loc8_ < priceMinerals.length)
				{
					_loc4_ = priceMinerals[_loc8_];
					_loc4_.y = _loc8_ * 30 + textField.height + 15;
					_loc8_++;
				}
				_loc5_++;
				_loc6_ = textField.height + _loc8_ * 30 + 15;
				_loc5_++;
				_loc2_ = 0;
				_loc5_++;
				if (confirmButton.visible)
				{
					confirmButton.y = _loc6_;
					_loc5_++;
					confirmButton.x = _loc2_;
					_loc5_++;
					_loc2_ += confirmButton.width + 5;
					_loc5_++;
				}
				if (fluxButton != null)
				{
					_loc5_++;
					fluxButton.y = _loc6_;
					_loc5_++;
					fluxButton.x = _loc2_;
					_loc5_++;
					_loc2_ += fluxButton.width + 5;
					_loc5_++;
				}
				closeButton.y = _loc6_;
				_loc5_++;
				closeButton.x = _loc2_;
				_loc5_++;
				_loc7_ = closeButton.y + closeButton.height - 3;
				_loc5_++;
				box.width = textField.width > closeButton.x + closeButton.width ? textField.width : closeButton.x + closeButton.width;
				_loc5_++;
				box.height = _loc7_;
				_loc5_++;
				box.x = g.stage.stageWidth / 2 - box.width / 2;
				_loc5_++;
				box.y = g.stage.stageHeight / 2 - box.height / 2;
				_loc5_++;
				bgr.width = g.stage.stageWidth;
				_loc5_++;
				bgr.height = g.stage.stageHeight;
				_loc5_++;
				bgr.alpha = 0.8;
			}
			catch (e:Error)
			{
				_loc3_ = {};
				_loc3_.box = box == null ? "null" : "exist";
				_loc3_.closeButton = closeButton == null ? "null" : "exist";
				_loc3_.fluxButton = fluxButton == null ? "null" : "exist";
				_loc3_.confirmButton = confirmButton == null ? "null" : "exist";
				_loc3_.priceMinerals = priceMinerals == null ? "null" : "exist";
				_loc3_.textField = textField == null ? "null" : "exist";
				_loc3_.line = _loc5_;
				g.client.errorLog.writeError("PopupbuyMessageNullError2", "", e.getStackTrace(), _loc3_);
			}
		}
	}
}
