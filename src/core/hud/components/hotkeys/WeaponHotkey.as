package core.hud.components.hotkeys
{
	import starling.textures.Texture;
	
	public class WeaponHotkey extends AbilityHotkey
	{
		public var key:int;
		
		private var tex:Texture;
		
		private var inactiveTex:Texture;
		
		private var _active:Boolean;
		
		public function WeaponHotkey(param1:Function, param2:Texture, param3:Texture, param4:int = 0)
		{
			key = param4;
			this.tex = param2;
			this.inactiveTex = param3;
			super(param1, this.tex, param3, param2, param4.toString());
		}
		
		override public function cooldownFinished():void
		{
			if (_active)
			{
				showAsActive();
			}
			else
			{
				showAsInactive();
			}
		}
		
		public function set active(param1:Boolean):void
		{
			_active = param1;
			if (param1)
			{
				enabled = true;
				showAsActive();
			}
			else
			{
				if (cooldownCounter > 0)
				{
					return;
				}
				showAsInactive();
			}
		}
		
		private function showAsActive():void
		{
			layer.texture = tex;
			sourceHover = tex;
			source = tex;
		}
		
		private function showAsInactive():void
		{
			layer.texture = inactiveTex;
			sourceHover = inactiveTex;
			source = inactiveTex;
		}
	}
}
