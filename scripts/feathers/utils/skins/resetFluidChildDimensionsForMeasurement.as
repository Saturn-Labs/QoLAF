package feathers.utils.skins {
	import feathers.core.IMeasureDisplayObject;
	import starling.display.DisplayObject;
	
	public function resetFluidChildDimensionsForMeasurement(child:DisplayObject, parentExplicitWidth:Number, parentExplicitHeight:Number, parentExplicitMinWidth:Number, parentExplicitMinHeight:Number, parentExplicitMaxWidth:Number, parentExplicitMaxHeight:Number, childExplicitWidth:Number, childExplicitHeight:Number, childExplicitMinWidth:Number, childExplicitMinHeight:Number, childExplicitMaxWidth:Number, childExplicitMaxHeight:Number) : void {
		var _local15:* = NaN;
		var _local20:* = NaN;
		var _local17:* = NaN;
		var _local18:* = NaN;
		if(child === null) {
			return;
		}
		var _local16:* = parentExplicitWidth !== parentExplicitWidth;
		var _local19:* = parentExplicitHeight !== parentExplicitHeight;
		if(_local16) {
			child.width = childExplicitWidth;
		} else {
			child.width = parentExplicitWidth;
		}
		if(_local19) {
			child.height = childExplicitHeight;
		} else {
			child.height = parentExplicitHeight;
		}
		var _local14:IMeasureDisplayObject = child as IMeasureDisplayObject;
		if(_local14 !== null) {
			compilerWorkaround = _local15 = parentExplicitMinWidth;
			if(_local15 !== _local15 || childExplicitMinWidth > _local15) {
				_local15 = childExplicitMinWidth;
			}
			_local14.minWidth = _local15;
			compilerWorkaround = _local20 = parentExplicitMinHeight;
			if(_local20 !== _local20 || childExplicitMinHeight > _local20) {
				_local20 = childExplicitMinHeight;
			}
			_local14.minHeight = _local20;
			compilerWorkaround = _local17 = parentExplicitMaxWidth;
			if(_local17 !== _local17 || childExplicitMaxWidth < _local17) {
				_local17 = childExplicitMaxWidth;
			}
			_local14.maxWidth = _local17;
			compilerWorkaround = _local18 = parentExplicitMaxHeight;
			if(_local18 !== _local18 || childExplicitMaxHeight < _local18) {
				_local18 = childExplicitMaxHeight;
			}
			_local14.maxHeight = _local18;
		}
	}
}

var compilerWorkaround:Object;
