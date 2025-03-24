package starling.rendering {
	import flash.display3D.VertexBuffer3D;
	import flash.utils.Dictionary;
	import starling.core.Starling;
	import starling.utils.StringUtil;
	
	public class VertexDataFormat {
		private static var sFormats:Dictionary = new Dictionary();
		
		private var _format:String;
		
		private var _vertexSize:int;
		
		private var _attributes:Vector.<VertexDataAttribute>;
		
		public function VertexDataFormat() {
			super();
			_attributes = new Vector.<VertexDataAttribute>();
		}
		
		public static function fromString(format:String) : VertexDataFormat {
			var _local2:VertexDataFormat = null;
			var _local3:String = null;
			if(format in sFormats) {
				return sFormats[format];
			}
			_local2 = new VertexDataFormat();
			_local2.parseFormat(format);
			_local3 = _local2._format;
			if(_local3 in sFormats) {
				_local2 = sFormats[_local3];
			}
			sFormats[format] = _local2;
			sFormats[_local3] = _local2;
			return _local2;
		}
		
		public function extend(format:String) : VertexDataFormat {
			return fromString(_format + ", " + format);
		}
		
		public function getSize(attrName:String) : int {
			return getAttribute(attrName).size;
		}
		
		public function getSizeIn32Bits(attrName:String) : int {
			return getAttribute(attrName).size / 4;
		}
		
		public function getOffset(attrName:String) : int {
			return getAttribute(attrName).offset;
		}
		
		public function getOffsetIn32Bits(attrName:String) : int {
			return getAttribute(attrName).offset / 4;
		}
		
		public function getFormat(attrName:String) : String {
			return getAttribute(attrName).format;
		}
		
		public function getName(attrIndex:int) : String {
			return _attributes[attrIndex].name;
		}
		
		public function hasAttribute(attrName:String) : Boolean {
			var _local3:int = 0;
			var _local2:int = int(_attributes.length);
			_local3 = 0;
			while(_local3 < _local2) {
				if(_attributes[_local3].name == attrName) {
					return true;
				}
				_local3++;
			}
			return false;
		}
		
		public function setVertexBufferAt(index:int, buffer:VertexBuffer3D, attrName:String) : void {
			var _local4:VertexDataAttribute = getAttribute(attrName);
			Starling.context.setVertexBufferAt(index,buffer,_local4.offset / 4,_local4.format);
		}
		
		private function parseFormat(format:String) : void {
			var _local5:Array = null;
			var _local4:int = 0;
			var _local3:int = 0;
			var _local6:int = 0;
			var _local10:String = null;
			var _local7:Array = null;
			var _local9:String = null;
			var _local2:String = null;
			var _local8:VertexDataAttribute = null;
			if(format != null && format != "") {
				_attributes.length = 0;
				_format = "";
				_local5 = format.split(",");
				_local4 = int(_local5.length);
				_local3 = 0;
				_local6 = 0;
				while(_local6 < _local4) {
					_local10 = _local5[_local6];
					_local7 = _local10.split(":");
					if(_local7.length != 2) {
						throw new ArgumentError("Missing colon: " + _local10);
					}
					_local9 = StringUtil.trim(_local7[0]);
					_local2 = StringUtil.trim(_local7[1]);
					if(_local9.length == 0 || _local2.length == 0) {
						throw new ArgumentError("Invalid format string: " + _local10);
					}
					_local8 = new VertexDataAttribute(_local9,_local2,_local3);
					_local3 += _local8.size;
					_format += (_local6 == 0 ? "" : ", ") + _local8.name + ":" + _local8.format;
					_attributes[_attributes.length] = _local8;
					_local6++;
				}
				_vertexSize = _local3;
			} else {
				_format = "";
			}
		}
		
		public function toString() : String {
			return _format;
		}
		
		internal function getAttribute(attrName:String) : VertexDataAttribute {
			var _local4:VertexDataAttribute = null;
			var _local3:int = 0;
			var _local2:int = int(_attributes.length);
			_local3 = 0;
			while(_local3 < _local2) {
				_local4 = _attributes[_local3];
				if(_local4.name == attrName) {
					return _local4;
				}
				_local3++;
			}
			return null;
		}
		
		internal function get attributes() : Vector.<VertexDataAttribute> {
			return _attributes;
		}
		
		public function get formatString() : String {
			return _format;
		}
		
		public function get vertexSize() : int {
			return _vertexSize;
		}
		
		public function get vertexSizeIn32Bits() : int {
			return _vertexSize / 4;
		}
		
		public function get numAttributes() : int {
			return _attributes.length;
		}
	}
}

