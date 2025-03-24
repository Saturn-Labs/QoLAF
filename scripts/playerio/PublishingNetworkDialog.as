package playerio {
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import mx.utils.UIDUtil;
	import playerio.generated.PlayerIOError;
	import playerio.utils.HTTPChannel;
	
	internal class PublishingNetworkDialog {
		private static var _addedCallbackGlue:Boolean = false;
		
		private static var _savedCallbacks:Object = {};
		
		public function PublishingNetworkDialog() {
			super();
		}
		
		public static function showDialog(dialog:String, arguments:Object, channel:HTTPChannel, callback:Function) : void {
			switch(Capabilities.playerType) {
				case "ActiveX":
				case "PlugIn":
					break;
				default:
					throw new playerio.generated.PlayerIOError("Cannot show the \'" + dialog + "\' dialog. Dialogs aren\'t supported in the current runtime environment:" + Capabilities.playerType,playerio.PlayerIOError.GeneralError.errorID);
			}
			javascriptDialog(dialog,arguments,channel == null ? null : channel.token,callback);
		}
		
		private static function javascriptDialog(dialog:String, arguments:Object, apiToken:String, callback:Function) : void {
			var _local5:String = null;
			if(!ExternalInterface.available) {
				throw new playerio.generated.PlayerIOError("ExternalInterface is not available!",0);
			}
			arguments.__apitoken__ = apiToken;
			var _local7:String = UIDUtil.createUID().replace("-","").toLowerCase();
			_savedCallbacks[_local7] = callback;
			if(!_addedCallbackGlue) {
				ExternalInterface.addCallback("JavascriptPlayerIOCallback",javascriptPlayerIOCallback);
				_local5 = "";
				_local5 = _local5 + "window.__PlayerIO_Flash_Callback__ = function(callbackId, result){";
				_local5 = _local5 + "\nvar resultStr = \'A\';";
				_local5 = _local5 + "\nresult[\'__PlayerIO_Flash_CallbackId__\'] = callbackId;";
				_local5 = _local5 + "\nfor(var x in result){resultStr+=\':\'+x.length+\':\'+x+\':\'+result[x].length+\':\'+result[x]};";
				_local5 = _local5 + "\n\tfor(var tag in {embed:1,object:1}){";
				_local5 = _local5 + "\n\t\tvar list=document.getElementsByTagName(tag);";
				_local5 = _local5 + "\n\t\tfor(var i=0;i!=list.length;i++){";
				_local5 = _local5 + "\n\t\t\ttry{list[i].JavascriptPlayerIOCallback(resultStr)}catch(e){};";
				_local5 = _local5 + "\n\t\t}";
				_local5 = _local5 + "\n\t}";
				_local5 = _local5 + "\n}";
				ExternalInterface.call("eval",_local5);
				_addedCallbackGlue = true;
			}
			var _local6:String = "";
			var _local8:String = "function(r){window.__PlayerIO_Flash_Callback__(\'" + _local7 + "\',r)}";
			_local6 += "if(!document.getElementById(\'publishingnetwork\')){alert(\'When using publishingnetworklogin:auto, the containing html page must include the publishingnetwork.js script\')};";
			_local6 = _local6 + "\nif(window.PublishingNetwork){";
			_local6 = _local6 + ("\n\twindow.PublishingNetwork.dialog(" + jsonEncode(dialog) + "," + getJavascriptLiteral(arguments) + "," + _local8 + ");");
			_local6 = _local6 + "\n}else{";
			_local6 = _local6 + "\n\tif(!window.PublishingNetwork_WaitingCalls){window.PublishingNetwork_WaitingCalls=[]};";
			_local6 = _local6 + ("\n\twindow.PublishingNetwork_WaitingCalls.push([\'dialog\'," + jsonEncode(dialog) + "," + getJavascriptLiteral(arguments) + "," + _local8 + "])");
			_local6 = _local6 + "\n}";
			ExternalInterface.call("eval",_local6);
		}
		
		private static function getJavascriptLiteral(options:Object) : String {
			var _local2:String = "{";
			if(options != null) {
				for(var _local3 in options) {
					_local2 += _local2.length == 1 ? "" : ",";
					_local2 += jsonEncode(_local3);
					_local2 += ":";
					_local2 += jsonEncode(options[_local3]);
				}
			}
			return _local2 + "}";
		}
		
		private static function jsonEncode(input:String) : String {
			var _local5:String = null;
			var _local8:int = 0;
			var _local3:Boolean = false;
			var _local4:Array = null;
			var _local6:* = 0;
			var _local7:int = 0;
			var _local2:int = 0;
			if(input == null) {
				return "null";
			}
			_local5 = "";
			_local5 = _local5 + "\"";
			_local8 = 0;
			while(_local8 < input.length) {
				switch(input.charAt(_local8)) {
					case "\n":
						_local5 += "\\n";
						break;
					case "\r":
						_local5 += "\\r";
						break;
					case "\t":
						_local5 += "\\t";
						break;
					case "\"":
					case "\\":
						_local5 += "\\";
						_local5 = _local5 + input[_local8];
						break;
					case "\f":
						_local5 += "\\f";
						break;
					case "\b":
						_local5 += "\\b";
						break;
					default:
						if(input.charCodeAt(_local8) >= 32 && input.charCodeAt(_local8) <= 126) {
							_local5 += input.charAt(_local8);
						} else {
							_local3 = input.charCodeAt(_local8) < 55296 || input.charCodeAt(_local8) > 0xdfff;
							if(_local3) {
								_local4 = [];
								_local6 = int(input.charCodeAt(_local8));
								_local7 = 0;
								while(_local7 < 4) {
									_local2 = _local6 % 16;
									_local4[3 - _local7] = _local2 < 10 ? String.fromCharCode("0".charCodeAt(0) + _local2) : String.fromCharCode("A".charCodeAt(0) + (_local2 - 10));
									_local6 >>= 4;
									_local7++;
								}
								_local5 += "\\u";
								_local5 = _local5 + _local4.join();
							}
						}
						break;
				}
				_local8++;
			}
			return _local5 + "\"";
		}
		
		private static function javascriptPlayerIOCallback(input:String) : void {
			var _local4:Function = null;
			var _local2:Object = StringForm.decodeStringDictionary(input);
			var _local3:String = _local2["__PlayerIO_Flash_CallbackId__"];
			if(_savedCallbacks[_local3] != undefined) {
				_local4 = _savedCallbacks[_local3];
				delete _local2["__PlayerIO_Flash_CallbackId__"];
				delete _savedCallbacks[_local3];
				_local4(_local2);
			}
		}
	}
}

