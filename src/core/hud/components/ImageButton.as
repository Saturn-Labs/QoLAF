package core.hud.components
{
	import starling.events.TouchEvent;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	
	public class ImageButton extends InteractiveImage
	{
		private var callback:Function;
		
		protected var disabledSource:Texture;
		
		protected var toggleSource:Texture;
		
		public function ImageButton(param1:Function, param2:Texture = null, param3:Texture = null, param4:Texture = null, param5:Texture = null, param6:String = null, param7:Boolean = false)
		{
			disabledSource = param4;
			toggleSource = param5;
			super(param2, param3, param6, param7);
			captionPosition = Position.INNER_RIGHT;
			this.callback = param1;
		}
		
		override public function set texture(param1:Texture):void
		{
			if (disabledSource == null)
			{
				disabledSource = param1;
			}
			if (toggleSource == null)
			{
				toggleSource = param1;
			}
			super.texture = param1;
		}
		
		public function set disabledBitmapData(param1:Texture):void
		{
			disabledSource = param1;
		}
		
		override public function set enabled(param1:Boolean):void
		{
			var _loc2_:ColorMatrixFilter = null;
			if (disabledSource == null)
			{
				disabledSource = source;
			}
			if (!_enabled && param1)
			{
				useHandCursor = true;
				if (layer.filter)
				{
					layer.filter.dispose();
					layer.filter = null;
				}
				layer.texture = source;
			}
			else if (_enabled && !param1)
			{
				useHandCursor = false;
				if (disabledSource == source)
				{
					_loc2_ = new ColorMatrixFilter();
					_loc2_.adjustSaturation(-1);
					layer.filter = _loc2_;
				}
				layer.texture = disabledSource;
			}
			super.enabled = param1;
		}
		
		override protected function onClick(param1:TouchEvent):void
		{
			layer.texture = toggleSource;
			var _loc2_:Texture = source;
			source = toggleSource;
			toggleSource = _loc2_;
			callback(this);
		}
	}
}
