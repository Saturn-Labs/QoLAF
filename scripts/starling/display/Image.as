package starling.display {
	import flash.geom.Rectangle;
	import starling.rendering.IndexData;
	import starling.rendering.VertexData;
	import starling.textures.Texture;
	import starling.utils.MathUtil;
	import starling.utils.Padding;
	import starling.utils.Pool;
	import starling.utils.RectangleUtil;
	
	public class Image extends Quad {
		private static var sPadding:Padding = new Padding();
		
		private static var sBounds:Rectangle = new Rectangle();
		
		private static var sBasCols:Vector.<Number> = new Vector.<Number>(3,true);
		
		private static var sBasRows:Vector.<Number> = new Vector.<Number>(3,true);
		
		private static var sPosCols:Vector.<Number> = new Vector.<Number>(3,true);
		
		private static var sPosRows:Vector.<Number> = new Vector.<Number>(3,true);
		
		private static var sTexCols:Vector.<Number> = new Vector.<Number>(3,true);
		
		private static var sTexRows:Vector.<Number> = new Vector.<Number>(3,true);
		
		private var _scale9Grid:Rectangle;
		
		private var _tileGrid:Rectangle;
		
		public function Image(texture:Texture) {
			super(100,100);
			this.texture = texture;
			readjustSize();
		}
		
		public function get scale9Grid() : Rectangle {
			return _scale9Grid;
		}
		
		public function set scale9Grid(value:Rectangle) : void {
			if(value) {
				if(_scale9Grid == null) {
					_scale9Grid = value.clone();
				} else {
					_scale9Grid.copyFrom(value);
				}
				readjustSize();
				_tileGrid = null;
			} else {
				_scale9Grid = null;
			}
			setupVertices();
		}
		
		public function get tileGrid() : Rectangle {
			return _tileGrid;
		}
		
		public function set tileGrid(value:Rectangle) : void {
			if(value) {
				if(_tileGrid == null) {
					_tileGrid = value.clone();
				} else {
					_tileGrid.copyFrom(value);
				}
				_scale9Grid = null;
			} else {
				_tileGrid = null;
			}
			setupVertices();
		}
		
		override protected function setupVertices() : void {
			if(texture && _scale9Grid) {
				setupScale9Grid();
			} else if(texture && _tileGrid) {
				setupTileGrid();
			} else {
				super.setupVertices();
			}
		}
		
		override public function set scaleX(value:Number) : void {
			super.scaleX = value;
			if(texture && (_scale9Grid || _tileGrid)) {
				setupVertices();
			}
		}
		
		override public function set scaleY(value:Number) : void {
			super.scaleY = value;
			if(texture && (_scale9Grid || _tileGrid)) {
				setupVertices();
			}
		}
		
		override public function set texture(value:Texture) : void {
			if(value != texture) {
				super.texture = value;
				if(_scale9Grid && value) {
					readjustSize();
				}
			}
		}
		
		private function setupScale9Grid() : void {
			var _local1:int = 0;
			var _local10:int = 0;
			var _local18:Number = NaN;
			var _local6:int = 0;
			var _local3:* = 0;
			var _local17:Number = NaN;
			var _local4:Texture = this.texture;
			var _local19:Rectangle = _local4.frame;
			var _local9:Number = scaleX > 0 ? scaleX : -scaleX;
			var _local11:Number = scaleY > 0 ? scaleY : -scaleY;
			if(MathUtil.isEquivalent(_scale9Grid.width,_local4.frameWidth)) {
				_local11 /= _local9;
			} else if(MathUtil.isEquivalent(_scale9Grid.height,_local4.frameHeight)) {
				_local9 /= _local11;
			}
			var _local7:Number = 1 / _local9;
			var _local13:Number = 1 / _local11;
			var _local5:VertexData = this.vertexData;
			var _local8:IndexData = this.indexData;
			var _local2:int = _local5.numVertices;
			var _local12:Rectangle = Pool.getRectangle();
			var _local14:Rectangle = Pool.getRectangle();
			var _local15:Rectangle = Pool.getRectangle();
			var _local16:Rectangle = Pool.getRectangle();
			_local12.copyFrom(_scale9Grid);
			_local14.setTo(0,0,_local4.frameWidth,_local4.frameHeight);
			if(_local19) {
				_local15.setTo(-_local19.x,-_local19.y,_local4.width,_local4.height);
			} else {
				_local15.copyFrom(_local14);
			}
			RectangleUtil.intersect(_local12,_local15,_local16);
			sBasCols[0] = sBasCols[2] = 0;
			sBasRows[0] = sBasRows[2] = 0;
			sBasCols[1] = _local16.width;
			sBasRows[1] = _local16.height;
			if(_local15.x < _local12.x) {
				sBasCols[0] = _local12.x - _local15.x;
			}
			if(_local15.y < _local12.y) {
				sBasRows[0] = _local12.y - _local15.y;
			}
			if(_local15.right > _local12.right) {
				sBasCols[2] = _local15.right - _local12.right;
			}
			if(_local15.bottom > _local12.bottom) {
				sBasRows[2] = _local15.bottom - _local12.bottom;
			}
			if(_local15.x < _local12.x) {
				sPadding.left = _local15.x * _local7;
			} else {
				sPadding.left = _local12.x * _local7 + _local15.x - _local12.x;
			}
			if(_local15.right > _local12.right) {
				sPadding.right = (_local14.width - _local15.right) * _local7;
			} else {
				sPadding.right = (_local14.width - _local12.right) * _local7 + _local12.right - _local15.right;
			}
			if(_local15.y < _local12.y) {
				sPadding.top = _local15.y * _local13;
			} else {
				sPadding.top = _local12.y * _local13 + _local15.y - _local12.y;
			}
			if(_local15.bottom > _local12.bottom) {
				sPadding.bottom = (_local14.height - _local15.bottom) * _local13;
			} else {
				sPadding.bottom = (_local14.height - _local12.bottom) * _local13 + _local12.bottom - _local15.bottom;
			}
			sPosCols[0] = sBasCols[0] * _local7;
			sPosCols[2] = sBasCols[2] * _local7;
			sPosCols[1] = _local14.width - sPadding.left - sPadding.right - sPosCols[0] - sPosCols[2];
			sPosRows[0] = sBasRows[0] * _local13;
			sPosRows[2] = sBasRows[2] * _local13;
			sPosRows[1] = _local14.height - sPadding.top - sPadding.bottom - sPosRows[0] - sPosRows[2];
			if(sPosCols[1] <= 0) {
				_local18 = _local14.width / (_local14.width - _local12.width) * _local9;
				sPadding.left *= _local18;
				sPosCols[0] *= _local18;
				sPosCols[1] = 0;
				sPosCols[2] *= _local18;
			}
			if(sPosRows[1] <= 0) {
				_local18 = _local14.height / (_local14.height - _local12.height) * _local11;
				sPadding.top *= _local18;
				sPosRows[0] *= _local18;
				sPosRows[1] = 0;
				sPosRows[2] *= _local18;
			}
			sTexCols[0] = sBasCols[0] / _local15.width;
			sTexCols[2] = sBasCols[2] / _local15.width;
			sTexCols[1] = 1 - sTexCols[0] - sTexCols[2];
			sTexRows[0] = sBasRows[0] / _local15.height;
			sTexRows[2] = sBasRows[2] / _local15.height;
			sTexRows[1] = 1 - sTexRows[0] - sTexRows[2];
			_local10 = setupScale9GridAttributes(sPadding.left,sPadding.top,sPosCols,sPosRows,sTexCols,sTexRows);
			_local1 = _local10 / 4;
			_local5.numVertices = _local10;
			_local8.numIndices = 0;
			_local6 = 0;
			while(_local6 < _local1) {
				_local8.addQuad(_local6 * 4,_local6 * 4 + 1,_local6 * 4 + 2,_local6 * 4 + 3);
				_local6++;
			}
			if(_local10 != _local2) {
				_local3 = uint(!!_local2 ? _local5.getColor(0) : 0xffffff);
				_local17 = !!_local2 ? _local5.getAlpha(0) : 1;
				_local5.colorize("color",_local3,_local17);
			}
			Pool.putRectangle(_local14);
			Pool.putRectangle(_local15);
			Pool.putRectangle(_local12);
			Pool.putRectangle(_local16);
			setRequiresRedraw();
		}
		
		private function setupScale9GridAttributes(startX:Number, startY:Number, posCols:Vector.<Number>, posRows:Vector.<Number>, texCols:Vector.<Number>, texRows:Vector.<Number>) : int {
			var _local13:String = null;
			_local13 = "position";
			var _local21:String = null;
			_local21 = "texCoords";
			var _local7:int = 0;
			var _local20:int = 0;
			var _local12:Number = NaN;
			var _local19:Number = NaN;
			var _local18:Number = NaN;
			var _local15:Number = NaN;
			var _local10:VertexData = this.vertexData;
			var _local9:Texture = this.texture;
			var _local14:* = startX;
			var _local11:* = startY;
			var _local17:Number = 0;
			var _local16:Number = 0;
			var _local8:int = 0;
			_local20 = 0;
			while(_local20 < 3) {
				_local12 = posRows[_local20];
				_local18 = texRows[_local20];
				if(_local12 > 0) {
					_local7 = 0;
					while(_local7 < 3) {
						_local19 = posCols[_local7];
						_local15 = texCols[_local7];
						if(_local19 > 0) {
							_local10.setPoint(_local8,"position",_local14,_local11);
							_local9.setTexCoords(_local10,_local8,"texCoords",_local17,_local16);
							_local8++;
							_local10.setPoint(_local8,"position",_local14 + _local19,_local11);
							_local9.setTexCoords(_local10,_local8,"texCoords",_local17 + _local15,_local16);
							_local8++;
							_local10.setPoint(_local8,"position",_local14,_local11 + _local12);
							_local9.setTexCoords(_local10,_local8,"texCoords",_local17,_local16 + _local18);
							_local8++;
							_local10.setPoint(_local8,"position",_local14 + _local19,_local11 + _local12);
							_local9.setTexCoords(_local10,_local8,"texCoords",_local17 + _local15,_local16 + _local18);
							_local8++;
							_local14 += _local19;
						}
						_local17 += _local15;
						_local7++;
					}
					_local11 += _local12;
				}
				_local14 = startX;
				_local17 = 0;
				_local16 += _local18;
				_local20++;
			}
			return _local8;
		}
		
		private function setupTileGrid() : void {
			var _local12:Number = NaN;
			var _local7:Number = NaN;
			var _local24:Number = NaN;
			var _local18:Number = NaN;
			var _local25:Number = NaN;
			var _local10:Number = NaN;
			var _local2:Number = NaN;
			var _local16:Number = NaN;
			var _local27:* = NaN;
			var _local21:* = 0;
			var _local17:Texture = this.texture;
			var _local32:Rectangle = _local17.frame;
			var _local20:VertexData = this.vertexData;
			var _local4:IndexData = this.indexData;
			var _local28:Rectangle = getBounds(this,sBounds);
			var _local13:int = _local20.numVertices;
			var _local1:uint = uint(!!_local13 ? _local20.getColor(0) : 0xffffff);
			var _local9:Number = !!_local13 ? _local20.getAlpha(0) : 1;
			var _local22:Number = scaleX > 0 ? 1 / scaleX : -1 / scaleX;
			var _local8:Number = scaleY > 0 ? 1 / scaleY : -1 / scaleY;
			var _local26:Number = _tileGrid.width > 0 ? _tileGrid.width : _local17.frameWidth;
			var _local11:Number = _tileGrid.height > 0 ? _tileGrid.height : _local17.frameHeight;
			_local26 *= _local22;
			_local11 *= _local8;
			var _local31:Number = !!_local32 ? -_local32.x * (_local26 / _local32.width) : 0;
			var _local33:Number = !!_local32 ? -_local32.y * (_local11 / _local32.height) : 0;
			var _local23:Number = _local17.width * (_local26 / _local17.frameWidth);
			var _local34:Number = _local17.height * (_local11 / _local17.frameHeight);
			var _local15:Number = _tileGrid.x * _local22 % _local26;
			var _local14:Number = _tileGrid.y * _local8 % _local11;
			if(_local15 < 0) {
				_local15 += _local26;
			}
			if(_local14 < 0) {
				_local14 += _local11;
			}
			var _local30:Number = _local15 + _local31;
			var _local29:Number = _local14 + _local33;
			if(_local30 > _local26 - _local23) {
				_local30 -= _local26;
			}
			if(_local29 > _local11 - _local34) {
				_local29 -= _local11;
			}
			var _local6:String = "position";
			var _local19:String = "texCoords";
			var _local5:* = _local29;
			var _local3:int = 0;
			_local4.numIndices = 0;
			while(_local5 < _local28.height) {
				_local27 = _local30;
				while(_local27 < _local28.width) {
					_local4.addQuad(_local3,_local3 + 1,_local3 + 2,_local3 + 3);
					_local18 = _local27 < 0 ? 0 : _local27;
					_local7 = _local5 < 0 ? 0 : _local5;
					_local12 = _local27 + _local23 > _local28.width ? _local28.width : _local27 + _local23;
					_local24 = _local5 + _local34 > _local28.height ? _local28.height : _local5 + _local34;
					_local20.setPoint(_local3,_local6,_local18,_local7);
					_local20.setPoint(_local3 + 1,_local6,_local12,_local7);
					_local20.setPoint(_local3 + 2,_local6,_local18,_local24);
					_local20.setPoint(_local3 + 3,_local6,_local12,_local24);
					_local16 = (_local18 - _local27) / _local23;
					_local10 = (_local7 - _local5) / _local34;
					_local25 = (_local12 - _local27) / _local23;
					_local2 = (_local24 - _local5) / _local34;
					_local17.setTexCoords(_local20,_local3,_local19,_local16,_local10);
					_local17.setTexCoords(_local20,_local3 + 1,_local19,_local25,_local10);
					_local17.setTexCoords(_local20,_local3 + 2,_local19,_local16,_local2);
					_local17.setTexCoords(_local20,_local3 + 3,_local19,_local25,_local2);
					_local27 += _local26;
					_local3 += 4;
				}
				_local5 += _local11;
			}
			_local20.numVertices = _local3;
			_local21 = _local13;
			while(_local21 < _local3) {
				_local20.setColor(_local21,"color",_local1);
				_local20.setAlpha(_local21,"color",_local9);
				_local21++;
			}
			setRequiresRedraw();
		}
	}
}

