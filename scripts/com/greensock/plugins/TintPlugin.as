package com.greensock.plugins {
	import com.greensock.*;
	import com.greensock.core.*;
	import flash.display.*;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	
	public class TintPlugin extends TweenPlugin {
		public static const API:Number = 2;
		
		protected static var _props:Array = ["redMultiplier","greenMultiplier","blueMultiplier","alphaMultiplier","redOffset","greenOffset","blueOffset","alphaOffset"];
		
		protected var _transform:Transform;
		
		public function TintPlugin() {
			super("tint,colorTransform,removeTint");
		}
		
		override public function _onInitTween(target:Object, value:*, tween:TweenLite) : Boolean {
			if(!(target is DisplayObject)) {
				return false;
			}
			var _local5:ColorTransform = new ColorTransform();
			if(value != null && tween.vars.removeTint != true) {
				_local5.color = value;
			}
			_transform = DisplayObject(target).transform;
			var _local4:ColorTransform = _transform.colorTransform;
			_local5.alphaMultiplier = _local4.alphaMultiplier;
			_local5.alphaOffset = _local4.alphaOffset;
			_init(_local4,_local5);
			return true;
		}
		
		public function _init(start:ColorTransform, end:ColorTransform) : void {
			var _local3:String = null;
			var _local4:int = int(_props.length);
			while(true) {
				_local4--;
				if(_local4 <= -1) {
					break;
				}
				_local3 = _props[_local4];
				if(start[_local3] != end[_local3]) {
					_addTween(start,_local3,start[_local3],end[_local3],"tint");
				}
			}
		}
		
		override public function setRatio(v:Number) : void {
			var _local2:ColorTransform = _transform.colorTransform;
			var _local3:PropTween = _firstPT;
			while(_local3) {
				_local2[_local3.p] = _local3.c * v + _local3.s;
				_local3 = _local3._next;
			}
			_transform.colorTransform = _local2;
		}
	}
}

