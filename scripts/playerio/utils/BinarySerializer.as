package playerio.utils {
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import playerio.Message;
	import playerio.MessageEvent;
	
	public class BinarySerializer extends EventDispatcher {
		public static const ON_MESSAGE:String = "onmessage";
		
		public static const ShortStringPattern:uint = parseInt("11000000",2);
		
		public static const ShortUnsignedIntPattern:uint = parseInt("10000000",2);
		
		public static const ShortByteArrayPattern:uint = parseInt("01000000",2);
		
		public static const UnsignedLongPattern:uint = parseInt("00111000",2);
		
		public static const LongPattern:uint = parseInt("00110000",2);
		
		public static const ByteArrayPattern:uint = parseInt("00010000",2);
		
		public static const StringPattern:uint = parseInt("00001100",2);
		
		public static const UnsignedIntPattern:uint = parseInt("00001000",2);
		
		public static const IntPattern:uint = parseInt("00000100",2);
		
		public static const DoublePattern:uint = parseInt("00000011",2);
		
		public static const FloatPattern:uint = parseInt("00000010",2);
		
		public static const BooleanTruePattern:uint = parseInt("00000001",2);
		
		public static const BooleanFalsePattern:uint = parseInt("00000000",2);
		
		private var tokens:Array = [];
		
		private var tokenBuilder:TokenBuilder = null;
		
		private var messageBuilder:MessageBuilder = null;
		
		public function BinarySerializer() {
			super();
			tokens.push(new Token(ShortStringPattern,readUnsignedInt,function(param1:ByteArray):String {
				return param1.readUTFBytes(param1.length);
			}));
			tokens.push(new Token(ShortUnsignedIntPattern,readUnsignedInt));
			tokens.push(new Token(ShortByteArrayPattern,readUnsignedInt,function(param1:ByteArray):ByteArray {
				return param1;
			}));
			tokens.push(new Token(UnsignedLongPattern,readLength,function():int {
				trace("Longs are unsupported in ActionScript, returning (int)0.");
				return 0;
			}));
			tokens.push(new Token(LongPattern,readLength,function():int {
				trace("Longs are unsupported in ActionScript, returning (int)0.");
				return 0;
			}));
			tokens.push(new Token(ByteArrayPattern,readLength,readUnsignedInt,function(param1:ByteArray):ByteArray {
				return param1;
			}));
			tokens.push(new Token(StringPattern,readLength,readUnsignedInt,function(param1:ByteArray):String {
				return param1.readUTFBytes(param1.length);
			}));
			tokens.push(new Token(UnsignedIntPattern,readLength,readUnsignedInt));
			tokens.push(new Token(IntPattern,readLength,function(param1:ByteArray):int {
				return readUnsignedInt(param1);
			}));
			tokens.push(new Token(DoublePattern,function(param1:ByteArray):int {
				return 8;
			},function(param1:ByteArray):Number {
				return param1.readDouble();
			}));
			tokens.push(new Token(FloatPattern,function(param1:ByteArray):int {
				return 4;
			},function(param1:ByteArray):Number {
				return param1.readFloat();
			}));
			tokens.push(new Token(BooleanTruePattern,function(param1:ByteArray):Boolean {
				return true;
			}));
			tokens.push(new Token(BooleanFalsePattern,function(param1:ByteArray):Boolean {
				return false;
			}));
		}
		
		private function readLength(b:ByteArray) : uint {
			return readUnsignedInt(b) + 1;
		}
		
		private function readUnsignedInt(b:ByteArray) : uint {
			var _local2:uint = 0;
			while(b.position < b.length) {
				_local2 = uint(_local2 << 8 | b.readUnsignedByte());
			}
			return _local2;
		}
		
		public function AddByte(b:uint) : void {
			if(tokenBuilder == null) {
				for each(var _local2 in tokens) {
					if((_local2.Type & b) == _local2.Type) {
						tokenBuilder = new TokenBuilder(_local2);
						tokenBuilder.addEventListener("onValue",onValue);
						tokenBuilder.AddByte(b & ~_local2.Type);
						break;
					}
				}
			} else {
				tokenBuilder.AddByte(b);
			}
		}
		
		public function AddBytes(b:ByteArray) : void {
			var _local2:int = 0;
			b.position = 0;
			_local2 = 0;
			while(_local2 < b.length) {
				AddByte(b.readUnsignedByte());
				_local2++;
			}
		}
		
		public function Serialize(o:*) : ByteArray {
			if(o is Number || o is Boolean || o is String || o is ByteArray) {
				return serialize(o);
			}
			throw new Error(typeof o + " is not yet supported");
		}
		
		public function SerializeMessage(m:Message) : ByteArray {
			var t:ByteArray;
			var ret:ByteArray = new ByteArray();
			var l:ByteArray = serialize(m.length);
			ret.writeBytes(l,0,l.length);
			t = serialize(m.type);
			ret.writeBytes(t,0,t.length);
			m.clone({"Add":function(param1:*):void {
				var _local2:ByteArray = Serialize(param1);
				ret.writeBytes(_local2,0,_local2.length);
			}});
			ret.position = 0;
			return ret;
		}
		
		private function serialize(o:*) : ByteArray {
			var _local4:ByteArray = null;
			var _local2:ByteArray = null;
			var _local3:ByteArray = new ByteArray();
			if(o is String) {
				_local2 = new ByteArray();
				_local2.writeUTFBytes(o);
				_local2.length < 64 ? _local3.writeByte(ShortStringPattern | _local2.length) : writeHeader(StringPattern,_local3,getUIntBytes(_local2.length));
				_local3.writeUTFBytes(o);
			}
			if(o is Boolean) {
				_local3.writeByte(o == true ? BooleanTruePattern : BooleanFalsePattern);
			}
			if(o is ByteArray) {
				o.position = 0;
				o.length < 64 ? _local3.writeByte(ShortByteArrayPattern | o.length) : writeHeader(ByteArrayPattern,_local3,getUIntBytes(o.length));
				_local3.writeBytes(o,0,o.length);
			}
			if(o is Number) {
				_local4 = new ByteArray();
				_local4.writeInt(o);
				_local4.position = 0;
				if(_local4.readInt() == o) {
					o >= 0 && o < 64 ? _local3.writeByte(ShortUnsignedIntPattern | o) : writeHeader(IntPattern,_local3,trim(_local4));
				} else {
					_local4 = new ByteArray();
					_local4.writeUnsignedInt(o);
					_local4.position = 0;
					if(_local4.readUnsignedInt() == o) {
						writeHeader(UnsignedIntPattern,_local3,trim(_local4));
					} else {
						_local4 = new ByteArray();
						_local4.writeFloat(o);
						_local4.position = 0;
						if(_local4.readFloat() == o) {
							_local3.writeByte(FloatPattern);
							_local3.writeFloat(o);
						} else {
							_local3.writeByte(DoublePattern);
							_local3.writeDouble(o);
						}
					}
				}
			}
			_local3.position = 0;
			return _local3;
		}
		
		private function onMessage(m:MessageEvent) : void {
			messageBuilder.removeEventListener("onMessage",onMessage);
			messageBuilder = null;
			this.dispatchEvent(new MessageEvent("onMessage",m.message));
		}
		
		private function onValue(t:TokenEvent) : void {
			if(messageBuilder == null) {
				messageBuilder = new MessageBuilder();
				messageBuilder.addEventListener("onMessage",onMessage);
			}
			tokenBuilder.removeEventListener("onValue",onValue);
			tokenBuilder = null;
			messageBuilder.AddValue(t.Value);
		}
		
		private function writeHeader(head:int, t:ByteArray, l:ByteArray) : void {
			t.writeByte(head | l.length - 1);
			l.position = 0;
			t.writeBytes(l,0,l.length);
		}
		
		private function getUIntBytes(l:int) : ByteArray {
			var _local2:ByteArray = new ByteArray();
			_local2.writeUnsignedInt(l);
			return trim(_local2);
		}
		
		private function trim(b:ByteArray) : ByteArray {
			var _local3:int = 0;
			var _local2:ByteArray = new ByteArray();
			_local2.position = 0;
			b.position = 0;
			_local3 = 0;
			while(_local3 < b.length) {
				if(b.readUnsignedByte() != 0) {
					_local2.writeBytes(b,_local3,b.length - _local3);
					return _local2;
				}
				_local3++;
			}
			return _local2;
		}
	}
}

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import playerio.Message;
import playerio.MessageEvent;

class MessageBuilder extends EventDispatcher {
	private var message:Message;
	
	private var length:int = -1;
	
	public function MessageBuilder() {
		super();
		this.message = new Message("");
	}
	
	public function AddValue(d:*) : void {
		if(length == -1) {
			length = d;
		} else {
			if(message.type == "") {
				message.type = d;
			} else {
				message.add(d);
			}
			if(length == message.length) {
				dispatchEvent(new MessageEvent("onMessage",message));
			}
		}
	}
}

class TokenBuilder extends EventDispatcher {
	private var token:Token;
	
	private var offset:uint = 0;
	
	private var length:uint = 1;
	
	private var tba:ByteArray = new ByteArray();
	
	public function TokenBuilder(token:Token) {
		super();
		this.token = token;
	}
	
	public function AddByte(b:int) : void {
		tba.writeByte(b);
		if(tba.length == length) {
			tba.position = 0;
			if(offset == token.length - 1) {
				dispatchEvent(new TokenEvent("onValue",token.Handlers[token.Handlers.length - 1](tba)));
			} else {
				length = token.Handlers[offset](tba);
				tba = new ByteArray();
				offset++;
				if(length == 0) {
					dispatchEvent(new TokenEvent("onValue",token.Handlers[token.Handlers.length - 1](tba)));
				}
			}
		}
	}
}

class Token {
	public var Handlers:Array;
	
	public var Type:uint;
	
	public function Token(type:uint, ... rest) {
		var _local3:int = 0;
		Handlers = [];
		super();
		Type = type;
		_local3 = 0;
		while(_local3 < rest.length) {
			Handlers.push(rest[_local3]);
			_local3++;
		}
	}
	
	public function get length() : int {
		return Handlers.length;
	}
}

class TokenEvent extends Event {
	public static const ON_VALUE:String = "onValue";
	
	public var Value:*;
	
	public function TokenEvent(type:String, value:*) {
		this.Value = value;
		super(type);
	}
	
	override public function clone() : Event {
		return new TokenEvent(type,Value);
	}
}
