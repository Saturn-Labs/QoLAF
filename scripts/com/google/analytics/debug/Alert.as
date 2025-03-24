package com.google.analytics.debug {
	import flash.events.TextEvent;
	
	public class Alert extends Label {
		private var _actions:Array;
		
		public var autoClose:Boolean = true;
		
		public var actionOnNextLine:Boolean = true;
		
		public function Alert(text:String, actions:Array, tag:String = "uiAlert", color:uint = 0, alignement:Align = null, stickToEdge:Boolean = false, actionOnNextLine:Boolean = true) {
			if(color == 0) {
				color = uint(Style.alertColor);
			}
			if(alignement == null) {
				alignement = Align.center;
			}
			super(text,tag,color,alignement,stickToEdge);
			this.selectable = true;
			super.mouseChildren = true;
			this.buttonMode = true;
			this.mouseEnabled = true;
			this.useHandCursor = true;
			this.actionOnNextLine = actionOnNextLine;
			this._actions = [];
			var _local8:int = 0;
			while(_local8 < actions.length) {
				actions[_local8].container = this;
				this._actions.push(actions[_local8]);
				_local8++;
			}
		}
		
		private function _defineActions() : void {
			var _local3:AlertAction = null;
			var _local1:String = "";
			if(this.actionOnNextLine) {
				_local1 += "\n";
			} else {
				_local1 += " |";
			}
			_local1 += " ";
			var _local2:Array = [];
			var _local4:int = 0;
			while(_local4 < this._actions.length) {
				_local3 = this._actions[_local4];
				_local2.push("<a href=\"event:" + _local3.activator + "\">" + _local3.name + "</a>");
				_local4++;
			}
			_local1 += _local2.join(" | ");
			appendText(_local1,"uiAlertAction");
		}
		
		protected function isValidAction(action:String) : Boolean {
			var _local2:int = 0;
			while(_local2 < this._actions.length) {
				if(action == this._actions[_local2].activator) {
					return true;
				}
				_local2++;
			}
			return false;
		}
		
		protected function getAction(name:String) : AlertAction {
			var _local2:int = 0;
			while(_local2 < this._actions.length) {
				if(name == this._actions[_local2].activator) {
					return this._actions[_local2];
				}
				_local2++;
			}
			return null;
		}
		
		protected function spaces(num:int) : String {
			var _local2:String = "";
			var _local3:String = "          ";
			var _local4:int = 0;
			while(_local4 < num + 1) {
				_local2 += _local3;
				_local4++;
			}
			return _local2;
		}
		
		override protected function layout() : void {
			super.layout();
			this._defineActions();
		}
		
		public function close() : void {
			if(parent != null) {
				parent.removeChild(this);
			}
		}
		
		override public function onLink(event:TextEvent) : void {
			var _local2:AlertAction = null;
			if(this.isValidAction(event.text)) {
				_local2 = this.getAction(event.text);
				if(_local2) {
					_local2.execute();
				}
			}
			if(this.autoClose) {
				this.close();
			}
		}
	}
}

