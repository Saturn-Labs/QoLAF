package starling.rendering {
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.errors.EOFError;
	import flash.utils.ByteArray;
	import starling.core.Starling;
	import starling.errors.MissingContextError;
	import starling.utils.StringUtil;
	
	public class IndexData {
		private static const INDEX_SIZE:int = 2;
		
		private static var sQuadDataNumIndices:uint = 0;
		
		private static var sQuadData:ByteArray = new ByteArray();
		
		private static var sVector:Vector.<uint> = new Vector.<uint>(0);
		
		private static var sTrimData:ByteArray = new ByteArray();
		
		private var _rawData:ByteArray;
		
		private var _numIndices:int;
		
		private var _initialCapacity:int;
		
		private var _useQuadLayout:Boolean;
		
		public function IndexData(initialCapacity:int = 48) {
			super();
			_numIndices = 0;
			_initialCapacity = initialCapacity;
			_useQuadLayout = true;
		}
		
		private static function getBasicQuadIndexAt(indexID:int) : int {
			var _local3:int = 0;
			var _local2:int = indexID / 6;
			var _local4:int = indexID - _local2 * 6;
			if(_local4 == 0) {
				_local3 = 0;
			} else if(_local4 == 1 || _local4 == 3) {
				_local3 = 1;
			} else if(_local4 == 2 || _local4 == 5) {
				_local3 = 2;
			} else {
				_local3 = 3;
			}
			return _local2 * 4 + _local3;
		}
		
		public function clear() : void {
			if(_rawData) {
				_rawData.clear();
			}
			_numIndices = 0;
			_useQuadLayout = true;
		}
		
		public function clone() : IndexData {
			var _local1:IndexData = new IndexData(_numIndices);
			if(!_useQuadLayout) {
				_local1.switchToGenericData();
				_local1._rawData.writeBytes(_rawData);
			}
			_local1._numIndices = _numIndices;
			return _local1;
		}
		
		public function copyTo(target:IndexData, targetIndexID:int = 0, offset:int = 0, indexID:int = 0, numIndices:int = -1) : void {
			var _local6:ByteArray = null;
			var _local15:ByteArray = null;
			var _local16:* = false;
			var _local7:int = 0;
			var _local9:int = 0;
			var _local13:int = 0;
			var _local12:int = 0;
			var _local11:* = 0;
			var _local10:* = 0;
			var _local14:* = 0;
			if(numIndices < 0 || indexID + numIndices > _numIndices) {
				numIndices = _numIndices - indexID;
			}
			var _local8:int = targetIndexID + numIndices;
			if(target._numIndices < _local8) {
				target._numIndices = _local8;
				if(sQuadDataNumIndices < _local8) {
					ensureQuadDataCapacity(_local8);
				}
			}
			if(_useQuadLayout) {
				if(target._useQuadLayout) {
					_local16 = true;
					_local7 = targetIndexID - indexID;
					_local9 = _local7 / 6;
					_local13 = offset / 4;
					if(_local9 == _local13 && (offset & 3) == 0 && _local9 * 6 == _local7) {
						_local16 = true;
					} else if(numIndices > 2) {
						_local16 = false;
					} else {
						_local12 = 0;
						while(_local12 < numIndices) {
							if(_local16) {
								_local16 = getBasicQuadIndexAt(indexID + _local12) + offset == getBasicQuadIndexAt(targetIndexID + _local12);
							}
							_local12++;
						}
					}
					if(_local16) {
						return;
					}
					target.switchToGenericData();
				}
				_local15 = sQuadData;
				_local6 = target._rawData;
				if((offset & 3) == 0) {
					indexID += 6 * offset / 4;
					offset = 0;
					ensureQuadDataCapacity(indexID + numIndices);
				}
			} else {
				if(target._useQuadLayout) {
					target.switchToGenericData();
				}
				_local15 = _rawData;
				_local6 = target._rawData;
			}
			_local6.position = targetIndexID * 2;
			if(offset == 0) {
				_local6.writeBytes(_local15,indexID * 2,numIndices * 2);
			} else {
				_local15.position = indexID * 2;
				while(numIndices > 1) {
					_local11 = _local15.readUnsignedInt();
					_local10 = uint(((_local11 & 4294901760) >> 16) + offset);
					_local14 = uint((_local11 & 0xFFFF) + offset);
					_local6.writeUnsignedInt(_local10 << 16 | _local14);
					numIndices -= 2;
				}
				if(numIndices) {
					_local6.writeShort(_local15.readUnsignedShort() + offset);
				}
			}
		}
		
		public function setIndex(indexID:int, index:uint) : void {
			if(_numIndices < indexID + 1) {
				numIndices = indexID + 1;
			}
			if(_useQuadLayout) {
				if(getBasicQuadIndexAt(indexID) == index) {
					return;
				}
				switchToGenericData();
			}
			_rawData.position = indexID * 2;
			_rawData.writeShort(index);
		}
		
		public function getIndex(indexID:int) : int {
			if(_useQuadLayout) {
				if(indexID < _numIndices) {
					return getBasicQuadIndexAt(indexID);
				}
				throw new EOFError();
			}
			_rawData.position = indexID * 2;
			return _rawData.readUnsignedShort();
		}
		
		public function offsetIndices(offset:int, indexID:int = 0, numIndices:int = -1) : void {
			var _local5:* = 0;
			if(numIndices < 0 || indexID + numIndices > _numIndices) {
				numIndices = _numIndices - indexID;
			}
			var _local4:int = indexID + numIndices;
			_local5 = indexID;
			while(_local5 < _local4) {
				setIndex(_local5,getIndex(_local5) + offset);
				_local5++;
			}
		}
		
		public function addTriangle(a:uint, b:uint, c:uint) : void {
			var _local5:* = false;
			var _local4:* = false;
			if(_useQuadLayout) {
				if(a == getBasicQuadIndexAt(_numIndices)) {
					_local5 = (_numIndices & 1) != 0;
					_local4 = !_local5;
					if(_local4 && b == a + 1 && c == b + 1 || _local5 && c == a + 1 && b == c + 1) {
						_numIndices += 3;
						ensureQuadDataCapacity(_numIndices);
						return;
					}
				}
				switchToGenericData();
			}
			_rawData.position = _numIndices * 2;
			_rawData.writeShort(a);
			_rawData.writeShort(b);
			_rawData.writeShort(c);
			_numIndices += 3;
		}
		
		public function addQuad(a:uint, b:uint, c:uint, d:uint) : void {
			if(_useQuadLayout) {
				if(a == getBasicQuadIndexAt(_numIndices) && b == a + 1 && c == b + 1 && d == c + 1) {
					_numIndices += 6;
					ensureQuadDataCapacity(_numIndices);
					return;
				}
				switchToGenericData();
			}
			_rawData.position = _numIndices * 2;
			_rawData.writeShort(a);
			_rawData.writeShort(b);
			_rawData.writeShort(c);
			_rawData.writeShort(b);
			_rawData.writeShort(d);
			_rawData.writeShort(c);
			_numIndices += 6;
		}
		
		public function toVector(out:Vector.<uint> = null) : Vector.<uint> {
			var _local2:int = 0;
			if(out == null) {
				out = new Vector.<uint>(_numIndices);
			} else {
				out.length = _numIndices;
			}
			var _local3:ByteArray = _useQuadLayout ? sQuadData : _rawData;
			_local3.position = 0;
			_local2 = 0;
			while(_local2 < _numIndices) {
				out[_local2] = _local3.readUnsignedShort();
				_local2++;
			}
			return out;
		}
		
		public function toString() : String {
			var _local1:String = StringUtil.format("[IndexData numIndices={0} indices=\"{1}\"]",_numIndices,toVector(sVector).join());
			sVector.length = 0;
			return _local1;
		}
		
		private function switchToGenericData() : void {
			if(_useQuadLayout) {
				_useQuadLayout = false;
				if(_rawData == null) {
					_rawData = new ByteArray();
					_rawData.endian = "littleEndian";
					_rawData.length = _initialCapacity * 2;
					_rawData.length = _numIndices * 2;
				}
				if(_numIndices) {
					_rawData.writeBytes(sQuadData,0,_numIndices * 2);
				}
			}
		}
		
		private function ensureQuadDataCapacity(numIndices:int) : void {
			var _local2:* = 0;
			if(sQuadDataNumIndices >= numIndices) {
				return;
			}
			var _local4:int = sQuadDataNumIndices / 6;
			var _local3:int = Math.ceil(numIndices / 6);
			sQuadData.endian = "littleEndian";
			sQuadData.position = sQuadData.length;
			sQuadDataNumIndices = _local3 * 6;
			_local2 = _local4;
			while(_local2 < _local3) {
				sQuadData.writeShort(4 * _local2);
				sQuadData.writeShort(4 * _local2 + 1);
				sQuadData.writeShort(4 * _local2 + 2);
				sQuadData.writeShort(4 * _local2 + 1);
				sQuadData.writeShort(4 * _local2 + 3);
				sQuadData.writeShort(4 * _local2 + 2);
				_local2++;
			}
		}
		
		public function createIndexBuffer(upload:Boolean = false, bufferUsage:String = "staticDraw") : IndexBuffer3D {
			var _local3:Context3D = Starling.context;
			if(_local3 == null) {
				throw new MissingContextError();
			}
			if(_numIndices == 0) {
				return null;
			}
			var _local4:IndexBuffer3D = _local3.createIndexBuffer(_numIndices,bufferUsage);
			if(upload) {
				uploadToIndexBuffer(_local4);
			}
			return _local4;
		}
		
		public function uploadToIndexBuffer(buffer:IndexBuffer3D, indexID:int = 0, numIndices:int = -1) : void {
			if(numIndices < 0 || indexID + numIndices > _numIndices) {
				numIndices = _numIndices - indexID;
			}
			if(numIndices > 0) {
				buffer.uploadFromByteArray(rawData,0,indexID,numIndices);
			}
		}
		
		public function trim() : void {
			if(_useQuadLayout) {
				return;
			}
			sTrimData.length = _rawData.length;
			sTrimData.position = 0;
			sTrimData.writeBytes(_rawData);
			_rawData.clear();
			_rawData.length = sTrimData.length;
			_rawData.writeBytes(sTrimData);
			sTrimData.clear();
		}
		
		public function get numIndices() : int {
			return _numIndices;
		}
		
		public function set numIndices(value:int) : void {
			if(value != _numIndices) {
				if(_useQuadLayout) {
					ensureQuadDataCapacity(value);
				} else {
					_rawData.length = value * 2;
				}
				if(value == 0) {
					_useQuadLayout = true;
				}
				_numIndices = value;
			}
		}
		
		public function get numTriangles() : int {
			return _numIndices / 3;
		}
		
		public function set numTriangles(value:int) : void {
			numIndices = value * 3;
		}
		
		public function get numQuads() : int {
			return _numIndices / 6;
		}
		
		public function set numQuads(value:int) : void {
			numIndices = value * 6;
		}
		
		public function get indexSizeInBytes() : int {
			return 2;
		}
		
		public function get useQuadLayout() : Boolean {
			return _useQuadLayout;
		}
		
		public function set useQuadLayout(value:Boolean) : void {
			if(value != _useQuadLayout) {
				if(value) {
					ensureQuadDataCapacity(_numIndices);
					_rawData.length = 0;
					_useQuadLayout = true;
				} else {
					switchToGenericData();
				}
			}
		}
		
		public function get rawData() : ByteArray {
			if(_useQuadLayout) {
				return sQuadData;
			}
			return _rawData;
		}
	}
}

