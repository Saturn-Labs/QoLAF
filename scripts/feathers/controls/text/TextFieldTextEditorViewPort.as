package feathers.controls.text {
	import feathers.controls.Scroller;
	import feathers.skins.IStyleProvider;
	import feathers.utils.display.stageToStarling;
	import feathers.utils.geom.matrixToRotation;
	import feathers.utils.geom.matrixToScaleX;
	import feathers.utils.geom.matrixToScaleY;
	import feathers.utils.math.roundToNearest;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import starling.core.Starling;
	import starling.utils.MatrixUtil;
	
	public class TextFieldTextEditorViewPort extends TextFieldTextEditor implements ITextEditorViewPort {
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_MATRIX:Matrix = new Matrix();
		
		private static const HELPER_POINT:Point = new Point();
		
		private var _ignoreScrolling:Boolean = false;
		
		private var _minVisibleWidth:Number = 0;
		
		private var _maxVisibleWidth:Number = Infinity;
		
		private var _visibleWidth:Number = NaN;
		
		private var _minVisibleHeight:Number = 0;
		
		private var _maxVisibleHeight:Number = Infinity;
		
		private var _visibleHeight:Number = NaN;
		
		protected var _scrollStep:int = 0;
		
		private var _horizontalScrollPosition:Number = 0;
		
		private var _verticalScrollPosition:Number = 0;
		
		protected var _paddingTop:Number = 0;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingBottom:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		public function TextFieldTextEditorViewPort() {
			super();
			this.multiline = true;
			this.wordWrap = true;
			this.resetScrollOnFocusOut = false;
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return globalStyleProvider;
		}
		
		public function get minVisibleWidth() : Number {
			return this._minVisibleWidth;
		}
		
		public function set minVisibleWidth(value:Number) : void {
			if(this._minVisibleWidth == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("minVisibleWidth cannot be NaN");
			}
			this._minVisibleWidth = value;
			this.invalidate("size");
		}
		
		public function get maxVisibleWidth() : Number {
			return this._maxVisibleWidth;
		}
		
		public function set maxVisibleWidth(value:Number) : void {
			if(this._maxVisibleWidth == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("maxVisibleWidth cannot be NaN");
			}
			this._maxVisibleWidth = value;
			this.invalidate("size");
		}
		
		public function get visibleWidth() : Number {
			return this._visibleWidth;
		}
		
		public function set visibleWidth(value:Number) : void {
			if(this._visibleWidth == value || value !== value && this._visibleWidth !== this._visibleWidth) {
				return;
			}
			this._visibleWidth = value;
			this.invalidate("size");
		}
		
		public function get minVisibleHeight() : Number {
			return this._minVisibleHeight;
		}
		
		public function set minVisibleHeight(value:Number) : void {
			if(this._minVisibleHeight == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("minVisibleHeight cannot be NaN");
			}
			this._minVisibleHeight = value;
			this.invalidate("size");
		}
		
		public function get maxVisibleHeight() : Number {
			return this._maxVisibleHeight;
		}
		
		public function set maxVisibleHeight(value:Number) : void {
			if(this._maxVisibleHeight == value) {
				return;
			}
			if(value !== value) {
				throw new ArgumentError("maxVisibleHeight cannot be NaN");
			}
			this._maxVisibleHeight = value;
			this.invalidate("size");
		}
		
		public function get visibleHeight() : Number {
			return this._visibleHeight;
		}
		
		public function set visibleHeight(value:Number) : void {
			if(this._visibleHeight == value || value !== value && this._visibleHeight !== this._visibleHeight) {
				return;
			}
			this._visibleHeight = value;
			this.invalidate("size");
		}
		
		public function get contentX() : Number {
			return 0;
		}
		
		public function get contentY() : Number {
			return 0;
		}
		
		public function get horizontalScrollStep() : Number {
			return this._scrollStep;
		}
		
		public function get verticalScrollStep() : Number {
			return this._scrollStep;
		}
		
		public function get horizontalScrollPosition() : Number {
			return this._horizontalScrollPosition;
		}
		
		public function set horizontalScrollPosition(value:Number) : void {
			this._horizontalScrollPosition = value;
		}
		
		public function get verticalScrollPosition() : Number {
			return this._verticalScrollPosition;
		}
		
		public function set verticalScrollPosition(value:Number) : void {
			if(this._verticalScrollPosition == value) {
				return;
			}
			this._verticalScrollPosition = value;
			this.invalidate("scroll");
			this.invalidate("size");
		}
		
		public function get requiresMeasurementOnScroll() : Boolean {
			return false;
		}
		
		override public function get baseline() : Number {
			return super.baseline + this._paddingTop + this._verticalScrollPosition;
		}
		
		public function get padding() : Number {
			return this._paddingTop;
		}
		
		public function set padding(value:Number) : void {
			this.paddingTop = value;
			this.paddingRight = value;
			this.paddingBottom = value;
			this.paddingLeft = value;
		}
		
		public function get paddingTop() : Number {
			return this._paddingTop;
		}
		
		public function set paddingTop(value:Number) : void {
			if(this._paddingTop == value) {
				return;
			}
			this._paddingTop = value;
			this.invalidate("styles");
		}
		
		public function get paddingRight() : Number {
			return this._paddingRight;
		}
		
		public function set paddingRight(value:Number) : void {
			if(this._paddingRight == value) {
				return;
			}
			this._paddingRight = value;
			this.invalidate("styles");
		}
		
		public function get paddingBottom() : Number {
			return this._paddingBottom;
		}
		
		public function set paddingBottom(value:Number) : void {
			if(this._paddingBottom == value) {
				return;
			}
			this._paddingBottom = value;
			this.invalidate("styles");
		}
		
		public function get paddingLeft() : Number {
			return this._paddingLeft;
		}
		
		public function set paddingLeft(value:Number) : void {
			if(this._paddingLeft == value) {
				return;
			}
			this._paddingLeft = value;
			this.invalidate("styles");
		}
		
		override public function setFocus(position:Point = null) : void {
			if(position !== null) {
				position.x -= this._paddingLeft;
				position.y -= this._paddingTop;
			}
			super.setFocus(position);
		}
		
		override protected function measure(result:Point = null) : Point {
			if(!result) {
				result = new Point();
			}
			var _local3:* = this._visibleWidth !== this._visibleWidth;
			this.commitStylesAndData(this.measureTextField);
			var _local5:Number = 4;
			if(this._useGutter) {
				_local5 = 0;
			}
			var _local2:Number = this._visibleWidth;
			this.measureTextField.width = _local2 - this._paddingLeft - this._paddingRight + _local5;
			if(_local3) {
				_local2 = this.measureTextField.width + this._paddingLeft + this._paddingRight - _local5;
				if(_local2 < this._minVisibleWidth) {
					_local2 = this._minVisibleWidth;
				} else if(_local2 > this._maxVisibleWidth) {
					_local2 = this._maxVisibleWidth;
				}
			}
			var _local4:Number = this.measureTextField.height + this._paddingTop + this._paddingBottom - _local5;
			if(this._useGutter) {
				_local4 += 4;
			}
			if(this._visibleHeight === this._visibleHeight) {
				if(_local4 < this._visibleHeight) {
					_local4 = this._visibleHeight;
				}
			} else if(_local4 < this._minVisibleHeight) {
				_local4 = this._minVisibleHeight;
			}
			result.x = _local2;
			result.y = _local4;
			return result;
		}
		
		override protected function refreshSnapshotParameters() : void {
			var _local3:Number = this._visibleWidth - this._paddingLeft - this._paddingRight;
			if(_local3 !== _local3) {
				if(this._maxVisibleWidth < Infinity) {
					_local3 = this._maxVisibleWidth - this._paddingLeft - this._paddingRight;
				} else {
					_local3 = this._minVisibleWidth - this._paddingLeft - this._paddingRight;
				}
			}
			var _local4:Number = this._visibleHeight - this._paddingTop - this._paddingBottom;
			if(_local4 !== _local4) {
				if(this._maxVisibleHeight < Infinity) {
					_local4 = this._maxVisibleHeight - this._paddingTop - this._paddingBottom;
				} else {
					_local4 = this._minVisibleHeight - this._paddingTop - this._paddingBottom;
				}
			}
			this._textFieldOffsetX = 0;
			this._textFieldOffsetY = 0;
			this._textFieldSnapshotClipRect.x = 0;
			this._textFieldSnapshotClipRect.y = 0;
			var _local1:Number = Starling.contentScaleFactor;
			var _local2:Number = _local3 * _local1;
			if(this._updateSnapshotOnScaleChange) {
				this.getTransformationMatrix(this.stage,HELPER_MATRIX);
				_local2 *= matrixToScaleX(HELPER_MATRIX);
			}
			if(_local2 < 0) {
				_local2 = 0;
			}
			var _local5:Number = _local4 * _local1;
			if(this._updateSnapshotOnScaleChange) {
				_local5 *= matrixToScaleY(HELPER_MATRIX);
			}
			if(_local5 < 0) {
				_local5 = 0;
			}
			this._textFieldSnapshotClipRect.width = _local2;
			this._textFieldSnapshotClipRect.height = _local5;
		}
		
		override protected function refreshTextFieldSize() : void {
			var _local1:Boolean = this._ignoreScrolling;
			var _local2:Number = 4;
			if(this._useGutter) {
				_local2 = 0;
			}
			this._ignoreScrolling = true;
			this.textField.width = this._visibleWidth - this._paddingLeft - this._paddingRight + _local2;
			var _local4:Number = this._visibleHeight - this._paddingTop - this._paddingBottom + _local2;
			if(this.textField.height != _local4) {
				this.textField.height = _local4;
			}
			var _local3:Scroller = Scroller(this.parent);
			this.textField.scrollV = Math.round(1 + (this.textField.maxScrollV - 1) * (this._verticalScrollPosition / _local3.maxVerticalScrollPosition));
			this._ignoreScrolling = _local1;
		}
		
		override protected function commitStylesAndData(textField:TextField) : void {
			super.commitStylesAndData(textField);
			if(textField == this.textField) {
				this._scrollStep = textField.getLineMetrics(0).height;
			}
		}
		
		override protected function transformTextField() : void {
			var _local3:Starling = stageToStarling(this.stage);
			if(_local3 === null) {
				_local3 = Starling.current;
			}
			var _local9:Number = 1;
			if(_local3.supportHighResolutions) {
				_local9 = _local3.nativeStage.contentsScaleFactor;
			}
			var _local7:Number = _local3.contentScaleFactor / _local9;
			HELPER_POINT.x = HELPER_POINT.y = 0;
			this.getTransformationMatrix(this.stage,HELPER_MATRIX);
			MatrixUtil.transformCoords(HELPER_MATRIX,0,0,HELPER_POINT);
			var _local1:Number = matrixToScaleX(HELPER_MATRIX) * _local7;
			var _local4:Number = matrixToScaleY(HELPER_MATRIX) * _local7;
			var _local2:Number = Math.round(this._paddingLeft * _local1);
			var _local5:Number = Math.round((this._paddingTop + this._verticalScrollPosition) * _local4);
			var _local6:Rectangle = _local3.viewPort;
			var _local8:Number = 2;
			if(this._useGutter) {
				_local8 = 0;
			}
			this.textField.x = _local2 + Math.round(_local6.x + HELPER_POINT.x * _local7 - _local8 * _local1);
			this.textField.y = _local5 + Math.round(_local6.y + HELPER_POINT.y * _local7 - _local8 * _local4);
			this.textField.rotation = matrixToRotation(HELPER_MATRIX) * (3 * 60) / 3.141592653589793;
			this.textField.scaleX = _local1;
			this.textField.scaleY = _local4;
		}
		
		override protected function positionSnapshot() : void {
			if(!this.textSnapshot) {
				return;
			}
			this.getTransformationMatrix(this.stage,HELPER_MATRIX);
			this.textSnapshot.x = this._paddingLeft + Math.round(HELPER_MATRIX.tx) - HELPER_MATRIX.tx;
			this.textSnapshot.y = this._paddingTop + this._verticalScrollPosition + Math.round(HELPER_MATRIX.ty) - HELPER_MATRIX.ty;
		}
		
		override protected function checkIfNewSnapshotIsNeeded() : void {
			super.checkIfNewSnapshotIsNeeded();
			this._needsNewTexture ||= this.isInvalid("scroll");
		}
		
		override protected function textField_focusInHandler(event:FocusEvent) : void {
			this.textField.addEventListener("scroll",textField_scrollHandler);
			super.textField_focusInHandler(event);
			this.invalidate("size");
		}
		
		override protected function textField_focusOutHandler(event:FocusEvent) : void {
			this.textField.removeEventListener("scroll",textField_scrollHandler);
			super.textField_focusOutHandler(event);
			this.invalidate("size");
		}
		
		protected function textField_scrollHandler(event:Event) : void {
			var _local2:Number = NaN;
			var _local3:Number = this.textField.scrollH;
			var _local5:Number = this.textField.scrollV;
			if(this._ignoreScrolling) {
				return;
			}
			var _local4:Scroller = Scroller(this.parent);
			if(_local4.maxVerticalScrollPosition > 0 && this.textField.maxScrollV > 1) {
				_local2 = _local4.maxVerticalScrollPosition * (_local5 - 1) / (this.textField.maxScrollV - 1);
				_local4.verticalScrollPosition = roundToNearest(_local2,this._scrollStep);
			}
		}
	}
}

