package data
{
	import core.scene.Game;
	import core.scene.SceneBase;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class Settings
	{
		public var sb:SceneBase;
		public var keybinds:KeyBinds;
		private var dirty:Boolean = false;
		private var soundManager:ISound;
		private var _musicVolume:Number = 0.5;
		private var _effectVolume:Number = 0.5;
		private var _showHud:Boolean = true;
		private var _showLatency:Boolean = false;
		private var _showEffects:Boolean = true;
		private var _showBackground:Boolean = true;
		private var _mouseAim:Boolean = true;
		private var _keyboardAim:Boolean = true;
		private var _rotationSpeed:Number = 1;
		private var _mouseFire:Boolean = false;
		private var _iWantAllTimedMissions:Boolean = false;
		private var _fireWithHotkeys:Boolean = true;
		private var _quality:int = 0;
		private var _chatMuted:String = "";
		
		public function Settings()
		{
			super();
			soundManager = SoundLocator.getService();
			keybinds = new KeyBinds();
		}
		
		public function init(message:Message, pointer:int):int
		{
			_musicVolume = message.getNumber(pointer++);
			_effectVolume = message.getNumber(pointer++);
			_showHud = message.getBoolean(pointer++);
			_showLatency = message.getBoolean(pointer++);
			_showEffects = message.getBoolean(pointer++);
			_showBackground = message.getBoolean(pointer++);
			_mouseAim = message.getBoolean(pointer++);
			_keyboardAim = message.getBoolean(pointer++);
			_rotationSpeed = message.getNumber(pointer++);
			_mouseFire = message.getBoolean(pointer++);
			_iWantAllTimedMissions = message.getBoolean(pointer++);
			_fireWithHotkeys = message.getBoolean(pointer++);
			_quality = message.getInt(pointer++);
			_chatMuted = message.getString(pointer++);
			if (message.getBoolean(pointer++))
			{
				keybinds.init(message, pointer);
				pointer += 2 * 27;
			}
			else
			{
				keybinds.init();
			}
			return pointer;
		}
		
		public function setPlayerValues(param1:Game):void
		{
			param1.parallaxManager.visible = showBackground;
			RymdenRunt.s.showStats = showLatency;
			param1.toggleHighGraphics(showEffects);
		}
		
		public function save():void
		{
			if (!dirty && !keybinds.dirty)
			{
				return;
			}
			var _loc1_:Message = sb.createMessage("settings", _musicVolume, _effectVolume, _showHud, _showLatency, _showEffects, _showBackground, _mouseAim, _keyboardAim, _rotationSpeed, _mouseFire, _iWantAllTimedMissions, _fireWithHotkeys, _quality, _chatMuted);
			keybinds.populateMessage(_loc1_);
			sb.sendMessage(_loc1_);
		}
		
		public function get musicVolume():Number
		{
			return _musicVolume;
		}
		
		public function set musicVolume(param1:Number):void
		{
			soundManager.musicVolume = param1;
			_musicVolume = param1;
			dirty = true;
		}
		
		public function get effectVolume():Number
		{
			return _effectVolume;
		}
		
		public function set effectVolume(param1:Number):void
		{
			soundManager.effectVolume = param1;
			_effectVolume = param1;
			dirty = true;
		}
		
		public function get showHud():Boolean
		{
			return _showHud;
		}
		
		public function set showHud(param1:Boolean):void
		{
			_showHud = param1;
			dirty = true;
		}
		
		public function get fireWithHotkeys():Boolean
		{
			return _fireWithHotkeys;
		}
		
		public function set fireWithHotkeys(param1:Boolean):void
		{
			_fireWithHotkeys = param1;
			dirty = true;
		}
		
		public function get showLatency():Boolean
		{
			return _showLatency;
		}
		
		public function set showLatency(param1:Boolean):void
		{
			_showLatency = param1;
			RymdenRunt.s.showStatsAt("left", "center");
			RymdenRunt.s.showStats = param1;
			dirty = true;
		}
		
		public function get showEffects():Boolean
		{
			return _showEffects;
		}
		
		public function set showEffects(param1:Boolean):void
		{
			_showEffects = param1;
			dirty = true;
		}
		
		public function get showBackground():Boolean
		{
			return _showBackground;
		}
		
		public function set showBackground(param1:Boolean):void
		{
			_showBackground = param1;
			dirty = true;
		}
		
		public function get mouseAim():Boolean
		{
			return _mouseAim;
		}
		
		public function set mouseAim(param1:Boolean):void
		{
			_mouseAim = param1;
			dirty = true;
		}
		
		public function get keyboardAim():Boolean
		{
			return _keyboardAim;
		}
		
		public function set keyboardAim(param1:Boolean):void
		{
			_keyboardAim = param1;
			dirty = true;
		}
		
		public function get rotationSpeed():Number
		{
			return _rotationSpeed;
		}
		
		public function set rotationSpeed(param1:Number):void
		{
			_rotationSpeed = param1;
			dirty = true;
		}
		
		public function get mouseFire():Boolean
		{
			return _mouseFire;
		}
		
		public function set mouseFire(param1:Boolean):void
		{
			_mouseFire = param1;
			dirty = true;
		}
		
		public function get quality():int
		{
			return _quality;
		}
		
		public function set quality(param1:int):void
		{
			_quality = param1;
			dirty = true;
		}
		
		public function get iWantAllTimedMissions():Boolean
		{
			return _iWantAllTimedMissions;
		}
		
		public function set iWantAllTimedMissions(param1:Boolean):void
		{
			_iWantAllTimedMissions = param1;
			dirty = true;
		}
		
		public function get chatMuted():Array
		{
			if (_chatMuted == "")
			{
				return [];
			}
			return _chatMuted.split(",");
		}
		
		public function set chatMuted(param1:Array):void
		{
			if (param1.length == 0)
			{
				_chatMuted = "";
				return;
			}
			_chatMuted = param1.join(",");
			dirty = true;
		}
	}
}
