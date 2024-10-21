package
{
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
	
	public class AstroTheme extends AeonDesktopTheme
	{
		protected static var chatTabTextFormat:TextFormat = new TextFormat("DAIDRR", 12, 16777215);
		
		protected var scrollBarThumbSkinTextures:Texture;
		protected var inputFormat:TextFormat;
		protected var toolTipFormat:TextFormat;
		protected var chatFormat:TextFormat;
		protected var shopListFormat:TextFormat;
		protected var artifactSetupDefaultFormat:TextFormat;
		protected var artifactSetupSelectedFormat:TextFormat;
		
		public function AstroTheme()
		{
			inputFormat = new TextFormat("Verdana", 12, 16777215);
			toolTipFormat = new TextFormat("Verdana", 11, 16755268);
			chatFormat = new TextFormat("Verdana", 11, 16777215);
			shopListFormat = new TextFormat("DAIDRR", 14, 16689475);
			artifactSetupDefaultFormat = new TextFormat("DAIDRR", 10, 11579568);
			artifactSetupSelectedFormat = new TextFormat("DAIDRR", 10, 16777215);
			super();
			Starling.current.stage.color = 0;
			Starling.current.nativeStage.color = 0;
		}
		
		protected static function simpleScrollBarFactory():IScrollBar
		{
			return new SimpleScrollBar();
		}
		
		override protected function initializeStage():void
		{
			super.initializeStage();
		}
		
		override protected function initializeTextures():void
		{
			super.initializeTextures();
			var _loc1_:ITextureManager = TextureLocator.getService();
			var _loc2_:TextureAtlas = _loc1_.getTextureAtlas("texture_gui1_test.png");
			scrollBarThumbSkinTextures = _loc2_.getTexture("simple-scroll-bar-thumb-skin");
		}
		
		override protected function initializeStyleProviders():void
		{
			super.initializeStyleProviders();
			this.getStyleProviderForClass(InputText).defaultStyleFunction = inputTextInitializer;
			this.getStyleProviderForClass(TextInput).setFunctionForStyleName("chat", chatInput);
			this.getStyleProviderForClass(Label).setFunctionForStyleName("tooltip", labelTooltip);
			this.getStyleProviderForClass(Label).setFunctionForStyleName("chat", labelChat);
			this.getStyleProviderForClass(List).setFunctionForStyleName("shop", shopList);
			this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName("shop", shopItemRendererInitializer);
			this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName("artifact_setup", artifactSetupButton);
			this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName("chat_tab", chatTab);
			this.getStyleProviderForClass(TabBar).setFunctionForStyleName("chat_tabs", chatTabs);
		}
		
		override protected function setScrollerStyles(param1:Scroller):void
		{
			super.setScrollerStyles(param1);
			param1.verticalScrollBarFactory = simpleScrollBarFactory;
			param1.horizontalScrollPolicy = "off";
			param1.interactionMode = "mouse";
			param1.scrollBarDisplayMode = "fixed";
			param1.verticalScrollStep = 30;
		}
		
		override protected function setVerticalSimpleScrollBarThumbStyles(param1:Button):void
		{
			var _loc2_:ImageSkin = new ImageSkin(this.scrollBarThumbSkinTextures);
			_loc2_.scale9Grid = new Rectangle(4, 4, 4, 4);
			_loc2_.scale = 0.5;
			param1.defaultSkin = _loc2_;
			param1.horizontalAlign = "left";
			param1.paddingLeft = this.smallGutterSize;
			param1.minTouchWidth = param1.minTouchHeight = 12;
			param1.hasLabelTextRenderer = false;
			param1.useHandCursor = true;
		}
		
		protected function inputTextInitializer(param1:InputText):void
		{
			param1.textEditorProperties.textFormat = inputFormat;
			param1.textEditorProperties.wordWrap = true;
		}
		
		protected function labelTooltip(param1:Label):void
		{
			param1.textRendererFactory = textRendererFactory;
			toolTipFormat.leading = 6;
			param1.textRendererProperties.textFormat = toolTipFormat;
			param1.textRendererProperties.wordWrap = true;
			param1.textRendererProperties.isHTML = true;
		}
		
		protected function labelChat(param1:Label):void
		{
			param1.textRendererFactory = textRendererFactory;
			param1.textRendererProperties.textFormat = chatFormat;
			param1.textRendererProperties.wordWrap = true;
			param1.textRendererProperties.isHTML = true;
			param1.textRendererProperties.alpha = 0.7;
			param1.touchable = false;
		}
		
		private function shopList(param1:List):void
		{
			super.setListStyles(param1);
			param1.hasElasticEdges = false;
			param1.customItemRendererStyleName = "shop";
			param1.backgroundSkin = null;
		}
		
		protected function shopItemRendererInitializer(param1:BaseDefaultItemRenderer):void
		{
			var _loc2_:ImageSkin = new ImageSkin();
			_loc2_.defaultColor = 0;
			_loc2_.selectedColor = 1717572;
			_loc2_.setColorForState("hover", 793121);
			_loc2_.setColorForState("down", 793121);
			param1.defaultSkin = _loc2_;
			param1.horizontalAlign = "left";
			param1.verticalAlign = "middle";
			param1.iconPosition = "left";
			param1.labelFactory = textRendererFactory;
			param1.defaultLabelProperties.textFormat = shopListFormat;
			param1.defaultLabelProperties.embedFonts = true;
			param1.paddingLeft = param1.paddingRight = 10;
			param1.minWidth = 88;
			param1.height = 56;
			param1.accessoryGap = Infinity;
			param1.accessoryPosition = "right";
			param1.accessoryLoaderFactory = this.shopImageLoaderFactory;
			param1.iconLoaderFactory = this.shopImageLoaderFactory;
		}
		
		protected function shopImageLoaderFactory():ImageLoader
		{
			return new ImageLoader();
		}
		
		protected function artifactSetupButton(param1:ToggleButton):void
		{
			var _loc2_:ITextureManager = TextureLocator.getService();
			var _loc3_:ImageSkin = new ImageSkin();
			_loc3_.defaultTexture = _loc2_.getTextureGUIByTextureName("setup_button");
			_loc3_.selectedTexture = _loc2_.getTextureGUIByTextureName("active_setup_button");
			_loc3_.setTextureForState("down", _loc2_.getTextureGUIByTextureName("active_setup_button"));
			_loc3_.scale9Grid = new Rectangle(1, 1, 12, 17);
			param1.defaultSkin = _loc3_;
			param1.isToggle = true;
			param1.labelFactory = textRendererFactory;
			param1.defaultLabelProperties.textFormat = artifactSetupDefaultFormat;
			param1.defaultLabelProperties.embedFonts = true;
			param1.defaultSelectedLabelProperties.textFormat = artifactSetupSelectedFormat;
			param1.defaultSelectedLabelProperties.embedFonts = true;
			param1.paddingTop = param1.paddingBottom = 5;
			param1.paddingLeft = param1.paddingRight = 8;
			param1.gap = 0;
		}
		
		protected function chatTabs(param1:TabBar):void
		{
			param1.distributeTabSizes = false;
			param1.horizontalAlign = "left";
			param1.direction = "horizontal";
			param1.gap = 0;
			param1.customTabStyleName = "chat_tab";
			param1.height = 24;
		}
		
		protected function chatTab(param1:ToggleButton):void
		{
			var _loc2_:ImageSkin = new ImageSkin();
			_loc2_.defaultColor = 0;
			_loc2_.selectedColor = 4212299;
			_loc2_.setColorForState("hover", 3356216);
			param1.defaultSkin = _loc2_;
			param1.isToggle = true;
			param1.labelFactory = textRendererFactory;
			param1.defaultLabelProperties.textFormat = chatTabTextFormat;
			param1.defaultLabelProperties.embedFonts = true;
			param1.paddingTop = param1.paddingBottom = 5;
			param1.paddingLeft = param1.paddingRight = 10;
			param1.gap = 0;
			param1.useHandCursor = true;
		}
		
		protected function chatInput(param1:TextInput):void
		{
			param1.maxChars = 150;
			param1.paddingLeft = 8;
			param1.paddingTop = 3;
			param1.textEditorProperties.textFormat = new TextFormat("Verdana", 12, 16777215);
			param1.textEditorProperties.wordWrap = false;
			param1.textEditorProperties.multiline = false;
			var _loc2_:ImageSkin = new ImageSkin();
			_loc2_.defaultColor = 3685954;
			param1.backgroundSkin = _loc2_;
		}
	}
}
