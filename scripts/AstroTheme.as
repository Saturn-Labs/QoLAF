package {
	import core.hud.components.InputText;
	import feathers.controls.Button;
	import feathers.controls.IScrollBar;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Scroller;
	import feathers.controls.SimpleScrollBar;
	import feathers.controls.TabBar;
	import feathers.controls.TextInput;
	import feathers.controls.ToggleButton;
	import feathers.controls.renderers.BaseDefaultItemRenderer;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.skins.ImageSkin;
	import feathers.themes.AeonDesktopTheme;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class AstroTheme extends AeonDesktopTheme {
		protected static var chatTabTextFormat:TextFormat = new TextFormat("DAIDRR",12,0xffffff);
		
		protected var scrollBarThumbSkinTextures:Texture;
		
		private const inputFormat:TextFormat = new TextFormat("Verdana",12,0xffffff);
		
		private const toolTipFormat:TextFormat = new TextFormat("Verdana",11,0xffaa44);
		
		private const chatFormat:TextFormat = new TextFormat("Verdana",11,0xffffff);
		
		private const shopListFormat:TextFormat = new TextFormat("DAIDRR",14,16689475);
		
		private const artifactSetupDefaultFormat:TextFormat = new TextFormat("DAIDRR",10,0xb0b0b0);
		
		private const artifactSetupSelectedFormat:TextFormat = new TextFormat("DAIDRR",10,0xffffff);
		
		public function AstroTheme() {
			super();
			Starling.current.stage.color = 0;
			Starling.current.nativeStage.color = 0;
		}
		
		protected static function simpleScrollBarFactory() : IScrollBar {
			return new SimpleScrollBar();
		}
		
		override protected function initializeStage() : void {
			super.initializeStage();
		}
		
		override protected function initializeTextures() : void {
			super.initializeTextures();
			var _local2:ITextureManager = TextureLocator.getService();
			var _local1:TextureAtlas = _local2.getTextureAtlas("texture_gui1_test.png");
			scrollBarThumbSkinTextures = _local1.getTexture("simple-scroll-bar-thumb-skin");
		}
		
		override protected function initializeStyleProviders() : void {
			super.initializeStyleProviders();
			this.getStyleProviderForClass(InputText).defaultStyleFunction = inputTextInitializer;
			this.getStyleProviderForClass(TextInput).setFunctionForStyleName("chat",chatInput);
			this.getStyleProviderForClass(Label).setFunctionForStyleName("tooltip",labelTooltip);
			this.getStyleProviderForClass(Label).setFunctionForStyleName("chat",labelChat);
			this.getStyleProviderForClass(List).setFunctionForStyleName("shop",shopList);
			this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName("shop",shopItemRendererInitializer);
			this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName("artifact_setup",artifactSetupButton);
			this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName("chat_tab",chatTab);
			this.getStyleProviderForClass(TabBar).setFunctionForStyleName("chat_tabs",chatTabs);
		}
		
		override protected function setScrollerStyles(scroller:Scroller) : void {
			super.setScrollerStyles(scroller);
			scroller.verticalScrollBarFactory = simpleScrollBarFactory;
			scroller.horizontalScrollPolicy = "off";
			scroller.interactionMode = "mouse";
			scroller.scrollBarDisplayMode = "fixed";
			scroller.verticalScrollStep = 30;
		}
		
		override protected function setVerticalSimpleScrollBarThumbStyles(thumb:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.scrollBarThumbSkinTextures);
			_local2.scale9Grid = new Rectangle(4,4,4,4);
			_local2.scale = 0.5;
			thumb.defaultSkin = _local2;
			thumb.horizontalAlign = "left";
			thumb.paddingLeft = this.smallGutterSize;
			thumb.minTouchWidth = thumb.minTouchHeight = 12;
			thumb.hasLabelTextRenderer = false;
			thumb.useHandCursor = true;
		}
		
		protected function inputTextInitializer(input:InputText) : void {
			input.textEditorProperties.textFormat = inputFormat;
			input.textEditorProperties.wordWrap = true;
		}
		
		protected function labelTooltip(label:Label) : void {
			label.textRendererFactory = textRendererFactory;
			toolTipFormat.leading = 6;
			label.textRendererProperties.textFormat = toolTipFormat;
			label.textRendererProperties.wordWrap = true;
			label.textRendererProperties.isHTML = true;
		}
		
		protected function labelChat(label:Label) : void {
			label.textRendererFactory = textRendererFactory;
			label.textRendererProperties.textFormat = chatFormat;
			label.textRendererProperties.wordWrap = true;
			label.textRendererProperties.isHTML = true;
			label.textRendererProperties.alpha = 0.7;
			label.touchable = false;
		}
		
		private function shopList(list:List) : void {
			super.setListStyles(list);
			list.hasElasticEdges = false;
			list.customItemRendererStyleName = "shop";
			list.backgroundSkin = null;
		}
		
		protected function shopItemRendererInitializer(renderer:BaseDefaultItemRenderer) : void {
			var _local2:ImageSkin = new ImageSkin();
			_local2.defaultColor = 0;
			_local2.selectedColor = 1717572;
			_local2.setColorForState("hover",793121);
			_local2.setColorForState("down",793121);
			renderer.defaultSkin = _local2;
			renderer.horizontalAlign = "left";
			renderer.verticalAlign = "middle";
			renderer.iconPosition = "left";
			renderer.labelFactory = textRendererFactory;
			renderer.defaultLabelProperties.textFormat = shopListFormat;
			renderer.defaultLabelProperties.embedFonts = true;
			renderer.paddingLeft = renderer.paddingRight = 10;
			renderer.minWidth = 88;
			renderer.height = 56;
			renderer.accessoryGap = Infinity;
			renderer.accessoryPosition = "right";
			renderer.accessoryLoaderFactory = this.shopImageLoaderFactory;
			renderer.iconLoaderFactory = this.shopImageLoaderFactory;
		}
		
		protected function shopImageLoaderFactory() : ImageLoader {
			return new ImageLoader();
		}
		
		protected function artifactSetupButton(button:ToggleButton) : void {
			var _local3:ITextureManager = TextureLocator.getService();
			var _local2:ImageSkin = new ImageSkin();
			_local2.defaultTexture = _local3.getTextureGUIByTextureName("setup_button");
			_local2.selectedTexture = _local3.getTextureGUIByTextureName("active_setup_button");
			_local2.setTextureForState("down",_local3.getTextureGUIByTextureName("active_setup_button"));
			_local2.scale9Grid = new Rectangle(1,1,12,17);
			button.defaultSkin = _local2;
			button.isToggle = true;
			button.labelFactory = textRendererFactory;
			button.defaultLabelProperties.textFormat = artifactSetupDefaultFormat;
			button.defaultLabelProperties.embedFonts = true;
			button.defaultSelectedLabelProperties.textFormat = artifactSetupSelectedFormat;
			button.defaultSelectedLabelProperties.embedFonts = true;
			button.paddingTop = button.paddingBottom = 5;
			button.paddingLeft = button.paddingRight = 8;
			button.gap = 0;
		}
		
		protected function chatTabs(tabBar:TabBar) : void {
			tabBar.distributeTabSizes = false;
			tabBar.horizontalAlign = "left";
			tabBar.direction = "horizontal";
			tabBar.gap = 0;
			tabBar.customTabStyleName = "chat_tab";
			tabBar.height = 24;
		}
		
		protected function chatTab(tab:ToggleButton) : void {
			var _local2:ImageSkin = new ImageSkin();
			_local2.defaultColor = 0;
			_local2.selectedColor = 4212299;
			_local2.setColorForState("hover",3356216);
			tab.defaultSkin = _local2;
			tab.isToggle = true;
			tab.labelFactory = textRendererFactory;
			tab.defaultLabelProperties.textFormat = chatTabTextFormat;
			tab.defaultLabelProperties.embedFonts = true;
			tab.paddingTop = tab.paddingBottom = 5;
			tab.paddingLeft = tab.paddingRight = 10;
			tab.gap = 0;
			tab.useHandCursor = true;
		}
		
		protected function chatInput(input:TextInput) : void {
			input.maxChars = 150;
			input.paddingLeft = 8;
			input.paddingTop = 3;
			input.textEditorProperties.textFormat = new TextFormat("Verdana",12,0xffffff);
			input.textEditorProperties.wordWrap = false;
			input.textEditorProperties.multiline = false;
			var _local2:ImageSkin = new ImageSkin();
			_local2.defaultColor = 3685954;
			input.backgroundSkin = _local2;
		}
	}
}

