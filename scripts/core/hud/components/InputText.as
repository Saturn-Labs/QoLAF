package core.hud.components {
	import feathers.controls.TextInput;
	import feathers.controls.text.TextFieldTextEditor;
	import feathers.skins.IStyleProvider;
	import feathers.skins.ImageSkin;
	import flash.text.TextFormat;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class InputText extends TextInput {
		public static var globalStyleProvider:IStyleProvider;
		
		private static var TextInputBackground:Class = text_input_png$a3aa02bc4be5076b98887fbc5f3486682078710351;
		
		private static var textFormat:TextFormat = new TextFormat("Verdana",12,0xffffff);
		
		public function InputText(x:int, y:int, w:int, h:int) {
			super();
			this.x = x;
			this.y = y;
			width = w;
			height = h;
			if(!backgroundSkin) {
				backgroundSkin = new Image(Texture.fromEmbeddedAsset(InputText.TextInputBackground,false));
			}
			this.textEditorFactory = getTextEditor;
			this.textEditorProperties.textFormat = InputText.textFormat;
			this.textEditorProperties.wordWrap = true;
			paddingLeft = 5;
			paddingTop = 2;
			paddingRight = 5;
		}
		
		private function getTextEditor() : TextFieldTextEditor {
			return new TextFieldTextEditor();
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			return InputText.globalStyleProvider;
		}
		
		public function setDesktopLogin() : void {
			var _local1:ImageSkin = new ImageSkin();
			_local1.defaultColor = 908765;
			_local1.selectedColor = 4212299;
			this.backgroundSkin = _local1;
			this.textEditorProperties.textFormat = new TextFormat("Verdana",18,0xffffff);
			this.textEditorProperties.wordWrap = true;
		}
	}
}

