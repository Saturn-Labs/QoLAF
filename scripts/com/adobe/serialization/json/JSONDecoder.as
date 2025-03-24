package com.adobe.serialization.json {
	public class JSONDecoder {
		private var strict:Boolean;
		
		private var value:*;
		
		private var tokenizer:JSONTokenizer;
		
		private var token:JSONToken;
		
		public function JSONDecoder(s:String, strict:Boolean) {
			super();
			this.strict = strict;
			tokenizer = new JSONTokenizer(s,strict);
			nextToken();
			value = parseValue();
			if(strict && nextToken() != null) {
				tokenizer.parseError("Unexpected characters left in input stream");
			}
		}
		
		public function getValue() : * {
			return value;
		}
		
		final private function nextToken() : JSONToken {
			return token = tokenizer.getNextToken();
		}
		
		final private function nextValidToken() : JSONToken {
			token = tokenizer.getNextToken();
			checkValidToken();
			return token;
		}
		
		final private function checkValidToken() : void {
			if(token == null) {
				tokenizer.parseError("Unexpected end of input");
			}
		}
		
		final private function parseArray() : Array {
			var _local1:Array = [];
			nextValidToken();
			if(token.type == 4) {
				return _local1;
			}
			if(!strict && token.type == 0) {
				nextValidToken();
				if(token.type == 4) {
					return _local1;
				}
				tokenizer.parseError("Leading commas are not supported.  Expecting \']\' but found " + token.value);
			}
			while(true) {
				_local1.push(parseValue());
				nextValidToken();
				if(token.type == 4) {
					break;
				}
				if(token.type == 0) {
					nextToken();
					if(!strict) {
						checkValidToken();
						if(token.type == 4) {
							return _local1;
						}
					}
				} else {
					tokenizer.parseError("Expecting ] or , but found " + token.value);
				}
			}
			return _local1;
		}
		
		final private function parseObject() : Object {
			var _local1:String = null;
			var _local2:Object = {};
			nextValidToken();
			if(token.type == 2) {
				return _local2;
			}
			if(!strict && token.type == 0) {
				nextValidToken();
				if(token.type == 2) {
					return _local2;
				}
				tokenizer.parseError("Leading commas are not supported.  Expecting \'}\' but found " + token.value);
			}
			while(true) {
				if(token.type == 10) {
					_local1 = String(token.value);
					nextValidToken();
					if(token.type == 6) {
						nextToken();
						_local2[_local1] = parseValue();
						nextValidToken();
						if(token.type == 2) {
							break;
						}
						if(token.type == 0) {
							nextToken();
							if(!strict) {
								checkValidToken();
								if(token.type == 2) {
									return _local2;
								}
							}
						} else {
							tokenizer.parseError("Expecting } or , but found " + token.value);
						}
					} else {
						tokenizer.parseError("Expecting : but found " + token.value);
					}
				} else {
					tokenizer.parseError("Expecting string but found " + token.value);
				}
			}
			return _local2;
		}
		
		final private function parseValue() : Object {
			checkValidToken();
			switch(token.type - 1) {
				case 0:
					return parseObject();
				case 2:
					return parseArray();
				case 6:
				case 7:
				case 8:
				case 9:
				case 10:
					return token.value;
				case 11:
					if(!strict) {
						return token.value;
					}
					tokenizer.parseError("Unexpected " + token.value);
					break;
			}
			tokenizer.parseError("Unexpected " + token.value);
			return null;
		}
	}
}

