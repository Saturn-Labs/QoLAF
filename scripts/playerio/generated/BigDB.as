package playerio.generated {
	import flash.events.EventDispatcher;
	import playerio.Client;
	import playerio.generated.messages.CreateObjectsArgs;
	import playerio.generated.messages.CreateObjectsError;
	import playerio.generated.messages.CreateObjectsOutput;
	import playerio.generated.messages.DeleteIndexRangeArgs;
	import playerio.generated.messages.DeleteIndexRangeError;
	import playerio.generated.messages.DeleteIndexRangeOutput;
	import playerio.generated.messages.DeleteObjectsArgs;
	import playerio.generated.messages.DeleteObjectsError;
	import playerio.generated.messages.DeleteObjectsOutput;
	import playerio.generated.messages.LoadIndexRangeArgs;
	import playerio.generated.messages.LoadIndexRangeError;
	import playerio.generated.messages.LoadIndexRangeOutput;
	import playerio.generated.messages.LoadMatchingObjectsArgs;
	import playerio.generated.messages.LoadMatchingObjectsError;
	import playerio.generated.messages.LoadMatchingObjectsOutput;
	import playerio.generated.messages.LoadMyPlayerObjectArgs;
	import playerio.generated.messages.LoadMyPlayerObjectError;
	import playerio.generated.messages.LoadMyPlayerObjectOutput;
	import playerio.generated.messages.LoadObjectsArgs;
	import playerio.generated.messages.LoadObjectsError;
	import playerio.generated.messages.LoadObjectsOutput;
	import playerio.generated.messages.SaveObjectChangesArgs;
	import playerio.generated.messages.SaveObjectChangesError;
	import playerio.generated.messages.SaveObjectChangesOutput;
	import playerio.utils.HTTPChannel;
	
	public class BigDB extends EventDispatcher {
		protected var channel:HTTPChannel;
		
		protected var client:Client;
		
		public function BigDB(channel:HTTPChannel, client:Client) {
			super();
			this.channel = channel;
			this.client = client;
		}
		
		protected function _createObjects(objects:Array, loadExisting:Boolean, callback:Function = null, errorHandler:Function = null) : void {
			var input:CreateObjectsArgs = new CreateObjectsArgs(objects,loadExisting);
			var output:CreateObjectsOutput = new CreateObjectsOutput();
			channel.Request(82,input,output,new CreateObjectsError(),function(param1:CreateObjectsOutput):void {
				if(callback != null) {
					try {
						callback(param1.objects);
					}
					catch(e:Error) {
						client.handleCallbackError("BigDB.createObjects",e);
						throw e;
					}
				}
			},function(param1:CreateObjectsError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _loadObjects(objectIds:Array, callback:Function = null, errorHandler:Function = null) : void {
			var input:LoadObjectsArgs = new LoadObjectsArgs(objectIds);
			var output:LoadObjectsOutput = new LoadObjectsOutput();
			channel.Request(85,input,output,new LoadObjectsError(),function(param1:LoadObjectsOutput):void {
				if(callback != null) {
					try {
						callback(param1.objects);
					}
					catch(e:Error) {
						client.handleCallbackError("BigDB.loadObjects",e);
						throw e;
					}
				}
			},function(param1:LoadObjectsError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _saveObjectChanges(lockType:int, changesets:Array, createIfMissing:Boolean, callback:Function = null, errorHandler:Function = null) : void {
			var input:SaveObjectChangesArgs = new SaveObjectChangesArgs(lockType,changesets,createIfMissing);
			var output:SaveObjectChangesOutput = new SaveObjectChangesOutput();
			channel.Request(88,input,output,new SaveObjectChangesError(),function(param1:SaveObjectChangesOutput):void {
				if(callback != null) {
					try {
						callback(param1.versions);
					}
					catch(e:Error) {
						client.handleCallbackError("BigDB.saveObjectChanges",e);
						throw e;
					}
				}
			},function(param1:SaveObjectChangesError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _deleteObjects(objectIds:Array, callback:Function = null, errorHandler:Function = null) : void {
			var input:DeleteObjectsArgs = new DeleteObjectsArgs(objectIds);
			var output:DeleteObjectsOutput = new DeleteObjectsOutput();
			channel.Request(91,input,output,new DeleteObjectsError(),function(param1:DeleteObjectsOutput):void {
				if(callback != null) {
					try {
						callback();
					}
					catch(e:Error) {
						client.handleCallbackError("BigDB.deleteObjects",e);
						throw e;
					}
				}
			},function(param1:DeleteObjectsError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _loadMyPlayerObject(callback:Function = null, errorHandler:Function = null) : void {
			var input:LoadMyPlayerObjectArgs = new LoadMyPlayerObjectArgs();
			var output:LoadMyPlayerObjectOutput = new LoadMyPlayerObjectOutput();
			channel.Request(103,input,output,new LoadMyPlayerObjectError(),function(param1:LoadMyPlayerObjectOutput):void {
				if(callback != null) {
					try {
						callback(param1.playerObject);
					}
					catch(e:Error) {
						client.handleCallbackError("BigDB.loadMyPlayerObject",e);
						throw e;
					}
				}
			},function(param1:LoadMyPlayerObjectError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _loadMatchingObjects(table:String, index:String, indexValue:Array, limit:int, callback:Function = null, errorHandler:Function = null) : void {
			var input:LoadMatchingObjectsArgs = new LoadMatchingObjectsArgs(table,index,indexValue,limit);
			var output:LoadMatchingObjectsOutput = new LoadMatchingObjectsOutput();
			channel.Request(94,input,output,new LoadMatchingObjectsError(),function(param1:LoadMatchingObjectsOutput):void {
				if(callback != null) {
					try {
						callback(param1.objects);
					}
					catch(e:Error) {
						client.handleCallbackError("BigDB.loadMatchingObjects",e);
						throw e;
					}
				}
			},function(param1:LoadMatchingObjectsError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _loadIndexRange(table:String, index:String, startIndexValue:Array, stopIndexValue:Array, limit:int, callback:Function = null, errorHandler:Function = null) : void {
			var input:LoadIndexRangeArgs = new LoadIndexRangeArgs(table,index,startIndexValue,stopIndexValue,limit);
			var output:LoadIndexRangeOutput = new LoadIndexRangeOutput();
			channel.Request(97,input,output,new LoadIndexRangeError(),function(param1:LoadIndexRangeOutput):void {
				if(callback != null) {
					try {
						callback(param1.objects);
					}
					catch(e:Error) {
						client.handleCallbackError("BigDB.loadIndexRange",e);
						throw e;
					}
				}
			},function(param1:LoadIndexRangeError):void {
				var _local2:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
				if(errorHandler != null) {
					errorHandler(_local2);
					return;
				}
				throw _local2;
			});
		}
		
		protected function _deleteIndexRange(table:String, index:String, startIndexValue:Array, stopIndexValue:Array, callback:Function = null, errorHandler:Function = null) : void {
			var input:DeleteIndexRangeArgs = new DeleteIndexRangeArgs(table,index,startIndexValue,stopIndexValue);
			var output:DeleteIndexRangeOutput = new DeleteIndexRangeOutput();
			channel.Request(100,input,output,new DeleteIndexRangeError(),function(param1:DeleteIndexRangeOutput):void {
				if(callback != null) {
					try {
						callback();
					}
					catch(e:Error) {
						client.handleCallbackError("BigDB.deleteIndexRange",e);
						throw e;
					}
				}
			},function(param1:DeleteIndexRangeError):void {
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

