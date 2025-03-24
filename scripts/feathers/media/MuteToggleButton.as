package feathers.media {
	import feathers.controls.ToggleButton;
	import feathers.controls.popups.DropDownPopUpContentManager;
	import feathers.controls.popups.IPopUpContentManager;
	import feathers.core.PropertyProxy;
	import feathers.skins.IStyleProvider;
	import flash.media.SoundTransform;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	
	public class MuteToggleButton extends ToggleButton implements IMediaPlayerControl {
		protected static const INVALIDATION_FLAG_VOLUME_SLIDER_FACTORY:String = "volumeSliderFactory";
		
		public static const DEFAULT_CHILD_STYLE_NAME_VOLUME_SLIDER:String = "feathers-volume-toggle-button-volume-slider";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var volumeSliderStyleName:String = "feathers-volume-toggle-button-volume-slider";
		
		protected var slider:VolumeSlider;
		
		protected var _oldVolume:Number;
		
		protected var _ignoreChanges:Boolean = false;
		
		protected var _touchPointID:int = -1;
		
		protected var _popUpTouchPointID:int = -1;
		
		protected var _mediaPlayer:IAudioPlayer;
		
		protected var _popUpContentManager:IPopUpContentManager;
		
		protected var _showVolumeSliderOnHover:Boolean = false;
		
		protected var _volumeSliderFactory:Function;
		
		protected var _customVolumeSliderStyleName:String;
		
		protected var _volumeSliderProperties:PropertyProxy;
		
		protected var _isOpenPopUpPending:Boolean = false;
		
		protected var _isClosePopUpPending:Boolean = false;
		
		public function MuteToggleButton() {
			super();
			this.addEventListener("change",muteToggleButton_changeHandler);
			this.addEventListener("touch",muteToggleButton_touchHandler);
		}
		
		protected static function defaultVolumeSliderFactory() : VolumeSlider {
			var _local1:VolumeSlider = new VolumeSlider();
			_local1.direction = "vertical";
			return _local1;
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return MuteToggleButton.globalStyleProvider;
		}
		
		public function get mediaPlayer() : IMediaPlayer {
			return this._mediaPlayer;
		}
		
		public function set mediaPlayer(value:IMediaPlayer) : void {
			if(this._mediaPlayer == value) {
				return;
			}
			this._mediaPlayer = value as IAudioPlayer;
			this.refreshVolumeFromMediaPlayer();
			if(this._mediaPlayer) {
				this._mediaPlayer.addEventListener("soundTransformChange",mediaPlayer_soundTransformChangeHandler);
			}
			this.invalidate("data");
		}
		
		public function get popUpContentManager() : IPopUpContentManager {
			return this._popUpContentManager;
		}
		
		public function set popUpContentManager(value:IPopUpContentManager) : void {
			var _local2:EventDispatcher = null;
			if(this._popUpContentManager == value) {
				return;
			}
			if(this._popUpContentManager is EventDispatcher) {
				_local2 = EventDispatcher(this._popUpContentManager);
				_local2.removeEventListener("open",popUpContentManager_openHandler);
				_local2.removeEventListener("close",popUpContentManager_closeHandler);
			}
			this._popUpContentManager = value;
			if(this._popUpContentManager is EventDispatcher) {
				_local2 = EventDispatcher(this._popUpContentManager);
				_local2.addEventListener("open",popUpContentManager_openHandler);
				_local2.addEventListener("close",popUpContentManager_closeHandler);
			}
			this.invalidate("styles");
		}
		
		public function get showVolumeSliderOnHover() : Boolean {
			return this._showVolumeSliderOnHover;
		}
		
		public function set showVolumeSliderOnHover(value:Boolean) : void {
			if(this._showVolumeSliderOnHover == value) {
				return;
			}
			this._showVolumeSliderOnHover = value;
			this.invalidate("volumeSliderFactory");
		}
		
		public function get volumeSliderFactory() : Function {
			return this._volumeSliderFactory;
		}
		
		public function set volumeSliderFactory(value:Function) : void {
			if(this._volumeSliderFactory == value) {
				return;
			}
			this._volumeSliderFactory = value;
			this.invalidate("volumeSliderFactory");
		}
		
		public function get customVolumeSliderStyleName() : String {
			return this._customVolumeSliderStyleName;
		}
		
		public function set customVolumeSliderStyleName(value:String) : void {
			if(this._customVolumeSliderStyleName == value) {
				return;
			}
			this._customVolumeSliderStyleName = value;
			this.invalidate("volumeSliderFactory");
		}
		
		public function get volumeSliderProperties() : Object {
			if(!this._volumeSliderProperties) {
				this._volumeSliderProperties = new PropertyProxy(childProperties_onChange);
			}
			return this._volumeSliderProperties;
		}
		
		public function set volumeSliderProperties(value:Object) : void {
			var _local2:PropertyProxy = null;
			if(this._volumeSliderProperties == value) {
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
			if(this._volumeSliderProperties) {
				this._volumeSliderProperties.removeOnChangeCallback(childProperties_onChange);
			}
			this._volumeSliderProperties = PropertyProxy(value);
			if(this._volumeSliderProperties) {
				this._volumeSliderProperties.addOnChangeCallback(childProperties_onChange);
			}
			this.invalidate("styles");
		}
		
		public function openPopUp() : void {
			this._isClosePopUpPending = false;
			if(this._popUpContentManager.isOpen) {
				return;
			}
			if(!this._isValidating && this.isInvalid()) {
				this._isOpenPopUpPending = true;
				return;
			}
			this._isOpenPopUpPending = false;
			this._popUpContentManager.open(this.slider,this);
			this.slider.validate();
			this._popUpTouchPointID = -1;
			this.slider.addEventListener("touch",volumeSlider_touchHandler);
		}
		
		public function closePopUp() : void {
			this._isOpenPopUpPending = false;
			if(!this._popUpContentManager.isOpen) {
				return;
			}
			if(!this._isValidating && this.isInvalid()) {
				this._isClosePopUpPending = true;
				return;
			}
			this._isClosePopUpPending = false;
			this.slider.validate();
			this._popUpContentManager.close();
		}
		
		override public function dispose() : void {
			if(this.slider) {
				this.closePopUp();
				this.slider.mediaPlayer = null;
				this.slider.dispose();
				this.slider = null;
			}
			if(this._popUpContentManager) {
				this._popUpContentManager.dispose();
				this._popUpContentManager = null;
			}
			super.dispose();
		}
		
		override protected function initialize() : void {
			var _local1:DropDownPopUpContentManager = null;
			if(!this._popUpContentManager) {
				_local1 = new DropDownPopUpContentManager();
				_local1.fitContentMinWidthToOrigin = false;
				_local1.primaryDirection = "up";
				this.popUpContentManager = _local1;
			}
			super.initialize();
		}
		
		override protected function draw() : void {
			var _local2:Boolean = this.isInvalid("styles");
			var _local1:Boolean = this.isInvalid("volumeSliderFactory");
			if(_local1) {
				this.createVolumeSlider();
			}
			if(this.slider && (_local1 || _local2)) {
				this.refreshVolumeSliderProperties();
			}
			super.draw();
			this.handlePendingActions();
		}
		
		protected function createVolumeSlider() : void {
			if(this.slider) {
				this.slider.removeFromParent(false);
				this.slider.dispose();
				this.slider = null;
			}
			if(!this._showVolumeSliderOnHover) {
				return;
			}
			var _local1:Function = this._volumeSliderFactory != null ? this._volumeSliderFactory : defaultVolumeSliderFactory;
			var _local2:String = this._customVolumeSliderStyleName != null ? this._customVolumeSliderStyleName : this.volumeSliderStyleName;
			this.slider = VolumeSlider(_local1());
			this.slider.focusOwner = this;
			this.slider.styleNameList.add(_local2);
		}
		
		protected function refreshVolumeSliderProperties() : void {
			var _local2:Object = null;
			for(var _local1 in this._volumeSliderProperties) {
				_local2 = this._volumeSliderProperties[_local1];
				this.slider[_local1] = _local2;
			}
			this.slider.mediaPlayer = this._mediaPlayer;
		}
		
		protected function handlePendingActions() : void {
			if(this._isOpenPopUpPending) {
				this.openPopUp();
			}
			if(this._isClosePopUpPending) {
				this.closePopUp();
			}
		}
		
		protected function refreshVolumeFromMediaPlayer() : void {
			var _local1:Boolean = this._ignoreChanges;
			this._ignoreChanges = true;
			if(this._mediaPlayer) {
				this.isSelected = this._mediaPlayer.soundTransform.volume == 0;
			} else {
				this.isSelected = false;
			}
			this._ignoreChanges = _local1;
		}
		
		protected function mediaPlayer_soundTransformChangeHandler(event:Event) : void {
			this.refreshVolumeFromMediaPlayer();
		}
		
		protected function muteToggleButton_changeHandler(event:Event) : void {
			var _local2:Number = NaN;
			if(this._ignoreChanges || !this._mediaPlayer) {
				return;
			}
			var _local3:SoundTransform = this._mediaPlayer.soundTransform;
			if(this._isSelected) {
				this._oldVolume = _local3.volume;
				if(this._oldVolume === 0) {
					this._oldVolume = 1;
				}
				_local3.volume = 0;
				this._mediaPlayer.soundTransform = _local3;
			} else {
				_local2 = this._oldVolume;
				if(_local2 !== _local2) {
					_local2 = 1;
				}
				_local3.volume = _local2;
				this._mediaPlayer.soundTransform = _local3;
			}
		}
		
		protected function muteToggleButton_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(!this.slider) {
				this._touchPointID = -1;
				return;
			}
			if(this._touchPointID >= 0) {
				_local2 = event.getTouch(this,null,this._touchPointID);
				if(_local2) {
					return;
				}
				this._touchPointID = -1;
				_local2 = event.getTouch(this.slider);
				if(this._popUpTouchPointID < 0 && !_local2) {
					this.closePopUp();
				}
			} else {
				_local2 = event.getTouch(this,"hover");
				if(!_local2) {
					return;
				}
				this._touchPointID = _local2.id;
				this.openPopUp();
			}
		}
		
		protected function volumeSlider_touchHandler(event:TouchEvent) : void {
			var _local2:Touch = null;
			if(this._popUpTouchPointID >= 0) {
				_local2 = event.getTouch(this.slider,null,this._popUpTouchPointID);
				if(_local2) {
					return;
				}
				this._popUpTouchPointID = -1;
				_local2 = event.getTouch(this);
				if(this._touchPointID < 0 && !_local2) {
					this.closePopUp();
				}
			} else {
				_local2 = event.getTouch(this.slider,"hover");
				if(!_local2) {
					return;
				}
				this._popUpTouchPointID = _local2.id;
			}
		}
		
		protected function popUpContentManager_openHandler(event:Event) : void {
			this.dispatchEventWith("open");
		}
		
		protected function popUpContentManager_closeHandler(event:Event) : void {
			this.slider.removeEventListener("touch",volumeSlider_touchHandler);
			this.dispatchEventWith("close");
		}
	}
}

