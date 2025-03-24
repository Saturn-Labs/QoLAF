package core.hud.components {
	import core.scene.Game;
	import starling.display.MeshBatch;
	
	public class BeamLine extends MeshBatch {
		private var period:int = 100;
		
		public var nodeFrequence:int;
		
		public var thickness:Number;
		
		public var amplitude:Number;
		
		private var ampFactor:Number;
		
		private var glowWidth:Number;
		
		private var glowColor:Number;
		
		private var _color:uint;
		
		private var lineTexture:String;
		
		private var lines:Vector.<Line> = new Vector.<Line>();
		
		private var g:Game;
		
		public function BeamLine(g:Game) {
			super();
			this.g = g;
		}
		
		public function init(thickness:Number = 3, nodeFrequence:int = 3, amplitude:Number = 2, color:uint = 16777215, alpha:Number = 1, glowWidth:Number = 3, glowColor:uint = 16711680, lineTexture:String = "line2") : void {
			this.thickness = thickness * 2;
			this.nodeFrequence = nodeFrequence;
			this.amplitude = amplitude;
			this.ampFactor = ampFactor;
			this.alpha = alpha;
			this.glowWidth = glowWidth;
			this.glowColor = glowColor;
			this.lineTexture = lineTexture;
			this.blendMode = "add";
			_color = color;
			this.touchable = true;
		}
		
		public function lineTo(toX:Number, toY:Number, chargeUpEffect:Number = 1) : void {
			var _local9:int = 0;
			var _local11:Line = null;
			var _local15:int = 0;
			var _local8:Line = null;
			var _local13:Number = NaN;
			var _local12:Number = NaN;
			var _local6:Number = toX - x;
			var _local7:Number = toY - y;
			var _local16:Number = _local6 * _local6 + _local7 * _local7;
			var _local14:Number = Math.sqrt(_local16);
			var _local10:Number = Math.round(_local14 / period * nodeFrequence);
			if(_local10 == 0) {
				_local10 = 1;
			}
			if(_local10 > lines.length) {
				_local15 = _local10 - lines.length;
				_local9 = 0;
				while(_local9 < _local15) {
					_local11 = g.linePool.getLine();
					_local11.init(lineTexture,thickness,color,1,true);
					_local11.blendMode = "add";
					lines.push(_local11);
					_local9++;
				}
			} else if(_local10 < lines.length) {
				_local9 = _local10;
				while(_local9 < lines.length) {
					g.linePool.removeLine(lines[_local9]);
					_local9++;
				}
				lines.length = _local10;
			}
			super.clear();
			var _local4:* = 0;
			var _local5:* = 0;
			_local9 = 0;
			while(_local9 < lines.length) {
				_local8 = lines[_local9];
				_local13 = 2 - Math.abs((_local10 / 2 - _local9) / _local10) * 2;
				_local8.x = _local4;
				_local8.y = _local5;
				_local12 = (_local9 + 1) / _local10;
				_local4 = _local6 * _local12 + (amplitude - Math.random() * amplitude * 2) * _local13;
				_local5 = _local7 * _local12 + (amplitude - Math.random() * amplitude * 2) * _local13;
				if(_local9 == _local10 - 1) {
					_local4 = _local6;
					_local5 = _local7;
				}
				_local8.lineTo(_local4,_local5);
				_local8.thickness = thickness + chargeUpEffect;
				this.addMesh(_local8);
				_local9++;
			}
		}
		
		override public function set touchable(value:Boolean) : void {
			var _local2:int = 0;
			var _local3:Line = null;
			_local2 = 0;
			while(_local2 < lines.length) {
				_local3 = lines[0];
				_local3.touchable = value;
				_local2++;
			}
			super.touchable = value;
		}
		
		override public function clear() : void {
			var _local1:int = 0;
			super.clear();
			_local1 = 0;
			while(_local1 < lines.length) {
				g.linePool.removeLine(lines[_local1]);
				_local1++;
			}
			lines.length = 0;
		}
		
		override public function set color(value:uint) : void {
			var _local2:int = 0;
			var _local3:Line = null;
			_local2 = 0;
			while(_local2 < lines.length) {
				_local3 = lines[_local2];
				_local3.color = value;
				_local2++;
			}
			_color = value;
		}
		
		override public function get color() : uint {
			return _color;
		}
	}
}

