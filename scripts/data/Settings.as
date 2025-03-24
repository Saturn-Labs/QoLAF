package data {
	import core.scene.Game;
	import core.scene.SceneBase;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	
	public class Settings {
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
		
		public function Settings() {
			super();
			soundManager = SoundLocator.getService();
			keybinds = new KeyBinds();
		}
		
		public function init(m:Message, i:int) : int {
			_musicVolume = m.getNumber(i++);
			_effectVolume = m.getNumber(i++);
			_showHud = m.getBoolean(i++);
			_showLatency = m.getBoolean(i++);
			_showEffects = m.getBoolean(i++);
			_showBackground = m.getBoolean(i++);
			_mouseAim = m.getBoolean(i++);
			_keyboardAim = m.getBoolean(i++);
			_rotationSpeed = m.getNumber(i++);
			_mouseFire = m.getBoolean(i++);
			_iWantAllTimedMissions = m.getBoolean(i++);
			_fireWithHotkeys = m.getBoolean(i++);
			_quality = m.getInt(i++);
			_chatMuted = m.getString(i++);
			if(m.getBoolean(i++)) {
				keybinds.init(m,i);
				i += 2 * 27;
			} else {
				keybinds.init();
			}
			return i;
		}
		
		public function setPlayerValues(g:Game) : void {
			g.parallaxManager.visible = showBackground;
			RymdenRunt.s.showStats = showLatency;
			g.toggleHighGraphics(showEffects);
		}
		
		public function save() : void {
			if(!dirty && !keybinds.dirty) {
				return;
			}
			var _local1:Message = sb.createMessage("settings",_musicVolume,_effectVolume,_showHud,_showLatency,_showEffects,_showBackground,_mouseAim,_keyboardAim,_rotationSpeed,_mouseFire,_iWantAllTimedMissions,_fireWithHotkeys,_quality,_chatMuted);
			keybinds.populateMessage(_local1);
			sb.sendMessage(_local1);
		}
		
		public function get musicVolume() : Number {
			return _musicVolume;
		}
		
		public function set musicVolume(value:Number) : void {
			soundManager.musicVolume = value;
			_musicVolume = value;
			dirty = true;
		}
		
		public function get effectVolume() : Number {
			return _effectVolume;
		}
		
		public function set effectVolume(value:Number) : void {
			soundManager.effectVolume = value;
			_effectVolume = value;
			dirty = true;
		}
		
		public function get showHud() : Boolean {
			return _showHud;
		}
		
		public function set showHud(value:Boolean) : void {
			_showHud = value;
			dirty = true;
		}
		
		public function get fireWithHotkeys() : Boolean {
			return _fireWithHotkeys;
		}
		
		public function set fireWithHotkeys(value:Boolean) : void {
			_fireWithHotkeys = value;
			dirty = true;
		}
		
		public function get showLatency() : Boolean {
			return _showLatency;
		}
		
		public function set showLatency(value:Boolean) : void {
			_showLatency = value;
			RymdenRunt.s.showStatsAt("left","center");
			RymdenRunt.s.showStats = value;
			dirty = true;
		}
		
		public function get showEffects() : Boolean {
			return _showEffects;
		}
		
		public function set showEffects(value:Boolean) : void {
			_showEffects = value;
			dirty = true;
		}
		
		public function get showBackground() : Boolean {
			return _showBackground;
		}
		
		public function set showBackground(value:Boolean) : void {
			_showBackground = value;
			dirty = true;
		}
		
		public function get mouseAim() : Boolean {
			return _mouseAim;
		}
		
		public function set mouseAim(value:Boolean) : void {
			_mouseAim = value;
			dirty = true;
		}
		
		public function get keyboardAim() : Boolean {
			return _keyboardAim;
		}
		
		public function set keyboardAim(value:Boolean) : void {
			_keyboardAim = value;
			dirty = true;
		}
		
		public function get rotationSpeed() : Number {
			return _rotationSpeed;
		}
		
		public function set rotationSpeed(value:Number) : void {
			_rotationSpeed = value;
			dirty = true;
		}
		
		public function get mouseFire() : Boolean {
			return _mouseFire;
		}
		
		public function set mouseFire(value:Boolean) : void {
			_mouseFire = value;
			dirty = true;
		}
		
		public function get quality() : int {
			return _quality;
		}
		
		public function set quality(value:int) : void {
			_quality = value;
			dirty = true;
		}
		
		public function get iWantAllTimedMissions() : Boolean {
			return _iWantAllTimedMissions;
		}
		
		public function set iWantAllTimedMissions(value:Boolean) : void {
			_iWantAllTimedMissions = value;
			dirty = true;
		}
		
		public function get chatMuted() : Array {
			if(_chatMuted == "") {
				return [];
			}
			return _chatMuted.split(",");
		}
		
		public function set chatMuted(value:Array) : void {
			if(value.length == 0) {
				_chatMuted = "";
				return;
			}
			_chatMuted = value.join(",");
			dirty = true;
		}
	}
}

