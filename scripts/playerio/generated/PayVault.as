package playerio.generated {
	import flash.events.EventDispatcher;
	import playerio.Client;
	import playerio.generated.messages.PayVaultBuyArgs;
	import playerio.generated.messages.PayVaultBuyError;
	import playerio.generated.messages.PayVaultBuyOutput;
	import playerio.generated.messages.PayVaultConsumeArgs;
	import playerio.generated.messages.PayVaultConsumeError;
	import playerio.generated.messages.PayVaultConsumeOutput;
	import playerio.generated.messages.PayVaultCreditArgs;
	import playerio.generated.messages.PayVaultCreditError;
	import playerio.generated.messages.PayVaultCreditOutput;
	import playerio.generated.messages.PayVaultDebitArgs;
	import playerio.generated.messages.PayVaultDebitError;
	import playerio.generated.messages.PayVaultDebitOutput;
	import playerio.generated.messages.PayVaultGiveArgs;
	import playerio.generated.messages.PayVaultGiveError;
	import playerio.generated.messages.PayVaultGiveOutput;
	import playerio.generated.messages.PayVaultPaymentInfoArgs;
	import playerio.generated.messages.PayVaultPaymentInfoError;
	import playerio.generated.messages.PayVaultPaymentInfoOutput;
	import playerio.generated.messages.PayVaultReadHistoryArgs;
	import playerio.generated.messages.PayVaultReadHistoryError;
	import playerio.generated.messages.PayVaultReadHistoryOutput;
	import playerio.generated.messages.PayVaultRefreshArgs;
	import playerio.generated.messages.PayVaultRefreshError;
	import playerio.generated.messages.PayVaultRefreshOutput;
	import playerio.generated.messages.PayVaultUsePaymentInfoArgs;
	import playerio.generated.messages.PayVaultUsePaymentInfoError;
	import playerio.generated.messages.PayVaultUsePaymentInfoOutput;
	import playerio.utils.Converter;
	import playerio.utils.HTTPChannel;
	
	public class PayVault extends EventDispatcher {
		protected var channel:HTTPChannel;
		
		protected var client:Client;
		
		public function PayVault(channel:HTTPChannel, client:Client) {
			super();
			this.channel = channel;
			this.client = client;
		}
		
		protected function _payVaultReadHistory(page:uint, pageSize:uint, targetUserId:String, callback:Function = null, errorHandler:Function = null) : void {
			var input:PayVaultReadHistoryArgs = new PayVaultReadHistoryArgs(page,pageSize,targetUserId);
			var output:PayVaultReadHistoryOutput = new PayVaultReadHistoryOutput();
			channel.Request(160,input,output,new PayVaultReadHistoryError(),function(param1:PayVaultReadHistoryOutput):void {
				if(callback != null) {
					try {
						callback(param1.entries);
					}
					catch(e:Error) {
						client.handleCallbackError("PayVault.payVaultReadHistory",e);
						throw e;
					}
				}
			},function(param1:PayVaultReadHistoryError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _payVaultRefresh(lastVersion:String, targetUserId:String, callback:Function = null, errorHandler:Function = null) : void {
			var input:PayVaultRefreshArgs = new PayVaultRefreshArgs(lastVersion,targetUserId);
			var output:PayVaultRefreshOutput = new PayVaultRefreshOutput();
			channel.Request(163,input,output,new PayVaultRefreshError(),function(param1:PayVaultRefreshOutput):void {
				if(callback != null) {
					try {
						callback(param1.vaultContents);
					}
					catch(e:Error) {
						client.handleCallbackError("PayVault.payVaultRefresh",e);
						throw e;
					}
				}
			},function(param1:PayVaultRefreshError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _payVaultConsume(ids:Array, targetUserId:String, callback:Function = null, errorHandler:Function = null) : void {
			var input:PayVaultConsumeArgs = new PayVaultConsumeArgs(ids,targetUserId);
			var output:PayVaultConsumeOutput = new PayVaultConsumeOutput();
			channel.Request(166,input,output,new PayVaultConsumeError(),function(param1:PayVaultConsumeOutput):void {
				if(callback != null) {
					try {
						callback(param1.vaultContents);
					}
					catch(e:Error) {
						client.handleCallbackError("PayVault.payVaultConsume",e);
						throw e;
					}
				}
			},function(param1:PayVaultConsumeError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _payVaultCredit(amount:uint, reason:String, targetUserId:String, callback:Function = null, errorHandler:Function = null) : void {
			var input:PayVaultCreditArgs = new PayVaultCreditArgs(amount,reason,targetUserId);
			var output:PayVaultCreditOutput = new PayVaultCreditOutput();
			channel.Request(169,input,output,new PayVaultCreditError(),function(param1:PayVaultCreditOutput):void {
				if(callback != null) {
					try {
						callback(param1.vaultContents);
					}
					catch(e:Error) {
						client.handleCallbackError("PayVault.payVaultCredit",e);
						throw e;
					}
				}
			},function(param1:PayVaultCreditError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _payVaultDebit(amount:uint, reason:String, targetUserId:String, callback:Function = null, errorHandler:Function = null) : void {
			var input:PayVaultDebitArgs = new PayVaultDebitArgs(amount,reason,targetUserId);
			var output:PayVaultDebitOutput = new PayVaultDebitOutput();
			channel.Request(172,input,output,new PayVaultDebitError(),function(param1:PayVaultDebitOutput):void {
				if(callback != null) {
					try {
						callback(param1.vaultContents);
					}
					catch(e:Error) {
						client.handleCallbackError("PayVault.payVaultDebit",e);
						throw e;
					}
				}
			},function(param1:PayVaultDebitError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _payVaultBuy(items:Array, storeItems:Boolean, targetUserId:String, callback:Function = null, errorHandler:Function = null) : void {
			var input:PayVaultBuyArgs = new PayVaultBuyArgs(items,storeItems,targetUserId);
			var output:PayVaultBuyOutput = new PayVaultBuyOutput();
			channel.Request(175,input,output,new PayVaultBuyError(),function(param1:PayVaultBuyOutput):void {
				if(callback != null) {
					try {
						callback(param1.vaultContents);
					}
					catch(e:Error) {
						client.handleCallbackError("PayVault.payVaultBuy",e);
						throw e;
					}
				}
			},function(param1:PayVaultBuyError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _payVaultGive(items:Array, targetUserId:String, callback:Function = null, errorHandler:Function = null) : void {
			var input:PayVaultGiveArgs = new PayVaultGiveArgs(items,targetUserId);
			var output:PayVaultGiveOutput = new PayVaultGiveOutput();
			channel.Request(178,input,output,new PayVaultGiveError(),function(param1:PayVaultGiveOutput):void {
				if(callback != null) {
					try {
						callback(param1.vaultContents);
					}
					catch(e:Error) {
						client.handleCallbackError("PayVault.payVaultGive",e);
						throw e;
					}
				}
			},function(param1:PayVaultGiveError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _payVaultPaymentInfo(provider:String, purchaseArguments:Object, items:Array, callback:Function = null, errorHandler:Function = null) : void {
			var input:PayVaultPaymentInfoArgs = new PayVaultPaymentInfoArgs(provider,Converter.toKeyValueArray(purchaseArguments),items);
			var output:PayVaultPaymentInfoOutput = new PayVaultPaymentInfoOutput();
			channel.Request(181,input,output,new PayVaultPaymentInfoError(),function(param1:PayVaultPaymentInfoOutput):void {
				if(callback != null) {
					try {
						callback(Converter.toKeyValueObject(param1.providerArguments));
					}
					catch(e:Error) {
						client.handleCallbackError("PayVault.payVaultPaymentInfo",e);
						throw e;
					}
				}
			},function(param1:PayVaultPaymentInfoError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _payVaultUsePaymentInfo(provider:String, providerArguments:Object, callback:Function = null, errorHandler:Function = null) : void {
			var input:PayVaultUsePaymentInfoArgs = new PayVaultUsePaymentInfoArgs(provider,Converter.toKeyValueArray(providerArguments));
			var output:PayVaultUsePaymentInfoOutput = new PayVaultUsePaymentInfoOutput();
			channel.Request(184,input,output,new PayVaultUsePaymentInfoError(),function(param1:PayVaultUsePaymentInfoOutput):void {
				if(callback != null) {
					try {
						callback(Converter.toKeyValueObject(param1.providerResults),param1.vaultContents);
					}
					catch(e:Error) {
						client.handleCallbackError("PayVault.payVaultUsePaymentInfo",e);
						throw e;
					}
				}
			},function(param1:PayVaultUsePaymentInfoError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
	}
}

