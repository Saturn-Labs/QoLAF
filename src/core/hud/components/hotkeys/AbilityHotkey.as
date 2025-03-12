package core.hud.components.hotkeys
{
	import core.hud.components.ImageButton;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class AbilityHotkey extends ImageButton
	{
		private var _cooldownTime:int = 1000;
		protected var cooldownCounter:int = 0;
		private var cooldownOverlay:Sprite;
		
		public var obj:Object;
		
		private var hotkeySymbol:Image;
		
		private const MIN_COOLDOWN:int = 200;
		private var quad:Quad;
		
		public function AbilityHotkey(param1:Function, param2:Texture, param3:Texture, param4:Texture = null, param5:String = null)
		{
			quad = new Quad(10, 10);
			super(param1, param2, param2, param4);
			cooldownOverlay = new Sprite();
			cooldownOverlay.addChild(new Image(param3));
			var _loc6_:ITextureManager = TextureLocator.getService();
			hotkeySymbol = new Image(_loc6_.getTextureGUIByTextureName("hotkey" + param5));
			hotkeySymbol.scaleX = hotkeySymbol.scaleY = 0.75;
			hotkeySymbol.x = 40 - hotkeySymbol.width - 2;
			hotkeySymbol.y = 2;
			addChild(hotkeySymbol);
		}
		
		public function update():void
		{
			if (_cooldownTime < 200)
			{
				return;
			}
			if (cooldownCounter >= 0)
			{
				cooldownCounter -= 33;
			}
			else
			{
				cooldownCounter = 0;
			}
			if (cooldownCounter == 0 && !_enabled)
			{
				cooldownFinished();
				removeChild(cooldownOverlay);
				enabled = true;
			}
			draw();
		}
		
		public function cooldownFinished():void
		{
		}
		
		public function initiateCooldown():void
		{
			if (_cooldownTime < 200)
			{
				return;
			}
			if (cooldownCounter > 0)
			{
				return;
			}
			enabled = false;
			cooldownCounter = _cooldownTime;
			addChild(cooldownOverlay);
		}
		
		private function draw():void
		{
			var _loc2_:Number = NaN;
			var _loc1_:Number = 0;
			if (cooldownCounter > 0)
			{
				_loc1_ = cooldownCounter / _cooldownTime;
				_loc2_ = source.width * _loc1_;
				quad.width = _loc2_;
				quad.height = source.height;
				cooldownOverlay.mask = quad;
			}
		}
		
		public function set cooldownTime(param1:int):void
		{
			_cooldownTime = param1;
		}
		
		override protected function onClick(param1:TouchEvent):void
		{
			var _loc2_:ISound = SoundLocator.getService();
			_loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
			super.onClick(param1);
		}
	}
}
