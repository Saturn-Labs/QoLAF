package starling.geom {
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	import starling.rendering.IndexData;
	import starling.rendering.VertexData;
	import starling.utils.MathUtil;
	import starling.utils.Pool;
	
	public class Polygon {
		private static var sRestIndices:Vector.<uint> = new Vector.<uint>(0);
		
		private var _coords:Vector.<Number>;
		
		public function Polygon(vertices:Array = null) {
			super();
			_coords = new Vector.<Number>(0);
			addVertices.apply(this,vertices);
		}
		
		public static function createEllipse(x:Number, y:Number, radiusX:Number, radiusY:Number) : Polygon {
			return new Ellipse(x,y,radiusX,radiusY);
		}
		
		public static function createCircle(x:Number, y:Number, radius:Number) : Polygon {
			return new Ellipse(x,y,radius,radius);
		}
		
		public static function createRectangle(x:Number, y:Number, width:Number, height:Number) : Polygon {
			return new Rectangle(x,y,width,height);
		}
		
		private static function isConvexTriangle(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number) : Boolean {
			return (ay - by) * (cx - bx) + (bx - ax) * (cy - by) >= 0;
		}
		
		private static function areVectorsIntersecting(ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, dx:Number, dy:Number) : Boolean {
			if(ax == bx && ay == by || cx == dx && cy == dy) {
				return false;
			}
			var _local12:Number = bx - ax;
			var _local14:Number = by - ay;
			var _local13:Number = dx - cx;
			var _local15:Number = dy - cy;
			var _local9:Number = _local15 * _local12 - _local13 * _local14;
			if(_local9 == 0) {
				return false;
			}
			var _local11:Number = (_local14 * (cx - ax) - _local12 * (cy - ay)) / _local9;
			if(_local11 < 0 || _local11 > 1) {
				return false;
			}
			var _local10:Number = !!_local14 ? (cy - ay + _local11 * _local15) / _local14 : (cx - ax + _local11 * _local13) / _local12;
			return _local10 >= 0 && _local10 <= 1;
		}
		
		public function clone() : Polygon {
			var _local3:int = 0;
			var _local1:Polygon = new Polygon();
			var _local2:int = int(_coords.length);
			_local3 = 0;
			while(_local3 < _local2) {
				_local1._coords[_local3] = _coords[_local3];
				_local3++;
			}
			return _local1;
		}
		
		public function reverse() : void {
			var _local2:Number = NaN;
			var _local4:int = 0;
			var _local3:int = int(_coords.length);
			var _local1:int = _local3 / 2;
			_local4 = 0;
			while(_local4 < _local1) {
				_local2 = _coords[_local4];
				_coords[_local4] = _coords[_local3 - _local4 - 2];
				_coords[_local3 - _local4 - 2] = _local2;
				_local2 = _coords[_local4 + 1];
				_coords[_local4 + 1] = _coords[_local3 - _local4 - 1];
				_coords[_local3 - _local4 - 1] = _local2;
				_local4 += 2;
			}
		}
		
		public function addVertices(... rest) : void {
			var _local3:int = 0;
			var _local2:int = int(rest.length);
			var _local4:int = int(_coords.length);
			if(_local2 > 0) {
				if(rest[0] is Point) {
					_local3 = 0;
					while(_local3 < _local2) {
						_coords[_local4 + _local3 * 2] = (rest[_local3] as Point).x;
						_coords[_local4 + _local3 * 2 + 1] = (rest[_local3] as Point).y;
						_local3++;
					}
				} else {
					if(!(rest[0] is Number)) {
						throw new ArgumentError("Invalid type: " + getQualifiedClassName(rest[0]));
					}
					_local3 = 0;
					while(_local3 < _local2) {
						_coords[_local4 + _local3] = rest[_local3];
						_local3++;
					}
				}
			}
		}
		
		public function setVertex(index:int, x:Number, y:Number) : void {
			if(index >= 0 && index <= numVertices) {
				_coords[index * 2] = x;
				_coords[index * 2 + 1] = y;
				return;
			}
			throw new RangeError("Invalid index: " + index);
		}
		
		public function getVertex(index:int, out:Point = null) : Point {
			if(index >= 0 && index < numVertices) {
				if(!out) {
					out = new Point();
				}
				out.setTo(_coords[index * 2],_coords[index * 2 + 1]);
				return out;
			}
			throw new RangeError("Invalid index: " + index);
		}
		
		public function contains(x:Number, y:Number) : Boolean {
			var _local5:int = 0;
			var _local8:Number = NaN;
			var _local3:Number = NaN;
			var _local7:Number = NaN;
			var _local9:Number = NaN;
			var _local6:* = numVertices - 1;
			var _local4:uint = 0;
			_local5 = 0;
			while(_local5 < numVertices) {
				_local8 = _coords[_local5 * 2];
				_local3 = _coords[_local5 * 2 + 1];
				_local7 = _coords[_local6 * 2];
				_local9 = _coords[_local6 * 2 + 1];
				if((_local3 < y && _local9 >= y || _local9 < y && _local3 >= y) && (_local8 <= x || _local7 <= x)) {
					_local4 ^= uint(_local8 + (y - _local3) / (_local9 - _local3) * (_local7 - _local8) < x);
				}
				_local6 = _local5;
				_local5++;
			}
			return _local4 != 0;
		}
		
		public function containsPoint(point:Point) : Boolean {
			return contains(point.x,point.y);
		}
		
		public function triangulate(indexData:IndexData = null, offset:int = 0) : IndexData {
			var _local16:int = 0;
			var _local13:* = 0;
			var _local11:int = 0;
			var _local9:* = 0;
			var _local6:Boolean = false;
			var _local7:* = 0;
			var _local10:* = 0;
			var _local12:* = 0;
			var _local14:int = this.numVertices;
			var _local8:int = this.numTriangles;
			if(indexData == null) {
				indexData = new IndexData(_local8 * 3);
			}
			if(_local8 == 0) {
				return indexData;
			}
			sRestIndices.length = _local14;
			_local11 = 0;
			while(_local11 < _local14) {
				sRestIndices[_local11] = _local11;
				_local11++;
			}
			_local16 = 0;
			_local13 = _local14;
			var _local3:Point = Pool.getPoint();
			var _local4:Point = Pool.getPoint();
			var _local5:Point = Pool.getPoint();
			var _local15:Point = Pool.getPoint();
			while(_local13 > 3) {
				_local6 = false;
				_local7 = sRestIndices[_local16 % _local13];
				_local10 = sRestIndices[(_local16 + 1) % _local13];
				_local12 = sRestIndices[(_local16 + 2) % _local13];
				_local3.setTo(_coords[2 * _local7],_coords[2 * _local7 + 1]);
				_local4.setTo(_coords[2 * _local10],_coords[2 * _local10 + 1]);
				_local5.setTo(_coords[2 * _local12],_coords[2 * _local12 + 1]);
				if(isConvexTriangle(_local3.x,_local3.y,_local4.x,_local4.y,_local5.x,_local5.y)) {
					_local6 = true;
					_local11 = 3;
					while(_local11 < _local13) {
						_local9 = sRestIndices[(_local16 + _local11) % _local13];
						_local15.setTo(_coords[2 * _local9],_coords[2 * _local9 + 1]);
						if(MathUtil.isPointInTriangle(_local15,_local3,_local4,_local5)) {
							_local6 = false;
							break;
						}
						_local11++;
					}
				}
				if(_local6) {
					indexData.addTriangle(_local7 + offset,_local10 + offset,_local12 + offset);
					sRestIndices.removeAt((_local16 + 1) % _local13);
					_local13--;
					_local16 = 0;
				} else {
					_local16++;
					if(_local16 == _local13) {
						break;
					}
				}
			}
			Pool.putPoint(_local3);
			Pool.putPoint(_local4);
			Pool.putPoint(_local5);
			Pool.putPoint(_local15);
			indexData.addTriangle(sRestIndices[0] + offset,sRestIndices[1] + offset,sRestIndices[2] + offset);
			return indexData;
		}
		
		public function copyToVertexData(target:VertexData = null, targetVertexID:int = 0, attrName:String = "position") : void {
			var _local6:int = 0;
			var _local4:int = this.numVertices;
			var _local5:int = targetVertexID + _local4;
			if(target.numVertices < _local5) {
				target.numVertices = _local5;
			}
			_local6 = 0;
			while(_local6 < _local4) {
				target.setPoint(targetVertexID + _local6,attrName,_coords[_local6 * 2],_coords[_local6 * 2 + 1]);
				_local6++;
			}
		}
		
		public function toString() : String {
			var _local3:int = 0;
			var _local1:String = "[Polygon";
			var _local2:int = this.numVertices;
			if(_local2 > 0) {
				_local1 += "\n";
			}
			_local3 = 0;
			while(_local3 < _local2) {
				_local1 += "  [Vertex " + _local3 + ": " + "x=" + _coords[_local3 * 2].toFixed(1) + ", " + "y=" + _coords[_local3 * 2 + 1].toFixed(1) + "]" + (_local3 == _local2 - 1 ? "\n" : ",\n");
				_local3++;
			}
			return _local1 + "]";
		}
		
		public function get isSimple() : Boolean {
			var _local11:int = 0;
			var _local7:Number = NaN;
			var _local9:Number = NaN;
			var _local5:Number = NaN;
			var _local8:Number = NaN;
			var _local1:Number = NaN;
			var _local12:int = 0;
			var _local3:Number = NaN;
			var _local6:Number = NaN;
			var _local2:Number = NaN;
			var _local4:Number = NaN;
			var _local10:int = int(_coords.length);
			if(_local10 <= 6) {
				return true;
			}
			_local11 = 0;
			while(_local11 < _local10) {
				_local7 = _coords[_local11];
				_local9 = _coords[_local11 + 1];
				_local5 = _coords[(_local11 + 2) % _local10];
				_local8 = _coords[(_local11 + 3) % _local10];
				_local1 = _local11 + _local10 - 2;
				_local12 = _local11 + 4;
				while(_local12 < _local1) {
					_local3 = _coords[_local12 % _local10];
					_local6 = _coords[(_local12 + 1) % _local10];
					_local2 = _coords[(_local12 + 2) % _local10];
					_local4 = _coords[(_local12 + 3) % _local10];
					if(areVectorsIntersecting(_local7,_local9,_local5,_local8,_local3,_local6,_local2,_local4)) {
						return false;
					}
					_local12 += 2;
				}
				_local11 += 2;
			}
			return true;
		}
		
		public function get isConvex() : Boolean {
			var _local2:int = 0;
			var _local1:int = int(_coords.length);
			if(_local1 < 6) {
				return true;
			}
			_local2 = 0;
			while(_local2 < _local1) {
				if(!isConvexTriangle(_coords[_local2],_coords[_local2 + 1],_coords[(_local2 + 2) % _local1],_coords[(_local2 + 3) % _local1],_coords[(_local2 + 4) % _local1],_coords[(_local2 + 5) % _local1])) {
					return false;
				}
				_local2 += 2;
			}
			return true;
		}
		
		public function get area() : Number {
			var _local3:int = 0;
			var _local1:Number = 0;
			var _local2:int = int(_coords.length);
			if(_local2 >= 6) {
				_local3 = 0;
				while(_local3 < _local2) {
					_local1 += _coords[_local3] * _coords[(_local3 + 3) % _local2];
					_local1 -= _coords[_local3 + 1] * _coords[(_local3 + 2) % _local2];
					_local3 += 2;
				}
			}
			return _local1 / 2;
		}
		
		public function get numVertices() : int {
			return _coords.length / 2;
		}
		
		public function set numVertices(value:int) : void {
			var _local3:* = 0;
			var _local2:int = numVertices;
			_coords.length = value * 2;
			if(_local2 < value) {
				_local3 = _local2;
				while(_local3 < value) {
					_coords[_local3 * 2] = _coords[_local3 * 2 + 1] = 0;
					_local3++;
				}
			}
		}
		
		public function get numTriangles() : int {
			var _local1:int = this.numVertices;
			return _local1 >= 3 ? _local1 - 2 : 0;
		}
	}
}

import flash.errors.IllegalOperationError;
import flash.utils.getQualifiedClassName;
import starling.rendering.IndexData;

class ImmutablePolygon extends Polygon {
	private var _frozen:Boolean;
	
	public function ImmutablePolygon(vertices:Array) {
		super(vertices);
		_frozen = true;
	}
	
	override public function addVertices(... rest) : void {
		if(_frozen) {
			throw getImmutableError();
		}
		super.addVertices.apply(this,rest);
	}
	
	override public function setVertex(index:int, x:Number, y:Number) : void {
		if(_frozen) {
			throw getImmutableError();
		}
		super.setVertex(index,x,y);
	}
	
	override public function reverse() : void {
		if(_frozen) {
			throw getImmutableError();
		}
		super.reverse();
	}
	
	override public function set numVertices(value:int) : void {
		if(_frozen) {
			throw getImmutableError();
		}
		super.reverse();
	}
	
	private function getImmutableError() : Error {
		var _local2:String = getQualifiedClassName(this).split("::").pop();
		var _local1:String = _local2 + " cannot be modified. Call \'clone\' to create a mutable copy.";
		return new IllegalOperationError(_local1);
	}
}

class Ellipse extends ImmutablePolygon {
	private var _x:Number;
	
	private var _y:Number;
	
	private var _radiusX:Number;
	
	private var _radiusY:Number;
	
	public function Ellipse(x:Number, y:Number, radiusX:Number, radiusY:Number, numSides:int = -1) {
		_x = x;
		_y = y;
		_radiusX = radiusX;
		_radiusY = radiusY;
		super(getVertices(numSides));
	}
	
	private function getVertices(numSides:int) : Array {
		var _local5:int = 0;
		if(numSides < 0) {
			numSides = 3.141592653589793 * (_radiusX + _radiusY) / 4;
		}
		if(numSides < 6) {
			numSides = 6;
		}
		var _local2:Array = [];
		var _local3:Number = 2 * 3.141592653589793 / numSides;
		var _local4:Number = 0;
		_local5 = 0;
		while(_local5 < numSides) {
			_local2[_local5 * 2] = Math.cos(_local4) * _radiusX + _x;
			_local2[_local5 * 2 + 1] = Math.sin(_local4) * _radiusY + _y;
			_local4 += _local3;
			_local5++;
		}
		return _local2;
	}
	
	override public function triangulate(indexData:IndexData = null, offset:int = 0) : IndexData {
		var _local3:int = 0;
		if(indexData == null) {
			indexData = new IndexData((numVertices - 2) * 3);
		}
		var _local4:uint = 1;
		var _local5:uint = numVertices - 1;
		_local3 = int(_local4);
		while(_local3 < _local5) {
			indexData.addTriangle(offset,offset + _local3,offset + _local3 + 1);
			_local3++;
		}
		return indexData;
	}
	
	override public function contains(x:Number, y:Number) : Boolean {
		var _local4:Number = x - _x;
		var _local6:Number = y - _y;
		var _local3:Number = _local4 / _radiusX;
		var _local5:Number = _local6 / _radiusY;
		return _local3 * _local3 + _local5 * _local5 <= 1;
	}
	
	override public function get area() : Number {
		return 3.141592653589793 * _radiusX * _radiusY;
	}
	
	override public function get isSimple() : Boolean {
		return true;
	}
	
	override public function get isConvex() : Boolean {
		return true;
	}
}

class Rectangle extends ImmutablePolygon {
	private var _x:Number;
	
	private var _y:Number;
	
	private var _width:Number;
	
	private var _height:Number;
	
	public function Rectangle(x:Number, y:Number, width:Number, height:Number) {
		_x = x;
		_y = y;
		_width = width;
		_height = height;
		super([x,y,x + width,y,x + width,y + height,x,y + height]);
	}
	
	override public function triangulate(indexData:IndexData = null, offset:int = 0) : IndexData {
		if(indexData == null) {
			indexData = new IndexData(6);
		}
		indexData.addTriangle(offset,offset + 1,offset + 3);
		indexData.addTriangle(offset + 1,offset + 2,offset + 3);
		return indexData;
	}
	
	override public function contains(x:Number, y:Number) : Boolean {
		return x >= _x && x <= _x + _width && y >= _y && y <= _y + _height;
	}
	
	override public function get area() : Number {
		return _width * _height;
	}
	
	override public function get isSimple() : Boolean {
		return true;
	}
	
	override public function get isConvex() : Boolean {
		return true;
	}
}
