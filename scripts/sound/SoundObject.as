package sound {
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	public class SoundObject extends Sound {
		private var position:Number;
		
		private var sc:SoundChannel;
		
		private var loop:Boolean;
		
		public var isPlaying:Boolean = false;
		
		private var _volume:Number;
		
		public var multipleAllowed:Boolean = false;
		
		public var key:String;
		
		private var _originalVolume:Number;
		
		private var soundChannels:Vector.<SoundChannel> = new Vector.<SoundChannel>();
		
		private var oldTime:int = 0;
		
		public function SoundObject(url:String) {
			super(new URLRequest(url),new SoundLoaderContext(1000,true));
			loop = false;
			position = 0;
		}
		
		public function playObject(volume:Number, loop:Boolean = false) : SoundChannel {
			var _local3:uint = uint(getTimer());
			if(_local3 - oldTime < 33 * 2) {
				return null;
			}
			oldTime = _local3;
			this.loop = loop;
			sc = super.play();
			this.volume = volume;
			if(sc != null) {
				isPlaying = true;
				if(multipleAllowed) {
					soundChannels.push(sc);
				}
				if(loop) {
					sc.addEventListener("soundComplete",restartSoundChannel);
				} else {
					sc.addEventListener("soundComplete",killSoundChannel);
				}
			}
			return sc;
		}
		
		public function resume(volume:Number, loop:Boolean) : SoundChannel {
			this.loop = loop;
			var _local3:SoundChannel = null;
			if(!sc) {
				return playObject(volume,loop);
			}
			if(isPlaying) {
				return sc;
			}
			fadePlay(position);
			return sc;
		}
		
		public function pause() : void {
			if(sc != null) {
				position = sc.position;
				isPlaying = false;
				sc.stop();
			}
		}
		
		public function stop() : void {
			isPlaying = false;
			if(multipleAllowed) {
				soundChannels.splice(soundChannels.indexOf(sc),1);
			}
			if(sc != null) {
				sc.stop();
			}
			loop = false;
			sc = null;
		}
		
		public function fadePlay(position:*, callback:Function = null) : void {
			var tween:TweenMax;
			var soundManager:ISound = SoundLocator.getService();
			if(isPlaying) {
				trace("fadePlay: already playing");
				if(callback != null) {
					callback();
				}
				return;
			}
			if(sc != null) {
				trace("fadePlay: starting");
				volume = 0;
				sc = play(position);
				isPlaying = true;
				tween = TweenMax.to(this,3,{
					"volume":originalVolume * soundManager.musicVolume,
					"onComplete":function():void {
						if(callback != null) {
							callback();
						}
					}
				});
			} else if(callback != null) {
				callback();
			}
		}
		
		public function fadeStop(callback:Function = null) : void {
			var tween:TweenMax;
			if(sc != null) {
				tween = TweenMax.to(this,3,{
					"volume":0,
					"onComplete":function():void {
						stop();
						if(callback != null) {
							callback();
						}
					}
				});
			} else if(callback != null) {
				callback();
			}
		}
		
		private function restartSoundChannel(e:Event) : void {
			if(!loop) {
				return;
			}
			sc.removeEventListener("soundComplete",restartSoundChannel);
			sc.stop();
			sc = super.play();
			updateVolume();
			sc.addEventListener("soundComplete",restartSoundChannel);
		}
		
		private function updateVolume() : void {
			var _local1:SoundTransform = null;
			if(sc != null) {
				_local1 = new SoundTransform(volume);
				sc.soundTransform = _local1;
			}
		}
		
		public function get volume() : Number {
			return _volume;
		}
		
		public function set volume(value:Number) : void {
			_volume = value;
			updateVolume();
		}
		
		public function set originalVolume(value:Number) : void {
			_originalVolume = value;
		}
		
		public function get originalVolume() : Number {
			return _originalVolume;
		}
		
		private function killSoundChannel(e:Event) : void {
			var _local2:SoundChannel = e.target as SoundChannel;
			isPlaying = false;
			if(multipleAllowed) {
				soundChannels.splice(soundChannels.indexOf(_local2),1);
			}
			_local2.removeEventListener("soundComplete",restartSoundChannel);
			_local2.removeEventListener("soundComplete",killSoundChannel);
			_local2 = null;
			sc = null;
			loop = false;
		}
	}
}

