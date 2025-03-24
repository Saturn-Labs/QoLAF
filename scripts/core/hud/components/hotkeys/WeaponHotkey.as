package core.hud.components.hotkeys {
	import starling.textures.Texture;
	
	public class WeaponHotkey extends AbilityHotkey {
		public var key:int;
		
		private var tex:Texture;
		
		private var inactiveTex:Texture;
		
		private var _active:Boolean;
		
		public function WeaponHotkey(callback:Function, tex:Texture, it:Texture, hotkey:int = 0) {
			key = hotkey;
			this.tex = tex;
			this.inactiveTex = it;
			super(callback,this.tex,it,tex,hotkey.toString());
		}
		
		override public function cooldownFinished() : void {
			if(_active) {
				showAsActive();
			} else {
				showAsInactive();
			}
		}
		
		public function set active(value:Boolean) : void {
			_active = value;
			if(value) {
				enabled = true;
				showAsActive();
			} else {
				if(cooldownEndTime > g.time) {
					return;
				}
				showAsInactive();
			}
		}
		
		private function showAsActive() : void {
			layer.texture = tex;
			sourceHover = tex;
			source = tex;
		}
		
		private function showAsInactive() : void {
			layer.texture = inactiveTex;
			sourceHover = inactiveTex;
			source = inactiveTex;
		}
	}
}

