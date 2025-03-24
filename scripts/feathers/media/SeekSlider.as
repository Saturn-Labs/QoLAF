package feathers.media {
	import feathers.controls.Slider;
	import feathers.core.IValidating;
	import feathers.skins.IStyleProvider;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class SeekSlider extends Slider implements IMediaPlayerControl {
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		
		public static const DIRECTION_VERTICAL:String = "vertical";
		
		public static const TRACK_LAYOUT_MODE_SINGLE:String = "single";
		
		public static const TRACK_LAYOUT_MODE_MIN_MAX:String = "minMax";
		
		public static const TRACK_SCALE_MODE_EXACT_FIT:String = "exactFit";
		
		public static const TRACK_SCALE_MODE_DIRECTIONAL:String = "directional";
		
		public static const TRACK_INTERACTION_MODE_TO_VALUE:String = "toValue";
		
		public static const TRACK_INTERACTION_MODE_BY_PAGE:String = "byPage";
		
		public static const DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK:String = "feathers-seek-slider-minimum-track";
		
		public static const DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK:String = "feathers-seek-slider-maximum-track";
		
		public static const DEFAULT_CHILD_STYLE_NAME_THUMB:String = "feathers-seek-slider-thumb";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var _mediaPlayer:ITimedMediaPlayer;
		
		protected var _progress:Number = 0;
		
		protected var _progressSkin:DisplayObject;
		
		public function SeekSlider() {
			super();
			this.thumbStyleName = "feathers-seek-slider-thumb";
			this.minimumTrackStyleName = "feathers-seek-slider-minimum-track";
			this.maximumTrackStyleName = "feathers-seek-slider-maximum-track";
			this.addEventListener("change",seekSlider_changeHandler);
			this.addEventListener("endInteraction",seekSlider_endInteractionHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return SeekSlider.globalStyleProvider;
		}
		
		public function get mediaPlayer() : IMediaPlayer {
			return this._mediaPlayer;
		}
		
		public function set mediaPlayer(value:IMediaPlayer) : void {
			var _local2:IProgressiveMediaPlayer = null;
			if(this._mediaPlayer == value) {
				return;
			}
			if(this._mediaPlayer) {
				this._mediaPlayer.removeEventListener("loadProgress",mediaPlayer_loadProgressHandler);
				this._mediaPlayer.removeEventListener("currentTimeChange",mediaPlayer_currentTimeChangeHandler);
				this._mediaPlayer.removeEventListener("totalTimeChange",mediaPlayer_totalTimeChangeHandler);
			}
			this._mediaPlayer = value as ITimedMediaPlayer;
			if(this._mediaPlayer) {
				this._mediaPlayer.addEventListener("currentTimeChange",mediaPlayer_currentTimeChangeHandler);
				this._mediaPlayer.addEventListener("totalTimeChange",mediaPlayer_totalTimeChangeHandler);
				if(this._mediaPlayer is IProgressiveMediaPlayer) {
					_local2 = IProgressiveMediaPlayer(this._mediaPlayer);
					_local2.addEventListener("loadProgress",mediaPlayer_loadProgressHandler);
					if(_local2.bytesTotal > 0) {
						this._progress = _local2.bytesLoaded / _local2.bytesTotal;
					} else {
						this._progress = 0;
					}
				} else {
					this._progress = 0;
				}
				this.minimum = 0;
				this.maximum = this._mediaPlayer.totalTime;
				this.value = this._mediaPlayer.currentTime;
			} else {
				this.minimum = 0;
				this.maximum = 0;
				this.value = 0;
			}
		}
		
		public function get progressSkin() : DisplayObject {
			return this._progressSkin;
		}
		
		public function set progressSkin(value:DisplayObject) : void {
			if(this._progressSkin == value) {
				return;
			}
			if(this._progressSkin) {
				this.removeChild(this._progressSkin);
			}
			this._progressSkin = value;
			if(this._progressSkin) {
				if(this._progressSkin.parent != this) {
					this._progressSkin.visible = false;
					this.addChild(this._progressSkin);
				}
				this._progressSkin.touchable = false;
			}
			this.invalidate("styles");
		}
		
		override protected function layoutChildren() : void {
			super.layoutChildren();
			this.layoutProgressSkin();
		}
		
		protected function layoutProgressSkin() : void {
			var _local4:Number = NaN;
			var _local6:Number = NaN;
			var _local3:* = NaN;
			var _local2:Number = NaN;
			var _local7:Number = NaN;
			var _local1:* = NaN;
			var _local5:Number = NaN;
			if(this._progressSkin === null) {
				return;
			}
			if(this._minimum === this._maximum) {
				_local4 = 1;
			} else {
				_local4 = (this._value - this._minimum) / (this._maximum - this._minimum);
				if(_local4 < 0) {
					_local4 = 0;
				} else if(_local4 > 1) {
					_local4 = 1;
				}
			}
			if(this._progress === 0 || this._progress <= _local4) {
				this._progressSkin.visible = false;
				return;
			}
			this._progressSkin.visible = true;
			if(this._progressSkin is IValidating) {
				IValidating(this._progressSkin).validate();
			}
			if(this._direction === "vertical") {
				_local6 = this.actualHeight - this.thumb.height / 2 - this._minimumPadding - this._maximumPadding;
				this._progressSkin.x = Math.round((this.actualWidth - this._progressSkin.width) / 2);
				_local3 = Math.round(_local6 * this._progress);
				_local2 = Math.round(this.thumb.y + this.thumb.height / 2);
				if(_local3 < 0) {
					_local3 = 0;
				} else if(_local3 > _local2) {
					_local3 = _local2;
				}
				this._progressSkin.height = _local3;
				this._progressSkin.y = _local2 - _local3;
			} else {
				_local7 = this.actualWidth - this._minimumPadding - this._maximumPadding;
				this._progressSkin.x = Math.round(this.thumb.x + this.thumb.width / 2);
				this._progressSkin.y = Math.round((this.actualHeight - this._progressSkin.height) / 2);
				_local1 = Math.round(_local7 * this._progress - this._progressSkin.x);
				if(_local1 < 0) {
					_local1 = 0;
				} else {
					_local5 = Math.round(this.actualWidth - this._progressSkin.x);
					if(_local1 > _local5) {
						_local1 = _local5;
					}
				}
				this._progressSkin.width = _local1;
			}
		}
		
		protected function updateValueFromMediaPlayerCurrentTime() : void {
			if(this.isDragging) {
				return;
			}
			this._value = this._mediaPlayer.currentTime;
			this.invalidate("data");
		}
		
		protected function seekSlider_changeHandler(event:Event) : void {
			if(!this._mediaPlayer) {
				return;
			}
			this._mediaPlayer.seek(this._value);
		}
		
		protected function seekSlider_endInteractionHandler(event:Event) : void {
			this.updateValueFromMediaPlayerCurrentTime();
		}
		
		protected function mediaPlayer_currentTimeChangeHandler(event:Event) : void {
			this.updateValueFromMediaPlayerCurrentTime();
		}
		
		protected function mediaPlayer_totalTimeChangeHandler(event:Event) : void {
			this.maximum = this._mediaPlayer.totalTime;
		}
		
		protected function mediaPlayer_loadProgressHandler(event:Event, progress:Number) : void {
			if(this._progress === progress) {
				return;
			}
			this._progress = progress;
			this.invalidate("data");
		}
	}
}

