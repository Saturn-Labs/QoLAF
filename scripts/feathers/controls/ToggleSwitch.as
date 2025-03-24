package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.IFeathersControl;
	import feathers.core.IFocusDisplayObject;
	import feathers.core.IMeasureDisplayObject;
	import feathers.core.ITextBaselineControl;
	import feathers.core.ITextRenderer;
	import feathers.core.IToggle;
	import feathers.core.IValidating;
	import feathers.core.PropertyProxy;
	import feathers.skins.IStyleProvider;
	import feathers.system.DeviceCapabilities;
	import flash.geom.Point;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.utils.SystemUtil;
	
	public class ToggleSwitch extends FeathersControl implements IToggle, IFocusDisplayObject, ITextBaselineControl {
		private static const MINIMUM_DRAG_DISTANCE:Number = 0.04;
		
		protected static const INVALIDATION_FLAG_THUMB_FACTORY:String = "thumbFactory";
		
		protected static const INVALIDATION_FLAG_ON_TRACK_FACTORY:String = "onTrackFactory";
		
		protected static const INVALIDATION_FLAG_OFF_TRACK_FACTORY:String = "offTrackFactory";
		
		public static const LABEL_ALIGN_MIDDLE:String = "middle";
		
		public static const LABEL_ALIGN_BASELINE:String = "baseline";
		
		public static const TRACK_LAYOUT_MODE_SINGLE:String = "single";
		
		public static const TRACK_LAYOUT_MODE_ON_OFF:String = "onOff";
		
		public static const DEFAULT_CHILD_STYLE_NAME_OFF_LABEL:String = "feathers-toggle-switch-off-label";
		
		public static const DEFAULT_CHILD_STYLE_NAME_ON_LABEL:String = "feathers-toggle-switch-on-label";
		
		public static const DEFAULT_CHILD_STYLE_NAME_OFF_TRACK:String = "feathers-toggle-switch-off-track";
		
		public static const DEFAULT_CHILD_STYLE_NAME_ON_TRACK:String = "feathers-toggle-switch-on-track";
		
		public static const DEFAULT_CHILD_STYLE_NAME_THUMB:String = "feathers-toggle-switch-thumb";
		
		public static var globalStyleProvider:IStyleProvider;
		
		private static const HELPER_POINT:Point = new Point();
		
		protected var onLabelStyleName:String = "feathers-toggle-switch-on-label";
		
		protected var offLabelStyleName:String = "feathers-toggle-switch-off-label";
		
		protected var onTrackStyleName:String = "feathers-toggle-switch-on-track";
		
		protected var offTrackStyleName:String = "feathers-toggle-switch-off-track";
		
		protected var thumbStyleName:String = "feathers-toggle-switch-thumb";
		
		protected var thumb:DisplayObject;
		
		protected var onTextRenderer:ITextRenderer;
		
		protected var offTextRenderer:ITextRenderer;
		
		protected var onTrack:DisplayObject;
		
		protected var offTrack:DisplayObject;
		
		protected var _paddingRight:Number = 0;
		
		protected var _paddingLeft:Number = 0;
		
		protected var _showLabels:Boolean = true;
		
		protected var _showThumb:Boolean = true;
		
		protected var _trackLayoutMode:String = "single";
		
		protected var _trackScaleMode:String = "directional";
		
		protected var _defaultLabelProperties:PropertyProxy;
		
		protected var _disabledLabelProperties:PropertyProxy;
		
		protected var _onLabelProperties:PropertyProxy;
		
		protected var _offLabelProperties:PropertyProxy;
		
		protected var _labelAlign:String = "middle";
		
		protected var _labelFactory:Function;
		
		protected var _onLabelFactory:Function;
		
		protected var _customOnLabelStyleName:String;
		
		protected var _offLabelFactory:Function;
		
		protected var _customOffLabelStyleName:String;
		
		protected var _onTrackSkinExplicitWidth:Number;
		
		protected var _onTrackSkinExplicitHeight:Number;
		
		protected var _onTrackSkinExplicitMinWidth:Number;
		
		protected var _onTrackSkinExplicitMinHeight:Number;
		
		protected var _offTrackSkinExplicitWidth:Number;
		
		protected var _offTrackSkinExplicitHeight:Number;
		
		protected var _offTrackSkinExplicitMinWidth:Number;
		
		protected var _offTrackSkinExplicitMinHeight:Number;
		
		protected var _isSelected:Boolean = false;
		
		protected var _toggleThumbSelection:Boolean = false;
		
		protected var _toggleDuration:Number = 0.15;
		
		protected var _toggleEase:Object = "easeOut";
		
		protected var _onText:String = "ON";
		
		protected var _offText:String = "OFF";
		
		protected var _toggleTween:Tween;
		
		protected var _ignoreTapHandler:Boolean = false;
		
		protected var _touchPointID:int = -1;
		
		protected var _thumbStartX:Number;
		
		protected var _touchStartX:Number;
		
		protected var _animateSelectionChange:Boolean = false;
		
		protected var _onTrackFactory:Function;
		
		protected var _customOnTrackStyleName:String;
		
		protected var _onTrackProperties:PropertyProxy;
		
		protected var _offTrackFactory:Function;
		
		protected var _customOffTrackStyleName:String;
		
		protected var _offTrackProperties:PropertyProxy;
		
		protected var _thumbFactory:Function;
		
		protected var _customThumbStyleName:String;
		
		protected var _thumbProperties:PropertyProxy;
		
		public function ToggleSwitch() {
			super();
			this.addEventListener("touch",toggleSwitch_touchHandler);
			this.addEventListener("removedFromStage",toggleSwitch_removedFromStageHandler);
		}
		
		protected static function defaultThumbFactory() : BasicButton {
			return new Button();
		}
		
		protected static function defaultOnTrackFactory() : BasicButton {
			return new Button();
		}
		
		protected static function defaultOffTrackFactory() : BasicButton {
			return new Button();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return ToggleSwitch.globalStyleProvider;
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
		
		public function get showLabels() : Boolean {
			return _showLabels;
		}
		
		public function set showLabels(value:Boolean) : void {
			if(this._showLabels == value) {
				return;
			}
			this._showLabels = value;
			this.invalidate("styles");
		}
		
		public function get showThumb() : Boolean {
			return this._showThumb;
		}
		
		public function set showThumb(value:Boolean) : void {
			if(this._showThumb == value) {
				return;
			}
			this._showThumb = value;
			this.invalidate("styles");
		}
		
		public function get trackLayoutMode() : String {
			return this._trackLayoutMode;
		}
		
		public function set trackLayoutMode(value:String) : void {
			if(value === "onOff") {
				value = "split";
			}
			if(this._trackLayoutMode == value) {
				return;
			}
			this._trackLayoutMode = value;
			this.invalidate("layout");
		}
		
		public function get trackScaleMode() : String {
			return this._trackScaleMode;
		}
		
		public function set trackScaleMode(value:String) : void {
			if(this._trackScaleMode == value) {
				return;
			}
			this._trackScaleMode = value;
			this.invalidate("styles");
		}
		
		public function get defaultLabelProperties() : Object {
			if(!this._defaultLabelProperties) {
				this._defaultLabelProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._defaultLabelProperties;
		}
		
		public function set defaultLabelProperties(value:Object) : void {
			if(!(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			if(this._defaultLabelProperties) {
				this._defaultLabelProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._defaultLabelProperties = PropertyProxy(value);
			if(this._defaultLabelProperties) {
				this._defaultLabelProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get disabledLabelProperties() : Object {
			if(!this._disabledLabelProperties) {
				this._disabledLabelProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._disabledLabelProperties;
		}
		
		public function set disabledLabelProperties(value:Object) : void {
			if(!(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			if(this._disabledLabelProperties) {
				this._disabledLabelProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._disabledLabelProperties = PropertyProxy(value);
			if(this._disabledLabelProperties) {
				this._disabledLabelProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get onLabelProperties() : Object {
			if(!this._onLabelProperties) {
				this._onLabelProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._onLabelProperties;
		}
		
		public function set onLabelProperties(value:Object) : void {
			if(!(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			if(this._onLabelProperties) {
				this._onLabelProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._onLabelProperties = PropertyProxy(value);
			if(this._onLabelProperties) {
				this._onLabelProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get offLabelProperties() : Object {
			if(!this._offLabelProperties) {
				this._offLabelProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._offLabelProperties;
		}
		
		public function set offLabelProperties(value:Object) : void {
			if(!(value is PropertyProxy)) {
				value = PropertyProxy.fromObject(value);
			}
			if(this._offLabelProperties) {
				this._offLabelProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._offLabelProperties = PropertyProxy(value);
			if(this._offLabelProperties) {
				this._offLabelProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get labelAlign() : String {
			return this._labelAlign;
		}
		
		public function set labelAlign(value:String) : void {
			if(this._labelAlign == value) {
				return;
			}
			this._labelAlign = value;
			this.invalidate("styles");
		}
		
		public function get labelFactory() : Function {
			return this._labelFactory;
		}
		
		public function set labelFactory(value:Function) : void {
			if(this._labelFactory == value) {
				return;
			}
			this._labelFactory = value;
			this.invalidate("textRenderer");
		}
		
		public function get onLabelFactory() : Function {
			return this._onLabelFactory;
		}
		
		public function set onLabelFactory(value:Function) : void {
			if(this._onLabelFactory == value) {
				return;
			}
			this._onLabelFactory = value;
			this.invalidate("textRenderer");
		}
		
		public function get customOnLabelStyleName() : String {
			return this._customOnLabelStyleName;
		}
		
		public function set customOnLabelStyleName(value:String) : void {
			if(this._customOnLabelStyleName == value) {
				return;
			}
			this._customOnLabelStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get offLabelFactory() : Function {
			return this._offLabelFactory;
		}
		
		public function set offLabelFactory(value:Function) : void {
			if(this._offLabelFactory == value) {
				return;
			}
			this._offLabelFactory = value;
			this.invalidate("textRenderer");
		}
		
		public function get customOffLabelStyleName() : String {
			return this._customOffLabelStyleName;
		}
		
		public function set customOffLabelStyleName(value:String) : void {
			if(this._customOffLabelStyleName == value) {
				return;
			}
			this._customOffLabelStyleName = value;
			this.invalidate("textRenderer");
		}
		
		public function get isSelected() : Boolean {
			return this._isSelected;
		}
		
		public function set isSelected(value:Boolean) : void {
			this._animateSelectionChange = false;
			if(this._isSelected == value) {
				return;
			}
			this._isSelected = value;
			this.invalidate("selected");
			this.dispatchEventWith("change");
		}
		
		public function get toggleThumbSelection() : Boolean {
			return this._toggleThumbSelection;
		}
		
		public function set toggleThumbSelection(value:Boolean) : void {
			if(this._toggleThumbSelection == value) {
				return;
			}
			this._toggleThumbSelection = value;
			this.invalidate("selected");
		}
		
		public function get toggleDuration() : Number {
			return this._toggleDuration;
		}
		
		public function set toggleDuration(value:Number) : void {
			this._toggleDuration = value;
		}
		
		public function get toggleEase() : Object {
			return this._toggleEase;
		}
		
		public function set toggleEase(value:Object) : void {
			this._toggleEase = value;
		}
		
		public function get onText() : String {
			return this._onText;
		}
		
		public function set onText(value:String) : void {
			if(value === null) {
				value = "";
			}
			if(this._onText == value) {
				return;
			}
			this._onText = value;
			this.invalidate("styles");
		}
		
		public function get offText() : String {
			return this._offText;
		}
		
		public function set offText(value:String) : void {
			if(value === null) {
				value = "";
			}
			if(this._offText == value) {
				return;
			}
			this._offText = value;
			this.invalidate("styles");
		}
		
		public function get onTrackFactory() : Function {
			return this._onTrackFactory;
		}
		
		public function set onTrackFactory(value:Function) : void {
			if(this._onTrackFactory == value) {
				return;
			}
			this._onTrackFactory = value;
			this.invalidate("onTrackFactory");
		}
		
		public function get customOnTrackStyleName() : String {
			return this._customOnTrackStyleName;
		}
		
		public function set customOnTrackStyleName(value:String) : void {
			if(this._customOnTrackStyleName == value) {
				return;
			}
			this._customOnTrackStyleName = value;
			this.invalidate("onTrackFactory");
		}
		
		public function get onTrackProperties() : Object {
			if(!this._onTrackProperties) {
				this._onTrackProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._onTrackProperties;
		}
		
		public function set onTrackProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._onTrackProperties == value) {
				return;
			}
			if(!value) {
				value = new PropertyProxy();
			}
			if(!(value is PropertyProxy)) {
				_local2 = new PropertyProxy();
				for(var _local3 in value) {
					_local2[_local3] = value[_local3];
				}
				value = _local2;
			}
			if(this._onTrackProperties) {
				this._onTrackProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._onTrackProperties = PropertyProxy(value);
			if(this._onTrackProperties) {
				this._onTrackProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get offTrackFactory() : Function {
			return this._offTrackFactory;
		}
		
		public function set offTrackFactory(value:Function) : void {
			if(this._offTrackFactory == value) {
				return;
			}
			this._offTrackFactory = value;
			this.invalidate("offTrackFactory");
		}
		
		public function get customOffTrackStyleName() : String {
			return this._customOffTrackStyleName;
		}
		
		public function set customOffTrackStyleName(value:String) : void {
			if(this._customOffTrackStyleName == value) {
				return;
			}
			this._customOffTrackStyleName = value;
			this.invalidate("offTrackFactory");
		}
		
		public function get offTrackProperties() : Object {
			if(!this._offTrackProperties) {
				this._offTrackProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._offTrackProperties;
		}
		
		public function set offTrackProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._offTrackProperties == value) {
				return;
			}
			if(!value) {
				value = new PropertyProxy();
			}
			if(!(value is PropertyProxy)) {
				_local2 = new PropertyProxy();
				for(var _local3 in value) {
					_local2[_local3] = value[_local3];
				}
				value = _local2;
			}
			if(this._offTrackProperties) {
				this._offTrackProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._offTrackProperties = PropertyProxy(value);
			if(this._offTrackProperties) {
				this._offTrackProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get thumbFactory() : Function {
			return this._thumbFactory;
		}
		
		public function set thumbFactory(value:Function) : void {
			if(this._thumbFactory == value) {
				return;
			}
			this._thumbFactory = value;
			this.invalidate("thumbFactory");
		}
		
		public function get customThumbStyleName() : String {
			return this._customThumbStyleName;
		}
		
		public function set customThumbStyleName(value:String) : void {
			if(this._customThumbStyleName == value) {
				return;
			}
			this._customThumbStyleName = value;
			this.invalidate("thumbFactory");
		}
		
		public function get thumbProperties() : Object {
			if(!this._thumbProperties) {
				this._thumbProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._thumbProperties;
		}
		
		public function set thumbProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._thumbProperties == value) {
				return;
			}
			if(!value) {
				value = new PropertyProxy();
			}
			if(!(value is PropertyProxy)) {
				_local2 = new PropertyProxy();
				for(var _local3 in value) {
					_local2[_local3] = value[_local3];
				}
				value = _local2;
			}
			if(this._thumbProperties) {
				this._thumbProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._thumbProperties = PropertyProxy(value);
			if(this._thumbProperties) {
				this._thumbProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function get baseline() : Number {
			if(!this.onTextRenderer) {
				return this.scaledActualHeight;
			}
			return this.scaleY * (this.onTextRenderer.y + this.onTextRenderer.baseline);
		}
		
		public function setSelectionWithAnimation(isSelected:Boolean) : void {
			if(this._isSelected == isSelected) {
				return;
			}
			this.isSelected = isSelected;
			this._animateSelectionChange = true;
		}
		
		override protected function draw() : void {
			var _local8:Boolean = this.isInvalid("selected");
			var _local10:Boolean = this.isInvalid("styles");
			var _local1:Boolean = this.isInvalid("size");
			var _local6:Boolean = this.isInvalid("state");
			var _local2:Boolean = this.isInvalid("focus");
			var _local3:Boolean = this.isInvalid("layout");
			var _local7:Boolean = this.isInvalid("textRenderer");
			var _local9:Boolean = this.isInvalid("thumbFactory");
			var _local5:Boolean = this.isInvalid("onTrackFactory");
			var _local4:Boolean = this.isInvalid("offTrackFactory");
			if(_local9) {
				this.createThumb();
			}
			if(_local5) {
				this.createOnTrack();
			}
			if(_local4 || _local3) {
				this.createOffTrack();
			}
			if(_local7) {
				this.createLabels();
			}
			if(_local7 || _local10 || _local6) {
				this.refreshOnLabelStyles();
				this.refreshOffLabelStyles();
			}
			if(_local9 || _local10) {
				this.refreshThumbStyles();
			}
			if(_local5 || _local10) {
				this.refreshOnTrackStyles();
			}
			if((_local4 || _local3 || _local10) && this.offTrack) {
				this.refreshOffTrackStyles();
			}
			if(_local6 || _local3 || _local9 || _local5 || _local5 || _local7) {
				this.refreshEnabled();
			}
			_local1 = this.autoSizeIfNeeded() || _local1;
			if(_local1 || _local10 || _local8) {
				this.updateSelection();
			}
			this.layoutChildren();
			if(_local1 || _local2) {
				this.refreshFocusIndicator();
			}
		}
		
		protected function autoSizeIfNeeded() : Boolean {
			var _local4:IMeasureDisplayObject = null;
			var _local5:Number = NaN;
			var _local6:IMeasureDisplayObject = null;
			var _local7:IMeasureDisplayObject = null;
			var _local2:* = this._explicitWidth !== this._explicitWidth;
			var _local12:* = this._explicitHeight !== this._explicitHeight;
			var _local9:* = this._explicitMinWidth !== this._explicitMinWidth;
			var _local13:* = this._explicitMinHeight !== this._explicitMinHeight;
			if(!_local2 && !_local12 && !_local9 && !_local13) {
				return false;
			}
			var _local10:* = this._trackLayoutMode === "single";
			if(_local2) {
				this.onTrack.width = this._onTrackSkinExplicitWidth;
			} else if(_local10) {
				this.onTrack.width = this._explicitWidth;
			}
			if(this.onTrack is IMeasureDisplayObject) {
				_local4 = IMeasureDisplayObject(this.onTrack);
				if(_local9) {
					_local4.minWidth = this._onTrackSkinExplicitMinWidth;
				} else if(_local10) {
					_local5 = this._explicitMinWidth;
					if(this._onTrackSkinExplicitMinWidth > _local5) {
						_local5 = this._onTrackSkinExplicitMinWidth;
					}
					_local4.minWidth = _local5;
				}
			}
			if(!_local10) {
				if(_local2) {
					this.offTrack.width = this._offTrackSkinExplicitWidth;
				}
				if(this.offTrack is IMeasureDisplayObject) {
					_local6 = IMeasureDisplayObject(this.offTrack);
					if(_local9) {
						_local6.minWidth = this._offTrackSkinExplicitMinWidth;
					}
				}
			}
			if(this.onTrack is IValidating) {
				IValidating(this.onTrack).validate();
			}
			if(this.offTrack is IValidating) {
				IValidating(this.offTrack).validate();
			}
			if(this.thumb is IValidating) {
				IValidating(this.thumb).validate();
			}
			var _local1:Number = this._explicitWidth;
			var _local3:Number = this._explicitHeight;
			var _local8:Number = this._explicitMinWidth;
			var _local11:Number = this._explicitMinHeight;
			if(_local2) {
				_local1 = this.onTrack.width;
				if(!_local10) {
					if(this.offTrack.width > _local1) {
						_local1 = this.offTrack.width;
					}
					_local1 += this.thumb.width / 2;
				}
			}
			if(_local12) {
				_local3 = this.onTrack.height;
				if(!_local10 && this.offTrack.height > _local3) {
					_local3 = this.offTrack.height;
				}
				if(this.thumb.height > _local3) {
					_local3 = this.thumb.height;
				}
			}
			if(_local9) {
				if(_local4 !== null) {
					_local8 = _local4.minWidth;
				} else {
					_local8 = this.onTrack.width;
				}
				if(!_local10) {
					if(_local6 !== null) {
						if(_local6.minWidth > _local8) {
							_local8 = _local6.minWidth;
						}
					} else if(this.offTrack.width > _local8) {
						_local8 = this.offTrack.width;
					}
					if(this.thumb is IMeasureDisplayObject) {
						_local8 += IMeasureDisplayObject(this.thumb).minWidth / 2;
					} else {
						_local8 += this.thumb.width / 2;
					}
				}
			}
			if(_local13) {
				if(_local4 !== null) {
					_local11 = _local4.minHeight;
				} else {
					_local11 = this.onTrack.height;
				}
				if(!_local10) {
					if(_local6 !== null) {
						if(_local6.minHeight > _local11) {
							_local11 = _local6.minHeight;
						}
					} else if(this.offTrack.height > _local11) {
						_local11 = this.offTrack.height;
					}
				}
				if(this.thumb is IMeasureDisplayObject) {
					_local7 = IMeasureDisplayObject(this.thumb);
					if(_local7.minHeight > _local11) {
						_local11 = _local7.minHeight;
					}
				} else if(this.thumb.height > _local11) {
					_local11 = this.thumb.height;
				}
			}
			return this.saveMeasurements(_local1,_local3,_local8,_local11);
		}
		
		protected function createThumb() : void {
			if(this.thumb !== null) {
				this.thumb.removeFromParent(true);
				this.thumb = null;
			}
			var _local1:Function = this._thumbFactory != null ? this._thumbFactory : defaultThumbFactory;
			var _local3:String = this._customThumbStyleName != null ? this._customThumbStyleName : this.thumbStyleName;
			var _local2:BasicButton = BasicButton(_local1());
			_local2.styleNameList.add(_local3);
			_local2.keepDownStateOnRollOut = true;
			_local2.addEventListener("touch",thumb_touchHandler);
			this.addChild(_local2);
			this.thumb = _local2;
		}
		
		protected function createOnTrack() : void {
			var _local4:IMeasureDisplayObject = null;
			if(this.onTrack !== null) {
				this.onTrack.removeFromParent(true);
				this.onTrack = null;
			}
			var _local1:Function = this._onTrackFactory != null ? this._onTrackFactory : defaultOnTrackFactory;
			var _local3:String = this._customOnTrackStyleName != null ? this._customOnTrackStyleName : this.onTrackStyleName;
			var _local2:BasicButton = BasicButton(_local1());
			_local2.styleNameList.add(_local3);
			_local2.keepDownStateOnRollOut = true;
			this.addChildAt(_local2,0);
			this.onTrack = _local2;
			if(this.onTrack is IFeathersControl) {
				IFeathersControl(this.onTrack).initializeNow();
			}
			if(this.onTrack is IMeasureDisplayObject) {
				_local4 = IMeasureDisplayObject(this.onTrack);
				this._onTrackSkinExplicitWidth = _local4.explicitWidth;
				this._onTrackSkinExplicitHeight = _local4.explicitHeight;
				this._onTrackSkinExplicitMinWidth = _local4.explicitMinWidth;
				this._onTrackSkinExplicitMinHeight = _local4.explicitMinHeight;
			} else {
				this._onTrackSkinExplicitWidth = this.onTrack.width;
				this._onTrackSkinExplicitHeight = this.onTrack.height;
				this._onTrackSkinExplicitMinWidth = this._onTrackSkinExplicitWidth;
				this._onTrackSkinExplicitMinHeight = this._onTrackSkinExplicitHeight;
			}
		}
		
		protected function createOffTrack() : void {
			var _local4:IMeasureDisplayObject = null;
			if(this.offTrack !== null) {
				this.offTrack.removeFromParent(true);
				this.offTrack = null;
			}
			if(this._trackLayoutMode === "single") {
				return;
			}
			var _local1:Function = this._offTrackFactory != null ? this._offTrackFactory : defaultOffTrackFactory;
			var _local3:String = this._customOffTrackStyleName != null ? this._customOffTrackStyleName : this.offTrackStyleName;
			var _local2:BasicButton = BasicButton(_local1());
			_local2.styleNameList.add(_local3);
			_local2.keepDownStateOnRollOut = true;
			this.addChildAt(_local2,1);
			this.offTrack = _local2;
			if(this.offTrack is IFeathersControl) {
				IFeathersControl(this.offTrack).initializeNow();
			}
			if(this.offTrack is IMeasureDisplayObject) {
				_local4 = IMeasureDisplayObject(this.offTrack);
				this._offTrackSkinExplicitWidth = _local4.explicitWidth;
				this._offTrackSkinExplicitHeight = _local4.explicitHeight;
				this._offTrackSkinExplicitMinWidth = _local4.explicitMinWidth;
				this._offTrackSkinExplicitMinHeight = _local4.explicitMinHeight;
			} else {
				this._offTrackSkinExplicitWidth = this.offTrack.width;
				this._offTrackSkinExplicitHeight = this.offTrack.height;
				this._offTrackSkinExplicitMinWidth = this._offTrackSkinExplicitWidth;
				this._offTrackSkinExplicitMinHeight = this._offTrackSkinExplicitHeight;
			}
		}
		
		protected function createLabels() : void {
			if(this.offTextRenderer) {
				this.removeChild(DisplayObject(this.offTextRenderer),true);
				this.offTextRenderer = null;
			}
			if(this.onTextRenderer) {
				this.removeChild(DisplayObject(this.onTextRenderer),true);
				this.onTextRenderer = null;
			}
			var _local3:int = this.getChildIndex(this.thumb);
			var _local5:Function = this._offLabelFactory;
			if(_local5 == null) {
				_local5 = this._labelFactory;
			}
			if(_local5 == null) {
				_local5 = FeathersControl.defaultTextRendererFactory;
			}
			this.offTextRenderer = ITextRenderer(_local5());
			var _local2:String = this._customOffLabelStyleName != null ? this._customOffLabelStyleName : this.offLabelStyleName;
			this.offTextRenderer.styleNameList.add(_local2);
			var _local6:Quad = new Quad(1,1,0xff00ff);
			_local6.width = 0;
			_local6.height = 0;
			this.offTextRenderer.mask = _local6;
			this.addChildAt(DisplayObject(this.offTextRenderer),_local3);
			var _local4:Function = this._onLabelFactory;
			if(_local4 == null) {
				_local4 = this._labelFactory;
			}
			if(_local4 == null) {
				_local4 = FeathersControl.defaultTextRendererFactory;
			}
			this.onTextRenderer = ITextRenderer(_local4());
			var _local1:String = this._customOnLabelStyleName != null ? this._customOnLabelStyleName : this.onLabelStyleName;
			this.onTextRenderer.styleNameList.add(_local1);
			_local6 = new Quad(1,1,0xff00ff);
			_local6.width = 0;
			_local6.height = 0;
			this.onTextRenderer.mask = _local6;
			this.addChildAt(DisplayObject(this.onTextRenderer),_local3);
		}
		
		protected function layoutChildren() : void {
			var _local2:* = NaN;
			if(this.thumb is IValidating) {
				IValidating(this.thumb).validate();
			}
			this.thumb.y = (this.actualHeight - this.thumb.height) / 2;
			var _local3:Number = Math.max(0,this.actualWidth - this.thumb.width - this._paddingLeft - this._paddingRight);
			var _local1:Number = Math.max(this.onTextRenderer.height,this.offTextRenderer.height);
			if(this._labelAlign == "middle") {
				_local2 = _local1;
			} else {
				_local2 = Math.max(this.onTextRenderer.baseline,this.offTextRenderer.baseline);
			}
			var _local4:DisplayObject = this.onTextRenderer.mask;
			_local4.width = _local3;
			_local4.height = _local1;
			this.onTextRenderer.y = (this.actualHeight - _local2) / 2;
			_local4 = this.offTextRenderer.mask;
			_local4.width = _local3;
			_local4.height = _local1;
			this.offTextRenderer.y = (this.actualHeight - _local2) / 2;
			this.layoutTracks();
		}
		
		protected function layoutTracks() : void {
			var _local5:Number = Math.max(0,this.actualWidth - this.thumb.width - this._paddingLeft - this._paddingRight);
			var _local3:Number = this.thumb.x - this._paddingLeft;
			var _local1:Number = _local5 - _local3 - (_local5 - this.onTextRenderer.width) / 2;
			var _local4:DisplayObject = this.onTextRenderer.mask;
			_local4.x = _local1;
			this.onTextRenderer.x = this._paddingLeft - _local1;
			var _local2:Number = -_local3 - (_local5 - this.offTextRenderer.width) / 2;
			_local4 = this.offTextRenderer.mask;
			_local4.x = _local2;
			this.offTextRenderer.x = this.actualWidth - this._paddingRight - _local5 - _local2;
			if(this._trackLayoutMode == "split") {
				this.layoutTrackWithOnOff();
			} else {
				this.layoutTrackWithSingle();
			}
		}
		
		protected function updateSelection() : void {
			var _local2:IToggle = null;
			if(this.thumb is IToggle) {
				_local2 = IToggle(this.thumb);
				if(this._toggleThumbSelection) {
					_local2.isSelected = this._isSelected;
				} else {
					_local2.isSelected = false;
				}
			}
			if(this.thumb is IValidating) {
				IValidating(this.thumb).validate();
			}
			var _local1:Number = this._paddingLeft;
			if(this._isSelected) {
				_local1 = this.actualWidth - this.thumb.width - this._paddingRight;
			}
			if(this._toggleTween) {
				Starling.juggler.remove(this._toggleTween);
				this._toggleTween = null;
			}
			if(this._animateSelectionChange) {
				this._toggleTween = new Tween(this.thumb,this._toggleDuration,this._toggleEase);
				this._toggleTween.animate("x",_local1);
				this._toggleTween.onUpdate = selectionTween_onUpdate;
				this._toggleTween.onComplete = selectionTween_onComplete;
				Starling.juggler.add(this._toggleTween);
			} else {
				this.thumb.x = _local1;
			}
			this._animateSelectionChange = false;
		}
		
		protected function refreshOnLabelStyles() : void {
			var _local4:PropertyProxy = null;
			var _local1:DisplayObject = null;
			var _local3:Object = null;
			if(!this._showLabels || !this._showThumb) {
				this.onTextRenderer.visible = false;
				return;
			}
			if(!this._isEnabled) {
				_local4 = this._disabledLabelProperties;
			}
			if(!_local4 && this._onLabelProperties) {
				_local4 = this._onLabelProperties;
			}
			if(!_local4) {
				_local4 = this._defaultLabelProperties;
			}
			this.onTextRenderer.text = this._onText;
			if(_local4) {
				_local1 = DisplayObject(this.onTextRenderer);
				for(var _local2 in _local4) {
					_local3 = _local4[_local2];
					_local1[_local2] = _local3;
				}
			}
			this.onTextRenderer.validate();
			this.onTextRenderer.visible = true;
		}
		
		protected function refreshOffLabelStyles() : void {
			var _local4:PropertyProxy = null;
			var _local1:DisplayObject = null;
			var _local3:Object = null;
			if(!this._showLabels || !this._showThumb) {
				this.offTextRenderer.visible = false;
				return;
			}
			if(!this._isEnabled) {
				_local4 = this._disabledLabelProperties;
			}
			if(!_local4 && this._offLabelProperties) {
				_local4 = this._offLabelProperties;
			}
			if(!_local4) {
				_local4 = this._defaultLabelProperties;
			}
			this.offTextRenderer.text = this._offText;
			if(_local4) {
				_local1 = DisplayObject(this.offTextRenderer);
				for(var _local2 in _local4) {
					_local3 = _local4[_local2];
					_local1[_local2] = _local3;
				}
			}
			this.offTextRenderer.validate();
			this.offTextRenderer.visible = true;
		}
		
		protected function refreshThumbStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._thumbProperties) {
				_local2 = this._thumbProperties[_local1];
				this.thumb[_local1] = _local2;
			}
			this.thumb.visible = this._showThumb;
		}
		
		protected function refreshOnTrackStyles() : void {
			var _local2:Object = null;
			for(var _local1 in this._onTrackProperties) {
				_local2 = this._onTrackProperties[_local1];
				this.onTrack[_local1] = _local2;
			}
		}
		
		protected function refreshOffTrackStyles() : void {
			var _local2:Object = null;
			if(!this.offTrack) {
				return;
			}
			for(var _local1 in this._offTrackProperties) {
				_local2 = this._offTrackProperties[_local1];
				this.offTrack[_local1] = _local2;
			}
		}
		
		protected function refreshEnabled() : void {
			if(this.thumb is IFeathersControl) {
				IFeathersControl(this.thumb).isEnabled = this._isEnabled;
			}
			if(this.onTrack is IFeathersControl) {
				IFeathersControl(this.onTrack).isEnabled = this._isEnabled;
			}
			if(this.offTrack is IFeathersControl) {
				IFeathersControl(this.offTrack).isEnabled = this._isEnabled;
			}
			this.onTextRenderer.isEnabled = this._isEnabled;
			this.offTextRenderer.isEnabled = this._isEnabled;
		}
		
		protected function layoutTrackWithOnOff() : void {
			var _local1:Number = Math.round(this.thumb.x + this.thumb.width / 2);
			this.onTrack.x = 0;
			this.onTrack.width = _local1;
			this.offTrack.x = _local1;
			this.offTrack.width = this.actualWidth - _local1;
			if(this._trackScaleMode === "exactFit") {
				this.onTrack.y = 0;
				this.onTrack.height = this.actualHeight;
				this.offTrack.y = 0;
				this.offTrack.height = this.actualHeight;
			}
			if(this.onTrack is IValidating) {
				IValidating(this.onTrack).validate();
			}
			if(this.offTrack is IValidating) {
				IValidating(this.offTrack).validate();
			}
			if(this._trackScaleMode === "directional") {
				this.onTrack.y = Math.round((this.actualHeight - this.onTrack.height) / 2);
				this.offTrack.y = Math.round((this.actualHeight - this.offTrack.height) / 2);
			}
		}
		
		protected function layoutTrackWithSingle() : void {
			this.onTrack.x = 0;
			this.onTrack.width = this.actualWidth;
			if(this._trackScaleMode === "exactFit") {
				this.onTrack.y = 0;
				this.onTrack.height = this.actualHeight;
			} else {
				this.onTrack.height = this._onTrackSkinExplicitHeight;
			}
			if(this.onTrack is IValidating) {
				IValidating(this.onTrack).validate();
			}
			if(this._trackScaleMode === "directional") {
				this.onTrack.y = Math.round((this.actualHeight - this.onTrack.height) / 2);
			}
		}
		
		protected function childProperties_onChange(proxy:PropertyProxy, name:Object) : void {
			this.invalidate("styles");
		}
		
		protected function toggleSwitch_removedFromStageHandler(event:Event) : void {
			this._touchPointID = -1;
		}
		
		override protected function focusInHandler(event:Event) : void {
			super.focusInHandler(event);
			this.stage.addEventListener("keyDown",stage_keyDownHandler);
			this.stage.addEventListener("keyUp",stage_keyUpHandler);
		}
		
		override protected function focusOutHandler(event:Event) : void {
			super.focusOutHandler(event);
			this.stage.removeEventListener("keyDown",stage_keyDownHandler);
			this.stage.removeEventListener("keyUp",stage_keyUpHandler);
		}
		
		protected function toggleSwitch_touchHandler(event:TouchEvent) : void {
			if(this._ignoreTapHandler) {
				this._ignoreTapHandler = false;
				return;
			}
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			var _local3:Touch = event.getTouch(this,"ended");
			if(!_local3) {
				return;
			}
			this._touchPointID = -1;
			_local3.getLocation(this.stage,HELPER_POINT);
			var _local2:Boolean = this.contains(this.stage.hitTest(HELPER_POINT));
			if(_local2) {
				this.setSelectionWithAnimation(!this._isSelected);
			}
		}
		
		protected function thumb_touchHandler(event:TouchEvent) : void {
			var _local5:Touch = null;
			var _local7:Number = NaN;
			var _local4:Number = NaN;
			var _local2:Number = NaN;
			var _local3:Number = NaN;
			var _local6:Number = NaN;
			if(!this._isEnabled) {
				this._touchPointID = -1;
				return;
			}
			if(this._touchPointID >= 0) {
				_local5 = event.getTouch(this.thumb,null,this._touchPointID);
				if(!_local5) {
					return;
				}
				_local5.getLocation(this,HELPER_POINT);
				_local7 = this.actualWidth - this._paddingLeft - this._paddingRight - this.thumb.width;
				if(_local5.phase == "moved") {
					_local4 = HELPER_POINT.x - this._touchStartX;
					_local2 = Math.min(Math.max(this._paddingLeft,this._thumbStartX + _local4),this._paddingLeft + _local7);
					this.thumb.x = _local2;
					this.layoutTracks();
				} else if(_local5.phase == "ended") {
					_local3 = Math.abs(HELPER_POINT.x - this._touchStartX);
					_local6 = _local3 / DeviceCapabilities.dpi;
					if(_local6 > 0.04 || SystemUtil.isDesktop && _local3 >= 1) {
						this._touchPointID = -1;
						this._ignoreTapHandler = true;
						this.setSelectionWithAnimation(this.thumb.x > this._paddingLeft + _local7 / 2);
						this.invalidate("selected");
					}
				}
			} else {
				_local5 = event.getTouch(this.thumb,"began");
				if(!_local5) {
					return;
				}
				_local5.getLocation(this,HELPER_POINT);
				this._touchPointID = _local5.id;
				this._thumbStartX = this.thumb.x;
				this._touchStartX = HELPER_POINT.x;
			}
		}
		
		protected function stage_keyDownHandler(event:KeyboardEvent) : void {
			if(event.keyCode == 27) {
				this._touchPointID = -1;
			}
			if(this._touchPointID >= 0 || event.keyCode != 32) {
				return;
			}
			this._touchPointID = 0x7fffffff;
		}
		
		protected function stage_keyUpHandler(event:KeyboardEvent) : void {
			if(this._touchPointID != 0x7fffffff || event.keyCode != 32) {
				return;
			}
			this._touchPointID = -1;
			this.setSelectionWithAnimation(!this._isSelected);
		}
		
		protected function selectionTween_onUpdate() : void {
			this.layoutTracks();
		}
		
		protected function selectionTween_onComplete() : void {
			this._toggleTween = null;
		}
	}
}

