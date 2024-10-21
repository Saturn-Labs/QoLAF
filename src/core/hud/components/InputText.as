package core.hud.components
{
	import feathers.controls.TextInput;
	import feathers.controls.text.TextFieldTextEditor;
	import feathers.skins.IStyleProvider;
	import feathers.skins.ImageSkin;
	import flash.text.TextFormat;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class InputText extends TextInput
	{
		public static var globalStyleProvider:IStyleProvider;
		
		private static var TextInputBackground:Class = TextInputBitmap;
		
		private static var textFormat:TextFormat = new TextFormat("Verdana", 12, 16777215);
		
		public function InputText(param1:int, param2:int, param3:int, param4:int)
		{
			super();
			this.x = param1;
			this.y = param2;
			width = param3;
			height = param4;
			if (!backgroundSkin)
			{
				backgroundSkin = new Image(Texture.fromEmbeddedAsset(InputText.TextInputBackground, false));
			}
			this.textEditorFactory = getTextEditor;
			this.textEditorProperties.textFormat = InputText.textFormat;
			this.textEditorProperties.wordWrap = true;
			paddingLeft = 5;
			paddingTop = 2;
			paddingRight = 5;
		}
		
		private function getTextEditor():TextFieldTextEditor
		{
			return new TextFieldTextEditor();
		}
		
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return InputText.globalStyleProvider;
		}
		
		public function setDesktopLogin():void
		{
			var _loc1_:ImageSkin = new ImageSkin();
			_loc1_.defaultColor = 908765;
			_loc1_.selectedColor = 4212299;
			this.backgroundSkin = _loc1_;
			this.textEditorProperties.textFormat = new TextFormat("Verdana", 18, 16777215);
			this.textEditorProperties.wordWrap = true;
		}
	}
}
