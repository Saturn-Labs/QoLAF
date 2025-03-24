package com.google.analytics.debug {
	public class SuccessAlert extends Alert {
		public function SuccessAlert(debug:DebugConfiguration, text:String, actions:Array) {
			var _local4:Align = Align.bottomLeft;
			var _local5:Boolean = true;
			var _local6:Boolean = false;
			if(debug.verbose) {
				text = "<u><span class=\"uiAlertTitle\">Success</span>" + spaces(18) + "</u>\n\n" + text;
				_local4 = Align.center;
				_local5 = false;
				_local6 = true;
			}
			super(text,actions,"uiSuccess",Style.successColor,_local4,_local5,_local6);
		}
	}
}

