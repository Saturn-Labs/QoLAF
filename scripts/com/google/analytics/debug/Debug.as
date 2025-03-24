package com.google.analytics.debug {
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class Debug extends Label {
		public static var count:uint;
		
		private var _lines:Array;
		
		private var _linediff:int = 0;
		
		private var _preferredForcedWidth:uint = 540;
		
		public var maxLines:uint = 16;
		
		public function Debug(color:uint = 0, alignement:Align = null, stickToEdge:Boolean = false) {
			if(alignement == null) {
				alignement = Align.bottom;
			}
			super("","uiLabel",color,alignement,stickToEdge);
			this.name = "Debug" + count++;
			this._lines = [];
			selectable = true;
			addEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
		}
		
		override public function get forcedWidth() : uint {
			if(this.parent) {
				if(UISprite(this.parent).forcedWidth > this._preferredForcedWidth) {
					return this._preferredForcedWidth;
				}
				return UISprite(this.parent).forcedWidth;
			}
			return super.forcedWidth;
		}
		
		override protected function dispose() : void {
			removeEventListener(KeyboardEvent.KEY_DOWN,this.onKey);
			super.dispose();
		}
		
		private function onKey(event:KeyboardEvent = null) : void {
			var _local2:Array = null;
			switch(event.keyCode) {
				case Keyboard.DOWN:
					_local2 = this._getLinesToDisplay(1);
					break;
				case Keyboard.UP:
					_local2 = this._getLinesToDisplay(-1);
					break;
				default:
					_local2 = null;
			}
			if(_local2 == null) {
				return;
			}
			text = _local2.join("\n");
		}
		
		private function _getLinesToDisplay(direction:int = 0) : Array {
			var _local2:Array = null;
			var _local3:uint = 0;
			var _local4:uint = 0;
			if(this._lines.length - 1 > this.maxLines) {
				if(this._linediff <= 0) {
					this._linediff += direction;
				} else if(this._linediff > 0 && direction < 0) {
					this._linediff += direction;
				}
				_local3 = uint(this._lines.length - this.maxLines + this._linediff);
				_local4 = _local3 + this.maxLines;
				_local2 = this._lines.slice(_local3,_local4);
			} else {
				_local2 = this._lines;
			}
			return _local2;
		}
		
		public function close() : void {
			this.dispose();
		}
		
		public function write(message:String, bold:Boolean = false) : void {
			var _local3:Array = null;
			if(message.indexOf("") > -1) {
				_local3 = message.split("\n");
			} else {
				_local3 = [message];
			}
			var _local4:String = "";
			var _local5:String = "";
			if(bold) {
				_local4 = "<b>";
				_local5 = "</b>";
			}
			var _local6:int = 0;
			while(_local6 < _local3.length) {
				this._lines.push(_local4 + _local3[_local6] + _local5);
				_local6++;
			}
			var _local7:Array = this._getLinesToDisplay();
			text = _local7.join("\n");
		}
		
		public function writeBold(message:String) : void {
			this.write(message,true);
		}
	}
}

