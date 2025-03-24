package feathers.media {
	import feathers.controls.ToggleButton;
	import feathers.skins.IStyleProvider;
	import starling.events.Event;
	
	public class FullScreenToggleButton extends ToggleButton implements IMediaPlayerControl {
		public static var globalStyleProvider:IStyleProvider;
		
		protected var _mediaPlayer:VideoPlayer;
		
		public function FullScreenToggleButton() {
			super();
			this.isToggle = false;
			this.addEventListener("triggered",fullScreenButton_triggeredHandler);
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return FullScreenToggleButton.globalStyleProvider;
		}
		
		public function get mediaPlayer() : IMediaPlayer {
			return this._mediaPlayer;
		}
		
		public function set mediaPlayer(value:IMediaPlayer) : void {
			if(this._mediaPlayer == value) {
				return;
			}
			if(this._mediaPlayer) {
				this._mediaPlayer.removeEventListener("displayStageChange",mediaPlayer_displayStageChangeHandler);
			}
			this._mediaPlayer = value as VideoPlayer;
			if(this._mediaPlayer) {
				this.isSelected = this._mediaPlayer.isFullScreen;
				this._mediaPlayer.addEventListener("displayStageChange",mediaPlayer_displayStageChangeHandler);
			}
		}
		
		protected function fullScreenButton_triggeredHandler(event:Event) : void {
			this._mediaPlayer.toggleFullScreen();
		}
		
		protected function mediaPlayer_displayStageChangeHandler(event:Event) : void {
			this.isSelected = this._mediaPlayer.isFullScreen;
		}
	}
}

