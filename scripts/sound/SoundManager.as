package sound {
	import com.greensock.TweenMax;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	import playerio.Client;
	import playerio.GameFS;
	
	public class SoundManager extends Sprite implements ISound {
		private static var audioPath:String = "/sound/";
		
		public static const TYPE_MUSIC:String = "music";
		
		public static const TYPE_EFFECT:String = "effects";
		
		public static const TYPE_VOICE:String = "voice";
		
		private var musicObjects:Dictionary = new Dictionary();
		
		private var effectObjects:Dictionary = new Dictionary();
		
		private var soundObjects:Dictionary = new Dictionary();
		
		private var soundObjectsByName:Dictionary = new Dictionary();
		
		private var callbackQueue:Dictionary = new Dictionary();
		
		private var _effectVolume:Number = 0.5;
		
		private var _musicVolume:Number = 0.5;
		
		private var loadItems:Array;
		
		private var totalItems:int = 0;
		
		private var currItem:int = 0;
		
		private var percentageLoaded:int = 0;
		
		private var fs:GameFS;
		
		private var _client:Client;
		
		public function SoundManager(client:Client) {
			super();
			_client = client;
			this.fs = client.gameFS;
			percentageLoaded = 0;
			currItem = 1;
			volume = 0.5;
		}
		
		public function set client(value:Client) : void {
			_client = value;
			this.fs = _client.gameFS;
		}
		
		public function play(key:String, loadCompleteCallback:Function = null, playCompleteCallback:Function = null) : void {
			internalPlay("effects",key,false,false,loadCompleteCallback,playCompleteCallback);
		}
		
		public function playMusic(key:String, loop:Boolean = false, resume:Boolean = false, loadCompleteCallback:Function = null, playCompleteCallback:Function = null, fade:Boolean = false) : void {
			var fadeDelay:int;
			stopAllMusicExcept(key);
			fadeDelay = 0;
			if(fade) {
				fadeDelay = 1;
			}
			TweenMax.delayedCall(fadeDelay,function():void {
				internalPlay("music",key,loop,resume,loadCompleteCallback,playCompleteCallback);
			});
		}
		
		public function preCacheSound(key:String, callback:Function = null, type:String = "effect") : void {
			if(soundObjects.hasOwnProperty(key)) {
				if(callback != null) {
					callback();
				}
				return;
			}
			getSoundObject(key,function(param1:SoundObject):void {
				if(callback != null) {
					callback();
				}
			},type);
		}
		
		public function stop(key:String, callback:Function = null) : void {
			getSoundObject(key,function(param1:SoundObject):void {
				param1.stop();
				if(callback != null) {
					callback();
				}
			});
		}
		
		public function stopMusic() : void {
			for each(var _local1 in musicObjects) {
				_local1.pause();
			}
		}
		
		public function stopAllMusicExcept(key:String, fade:Boolean = true) : void {
			var _local4:int = 1;
			for each(var _local3 in musicObjects) {
				if(_local3.key != key) {
					if(fade) {
						_local3.fadeStop();
					} else {
						_local3.stop();
					}
				}
			}
		}
		
		private function internalPlay(type:String, key:String, loop:Boolean, resume:Boolean, loadCompleteCallback:Function = null, playCompleteCallback:Function = null) : void {
			if(type == "effects" && _effectVolume < 0.1 && loadCompleteCallback == null && playCompleteCallback == null) {
				return;
			}
			if(type == "music" && _musicVolume < 0.1 && loadCompleteCallback == null && playCompleteCallback == null) {
				return;
			}
			getSoundObject(key,function(param1:SoundObject):void {
				var sc:SoundChannel;
				var sObject:SoundObject = param1;
				var volume:Number = sObject.originalVolume;
				if(type == "music") {
					volume *= musicVolume;
				} else if(type == "effects") {
					volume *= effectVolume;
				}
				if(resume) {
					sc = sObject.resume(volume,loop);
				} else {
					sc = sObject.playObject(volume,loop);
				}
				if(loadCompleteCallback != null) {
					loadCompleteCallback(sc);
				}
				if(sc == null) {
					return;
				}
				if(playCompleteCallback != null) {
					sc.addEventListener("soundComplete",(function():* {
						var onComplete:Function;
						return onComplete = function(param1:Event):void {
							sc.removeEventListener("soundComplete",onComplete);
							playCompleteCallback();
						};
					})());
				}
			},type);
		}
		
		public function load(items:Array) : void {
			loadItems = items;
			totalItems = items.length;
			loadOne(currItem - 1);
		}
		
		private function loadOne(what:int) : void {
			var _local2:SoundObject = new SoundObject(fs.getUrl(audioPath + loadItems[what].toString(),Login.useSecure));
			_local2.addEventListener("progress",onLoadProgress);
			_local2.addEventListener("complete",onLoadComplete);
			_local2.addEventListener("ioError",onIOError);
		}
		
		private function onIOError(error:IOErrorEvent) : void {
			Console.write("Load sound error: " + error);
		}
		
		private function onLoadProgress(e:Event) : void {
			var _local2:int = Math.ceil(e.target.bytesLoaded / e.target.bytesTotal * 100 * currItem / totalItems);
			if(_local2 > percentageLoaded) {
				percentageLoaded = _local2;
			}
			dispatchEvent(new Event("preloadProgress"));
		}
		
		private function onLoadComplete(e:Event) : void {
			soundObjects[loadItems[currItem - 1]] = e.target as SoundObject;
			if(currItem == totalItems) {
				e.target.removeEventListener("progress",onLoadProgress);
				e.target.removeEventListener("complete",onLoadComplete);
				e.target.removeEventListener("ioError",onIOError);
				dispatchEvent(new Event("preloadComplete"));
			} else {
				currItem += 1;
				loadOne(currItem - 1);
			}
		}
		
		public function get percLoaded() : int {
			return percentageLoaded;
		}
		
		private function getSoundObject(key:String, callback:Function, type:String = "effects") : void {
			var _local6:IDataManager = null;
			var _local4:Object = null;
			var _local5:Array = null;
			if(key == null) {
				return;
			}
			if(soundObjects.hasOwnProperty(key)) {
				callback(soundObjects[key] as SoundObject);
			} else {
				_local6 = DataLocator.getService();
				_local4 = _local6.loadKey("Sounds",key);
				if(_local4 == null) {
					return;
				}
				if(callbackQueue.hasOwnProperty(key)) {
					_local5 = callbackQueue[key];
					_local5.push(callback);
				} else {
					_local5 = [];
					_local5.push(callback);
					callbackQueue[key] = _local5;
					cacheSound(type,key,_local4);
				}
			}
		}
		
		private function cacheSound(type:String, key:String, obj:Object) : void {
			loadSoundFromFS(obj.type + "/" + obj.fileName,function(param1:SoundObject):void {
				param1.originalVolume = obj.volume;
				soundObjects[key] = param1;
				param1.key = key;
				if(type == "music") {
					musicObjects[key] = param1;
				} else {
					param1.multipleAllowed = true;
					effectObjects[key] = param1;
				}
				for each(var _local2 in callbackQueue[key]) {
					_local2(param1);
				}
				delete callbackQueue[key];
			});
		}
		
		private function loadSoundFromUrl(url:String, callback:Function) : void {
			var s:SoundObject = new SoundObject(url);
			s.addEventListener("complete",(function():* {
				var onComplete:Function;
				return onComplete = function(param1:Event):void {
					var _local2:SoundObject = param1.target as SoundObject;
					s.removeEventListener("complete",onComplete);
					s.removeEventListener("ioError",onIOError);
					callback(_local2);
				};
			})());
			s.addEventListener("ioError",onIOError);
		}
		
		private function loadSoundFromFS(fileName:String, callback:Function) : void {
			loadSoundFromUrl(fs.getUrl(audioPath + fileName,Login.useSecure),function(param1:SoundObject):void {
				callback(param1);
			});
		}
		
		public function get musicVolume() : Number {
			return _musicVolume;
		}
		
		public function set musicVolume(value:Number) : void {
			_musicVolume = value;
			for each(var _local2 in musicObjects) {
				_local2.volume = _local2.originalVolume * value;
			}
			if(Game.instance) {
				Playlist.play(Game.instance.solarSystem.key);
			}
		}
		
		public function get effectVolume() : Number {
			return _effectVolume;
		}
		
		public function set effectVolume(value:Number) : void {
			_effectVolume = value;
			for each(var _local2 in effectObjects) {
				_local2.volume = _local2.originalVolume * value;
			}
		}
		
		public function get volume() : Number {
			return SoundMixer.soundTransform.volume;
		}
		
		public function set volume(value:Number) : void {
			var _local2:SoundTransform = SoundMixer.soundTransform;
			_local2.volume = value;
			SoundMixer.soundTransform = _local2;
			for each(var _local3 in soundObjects) {
				_local3.volume = _local3.originalVolume * value;
			}
		}
		
		public function stopAll() : void {
			SoundMixer.stopAll();
		}
	}
}

