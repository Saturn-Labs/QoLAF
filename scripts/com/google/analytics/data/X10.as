package com.google.analytics.data {
	public class X10 {
		private var _projectData:Object;
		
		private var _key:String = "k";
		
		private var _value:String = "v";
		
		private var _set:Array = [this._key,this._value];
		
		private var _delimBegin:String = "(";
		
		private var _delimEnd:String = ")";
		
		private var _delimSet:String = "*";
		
		private var _delimNumValue:String = "!";
		
		private var _escapeChar:String = "\'";
		
		private var _escapeCharMap:Object;
		
		private var _minimum:int;
		
		private var _hasData:int;
		
		public function X10() {
			super();
			this._projectData = {};
			this._escapeCharMap = {};
			this._escapeCharMap[this._escapeChar] = "\'0";
			this._escapeCharMap[this._delimEnd] = "\'1";
			this._escapeCharMap[this._delimSet] = "\'2";
			this._escapeCharMap[this._delimNumValue] = "\'3";
			this._minimum = 1;
		}
		
		private function _setInternal(projectId:Number, type:String, num:Number, value:String) : void {
			if(!this.hasProject(projectId)) {
				this._projectData[projectId] = {};
			}
			if(this._projectData[projectId][type] == undefined) {
				this._projectData[projectId][type] = [];
			}
			this._projectData[projectId][type][num] = value;
			this._hasData += 1;
		}
		
		private function _getInternal(projectId:Number, type:String, num:Number) : Object {
			if(this.hasProject(projectId) && this._projectData[projectId][type] != undefined) {
				return this._projectData[projectId][type][num];
			}
			return undefined;
		}
		
		private function _clearInternal(projectId:Number, type:String) : void {
			var _local3:Boolean = false;
			var _local4:int = 0;
			var _local5:int = 0;
			if(this.hasProject(projectId) && this._projectData[projectId][type] != undefined) {
				this._projectData[projectId][type] = undefined;
				_local3 = true;
				_local5 = int(this._set.length);
				_local4 = 0;
				while(_local4 < _local5) {
					if(this._projectData[projectId][this._set[_local4]] != undefined) {
						_local3 = false;
						break;
					}
					_local4++;
				}
				if(_local3) {
					this._projectData[projectId] = undefined;
					this._hasData -= 1;
				}
			}
		}
		
		private function _escapeExtensibleValue(value:String) : String {
			var _local3:int = 0;
			var _local4:String = null;
			var _local5:String = null;
			var _local2:String = "";
			_local3 = 0;
			while(_local3 < value.length) {
				_local4 = value.charAt(_local3);
				_local5 = this._escapeCharMap[_local4];
				if(_local5) {
					_local2 += _local5;
				} else {
					_local2 += _local4;
				}
				_local3++;
			}
			return _local2;
		}
		
		private function _renderDataType(data:Array) : String {
			var _local3:String = null;
			var _local4:int = 0;
			var _local2:Array = [];
			_local4 = 0;
			while(_local4 < data.length) {
				if(data[_local4] != undefined) {
					_local3 = "";
					if(_local4 != this._minimum && data[_local4 - 1] == undefined) {
						_local3 += _local4.toString();
						_local3 += this._delimNumValue;
					}
					_local3 += this._escapeExtensibleValue(data[_local4]);
					_local2.push(_local3);
				}
				_local4++;
			}
			return this._delimBegin + _local2.join(this._delimSet) + this._delimEnd;
		}
		
		private function _renderProject(project:Object) : String {
			var _local4:int = 0;
			var _local5:Array = null;
			var _local2:String = "";
			var _local3:Boolean = false;
			var _local6:int = int(this._set.length);
			_local4 = 0;
			while(_local4 < _local6) {
				_local5 = project[this._set[_local4]];
				if(_local5) {
					if(_local3) {
						_local2 += this._set[_local4];
					}
					_local2 += this._renderDataType(_local5);
					_local3 = false;
				} else {
					_local3 = true;
				}
				_local4++;
			}
			return _local2;
		}
		
		public function hasProject(projectId:Number) : Boolean {
			return this._projectData[projectId];
		}
		
		public function hasData() : Boolean {
			return this._hasData > 0;
		}
		
		public function setKey(projectId:Number, num:Number, value:String) : Boolean {
			this._setInternal(projectId,this._key,num,value);
			return true;
		}
		
		public function getKey(projectId:Number, num:Number) : String {
			return this._getInternal(projectId,this._key,num) as String;
		}
		
		public function clearKey(projectId:Number) : void {
			this._clearInternal(projectId,this._key);
		}
		
		public function setValue(projectId:Number, num:Number, value:Number) : Boolean {
			if(Math.round(value) != value || isNaN(value) || value == Infinity) {
				return false;
			}
			this._setInternal(projectId,this._value,num,value.toString());
			return true;
		}
		
		public function getValue(projectId:Number, num:Number) : * {
			var _local3:* = this._getInternal(projectId,this._value,num);
			if(_local3 == null) {
				return null;
			}
			return Number(_local3);
		}
		
		public function clearValue(projectId:Number) : void {
			this._clearInternal(projectId,this._value);
		}
		
		public function renderUrlString() : String {
			var _local2:String = null;
			var _local1:Array = [];
			for(_local2 in this._projectData) {
				if(this.hasProject(Number(_local2))) {
					_local1.push(_local2 + this._renderProject(this._projectData[_local2]));
				}
			}
			return _local1.join("");
		}
		
		public function renderMergedUrlString(extObject:X10 = null) : String {
			var _local3:String = null;
			if(!extObject) {
				return this.renderUrlString();
			}
			var _local2:Array = [extObject.renderUrlString()];
			for(_local3 in this._projectData) {
				if(this.hasProject(Number(_local3)) && !extObject.hasProject(Number(_local3))) {
					_local2.push(_local3 + this._renderProject(this._projectData[_local3]));
				}
			}
			return _local2.join("");
		}
	}
}

