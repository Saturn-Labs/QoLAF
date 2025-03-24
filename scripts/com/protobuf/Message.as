package com.protobuf {
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.getDefinitionByName;
	
	public class Message {
		protected var fieldDescriptors:Array;
		
		public function Message() {
			super();
			if(fieldDescriptors == null) {
				fieldDescriptors = [];
			}
		}
		
		public function writeToCodedStream(output:CodedOutputStream) : void {
			for each(var _local3 in fieldDescriptors) {
				if(this[_local3.fieldName] == null) {
					if(_local3.isRequired()) {
						trace("Missing required field " + _local3.fieldName);
					}
				} else if(_local3.isRepeated() && this[_local3.fieldName] is Array) {
					for each(var _local2 in this[_local3.fieldName]) {
						if(_local3.isMessage()) {
							output.writeMessage(_local3.fieldNumber,_local2);
						} else {
							output.writeField(_local3.fieldNumber,_local2,_local3.type);
						}
					}
				} else if(_local3.isMessage()) {
					if(this[_local3.fieldName] is Message) {
						output.writeMessage(_local3.fieldNumber,this[_local3.fieldName]);
					}
				} else {
					output.writeField(_local3.fieldNumber,this[_local3.fieldName],_local3.type);
				}
			}
		}
		
		public function writeToDataOutput(output:IDataOutput) : void {
			var _local2:CodedOutputStream = CodedOutputStream.newInstance(output);
			writeToCodedStream(_local2);
		}
		
		public function readFromCodedStream(input:CodedInputStream) : void {
			var _local2:int = 0;
			var _local4:Descriptor = null;
			var _local6:* = undefined;
			var _local7:Class = null;
			var _local8:int = 0;
			var _local3:ByteArray = null;
			var _local5:int = input.readTag();
			while(_local5 != 0) {
				_local2 = WireFormat.getTagFieldNumber(_local5);
				_local4 = getDescriptorByFieldNumber(_local2);
				if(_local4 != null) {
					if(_local4.isMessage()) {
						_local7 = getDefinitionByName(_local4.messageClass) as Class;
						_local6 = new _local7();
						_local8 = input.readRawVarint32();
						_local3 = input.readRawBytes(_local8);
						_local3.position = 0;
						_local6.readFromDataOutput(_local3);
					} else {
						_local6 = input.readPrimitiveField(_local4.type);
					}
					if(_local4.isRepeated() && this[_local4.fieldName] is Array) {
						this[_local4.fieldName].push(_local6);
					} else {
						this[_local4.fieldName] = _local6;
					}
				} else {
					input.skipField(_local5);
				}
				_local5 = input.readTag();
			}
		}
		
		public function readFromDataOutput(input:IDataInput) : void {
			var _local2:CodedInputStream = CodedInputStream.newInstance(input);
			readFromCodedStream(_local2);
		}
		
		public function getSerializedSize() : int {
			var _local2:int = 0;
			for each(var _local1 in fieldDescriptors) {
				if(this[_local1.fieldName] != null) {
					_local2 += CodedOutputStream.computeFieldSize(_local1.fieldNumber,this[_local1.fieldName],_local1.type);
				}
			}
			return _local2;
		}
		
		protected function registerField(field:String, messageClass:String, type:int, label:int, fieldNumber:int) : void {
			if(fieldDescriptors[field] == null) {
				fieldDescriptors[field] = new Descriptor(field,messageClass,type,label,fieldNumber);
			}
		}
		
		public function getDescriptorByFieldNumber(fieldNum:int) : Descriptor {
			for each(var _local2 in fieldDescriptors) {
				if(_local2.fieldNumber == fieldNum) {
					return _local2;
				}
			}
			return null;
		}
		
		public function getDescriptor(field:String) : Descriptor {
			return fieldDescriptors[field];
		}
	}
}

