package com.google.analytics.debug {
	import com.google.analytics.GATracker;
	import com.google.analytics.core.GIFRequest;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	
	public class Layout implements ILayout {
		private var _display:DisplayObject;
		
		private var _debug:DebugConfiguration;
		
		private var _mainPanel:Panel;
		
		private var _hasWarning:Boolean;
		
		private var _hasInfo:Boolean;
		
		private var _hasDebug:Boolean;
		
		private var _hasGRAlert:Boolean;
		
		private var _infoQueue:Array;
		
		private var _maxCharPerLine:int = 85;
		
		private var _warningQueue:Array;
		
		private var _GRAlertQueue:Array;
		
		public var visualDebug:Debug;
		
		public function Layout(debug:DebugConfiguration, display:DisplayObject) {
			super();
			this._display = display;
			this._debug = debug;
			this._hasWarning = false;
			this._hasInfo = false;
			this._hasDebug = false;
			this._hasGRAlert = false;
			this._warningQueue = [];
			this._infoQueue = [];
			this._GRAlertQueue = [];
		}
		
		public function init() : void {
			var _local1:int = 10;
			var _local2:uint = uint(this._display.stage.stageWidth - _local1 * 2);
			var _local3:uint = uint(this._display.stage.stageHeight - _local1 * 2);
			var _local4:Panel = new Panel("analytics",_local2,_local3);
			_local4.alignement = Align.top;
			_local4.stickToEdge = false;
			_local4.title = "Google Analytics v" + GATracker.version;
			this._mainPanel = _local4;
			this.addToStage(_local4);
			this.bringToFront(_local4);
			if(this._debug.minimizedOnStart) {
				this._mainPanel.onToggle();
			}
			this.createVisualDebug();
			this._display.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKey,false,0,true);
		}
		
		public function destroy() : void {
			this._mainPanel.close();
			this._debug.layout = null;
		}
		
		private function onKey(event:KeyboardEvent = null) : void {
			switch(event.keyCode) {
				case this._debug.showHideKey:
					this._mainPanel.visible = !this._mainPanel.visible;
					break;
				case this._debug.destroyKey:
					this.destroy();
			}
		}
		
		private function _clearInfo(event:Event) : void {
			this._hasInfo = false;
			if(this._infoQueue.length > 0) {
				this.createInfo(this._infoQueue.shift());
			}
		}
		
		private function _clearWarning(event:Event) : void {
			this._hasWarning = false;
			if(this._warningQueue.length > 0) {
				this.createWarning(this._warningQueue.shift());
			}
		}
		
		private function _clearGRAlert(event:Event) : void {
			this._hasGRAlert = false;
			if(this._GRAlertQueue.length > 0) {
				this.createGIFRequestAlert.apply(this,this._GRAlertQueue.shift());
			}
		}
		
		private function _filterMaxChars(message:String, maxCharPerLine:int = 0) : String {
			var _local6:String = null;
			var _local3:String = "\n";
			var _local4:Array = [];
			var _local5:Array = message.split(_local3);
			if(maxCharPerLine == 0) {
				maxCharPerLine = this._maxCharPerLine;
			}
			var _local7:int = 0;
			while(_local7 < _local5.length) {
				_local6 = _local5[_local7];
				while(_local6.length > maxCharPerLine) {
					_local4.push(_local6.substr(0,maxCharPerLine));
					_local6 = _local6.substring(maxCharPerLine);
				}
				_local4.push(_local6);
				_local7++;
			}
			return _local4.join(_local3);
		}
		
		public function addToStage(visual:DisplayObject) : void {
			this._display.stage.addChild(visual);
		}
		
		public function addToPanel(name:String, visual:DisplayObject) : void {
			var _local4:Panel = null;
			var _local3:DisplayObject = this._display.stage.getChildByName(name);
			if(_local3) {
				_local4 = _local3 as Panel;
				_local4.addData(visual);
			} else {
				trace("panel \"" + name + "\" not found");
			}
		}
		
		public function bringToFront(visual:DisplayObject) : void {
			this._display.stage.setChildIndex(visual,this._display.stage.numChildren - 1);
		}
		
		public function isAvailable() : Boolean {
			return this._display.stage != null;
		}
		
		public function createVisualDebug() : void {
			if(!this.visualDebug) {
				this.visualDebug = new Debug();
				this.visualDebug.alignement = Align.bottom;
				this.visualDebug.stickToEdge = true;
				this.addToPanel("analytics",this.visualDebug);
				this._hasDebug = true;
			}
		}
		
		public function createPanel(name:String, width:uint, height:uint) : void {
			var _local4:Panel = new Panel(name,width,height);
			_local4.alignement = Align.center;
			_local4.stickToEdge = false;
			this.addToStage(_local4);
			this.bringToFront(_local4);
		}
		
		public function createInfo(message:String) : void {
			if(this._hasInfo || !this.isAvailable()) {
				this._infoQueue.push(message);
				return;
			}
			message = this._filterMaxChars(message);
			this._hasInfo = true;
			var _local2:Info = new Info(message,this._debug.infoTimeout);
			this.addToPanel("analytics",_local2);
			_local2.addEventListener(Event.REMOVED_FROM_STAGE,this._clearInfo,false,0,true);
			if(this._hasDebug) {
				this.visualDebug.write(message);
			}
		}
		
		public function createWarning(message:String) : void {
			if(this._hasWarning || !this.isAvailable()) {
				this._warningQueue.push(message);
				return;
			}
			message = this._filterMaxChars(message);
			this._hasWarning = true;
			var _local2:Warning = new Warning(message,this._debug.warningTimeout);
			this.addToPanel("analytics",_local2);
			_local2.addEventListener(Event.REMOVED_FROM_STAGE,this._clearWarning,false,0,true);
			if(this._hasDebug) {
				this.visualDebug.writeBold(message);
			}
		}
		
		public function createAlert(message:String) : void {
			message = this._filterMaxChars(message);
			var _local2:Alert = new Alert(message,[new AlertAction("Close","close","close")]);
			this.addToPanel("analytics",_local2);
			if(this._hasDebug) {
				this.visualDebug.writeBold(message);
			}
		}
		
		public function createFailureAlert(message:String) : void {
			var _local2:AlertAction = null;
			if(this._debug.verbose) {
				message = this._filterMaxChars(message);
				_local2 = new AlertAction("Close","close","close");
			} else {
				_local2 = new AlertAction("X","close","close");
			}
			var _local3:Alert = new FailureAlert(this._debug,message,[_local2]);
			this.addToPanel("analytics",_local3);
			if(this._hasDebug) {
				if(this._debug.verbose) {
					message = message.split("\n").join("");
					message = this._filterMaxChars(message,66);
				}
				this.visualDebug.writeBold(message);
			}
		}
		
		public function createSuccessAlert(message:String) : void {
			var _local2:AlertAction = null;
			if(this._debug.verbose) {
				message = this._filterMaxChars(message);
				_local2 = new AlertAction("Close","close","close");
			} else {
				_local2 = new AlertAction("X","close","close");
			}
			var _local3:Alert = new SuccessAlert(this._debug,message,[_local2]);
			this.addToPanel("analytics",_local3);
			if(this._hasDebug) {
				if(this._debug.verbose) {
					message = message.split("\n").join("");
					message = this._filterMaxChars(message,66);
				}
				this.visualDebug.writeBold(message);
			}
		}
		
		public function createGIFRequestAlert(message:String, request:URLRequest, ref:GIFRequest) : void {
			var f:Function;
			var gra:GIFRequestAlert;
			if(this._hasGRAlert) {
				this._GRAlertQueue.push([message,request,ref]);
				return;
			}
			this._hasGRAlert = true;
			f = function():void {
				ref.sendRequest(request);
			};
			message = this._filterMaxChars(message);
			gra = new GIFRequestAlert(message,[new AlertAction("OK","ok",f),new AlertAction("Cancel","cancel","close")]);
			this.addToPanel("analytics",gra);
			gra.addEventListener(Event.REMOVED_FROM_STAGE,this._clearGRAlert,false,0,true);
			if(this._hasDebug) {
				if(this._debug.verbose) {
					message = message.split("\n").join("");
					message = this._filterMaxChars(message,66);
				}
				this.visualDebug.write(message);
			}
		}
	}
}

