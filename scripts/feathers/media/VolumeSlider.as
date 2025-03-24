package feathers.media {
	import feathers.controls.Slider;
	import feathers.skins.IStyleProvider;
	import flash.media.SoundTransform;
	import starling.events.Event;
	
	public class VolumeSlider extends Slider implements IMediaPlayerControl {
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		
		public static const DIRECTION_VERTICAL:String = "vertical";
		
		public static const TRACK_LAYOUT_MODE_SINGLE:String = "single";
		
		public static const TRACK_LAYOUT_MODE_MIN_MAX:String = "minMax";
		
		public static const TRACK_SCALE_MODE_EXACT_FIT:String = "exactFit";
		
		public static const TRACK_SCALE_MODE_DIRECTIONAL:String = "directional";
		
		public static const TRACK_INTERACTION_MODE_TO_VALUE:String = "toValue";
		
		public static const TRACK_INTERACTION_MODE_BY_PAGE:String = "byPage";
		
		public static const DEFAULT_CHILD_STYLE_NAME_MINIMUM_TRACK:String = "feathers-volume-slider-minimum-track";
		
		public static const DEFAULT_CHILD_STYLE_NAME_MAXIMUM_TRACK:String = "feathers-volume-slider-maximum-track";
		
		public static const DEFAULT_CHILD_STYLE_NAME_THUMB:String = "feathers-volume-slider-thumb";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var _ignoreChanges:Boolean = false;
		
		protected var _mediaPlayer:IAudioPlayer;
		
		public function VolumeSlider() {
			super();
			this.thumbStyleName = "feathers-volume-slider-thumb";
			this.minimumTrackStyleName = "feathers-volume-slider-minimum-track";
			this.maximumTrackStyleName = "feathers-volume-slider-maximum-track";
			this.minimum = 0;
			this.maximum = 1;
			this.addEventListener("change",volumeSlider_changeHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return VolumeSlider.globalStyleProvider;
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
		
		protected function refreshVolumeFromMediaPlayer() : void {
			var _local1:Boolean = this._ignoreChanges;
			this._ignoreChanges = true;
			if(this._mediaPlayer) {
				this.value = this._mediaPlayer.soundTransform.volume;
			} else {
				this.value = 0;
			}
			this._ignoreChanges = _local1;
		}
		
		protected function mediaPlayer_soundTransformChangeHandler(event:Event) : void {
			this.refreshVolumeFromMediaPlayer();
		}
		
		protected function volumeSlider_changeHandler(event:Event) : void {
			if(!this._mediaPlayer || this._ignoreChanges) {
				return;
			}
			var _local2:SoundTransform = this._mediaPlayer.soundTransform;
			_local2.volume = this._value;
			this._mediaPlayer.soundTransform = _local2;
		}
	}
}

