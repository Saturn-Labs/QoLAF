package feathers.media {
	import feathers.controls.LayoutGroup;
	import feathers.core.PopUpManager;
	import feathers.skins.IStyleProvider;
	import feathers.utils.display.stageToStarling;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.rendering.Painter;
	import starling.textures.Texture;
	
	public class VideoPlayer extends BaseTimedMediaPlayer implements IVideoPlayer, IProgressiveMediaPlayer {
		protected static const NET_STATUS_CODE_NETCONNECTION_CONNECT_SUCCESS:String = "NetConnection.Connect.Success";
		
		protected static const NET_STATUS_CODE_NETSTREAM_PLAY_START:String = "NetStream.Play.Start";
		
		protected static const NET_STATUS_CODE_NETSTREAM_PLAY_STOP:String = "NetStream.Play.Stop";
		
		protected static const NET_STATUS_CODE_NETSTREAM_PLAY_STREAMNOTFOUND:String = "NetStream.Play.StreamNotFound";
		
		protected static const NET_STATUS_CODE_NETSTREAM_PLAY_NOSUPPORTEDTRACKFOUND:String = "NetStream.Play.NoSupportedTrackFound";
		
		protected static const NO_VIDEO_SOURCE_PLAY_ERROR:String = "Cannot play media when videoSource property has not been set.";
		
		protected static const NO_VIDEO_SOURCE_PAUSE_ERROR:String = "Cannot pause media when videoSource property has not been set.";
		
		protected static const NO_VIDEO_SOURCE_SEEK_ERROR:String = "Cannot seek media when videoSource property has not been set.";
		
		public static var globalStyleProvider:IStyleProvider;
		
		protected var _fullScreenContainer:LayoutGroup;
		
		protected var _ignoreDisplayListEvents:Boolean = false;
		
		protected var _soundTransform:SoundTransform;
		
		protected var _isWaitingForTextureReady:Boolean = false;
		
		protected var _texture:Texture;
		
		protected var _netConnection:NetConnection;
		
		protected var _netStream:NetStream;
		
		protected var _hasPlayedToEnd:Boolean = false;
		
		protected var _videoSource:String;
		
		protected var _autoPlay:Boolean = true;
		
		protected var _isFullScreen:Boolean = false;
		
		protected var _normalDisplayState:String = "normal";
		
		protected var _fullScreenDisplayState:String = "fullScreenInteractive";
		
		protected var _hideRootWhenFullScreen:Boolean = true;
		
		protected var _netConnectionFactory:Function = defaultNetConnectionFactory;
		
		protected var _bytesLoaded:uint = 0;
		
		protected var _bytesTotal:uint = 0;
		
		public function VideoPlayer() {
			super();
		}
		
		protected static function defaultNetConnectionFactory() : NetConnection {
			var _local1:NetConnection = new NetConnection();
			_local1.connect(null);
			return _local1;
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return VideoPlayer.globalStyleProvider;
		}
		
		public function get soundTransform() : SoundTransform {
			if(!this._soundTransform) {
				this._soundTransform = new SoundTransform();
			}
			return this._soundTransform;
		}
		
		public function set soundTransform(value:SoundTransform) : void {
			this._soundTransform = value;
			if(this._netStream) {
				this._netStream.soundTransform = this._soundTransform;
			}
			this.dispatchEventWith("soundTransformChange");
		}
		
		public function get texture() : Texture {
			if(this._isWaitingForTextureReady) {
				return null;
			}
			return this._texture;
		}
		
		public function get nativeWidth() : Number {
			if(this._texture) {
				return this._texture.nativeWidth;
			}
			return 0;
		}
		
		public function get nativeHeight() : Number {
			if(this._texture) {
				return this._texture.nativeHeight;
			}
			return 0;
		}
		
		public function get netStream() : NetStream {
			return this._netStream;
		}
		
		public function get videoSource() : String {
			return this._videoSource;
		}
		
		public function set videoSource(value:String) : void {
			if(this._videoSource === value) {
				return;
			}
			if(this._isPlaying) {
				this.stop();
			}
			this.disposeNetStream();
			if(!value) {
				this.disposeNetConnection();
			}
			if(this._texture !== null) {
				this._texture.dispose();
				this._texture = null;
				this.dispatchEventWith("clear");
			}
			this._videoSource = value;
			if(this._currentTime !== 0) {
				this._currentTime = 0;
				this.dispatchEventWith("currentTimeChange");
			}
			if(this._totalTime !== 0) {
				this._totalTime = 0;
				this.dispatchEventWith("totalTimeChange");
			}
			this._bytesLoaded = 0;
			this._bytesTotal = 0;
			if(this._autoPlay && this._videoSource) {
				this.play();
			}
		}
		
		public function get autoPlay() : Boolean {
			return this._autoPlay;
		}
		
		public function set autoPlay(value:Boolean) : void {
			this._autoPlay = value;
		}
		
		public function get isFullScreen() : Boolean {
			return this._isFullScreen;
		}
		
		public function get normalDisplayState() : String {
			return this._normalDisplayState;
		}
		
		public function set normalDisplayState(value:String) : void {
			var _local2:Starling = null;
			var _local3:Stage = null;
			if(this._normalDisplayState == value) {
				return;
			}
			this._normalDisplayState = value;
			if(!this._isFullScreen && this.stage) {
				_local2 = stageToStarling(this.stage);
				_local3 = _local2.nativeStage;
				_local3.displayState = this._normalDisplayState;
			}
		}
		
		public function get fullScreenDisplayState() : String {
			return this._fullScreenDisplayState;
		}
		
		public function set fullScreenDisplayState(value:String) : void {
			var _local2:Starling = null;
			var _local3:Stage = null;
			if(this._fullScreenDisplayState == value) {
				return;
			}
			this._fullScreenDisplayState = value;
			if(this._isFullScreen && this.stage) {
				_local2 = stageToStarling(this.stage);
				_local3 = _local2.nativeStage;
				_local3.displayState = this._fullScreenDisplayState;
			}
		}
		
		public function get hideRootWhenFullScreen() : Boolean {
			return this._hideRootWhenFullScreen;
		}
		
		public function set hideRootWhenFullScreen(value:Boolean) : void {
			this._hideRootWhenFullScreen = value;
		}
		
		public function get netConnectionFactory() : Function {
			return this._netConnectionFactory;
		}
		
		public function set netConnectionFactory(value:Function) : void {
			if(this._netConnectionFactory === value) {
				return;
			}
			this._netConnectionFactory = value;
			this.stop();
			this.disposeNetStream();
			this.disposeNetConnection();
		}
		
		public function get bytesLoaded() : uint {
			return this._bytesLoaded;
		}
		
		public function get bytesTotal() : uint {
			return this._bytesTotal;
		}
		
		override public function dispose() : void {
			this.videoSource = null;
			super.dispose();
		}
		
		override public function play() : void {
			if(this._videoSource === null) {
				return;
			}
			super.play();
		}
		
		override public function stop() : void {
			if(this._videoSource === null) {
				return;
			}
			super.stop();
		}
		
		override public function render(painter:Painter) : void {
			if(this._isFullScreen) {
				return;
			}
			super.render(painter);
		}
		
		public function toggleFullScreen() : void {
			var _local4:int = 0;
			var _local3:int = 0;
			var _local6:DisplayObject = null;
			if(!this.stage) {
				throw new IllegalOperationError("Cannot enter full screen mode if the video player does not have access to the Starling stage.");
			}
			var _local1:Starling = stageToStarling(this.stage);
			var _local2:Stage = _local1.nativeStage;
			var _local5:Boolean = this._ignoreDisplayListEvents;
			this._ignoreDisplayListEvents = true;
			if(this._isFullScreen) {
				this.root.visible = true;
				PopUpManager.removePopUp(this._fullScreenContainer,false);
				_local4 = this._fullScreenContainer.numChildren;
				_local3 = 0;
				while(_local3 < _local4) {
					_local6 = this._fullScreenContainer.getChildAt(0);
					this.addChild(_local6);
					_local3++;
				}
				_local2.displayState = this._normalDisplayState;
			} else {
				if(this._hideRootWhenFullScreen) {
					this.root.visible = false;
				}
				_local2.displayState = this._fullScreenDisplayState;
				if(!this._fullScreenContainer) {
					this._fullScreenContainer = new LayoutGroup();
					this._fullScreenContainer.autoSizeMode = "stage";
				}
				this._fullScreenContainer.layout = this._layout;
				_local4 = this.numChildren;
				_local3 = 0;
				while(_local3 < _local4) {
					_local6 = this.getChildAt(0);
					this._fullScreenContainer.addChild(_local6);
					_local3++;
				}
				PopUpManager.addPopUp(this._fullScreenContainer,true,false);
			}
			this._ignoreDisplayListEvents = _local5;
			this._isFullScreen = !this._isFullScreen;
			this.dispatchEventWith("displayStageChange");
		}
		
		override protected function playMedia() : void {
			var _local1:Function = null;
			if(!this._videoSource) {
				throw new IllegalOperationError("Cannot play media when videoSource property has not been set.");
			}
			if(this._netConnection === null) {
				_local1 = this._netConnectionFactory !== null ? this._netConnectionFactory : defaultNetConnectionFactory;
				this._netConnection = NetConnection(_local1());
			}
			if(this._netStream === null) {
				if(!this._netConnection.connected) {
					this._netConnection.addEventListener("netStatus",netConnection_netStatusHandler);
					return;
				}
				this._netStream = new NetStream(this._netConnection);
				this._netStream.client = new VideoPlayerNetStreamClient(this.netStream_onMetaData);
				this._netStream.addEventListener("netStatus",netStream_netStatusHandler);
				this._netStream.addEventListener("ioError",netStream_ioErrorHandler);
			}
			if(this._soundTransform === null) {
				this._soundTransform = new SoundTransform();
			}
			this._netStream.soundTransform = this._soundTransform;
			var _local2:Function = videoTexture_onComplete;
			if(this._texture !== null) {
				if(this._hasPlayedToEnd) {
					this._netStream.play(this._videoSource);
				} else {
					this.addEventListener("enterFrame",videoPlayer_enterFrameHandler);
					this._netStream.resume();
				}
			} else {
				this._isWaitingForTextureReady = true;
				this._texture = Texture.fromNetStream(this._netStream,Starling.current.contentScaleFactor,_local2);
				this._texture.root.onRestore = videoTexture_onRestore;
				this._netStream.play(this._videoSource);
			}
			this._hasPlayedToEnd = false;
		}
		
		override protected function pauseMedia() : void {
			if(!this._videoSource) {
				throw new IllegalOperationError("Cannot pause media when videoSource property has not been set.");
			}
			this.removeEventListener("enterFrame",videoPlayer_enterFrameHandler);
			this._netStream.pause();
		}
		
		override protected function seekMedia(seconds:Number) : void {
			if(!this._videoSource) {
				throw new IllegalOperationError("Cannot seek media when videoSource property has not been set.");
			}
			this._currentTime = seconds;
			if(this._hasPlayedToEnd) {
				this.playMedia();
				return;
			}
			this._netStream.seek(seconds);
		}
		
		protected function disposeNetConnection() : void {
			if(this._netConnection === null) {
				return;
			}
			this._netConnection.removeEventListener("netStatus",netConnection_netStatusHandler);
			this._netConnection.close();
			this._netConnection = null;
		}
		
		protected function disposeNetStream() : void {
			if(this._netStream === null) {
				return;
			}
			this._netStream.removeEventListener("netStatus",netStream_netStatusHandler);
			this._netStream.removeEventListener("ioError",netStream_ioErrorHandler);
			this._netStream.close();
			this._netStream = null;
		}
		
		protected function videoPlayer_enterFrameHandler(event:Event) : void {
			this._currentTime = this._netStream.time;
			this.dispatchEventWith("currentTimeChange");
		}
		
		protected function videoPlayer_progress_enterFrameHandler(event:Event) : void {
			var _local3:Boolean = false;
			var _local4:Number = NaN;
			var _local2:Number = this._netStream.bytesTotal;
			if(_local2 > 0) {
				_local3 = false;
				_local4 = this._netStream.bytesLoaded;
				if(this._bytesTotal !== _local2) {
					this._bytesTotal = _local2;
					_local3 = true;
				}
				if(this._bytesLoaded !== _local4) {
					this._bytesLoaded = _local4;
					_local3 = true;
				}
				if(_local3) {
					this.dispatchEventWith("loadProgress",false,_local4 / _local2);
				}
				if(_local4 === _local2) {
					this.removeEventListener("enterFrame",videoPlayer_progress_enterFrameHandler);
				}
			}
		}
		
		protected function videoTexture_onRestore() : void {
			this.pauseMedia();
			this._isWaitingForTextureReady = true;
			this._texture.root.attachNetStream(this._netStream,videoTexture_onComplete);
			this._netStream.play(this._videoSource);
		}
		
		protected function videoTexture_onComplete() : void {
			this._isWaitingForTextureReady = false;
			this.dispatchEventWith("ready");
			var _local1:Number = this._netStream.bytesTotal;
			if(this._bytesTotal === 0 && _local1 > 0) {
				this._bytesLoaded = this._netStream.bytesLoaded;
				this._bytesTotal = _local1;
				this.dispatchEventWith("loadProgress",false,this._bytesLoaded / _local1);
				if(this._bytesLoaded !== this._bytesTotal) {
					this.addEventListener("enterFrame",videoPlayer_progress_enterFrameHandler);
				}
			}
		}
		
		protected function netConnection_netStatusHandler(event:NetStatusEvent) : void {
			var _local2:String = event.info.code;
			var _local3:* = _local2;
			if("NetConnection.Connect.Success" === _local3) {
				this.playMedia();
			}
		}
		
		protected function netStream_onMetaData(metadata:Object) : void {
			this.dispatchEventWith("dimensionsChange");
			this._totalTime = metadata.duration;
			this.dispatchEventWith("totalTimeChange");
			this.dispatchEventWith("metadataReceived",false,metadata);
		}
		
		protected function netStream_ioErrorHandler(event:IOErrorEvent) : void {
			this.dispatchEventWith(event.type,false,event);
		}
		
		protected function netStream_netStatusHandler(event:NetStatusEvent) : void {
			var _local2:String = event.info.code;
			switch(_local2) {
				case "NetStream.Play.StreamNotFound":
					this.dispatchEventWith("error",false,_local2);
					break;
				case "NetStream.Play.NoSupportedTrackFound":
					this.dispatchEventWith("error",false,_local2);
					break;
				case "NetStream.Play.Start":
					if(this._netStream.time !== this._currentTime) {
						this._netStream.seek(this._currentTime);
					}
					if(this._isPlaying) {
						this.addEventListener("enterFrame",videoPlayer_enterFrameHandler);
					} else {
						this.pauseMedia();
					}
					break;
				case "NetStream.Play.Stop":
					if(this._hasPlayedToEnd) {
						return;
					}
					this.removeEventListener("enterFrame",videoPlayer_enterFrameHandler);
					if(Starling.context.driverInfo !== "Disposed") {
						this.stop();
						this._hasPlayedToEnd = true;
						this.dispatchEventWith("complete");
					}
					break;
			}
		}
		
		override protected function mediaPlayer_addedHandler(event:Event) : void {
			if(this._ignoreDisplayListEvents) {
				return;
			}
			super.mediaPlayer_addedHandler(event);
		}
		
		override protected function mediaPlayer_removedHandler(event:Event) : void {
			if(this._ignoreDisplayListEvents) {
				return;
			}
			super.mediaPlayer_removedHandler(event);
		}
	}
}

dynamic class VideoPlayerNetStreamClient {
	public var onMetaDataCallback:Function;
	
	public function VideoPlayerNetStreamClient(onMetaDataCallback:Function) {
		super();
		this.onMetaDataCallback = onMetaDataCallback;
	}
	
	public function onMetaData(metadata:Object) : void {
		this.onMetaDataCallback(metadata);
	}
}
