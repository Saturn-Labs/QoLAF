package core.hud.components.dialogs {
	import core.hud.components.Button;
	import core.hud.components.PriceCommodities;
	import core.scene.Game;
	import playerio.Message;
	import starling.events.Event;
	
	public class PopupBuyMessage extends PopupConfirmMessage {
		public static const BOUGHT_WITH_FLUX:String = "fluxBuy";
		
		private var priceMinerals:Vector.<PriceCommodities> = new Vector.<PriceCommodities>();
		
		private var fluxButton:Button;
		
		private var g:Game;
		
		public function PopupBuyMessage(g:Game) {
			super("Buy");
			this.g = g;
			this.confirmButton.visible = false;
		}
		
		public function addCost(pm:PriceCommodities) : void {
			priceMinerals.push(pm);
			if(!g.myCargo.hasCommodities(pm.item,pm.amount)) {
				confirmButton.enabled = false;
			}
			box.addChild(pm);
			this.confirmButton.visible = true;
			redraw();
		}
		
		public function addBuyForFluxButton(fluxCost:int, slot:int, rpcName:String, buyMessage:String) : void {
			fluxButton = new Button(function():void {
				g.creditManager.refresh(function():void {
					onBuyForFlux(fluxCost,slot,rpcName,buyMessage);
				});
			},"Buy for " + fluxCost + " Flux","buy");
			fluxButton.autoEnableAfterClick = true;
			box.addChild(fluxButton);
			redraw();
		}
		
		private function onBuyForFlux(fluxCost:int, slot:int, rpcName:String, buyMessage:String) : void {
			var creditBuyBox:CreditBuyBox = new CreditBuyBox(g,fluxCost,buyMessage);
			g.addChildToOverlay(creditBuyBox);
			creditBuyBox.addEventListener("accept",function(param1:Event):void {
				var e:Event = param1;
				g.rpc(rpcName,function(param1:Message):void {
					if(param1.getBoolean(0)) {
						g.creditManager.refresh();
						dispatchEventWith("fluxBuy");
					} else {
						g.showErrorDialog(param1.getString(1),true);
						g.removeChildFromOverlay(creditBuyBox,true);
					}
				},slot);
			});
			creditBuyBox.addEventListener("close",function(param1:Event):void {
				g.removeChildFromOverlay(creditBuyBox,true);
			});
		}
		
		override protected function redraw(e:Event = null) : void {
			var _local7:int = 0;
			var _local8:PriceCommodities = null;
			var _local2:Number = NaN;
			var _local3:Number = NaN;
			var _local6:int = 0;
			var _local4:Object = null;
			var _local5:int = 0;
			try {
				if(g == null || g.stage == null || box == null) {
					return;
				}
				_local5++;
				_local7 = 0;
				while(_local7 < priceMinerals.length) {
					_local8 = priceMinerals[_local7];
					_local8.y = _local7 * 30 + textField.height + 15;
					_local7++;
				}
				_local5++;
				_local2 = textField.height + _local7 * 30 + 15;
				_local5++;
				_local3 = 0;
				_local5++;
				if(confirmButton.visible) {
					confirmButton.y = _local2;
					_local5++;
					confirmButton.x = _local3;
					_local5++;
					_local3 += confirmButton.width + 5;
					_local5++;
				}
				if(fluxButton != null) {
					_local5++;
					fluxButton.y = _local2;
					_local5++;
					fluxButton.x = _local3;
					_local5++;
					_local3 += fluxButton.width + 5;
					_local5++;
				}
				closeButton.y = _local2;
				_local5++;
				closeButton.x = _local3;
				_local5++;
				_local6 = closeButton.y + closeButton.height - 3;
				_local5++;
				box.width = textField.width > closeButton.x + closeButton.width ? textField.width : closeButton.x + closeButton.width;
				_local5++;
				box.height = _local6;
				_local5++;
				box.x = g.stage.stageWidth / 2 - box.width / 2;
				_local5++;
				box.y = g.stage.stageHeight / 2 - box.height / 2;
				_local5++;
				bgr.width = g.stage.stageWidth;
				_local5++;
				bgr.height = g.stage.stageHeight;
				_local5++;
				bgr.alpha = 0.8;
			}
			catch(e:Error) {
				_local4 = {};
				_local4.box = box == null ? "null" : "exist";
				_local4.closeButton = closeButton == null ? "null" : "exist";
				_local4.fluxButton = fluxButton == null ? "null" : "exist";
				_local4.confirmButton = confirmButton == null ? "null" : "exist";
				_local4.priceMinerals = priceMinerals == null ? "null" : "exist";
				_local4.textField = textField == null ? "null" : "exist";
				_local4.line = _local5;
				g.client.errorLog.writeError("PopupbuyMessageNullError2","",e.getStackTrace(),_local4);
			}
		}
	}
}

