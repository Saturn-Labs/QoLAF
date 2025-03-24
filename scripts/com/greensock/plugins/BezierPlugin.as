package com.greensock.plugins {
	import com.greensock.TweenLite;
	import flash.geom.Point;
	
	public class BezierPlugin extends TweenPlugin {
		public static const API:Number = 2;
		
		protected static const _RAD2DEG:Number = 57.29577951308232;
		
		protected static var _r1:Array = [];
		
		protected static var _r2:Array = [];
		
		protected static var _r3:Array = [];
		
		protected static var _corProps:Object = {};
		
		protected var _target:Object;
		
		protected var _autoRotate:Array;
		
		protected var _round:Object;
		
		protected var _lengths:Array;
		
		protected var _segments:Array;
		
		protected var _length:Number;
		
		protected var _func:Object;
		
		protected var _props:Array;
		
		protected var _l1:Number;
		
		protected var _l2:Number;
		
		protected var _li:Number;
		
		protected var _curSeg:Array;
		
		protected var _s1:Number;
		
		protected var _s2:Number;
		
		protected var _si:Number;
		
		protected var _beziers:Object;
		
		protected var _segCount:int;
		
		protected var _prec:Number;
		
		protected var _timeRes:int;
		
		protected var _initialRotations:Array;
		
		protected var _startRatio:int;
		
		public function BezierPlugin() {
			super("bezier");
			this._overwriteProps.pop();
			this._func = {};
			this._round = {};
		}
		
		public static function bezierThrough(values:Array, curviness:Number = 1, quadratic:Boolean = false, basic:Boolean = false, correlate:String = "x,y,z", prepend:Object = null) : Object {
			var _local13:Array = null;
			var _local10:int = 0;
			var _local14:String = null;
			var _local11:int = 0;
			var _local7:Array = null;
			var _local12:int = 0;
			var _local15:Number = NaN;
			var _local8:Boolean = false;
			var _local9:Object = null;
			var _local16:Object = {};
			var _local17:Object = prepend || values[0];
			correlate = "," + correlate + ",";
			if(_local17 is Point) {
				_local13 = ["x","y"];
			} else {
				_local13 = [];
				for(_local14 in _local17) {
					_local13.push(_local14);
				}
			}
			if(values.length > 1) {
				_local9 = values[values.length - 1];
				_local8 = true;
				_local10 = int(_local13.length);
				while(true) {
					_local10--;
					if(_local10 <= -1) {
						break;
					}
					_local14 = _local13[_local10];
					if(Math.abs(_local17[_local14] - _local9[_local14]) > 0.05) {
						_local8 = false;
						break;
					}
				}
				if(_local8) {
					values = values.concat();
					if(prepend) {
						values.unshift(prepend);
					}
					values.push(values[1]);
					prepend = values[values.length - 3];
				}
			}
			_r1.length = _r2.length = _r3.length = 0;
			_local10 = int(_local13.length);
			while(true) {
				_local10--;
				if(_local10 <= -1) {
					break;
				}
				_local14 = _local13[_local10];
				_corProps[_local14] = correlate.indexOf("," + _local14 + ",") !== -1;
				_local16[_local14] = _parseAnchors(values,_local14,_corProps[_local14],prepend);
			}
			_local10 = int(_r1.length);
			while(true) {
				_local10--;
				if(_local10 <= -1) {
					break;
				}
				_r1[_local10] = Math.sqrt(_r1[_local10]);
				_r2[_local10] = Math.sqrt(_r2[_local10]);
			}
			if(!basic) {
				_local10 = int(_local13.length);
				while(true) {
					_local10--;
					if(_local10 <= -1) {
						break;
					}
					if(_corProps[_local14]) {
						_local7 = _local16[_local13[_local10]];
						_local12 = _local7.length - 1;
						_local11 = 0;
						while(_local11 < _local12) {
							_local15 = _local7[_local11 + 1].da / _r2[_local11] + _local7[_local11].da / _r1[_local11];
							_r3[_local11] = (_r3[_local11] || 0) + _local15 * _local15;
							_local11++;
						}
					}
				}
				_local10 = int(_r3.length);
				while(true) {
					_local10--;
					if(_local10 <= -1) {
						break;
					}
					_r3[_local10] = Math.sqrt(_r3[_local10]);
				}
			}
			_local10 = int(_local13.length);
			_local11 = quadratic ? 4 : 1;
			while(true) {
				_local10--;
				if(_local10 <= -1) {
					break;
				}
				_local14 = _local13[_local10];
				_local7 = _local16[_local14];
				_calculateControlPoints(_local7,curviness,quadratic,basic,_corProps[_local14]);
				if(_local8) {
					_local7.splice(0,_local11);
					_local7.splice(_local7.length - _local11,_local11);
				}
			}
			return _local16;
		}
		
		public static function _parseBezierData(values:Array, type:String, prepend:Object = null) : Object {
			var _local4:Number = NaN;
			var _local6:Number = NaN;
			var _local7:Number = NaN;
			var _local8:Number = NaN;
			var _local5:Array = null;
			var _local13:Array = null;
			var _local10:int = 0;
			var _local11:int = 0;
			var _local12:int = 0;
			var _local14:String = null;
			var _local9:int = 0;
			var _local15:Object = null;
			type ||= "soft";
			var _local16:Object = {};
			var _local17:int = type === "cubic" ? 3 : 2;
			var _local18:* = type === "soft";
			if(_local18 && prepend) {
				values = [prepend].concat(values);
			}
			if(values == null || values.length < _local17 + 1) {
				throw new Error("invalid Bezier data");
			}
			if(values[1] is Point) {
				_local13 = ["x","y"];
			} else {
				_local13 = [];
				for(_local14 in values[0]) {
					_local13.push(_local14);
				}
			}
			_local10 = int(_local13.length);
			while(true) {
				_local10--;
				if(_local10 <= -1) {
					break;
				}
				_local14 = _local13[_local10];
				_local16[_local14] = _local5 = [];
				_local9 = 0;
				_local12 = int(values.length);
				_local11 = 0;
				while(_local11 < _local12) {
					_local15 = values[_local11][_local14];
					_local4 = Number(prepend == null ? values[_local11][_local14] : (typeof _local15 === "string" && _local15.charAt(1) === "=" ? prepend[_local14] + (_local15.charAt(0) + _local15.substr(2)) : Number(_local15)));
					if(_local18) {
						if(_local11 > 1) {
							if(_local11 < _local12 - 1) {
								_local5[_local9++] = (_local4 + _local5[_local9 - 2]) / 2;
							}
						}
					}
					_local5[_local9++] = _local4;
					_local11++;
				}
				_local12 = _local9 - _local17 + 1;
				_local9 = 0;
				_local11 = 0;
				while(_local11 < _local12) {
					_local4 = Number(_local5[_local11]);
					_local6 = Number(_local5[_local11 + 1]);
					_local7 = Number(_local5[_local11 + 2]);
					_local8 = Number(_local17 === 2 ? 0 : _local5[_local11 + 3]);
					_local5[_local9++] = _local17 === 3 ? new Segment(_local4,_local6,_local7,_local8) : new Segment(_local4,(2 * _local6 + _local4) / 3,(2 * _local6 + _local7) / 3,_local7);
					_local11 += _local17;
				}
				_local5.length = _local9;
			}
			return _local16;
		}
		
		protected static function _parseAnchors(values:Array, p:String, correlate:Boolean, prepend:Object) : Array {
			var _local11:int = 0;
			var _local10:int = 0;
			var _local5:Number = NaN;
			var _local7:Number = NaN;
			var _local8:Number = NaN;
			var _local9:Object = null;
			var _local6:Array = [];
			if(prepend) {
				values = [prepend].concat(values);
				_local10 = int(values.length);
				while(true) {
					_local10--;
					if(_local10 <= -1) {
						break;
					}
					_local9 = values[_local10][p];
					if(typeof _local9 === "string") {
						if(_local9.charAt(1) === "=") {
							values[_local10][p] = prepend[p] + (_local9.charAt(0) + _local9.substr(2));
						}
					}
				}
			}
			_local11 = values.length - 2;
			if(_local11 < 0) {
				_local6[0] = new Segment(values[0][p],0,0,values[_local11 < -1 ? 0 : 1][p]);
				return _local6;
			}
			_local10 = 0;
			while(_local10 < _local11) {
				_local5 = Number(values[_local10][p]);
				_local7 = Number(values[_local10 + 1][p]);
				_local6[_local10] = new Segment(_local5,0,0,_local7);
				if(correlate) {
					_local8 = Number(values[_local10 + 2][p]);
					_r1[_local10] = (_r1[_local10] || 0) + (_local7 - _local5) * (_local7 - _local5);
					_r2[_local10] = (_r2[_local10] || 0) + (_local8 - _local7) * (_local8 - _local7);
				}
				_local10++;
			}
			_local6[_local10] = new Segment(values[_local10][p],0,0,values[_local10 + 1][p]);
			return _local6;
		}
		
		protected static function _calculateControlPoints(a:Array, curviness:Number = 1, quad:Boolean = false, basic:Boolean = false, correlate:Boolean = false) : void {
			var _local16:int = 0;
			var _local9:Number = NaN;
			var _local10:Number = NaN;
			var _local11:Number = NaN;
			var _local19:Segment = null;
			var _local12:Number = NaN;
			var _local15:Number = NaN;
			var _local7:Number = NaN;
			var _local13:* = NaN;
			var _local18:Array = null;
			var _local21:Number = NaN;
			var _local8:Number = NaN;
			var _local20:Number = NaN;
			var _local17:int = a.length - 1;
			var _local6:int = 0;
			var _local14:* = Number(a[0].a);
			_local16 = 0;
			while(_local16 < _local17) {
				_local19 = a[_local6];
				_local9 = _local19.a;
				_local10 = _local19.d;
				_local11 = Number(a[_local6 + 1].d);
				if(correlate) {
					_local21 = Number(_r1[_local16]);
					_local8 = Number(_r2[_local16]);
					_local20 = (_local8 + _local21) * curviness * 0.25 / (basic ? 0.5 : _r3[_local16] || 0.5);
					_local12 = _local10 - (_local10 - _local9) * (basic ? curviness * 0.5 : (_local21 !== 0 ? _local20 / _local21 : 0));
					_local15 = _local10 + (_local11 - _local10) * (basic ? curviness * 0.5 : (_local8 !== 0 ? _local20 / _local8 : 0));
					_local7 = _local10 - (_local12 + ((_local15 - _local12) * (_local21 * 3 / (_local21 + _local8) + 0.5) / 4 || 0));
				} else {
					_local12 = _local10 - (_local10 - _local9) * curviness * 0.5;
					_local15 = _local10 + (_local11 - _local10) * curviness * 0.5;
					_local7 = _local10 - (_local12 + _local15) / 2;
				}
				_local12 += _local7;
				_local15 += _local7;
				_local19.c = _local13 = _local12;
				if(_local16 != 0) {
					_local19.b = _local14;
				} else {
					_local19.b = _local14 = _local19.a + (_local19.c - _local19.a) * 0.6;
				}
				_local19.da = _local10 - _local9;
				_local19.ca = _local13 - _local9;
				_local19.ba = _local14 - _local9;
				if(quad) {
					_local18 = cubicToQuadratic(_local9,_local14,_local13,_local10);
					a.splice(_local6,1,_local18[0],_local18[1],_local18[2],_local18[3]);
					_local6 += 4;
				} else {
					_local6++;
				}
				_local14 = _local15;
				_local16++;
			}
			_local19 = a[_local6];
			_local19.b = _local14;
			_local19.c = _local14 + (_local19.d - _local14) * 0.4;
			_local19.da = _local19.d - _local19.a;
			_local19.ca = _local19.c - _local19.a;
			_local19.ba = _local14 - _local19.a;
			if(quad) {
				_local18 = cubicToQuadratic(_local19.a,_local14,_local19.c,_local19.d);
				a.splice(_local6,1,_local18[0],_local18[1],_local18[2],_local18[3]);
			}
		}
		
		public static function cubicToQuadratic(a:Number, b:Number, c:Number, d:Number) : Array {
			var _local5:Object = {"a":a};
			var _local6:Object = {};
			var _local7:Object = {};
			var _local8:Object = {"c":d};
			var _local12:Number = (a + b) / 2;
			var _local13:Number = (b + c) / 2;
			var _local14:Number = (c + d) / 2;
			var _local10:Number = (_local12 + _local13) / 2;
			var _local9:Number = (_local13 + _local14) / 2;
			var _local11:Number = (_local9 - _local10) / 8;
			_local5.b = _local12 + (a - _local12) / 4;
			_local6.b = _local10 + _local11;
			_local5.c = _local6.a = (_local5.b + _local6.b) / 2;
			_local6.c = _local7.a = (_local10 + _local9) / 2;
			_local7.b = _local9 - _local11;
			_local8.b = _local14 + (d - _local14) / 4;
			_local7.c = _local8.a = (_local7.b + _local8.b) / 2;
			return [_local5,_local6,_local7,_local8];
		}
		
		public static function quadraticToCubic(a:Number, b:Number, c:Number) : Object {
			return new Segment(a,(2 * b + a) / 3,(2 * b + c) / 3,c);
		}
		
		protected static function _parseLengthData(obj:Object, precision:uint = 6) : Object {
			var _local11:String = null;
			var _local5:int = 0;
			var _local8:int = 0;
			var _local6:Number = NaN;
			var _local3:Array = [];
			var _local13:Array = [];
			var _local4:Number = 0;
			var _local12:Number = 0;
			var _local7:int = precision - 1;
			var _local10:Array = [];
			var _local9:Array = [];
			for(_local11 in obj) {
				_addCubicLengths(obj[_local11],_local3,precision);
			}
			_local8 = int(_local3.length);
			_local5 = 0;
			while(_local5 < _local8) {
				_local4 += Math.sqrt(_local3[_local5]);
				_local6 = _local5 % precision;
				_local9[_local6] = _local4;
				if(_local6 == _local7) {
					_local12 += _local4;
					_local6 = _local5 / precision >> 0;
					_local10[_local6] = _local9;
					_local13[_local6] = _local12;
					_local4 = 0;
					_local9 = [];
				}
				_local5++;
			}
			return {
				"length":_local12,
				"lengths":_local13,
				"segments":_local10
			};
		}
		
		private static function _addCubicLengths(a:Array, steps:Array, precision:uint = 6) : void {
			var _local4:Number = NaN;
			var _local8:Number = NaN;
			var _local11:Number = NaN;
			var _local13:Number = NaN;
			var _local14:Number = NaN;
			var _local15:Number = NaN;
			var _local9:Number = NaN;
			var _local5:int = 0;
			var _local10:Number = NaN;
			var _local12:Segment = null;
			var _local6:int = 0;
			var _local16:Number = 1 / precision;
			var _local7:int = int(a.length);
			while(true) {
				_local7--;
				if(_local7 <= -1) {
					break;
				}
				_local12 = a[_local7];
				_local11 = _local12.a;
				_local13 = _local12.d - _local11;
				_local14 = _local12.c - _local11;
				_local15 = _local12.b - _local11;
				_local4 = _local8 = 0;
				_local5 = 1;
				while(_local5 <= precision) {
					_local9 = _local16 * _local5;
					_local10 = 1 - _local9;
					_local4 = _local8 - (_local8 = (_local9 * _local9 * _local13 + 3 * _local10 * (_local9 * _local14 + _local10 * _local15)) * _local9);
					_local6 = _local7 * precision + _local5 - 1;
					steps[_local6] = (steps[_local6] || 0) + _local4 * _local4;
					_local5++;
				}
			}
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			var _local10:String = null;
			var _local8:Boolean = false;
			var _local6:int = 0;
			var _local7:int = 0;
			var _local11:Array = null;
			var _local5:* = null;
			var _local4:Array = null;
			var _local12:Object = null;
			this._target = target;
			var _local13:Object = value is Array ? {"values":value} : value;
			this._props = [];
			this._timeRes = _local13.timeResolution == null ? 6 : int(_local13.timeResolution);
			_local4 = _local13.values || [];
			var _local15:Object = {};
			var _local9:Object = _local4[0];
			var _local14:Object = _local13.autoRotate || tween.vars.orientToBezier;
			this._autoRotate = !!_local14 ? (_local14 is Array ? _local14 as Array : [["x","y","rotation",_local14 === true ? 0 : Number(_local14)]]) : null;
			if(_local9 is Point) {
				this._props = ["x","y"];
			} else {
				for(_local10 in _local9) {
					this._props.push(_local10);
				}
			}
			_local6 = int(this._props.length);
			while(true) {
				_local6--;
				if(_local6 <= -1) {
					break;
				}
				_local10 = this._props[_local6];
				this._overwriteProps.push(_local10);
				_local8 = this._func[_local10] = target[_local10] is Function;
				_local15[_local10] = !_local8 ? target[_local10] : target[_local10.indexOf("set") || !("get" + _local10.substr(3) in target) ? _local10 : "get" + _local10.substr(3)]();
				if(!_local5) {
					if(_local15[_local10] !== _local4[0][_local10]) {
						_local5 = _local15;
					}
				}
			}
			this._beziers = _local13.type !== "cubic" && _local13.type !== "quadratic" && _local13.type !== "soft" ? bezierThrough(_local4,isNaN(_local13.curviness) ? 1 : _local13.curviness,false,_local13.type === "thruBasic",_local13.correlate || "x,y,z",_local5) : _parseBezierData(_local4,_local13.type,_local15);
			this._segCount = this._beziers[_local10].length;
			if(this._timeRes) {
				_local12 = _parseLengthData(this._beziers,this._timeRes);
				this._length = _local12.length;
				this._lengths = _local12.lengths;
				this._segments = _local12.segments;
				this._l1 = this._li = this._s1 = this._si = 0;
				this._l2 = this._lengths[0];
				this._curSeg = this._segments[0];
				this._s2 = this._curSeg[0];
				this._prec = 1 / this._curSeg.length;
			}
			_local11 = this._autoRotate;
			if(_local11) {
				this._initialRotations = [];
				if(!(_local11[0] is Array)) {
					this._autoRotate = _local11 = [_local11];
				}
				_local6 = int(_local11.length);
				while(true) {
					_local6--;
					if(_local6 <= -1) {
						break;
					}
					_local7 = 0;
					while(_local7 < 3) {
						_local10 = _local11[_local6][_local7];
						this._func[_local10] = target[_local10] is Function ? target[_local10.indexOf("set") || !("get" + _local10.substr(3) in target) ? _local10 : "get" + _local10.substr(3)] : false;
						_local7++;
					}
					_local10 = _local11[_local6][2];
					this._initialRotations[_local6] = !!this._func[_local10] ? this._func[_local10]() : this._target[_local10];
				}
			}
			_startRatio = !!tween.vars.runBackwards ? 1 : 0;
			return true;
		}
		
		override public function _kill(lookup:Object) : Boolean {
			var _local2:String = null;
			var _local4:int = 0;
			var _local3:Array = this._props;
			for(_local2 in _beziers) {
				if(_local2 in lookup) {
					delete _beziers[_local2];
					delete _func[_local2];
					_local4 = int(_local3.length);
					while(true) {
						_local4--;
						if(_local4 <= -1) {
							break;
						}
						if(_local3[_local4] === _local2) {
							_local3.splice(_local4,1);
						}
					}
				}
			}
			return super._kill(lookup);
		}
		
		override public function _roundProps(lookup:Object, value:Boolean = true) : void {
			var _local3:Array = null;
			_local3 = this._overwriteProps;
			var _local4:int = int(_local3.length);
			while(true) {
				_local4--;
				if(_local4 <= -1) {
					break;
				}
				if(_local3[_local4] in lookup || "bezier" in lookup || "bezierThrough" in lookup) {
					this._round[_local3[_local4]] = value;
				}
			}
		}
		
		override public function setRatio(v:Number) : void {
			var _local23:* = 0;
			var _local11:Number = NaN;
			var _local7:int = 0;
			var _local12:String = null;
			var _local6:Segment = null;
			var _local16:Number = NaN;
			var _local2:Number = NaN;
			var _local8:int = 0;
			var _local17:Array = null;
			var _local3:Array = null;
			var _local13:Segment = null;
			var _local19:Number = NaN;
			var _local18:Number = NaN;
			var _local21:Number = NaN;
			var _local20:Number = NaN;
			var _local4:Number = NaN;
			var _local22:Number = NaN;
			var _local14:Array = null;
			var _local10:int = this._segCount;
			var _local15:Object = this._func;
			var _local9:Object = this._target;
			var _local5:* = v !== this._startRatio;
			if(this._timeRes == 0) {
				_local23 = int(v < 0 ? 0 : (v >= 1 ? _local10 - 1 : _local10 * v >> 0));
				_local16 = (v - _local23 * (1 / _local10)) * _local10;
			} else {
				_local17 = this._lengths;
				_local3 = this._curSeg;
				v *= this._length;
				_local7 = this._li;
				if(v > this._l2 && _local7 < _local10 - 1) {
					_local8 = _local10 - 1;
					while(_local7 < _local8 && (this._l2 = _local17[_local7]) <= v) {
					}
					this._l1 = _local17[_local7 - 1];
					this._li = _local7;
					this._curSeg = _local3 = this._segments[_local7];
					this._s2 = _local3[this._s1 = this._si = 0];
				} else if(v < this._l1 && _local7 > 0) {
					while(_local7 > 0 && (this._l1 = _local17[_local7]) >= v) {
					}
					if(_local7 === 0 && v < this._l1) {
						this._l1 = 0;
					} else {
						_local7++;
					}
					this._l2 = _local17[_local7];
					this._li = _local7;
					this._curSeg = _local3 = this._segments[_local7];
					this._s1 = _local3[(this._si = _local3.length - 1) - 1] || 0;
					this._s2 = _local3[this._si];
				}
				_local23 = _local7;
				v -= this._l1;
				_local7 = this._si;
				if(v > this._s2 && _local7 < _local3.length - 1) {
					_local8 = _local3.length - 1;
					while(_local7 < _local8 && (this._s2 = _local3[_local7]) <= v) {
					}
					this._s1 = _local3[_local7 - 1];
					this._si = _local7;
				} else if(v < this._s1 && _local7 > 0) {
					while(_local7 > 0 && (this._s1 = _local3[_local7]) >= v) {
					}
					if(_local7 === 0 && v < this._s1) {
						this._s1 = 0;
					} else {
						_local7++;
					}
					this._s2 = _local3[_local7];
					this._si = _local7;
				}
				_local16 = (_local7 + (v - this._s1) / (this._s2 - this._s1)) * this._prec;
			}
			_local11 = 1 - _local16;
			_local7 = int(this._props.length);
			while(true) {
				_local7--;
				if(_local7 <= -1) {
					break;
				}
				_local12 = this._props[_local7];
				_local6 = this._beziers[_local12][_local23];
				_local2 = (_local16 * _local16 * _local6.da + 3 * _local11 * (_local16 * _local6.ca + _local11 * _local6.ba)) * _local16 + _local6.a;
				if(this._round[_local12]) {
					_local2 = _local2 + (_local2 > 0 ? 0.5 : -0.5) >> 0;
				}
				if(_local15[_local12]) {
					_local9[_local12](_local2);
				} else {
					_local9[_local12] = _local2;
				}
			}
			if(this._autoRotate != null) {
				_local14 = this._autoRotate;
				_local7 = int(_local14.length);
				while(true) {
					_local7--;
					if(_local7 <= -1) {
						break;
					}
					_local12 = _local14[_local7][2];
					_local4 = Number(_local14[_local7][3] || 0);
					_local22 = _local14[_local7][4] == true ? 1 : 57.29577951308232;
					_local6 = this._beziers[_local14[_local7][0]][_local23];
					_local13 = this._beziers[_local14[_local7][1]][_local23];
					_local19 = _local6.a + (_local6.b - _local6.a) * _local16;
					_local21 = _local6.b + (_local6.c - _local6.b) * _local16;
					_local19 += (_local21 - _local19) * _local16;
					_local21 += (_local6.c + (_local6.d - _local6.c) * _local16 - _local21) * _local16;
					_local18 = _local13.a + (_local13.b - _local13.a) * _local16;
					_local20 = _local13.b + (_local13.c - _local13.b) * _local16;
					_local18 += (_local20 - _local18) * _local16;
					_local20 += (_local13.c + (_local13.d - _local13.c) * _local16 - _local20) * _local16;
					_local2 = Number(_local5 ? Math.atan2(_local20 - _local18,_local21 - _local19) * _local22 + _local4 : this._initialRotations[_local7]);
					if(_local15[_local12]) {
						_local9[_local12](_local2);
					} else {
						_local9[_local12] = _local2;
					}
				}
			}
		}
	}
}

class Segment {
	public var a:Number;
	
	public var b:Number;
	
	public var c:Number;
	
	public var d:Number;
	
	public var da:Number;
	
	public var ca:Number;
	
	public var ba:Number;
	
	public function Segment(a:Number, b:Number, c:Number, d:Number) {
		super();
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.da = d - a;
		this.ca = c - a;
		this.ba = b - a;
	}
}
