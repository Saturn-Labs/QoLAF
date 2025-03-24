package com.google.analytics.debug {
	public class FailureAlert extends Alert {
		public function FailureAlert(debug:DebugConfiguration, text:String, actions:Array) {
			var _local4:Align = Align.bottomLeft;
			var _local5:Boolean = true;
			var _local6:Boolean = false;
			if(debug.verbose) {
				text = "<u><span class=\"uiAlertTitle\">Failure</span>" + spaces(18) + "</u>\n\n" + text;
				_local4 = Align.center;
				_local5 = false;
				_local6 = true;
			}
			super(text,actions,"uiFailure",Style.failureColor,_local4,_local5,_local6);
		}
	}
}

