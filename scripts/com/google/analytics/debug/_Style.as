package com.google.analytics.debug {
	import flash.net.URLLoader;
	import flash.text.StyleSheet;
	
	public class _Style {
		private var _defaultSheet:String;
		
		private var _sheet:StyleSheet;
		
		private var _loader:URLLoader;
		
		public var backgroundColor:uint;
		
		public var borderColor:uint;
		
		public var infoColor:uint;
		
		public var roundedCorner:uint;
		
		public var warningColor:uint;
		
		public var alertColor:uint;
		
		public var successColor:uint;
		
		public var failureColor:uint;
		
		public function _Style() {
			super();
			this._sheet = new StyleSheet();
			this._loader = new URLLoader();
			this._init();
		}
		
		private function _init() : void {
			this._defaultSheet = "";
			this._defaultSheet += "a{text-decoration: underline;}\n";
			this._defaultSheet += ".uiLabel{color: #000000;font-family: Arial;font-size: 12;margin-left: 2;margin-right: 2;}\n";
			this._defaultSheet += ".uiWarning{color: #ffffff;font-family: Arial;font-size: 14;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
			this._defaultSheet += ".uiAlert{color: #ffffff;font-family: Arial;font-size: 14;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
			this._defaultSheet += ".uiInfo{color: #000000;font-family: Arial;font-size: 14;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
			this._defaultSheet += ".uiSuccess{color: #ffffff;font-family: Arial;font-size: 12;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
			this._defaultSheet += ".uiFailure{color: #ffffff;font-family: Arial;font-size: 12;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
			this._defaultSheet += ".uiAlertAction{color: #ffffff;text-align: center;font-family: Arial;font-size: 12;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
			this._defaultSheet += ".uiAlertTitle{color: #ffffff;font-family: Arial;font-size: 16;font-weight: bold;margin-left: 6;margin-right: 6;}\n";
			this._defaultSheet += "\n";
			this.roundedCorner = 6;
			this.backgroundColor = 0xcccccc;
			this.borderColor = 0x555555;
			this.infoColor = 0xffff99;
			this.alertColor = 0xffcc00;
			this.warningColor = 0xcc0000;
			this.successColor = 0xff00;
			this.failureColor = 0xff0000;
			this._parseSheet(this._defaultSheet);
		}
		
		private function _parseSheet(data:String) : void {
			this._sheet.parseCSS(data);
		}
		
		public function get sheet() : StyleSheet {
			return this._sheet;
		}
	}
}

