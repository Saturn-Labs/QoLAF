package com.greensock.plugins {
	import com.greensock.TweenLite;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	
	public class FilterPlugin extends TweenPlugin {
		public static const API:Number = 2;
		
		protected var _target:Object;
		
		protected var _type:Class;
		
		protected var _filter:BitmapFilter;
		
		protected var _index:int;
		
		protected var _remove:Boolean;
		
		private var _tween:TweenLite;
		
		public function FilterPlugin(props:String = "", priority:Number = 0) {
			super(props,priority);
		}
		
		protected function _initFilter(target:*, props:Object, tween:TweenLite, type:Class, defaultFilter:BitmapFilter, propNames:Array) : Boolean {
			var _local7:String = null;
			var _local8:int = 0;
			var _local11:HexColorsPlugin = null;
			_target = target;
			_tween = tween;
			_type = type;
			var _local10:Array = _target.filters;
			var _local9:Object = props is BitmapFilter ? {} : props;
			if(_local9.index != null) {
				_index = _local9.index;
			} else {
				_index = _local10.length;
				if(_local9.addFilter != true) {
					while(--_index > -1 && !(_local10[_index] is _type)) {
					}
				}
			}
			if(_index < 0 || !(_local10[_index] is _type)) {
				if(_index < 0) {
					_index = _local10.length;
				}
				if(_index > _local10.length) {
					_local8 = _local10.length - 1;
					while(true) {
						_local8++;
						if(_local8 >= _index) {
							break;
						}
						_local10[_local8] = new BlurFilter(0,0,1);
					}
				}
				_local10[_index] = defaultFilter;
				_target.filters = _local10;
			}
			_filter = _local10[_index];
			_remove = _local9.remove == true;
			_local8 = int(propNames.length);
			while(true) {
				_local8--;
				if(_local8 <= -1) {
					break;
				}
				_local7 = propNames[_local8];
				if(_local7 in props && _filter[_local7] != props[_local7]) {
					if(_local7 == "color" || _local7 == "highlightColor" || _local7 == "shadowColor") {
						_local11 = new HexColorsPlugin();
						_local11._initColor(_filter,_local7,props[_local7]);
						_addTween(_local11,"setRatio",0,1,_propName);
					} else if(_local7 == "quality" || _local7 == "inner" || _local7 == "knockout" || _local7 == "hideObject") {
						_filter[_local7] = props[_local7];
					} else {
						_addTween(_filter,_local7,_filter[_local7],props[_local7],_propName);
					}
				}
			}
			return true;
		}
		
		override public function setRatio(v:Number) : void {
			super.setRatio(v);
			var _local2:Array = _target.filters;
			if(!(_local2[_index] is _type)) {
				_index = _local2.length;
				while(--_index > -1 && !(_local2[_index] is _type)) {
				}
				if(_index == -1) {
					_index = _local2.length;
				}
			}
			if(v == 1 && _remove && _tween._time == _tween._duration && _tween.data != "isFromStart") {
				if(_index < _local2.length) {
					_local2.splice(_index,1);
				}
			} else {
				_local2[_index] = _filter;
			}
			_target.filters = _local2;
		}
	}
}

