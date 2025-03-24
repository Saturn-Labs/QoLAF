package core.hud.components {
	import starling.events.TouchEvent;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	
	public class ImageButton extends InteractiveImage {
		private var callback:Function;
		
		protected var disabledSource:Texture;
		
		protected var toggleSource:Texture;
		
		public function ImageButton(callback:Function, bd:Texture = null, hoverBd:Texture = null, disabledBd:Texture = null, toggleBd:Texture = null, caption:String = null, alwaysShowCaption:Boolean = false) {
			disabledSource = disabledBd;
			toggleSource = toggleBd;
			super(bd,hoverBd,caption,alwaysShowCaption);
			captionPosition = Position.INNER_RIGHT;
			this.callback = callback;
		}
		
		override public function set texture(bd:Texture) : void {
			if(disabledSource == null) {
				disabledSource = bd;
			}
			if(toggleSource == null) {
				toggleSource = bd;
			}
			super.texture = bd;
		}
		
		public function set disabledBitmapData(bd:Texture) : void {
			disabledSource = bd;
		}
		
		override public function set enabled(value:Boolean) : void {
			var _local2:ColorMatrixFilter = null;
			if(disabledSource == null) {
				disabledSource = source;
			}
			if(!_enabled && value) {
				useHandCursor = true;
				if(layer.filter) {
					layer.filter.dispose();
					layer.filter = null;
				}
				layer.texture = source;
			} else if(_enabled && !value) {
				useHandCursor = false;
				if(disabledSource == source) {
					_local2 = new ColorMatrixFilter();
					_local2.adjustSaturation(-1);
					layer.filter = _local2;
				}
				layer.texture = disabledSource;
			}
			super.enabled = value;
		}
		
		override protected function onClick(e:TouchEvent) : void {
			layer.texture = toggleSource;
			var _local2:Texture = source;
			source = toggleSource;
			toggleSource = _local2;
			callback(this);
		}
	}
}

