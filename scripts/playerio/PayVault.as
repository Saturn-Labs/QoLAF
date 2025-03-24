package playerio {
	import playerio.generated.PayVault;
	import playerio.generated.PlayerIOError;
	import playerio.generated.messages.PayVaultContents;
	import playerio.utils.Converter;
	import playerio.utils.HTTPChannel;
	
	public class PayVault extends playerio.generated.PayVault {
		private var _version:String = null;
		
		private var _coins:Number = 0;
		
		private var _items:Array = [];
		
		public function PayVault(channel:HTTPChannel, client:Client) {
			super(channel,client);
		}
		
		public function get coins() : Number {
			if(_version !== null) {
				return _coins;
			}
			throw new playerio.generated.PlayerIOError("Cannot access coins before vault has been loaded. Please refresh the vault first",50);
		}
		
		public function get items() : Array {
			if(_version !== null) {
				return _items;
			}
			throw new playerio.generated.PlayerIOError("Cannot access items before vault has been loaded. Please refresh the vault first",50);
		}
		
		public function readHistory(page:uint, pageSize:uint, callback:Function = null, errorHandler:Function = null) : void {
			_payVaultReadHistory(page,pageSize,null,function(param1:Array):void {
				if(callback != null) {
					callback(Converter.toPayVaultHistoryEntryArray(param1));
				}
			},errorHandler);
		}
		
		public function refresh(callback:Function = null, errorHandler:Function = null) : void {
			_payVaultRefresh(_version,null,function(param1:PayVaultContents):void {
				parseVault(param1);
				if(callback != null) {
					callback();
				}
			},errorHandler);
		}
		
		public function credit(amount:uint, reason:String, callback:Function = null, errorHandler:Function = null) : void {
			_payVaultCredit(amount,reason,null,function(param1:PayVaultContents):void {
				parseVault(param1);
				if(callback != null) {
					callback();
				}
			},errorHandler);
		}
		
		public function debit(amount:uint, reason:String, callback:Function = null, errorHandler:Function = null) : void {
			_payVaultDebit(amount,reason,null,function(param1:PayVaultContents):void {
				parseVault(param1);
				if(callback != null) {
					callback();
				}
			},errorHandler);
		}
		
		public function consume(items:Array, callback:Function = null, errorHandler:Function = null) : void {
			var item:VaultItem;
			var ids:Array = [];
			var a:int = 0;
			while(a < items.length) {
				item = items[a] as VaultItem;
				if(item == null) {
					throw new playerio.generated.PlayerIOError("Element is not a VaultItem: " + items[a],2);
				}
				ids.push(item.id);
				a++;
			}
			_payVaultConsume(ids,null,function(param1:PayVaultContents):void {
				parseVault(param1);
				if(callback != null) {
					callback();
				}
			},errorHandler);
		}
		
		public function getBuyDirectInfo(provider:String, purchaseArguments:Object, items:Array, callback:Function = null, errorHandler:Function = null) : void {
			_payVaultPaymentInfo(provider,purchaseArguments,Converter.toBuyItemInfoArray(items),callback,errorHandler);
		}
		
		public function getBuyCoinsInfo(provider:String, purchaseArguments:Object, callback:Function = null, errorHandler:Function = null) : void {
			_payVaultPaymentInfo(provider,purchaseArguments,null,callback,errorHandler);
		}
		
		public function buy(items:Array, storeItems:Boolean, callback:Function = null, errorHandler:Function = null) : void {
			_payVaultBuy(Converter.toBuyItemInfoArray(items),storeItems,null,function(param1:PayVaultContents):void {
				parseVault(param1);
				if(callback != null) {
					callback();
				}
			},errorHandler);
		}
		
		public function give(items:Array, callback:Function = null, errorHandler:Function = null) : void {
			_payVaultGive(Converter.toBuyItemInfoArray(items),null,function(param1:PayVaultContents):void {
				parseVault(param1);
				if(callback != null) {
					callback();
				}
			},errorHandler);
		}
		
		public function usePaymentInfo(provider:String, providerArguments:Object, callback:Function = null, errorHandler:Function = null) : void {
			_payVaultUsePaymentInfo(provider,providerArguments,function(param1:Object, param2:PayVaultContents):void {
				parseVault(param2);
				if(callback != null) {
					callback(param1);
				}
			},errorHandler);
		}
		
		public function has(itemKey:String) : Boolean {
			var _local3:int = 0;
			var _local2:VaultItem = null;
			_local3 = 0;
			while(_local3 < items.length) {
				_local2 = items[_local3] as VaultItem;
				if(_local2.itemKey == itemKey) {
					return true;
				}
				_local3++;
			}
			return false;
		}
		
		public function first(itemKey:String) : VaultItem {
			var _local3:int = 0;
			var _local2:VaultItem = null;
			_local3 = 0;
			while(_local3 < items.length) {
				_local2 = items[_local3] as VaultItem;
				if(_local2.itemKey == itemKey) {
					return _local2;
				}
				_local3++;
			}
			return null;
		}
		
		public function count(itemKey:String) : uint {
			var _local4:int = 0;
			var _local2:VaultItem = null;
			var _local3:int = 0;
			_local4 = 0;
			while(_local4 < items.length) {
				_local2 = items[_local4] as VaultItem;
				if(_local2.itemKey == itemKey) {
					_local3++;
				}
				_local4++;
			}
			return _local3;
		}
		
		private function parseVault(vault:PayVaultContents) : void {
			if(vault != null) {
				_version = vault.version;
				_coins = vault.coins;
				_items = Converter.toVaultItemArray(vault.items);
			}
		}
	}
}

