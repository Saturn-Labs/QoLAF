package qolaf.ui.elements
{
	import feathers.controls.LayoutGroup;
	import starling.textures.Texture;
	import qolaf.data.ModifierInfo;
	import qolaf.modifiers.Modifier;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;

	/**
	 * @author rydev
	 */
	public class ModifierIcon extends LayoutGroup
	{
		private var _modifier:Modifier;
		private var _icon:Image;
		private var _textureManager:ITextureManager;
		private var _defaultIcon:Texture;
		public function ModifierIcon(modifier:Modifier, width:Number = 21.2, height:Number = 21.2)
		{
			_textureManager = TextureLocator.getService();
			_defaultIcon = ModifierInfo.getIcon(_textureManager, "ti_astro_lance_levels");
			_icon = new Image(_defaultIcon);
			_icon.touchable = true;
			addChild(_icon);

			this.width = width;
			this.height = height;
			this.modifier = modifier;
		}

		override public function get width():Number
		{
			return _icon.width;
		}

		override public function get height():Number
		{
			return _icon.height;
		}

		override public function set width(w:Number):void
		{
			_icon.width = w;
			readjustLayout();
		}

		override public function set height(h:Number):void
		{
			_icon.height = h;
			readjustLayout();
		}

		public function get modifier():Modifier
		{
			return _modifier;
		}

		override public function addEventListener(type:String, listener:Function):void
		{
			if (_icon != null)
				_icon.addEventListener(type, listener);
		}

		override public function removeEventListener(type:String, listener:Function):void
		{
			if (_icon != null)
				_icon.removeEventListener(type, listener);
		}

		override public function removeEventListeners(type:String = null):void
		{
			if (_icon != null)
				_icon.removeEventListeners(type);
		}

		public function set modifier(modifier:Modifier):void
		{
			_modifier = modifier;
			if (modifier == null)
			{
				_icon.texture = _defaultIcon;
			}
			else
			{
				var info:Object = ModifierInfo.getModifier(modifier.id);
				_icon.texture = ModifierInfo.getIcon(_textureManager, info.icon);
			}
		}
	}
}