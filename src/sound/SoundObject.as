package sound
{
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	public class SoundObject extends Sound
	{
		private var position:Number;
		
		private var sc:SoundChannel;
		
		private var loop:Boolean;
		
		public var isPlaying:Boolean = false;
		private var _volume:Number;
		
		public var multipleAllowed:Boolean = false;
		public var key:String;
		
		private var _originalVolume:Number;
		
		private var soundChannels:Vector.<SoundChannel>;
		
		private var oldTime:int = 0;
		public function SoundObject(param1:String)
		{
			soundChannels = new Vector.<SoundChannel>();
			super(new URLRequest(param1), new SoundLoaderContext(1000, true));
			loop = false;
			position = 0;
		}
		
		public function playObject(param1:Number, param2:Boolean = false):SoundChannel
		{
			var _loc3_:uint = uint(getTimer());
			if (_loc3_ - oldTime < 33 * 2)
			{
				return null;
			}
			oldTime = _loc3_;
			this.loop = param2;
			sc = super.play();
			this.volume = param1;
			if (sc != null)
			{
				isPlaying = true;
				if (multipleAllowed)
				{
					soundChannels.push(sc);
				}
				if (param2)
				{
					sc.addEventListener("soundComplete", restartSoundChannel);
				}
				else
				{
					sc.addEventListener("soundComplete", killSoundChannel);
				}
			}
			return sc;
		}
		
		public function resume(param1:Number, param2:Boolean):SoundChannel
		{
			this.loop = param2;
			var _loc3_:SoundChannel = null;
			if (!sc)
			{
				return playObject(param1, param2);
			}
			if (isPlaying)
			{
				return sc;
			}
			fadePlay(position);
			return sc;
		}
		
		public function pause():void
		{
			if (sc != null)
			{
				position = sc.position;
				isPlaying = false;
				sc.stop();
			}
		}
		
		public function stop():void
		{
			isPlaying = false;
			if (multipleAllowed)
			{
				soundChannels.splice(soundChannels.indexOf(sc), 1);
			}
			if (sc != null)
			{
				sc.stop();
			}
			loop = false;
			sc = null;
		}
		
		public function fadePlay(param1:*, param2:Function = null):void
		{
			var tween:TweenMax;
			var position:* = param1;
			var callback:Function = param2;
			var soundManager:ISound = SoundLocator.getService();
			if (isPlaying)
			{
				trace("fadePlay: already playing");
				if (callback != null)
				{
					callback();
				}
				return;
			}
			if (sc != null)
			{
				trace("fadePlay: starting");
				volume = 0;
				sc = play(position);
				isPlaying = true;
				tween = TweenMax.to(this, 3, {"volume": originalVolume * soundManager.musicVolume, "onComplete": function():void
				{
					if (callback != null)
					{
						callback();
					}
				}});
			}
			else if (callback != null)
			{
				callback();
			}
		}
		
		public function fadeStop(param1:Function = null):void
		{
			var tween:TweenMax;
			var callback:Function = param1;
			if (sc != null)
			{
				tween = TweenMax.to(this, 3, {"volume": 0, "onComplete": function():void
				{
					stop();
					if (callback != null)
					{
						callback();
					}
				}});
			}
			else if (callback != null)
			{
				callback();
			}
		}
		
		private function restartSoundChannel(param1:Event):void
		{
			if (!loop)
			{
				return;
			}
			sc.removeEventListener("soundComplete", restartSoundChannel);
			sc.stop();
			sc = super.play();
			updateVolume();
			sc.addEventListener("soundComplete", restartSoundChannel);
		}
		
		private function updateVolume():void
		{
			var _loc1_:SoundTransform = null;
			if (sc != null)
			{
				_loc1_ = new SoundTransform(volume);
				sc.soundTransform = _loc1_;
			}
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(param1:Number):void
		{
			_volume = param1;
			updateVolume();
		}
		
		public function set originalVolume(param1:Number):void
		{
			_originalVolume = param1;
		}
		
		public function get originalVolume():Number
		{
			return _originalVolume;
		}
		
		private function killSoundChannel(param1:Event):void
		{
			var _loc2_:SoundChannel = param1.target as SoundChannel;
			isPlaying = false;
			if (multipleAllowed)
			{
				soundChannels.splice(soundChannels.indexOf(_loc2_), 1);
			}
			_loc2_.removeEventListener("soundComplete", restartSoundChannel);
			_loc2_.removeEventListener("soundComplete", killSoundChannel);
			_loc2_ = null;
			sc = null;
			loop = false;
		}
	}
}
