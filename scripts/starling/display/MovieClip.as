package starling.display {
	import flash.errors.IllegalOperationError;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import starling.animation.IAnimatable;
	import starling.textures.Texture;
	
	public class MovieClip extends Image implements IAnimatable {
		private var _frames:Vector.<MovieClipFrame>;
		
		private var _defaultFrameDuration:Number;
		
		private var _currentTime:Number;
		
		private var _currentFrameID:int;
		
		private var _loop:Boolean;
		
		private var _playing:Boolean;
		
		private var _muted:Boolean;
		
		private var _wasStopped:Boolean;
		
		private var _soundTransform:SoundTransform;
		
		public function MovieClip(textures:Vector.<Texture>, fps:Number = 12) {
			if(textures.length > 0) {
				super(textures[0]);
				init(textures,fps);
				return;
			}
			throw new ArgumentError("Empty texture array");
		}
		
		private function init(textures:Vector.<Texture>, fps:Number) : void {
			var _local4:int = 0;
			if(fps <= 0) {
				throw new ArgumentError("Invalid fps: " + fps);
			}
			var _local3:int = int(textures.length);
			_defaultFrameDuration = 1 / fps;
			_loop = true;
			_playing = true;
			_currentTime = 0;
			_currentFrameID = 0;
			_wasStopped = true;
			_frames = new Vector.<MovieClipFrame>(0);
			_local4 = 0;
			while(_local4 < _local3) {
				_frames[_local4] = new MovieClipFrame(textures[_local4],_defaultFrameDuration,_defaultFrameDuration * _local4);
				_local4++;
			}
		}
		
		public function addFrame(texture:Texture, sound:Sound = null, duration:Number = -1) : void {
			addFrameAt(numFrames,texture,sound,duration);
		}
		
		public function addFrameAt(frameID:int, texture:Texture, sound:Sound = null, duration:Number = -1) : void {
			var _local6:Number = NaN;
			var _local5:Number = NaN;
			if(frameID < 0 || frameID > numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			if(duration < 0) {
				duration = _defaultFrameDuration;
			}
			var _local7:MovieClipFrame = new MovieClipFrame(texture,duration);
			_local7.sound = sound;
			_frames.insertAt(frameID,_local7);
			if(frameID == numFrames) {
				_local6 = Number(frameID > 0 ? _frames[frameID - 1].startTime : 0);
				_local5 = Number(frameID > 0 ? _frames[frameID - 1].duration : 0);
				_local7.startTime = _local6 + _local5;
			} else {
				updateStartTimes();
			}
		}
		
		public function removeFrameAt(frameID:int) : void {
			if(frameID < 0 || frameID >= numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			if(numFrames == 1) {
				throw new IllegalOperationError("Movie clip must not be empty");
			}
			_frames.removeAt(frameID);
			if(frameID != numFrames) {
				updateStartTimes();
			}
		}
		
		public function getFrameTexture(frameID:int) : Texture {
			if(frameID < 0 || frameID >= numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			return _frames[frameID].texture;
		}
		
		public function setFrameTexture(frameID:int, texture:Texture) : void {
			if(frameID < 0 || frameID >= numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			_frames[frameID].texture = texture;
		}
		
		public function getFrameSound(frameID:int) : Sound {
			if(frameID < 0 || frameID >= numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			return _frames[frameID].sound;
		}
		
		public function setFrameSound(frameID:int, sound:Sound) : void {
			if(frameID < 0 || frameID >= numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			_frames[frameID].sound = sound;
		}
		
		public function getFrameAction(frameID:int) : Function {
			if(frameID < 0 || frameID >= numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			return _frames[frameID].action;
		}
		
		public function setFrameAction(frameID:int, action:Function) : void {
			if(frameID < 0 || frameID >= numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			_frames[frameID].action = action;
		}
		
		public function getFrameDuration(frameID:int) : Number {
			if(frameID < 0 || frameID >= numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			return _frames[frameID].duration;
		}
		
		public function setFrameDuration(frameID:int, duration:Number) : void {
			if(frameID < 0 || frameID >= numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			_frames[frameID].duration = duration;
			updateStartTimes();
		}
		
		public function reverseFrames() : void {
			_frames.reverse();
			_currentTime = totalTime - _currentTime;
			_currentFrameID = numFrames - _currentFrameID - 1;
			updateStartTimes();
		}
		
		public function play() : void {
			_playing = true;
		}
		
		public function pause() : void {
			_playing = false;
		}
		
		public function stop() : void {
			_playing = false;
			_wasStopped = true;
			currentFrame = 0;
		}
		
		private function updateStartTimes() : void {
			var _local2:int = 0;
			var _local1:int = this.numFrames;
			var _local3:MovieClipFrame = _frames[0];
			_local3.startTime = 0;
			_local2 = 1;
			while(_local2 < _local1) {
				_frames[_local2].startTime = _local3.startTime + _local3.duration;
				_local3 = _frames[_local2];
				_local2++;
			}
		}
		
		public function advanceTime(passedTime:Number) : void {
			var _local2:Boolean = false;
			if(!_playing) {
				return;
			}
			var _local8:MovieClipFrame = _frames[_currentFrameID];
			if(_wasStopped) {
				_wasStopped = false;
				_local8.playSound(_soundTransform);
				if(_local8.action != null) {
					_local8.executeAction(this,_currentFrameID);
					advanceTime(passedTime);
					return;
				}
			}
			if(_currentTime == totalTime) {
				if(!_loop) {
					return;
				}
				_currentTime = 0;
				_currentFrameID = 0;
				_local8 = _frames[0];
				_local8.playSound(_soundTransform);
				texture = _local8.texture;
				if(_local8.action != null) {
					_local8.executeAction(this,_currentFrameID);
					advanceTime(passedTime);
					return;
				}
			}
			var _local3:int = _frames.length - 1;
			var _local4:Number = _local8.duration - _currentTime + _local8.startTime;
			var _local5:Boolean = false;
			var _local6:Function = null;
			var _local7:int = _currentFrameID;
			while(passedTime >= _local4) {
				_local2 = false;
				passedTime -= _local4;
				_currentTime = _local8.startTime + _local8.duration;
				if(_currentFrameID == _local3) {
					if(hasEventListener("complete")) {
						_local5 = true;
					} else {
						if(!_loop) {
							return;
						}
						_currentTime = 0;
						_currentFrameID = 0;
						_local2 = true;
					}
				} else {
					_currentFrameID += 1;
					_local2 = true;
				}
				_local8 = _frames[_currentFrameID];
				_local6 = _local8.action;
				if(_local2) {
					_local8.playSound(_soundTransform);
				}
				if(_local5) {
					texture = _local8.texture;
					dispatchEventWith("complete");
					advanceTime(passedTime);
					return;
				}
				if(_local6 != null) {
					texture = _local8.texture;
					_local8.executeAction(this,_currentFrameID);
					advanceTime(passedTime);
					return;
				}
				_local4 = _local8.duration;
				if(passedTime + 0.0001 > _local4 && passedTime - 0.0001 < _local4) {
					passedTime = _local4;
				}
			}
			if(_local7 != _currentFrameID) {
				texture = _frames[_currentFrameID].texture;
			}
			_currentTime += passedTime;
		}
		
		public function get numFrames() : int {
			return _frames.length;
		}
		
		public function get totalTime() : Number {
			var _local1:MovieClipFrame = _frames[_frames.length - 1];
			return _local1.startTime + _local1.duration;
		}
		
		public function get currentTime() : Number {
			return _currentTime;
		}
		
		public function set currentTime(value:Number) : void {
			if(value < 0 || value > totalTime) {
				throw new ArgumentError("Invalid time: " + value);
			}
			var _local2:int = _frames.length - 1;
			_currentTime = value;
			_currentFrameID = 0;
			while(_currentFrameID < _local2 && _frames[_currentFrameID + 1].startTime <= value) {
				++_currentFrameID;
			}
			var _local3:MovieClipFrame = _frames[_currentFrameID];
			texture = _local3.texture;
		}
		
		public function get loop() : Boolean {
			return _loop;
		}
		
		public function set loop(value:Boolean) : void {
			_loop = value;
		}
		
		public function get muted() : Boolean {
			return _muted;
		}
		
		public function set muted(value:Boolean) : void {
			_muted = value;
		}
		
		public function get soundTransform() : SoundTransform {
			return _soundTransform;
		}
		
		public function set soundTransform(value:SoundTransform) : void {
			_soundTransform = value;
		}
		
		public function get currentFrame() : int {
			return _currentFrameID;
		}
		
		public function set currentFrame(value:int) : void {
			if(value < 0 || value >= numFrames) {
				throw new ArgumentError("Invalid frame id");
			}
			currentTime = _frames[value].startTime;
		}
		
		public function get fps() : Number {
			return 1 / _defaultFrameDuration;
		}
		
		public function set fps(value:Number) : void {
			var _local4:int = 0;
			if(value <= 0) {
				throw new ArgumentError("Invalid fps: " + value);
			}
			var _local2:Number = 1 / value;
			var _local3:Number = _local2 / _defaultFrameDuration;
			_currentTime *= _local3;
			_defaultFrameDuration = _local2;
			_local4 = 0;
			while(_local4 < numFrames) {
				_frames[_local4].duration *= _local3;
				_local4++;
			}
			updateStartTimes();
		}
		
		public function get isPlaying() : Boolean {
			if(_playing) {
				return _loop || _currentTime < totalTime;
			}
			return false;
		}
		
		public function get isComplete() : Boolean {
			return !_loop && _currentTime >= totalTime;
		}
	}
}

import flash.media.Sound;
import flash.media.SoundTransform;
import starling.textures.Texture;

class MovieClipFrame {
	public var texture:Texture;
	
	public var sound:Sound;
	
	public var duration:Number;
	
	public var startTime:Number;
	
	public var action:Function;
	
	public function MovieClipFrame(texture:Texture, duration:Number = 0.1, startTime:Number = 0) {
		super();
		this.texture = texture;
		this.duration = duration;
		this.startTime = startTime;
	}
	
	public function playSound(transform:SoundTransform) : void {
		if(sound) {
			sound.play(0,0,transform);
		}
	}
	
	public function executeAction(movie:MovieClip, frameID:int) : void {
		var _local3:int = 0;
		if(action != null) {
			_local3 = int(action.length);
			if(_local3 == 0) {
				action();
			} else if(_local3 == 1) {
				action(movie);
			} else {
				if(_local3 != 2) {
					throw new Error("Frame actions support zero, one or two parameters: movie:MovieClip, frameID:int");
				}
				action(movie,frameID);
			}
		}
	}
}
