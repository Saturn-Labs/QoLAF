package starling.text {
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import starling.display.Image;
	import starling.display.MeshBatch;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.utils.StringUtil;
	
	public class BitmapFont implements ITextCompositor {
		public static const NATIVE_SIZE:int = -1;
		
		public static const MINI:String = "mini";
		
		private static const CHAR_SPACE:int = 32;
		
		private static const CHAR_TAB:int = 9;
		
		private static const CHAR_NEWLINE:int = 10;
		
		private static const CHAR_CARRIAGE_RETURN:int = 13;
		
		private static var sLines:Array = [];
		
		private static var sDefaultOptions:TextOptions = new TextOptions();
		
		private var _texture:Texture;
		
		private var _chars:Dictionary;
		
		private var _name:String;
		
		private var _size:Number;
		
		private var _lineHeight:Number;
		
		private var _baseline:Number;
		
		private var _offsetX:Number;
		
		private var _offsetY:Number;
		
		private var _padding:Number;
		
		private var _helperImage:Image;
		
		public function BitmapFont(texture:Texture = null, fontXml:XML = null) {
			super();
			if(texture == null && fontXml == null) {
				texture = MiniBitmapFont.texture;
				fontXml = MiniBitmapFont.xml;
			} else if(texture == null || fontXml == null) {
				throw new ArgumentError("Set both of the \'texture\' and \'fontXml\' arguments to valid objects or leave both of them null.");
			}
			_name = "unknown";
			_lineHeight = _size = _baseline = 14;
			_offsetX = _offsetY = _padding = 0;
			_texture = texture;
			_chars = new Dictionary();
			_helperImage = new Image(texture);
			parseFontXml(fontXml);
		}
		
		public function dispose() : void {
			if(_texture) {
				_texture.dispose();
			}
		}
		
		private function parseFontXml(fontXml:XML) : void {
			var _local14:int = 0;
			var _local4:Number = NaN;
			var _local2:Number = NaN;
			var _local13:Number = NaN;
			var _local15:Rectangle = null;
			var _local5:Texture = null;
			var _local8:BitmapChar = null;
			var _local16:int = 0;
			var _local10:int = 0;
			var _local3:Number = NaN;
			var _local6:Number = _texture.scale;
			var _local17:Rectangle = _texture.frame;
			var _local7:Number = !!_local17 ? _local17.x : 0;
			var _local9:Number = !!_local17 ? _local17.y : 0;
			_name = StringUtil.clean(fontXml.info.@face);
			_size = parseFloat(fontXml.info.@size) / _local6;
			_lineHeight = parseFloat(fontXml.common.@lineHeight) / _local6;
			_baseline = parseFloat(fontXml.common.@base) / _local6;
			if(fontXml.info.@smooth.toString() == "0") {
				smoothing = "none";
			}
			if(_size <= 0) {
				trace("[Starling] Warning: invalid font size in \'" + _name + "\' font.");
				_size = _size == 0 ? 16 : _size * -1;
			}
			for each(var _local11 in fontXml.chars.char) {
				_local14 = parseInt(_local11.@id);
				_local4 = parseFloat(_local11.@xoffset) / _local6;
				_local2 = parseFloat(_local11.@yoffset) / _local6;
				_local13 = parseFloat(_local11.@xadvance) / _local6;
				_local15 = new Rectangle();
				_local15.x = parseFloat(_local11.@x) / _local6 + _local7;
				_local15.y = parseFloat(_local11.@y) / _local6 + _local9;
				_local15.width = parseFloat(_local11.@width) / _local6;
				_local15.height = parseFloat(_local11.@height) / _local6;
				_local5 = Texture.fromTexture(_texture,_local15);
				_local8 = new BitmapChar(_local14,_local5,_local4,_local2,_local13);
				addChar(_local14,_local8);
			}
			for each(var _local12 in fontXml.kernings.kerning) {
				_local16 = parseInt(_local12.@first);
				_local10 = parseInt(_local12.@second);
				_local3 = parseFloat(_local12.@amount) / _local6;
				if(_local10 in _chars) {
					getChar(_local10).addKerning(_local16,_local3);
				}
			}
		}
		
		public function getChar(charID:int) : BitmapChar {
			return _chars[charID];
		}
		
		public function addChar(charID:int, bitmapChar:BitmapChar) : void {
			_chars[charID] = bitmapChar;
		}
		
		public function getCharIDs(out:Vector.<int> = null) : Vector.<int> {
			if(out == null) {
				out = new Vector.<int>(0);
			}
			for(var _local2 in _chars) {
				out[out.length] = _local2;
			}
			return out;
		}
		
		public function hasChars(text:String) : Boolean {
			var _local2:int = 0;
			var _local3:int = 0;
			if(text == null) {
				return true;
			}
			var _local4:int = text.length;
			_local3 = 0;
			while(_local3 < _local4) {
				_local2 = int(text.charCodeAt(_local3));
				if(_local2 != 32 && _local2 != 9 && _local2 != 10 && _local2 != 13 && getChar(_local2) == null) {
					return false;
				}
				_local3++;
			}
			return true;
		}
		
		public function createSprite(width:Number, height:Number, text:String, format:TextFormat, options:TextOptions = null) : Sprite {
			var _local9:int = 0;
			var _local10:CharLocation = null;
			var _local8:Image = null;
			var _local6:Vector.<CharLocation> = arrangeChars(width,height,text,format,options);
			var _local12:int = int(_local6.length);
			var _local11:String = this.smoothing;
			var _local7:Sprite = new Sprite();
			_local9 = 0;
			while(_local9 < _local12) {
				_local10 = _local6[_local9];
				_local8 = _local10.char.createImage();
				_local8.x = _local10.x;
				_local8.y = _local10.y;
				_local8.scale = _local10.scale;
				_local8.color = format.color;
				_local8.textureSmoothing = _local11;
				_local7.addChild(_local8);
				_local9++;
			}
			CharLocation.rechargePool();
			return _local7;
		}
		
		public function fillMeshBatch(meshBatch:MeshBatch, width:Number, height:Number, text:String, format:TextFormat, options:TextOptions = null) : void {
			var _local8:int = 0;
			var _local9:CharLocation = null;
			var _local7:Vector.<CharLocation> = arrangeChars(width,height,text,format,options);
			var _local10:int = int(_local7.length);
			_helperImage.color = format.color;
			_local8 = 0;
			while(_local8 < _local10) {
				_local9 = _local7[_local8];
				_helperImage.texture = _local9.char.texture;
				_helperImage.readjustSize();
				_helperImage.x = _local9.x;
				_helperImage.y = _local9.y;
				_helperImage.scale = _local9.scale;
				meshBatch.addMesh(_helperImage);
				_local8++;
			}
			CharLocation.rechargePool();
		}
		
		public function clearMeshBatch(meshBatch:MeshBatch) : void {
			meshBatch.clear();
		}
		
		private function arrangeChars(width:Number, height:Number, text:String, format:TextFormat, options:TextOptions) : Vector.<CharLocation> {
			var _local38:CharLocation = null;
			var _local31:int = 0;
			var _local18:Number = NaN;
			var _local34:Number = NaN;
			var _local13:Number = NaN;
			var _local29:int = 0;
			var _local27:int = 0;
			var _local23:* = 0;
			var _local36:* = 0;
			var _local35:Number = NaN;
			var _local15:Number = NaN;
			var _local19:* = undefined;
			var _local33:Boolean = false;
			var _local24:int = 0;
			var _local37:BitmapChar = null;
			var _local32:int = 0;
			var _local14:int = 0;
			var _local12:* = undefined;
			var _local21:int = 0;
			var _local26:CharLocation = null;
			var _local30:Number = NaN;
			var _local22:int = 0;
			if(text == null || text.length == 0) {
				return CharLocation.vectorFromPool();
			}
			if(options == null) {
				options = sDefaultOptions;
			}
			var _local6:Boolean = format.kerning;
			var _local10:Number = format.leading;
			var _local8:String = format.horizontalAlign;
			var _local16:String = format.verticalAlign;
			var _local39:Number = format.size;
			var _local17:Boolean = options.autoScale;
			var _local11:Boolean = options.wordWrap;
			var _local28:Boolean = false;
			if(_local39 < 0) {
				_local39 *= -_size;
			}
			while(!_local28) {
				sLines.length = 0;
				_local13 = _local39 / _size;
				_local18 = (width - 2 * _padding) / _local13;
				_local34 = (height - 2 * _padding) / _local13;
				if(_lineHeight <= _local34) {
					_local23 = -1;
					_local36 = -1;
					_local35 = 0;
					_local15 = 0;
					_local19 = CharLocation.vectorFromPool();
					_local31 = text.length;
					_local27 = 0;
					while(_local27 < _local31) {
						_local33 = false;
						_local24 = int(text.charCodeAt(_local27));
						_local37 = getChar(_local24);
						if(_local24 == 10 || _local24 == 13) {
							_local33 = true;
						} else if(_local37 == null) {
							trace("[Starling] Font: " + name + " missing character: " + text.charAt(_local27) + " id: " + _local24);
						} else {
							if(_local24 == 32 || _local24 == 9) {
								_local23 = _local27;
							}
							if(_local6) {
								_local35 += _local37.getKerning(_local36);
							}
							_local38 = CharLocation.instanceFromPool(_local37);
							_local38.x = _local35 + _local37.xOffset;
							_local38.y = _local15 + _local37.yOffset;
							_local19[_local19.length] = _local38;
							_local35 += _local37.xAdvance;
							_local36 = _local24;
							if(_local38.x + _local37.width > _local18) {
								if(_local11) {
									if(!(_local17 && _local23 == -1)) {
										_local32 = _local23 == -1 ? 1 : _local27 - _local23;
										_local29 = 0;
										while(_local29 < _local32) {
											_local19.pop();
											_local29++;
										}
										if(_local19.length != 0) {
											_local27 -= _local32;
										}
									}
									break;
								}
								if(!_local17) {
									_local19.pop();
									while(_local27 < _local31 - 1 && text.charCodeAt(_local27) != 10) {
										_local27++;
									}
								}
								break;
								_local33 = true;
							}
						}
						if(_local27 == _local31 - 1) {
							sLines[sLines.length] = _local19;
							_local28 = true;
						} else if(_local33) {
							sLines[sLines.length] = _local19;
							if(_local23 == _local27) {
								_local19.pop();
							}
							if(_local15 + _local10 + 2 * _lineHeight > _local34) {
								break;
							}
							_local19 = CharLocation.vectorFromPool();
							_local35 = 0;
							_local15 += _lineHeight + _local10;
							_local23 = -1;
							_local36 = -1;
						}
						_local27++;
					}
				}
				if(_local17 && !_local28 && _local39 > 3) {
					_local39 -= 1;
				} else {
					_local28 = true;
				}
			}
			var _local20:Vector.<CharLocation> = CharLocation.vectorFromPool();
			var _local9:int = int(sLines.length);
			var _local25:Number = _local15 + _lineHeight;
			var _local7:int = 0;
			if(_local16 == "bottom") {
				_local7 = _local34 - _local25;
			} else if(_local16 == "center") {
				_local7 = (_local34 - _local25) / 2;
			}
			_local14 = 0;
			while(_local14 < _local9) {
				_local12 = sLines[_local14];
				_local31 = int(_local12.length);
				if(_local31 != 0) {
					_local21 = 0;
					_local26 = _local12[_local12.length - 1];
					_local30 = _local26.x - _local26.char.xOffset + _local26.char.xAdvance;
					if(_local8 == "right") {
						_local21 = _local18 - _local30;
					} else if(_local8 == "center") {
						_local21 = (_local18 - _local30) / 2;
					}
					_local22 = 0;
					while(_local22 < _local31) {
						_local38 = _local12[_local22];
						_local38.x = _local13 * (_local38.x + _local21 + _offsetX) + _padding;
						_local38.y = _local13 * (_local38.y + _local7 + _offsetY) + _padding;
						_local38.scale = _local13;
						if(_local38.char.width > 0 && _local38.char.height > 0) {
							_local20[_local20.length] = _local38;
						}
						_local22++;
					}
				}
				_local14++;
			}
			return _local20;
		}
		
		public function get name() : String {
			return _name;
		}
		
		public function get size() : Number {
			return _size;
		}
		
		public function get lineHeight() : Number {
			return _lineHeight;
		}
		
		public function set lineHeight(value:Number) : void {
			_lineHeight = value;
		}
		
		public function get smoothing() : String {
			return _helperImage.textureSmoothing;
		}
		
		public function set smoothing(value:String) : void {
			_helperImage.textureSmoothing = value;
		}
		
		public function get baseline() : Number {
			return _baseline;
		}
		
		public function set baseline(value:Number) : void {
			_baseline = value;
		}
		
		public function get offsetX() : Number {
			return _offsetX;
		}
		
		public function set offsetX(value:Number) : void {
			_offsetX = value;
		}
		
		public function get offsetY() : Number {
			return _offsetY;
		}
		
		public function set offsetY(value:Number) : void {
			_offsetY = value;
		}
		
		public function get padding() : Number {
			return _padding;
		}
		
		public function set padding(value:Number) : void {
			_padding = value;
		}
		
		public function get texture() : Texture {
			return _texture;
		}
	}
}

class CharLocation {
	private static var sInstancePool:Vector.<CharLocation> = new Vector.<CharLocation>(0);
	
	private static var sVectorPool:Array = [];
	
	private static var sInstanceLoan:Vector.<CharLocation> = new Vector.<CharLocation>(0);
	
	private static var sVectorLoan:Array = [];
	
	public var char:BitmapChar;
	
	public var scale:Number;
	
	public var x:Number;
	
	public var y:Number;
	
	public function CharLocation(char:BitmapChar) {
		super();
		reset(char);
	}
	
	public static function instanceFromPool(char:BitmapChar) : CharLocation {
		var _local2:CharLocation = sInstancePool.length > 0 ? sInstancePool.pop() : new CharLocation(char);
		_local2.reset(char);
		sInstanceLoan[sInstanceLoan.length] = _local2;
		return _local2;
	}
	
	public static function vectorFromPool() : Vector.<CharLocation> {
		var _local1:Vector.<CharLocation> = sVectorPool.length > 0 ? sVectorPool.pop() : new Vector.<CharLocation>(0);
		_local1.length = 0;
		sVectorLoan[sVectorLoan.length] = _local1;
		return _local1;
	}
	
	public static function rechargePool() : void {
		var _local1:CharLocation = null;
		var _local2:* = undefined;
		while(sInstanceLoan.length > 0) {
			_local1 = sInstanceLoan.pop();
			_local1.char = null;
			sInstancePool[sInstancePool.length] = _local1;
		}
		while(sVectorLoan.length > 0) {
			_local2 = sVectorLoan.pop();
			_local2.length = 0;
			sVectorPool[sVectorPool.length] = _local2;
		}
	}
	
	private function reset(char:BitmapChar) : CharLocation {
		this.char = char;
		return this;
	}
}
