package facebook {
	internal class JSON2 {
		public function JSON2() {
			super();
		}
		
		public static function deserialize(source:String) : * {
			source = new String(source);
			var at:Number = 0;
			var ch:String = " ";
			var _isDigit:Function = function(param1:String):* {
				return "0" <= param1 && param1 <= "9";
			};
			var _isHexDigit:Function = function(param1:String):* {
				return _isDigit(param1) || "A" <= param1 && param1 <= "F" || "a" <= param1 && param1 <= "f";
			};
			var _error:Function = function(param1:String):void {
				throw new Error(param1,at - 1);
			};
			var _next:Function = function():* {
				ch = source.charAt(at);
				at += 1;
				return ch;
			};
			var _white:Function = function():void {
				while(ch) {
					if(ch <= " ") {
						_next();
					} else {
						if(ch != "/") {
							break;
						}
						switch(_next()) {
							case "/":
								while(_next() && ch != "\n" && ch != "\r") {
								}
								break;
							case "*":
								_next();
								while(true) {
									if(ch) {
										if(ch == "*") {
											if(_next() == "/") {
												break;
											}
										} else {
											_next();
										}
									} else {
										_error("Unterminated Comment");
									}
								}
								_next();
								break;
							default:
								_error("Syntax Error");
						}
					}
				}
			};
			var _string:Function = function():* {
				var _local2:* = undefined;
				var _local3:* = undefined;
				var _local5:* = "";
				var _local1:* = "";
				var _local4:Boolean = false;
				if(ch == "\"") {
					while(Boolean(_next())) {
						if(ch == "\"") {
							_next();
							return _local1;
						}
						if(ch == "\\") {
							switch(_next()) {
								case "b":
									_local1 += "\b";
									break;
								case "f":
									_local1 += "\f";
									break;
								case "n":
									_local1 += "\n";
									break;
								case "r":
									_local1 += "\r";
									break;
								case "t":
									_local1 += "\t";
									break;
								case "u":
									_local3 = 0;
									_local5 = 0;
									while(_local5 < 4) {
										_local2 = parseInt(_next(),16);
										if(!isFinite(_local2)) {
											_local4 = true;
											break;
										}
										_local3 = _local3 * 16 + _local2;
										_local5 += 1;
									}
									if(_local4) {
										_local4 = false;
										break;
									}
									_local1 += String.fromCharCode(_local3);
									break;
								default:
									_local1 += ch;
							}
						} else {
							_local1 += ch;
						}
					}
				}
				_error("Bad String");
				return null;
			};
			var _array:Function = function():* {
				var _local1:Array = [];
				if(ch == "[") {
					_next();
					_white();
					if(ch == "]") {
						_next();
						return _local1;
					}
					while(ch) {
						_local1.push(_value());
						_white();
						if(ch == "]") {
							_next();
							return _local1;
						}
						if(ch != ",") {
							break;
						}
						_next();
						_white();
					}
				}
				_error("Bad Array");
				return null;
			};
			var _object:Function = function():* {
				var _local1:* = {};
				var _local2:* = {};
				if(ch == "{") {
					_next();
					_white();
					if(ch == "}") {
						_next();
						return _local2;
					}
					while(ch) {
						_local1 = _string();
						_white();
						if(ch != ":") {
							break;
						}
						_next();
						_local2[_local1] = _value();
						_white();
						if(ch == "}") {
							_next();
							return _local2;
						}
						if(ch != ",") {
							break;
						}
						_next();
						_white();
					}
				}
				_error("Bad Object");
			};
			var _number:Function = function():* {
				var _local1:* = undefined;
				var _local4:* = "";
				var _local3:String = "";
				var _local2:String = "";
				if(ch == "-") {
					_local2 = _local4 = "-";
					_next();
				}
				if(ch == "0") {
					_next();
					if(ch == "x" || ch == "X") {
						_next();
						while(Boolean(_isHexDigit(ch))) {
							_local3 += ch;
							_next();
						}
						if(_local3 != "") {
							return Number(_local2 + "0x" + _local3);
						}
						_error("mal formed Hexadecimal");
					} else {
						_local4 += "0";
					}
				}
				while(Boolean(_isDigit(ch))) {
					_local4 += ch;
					_next();
				}
				if(ch == ".") {
					_local4 += ".";
					while(_next() && ch >= "0" && ch <= "9") {
						_local4 += ch;
					}
				}
				_local1 = 1 * _local4;
				if(!isFinite(_local1)) {
					_error("Bad Number");
					return NaN;
				}
				return _local1;
			};
			var _word:Function = function():* {
				switch(ch) {
					case "t":
						if(_next() == "r" && _next() == "u" && _next() == "e") {
							_next();
							return true;
						}
						break;
					case "f":
						if(_next() == "a" && _next() == "l" && _next() == "s" && _next() == "e") {
							_next();
							return false;
						}
						break;
					case "n":
						if(_next() == "u" && _next() == "l" && _next() == "l") {
							_next();
							return null;
						}
						break;
				}
				_error("Syntax Error");
				return null;
			};
			var _value:Function = function():* {
				_white();
				switch(ch) {
					case "{":
						return _object();
					case "[":
						return _array();
					case "\"":
						return _string();
					case "-":
						return _number();
					default:
						return ch >= "0" && ch <= "9" ? _number() : _word();
				}
			};
			return _value();
		}
		
		public static function serialize(o:*) : String {
			var _local2:String = null;
			var _local7:Number = NaN;
			var _local8:Number = NaN;
			var _local5:* = undefined;
			var _local4:Number = NaN;
			var _local3:String = "";
			switch(typeof o) {
				case "object":
					if(o) {
						if(o is Array) {
							_local8 = Number(o.length);
							_local7 = 0;
							while(_local7 < _local8) {
								_local5 = serialize(o[_local7]);
								if(_local3) {
									_local3 += ",";
								}
								_local3 += _local5;
								_local7++;
							}
							return "[" + _local3 + "]";
						}
						if(typeof o.toString != "undefined") {
							for(var _local6 in o) {
								_local5 = o[_local6];
								if(typeof _local5 != "undefined" && typeof _local5 != "function") {
									_local5 = serialize(_local5);
									if(_local3) {
										_local3 += ",";
									}
									_local3 += serialize(_local6) + ":" + _local5;
								}
							}
							return "{" + _local3 + "}";
						}
					}
					return "null";
				case "number":
					return isFinite(o) ? o : "null";
				case "string":
					_local8 = Number(o.length);
					_local3 = "\"";
					_local7 = 0;
					while(_local7 < _local8) {
						_local2 = o.charAt(_local7);
						if(_local2 >= " ") {
							if(_local2 == "\\" || _local2 == "\"") {
								_local3 += "\\";
							}
							_local3 += _local2;
						} else {
							switch(_local2) {
								case "\b":
									_local3 += "\\b";
									break;
								case "\f":
									_local3 += "\\f";
									break;
								case "\n":
									_local3 += "\\n";
									break;
								case "\r":
									_local3 += "\\r";
									break;
								case "\t":
									_local3 += "\\t";
									break;
								default:
									_local4 = Number(_local2.charCodeAt());
									_local3 += "\\u00" + Math.floor(_local4 / 16).toString(16) + (_local4 % 16).toString(16);
							}
						}
						_local7 += 1;
					}
					return _local3 + "\"";
				case "boolean":
					return o;
				default:
					return "null";
			}
		}
	}
}

