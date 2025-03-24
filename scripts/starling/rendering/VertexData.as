package starling.rendering {
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import starling.core.Starling;
	import starling.errors.MissingContextError;
	import starling.styles.MeshStyle;
	import starling.utils.MathUtil;
	import starling.utils.MatrixUtil;
	import starling.utils.StringUtil;
	
	public class VertexData {
		private static var sHelperPoint:Point = new Point();
		
		private static var sHelperPoint3D:Vector3D = new Vector3D();
		
		private static var sBytes:ByteArray = new ByteArray();
		
		private var _rawData:ByteArray;
		
		private var _numVertices:int;
		
		private var _format:VertexDataFormat;
		
		private var _attributes:Vector.<VertexDataAttribute>;
		
		private var _numAttributes:int;
		
		private var _premultipliedAlpha:Boolean;
		
		private var _tinted:Boolean;
		
		private var _posOffset:int;
		
		private var _colOffset:int;
		
		private var _vertexSize:int;
		
		public function VertexData(format:* = null, initialCapacity:int = 32) {
			super();
			if(format == null) {
				_format = MeshStyle.VERTEX_FORMAT;
			} else if(format is VertexDataFormat) {
				_format = format;
			} else {
				if(!(format is String)) {
					throw new ArgumentError("\'format\' must be String or VertexDataFormat");
				}
				_format = VertexDataFormat.fromString(format as String);
			}
			_attributes = _format.attributes;
			_numAttributes = _attributes.length;
			_posOffset = _format.hasAttribute("position") ? _format.getOffset("position") : 0;
			_colOffset = _format.hasAttribute("color") ? _format.getOffset("color") : 0;
			_vertexSize = _format.vertexSize;
			_numVertices = 0;
			_premultipliedAlpha = true;
			_rawData = new ByteArray();
			_rawData.endian = sBytes.endian = "littleEndian";
			_rawData.length = initialCapacity * _vertexSize;
			_rawData.length = 0;
		}
		
		private static function switchEndian(value:uint) : uint {
			return (value & 0xFF) << 24 | (value >> 8 & 0xFF) << 16 | (value >> 16 & 0xFF) << 8 | value >> 24 & 0xFF;
		}
		
		private static function premultiplyAlpha(rgba:uint) : uint {
			var _local6:Number = NaN;
			var _local2:* = 0;
			var _local5:* = 0;
			var _local3:* = 0;
			var _local4:uint = uint(rgba & 0xFF);
			if(_local4 == 255) {
				return rgba;
			}
			_local6 = _local4 / 255;
			_local2 = (rgba >> 24 & 0xFF) * _local6;
			_local5 = (rgba >> 16 & 0xFF) * _local6;
			_local3 = (rgba >> 8 & 0xFF) * _local6;
			return (_local2 & 0xFF) << 24 | (_local5 & 0xFF) << 16 | (_local3 & 0xFF) << 8 | _local4;
		}
		
		private static function unmultiplyAlpha(rgba:uint) : uint {
			var _local6:Number = NaN;
			var _local2:* = 0;
			var _local5:* = 0;
			var _local3:* = 0;
			var _local4:uint = uint(rgba & 0xFF);
			if(_local4 == 255 || _local4 == 0) {
				return rgba;
			}
			_local6 = _local4 / 255;
			_local2 = (rgba >> 24 & 0xFF) / _local6;
			_local5 = (rgba >> 16 & 0xFF) / _local6;
			_local3 = (rgba >> 8 & 0xFF) / _local6;
			return (_local2 & 0xFF) << 24 | (_local5 & 0xFF) << 16 | (_local3 & 0xFF) << 8 | _local4;
		}
		
		public function clear() : void {
			_rawData.clear();
			_numVertices = 0;
			_tinted = false;
		}
		
		public function clone() : VertexData {
			var _local1:VertexData = new VertexData(_format,_numVertices);
			_local1._rawData.writeBytes(_rawData);
			_local1._numVertices = _numVertices;
			_local1._premultipliedAlpha = _premultipliedAlpha;
			_local1._tinted = _tinted;
			return _local1;
		}
		
		public function copyTo(target:VertexData, targetVertexID:int = 0, matrix:Matrix = null, vertexID:int = 0, numVertices:int = -1) : void {
			var _local8:ByteArray = null;
			var _local13:Number = NaN;
			var _local12:Number = NaN;
			var _local11:int = 0;
			var _local9:int = 0;
			var _local7:int = 0;
			var _local10:VertexDataAttribute = null;
			var _local6:VertexDataAttribute = null;
			if(numVertices < 0 || vertexID + numVertices > _numVertices) {
				numVertices = _numVertices - vertexID;
			}
			if(_format === target._format) {
				if(target._numVertices < targetVertexID + numVertices) {
					target._numVertices = targetVertexID + numVertices;
				}
				target._tinted ||= _tinted;
				_local8 = target._rawData;
				_local8.position = targetVertexID * _vertexSize;
				_local8.writeBytes(_rawData,vertexID * _vertexSize,numVertices * _vertexSize);
				if(matrix) {
					_local11 = targetVertexID * _vertexSize + _posOffset;
					_local9 = _local11 + numVertices * _vertexSize;
					while(_local11 < _local9) {
						_local8.position = _local11;
						_local12 = _local8.readFloat();
						_local13 = _local8.readFloat();
						_local8.position = _local11;
						_local8.writeFloat(matrix.a * _local12 + matrix.c * _local13 + matrix.tx);
						_local8.writeFloat(matrix.d * _local13 + matrix.b * _local12 + matrix.ty);
						_local11 += _vertexSize;
					}
				}
			} else {
				if(target._numVertices < targetVertexID + numVertices) {
					target.numVertices = targetVertexID + numVertices;
				}
				_local7 = 0;
				while(_local7 < _numAttributes) {
					_local10 = _attributes[_local7];
					_local6 = target.getAttribute(_local10.name);
					if(_local6) {
						if(_local10.offset == _posOffset) {
							copyAttributeTo_internal(target,targetVertexID,matrix,_local10,_local6,vertexID,numVertices);
						} else {
							copyAttributeTo_internal(target,targetVertexID,null,_local10,_local6,vertexID,numVertices);
						}
					}
					_local7++;
				}
			}
		}
		
		public function copyAttributeTo(target:VertexData, targetVertexID:int, attrName:String, matrix:Matrix = null, vertexID:int = 0, numVertices:int = -1) : void {
			var _local8:VertexDataAttribute = getAttribute(attrName);
			var _local7:VertexDataAttribute = target.getAttribute(attrName);
			if(_local8 == null) {
				throw new ArgumentError("Attribute \'" + attrName + "\' not found in source data");
			}
			if(_local7 == null) {
				throw new ArgumentError("Attribute \'" + attrName + "\' not found in target data");
			}
			if(_local8.isColor) {
				target._tinted ||= _tinted;
			}
			copyAttributeTo_internal(target,targetVertexID,matrix,_local8,_local7,vertexID,numVertices);
		}
		
		private function copyAttributeTo_internal(target:VertexData, targetVertexID:int, matrix:Matrix, sourceAttribute:VertexDataAttribute, targetAttribute:VertexDataAttribute, vertexID:int, numVertices:int) : void {
			var _local11:int = 0;
			var _local13:Number = NaN;
			var _local14:Number = NaN;
			var _local10:int = 0;
			if(sourceAttribute.format != targetAttribute.format) {
				throw new IllegalOperationError("Attribute formats differ between source and target");
			}
			if(numVertices < 0 || vertexID + numVertices > _numVertices) {
				numVertices = _numVertices - vertexID;
			}
			if(target._numVertices < targetVertexID + numVertices) {
				target._numVertices = targetVertexID + numVertices;
			}
			var _local16:ByteArray = _rawData;
			var _local8:ByteArray = target._rawData;
			var _local12:int = _vertexSize - sourceAttribute.size;
			var _local15:int = target._vertexSize - targetAttribute.size;
			var _local9:int = sourceAttribute.size / 4;
			_local16.position = vertexID * _vertexSize + sourceAttribute.offset;
			_local8.position = targetVertexID * target._vertexSize + targetAttribute.offset;
			if(matrix) {
				_local10 = 0;
				while(_local10 < numVertices) {
					_local13 = _local16.readFloat();
					_local14 = _local16.readFloat();
					_local8.writeFloat(matrix.a * _local13 + matrix.c * _local14 + matrix.tx);
					_local8.writeFloat(matrix.d * _local14 + matrix.b * _local13 + matrix.ty);
					_local16.position += _local12;
					_local8.position += _local15;
					_local10++;
				}
			} else {
				_local10 = 0;
				while(_local10 < numVertices) {
					_local11 = 0;
					while(_local11 < _local9) {
						_local8.writeUnsignedInt(_local16.readUnsignedInt());
						_local11++;
					}
					_local16.position += _local12;
					_local8.position += _local15;
					_local10++;
				}
			}
		}
		
		public function trim() : void {
			var _local1:int = _numVertices * _vertexSize;
			sBytes.length = _local1;
			sBytes.position = 0;
			sBytes.writeBytes(_rawData,0,_local1);
			_rawData.clear();
			_rawData.length = _local1;
			_rawData.writeBytes(sBytes);
			sBytes.clear();
		}
		
		public function toString() : String {
			return StringUtil.format("[VertexData format=\"{0}\" numVertices={1}]",_format.formatString,_numVertices);
		}
		
		public function getUnsignedInt(vertexID:int, attrName:String) : uint {
			_rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
			return _rawData.readUnsignedInt();
		}
		
		public function setUnsignedInt(vertexID:int, attrName:String, value:uint) : void {
			if(_numVertices < vertexID + 1) {
				numVertices = vertexID + 1;
			}
			_rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
			_rawData.writeUnsignedInt(value);
		}
		
		public function getFloat(vertexID:int, attrName:String) : Number {
			_rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
			return _rawData.readFloat();
		}
		
		public function setFloat(vertexID:int, attrName:String, value:Number) : void {
			if(_numVertices < vertexID + 1) {
				numVertices = vertexID + 1;
			}
			_rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
			_rawData.writeFloat(value);
		}
		
		public function getPoint(vertexID:int, attrName:String, out:Point = null) : Point {
			if(out == null) {
				out = new Point();
			}
			var _local4:int = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
			_rawData.position = vertexID * _vertexSize + _local4;
			out.x = _rawData.readFloat();
			out.y = _rawData.readFloat();
			return out;
		}
		
		public function setPoint(vertexID:int, attrName:String, x:Number, y:Number) : void {
			if(_numVertices < vertexID + 1) {
				numVertices = vertexID + 1;
			}
			var _local5:int = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
			_rawData.position = vertexID * _vertexSize + _local5;
			_rawData.writeFloat(x);
			_rawData.writeFloat(y);
		}
		
		public function getPoint3D(vertexID:int, attrName:String, out:Vector3D = null) : Vector3D {
			if(out == null) {
				out = new Vector3D();
			}
			_rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
			out.x = _rawData.readFloat();
			out.y = _rawData.readFloat();
			out.z = _rawData.readFloat();
			return out;
		}
		
		public function setPoint3D(vertexID:int, attrName:String, x:Number, y:Number, z:Number) : void {
			if(_numVertices < vertexID + 1) {
				numVertices = vertexID + 1;
			}
			_rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
			_rawData.writeFloat(x);
			_rawData.writeFloat(y);
			_rawData.writeFloat(z);
		}
		
		public function getPoint4D(vertexID:int, attrName:String, out:Vector3D = null) : Vector3D {
			if(out == null) {
				out = new Vector3D();
			}
			_rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
			out.x = _rawData.readFloat();
			out.y = _rawData.readFloat();
			out.z = _rawData.readFloat();
			out.w = _rawData.readFloat();
			return out;
		}
		
		public function setPoint4D(vertexID:int, attrName:String, x:Number, y:Number, z:Number, w:Number = 1) : void {
			if(_numVertices < vertexID + 1) {
				numVertices = vertexID + 1;
			}
			_rawData.position = vertexID * _vertexSize + getAttribute(attrName).offset;
			_rawData.writeFloat(x);
			_rawData.writeFloat(y);
			_rawData.writeFloat(z);
			_rawData.writeFloat(w);
		}
		
		public function getColor(vertexID:int, attrName:String = "color") : uint {
			var _local4:int = attrName == "color" ? _colOffset : getAttribute(attrName).offset;
			_rawData.position = vertexID * _vertexSize + _local4;
			var _local3:uint = switchEndian(_rawData.readUnsignedInt());
			if(_premultipliedAlpha) {
				_local3 = unmultiplyAlpha(_local3);
			}
			return _local3 >> 8 & 0xFFFFFF;
		}
		
		public function setColor(vertexID:int, attrName:String, color:uint) : void {
			if(_numVertices < vertexID + 1) {
				numVertices = vertexID + 1;
			}
			var _local4:Number = getAlpha(vertexID,attrName);
			colorize(attrName,color,_local4,vertexID,1);
		}
		
		public function getAlpha(vertexID:int, attrName:String = "color") : Number {
			var _local4:int = attrName == "color" ? _colOffset : getAttribute(attrName).offset;
			_rawData.position = vertexID * _vertexSize + _local4;
			var _local3:uint = switchEndian(_rawData.readUnsignedInt());
			return (_local3 & 0xFF) / 255;
		}
		
		public function setAlpha(vertexID:int, attrName:String, alpha:Number) : void {
			if(_numVertices < vertexID + 1) {
				numVertices = vertexID + 1;
			}
			var _local4:uint = getColor(vertexID,attrName);
			colorize(attrName,_local4,alpha,vertexID,1);
		}
		
		public function getBounds(attrName:String = "position", matrix:Matrix = null, vertexID:int = 0, numVertices:int = -1, out:Rectangle = null) : Rectangle {
			var _local11:* = NaN;
			var _local10:* = NaN;
			var _local6:int = 0;
			var _local14:int = 0;
			var _local13:Number = NaN;
			var _local9:int = 0;
			var _local12:Number = NaN;
			if(out == null) {
				out = new Rectangle();
			}
			if(numVertices < 0 || vertexID + numVertices > _numVertices) {
				numVertices = _numVertices - vertexID;
			}
			if(numVertices == 0) {
				if(matrix == null) {
					out.setEmpty();
				} else {
					MatrixUtil.transformCoords(matrix,0,0,sHelperPoint);
					out.setTo(sHelperPoint.x,sHelperPoint.y,0,0);
				}
			} else {
				_local11 = 1.7976931348623157e+308;
				var _local8:* = -1.7976931348623157e+308;
				_local10 = 1.7976931348623157e+308;
				var _local7:* = -1.7976931348623157e+308;
				_local6 = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
				_local14 = vertexID * _vertexSize + _local6;
				if(matrix == null) {
					_local9 = 0;
					while(_local9 < numVertices) {
						_rawData.position = _local14;
						_local12 = _rawData.readFloat();
						_local13 = _rawData.readFloat();
						_local14 += _vertexSize;
						if(_local11 > _local12) {
							_local11 = _local12;
						}
						if(_local8 < _local12) {
							_local8 = _local12;
						}
						if(_local10 > _local13) {
							_local10 = _local13;
						}
						if(_local7 < _local13) {
							_local7 = _local13;
						}
						_local9++;
					}
				} else {
					_local9 = 0;
					while(_local9 < numVertices) {
						_rawData.position = _local14;
						_local12 = _rawData.readFloat();
						_local13 = _rawData.readFloat();
						_local14 += _vertexSize;
						MatrixUtil.transformCoords(matrix,_local12,_local13,sHelperPoint);
						if(_local11 > sHelperPoint.x) {
							_local11 = sHelperPoint.x;
						}
						if(_local8 < sHelperPoint.x) {
							_local8 = sHelperPoint.x;
						}
						if(_local10 > sHelperPoint.y) {
							_local10 = sHelperPoint.y;
						}
						if(_local7 < sHelperPoint.y) {
							_local7 = sHelperPoint.y;
						}
						_local9++;
					}
				}
				out.setTo(_local11,_local10,_local8 - _local11,_local7 - _local10);
			}
			return out;
		}
		
		public function getBoundsProjected(attrName:String, matrix:Matrix3D, camPos:Vector3D, vertexID:int = 0, numVertices:int = -1, out:Rectangle = null) : Rectangle {
			var _local12:Number = NaN;
			var _local11:Number = NaN;
			var _local7:int = 0;
			var _local15:int = 0;
			var _local14:Number = NaN;
			var _local10:int = 0;
			var _local13:Number = NaN;
			if(out == null) {
				out = new Rectangle();
			}
			if(camPos == null) {
				throw new ArgumentError("camPos must not be null");
			}
			if(numVertices < 0 || vertexID + numVertices > _numVertices) {
				numVertices = _numVertices - vertexID;
			}
			if(numVertices == 0) {
				if(matrix) {
					MatrixUtil.transformCoords3D(matrix,0,0,0,sHelperPoint3D);
				} else {
					sHelperPoint3D.setTo(0,0,0);
				}
				MathUtil.intersectLineWithXYPlane(camPos,sHelperPoint3D,sHelperPoint);
				out.setTo(sHelperPoint.x,sHelperPoint.y,0,0);
			} else {
				_local12 = 1.7976931348623157e+308;
				var _local9:Number = -1.7976931348623157e+308;
				_local11 = 1.7976931348623157e+308;
				var _local8:Number = -1.7976931348623157e+308;
				_local7 = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
				_local15 = vertexID * _vertexSize + _local7;
				_local10 = 0;
				while(_local10 < numVertices) {
					_rawData.position = _local15;
					_local13 = _rawData.readFloat();
					_local14 = _rawData.readFloat();
					_local15 += _vertexSize;
					if(matrix) {
						MatrixUtil.transformCoords3D(matrix,_local13,_local14,0,sHelperPoint3D);
					} else {
						sHelperPoint3D.setTo(_local13,_local14,0);
					}
					MathUtil.intersectLineWithXYPlane(camPos,sHelperPoint3D,sHelperPoint);
					if(_local12 > sHelperPoint.x) {
						_local12 = sHelperPoint.x;
					}
					if(_local9 < sHelperPoint.x) {
						_local9 = sHelperPoint.x;
					}
					if(_local11 > sHelperPoint.y) {
						_local11 = sHelperPoint.y;
					}
					if(_local8 < sHelperPoint.y) {
						_local8 = sHelperPoint.y;
					}
					_local10++;
				}
				out.setTo(_local12,_local11,_local9 - _local12,_local8 - _local11);
			}
			return out;
		}
		
		public function get premultipliedAlpha() : Boolean {
			return _premultipliedAlpha;
		}
		
		public function set premultipliedAlpha(value:Boolean) : void {
			setPremultipliedAlpha(value,false);
		}
		
		public function setPremultipliedAlpha(value:Boolean, updateData:Boolean) : void {
			var _local6:int = 0;
			var _local8:VertexDataAttribute = null;
			var _local4:int = 0;
			var _local3:* = 0;
			var _local5:* = 0;
			var _local7:int = 0;
			if(updateData && value != _premultipliedAlpha) {
				_local6 = 0;
				while(_local6 < _numAttributes) {
					_local8 = _attributes[_local6];
					if(_local8.isColor) {
						_local4 = _local8.offset;
						_local7 = 0;
						while(_local7 < _numVertices) {
							_rawData.position = _local4;
							_local3 = switchEndian(_rawData.readUnsignedInt());
							_local5 = value ? premultiplyAlpha(_local3) : unmultiplyAlpha(_local3);
							_rawData.position = _local4;
							_rawData.writeUnsignedInt(switchEndian(_local5));
							_local4 += _vertexSize;
							_local7++;
						}
					}
					_local6++;
				}
			}
			_premultipliedAlpha = value;
		}
		
		public function updateTinted(attrName:String = "color") : Boolean {
			var _local3:int = 0;
			var _local2:int = attrName == "color" ? _colOffset : getAttribute(attrName).offset;
			_tinted = false;
			_local3 = 0;
			while(_local3 < _numVertices) {
				_rawData.position = _local2;
				if(_rawData.readUnsignedInt() != 4294967295) {
					_tinted = true;
					break;
				}
				_local2 += _vertexSize;
				_local3++;
			}
			return _tinted;
		}
		
		public function transformPoints(attrName:String, matrix:Matrix, vertexID:int = 0, numVertices:int = -1) : void {
			var _local8:Number = NaN;
			var _local7:Number = NaN;
			if(numVertices < 0 || vertexID + numVertices > _numVertices) {
				numVertices = _numVertices - vertexID;
			}
			var _local5:int = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
			var _local6:int = vertexID * _vertexSize + _local5;
			var _local9:int = _local6 + numVertices * _vertexSize;
			while(_local6 < _local9) {
				_rawData.position = _local6;
				_local7 = _rawData.readFloat();
				_local8 = _rawData.readFloat();
				_rawData.position = _local6;
				_rawData.writeFloat(matrix.a * _local7 + matrix.c * _local8 + matrix.tx);
				_rawData.writeFloat(matrix.d * _local8 + matrix.b * _local7 + matrix.ty);
				_local6 += _vertexSize;
			}
		}
		
		public function translatePoints(attrName:String, deltaX:Number, deltaY:Number, vertexID:int = 0, numVertices:int = -1) : void {
			var _local9:Number = NaN;
			var _local8:Number = NaN;
			if(numVertices < 0 || vertexID + numVertices > _numVertices) {
				numVertices = _numVertices - vertexID;
			}
			var _local6:int = attrName == "position" ? _posOffset : getAttribute(attrName).offset;
			var _local7:int = vertexID * _vertexSize + _local6;
			var _local10:int = _local7 + numVertices * _vertexSize;
			while(_local7 < _local10) {
				_rawData.position = _local7;
				_local8 = _rawData.readFloat();
				_local9 = _rawData.readFloat();
				_rawData.position = _local7;
				_rawData.writeFloat(_local8 + deltaX);
				_rawData.writeFloat(_local9 + deltaY);
				_local7 += _vertexSize;
			}
		}
		
		public function scaleAlphas(attrName:String, factor:Number, vertexID:int = 0, numVertices:int = -1) : void {
			var _local9:int = 0;
			var _local8:Number = NaN;
			var _local5:* = 0;
			var _local10:int = 0;
			if(factor == 1) {
				return;
			}
			if(numVertices < 0 || vertexID + numVertices > _numVertices) {
				numVertices = _numVertices - vertexID;
			}
			_tinted = true;
			var _local6:int = attrName == "color" ? _colOffset : getAttribute(attrName).offset;
			var _local7:int = vertexID * _vertexSize + _local6;
			_local9 = 0;
			while(_local9 < numVertices) {
				_local10 = _local7 + 3;
				_local8 = _rawData[_local10] / 255 * factor;
				if(_local8 > 1) {
					_local8 = 1;
				} else if(_local8 < 0) {
					_local8 = 0;
				}
				if(_local8 == 1 || !_premultipliedAlpha) {
					_rawData[_local10] = int(_local8 * 255);
				} else {
					_rawData.position = _local7;
					_local5 = unmultiplyAlpha(switchEndian(_rawData.readUnsignedInt()));
					_local5 = uint(_local5 & 4294967040 | int(_local8 * 255) & 0xFF);
					_local5 = premultiplyAlpha(_local5);
					_rawData.position = _local7;
					_rawData.writeUnsignedInt(switchEndian(_local5));
				}
				_local7 += _vertexSize;
				_local9++;
			}
		}
		
		public function colorize(attrName:String = "color", color:uint = 16777215, alpha:Number = 1, vertexID:int = 0, numVertices:int = -1) : void {
			if(numVertices < 0 || vertexID + numVertices > _numVertices) {
				numVertices = _numVertices - vertexID;
			}
			var _local7:int = attrName == "color" ? _colOffset : getAttribute(attrName).offset;
			var _local8:int = vertexID * _vertexSize + _local7;
			var _local9:int = _local8 + numVertices * _vertexSize;
			if(alpha > 1) {
				alpha = 1;
			} else if(alpha < 0) {
				alpha = 0;
			}
			var _local6:uint = uint(color << 8 & 4294967040 | int(alpha * 255) & 0xFF);
			if(_local6 == 4294967295 && numVertices == _numVertices) {
				_tinted = false;
			} else if(_local6 != 4294967295) {
				_tinted = true;
			}
			if(_premultipliedAlpha && alpha != 1) {
				_local6 = premultiplyAlpha(_local6);
			}
			_rawData.position = vertexID * _vertexSize + _local7;
			_rawData.writeUnsignedInt(switchEndian(_local6));
			while(_local8 < _local9) {
				_rawData.position = _local8;
				_rawData.writeUnsignedInt(switchEndian(_local6));
				_local8 += _vertexSize;
			}
		}
		
		public function getFormat(attrName:String) : String {
			return getAttribute(attrName).format;
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
		
		public function hasAttribute(attrName:String) : Boolean {
			return getAttribute(attrName) != null;
		}
		
		public function createVertexBuffer(upload:Boolean = false, bufferUsage:String = "staticDraw") : VertexBuffer3D {
			var _local3:Context3D = Starling.context;
			if(_local3 == null) {
				throw new MissingContextError();
			}
			if(_numVertices == 0) {
				return null;
			}
			var _local4:VertexBuffer3D = _local3.createVertexBuffer(_numVertices,_vertexSize / 4,bufferUsage);
			if(upload) {
				uploadToVertexBuffer(_local4);
			}
			return _local4;
		}
		
		public function uploadToVertexBuffer(buffer:VertexBuffer3D, vertexID:int = 0, numVertices:int = -1) : void {
			if(numVertices < 0 || vertexID + numVertices > _numVertices) {
				numVertices = _numVertices - vertexID;
			}
			if(numVertices > 0) {
				buffer.uploadFromByteArray(_rawData,0,vertexID,numVertices);
			}
		}
		
		final private function getAttribute(attrName:String) : VertexDataAttribute {
			var _local3:VertexDataAttribute = null;
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < _numAttributes) {
				_local3 = _attributes[_local2];
				if(_local3.name == attrName) {
					return _local3;
				}
				_local2++;
			}
			return null;
		}
		
		public function get numVertices() : int {
			return _numVertices;
		}
		
		public function set numVertices(value:int) : void {
			var _local2:int = 0;
			var _local3:int = 0;
			var _local5:int = 0;
			var _local7:VertexDataAttribute = null;
			var _local4:int = 0;
			var _local6:int = 0;
			if(value > _numVertices) {
				_local2 = _numVertices * vertexSize;
				_local3 = value * _vertexSize;
				if(_rawData.length > _local2) {
					_rawData.position = _local2;
					while(_rawData.bytesAvailable) {
						_rawData.writeUnsignedInt(0);
					}
				}
				if(_rawData.length < _local3) {
					_rawData.length = _local3;
				}
				_local5 = 0;
				while(_local5 < _numAttributes) {
					_local7 = _attributes[_local5];
					if(_local7.isColor) {
						_local4 = _numVertices * _vertexSize + _local7.offset;
						_local6 = _numVertices;
						while(_local6 < value) {
							_rawData.position = _local4;
							_rawData.writeUnsignedInt(4294967295);
							_local4 += _vertexSize;
							_local6++;
						}
					}
					_local5++;
				}
			}
			if(value == 0) {
				_tinted = false;
			}
			_numVertices = value;
		}
		
		public function get rawData() : ByteArray {
			return _rawData;
		}
		
		public function get format() : VertexDataFormat {
			return _format;
		}
		
		public function set format(value:VertexDataFormat) : void {
			var _local8:int = 0;
			var _local6:int = 0;
			var _local4:int = 0;
			var _local7:VertexDataAttribute = null;
			var _local5:VertexDataAttribute = null;
			if(_format === value) {
				return;
			}
			var _local2:int = _format.vertexSize;
			var _local9:int = value.vertexSize;
			var _local3:int = value.numAttributes;
			sBytes.length = value.vertexSize * _numVertices;
			_local4 = 0;
			while(_local4 < _local3) {
				_local7 = value.attributes[_local4];
				_local5 = getAttribute(_local7.name);
				if(_local5) {
					_local6 = _local7.offset;
					_local8 = 0;
					while(_local8 < _numVertices) {
						sBytes.position = _local6;
						sBytes.writeBytes(_rawData,_local2 * _local8 + _local5.offset,_local5.size);
						_local6 += _local9;
						_local8++;
					}
				} else if(_local7.isColor) {
					_local6 = _local7.offset;
					_local8 = 0;
					while(_local8 < _numVertices) {
						sBytes.position = _local6;
						sBytes.writeUnsignedInt(4294967295);
						_local6 += _local9;
						_local8++;
					}
				}
				_local4++;
			}
			_rawData.clear();
			_rawData.length = sBytes.length;
			_rawData.writeBytes(sBytes);
			sBytes.clear();
			_format = value;
			_attributes = _format.attributes;
			_numAttributes = _attributes.length;
			_vertexSize = _format.vertexSize;
			_posOffset = _format.hasAttribute("position") ? _format.getOffset("position") : 0;
			_colOffset = _format.hasAttribute("color") ? _format.getOffset("color") : 0;
		}
		
		public function get tinted() : Boolean {
			return _tinted;
		}
		
		public function set tinted(value:Boolean) : void {
			_tinted = value;
		}
		
		public function get formatString() : String {
			return _format.formatString;
		}
		
		public function get vertexSize() : int {
			return _vertexSize;
		}
		
		public function get vertexSizeIn32Bits() : int {
			return _vertexSize / 4;
		}
		
		public function get size() : int {
			return _numVertices * _vertexSize;
		}
		
		public function get sizeIn32Bits() : int {
			return _numVertices * _vertexSize / 4;
		}
	}
}

