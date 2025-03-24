package com.adobe.serialization.json {
	public class JSONTokenizer {
		private var strict:Boolean;
		
		private var obj:Object;
		
		private var jsonString:String;
		
		private var loc:int;
		
		private var ch:String;
		
		private const controlCharsRegExp:RegExp = /[\x00-\x1F]/;
		
		public function JSONTokenizer(s:String, strict:Boolean) {
			super();
			jsonString = s;
			this.strict = strict;
			loc = 0;
			nextChar();
		}
		
		public function getNextToken() : JSONToken {
			var _local1:String = null;
			var _local3:String = null;
			var _local2:String = null;
			var _local5:String = null;
			var _local4:JSONToken = null;
			skipIgnored();
			switch(ch) {
				case "{":
					_local4 = JSONToken.create(1,ch);
					nextChar();
					break;
				case "}":
					_local4 = JSONToken.create(2,ch);
					nextChar();
					break;
				case "[":
					_local4 = JSONToken.create(3,ch);
					nextChar();
					break;
				case "]":
					_local4 = JSONToken.create(4,ch);
					nextChar();
					break;
				case ",":
					_local4 = JSONToken.create(0,ch);
					nextChar();
					break;
				case ":":
					_local4 = JSONToken.create(6,ch);
					nextChar();
					break;
				case "t":
					_local1 = "t" + nextChar() + nextChar() + nextChar();
					if(_local1 == "true") {
						_local4 = JSONToken.create(7,true);
						nextChar();
					} else {
						parseError("Expecting \'true\' but found " + _local1);
					}
					break;
				case "f":
					_local3 = "f" + nextChar() + nextChar() + nextChar() + nextChar();
					if(_local3 == "false") {
						_local4 = JSONToken.create(8,false);
						nextChar();
					} else {
						parseError("Expecting \'false\' but found " + _local3);
					}
					break;
				case "n":
					_local2 = "n" + nextChar() + nextChar() + nextChar();
					if(_local2 == "null") {
						_local4 = JSONToken.create(9,null);
						nextChar();
					} else {
						parseError("Expecting \'null\' but found " + _local2);
					}
					break;
				case "N":
					_local5 = "N" + nextChar() + nextChar();
					if(_local5 == "NaN") {
						_local4 = JSONToken.create(12,NaN);
						nextChar();
					} else {
						parseError("Expecting \'NaN\' but found " + _local5);
					}
					break;
				case "\"":
					_local4 = readString();
					break;
				default:
					if(isDigit(ch) || ch == "-") {
						_local4 = readNumber();
					} else if(ch == "") {
						_local4 = null;
					} else {
						parseError("Unexpected " + ch + " encountered");
					}
			}
			return _local4;
		}
		
		final private function readString() : JSONToken {
			var _local2:int = 0;
			var _local1:int = 0;
			var _local3:int = loc;
			while(true) {
				_local3 = int(jsonString.indexOf("\"",_local3));
				if(_local3 >= 0) {
					_local2 = 0;
					_local1 = _local3 - 1;
					while(jsonString.charAt(_local1) == "\\") {
						_local2++;
						_local1--;
					}
					if((_local2 & 1) == 0) {
						break;
					}
					_local3++;
				} else {
					parseError("Unterminated string literal");
				}
			}
			var _local4:JSONToken = JSONToken.create(10,unescapeString(jsonString.substr(loc,_local3 - loc)));
			loc = _local3 + 1;
			nextChar();
			return _local4;
		}
		
		public function unescapeString(input:String) : String {
			var _local8:String = null;
			var _local6:String = null;
			var _local4:int = 0;
			var _local7:* = 0;
			var _local5:String = null;
			if(strict && Boolean(controlCharsRegExp.test(input))) {
				parseError("String contains unescaped control character (0x00-0x1F)");
			}
			var _local2:String = "";
			var _local9:int = 0;
			var _local10:* = 0;
			var _local3:int = input.length;
			do {
				_local9 = int(input.indexOf("\\",_local10));
				if(_local9 < 0) {
					_local2 += input.substr(_local10);
					break;
				}
				_local2 += input.substr(_local10,_local9 - _local10);
				_local10 = _local9 + 2;
				switch(_local8 = input.charAt(_local9 + 1)) {
					case "\"":
						_local2 += _local8;
						break;
					case "\\":
						_local2 += _local8;
						break;
					case "n":
						_local2 += "\n";
						break;
					case "r":
						_local2 += "\r";
						break;
					case "t":
						_local2 += "\t";
						break;
					case "u":
						_local6 = "";
						_local4 = _local10 + 4;
						if(_local4 > _local3) {
							parseError("Unexpected end of input.  Expecting 4 hex digits after \\u.");
						}
						_local7 = _local10;
						while(_local7 < _local4) {
							_local5 = input.charAt(_local7);
							if(!isHexDigit(_local5)) {
								parseError("Excepted a hex digit, but found: " + _local5);
							}
							_local6 += _local5;
							_local7++;
						}
						_local2 += String.fromCharCode(parseInt(_local6,16));
						_local10 = _local4;
						break;
					case "f":
						_local2 += "\f";
						break;
					case "/":
						_local2 += "/";
						break;
					case "b":
						_local2 += "\b";
						break;
					default:
						_local2 += "\\" + _local8;
				}
			}
			while(_local10 < _local3);
			
			return _local2;
		}
		
		final private function readNumber() : JSONToken {
			var _local1:String = "";
			if(ch == "-") {
				_local1 += "-";
				nextChar();
			}
			if(!isDigit(ch)) {
				parseError("Expecting a digit");
			}
			if(ch == "0") {
				_local1 += ch;
				nextChar();
				if(isDigit(ch)) {
					parseError("A digit cannot immediately follow 0");
				} else if(!strict && ch == "x") {
					_local1 += ch;
					nextChar();
					if(isHexDigit(ch)) {
						_local1 += ch;
						nextChar();
					} else {
						parseError("Number in hex format require at least one hex digit after \"0x\"");
					}
					while(isHexDigit(ch)) {
						_local1 += ch;
						nextChar();
					}
				}
			} else {
				while(isDigit(ch)) {
					_local1 += ch;
					nextChar();
				}
			}
			if(ch == ".") {
				_local1 += ".";
				nextChar();
				if(!isDigit(ch)) {
					parseError("Expecting a digit");
				}
				while(isDigit(ch)) {
					_local1 += ch;
					nextChar();
				}
			}
			if(ch == "e" || ch == "E") {
				_local1 += "e";
				nextChar();
				if(ch == "+" || ch == "-") {
					_local1 += ch;
					nextChar();
				}
				if(!isDigit(ch)) {
					parseError("Scientific notation number needs exponent value");
				}
				while(isDigit(ch)) {
					_local1 += ch;
					nextChar();
				}
			}
			var _local2:Number = Number(_local1);
			if(isFinite(_local2) && !isNaN(_local2)) {
				return JSONToken.create(11,_local2);
			}
			parseError("Number " + _local2 + " is not valid!");
			return null;
		}
		
		final private function nextChar() : String {
			return ch = jsonString.charAt(loc++);
		}
		
		final private function skipIgnored() : void {
			var _local1:int = 0;
			do {
				_local1 = loc;
				skipWhite();
				skipComments();
			}
			while(_local1 != loc);
			
		}
		
		private function skipComments() : void {
			if(ch == "/") {
				nextChar();
				switch(ch) {
					case "/":
						do {
							nextChar();
						}
						while(ch != "\n" && ch != "");
						
						nextChar();
						break;
					case "*":
						nextChar();
						while(true) {
							if(ch == "*") {
								nextChar();
								if(ch == "/") {
									break;
								}
							} else {
								nextChar();
							}
							if(ch == "") {
								parseError("Multi-line comment not closed");
							}
						}
						nextChar();
						break;
					default:
						parseError("Unexpected " + ch + " encountered (expecting \'/\' or \'*\' )");
				}
			}
		}
		
		final private function skipWhite() : void {
			while(isWhiteSpace(ch)) {
				nextChar();
			}
		}
		
		final private function isWhiteSpace(ch:String) : Boolean {
			if(ch == " " || ch == "\t" || ch == "\n" || ch == "\r") {
				return true;
			}
			if(!strict && ch.charCodeAt(0) == 160) {
				return true;
			}
			return false;
		}
		
		final private function isDigit(ch:String) : Boolean {
			return ch >= "0" && ch <= "9";
		}
		
		final private function isHexDigit(ch:String) : Boolean {
			return isDigit(ch) || ch >= "A" && ch <= "F" || ch >= "a" && ch <= "f";
		}
		
		final public function parseError(message:String) : void {
			throw new JSONParseError(message,loc,jsonString);
		}
	}
}

