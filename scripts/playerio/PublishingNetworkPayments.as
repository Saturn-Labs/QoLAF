package playerio {
	import playerio.generated.PlayerIOError;
	import playerio.utils.Converter;
	
	internal class PublishingNetworkPayments {
		private var _client:Client;
		
		public function PublishingNetworkPayments(client:Client) {
			super();
			this._client = client;
		}
		
		public function showBuyCoinsDialog(cointamount:int, purchaseArguments:Object, callback:Function, errorCallback:Function) : void {
			if(purchaseArguments == null) {
				purchaseArguments = {};
			}
			purchaseArguments["coinamount"] = cointamount.toString();
			_client.payVault.getBuyCoinsInfo("publishingnetwork",purchaseArguments,function(param1:Object):void {
				var info:Object = param1;
				PublishingNetwork._internal_showDialog("buy",info,_client.channel,function(param1:Object):void {
					if(param1["error"] != undefined && errorCallback != null) {
						errorCallback(new playerio.generated.PlayerIOError(param1["error"],playerio.PlayerIOError.GeneralError.errorID));
					} else if(callback != null) {
						callback(param1);
					}
				});
			},errorCallback);
		}
		
		public function showBuyItemsDialog(items:Array, purchaseArguments:Object, callback:Function, errorCallback:Function) : void {
			_client.payVault.getBuyDirectInfo("publishingnetwork",purchaseArguments,Converter.toBuyItemInfoArray(items),function(param1:Object):void {
				var info:Object = param1;
				PublishingNetwork._internal_showDialog("buy",info,_client.channel,function(param1:Object):void {
					if(param1["error"] != undefined && errorCallback != null) {
						errorCallback(new playerio.generated.PlayerIOError(param1["error"],playerio.PlayerIOError.GeneralError.errorID));
					} else if(callback != null) {
						callback(param1);
					}
				});
			},errorCallback);
		}
	}
}

