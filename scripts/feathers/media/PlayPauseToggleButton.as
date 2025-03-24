package feathers.media {
	import feathers.controls.ToggleButton;
	import feathers.skins.IStyleProvider;
	import starling.events.Event;
	
	public class PlayPauseToggleButton extends ToggleButton implements IMediaPlayerControl {
		public static const ALTERNATE_STYLE_NAME_OVERLAY_PLAY_PAUSE_TOGGLE_BUTTON:String = "feathers-overlay-play-pause-toggle-button";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var _mediaPlayer:ITimedMediaPlayer;
		
		protected var _touchableWhenPlaying:Boolean = true;
		
		public function PlayPauseToggleButton() {
			super();
			this.isToggle = false;
			this.addEventListener("triggered",playPlayButton_triggeredHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return PlayPauseToggleButton.globalStyleProvider;
		}
		
		public function get mediaPlayer() : IMediaPlayer {
			return this._mediaPlayer;
		}
		
		public function set mediaPlayer(value:IMediaPlayer) : void {
			if(this._mediaPlayer == value) {
				return;
			}
			if(this._mediaPlayer) {
				this._mediaPlayer.removeEventListener("playbackStageChange",mediaPlayer_playbackStateChangeHandler);
			}
			this._mediaPlayer = value as ITimedMediaPlayer;
			this.refreshState();
			if(this._mediaPlayer) {
				this._mediaPlayer.addEventListener("playbackStageChange",mediaPlayer_playbackStateChangeHandler);
			}
			this.invalidate("data");
		}
		
		public function get touchableWhenPlaying() : Boolean {
			return this._touchableWhenPlaying;
		}
		
		public function set touchableWhenPlaying(value:Boolean) : void {
			if(this._touchableWhenPlaying == value) {
				return;
			}
			this._touchableWhenPlaying = value;
		}
		
		protected function refreshState() : void {
			if(!this._mediaPlayer) {
				this.isSelected = false;
				return;
			}
			this.isSelected = this._mediaPlayer.isPlaying;
			this.touchable = !this._isSelected || this._touchableWhenPlaying;
		}
		
		protected function playPlayButton_triggeredHandler(event:Event) : void {
			this._mediaPlayer.togglePlayPause();
		}
		
		protected function mediaPlayer_playbackStateChangeHandler(event:Event) : void {
			this.refreshState();
		}
	}
}

