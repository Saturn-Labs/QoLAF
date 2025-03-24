package feathers.themes {
	import feathers.controls.Alert;
	import feathers.controls.AutoComplete;
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Callout;
	import feathers.controls.Check;
	import feathers.controls.Drawers;
	import feathers.controls.GroupedList;
	import feathers.controls.Header;
	import feathers.controls.IScrollBar;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.NumericStepper;
	import feathers.controls.PageIndicator;
	import feathers.controls.Panel;
	import feathers.controls.PanelScreen;
	import feathers.controls.PickerList;
	import feathers.controls.ProgressBar;
	import feathers.controls.Radio;
	import feathers.controls.ScrollBar;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ScrollScreen;
	import feathers.controls.ScrollText;
	import feathers.controls.Scroller;
	import feathers.controls.SimpleScrollBar;
	import feathers.controls.Slider;
	import feathers.controls.SpinnerList;
	import feathers.controls.TabBar;
	import feathers.controls.TextArea;
	import feathers.controls.TextCallout;
	import feathers.controls.TextInput;
	import feathers.controls.ToggleButton;
	import feathers.controls.ToggleSwitch;
	import feathers.controls.popups.DropDownPopUpContentManager;
	import feathers.controls.renderers.BaseDefaultItemRenderer;
	import feathers.controls.renderers.DefaultGroupedListHeaderOrFooterRenderer;
	import feathers.controls.renderers.DefaultGroupedListItemRenderer;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.text.TextFieldTextEditor;
	import feathers.controls.text.TextFieldTextEditorViewPort;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.FocusManager;
	import feathers.core.ITextEditor;
	import feathers.core.ITextRenderer;
	import feathers.core.PopUpManager;
	import feathers.core.ToolTipManager;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.media.FullScreenToggleButton;
	import feathers.media.MuteToggleButton;
	import feathers.media.PlayPauseToggleButton;
	import feathers.media.SeekSlider;
	import feathers.media.VolumeSlider;
	import feathers.skins.ImageSkin;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Stage;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class BaseAeonDesktopTheme extends StyleNameFunctionTheme {
		protected static const THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_INCREMENT_BUTTON:String = "aeon-horizontal-scroll-bar-increment-button";
		
		protected static const THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_DECREMENT_BUTTON:String = "aeon-horizontal-scroll-bar-decrement-button";
		
		protected static const THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_THUMB:String = "aeon-horizontal-scroll-bar-thumb";
		
		protected static const THEME_STYLE_NAME_HORIZONTAL_SCROLL_BAR_MINIMUM_TRACK:String = "aeon-horizontal-scroll-bar-minimum-track";
		
		protected static const THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_INCREMENT_BUTTON:String = "aeon-vertical-scroll-bar-increment-button";
		
		protected static const THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_DECREMENT_BUTTON:String = "aeon-vertical-scroll-bar-decrement-button";
		
		protected static const THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_THUMB:String = "aeon-vertical-scroll-bar-thumb";
		
		protected static const THEME_STYLE_NAME_VERTICAL_SCROLL_BAR_MINIMUM_TRACK:String = "aeon-vertical-scroll-bar-minimum-track";
		
		protected static const THEME_STYLE_NAME_HORIZONTAL_SIMPLE_SCROLL_BAR_THUMB:String = "aeon-horizontal-simple-scroll-bar-thumb";
		
		protected static const THEME_STYLE_NAME_VERTICAL_SIMPLE_SCROLL_BAR_THUMB:String = "aeon-vertical-simple-scroll-bar-thumb";
		
		protected static const THEME_STYLE_NAME_HORIZONTAL_SLIDER_THUMB:String = "aeon-horizontal-slider-thumb";
		
		protected static const THEME_STYLE_NAME_HORIZONTAL_SLIDER_MINIMUM_TRACK:String = "aeon-horizontal-slider-minimum-track";
		
		protected static const THEME_STYLE_NAME_VERTICAL_SLIDER_THUMB:String = "aeon-vertical-slider-thumb";
		
		protected static const THEME_STYLE_NAME_VERTICAL_SLIDER_MINIMUM_TRACK:String = "aeon-vertical-slider-minimum-track";
		
		protected static const THEME_STYLE_NAME_VERTICAL_VOLUME_SLIDER_MINIMUM_TRACK:String = "aeon-vertical-volume-slider-minimum-track";
		
		protected static const THEME_STYLE_NAME_VERTICAL_VOLUME_SLIDER_MAXIMUM_TRACK:String = "aeon-vertical-volume-slider-maximum-track";
		
		protected static const THEME_STYLE_NAME_HORIZONTAL_VOLUME_SLIDER_MINIMUM_TRACK:String = "aeon-horizontal-volume-slider-minimum-track";
		
		protected static const THEME_STYLE_NAME_HORIZONTAL_VOLUME_SLIDER_MAXIMUM_TRACK:String = "aeon-horizontal-volume-slider-maximum-track";
		
		protected static const THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MINIMUM_TRACK:String = "aeon-pop-up-volume-slider-minimum-track";
		
		protected static const THEME_STYLE_NAME_POP_UP_VOLUME_SLIDER_MAXIMUM_TRACK:String = "aeon-pop-up-volume-slider-maximum-track";
		
		protected static const THEME_STYLE_NAME_DATE_TIME_SPINNER_LIST_ITEM_RENDERER:String = "aeon-date-time-spinner-list-item-renderer";
		
		protected static const THEME_STYLE_NAME_DANGER_TEXT_CALLOUT_TEXT_RENDERER:String = "aeon-danger-text-callout-text-renderer";
		
		protected static const THEME_STYLE_NAME_HEADING_LABEL_TEXT_RENDERER:String = "aeon-heading-label-text-renderer";
		
		protected static const THEME_STYLE_NAME_DETAIL_LABEL_TEXT_RENDERER:String = "aeon-detail-label-text-renderer";
		
		protected static const THEME_STYLE_NAME_TOOL_TIP_LABEL_TEXT_RENDERER:String = "aeon-tool-tip-label-text-renderer";
		
		public static const FONT_NAME:String = "_sans";
		
		protected static const BACKGROUND_COLOR:uint = 8821927;
		
		protected static const MODAL_OVERLAY_COLOR:uint = 14540253;
		
		protected static const MODAL_OVERLAY_ALPHA:Number = 0.5;
		
		protected static const PRIMARY_TEXT_COLOR:uint = 734012;
		
		protected static const DISABLED_TEXT_COLOR:uint = 5990256;
		
		protected static const INVERTED_TEXT_COLOR:uint = 16777215;
		
		protected static const VIDEO_OVERLAY_COLOR:uint = 13230318;
		
		protected static const VIDEO_OVERLAY_ALPHA:Number = 0.25;
		
		protected static const FOCUS_INDICATOR_SCALE_9_GRID:Rectangle = new Rectangle(5,5,2,2);
		
		protected static const TOOL_TIP_SCALE_9_GRID:Rectangle = new Rectangle(5,5,1,1);
		
		protected static const CALLOUT_SCALE_9_GRID:Rectangle = new Rectangle(5,5,1,1);
		
		protected static const BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(5,5,1,12);
		
		protected static const TAB_SCALE_9_GRID:Rectangle = new Rectangle(5,5,1,15);
		
		protected static const STEPPER_INCREMENT_BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(1,9,15,1);
		
		protected static const STEPPER_DECREMENT_BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(1,1,15,1);
		
		protected static const HORIZONTAL_SLIDER_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(3,0,1,4);
		
		protected static const VERTICAL_SLIDER_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(0,3,4,1);
		
		protected static const TEXT_INPUT_SCALE_9_GRID:Rectangle = new Rectangle(2,2,1,1);
		
		protected static const VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID:Rectangle = new Rectangle(2,5,6,42);
		
		protected static const VERTICAL_SCROLL_BAR_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(2,1,11,2);
		
		protected static const VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(2,2,11,10);
		
		protected static const HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID:Rectangle = new Rectangle(5,2,42,6);
		
		protected static const HORIZONTAL_SCROLL_BAR_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(1,2,2,11);
		
		protected static const HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID:Rectangle = new Rectangle(2,2,10,11);
		
		protected static const SIMPLE_BORDER_SCALE_9_GRID:Rectangle = new Rectangle(2,2,2,2);
		
		protected static const PANEL_BORDER_SCALE_9_GRID:Rectangle = new Rectangle(5,5,1,1);
		
		protected static const HEADER_SCALE_9_GRID:Rectangle = new Rectangle(1,1,2,28);
		
		protected static const SEEK_SLIDER_MINIMUM_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(3,0,1,4);
		
		protected static const SEEK_SLIDER_MAXIMUM_TRACK_SCALE_9_GRID:Rectangle = new Rectangle(1,0,1,4);
		
		protected static const ITEM_RENDERER_SKIN_TEXTURE_REGION:Rectangle = new Rectangle(1,1,4,4);
		
		protected static const PROGRESS_BAR_FILL_TEXTURE_REGION:Rectangle = new Rectangle(1,1,4,4);
		
		protected var smallFontSize:int;
		
		protected var regularFontSize:int;
		
		protected var largeFontSize:int;
		
		protected var gridSize:int;
		
		protected var gutterSize:int;
		
		protected var smallGutterSize:int;
		
		protected var extraSmallGutterSize:int;
		
		protected var buttonMinWidth:int;
		
		protected var wideControlSize:int;
		
		protected var controlSize:int;
		
		protected var smallControlSize:int;
		
		protected var borderSize:int;
		
		protected var calloutBackgroundMinSize:int;
		
		protected var calloutArrowOverlapGap:int;
		
		protected var progressBarFillMinSize:int;
		
		protected var popUpSize:int;
		
		protected var popUpVolumeSliderPaddingSize:int;
		
		protected var bottomDropShadowSize:int;
		
		protected var leftAndRightDropShadowSize:int;
		
		protected var atlas:TextureAtlas;
		
		protected var defaultTextFormat:TextFormat;
		
		protected var disabledTextFormat:TextFormat;
		
		protected var headingTextFormat:TextFormat;
		
		protected var headingDisabledTextFormat:TextFormat;
		
		protected var detailTextFormat:TextFormat;
		
		protected var detailDisabledTextFormat:TextFormat;
		
		protected var invertedTextFormat:TextFormat;
		
		protected var focusIndicatorSkinTexture:Texture;
		
		protected var toolTipBackgroundSkinTexture:Texture;
		
		protected var calloutBackgroundSkinTexture:Texture;
		
		protected var calloutTopArrowSkinTexture:Texture;
		
		protected var calloutRightArrowSkinTexture:Texture;
		
		protected var calloutBottomArrowSkinTexture:Texture;
		
		protected var calloutLeftArrowSkinTexture:Texture;
		
		protected var dangerCalloutBackgroundSkinTexture:Texture;
		
		protected var dangerCalloutTopArrowSkinTexture:Texture;
		
		protected var dangerCalloutRightArrowSkinTexture:Texture;
		
		protected var dangerCalloutBottomArrowSkinTexture:Texture;
		
		protected var dangerCalloutLeftArrowSkinTexture:Texture;
		
		protected var buttonUpSkinTexture:Texture;
		
		protected var buttonHoverSkinTexture:Texture;
		
		protected var buttonDownSkinTexture:Texture;
		
		protected var buttonDisabledSkinTexture:Texture;
		
		protected var toggleButtonSelectedUpSkinTexture:Texture;
		
		protected var toggleButtonSelectedHoverSkinTexture:Texture;
		
		protected var toggleButtonSelectedDownSkinTexture:Texture;
		
		protected var toggleButtonSelectedDisabledSkinTexture:Texture;
		
		protected var quietButtonHoverSkinTexture:Texture;
		
		protected var callToActionButtonUpSkinTexture:Texture;
		
		protected var callToActionButtonHoverSkinTexture:Texture;
		
		protected var dangerButtonUpSkinTexture:Texture;
		
		protected var dangerButtonHoverSkinTexture:Texture;
		
		protected var dangerButtonDownSkinTexture:Texture;
		
		protected var backButtonUpIconTexture:Texture;
		
		protected var backButtonDisabledIconTexture:Texture;
		
		protected var forwardButtonUpIconTexture:Texture;
		
		protected var forwardButtonDisabledIconTexture:Texture;
		
		protected var tabUpSkinTexture:Texture;
		
		protected var tabHoverSkinTexture:Texture;
		
		protected var tabDownSkinTexture:Texture;
		
		protected var tabDisabledSkinTexture:Texture;
		
		protected var tabSelectedUpSkinTexture:Texture;
		
		protected var tabSelectedDisabledSkinTexture:Texture;
		
		protected var stepperIncrementButtonUpSkinTexture:Texture;
		
		protected var stepperIncrementButtonHoverSkinTexture:Texture;
		
		protected var stepperIncrementButtonDownSkinTexture:Texture;
		
		protected var stepperIncrementButtonDisabledSkinTexture:Texture;
		
		protected var stepperDecrementButtonUpSkinTexture:Texture;
		
		protected var stepperDecrementButtonHoverSkinTexture:Texture;
		
		protected var stepperDecrementButtonDownSkinTexture:Texture;
		
		protected var stepperDecrementButtonDisabledSkinTexture:Texture;
		
		protected var hSliderThumbUpSkinTexture:Texture;
		
		protected var hSliderThumbHoverSkinTexture:Texture;
		
		protected var hSliderThumbDownSkinTexture:Texture;
		
		protected var hSliderThumbDisabledSkinTexture:Texture;
		
		protected var hSliderTrackEnabledSkinTexture:Texture;
		
		protected var vSliderThumbUpSkinTexture:Texture;
		
		protected var vSliderThumbHoverSkinTexture:Texture;
		
		protected var vSliderThumbDownSkinTexture:Texture;
		
		protected var vSliderThumbDisabledSkinTexture:Texture;
		
		protected var vSliderTrackEnabledSkinTexture:Texture;
		
		protected var itemRendererUpSkinTexture:Texture;
		
		protected var itemRendererHoverSkinTexture:Texture;
		
		protected var itemRendererSelectedUpSkinTexture:Texture;
		
		protected var headerBackgroundSkinTexture:Texture;
		
		protected var groupedListHeaderBackgroundSkinTexture:Texture;
		
		protected var checkUpIconTexture:Texture;
		
		protected var checkHoverIconTexture:Texture;
		
		protected var checkDownIconTexture:Texture;
		
		protected var checkDisabledIconTexture:Texture;
		
		protected var checkSelectedUpIconTexture:Texture;
		
		protected var checkSelectedHoverIconTexture:Texture;
		
		protected var checkSelectedDownIconTexture:Texture;
		
		protected var checkSelectedDisabledIconTexture:Texture;
		
		protected var radioUpIconTexture:Texture;
		
		protected var radioHoverIconTexture:Texture;
		
		protected var radioDownIconTexture:Texture;
		
		protected var radioDisabledIconTexture:Texture;
		
		protected var radioSelectedUpIconTexture:Texture;
		
		protected var radioSelectedHoverIconTexture:Texture;
		
		protected var radioSelectedDownIconTexture:Texture;
		
		protected var radioSelectedDisabledIconTexture:Texture;
		
		protected var pageIndicatorNormalSkinTexture:Texture;
		
		protected var pageIndicatorSelectedSkinTexture:Texture;
		
		protected var pickerListUpIconTexture:Texture;
		
		protected var pickerListHoverIconTexture:Texture;
		
		protected var pickerListDownIconTexture:Texture;
		
		protected var pickerListDisabledIconTexture:Texture;
		
		protected var textInputBackgroundEnabledSkinTexture:Texture;
		
		protected var textInputBackgroundDisabledSkinTexture:Texture;
		
		protected var textInputBackgroundErrorSkinTexture:Texture;
		
		protected var textInputSearchIconTexture:Texture;
		
		protected var textInputSearchIconDisabledTexture:Texture;
		
		protected var vScrollBarThumbUpSkinTexture:Texture;
		
		protected var vScrollBarThumbHoverSkinTexture:Texture;
		
		protected var vScrollBarThumbDownSkinTexture:Texture;
		
		protected var vScrollBarTrackSkinTexture:Texture;
		
		protected var vScrollBarThumbIconTexture:Texture;
		
		protected var vScrollBarStepButtonUpSkinTexture:Texture;
		
		protected var vScrollBarStepButtonHoverSkinTexture:Texture;
		
		protected var vScrollBarStepButtonDownSkinTexture:Texture;
		
		protected var vScrollBarStepButtonDisabledSkinTexture:Texture;
		
		protected var vScrollBarDecrementButtonIconTexture:Texture;
		
		protected var vScrollBarIncrementButtonIconTexture:Texture;
		
		protected var hScrollBarThumbUpSkinTexture:Texture;
		
		protected var hScrollBarThumbHoverSkinTexture:Texture;
		
		protected var hScrollBarThumbDownSkinTexture:Texture;
		
		protected var hScrollBarTrackSkinTexture:Texture;
		
		protected var hScrollBarThumbIconTexture:Texture;
		
		protected var hScrollBarStepButtonUpSkinTexture:Texture;
		
		protected var hScrollBarStepButtonHoverSkinTexture:Texture;
		
		protected var hScrollBarStepButtonDownSkinTexture:Texture;
		
		protected var hScrollBarStepButtonDisabledSkinTexture:Texture;
		
		protected var hScrollBarDecrementButtonIconTexture:Texture;
		
		protected var hScrollBarIncrementButtonIconTexture:Texture;
		
		protected var simpleBorderBackgroundSkinTexture:Texture;
		
		protected var insetBorderBackgroundSkinTexture:Texture;
		
		protected var panelBorderBackgroundSkinTexture:Texture;
		
		protected var alertBorderBackgroundSkinTexture:Texture;
		
		protected var progressBarFillSkinTexture:Texture;
		
		protected var listDrillDownAccessoryTexture:Texture;
		
		protected var playPauseButtonPlayUpIconTexture:Texture;
		
		protected var playPauseButtonPauseUpIconTexture:Texture;
		
		protected var overlayPlayPauseButtonPlayUpIconTexture:Texture;
		
		protected var fullScreenToggleButtonEnterUpIconTexture:Texture;
		
		protected var fullScreenToggleButtonExitUpIconTexture:Texture;
		
		protected var muteToggleButtonLoudUpIconTexture:Texture;
		
		protected var muteToggleButtonMutedUpIconTexture:Texture;
		
		protected var horizontalVolumeSliderMinimumTrackSkinTexture:Texture;
		
		protected var horizontalVolumeSliderMaximumTrackSkinTexture:Texture;
		
		protected var verticalVolumeSliderMinimumTrackSkinTexture:Texture;
		
		protected var verticalVolumeSliderMaximumTrackSkinTexture:Texture;
		
		protected var popUpVolumeSliderMinimumTrackSkinTexture:Texture;
		
		protected var popUpVolumeSliderMaximumTrackSkinTexture:Texture;
		
		protected var seekSliderMinimumTrackSkinTexture:Texture;
		
		protected var seekSliderMaximumTrackSkinTexture:Texture;
		
		protected var seekSliderProgressSkinTexture:Texture;
		
		public function BaseAeonDesktopTheme() {
			super();
		}
		
		protected static function textRendererFactory() : ITextRenderer {
			return new TextFieldTextRenderer();
		}
		
		protected static function textEditorFactory() : ITextEditor {
			return new TextFieldTextEditor();
		}
		
		protected static function scrollBarFactory() : IScrollBar {
			return new ScrollBar();
		}
		
		protected static function popUpOverlayFactory() : DisplayObject {
			var _local1:Quad = new Quad(100,100,14540253);
			_local1.alpha = 0.5;
			return _local1;
		}
		
		override public function dispose() : void {
			if(this.atlas) {
				this.atlas.texture.root.onRestore = null;
				this.atlas.dispose();
				this.atlas = null;
			}
			var _local1:Stage = Starling.current.stage;
			FocusManager.setEnabledForStage(_local1,false);
			ToolTipManager.setEnabledForStage(_local1,false);
			super.dispose();
		}
		
		protected function initialize() : void {
			this.initializeDimensions();
			this.initializeFonts();
			this.initializeTextures();
			this.initializeGlobals();
			this.initializeStage();
			this.initializeStyleProviders();
		}
		
		protected function initializeDimensions() : void {
			this.gridSize = 30;
			this.extraSmallGutterSize = 2;
			this.smallGutterSize = 6;
			this.gutterSize = 10;
			this.borderSize = 1;
			this.controlSize = 22;
			this.smallControlSize = 12;
			this.calloutBackgroundMinSize = 5;
			this.progressBarFillMinSize = 7;
			this.buttonMinWidth = 40;
			this.wideControlSize = 152;
			this.popUpSize = this.gridSize * 10 + this.smallGutterSize * 9;
			this.popUpVolumeSliderPaddingSize = 6;
			this.leftAndRightDropShadowSize = 1;
			this.bottomDropShadowSize = 3;
			this.calloutArrowOverlapGap = -1;
		}
		
		protected function initializeStage() : void {
			Starling.current.stage.color = 8821927;
			Starling.current.nativeStage.color = 8821927;
		}
		
		protected function initializeGlobals() : void {
			var _local1:Stage = Starling.current.stage;
			FocusManager.setEnabledForStage(_local1,true);
			ToolTipManager.setEnabledForStage(_local1,true);
			FeathersControl.defaultTextRendererFactory = textRendererFactory;
			FeathersControl.defaultTextEditorFactory = textEditorFactory;
			PopUpManager.overlayFactory = popUpOverlayFactory;
			Callout.stagePadding = this.smallGutterSize;
		}
		
		protected function initializeFonts() : void {
			this.smallFontSize = 10;
			this.regularFontSize = 11;
			this.largeFontSize = 13;
			this.defaultTextFormat = new TextFormat("_sans",this.regularFontSize,734012,false,false,false,null,null,"left",0,0,0,0);
			this.disabledTextFormat = new TextFormat("_sans",this.regularFontSize,5990256,false,false,false,null,null,"left",0,0,0,0);
			this.headingTextFormat = new TextFormat("_sans",this.largeFontSize,734012,false,false,false,null,null,"left",0,0,0,0);
			this.headingDisabledTextFormat = new TextFormat("_sans",this.largeFontSize,5990256,false,false,false,null,null,"left",0,0,0,0);
			this.detailTextFormat = new TextFormat("_sans",this.smallFontSize,734012,false,false,false,null,null,"left",0,0,0,0);
			this.detailDisabledTextFormat = new TextFormat("_sans",this.smallFontSize,5990256,false,false,false,null,null,"left",0,0,0,0);
			this.invertedTextFormat = new TextFormat("_sans",this.regularFontSize,16777215,false,false,false,null,null,"left",0,0,0,0);
		}
		
		protected function initializeTextures() : void {
			this.focusIndicatorSkinTexture = this.atlas.getTexture("focus-indicator-skin0000");
			this.toolTipBackgroundSkinTexture = this.atlas.getTexture("tool-tip-background-skin0000");
			this.calloutBackgroundSkinTexture = this.atlas.getTexture("callout-background-skin0000");
			this.calloutTopArrowSkinTexture = this.atlas.getTexture("callout-top-arrow-skin0000");
			this.calloutRightArrowSkinTexture = this.atlas.getTexture("callout-right-arrow-skin0000");
			this.calloutBottomArrowSkinTexture = this.atlas.getTexture("callout-bottom-arrow-skin0000");
			this.calloutLeftArrowSkinTexture = this.atlas.getTexture("callout-left-arrow-skin0000");
			this.dangerCalloutBackgroundSkinTexture = this.atlas.getTexture("danger-callout-background-skin0000");
			this.dangerCalloutTopArrowSkinTexture = this.atlas.getTexture("danger-callout-top-arrow-skin0000");
			this.dangerCalloutRightArrowSkinTexture = this.atlas.getTexture("danger-callout-right-arrow-skin0000");
			this.dangerCalloutBottomArrowSkinTexture = this.atlas.getTexture("danger-callout-bottom-arrow-skin0000");
			this.dangerCalloutLeftArrowSkinTexture = this.atlas.getTexture("danger-callout-left-arrow-skin0000");
			this.buttonUpSkinTexture = this.atlas.getTexture("button-up-skin0000");
			this.buttonHoverSkinTexture = this.atlas.getTexture("button-hover-skin0000");
			this.buttonDownSkinTexture = this.atlas.getTexture("button-down-skin0000");
			this.buttonDisabledSkinTexture = this.atlas.getTexture("button-disabled-skin0000");
			this.toggleButtonSelectedUpSkinTexture = this.atlas.getTexture("toggle-button-selected-up-skin0000");
			this.toggleButtonSelectedHoverSkinTexture = this.atlas.getTexture("toggle-button-selected-hover-skin0000");
			this.toggleButtonSelectedDownSkinTexture = this.atlas.getTexture("toggle-button-selected-down-skin0000");
			this.toggleButtonSelectedDisabledSkinTexture = this.atlas.getTexture("toggle-button-selected-disabled-skin0000");
			this.quietButtonHoverSkinTexture = this.atlas.getTexture("quiet-button-hover-skin0000");
			this.callToActionButtonUpSkinTexture = this.atlas.getTexture("call-to-action-button-up-skin0000");
			this.callToActionButtonHoverSkinTexture = this.atlas.getTexture("call-to-action-button-hover-skin0000");
			this.dangerButtonUpSkinTexture = this.atlas.getTexture("danger-button-up-skin0000");
			this.dangerButtonHoverSkinTexture = this.atlas.getTexture("danger-button-hover-skin0000");
			this.dangerButtonDownSkinTexture = this.atlas.getTexture("danger-button-down-skin0000");
			this.backButtonUpIconTexture = this.atlas.getTexture("back-button-up-icon0000");
			this.backButtonDisabledIconTexture = this.atlas.getTexture("back-button-disabled-icon0000");
			this.forwardButtonUpIconTexture = this.atlas.getTexture("forward-button-up-icon0000");
			this.forwardButtonDisabledIconTexture = this.atlas.getTexture("forward-button-disabled-icon0000");
			this.tabUpSkinTexture = this.atlas.getTexture("tab-up-skin0000");
			this.tabHoverSkinTexture = this.atlas.getTexture("tab-hover-skin0000");
			this.tabDownSkinTexture = this.atlas.getTexture("tab-down-skin0000");
			this.tabDisabledSkinTexture = this.atlas.getTexture("tab-disabled-skin0000");
			this.tabSelectedUpSkinTexture = this.atlas.getTexture("tab-selected-up-skin0000");
			this.tabSelectedDisabledSkinTexture = this.atlas.getTexture("tab-selected-disabled-skin0000");
			this.stepperIncrementButtonUpSkinTexture = this.atlas.getTexture("numeric-stepper-increment-button-up-skin0000");
			this.stepperIncrementButtonHoverSkinTexture = this.atlas.getTexture("numeric-stepper-increment-button-hover-skin0000");
			this.stepperIncrementButtonDownSkinTexture = this.atlas.getTexture("numeric-stepper-increment-button-down-skin0000");
			this.stepperIncrementButtonDisabledSkinTexture = this.atlas.getTexture("numeric-stepper-increment-button-disabled-skin0000");
			this.stepperDecrementButtonUpSkinTexture = this.atlas.getTexture("numeric-stepper-decrement-button-up-skin0000");
			this.stepperDecrementButtonHoverSkinTexture = this.atlas.getTexture("numeric-stepper-decrement-button-hover-skin0000");
			this.stepperDecrementButtonDownSkinTexture = this.atlas.getTexture("numeric-stepper-decrement-button-down-skin0000");
			this.stepperDecrementButtonDisabledSkinTexture = this.atlas.getTexture("numeric-stepper-decrement-button-disabled-skin0000");
			this.hSliderThumbUpSkinTexture = this.atlas.getTexture("horizontal-slider-thumb-up-skin0000");
			this.hSliderThumbHoverSkinTexture = this.atlas.getTexture("horizontal-slider-thumb-hover-skin0000");
			this.hSliderThumbDownSkinTexture = this.atlas.getTexture("horizontal-slider-thumb-down-skin0000");
			this.hSliderThumbDisabledSkinTexture = this.atlas.getTexture("horizontal-slider-thumb-disabled-skin0000");
			this.hSliderTrackEnabledSkinTexture = this.atlas.getTexture("horizontal-slider-track-enabled-skin0000");
			this.vSliderThumbUpSkinTexture = this.atlas.getTexture("vertical-slider-thumb-up-skin0000");
			this.vSliderThumbHoverSkinTexture = this.atlas.getTexture("vertical-slider-thumb-hover-skin0000");
			this.vSliderThumbDownSkinTexture = this.atlas.getTexture("vertical-slider-thumb-down-skin0000");
			this.vSliderThumbDisabledSkinTexture = this.atlas.getTexture("vertical-slider-thumb-disabled-skin0000");
			this.vSliderTrackEnabledSkinTexture = this.atlas.getTexture("vertical-slider-track-enabled-skin0000");
			this.itemRendererUpSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-up-skin0000"),ITEM_RENDERER_SKIN_TEXTURE_REGION);
			this.itemRendererHoverSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-hover-skin0000"),ITEM_RENDERER_SKIN_TEXTURE_REGION);
			this.itemRendererSelectedUpSkinTexture = Texture.fromTexture(this.atlas.getTexture("item-renderer-selected-up-skin0000"),ITEM_RENDERER_SKIN_TEXTURE_REGION);
			this.headerBackgroundSkinTexture = this.atlas.getTexture("header-background-skin0000");
			this.groupedListHeaderBackgroundSkinTexture = this.atlas.getTexture("grouped-list-header-background-skin0000");
			this.checkUpIconTexture = this.atlas.getTexture("check-up-icon0000");
			this.checkHoverIconTexture = this.atlas.getTexture("check-hover-icon0000");
			this.checkDownIconTexture = this.atlas.getTexture("check-down-icon0000");
			this.checkDisabledIconTexture = this.atlas.getTexture("check-disabled-icon0000");
			this.checkSelectedUpIconTexture = this.atlas.getTexture("check-selected-up-icon0000");
			this.checkSelectedHoverIconTexture = this.atlas.getTexture("check-selected-hover-icon0000");
			this.checkSelectedDownIconTexture = this.atlas.getTexture("check-selected-down-icon0000");
			this.checkSelectedDisabledIconTexture = this.atlas.getTexture("check-selected-disabled-icon0000");
			this.radioUpIconTexture = this.atlas.getTexture("radio-up-icon0000");
			this.radioHoverIconTexture = this.atlas.getTexture("radio-hover-icon0000");
			this.radioDownIconTexture = this.atlas.getTexture("radio-down-icon0000");
			this.radioDisabledIconTexture = this.atlas.getTexture("radio-disabled-icon0000");
			this.radioSelectedUpIconTexture = this.atlas.getTexture("radio-selected-up-icon0000");
			this.radioSelectedHoverIconTexture = this.atlas.getTexture("radio-selected-hover-icon0000");
			this.radioSelectedDownIconTexture = this.atlas.getTexture("radio-selected-down-icon0000");
			this.radioSelectedDisabledIconTexture = this.atlas.getTexture("radio-selected-disabled-icon0000");
			this.pageIndicatorNormalSkinTexture = this.atlas.getTexture("page-indicator-normal-symbol0000");
			this.pageIndicatorSelectedSkinTexture = this.atlas.getTexture("page-indicator-selected-symbol0000");
			this.pickerListUpIconTexture = this.atlas.getTexture("picker-list-up-icon0000");
			this.pickerListHoverIconTexture = this.atlas.getTexture("picker-list-hover-icon0000");
			this.pickerListDownIconTexture = this.atlas.getTexture("picker-list-down-icon0000");
			this.pickerListDisabledIconTexture = this.atlas.getTexture("picker-list-disabled-icon0000");
			this.textInputBackgroundEnabledSkinTexture = this.atlas.getTexture("text-input-background-enabled-skin0000");
			this.textInputBackgroundDisabledSkinTexture = this.atlas.getTexture("text-input-background-disabled-skin0000");
			this.textInputBackgroundErrorSkinTexture = this.atlas.getTexture("text-input-background-error-skin0000");
			this.textInputSearchIconTexture = this.atlas.getTexture("search-icon0000");
			this.textInputSearchIconDisabledTexture = this.atlas.getTexture("search-icon-disabled0000");
			this.vScrollBarThumbUpSkinTexture = this.atlas.getTexture("vertical-scroll-bar-thumb-up-skin0000");
			this.vScrollBarThumbHoverSkinTexture = this.atlas.getTexture("vertical-scroll-bar-thumb-hover-skin0000");
			this.vScrollBarThumbDownSkinTexture = this.atlas.getTexture("vertical-scroll-bar-thumb-down-skin0000");
			this.vScrollBarTrackSkinTexture = this.atlas.getTexture("vertical-scroll-bar-track-skin0000");
			this.vScrollBarThumbIconTexture = this.atlas.getTexture("vertical-scroll-bar-thumb-icon0000");
			this.vScrollBarStepButtonUpSkinTexture = this.atlas.getTexture("vertical-scroll-bar-step-button-up-skin0000");
			this.vScrollBarStepButtonHoverSkinTexture = this.atlas.getTexture("vertical-scroll-bar-step-button-hover-skin0000");
			this.vScrollBarStepButtonDownSkinTexture = this.atlas.getTexture("vertical-scroll-bar-step-button-down-skin0000");
			this.vScrollBarStepButtonDisabledSkinTexture = this.atlas.getTexture("vertical-scroll-bar-step-button-disabled-skin0000");
			this.vScrollBarDecrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-decrement-button-icon0000");
			this.vScrollBarIncrementButtonIconTexture = this.atlas.getTexture("vertical-scroll-bar-increment-button-icon0000");
			this.hScrollBarThumbUpSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-thumb-up-skin0000");
			this.hScrollBarThumbHoverSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-thumb-hover-skin0000");
			this.hScrollBarThumbDownSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-thumb-down-skin0000");
			this.hScrollBarTrackSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-track-skin0000");
			this.hScrollBarThumbIconTexture = this.atlas.getTexture("horizontal-scroll-bar-thumb-icon0000");
			this.hScrollBarStepButtonUpSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-step-button-up-skin0000");
			this.hScrollBarStepButtonHoverSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-step-button-hover-skin0000");
			this.hScrollBarStepButtonDownSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-step-button-down-skin0000");
			this.hScrollBarStepButtonDisabledSkinTexture = this.atlas.getTexture("horizontal-scroll-bar-step-button-disabled-skin0000");
			this.hScrollBarDecrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-decrement-button-icon0000");
			this.hScrollBarIncrementButtonIconTexture = this.atlas.getTexture("horizontal-scroll-bar-increment-button-icon0000");
			this.simpleBorderBackgroundSkinTexture = this.atlas.getTexture("simple-border-background-skin0000");
			this.insetBorderBackgroundSkinTexture = this.atlas.getTexture("inset-border-background-skin0000");
			this.panelBorderBackgroundSkinTexture = this.atlas.getTexture("panel-background-skin0000");
			this.alertBorderBackgroundSkinTexture = this.atlas.getTexture("alert-background-skin0000");
			this.progressBarFillSkinTexture = Texture.fromTexture(this.atlas.getTexture("progress-bar-fill-skin0000"),PROGRESS_BAR_FILL_TEXTURE_REGION);
			this.playPauseButtonPlayUpIconTexture = this.atlas.getTexture("play-pause-toggle-button-play-up-icon0000");
			this.playPauseButtonPauseUpIconTexture = this.atlas.getTexture("play-pause-toggle-button-pause-up-icon0000");
			this.overlayPlayPauseButtonPlayUpIconTexture = this.atlas.getTexture("overlay-play-pause-toggle-button-play-up-icon0000");
			this.fullScreenToggleButtonEnterUpIconTexture = this.atlas.getTexture("full-screen-toggle-button-enter-up-icon0000");
			this.fullScreenToggleButtonExitUpIconTexture = this.atlas.getTexture("full-screen-toggle-button-exit-up-icon0000");
			this.muteToggleButtonMutedUpIconTexture = this.atlas.getTexture("mute-toggle-button-muted-up-icon0000");
			this.muteToggleButtonLoudUpIconTexture = this.atlas.getTexture("mute-toggle-button-loud-up-icon0000");
			this.horizontalVolumeSliderMinimumTrackSkinTexture = this.atlas.getTexture("horizontal-volume-slider-minimum-track-skin0000");
			this.horizontalVolumeSliderMaximumTrackSkinTexture = this.atlas.getTexture("horizontal-volume-slider-maximum-track-skin0000");
			this.verticalVolumeSliderMinimumTrackSkinTexture = this.atlas.getTexture("vertical-volume-slider-minimum-track-skin0000");
			this.verticalVolumeSliderMaximumTrackSkinTexture = this.atlas.getTexture("vertical-volume-slider-maximum-track-skin0000");
			this.popUpVolumeSliderMinimumTrackSkinTexture = this.atlas.getTexture("pop-up-volume-slider-minimum-track-skin0000");
			this.popUpVolumeSliderMaximumTrackSkinTexture = this.atlas.getTexture("pop-up-volume-slider-maximum-track-skin0000");
			this.seekSliderMinimumTrackSkinTexture = this.atlas.getTexture("seek-slider-minimum-track-skin0000");
			this.seekSliderMaximumTrackSkinTexture = this.atlas.getTexture("seek-slider-maximum-track-skin0000");
			this.seekSliderProgressSkinTexture = this.atlas.getTexture("seek-slider-progress-skin0000");
			this.listDrillDownAccessoryTexture = this.atlas.getTexture("drill-down-icon0000");
		}
		
		protected function initializeStyleProviders() : void {
			this.getStyleProviderForClass(Alert).defaultStyleFunction = this.setAlertStyles;
			this.getStyleProviderForClass(Header).setFunctionForStyleName("feathers-alert-header",this.setPanelHeaderStyles);
			this.getStyleProviderForClass(ButtonGroup).setFunctionForStyleName("feathers-alert-button-group",this.setAlertButtonGroupStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-alert-message",this.setAlertMessageTextRendererStyles);
			this.getStyleProviderForClass(AutoComplete).defaultStyleFunction = this.setTextInputStyles;
			this.getStyleProviderForClass(List).setFunctionForStyleName("feathers-auto-complete-list",this.setDropDownListStyles);
			this.getStyleProviderForClass(Button).defaultStyleFunction = this.setButtonStyles;
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-quiet-button",this.setQuietButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-call-to-action-button",this.setCallToActionButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-danger-button",this.setDangerButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-back-button",this.setBackButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-forward-button",this.setForwardButtonStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-button-label",this.setButtonLabelStyles);
			this.getStyleProviderForClass(ButtonGroup).defaultStyleFunction = this.setButtonGroupStyles;
			this.getStyleProviderForClass(Callout).defaultStyleFunction = this.setCalloutStyles;
			this.getStyleProviderForClass(Check).defaultStyleFunction = this.setCheckStyles;
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-check-label",this.setCheckLabelStyles);
			this.getStyleProviderForClass(SpinnerList).setFunctionForStyleName("feathers-date-time-spinner-list",this.setDateTimeSpinnerListStyles);
			this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName("aeon-date-time-spinner-list-item-renderer",this.setDateTimeSpinnerListItemRendererStyles);
			this.getStyleProviderForClass(Drawers).defaultStyleFunction = this.setDrawersStyles;
			this.getStyleProviderForClass(GroupedList).defaultStyleFunction = this.setGroupedListStyles;
			this.getStyleProviderForClass(GroupedList).setFunctionForStyleName("feathers-inset-grouped-list",this.setInsetGroupedListStyles);
			this.getStyleProviderForClass(Header).defaultStyleFunction = this.setHeaderStyles;
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-header-title",this.setHeaderTitleStyles);
			this.getStyleProviderForClass(DefaultListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
			this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName("feathers-drill-down-item-renderer",this.setDrillDownItemRendererStyles);
			this.getStyleProviderForClass(DefaultListItemRenderer).setFunctionForStyleName("feathers-check-item-renderer",this.setCheckItemRendererStyles);
			this.getStyleProviderForClass(DefaultGroupedListItemRenderer).defaultStyleFunction = this.setItemRendererStyles;
			this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName("feathers-drill-down-item-renderer",this.setDrillDownItemRendererStyles);
			this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName("feathers-check-item-renderer",this.setCheckItemRendererStyles);
			this.getStyleProviderForClass(DefaultGroupedListItemRenderer).setFunctionForStyleName("feathers-grouped-list-inset-item-renderer",this.setInsetGroupedListItemRendererStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-item-renderer-accessory-label",this.setItemRendererAccessoryLabelStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-item-renderer-icon-label",this.setItemRendererIconLabelStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-item-renderer-label",this.setItemRendererLabelStyles);
			this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).defaultStyleFunction = this.setGroupedListHeaderOrFooterRendererStyles;
			this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName("feathers-grouped-list-inset-header-renderer",this.setInsetGroupedListHeaderRendererStyles);
			this.getStyleProviderForClass(DefaultGroupedListHeaderOrFooterRenderer).setFunctionForStyleName("feathers-grouped-list-inset-footer-renderer",this.setInsetGroupedListFooterRendererStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-header-footer-renderer-content-label",this.setGroupedListHeaderOrFooterRendererContentLabelStyles);
			this.getStyleProviderForClass(Label).setFunctionForStyleName("feathers-heading-label",this.setHeadingLabelStyles);
			this.getStyleProviderForClass(Label).setFunctionForStyleName("feathers-detail-label",this.setDetailLabelStyles);
			this.getStyleProviderForClass(Label).setFunctionForStyleName("feathers-tool-tip",this.setToolTipLabelStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-label-text-renderer",this.setLabelTextRendererStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("aeon-heading-label-text-renderer",this.setHeadingLabelTextRendererStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("aeon-detail-label-text-renderer",this.setDetailLabelTextRendererStyles);
			this.getStyleProviderForClass(LayoutGroup).setFunctionForStyleName("feathers-toolbar-layout-group",this.setToolbarLayoutGroupStyles);
			this.getStyleProviderForClass(List).defaultStyleFunction = this.setListStyles;
			this.getStyleProviderForClass(NumericStepper).defaultStyleFunction = this.setNumericStepperStyles;
			this.getStyleProviderForClass(TextInput).setFunctionForStyleName("feathers-numeric-stepper-text-input",this.setNumericStepperTextInputStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-numeric-stepper-increment-button",this.setNumericStepperIncrementButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-numeric-stepper-decrement-button",this.setNumericStepperDecrementButtonStyles);
			this.getStyleProviderForClass(Panel).defaultStyleFunction = this.setPanelStyles;
			this.getStyleProviderForClass(Header).setFunctionForStyleName("feathers-panel-header",this.setPanelHeaderStyles);
			this.getStyleProviderForClass(PanelScreen).defaultStyleFunction = this.setPanelScreenStyles;
			this.getStyleProviderForClass(PageIndicator).defaultStyleFunction = this.setPageIndicatorStyles;
			this.getStyleProviderForClass(PickerList).defaultStyleFunction = this.setPickerListStyles;
			this.getStyleProviderForClass(List).setFunctionForStyleName("feathers-picker-list-list",this.setDropDownListStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-picker-list-button",this.setPickerListButtonStyles);
			this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName("feathers-picker-list-button",this.setPickerListButtonStyles);
			this.getStyleProviderForClass(ProgressBar).defaultStyleFunction = this.setProgressBarStyles;
			this.getStyleProviderForClass(Radio).defaultStyleFunction = this.setRadioStyles;
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-radio-label",this.setRadioLabelStyles);
			this.getStyleProviderForClass(ScrollBar).setFunctionForStyleName("feathers-scroller-horizontal-scroll-bar",this.setHorizontalScrollBarStyles);
			this.getStyleProviderForClass(ScrollBar).setFunctionForStyleName("feathers-scroller-vertical-scroll-bar",this.setVerticalScrollBarStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-horizontal-scroll-bar-increment-button",this.setHorizontalScrollBarIncrementButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-horizontal-scroll-bar-decrement-button",this.setHorizontalScrollBarDecrementButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-horizontal-scroll-bar-thumb",this.setHorizontalScrollBarThumbStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-horizontal-scroll-bar-minimum-track",this.setHorizontalScrollBarMinimumTrackStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-vertical-scroll-bar-increment-button",this.setVerticalScrollBarIncrementButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-vertical-scroll-bar-decrement-button",this.setVerticalScrollBarDecrementButtonStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-vertical-scroll-bar-thumb",this.setVerticalScrollBarThumbStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-vertical-scroll-bar-minimum-track",this.setVerticalScrollBarMinimumTrackStyles);
			this.getStyleProviderForClass(ScrollContainer).defaultStyleFunction = this.setScrollContainerStyles;
			this.getStyleProviderForClass(ScrollContainer).setFunctionForStyleName("feathers-toolbar-scroll-container",this.setToolbarScrollContainerStyles);
			this.getStyleProviderForClass(ScrollScreen).defaultStyleFunction = this.setScrollScreenStyles;
			this.getStyleProviderForClass(ScrollText).defaultStyleFunction = this.setScrollTextStyles;
			this.getStyleProviderForClass(SimpleScrollBar).setFunctionForStyleName("feathers-scroller-horizontal-scroll-bar",this.setHorizontalSimpleScrollBarStyles);
			this.getStyleProviderForClass(SimpleScrollBar).setFunctionForStyleName("feathers-scroller-vertical-scroll-bar",this.setVerticalSimpleScrollBarStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-horizontal-simple-scroll-bar-thumb",this.setHorizontalSimpleScrollBarThumbStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-vertical-simple-scroll-bar-thumb",this.setVerticalSimpleScrollBarThumbStyles);
			this.getStyleProviderForClass(Slider).defaultStyleFunction = this.setSliderStyles;
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-horizontal-slider-thumb",this.setHorizontalSliderThumbStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-horizontal-slider-minimum-track",this.setHorizontalSliderMinimumTrackStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-vertical-slider-thumb",this.setVerticalSliderThumbStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-vertical-slider-minimum-track",this.setVerticalSliderMinimumTrackStyles);
			this.getStyleProviderForClass(SpinnerList).defaultStyleFunction = this.setSpinnerListStyles;
			this.getStyleProviderForClass(TabBar).defaultStyleFunction = this.setTabBarStyles;
			this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName("feathers-tab-bar-tab",this.setTabStyles);
			this.getStyleProviderForClass(TextArea).defaultStyleFunction = this.setTextAreaStyles;
			this.getStyleProviderForClass(TextFieldTextEditorViewPort).setFunctionForStyleName("feathers-text-area-text-editor",this.setTextAreaTextEditorStyles);
			this.getStyleProviderForClass(TextCallout).setFunctionForStyleName("feathers-text-input-error-callout",this.setTextAreaErrorCalloutStyles);
			this.getStyleProviderForClass(TextCallout).defaultStyleFunction = this.setTextCalloutStyles;
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-text-callout-text-renderer",this.setTextCalloutTextRendererStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("aeon-danger-text-callout-text-renderer",this.setDangerTextCalloutTextRendererStyles);
			this.getStyleProviderForClass(TextInput).defaultStyleFunction = this.setTextInputStyles;
			this.getStyleProviderForClass(TextInput).setFunctionForStyleName("feathers-search-text-input",this.setSearchTextInputStyles);
			this.getStyleProviderForClass(TextFieldTextEditor).setFunctionForStyleName("feathers-text-input-text-editor",this.setTextInputTextEditorStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-text-input-prompt",this.setTextInputPromptStyles);
			this.getStyleProviderForClass(TextCallout).setFunctionForStyleName("feathers-text-input-error-callout",this.setTextInputErrorCalloutStyles);
			this.getStyleProviderForClass(ToggleButton).defaultStyleFunction = this.setButtonStyles;
			this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName("feathers-quiet-button",this.setQuietButtonStyles);
			this.getStyleProviderForClass(ToggleSwitch).defaultStyleFunction = this.setToggleSwitchStyles;
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-toggle-switch-on-track",this.setToggleSwitchOnTrackStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-toggle-switch-thumb",this.setToggleSwitchThumbStyles);
			this.getStyleProviderForClass(ToggleButton).setFunctionForStyleName("feathers-toggle-switch-thumb",this.setToggleSwitchThumbStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-toggle-switch-on-label",this.setToggleSwitchOnLabelStyles);
			this.getStyleProviderForClass(TextFieldTextRenderer).setFunctionForStyleName("feathers-toggle-switch-off-label",this.setToggleSwitchOffLabelStyles);
			this.getStyleProviderForClass(PlayPauseToggleButton).defaultStyleFunction = this.setPlayPauseToggleButtonStyles;
			this.getStyleProviderForClass(PlayPauseToggleButton).setFunctionForStyleName("feathers-overlay-play-pause-toggle-button",this.setOverlayPlayPauseToggleButtonStyles);
			this.getStyleProviderForClass(FullScreenToggleButton).defaultStyleFunction = this.setFullScreenToggleButtonStyles;
			this.getStyleProviderForClass(MuteToggleButton).defaultStyleFunction = this.setMuteToggleButtonStyles;
			this.getStyleProviderForClass(VolumeSlider).setFunctionForStyleName("feathers-volume-toggle-button-volume-slider",this.setPopUpVolumeSliderStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-pop-up-volume-slider-minimum-track",this.setPopUpVolumeSliderMinimumTrackStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-pop-up-volume-slider-maximum-track",this.setPopUpVolumeSliderMaximumTrackStyles);
			this.getStyleProviderForClass(SeekSlider).defaultStyleFunction = this.setSeekSliderStyles;
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-seek-slider-thumb",this.setHorizontalSliderThumbStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-seek-slider-minimum-track",this.setSeekSliderMinimumTrackStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-seek-slider-maximum-track",this.setSeekSliderMaximumTrackStyles);
			this.getStyleProviderForClass(VolumeSlider).defaultStyleFunction = this.setVolumeSliderStyles;
			this.getStyleProviderForClass(Button).setFunctionForStyleName("feathers-volume-slider-thumb",this.setVolumeSliderThumbStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-horizontal-volume-slider-minimum-track",this.setHorizontalVolumeSliderMinimumTrackStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-horizontal-volume-slider-maximum-track",this.setHorizontalVolumeSliderMaximumTrackStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-vertical-volume-slider-minimum-track",this.setVerticalVolumeSliderMinimumTrackStyles);
			this.getStyleProviderForClass(Button).setFunctionForStyleName("aeon-vertical-volume-slider-maximum-track",this.setVerticalVolumeSliderMaximumTrackStyles);
		}
		
		protected function pageIndicatorNormalSymbolFactory() : Image {
			return new Image(this.pageIndicatorNormalSkinTexture);
		}
		
		protected function pageIndicatorSelectedSymbolFactory() : Image {
			return new Image(this.pageIndicatorSelectedSkinTexture);
		}
		
		protected function setScrollerStyles(scroller:Scroller) : void {
			scroller.clipContent = true;
			scroller.horizontalScrollBarFactory = scrollBarFactory;
			scroller.verticalScrollBarFactory = scrollBarFactory;
			scroller.interactionMode = "mouse";
			scroller.scrollBarDisplayMode = "fixed";
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			scroller.focusIndicatorSkin = _local2;
			scroller.focusPadding = 0;
		}
		
		protected function setDropDownListStyles(list:List) : void {
			this.setListStyles(list);
			list.maxHeight = this.wideControlSize;
		}
		
		protected function setAlertStyles(alert:Alert) : void {
			this.setScrollerStyles(alert);
			var _local2:Image = new Image(this.alertBorderBackgroundSkinTexture);
			_local2.scale9Grid = PANEL_BORDER_SCALE_9_GRID;
			alert.backgroundSkin = _local2;
			alert.outerPadding = this.borderSize;
			alert.paddingTop = this.smallGutterSize;
			alert.paddingBottom = this.smallGutterSize;
			alert.paddingRight = this.gutterSize;
			alert.paddingLeft = this.gutterSize;
			alert.gap = this.gutterSize;
			alert.maxWidth = this.popUpSize;
			alert.maxHeight = this.popUpSize;
		}
		
		protected function setAlertButtonGroupStyles(group:ButtonGroup) : void {
			group.direction = "horizontal";
			group.horizontalAlign = "center";
			group.verticalAlign = "justify";
			group.distributeButtonSizes = false;
			group.gap = this.smallGutterSize;
			group.padding = this.smallGutterSize;
		}
		
		protected function setAlertMessageTextRendererStyles(renderer:TextFieldTextRenderer) : void {
			renderer.textFormat = this.defaultTextFormat;
			renderer.disabledTextFormat = this.disabledTextFormat;
			renderer.wordWrap = true;
		}
		
		protected function setBaseButtonStyles(button:Button) : void {
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			button.focusIndicatorSkin = _local2;
			button.focusPadding = -1;
			button.paddingTop = this.extraSmallGutterSize;
			button.paddingBottom = this.extraSmallGutterSize;
			button.paddingLeft = this.smallGutterSize;
			button.paddingRight = this.smallGutterSize;
			button.gap = this.smallGutterSize;
			button.minGap = this.smallGutterSize;
			button.minWidth = this.smallControlSize;
			button.minHeight = this.smallControlSize;
		}
		
		protected function setButtonStyles(button:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.buttonUpSkinTexture);
			_local2.setTextureForState("hover",this.buttonHoverSkinTexture);
			_local2.setTextureForState("down",this.buttonDownSkinTexture);
			_local2.setTextureForState("disabled",this.buttonDisabledSkinTexture);
			if(button is ToggleButton) {
				_local2.selectedTexture = this.toggleButtonSelectedUpSkinTexture;
				_local2.setTextureForState("hoverAndSelected",this.toggleButtonSelectedHoverSkinTexture);
				_local2.setTextureForState("downAndSelected",this.toggleButtonSelectedDownSkinTexture);
				_local2.setTextureForState("disabledAndSelected",this.toggleButtonSelectedDisabledSkinTexture);
			}
			_local2.scale9Grid = BUTTON_SCALE_9_GRID;
			button.defaultSkin = _local2;
			this.setBaseButtonStyles(button);
			button.minWidth = this.buttonMinWidth;
			button.minHeight = this.controlSize;
		}
		
		protected function setQuietButtonStyles(button:Button) : void {
			var _local2:Quad = new Quad(this.controlSize,this.controlSize,0xff00ff);
			_local2.alpha = 0;
			button.defaultSkin = _local2;
			var _local3:ImageSkin = new ImageSkin(null);
			_local3.setTextureForState("hover",this.quietButtonHoverSkinTexture);
			_local3.setTextureForState("down",this.buttonDownSkinTexture);
			button.setSkinForState("hover",_local3);
			button.setSkinForState("down",_local3);
			if(button is ToggleButton) {
				_local3.selectedTexture = this.toggleButtonSelectedUpSkinTexture;
				_local3.setTextureForState("hoverAndSelected",this.toggleButtonSelectedHoverSkinTexture);
				_local3.setTextureForState("downAndSelected",this.toggleButtonSelectedDownSkinTexture);
				_local3.setTextureForState("disabledAndSelected",this.toggleButtonSelectedDisabledSkinTexture);
				ToggleButton(button).defaultSelectedSkin = _local3;
			}
			_local3.scale9Grid = BUTTON_SCALE_9_GRID;
			_local3.width = this.controlSize;
			_local3.height = this.controlSize;
			this.setBaseButtonStyles(button);
			button.minWidth = this.controlSize;
			button.minHeight = this.controlSize;
		}
		
		protected function setCallToActionButtonStyles(button:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.callToActionButtonUpSkinTexture);
			_local2.setTextureForState("hover",this.callToActionButtonHoverSkinTexture);
			_local2.setTextureForState("down",this.buttonDownSkinTexture);
			_local2.scale9Grid = BUTTON_SCALE_9_GRID;
			_local2.width = this.controlSize;
			_local2.height = this.controlSize;
			button.defaultSkin = _local2;
			this.setBaseButtonStyles(button);
			button.minWidth = this.controlSize;
			button.minHeight = this.controlSize;
		}
		
		protected function setDangerButtonStyles(button:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.dangerButtonUpSkinTexture);
			_local2.setTextureForState("hover",this.dangerButtonHoverSkinTexture);
			_local2.setTextureForState("down",this.dangerButtonDownSkinTexture);
			_local2.scale9Grid = BUTTON_SCALE_9_GRID;
			_local2.width = this.controlSize;
			_local2.height = this.controlSize;
			button.defaultSkin = _local2;
			this.setBaseButtonStyles(button);
			button.minWidth = this.controlSize;
			button.minHeight = this.controlSize;
		}
		
		protected function setBackButtonStyles(button:Button) : void {
			this.setButtonStyles(button);
			var _local2:ImageSkin = new ImageSkin(this.backButtonUpIconTexture);
			_local2.disabledTexture = this.backButtonDisabledIconTexture;
			button.defaultIcon = _local2;
			button.iconPosition = "leftBaseline";
		}
		
		protected function setForwardButtonStyles(button:Button) : void {
			this.setButtonStyles(button);
			var _local2:ImageSkin = new ImageSkin(this.forwardButtonUpIconTexture);
			_local2.disabledTexture = this.forwardButtonDisabledIconTexture;
			button.defaultIcon = _local2;
			button.iconPosition = "rightBaseline";
		}
		
		protected function setButtonLabelStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setButtonGroupStyles(group:ButtonGroup) : void {
			group.gap = this.smallGutterSize;
		}
		
		protected function setCalloutStyles(callout:Callout) : void {
			var _local5:Image = new Image(this.calloutBackgroundSkinTexture);
			_local5.scale9Grid = CALLOUT_SCALE_9_GRID;
			callout.backgroundSkin = _local5;
			var _local3:Image = new Image(this.calloutTopArrowSkinTexture);
			callout.topArrowSkin = _local3;
			callout.topArrowGap = this.calloutArrowOverlapGap;
			var _local6:Image = new Image(this.calloutRightArrowSkinTexture);
			callout.rightArrowSkin = _local6;
			callout.rightArrowGap = this.calloutArrowOverlapGap - this.leftAndRightDropShadowSize;
			var _local4:Image = new Image(this.calloutBottomArrowSkinTexture);
			callout.bottomArrowSkin = _local4;
			callout.bottomArrowGap = this.calloutArrowOverlapGap - this.bottomDropShadowSize;
			var _local2:Image = new Image(this.calloutLeftArrowSkinTexture);
			callout.leftArrowSkin = _local2;
			callout.leftArrowGap = this.calloutArrowOverlapGap - this.leftAndRightDropShadowSize;
			callout.paddingTop = this.smallGutterSize;
			callout.paddingBottom = this.smallGutterSize + this.bottomDropShadowSize;
			callout.paddingRight = this.gutterSize + this.leftAndRightDropShadowSize;
			callout.paddingLeft = this.gutterSize + this.leftAndRightDropShadowSize;
		}
		
		protected function setDangerCalloutStyles(callout:Callout) : void {
			var _local5:Image = new Image(this.dangerCalloutBackgroundSkinTexture);
			_local5.scale9Grid = CALLOUT_SCALE_9_GRID;
			callout.backgroundSkin = _local5;
			var _local3:Image = new Image(this.dangerCalloutTopArrowSkinTexture);
			callout.topArrowSkin = _local3;
			callout.topArrowGap = this.calloutArrowOverlapGap;
			var _local6:Image = new Image(this.dangerCalloutRightArrowSkinTexture);
			callout.rightArrowSkin = _local6;
			callout.rightArrowGap = this.calloutArrowOverlapGap - this.leftAndRightDropShadowSize;
			var _local4:Image = new Image(this.dangerCalloutBottomArrowSkinTexture);
			callout.bottomArrowSkin = _local4;
			callout.bottomArrowGap = this.calloutArrowOverlapGap - this.bottomDropShadowSize;
			var _local2:Image = new Image(this.dangerCalloutLeftArrowSkinTexture);
			callout.leftArrowSkin = _local2;
			callout.leftArrowGap = this.calloutArrowOverlapGap - this.leftAndRightDropShadowSize;
			callout.paddingTop = this.smallGutterSize;
			callout.paddingBottom = this.smallGutterSize + this.bottomDropShadowSize;
			callout.paddingRight = this.gutterSize + this.leftAndRightDropShadowSize;
			callout.paddingLeft = this.gutterSize + this.leftAndRightDropShadowSize;
		}
		
		protected function setCheckStyles(check:Check) : void {
			var _local3:ImageSkin = new ImageSkin(this.checkUpIconTexture);
			_local3.selectedTexture = this.checkSelectedUpIconTexture;
			_local3.setTextureForState("hover",this.checkHoverIconTexture);
			_local3.setTextureForState("down",this.checkDownIconTexture);
			_local3.setTextureForState("disabled",this.checkDisabledIconTexture);
			_local3.setTextureForState("hoverAndSelected",this.checkSelectedHoverIconTexture);
			_local3.setTextureForState("downAndSelected",this.checkSelectedDownIconTexture);
			_local3.setTextureForState("disabledAndSelected",this.checkSelectedDisabledIconTexture);
			check.defaultIcon = _local3;
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			check.focusIndicatorSkin = _local2;
			check.focusPadding = -2;
			check.horizontalAlign = "left";
			check.verticalAlign = "middle";
			check.gap = this.smallGutterSize;
			check.minWidth = this.controlSize;
			check.minHeight = this.controlSize;
		}
		
		protected function setCheckLabelStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setDateTimeSpinnerListStyles(list:SpinnerList) : void {
			this.setSpinnerListStyles(list);
			list.customItemRendererStyleName = "aeon-date-time-spinner-list-item-renderer";
		}
		
		protected function setDateTimeSpinnerListItemRendererStyles(itemRenderer:DefaultListItemRenderer) : void {
			this.setItemRendererStyles(itemRenderer);
			itemRenderer.accessoryPosition = "left";
			itemRenderer.accessoryGap = this.smallGutterSize;
		}
		
		protected function setDrawersStyles(drawers:Drawers) : void {
			var _local2:Quad = new Quad(10,10,14540253);
			_local2.alpha = 0.5;
			drawers.overlaySkin = _local2;
		}
		
		protected function setGroupedListStyles(list:GroupedList) : void {
			this.setScrollerStyles(list);
			list.verticalScrollPolicy = "auto";
			var _local2:Image = new Image(this.simpleBorderBackgroundSkinTexture);
			_local2.scale9Grid = SIMPLE_BORDER_SCALE_9_GRID;
			list.backgroundSkin = _local2;
			list.padding = this.borderSize;
		}
		
		protected function setGroupedListHeaderOrFooterRendererStyles(renderer:DefaultGroupedListHeaderOrFooterRenderer) : void {
			var _local2:Image = new Image(this.groupedListHeaderBackgroundSkinTexture);
			_local2.scale9Grid = HEADER_SCALE_9_GRID;
			_local2.height = this.controlSize;
			renderer.backgroundSkin = _local2;
			renderer.paddingTop = this.extraSmallGutterSize;
			renderer.paddingBottom = this.extraSmallGutterSize;
			renderer.paddingRight = this.smallGutterSize;
			renderer.paddingLeft = this.smallGutterSize;
			renderer.minWidth = this.controlSize;
			renderer.minHeight = this.controlSize;
		}
		
		protected function setGroupedListHeaderOrFooterRendererContentLabelStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setInsetGroupedListStyles(list:GroupedList) : void {
			this.setScrollerStyles(list);
			list.verticalScrollPolicy = "auto";
			var _local3:Image = new Image(this.insetBorderBackgroundSkinTexture);
			_local3.scale9Grid = SIMPLE_BORDER_SCALE_9_GRID;
			list.backgroundSkin = _local3;
			list.padding = this.borderSize;
			list.customItemRendererStyleName = "feathers-grouped-list-inset-item-renderer";
			list.customHeaderRendererStyleName = "feathers-grouped-list-inset-header-renderer";
			list.customFooterRendererStyleName = "feathers-grouped-list-inset-footer-renderer";
			var _local2:VerticalLayout = new VerticalLayout();
			_local2.useVirtualLayout = true;
			_local2.paddingTop = this.gutterSize;
			_local2.paddingBottom = this.gutterSize;
			_local2.gap = 0;
			_local2.horizontalAlign = "justify";
			_local2.verticalAlign = "top";
			list.layout = _local2;
		}
		
		protected function setInsetGroupedListItemRendererStyles(renderer:BaseDefaultItemRenderer) : void {
			var _local2:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
			_local2.selectedTexture = this.itemRendererSelectedUpSkinTexture;
			_local2.setTextureForState("hover",this.itemRendererHoverSkinTexture);
			_local2.setTextureForState("down",this.itemRendererSelectedUpSkinTexture);
			renderer.defaultSkin = _local2;
			renderer.horizontalAlign = "left";
			renderer.iconPosition = "left";
			renderer.accessoryPosition = "right";
			renderer.paddingTop = this.extraSmallGutterSize;
			renderer.paddingBottom = this.extraSmallGutterSize;
			renderer.paddingRight = this.gutterSize;
			renderer.paddingLeft = this.gutterSize;
			renderer.gap = this.extraSmallGutterSize;
			renderer.minGap = this.extraSmallGutterSize;
			renderer.accessoryGap = Infinity;
			renderer.minAccessoryGap = this.smallGutterSize;
			renderer.minWidth = this.controlSize;
			renderer.minHeight = this.controlSize;
			renderer.useStateDelayTimer = false;
		}
		
		protected function setInsetGroupedListHeaderRendererStyles(renderer:DefaultGroupedListHeaderOrFooterRenderer) : void {
			renderer.paddingTop = this.gutterSize;
			renderer.paddingBottom = this.smallGutterSize;
			renderer.paddingRight = this.gutterSize;
			renderer.paddingLeft = this.gutterSize;
			renderer.minWidth = this.controlSize;
			renderer.minHeight = this.controlSize;
		}
		
		protected function setInsetGroupedListFooterRendererStyles(renderer:DefaultGroupedListHeaderOrFooterRenderer) : void {
			renderer.paddingTop = this.smallGutterSize;
			renderer.paddingBottom = this.smallGutterSize;
			renderer.paddingRight = this.gutterSize;
			renderer.paddingLeft = this.gutterSize;
			renderer.minWidth = this.controlSize;
			renderer.minHeight = this.controlSize;
		}
		
		protected function setHeaderStyles(header:Header) : void {
			var _local2:Image = new Image(this.headerBackgroundSkinTexture);
			_local2.scale9Grid = HEADER_SCALE_9_GRID;
			header.backgroundSkin = _local2;
			header.minWidth = this.gridSize;
			header.minHeight = this.gridSize;
			header.paddingTop = this.extraSmallGutterSize;
			header.paddingBottom = this.extraSmallGutterSize + this.borderSize;
			header.paddingLeft = this.smallGutterSize;
			header.paddingRight = this.smallGutterSize;
			header.gap = this.extraSmallGutterSize;
			header.titleGap = this.gutterSize;
		}
		
		protected function setHeaderTitleStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setLabelTextRendererStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setHeadingLabelStyles(label:Label) : void {
			label.customTextRendererStyleName = "aeon-heading-label-text-renderer";
		}
		
		protected function setHeadingLabelTextRendererStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.headingTextFormat;
			textRenderer.disabledTextFormat = this.headingDisabledTextFormat;
		}
		
		protected function setDetailLabelStyles(label:Label) : void {
			label.customTextRendererStyleName = "aeon-detail-label-text-renderer";
		}
		
		protected function setDetailLabelTextRendererStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.detailTextFormat;
			textRenderer.disabledTextFormat = this.detailDisabledTextFormat;
		}
		
		protected function setToolTipLabelStyles(label:Label) : void {
			var _local2:Image = new Image(this.toolTipBackgroundSkinTexture);
			_local2.scale9Grid = TOOL_TIP_SCALE_9_GRID;
			label.backgroundSkin = _local2;
			label.customTextRendererStyleName = "aeon-tool-tip-label-text-renderer";
			label.paddingTop = this.extraSmallGutterSize;
			label.paddingRight = this.smallGutterSize + this.leftAndRightDropShadowSize;
			label.paddingBottom = this.extraSmallGutterSize + this.bottomDropShadowSize;
			label.paddingLeft = this.smallGutterSize + this.leftAndRightDropShadowSize;
		}
		
		protected function setToolTipLabelTextRendererStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setToolbarLayoutGroupStyles(group:LayoutGroup) : void {
			var _local2:HorizontalLayout = null;
			if(!group.layout) {
				_local2 = new HorizontalLayout();
				_local2.paddingTop = this.extraSmallGutterSize;
				_local2.paddingBottom = this.extraSmallGutterSize;
				_local2.paddingRight = this.smallGutterSize;
				_local2.paddingLeft = this.smallGutterSize;
				_local2.gap = this.smallGutterSize;
				_local2.verticalAlign = "middle";
				group.layout = _local2;
			}
			group.minHeight = this.gridSize;
			var _local3:Image = new Image(this.headerBackgroundSkinTexture);
			_local3.scale9Grid = HEADER_SCALE_9_GRID;
			group.backgroundSkin = _local3;
		}
		
		protected function setListStyles(list:List) : void {
			this.setScrollerStyles(list);
			list.verticalScrollPolicy = "auto";
			var _local2:Image = new Image(this.simpleBorderBackgroundSkinTexture);
			_local2.scale9Grid = SIMPLE_BORDER_SCALE_9_GRID;
			list.backgroundSkin = _local2;
			list.padding = this.borderSize;
		}
		
		protected function setItemRendererStyles(itemRenderer:BaseDefaultItemRenderer) : void {
			var _local2:ImageSkin = new ImageSkin(this.itemRendererUpSkinTexture);
			_local2.selectedTexture = this.itemRendererSelectedUpSkinTexture;
			_local2.setTextureForState("hover",this.itemRendererHoverSkinTexture);
			_local2.setTextureForState("down",this.itemRendererSelectedUpSkinTexture);
			itemRenderer.defaultSkin = _local2;
			itemRenderer.horizontalAlign = "left";
			itemRenderer.iconPosition = "left";
			itemRenderer.accessoryPosition = "right";
			itemRenderer.paddingTop = this.extraSmallGutterSize;
			itemRenderer.paddingBottom = this.extraSmallGutterSize;
			itemRenderer.paddingRight = this.smallGutterSize;
			itemRenderer.paddingLeft = this.smallGutterSize;
			itemRenderer.gap = this.extraSmallGutterSize;
			itemRenderer.minGap = this.extraSmallGutterSize;
			itemRenderer.accessoryGap = Infinity;
			itemRenderer.minAccessoryGap = this.smallGutterSize;
			itemRenderer.minWidth = this.controlSize;
			itemRenderer.minHeight = this.controlSize;
			itemRenderer.useStateDelayTimer = false;
		}
		
		protected function setDrillDownItemRendererStyles(itemRenderer:BaseDefaultItemRenderer) : void {
			this.setItemRendererStyles(itemRenderer);
			itemRenderer.itemHasAccessory = false;
			var _local2:ImageLoader = new ImageLoader();
			_local2.source = this.listDrillDownAccessoryTexture;
			itemRenderer.defaultAccessory = _local2;
		}
		
		protected function setCheckItemRendererStyles(itemRenderer:BaseDefaultItemRenderer) : void {
			itemRenderer.defaultSkin = new Image(this.itemRendererUpSkinTexture);
			itemRenderer.itemHasIcon = false;
			var _local2:ImageSkin = new ImageSkin(this.checkUpIconTexture);
			_local2.selectedTexture = this.checkSelectedUpIconTexture;
			_local2.setTextureForState("hover",this.checkHoverIconTexture);
			_local2.setTextureForState("down",this.checkDownIconTexture);
			_local2.setTextureForState("disabled",this.checkDisabledIconTexture);
			_local2.setTextureForState("hoverAndSelected",this.checkSelectedHoverIconTexture);
			_local2.setTextureForState("downAndSelected",this.checkSelectedDownIconTexture);
			_local2.setTextureForState("disabledAndSelected",this.checkSelectedDisabledIconTexture);
			itemRenderer.defaultIcon = _local2;
			itemRenderer.horizontalAlign = "left";
			itemRenderer.iconPosition = "left";
			itemRenderer.accessoryPosition = "right";
			itemRenderer.paddingTop = this.extraSmallGutterSize;
			itemRenderer.paddingBottom = this.extraSmallGutterSize;
			itemRenderer.paddingRight = this.smallGutterSize;
			itemRenderer.paddingLeft = this.smallGutterSize;
			itemRenderer.gap = this.smallGutterSize;
			itemRenderer.minGap = this.smallGutterSize;
			itemRenderer.accessoryGap = Infinity;
			itemRenderer.minAccessoryGap = this.smallGutterSize;
			itemRenderer.minWidth = this.controlSize;
			itemRenderer.minHeight = this.controlSize;
			itemRenderer.useStateDelayTimer = false;
		}
		
		protected function setItemRendererLabelStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setItemRendererAccessoryLabelStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setItemRendererIconLabelStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setNumericStepperStyles(stepper:NumericStepper) : void {
			stepper.buttonLayoutMode = "rightSideVertical";
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			stepper.focusIndicatorSkin = _local2;
			stepper.focusPadding = -1;
		}
		
		protected function setNumericStepperIncrementButtonStyles(button:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.stepperIncrementButtonUpSkinTexture);
			_local2.setTextureForState("hover",this.stepperIncrementButtonHoverSkinTexture);
			_local2.setTextureForState("down",this.stepperIncrementButtonDownSkinTexture);
			_local2.setTextureForState("disabled",this.stepperIncrementButtonDisabledSkinTexture);
			_local2.scale9Grid = STEPPER_INCREMENT_BUTTON_SCALE_9_GRID;
			button.defaultSkin = _local2;
			button.keepDownStateOnRollOut = true;
			button.hasLabelTextRenderer = false;
		}
		
		protected function setNumericStepperDecrementButtonStyles(button:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.stepperDecrementButtonUpSkinTexture);
			_local2.setTextureForState("hover",this.stepperDecrementButtonHoverSkinTexture);
			_local2.setTextureForState("down",this.stepperDecrementButtonDownSkinTexture);
			_local2.setTextureForState("disabled",this.stepperDecrementButtonDisabledSkinTexture);
			_local2.scale9Grid = STEPPER_DECREMENT_BUTTON_SCALE_9_GRID;
			button.defaultSkin = _local2;
			button.keepDownStateOnRollOut = true;
			button.hasLabelTextRenderer = false;
		}
		
		protected function setNumericStepperTextInputStyles(input:TextInput) : void {
			input.minWidth = this.controlSize;
			input.minHeight = this.controlSize;
			input.gap = this.extraSmallGutterSize;
			input.paddingTop = this.extraSmallGutterSize;
			input.paddingBottom = this.extraSmallGutterSize;
			input.paddingRight = this.smallGutterSize;
			input.paddingLeft = this.smallGutterSize;
			var _local2:ImageSkin = new ImageSkin(this.textInputBackgroundEnabledSkinTexture);
			_local2.disabledTexture = this.textInputBackgroundDisabledSkinTexture;
			_local2.scale9Grid = TEXT_INPUT_SCALE_9_GRID;
			_local2.width = this.controlSize;
			_local2.height = this.controlSize;
			input.backgroundSkin = _local2;
		}
		
		protected function setPanelScreenStyles(screen:PanelScreen) : void {
			this.setScrollerStyles(screen);
		}
		
		protected function setPageIndicatorStyles(pageIndicator:PageIndicator) : void {
			pageIndicator.interactionMode = "precise";
			pageIndicator.normalSymbolFactory = this.pageIndicatorNormalSymbolFactory;
			pageIndicator.selectedSymbolFactory = this.pageIndicatorSelectedSymbolFactory;
			pageIndicator.gap = this.gutterSize;
			pageIndicator.padding = this.smallGutterSize;
			pageIndicator.minWidth = this.controlSize;
			pageIndicator.minHeight = this.controlSize;
		}
		
		protected function setPanelStyles(panel:Panel) : void {
			this.setScrollerStyles(panel);
			var _local2:Image = new Image(this.panelBorderBackgroundSkinTexture);
			_local2.scale9Grid = PANEL_BORDER_SCALE_9_GRID;
			panel.backgroundSkin = _local2;
			panel.paddingTop = 0;
			panel.paddingRight = this.gutterSize;
			panel.paddingBottom = this.gutterSize;
			panel.paddingLeft = this.gutterSize;
		}
		
		protected function setPanelHeaderStyles(header:Header) : void {
			header.minHeight = this.gridSize;
			header.paddingTop = this.extraSmallGutterSize;
			header.paddingBottom = this.extraSmallGutterSize;
			header.paddingLeft = this.gutterSize;
			header.paddingRight = this.gutterSize;
			header.gap = this.extraSmallGutterSize;
			header.titleGap = this.smallGutterSize;
		}
		
		protected function setPickerListStyles(list:PickerList) : void {
			list.popUpContentManager = new DropDownPopUpContentManager();
		}
		
		protected function setPickerListButtonStyles(button:Button) : void {
			this.setButtonStyles(button);
			var _local2:ImageSkin = new ImageSkin(this.pickerListUpIconTexture);
			_local2.setTextureForState("hover",this.pickerListHoverIconTexture);
			_local2.setTextureForState("down",this.pickerListDownIconTexture);
			_local2.setTextureForState("disabled",this.pickerListDisabledIconTexture);
			button.defaultIcon = _local2;
			button.gap = Infinity;
			button.minGap = this.smallGutterSize;
			button.horizontalAlign = "left";
			button.iconPosition = "right";
			button.paddingRight = this.smallGutterSize;
		}
		
		protected function setProgressBarStyles(progress:ProgressBar) : void {
			var _local3:Image = new Image(this.simpleBorderBackgroundSkinTexture);
			_local3.scale9Grid = SIMPLE_BORDER_SCALE_9_GRID;
			if(progress.direction == "vertical") {
				_local3.height = this.wideControlSize;
			} else {
				_local3.width = this.wideControlSize;
			}
			progress.backgroundSkin = _local3;
			var _local2:Image = new Image(this.progressBarFillSkinTexture);
			if(progress.direction == "vertical") {
				_local2.height = 0;
			} else {
				_local2.width = 0;
			}
			progress.fillSkin = _local2;
			progress.padding = this.borderSize;
		}
		
		protected function setRadioStyles(radio:Radio) : void {
			var _local3:ImageSkin = new ImageSkin(this.radioUpIconTexture);
			_local3.selectedTexture = this.radioSelectedUpIconTexture;
			_local3.setTextureForState("hover",this.radioHoverIconTexture);
			_local3.setTextureForState("down",this.radioDownIconTexture);
			_local3.setTextureForState("disabled",this.radioDisabledIconTexture);
			_local3.setTextureForState("hoverAndSelected",this.radioSelectedHoverIconTexture);
			_local3.setTextureForState("downAndSelected",this.radioSelectedDownIconTexture);
			_local3.setTextureForState("disabledAndSelected",this.radioSelectedDisabledIconTexture);
			radio.defaultIcon = _local3;
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			radio.focusIndicatorSkin = _local2;
			radio.focusPadding = -2;
			radio.horizontalAlign = "left";
			radio.verticalAlign = "middle";
			radio.gap = this.smallGutterSize;
			radio.minWidth = this.controlSize;
			radio.minHeight = this.controlSize;
		}
		
		protected function setRadioLabelStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setHorizontalScrollBarStyles(scrollBar:ScrollBar) : void {
			scrollBar.trackLayoutMode = "single";
			scrollBar.customIncrementButtonStyleName = "aeon-horizontal-scroll-bar-increment-button";
			scrollBar.customDecrementButtonStyleName = "aeon-horizontal-scroll-bar-decrement-button";
			scrollBar.customThumbStyleName = "aeon-horizontal-scroll-bar-thumb";
			scrollBar.customMinimumTrackStyleName = "aeon-horizontal-scroll-bar-minimum-track";
		}
		
		protected function setVerticalScrollBarStyles(scrollBar:ScrollBar) : void {
			scrollBar.trackLayoutMode = "single";
			scrollBar.customIncrementButtonStyleName = "aeon-vertical-scroll-bar-increment-button";
			scrollBar.customDecrementButtonStyleName = "aeon-vertical-scroll-bar-decrement-button";
			scrollBar.customThumbStyleName = "aeon-vertical-scroll-bar-thumb";
			scrollBar.customMinimumTrackStyleName = "aeon-vertical-scroll-bar-minimum-track";
		}
		
		protected function setHorizontalScrollBarIncrementButtonStyles(button:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.hScrollBarStepButtonUpSkinTexture);
			_local2.setTextureForState("hover",this.hScrollBarStepButtonHoverSkinTexture);
			_local2.setTextureForState("down",this.hScrollBarStepButtonDownSkinTexture);
			_local2.setTextureForState("disabled",this.hScrollBarStepButtonDisabledSkinTexture);
			_local2.scale9Grid = HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID;
			button.defaultSkin = _local2;
			button.defaultIcon = new Image(this.hScrollBarIncrementButtonIconTexture);
			var _local3:Quad = new Quad(1,1,0xff00ff);
			_local3.alpha = 0;
			button.disabledIcon = _local3;
			button.hasLabelTextRenderer = false;
		}
		
		protected function setHorizontalScrollBarDecrementButtonStyles(button:Button) : void {
			var _local2:ImageSkin = new ImageSkin(hScrollBarStepButtonUpSkinTexture);
			_local2.setTextureForState("hover",this.hScrollBarStepButtonHoverSkinTexture);
			_local2.setTextureForState("down",this.hScrollBarStepButtonDownSkinTexture);
			_local2.setTextureForState("disabled",this.hScrollBarStepButtonDisabledSkinTexture);
			_local2.scale9Grid = HORIZONTAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID;
			button.defaultSkin = _local2;
			button.defaultIcon = new Image(this.hScrollBarDecrementButtonIconTexture);
			var _local3:Quad = new Quad(1,1,0xff00ff);
			_local3.alpha = 0;
			button.disabledIcon = _local3;
			button.hasLabelTextRenderer = false;
		}
		
		protected function setHorizontalScrollBarThumbStyles(thumb:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.hScrollBarThumbUpSkinTexture);
			_local2.setTextureForState("hover",this.hScrollBarThumbHoverSkinTexture);
			_local2.setTextureForState("down",this.hScrollBarThumbDownSkinTexture);
			_local2.scale9Grid = HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID;
			thumb.defaultSkin = _local2;
			thumb.defaultIcon = new Image(this.hScrollBarThumbIconTexture);
			thumb.verticalAlign = "middle";
			thumb.paddingBottom = this.extraSmallGutterSize;
			thumb.hasLabelTextRenderer = false;
		}
		
		protected function setHorizontalScrollBarMinimumTrackStyles(track:Button) : void {
			var _local2:Image = new Image(this.hScrollBarTrackSkinTexture);
			_local2.scale9Grid = HORIZONTAL_SCROLL_BAR_TRACK_SCALE_9_GRID;
			track.defaultSkin = _local2;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setVerticalScrollBarIncrementButtonStyles(button:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.vScrollBarStepButtonUpSkinTexture);
			_local2.setTextureForState("hover",this.vScrollBarStepButtonHoverSkinTexture);
			_local2.setTextureForState("down",this.vScrollBarStepButtonDownSkinTexture);
			_local2.setTextureForState("disabled",this.vScrollBarStepButtonDisabledSkinTexture);
			_local2.scale9Grid = VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID;
			button.defaultSkin = _local2;
			button.defaultIcon = new Image(this.vScrollBarIncrementButtonIconTexture);
			var _local3:Quad = new Quad(1,1,0xff00ff);
			_local3.alpha = 0;
			button.disabledIcon = _local3;
			button.hasLabelTextRenderer = false;
		}
		
		protected function setVerticalScrollBarDecrementButtonStyles(button:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.vScrollBarStepButtonUpSkinTexture);
			_local2.setTextureForState("hover",this.vScrollBarStepButtonHoverSkinTexture);
			_local2.setTextureForState("down",this.vScrollBarStepButtonDownSkinTexture);
			_local2.setTextureForState("disabled",this.vScrollBarStepButtonDisabledSkinTexture);
			_local2.scale9Grid = VERTICAL_SCROLL_BAR_STEP_BUTTON_SCALE_9_GRID;
			button.defaultSkin = _local2;
			button.defaultIcon = new Image(this.vScrollBarDecrementButtonIconTexture);
			var _local3:Quad = new Quad(1,1,0xff00ff);
			_local3.alpha = 0;
			button.disabledIcon = _local3;
			button.hasLabelTextRenderer = false;
		}
		
		protected function setVerticalScrollBarThumbStyles(thumb:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.vScrollBarThumbUpSkinTexture);
			_local2.setTextureForState("hover",this.vScrollBarThumbHoverSkinTexture);
			_local2.setTextureForState("down",this.vScrollBarThumbDownSkinTexture);
			_local2.scale9Grid = VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID;
			thumb.defaultSkin = _local2;
			thumb.defaultIcon = new Image(this.vScrollBarThumbIconTexture);
			thumb.horizontalAlign = "center";
			thumb.paddingRight = this.extraSmallGutterSize;
			thumb.hasLabelTextRenderer = false;
		}
		
		protected function setVerticalScrollBarMinimumTrackStyles(track:Button) : void {
			var _local2:Image = new Image(this.vScrollBarTrackSkinTexture);
			_local2.scale9Grid = VERTICAL_SCROLL_BAR_TRACK_SCALE_9_GRID;
			track.defaultSkin = _local2;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setScrollContainerStyles(container:ScrollContainer) : void {
			this.setScrollerStyles(container);
		}
		
		protected function setToolbarScrollContainerStyles(container:ScrollContainer) : void {
			var _local2:HorizontalLayout = null;
			this.setScrollerStyles(container);
			if(!container.layout) {
				_local2 = new HorizontalLayout();
				_local2.paddingTop = this.extraSmallGutterSize;
				_local2.paddingBottom = this.extraSmallGutterSize;
				_local2.paddingRight = this.smallGutterSize;
				_local2.paddingLeft = this.smallGutterSize;
				_local2.gap = this.extraSmallGutterSize;
				_local2.verticalAlign = "middle";
				container.layout = _local2;
			}
			var _local3:Image = new Image(this.headerBackgroundSkinTexture);
			_local3.scale9Grid = HEADER_SCALE_9_GRID;
			container.backgroundSkin = _local3;
			container.minHeight = this.gridSize;
		}
		
		protected function setScrollScreenStyles(screen:ScrollScreen) : void {
			this.setScrollerStyles(screen);
		}
		
		protected function setScrollTextStyles(text:ScrollText) : void {
			this.setScrollerStyles(text);
			text.textFormat = this.defaultTextFormat;
			text.disabledTextFormat = this.disabledTextFormat;
			text.padding = this.gutterSize;
		}
		
		protected function setHorizontalSimpleScrollBarStyles(scrollBar:SimpleScrollBar) : void {
			scrollBar.customThumbStyleName = "aeon-horizontal-simple-scroll-bar-thumb";
		}
		
		protected function setVerticalSimpleScrollBarStyles(scrollBar:SimpleScrollBar) : void {
			scrollBar.customThumbStyleName = "aeon-vertical-simple-scroll-bar-thumb";
		}
		
		protected function setHorizontalSimpleScrollBarThumbStyles(thumb:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.hScrollBarThumbUpSkinTexture);
			_local2.setTextureForState("hover",this.hScrollBarThumbHoverSkinTexture);
			_local2.setTextureForState("down",this.hScrollBarThumbDownSkinTexture);
			_local2.scale9Grid = HORIZONTAL_SCROLL_BAR_THUMB_SCALE_9_GRID;
			thumb.defaultSkin = _local2;
			thumb.defaultIcon = new Image(this.hScrollBarThumbIconTexture);
			thumb.verticalAlign = "top";
			thumb.paddingTop = this.smallGutterSize;
			thumb.hasLabelTextRenderer = false;
		}
		
		protected function setVerticalSimpleScrollBarThumbStyles(thumb:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.vScrollBarThumbUpSkinTexture);
			_local2.setTextureForState("hover",this.vScrollBarThumbHoverSkinTexture);
			_local2.setTextureForState("down",this.vScrollBarThumbDownSkinTexture);
			_local2.scale9Grid = VERTICAL_SCROLL_BAR_THUMB_SCALE_9_GRID;
			thumb.defaultSkin = _local2;
			thumb.defaultIcon = new Image(this.vScrollBarThumbIconTexture);
			thumb.horizontalAlign = "left";
			thumb.paddingLeft = this.smallGutterSize;
			thumb.hasLabelTextRenderer = false;
		}
		
		protected function setSliderStyles(slider:Slider) : void {
			slider.trackLayoutMode = "single";
			slider.minimumPadding = slider.maximumPadding = -vSliderThumbUpSkinTexture.height / 2;
			if(slider.direction == "vertical") {
				slider.customThumbStyleName = "aeon-vertical-slider-thumb";
				slider.customMinimumTrackStyleName = "aeon-vertical-slider-minimum-track";
				slider.focusPaddingLeft = slider.focusPaddingRight = -2;
				slider.focusPaddingTop = slider.focusPaddingBottom = -2 + slider.minimumPadding;
			} else {
				slider.customThumbStyleName = "aeon-horizontal-slider-thumb";
				slider.customMinimumTrackStyleName = "aeon-horizontal-slider-minimum-track";
				slider.focusPaddingTop = slider.focusPaddingBottom = -2;
				slider.focusPaddingLeft = slider.focusPaddingRight = -2 + slider.minimumPadding;
			}
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			slider.focusIndicatorSkin = _local2;
		}
		
		protected function setHorizontalSliderThumbStyles(thumb:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.hSliderThumbUpSkinTexture);
			_local2.setTextureForState("hover",this.hSliderThumbHoverSkinTexture);
			_local2.setTextureForState("down",this.hSliderThumbDownSkinTexture);
			_local2.setTextureForState("disabled",this.hSliderThumbDisabledSkinTexture);
			thumb.defaultSkin = _local2;
			thumb.hasLabelTextRenderer = false;
		}
		
		protected function setHorizontalSliderMinimumTrackStyles(track:Button) : void {
			var _local2:Image = new Image(this.hSliderTrackEnabledSkinTexture);
			_local2.scale9Grid = HORIZONTAL_SLIDER_TRACK_SCALE_9_GRID;
			_local2.width = this.wideControlSize;
			track.defaultSkin = _local2;
			track.minTouchHeight = this.controlSize;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setVerticalSliderThumbStyles(thumb:Button) : void {
			var _local2:ImageSkin = new ImageSkin(this.vSliderThumbUpSkinTexture);
			_local2.setTextureForState("hover",this.vSliderThumbHoverSkinTexture);
			_local2.setTextureForState("down",this.vSliderThumbDownSkinTexture);
			_local2.setTextureForState("disabled",this.vSliderThumbDisabledSkinTexture);
			thumb.defaultSkin = _local2;
			thumb.hasLabelTextRenderer = false;
		}
		
		protected function setVerticalSliderMinimumTrackStyles(track:Button) : void {
			var _local2:Image = new Image(this.vSliderTrackEnabledSkinTexture);
			_local2.scale9Grid = VERTICAL_SLIDER_TRACK_SCALE_9_GRID;
			_local2.height = this.wideControlSize;
			track.defaultSkin = _local2;
			track.minTouchWidth = this.controlSize;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setSpinnerListStyles(list:SpinnerList) : void {
			this.setListStyles(list);
		}
		
		protected function setTabBarStyles(tabBar:TabBar) : void {
			tabBar.distributeTabSizes = false;
			tabBar.horizontalAlign = "left";
			tabBar.verticalAlign = "justify";
		}
		
		protected function setTabStyles(tab:ToggleButton) : void {
			var _local3:ImageSkin = new ImageSkin(this.tabUpSkinTexture);
			_local3.selectedTexture = this.tabSelectedUpSkinTexture;
			_local3.setTextureForState("hover",this.tabHoverSkinTexture);
			_local3.setTextureForState("down",this.tabDownSkinTexture);
			_local3.setTextureForState("disabled",this.tabDisabledSkinTexture);
			_local3.setTextureForState("disabledAndSelected",this.tabSelectedDisabledSkinTexture);
			_local3.scale9Grid = TAB_SCALE_9_GRID;
			tab.defaultSkin = _local3;
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			tab.focusIndicatorSkin = _local2;
			tab.paddingTop = this.extraSmallGutterSize;
			tab.paddingBottom = this.extraSmallGutterSize;
			tab.paddingLeft = this.smallGutterSize;
			tab.paddingRight = this.smallGutterSize;
			tab.gap = this.extraSmallGutterSize;
			tab.minWidth = this.buttonMinWidth;
			tab.minHeight = this.controlSize;
		}
		
		protected function setTextAreaStyles(textArea:TextArea) : void {
			this.setScrollerStyles(textArea);
			textArea.focusPadding = -2;
			textArea.padding = this.borderSize;
			var _local2:ImageSkin = new ImageSkin(this.textInputBackgroundEnabledSkinTexture);
			_local2.disabledTexture = this.textInputBackgroundDisabledSkinTexture;
			_local2.setTextureForState("error",this.textInputBackgroundErrorSkinTexture);
			_local2.scale9Grid = TEXT_INPUT_SCALE_9_GRID;
			_local2.width = this.wideControlSize * 2;
			_local2.height = this.wideControlSize;
			textArea.backgroundSkin = _local2;
		}
		
		protected function setTextAreaTextEditorStyles(textEditor:TextFieldTextEditorViewPort) : void {
			textEditor.textFormat = this.defaultTextFormat;
			textEditor.disabledTextFormat = this.disabledTextFormat;
			textEditor.paddingTop = this.extraSmallGutterSize;
			textEditor.paddingRight = this.smallGutterSize;
			textEditor.paddingBottom = this.extraSmallGutterSize;
			textEditor.paddingLeft = this.smallGutterSize;
		}
		
		protected function setTextAreaErrorCalloutStyles(callout:TextCallout) : void {
			this.setDangerTextCalloutStyles(callout);
			callout.verticalAlign = "top";
			callout.horizontalAlign = "left";
			callout.supportedPositions = new <String>["right","top","bottom","left"];
		}
		
		protected function setTextCalloutStyles(callout:TextCallout) : void {
			this.setCalloutStyles(callout);
		}
		
		protected function setTextCalloutTextRendererStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
		}
		
		protected function setDangerTextCalloutStyles(callout:TextCallout) : void {
			this.setDangerCalloutStyles(callout);
			callout.customTextRendererStyleName = "aeon-danger-text-callout-text-renderer";
		}
		
		protected function setDangerTextCalloutTextRendererStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.invertedTextFormat;
		}
		
		protected function setBaseTextInputStyles(input:TextInput) : void {
			var _local3:ImageSkin = new ImageSkin(this.textInputBackgroundEnabledSkinTexture);
			_local3.disabledTexture = this.textInputBackgroundDisabledSkinTexture;
			_local3.setTextureForState("error",this.textInputBackgroundErrorSkinTexture);
			_local3.scale9Grid = TEXT_INPUT_SCALE_9_GRID;
			_local3.width = this.wideControlSize;
			_local3.height = this.controlSize;
			input.backgroundSkin = _local3;
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			input.focusIndicatorSkin = _local2;
			input.focusPadding = -2;
			input.minWidth = this.controlSize;
			input.minHeight = this.controlSize;
			input.gap = this.extraSmallGutterSize;
			input.paddingTop = this.extraSmallGutterSize;
			input.paddingBottom = this.extraSmallGutterSize;
			input.paddingRight = this.smallGutterSize;
			input.paddingLeft = this.smallGutterSize;
		}
		
		protected function setTextInputStyles(input:TextInput) : void {
			this.setBaseTextInputStyles(input);
		}
		
		protected function setSearchTextInputStyles(input:TextInput) : void {
			this.setBaseTextInputStyles(input);
			var _local2:ImageSkin = new ImageSkin(this.textInputSearchIconTexture);
			_local2.disabledTexture = this.textInputSearchIconDisabledTexture;
			input.defaultIcon = _local2;
		}
		
		protected function setTextInputTextEditorStyles(textEditor:TextFieldTextEditor) : void {
			textEditor.textFormat = this.defaultTextFormat;
			textEditor.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setTextInputPromptStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setTextInputErrorCalloutStyles(callout:TextCallout) : void {
			this.setDangerTextCalloutStyles(callout);
			callout.verticalAlign = "top";
			callout.horizontalAlign = "left";
			callout.supportedPositions = new <String>["right","top","bottom","left"];
		}
		
		protected function setToggleSwitchStyles(toggle:ToggleSwitch) : void {
			toggle.trackLayoutMode = "single";
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			toggle.focusIndicatorSkin = _local2;
			toggle.focusPadding = -1;
		}
		
		protected function setToggleSwitchOnLabelStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setToggleSwitchOffLabelStyles(textRenderer:TextFieldTextRenderer) : void {
			textRenderer.textFormat = this.defaultTextFormat;
			textRenderer.disabledTextFormat = this.disabledTextFormat;
		}
		
		protected function setToggleSwitchOnTrackStyles(track:Button) : void {
			var _local2:Image = new Image(this.toggleButtonSelectedUpSkinTexture);
			_local2.scale9Grid = BUTTON_SCALE_9_GRID;
			_local2.width = 2 * this.controlSize + this.smallControlSize;
			track.defaultSkin = _local2;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setToggleSwitchThumbStyles(thumb:Button) : void {
			this.setButtonStyles(thumb);
			thumb.width = this.controlSize;
			thumb.height = this.controlSize;
			thumb.hasLabelTextRenderer = false;
		}
		
		protected function setPlayPauseToggleButtonStyles(button:PlayPauseToggleButton) : void {
			var _local4:Quad = new Quad(this.controlSize,this.controlSize,0xff00ff);
			_local4.alpha = 0;
			button.defaultSkin = _local4;
			var _local5:ImageSkin = new ImageSkin(null);
			_local5.setTextureForState("hover",this.quietButtonHoverSkinTexture);
			_local5.setTextureForState("down",this.buttonDownSkinTexture);
			_local5.setTextureForState("hoverAndSelected",this.toggleButtonSelectedHoverSkinTexture);
			_local5.setTextureForState("downAndSelected",this.toggleButtonSelectedDownSkinTexture);
			_local5.setTextureForState("disabledAndSelected",this.toggleButtonSelectedDisabledSkinTexture);
			_local5.width = this.controlSize;
			_local5.height = this.controlSize;
			button.setSkinForState("hover",_local5);
			button.setSkinForState("down",_local5);
			button.setSkinForState("hoverAndSelected",_local5);
			button.setSkinForState("downAndSelected",_local5);
			button.setSkinForState("disabledAndSelected",_local5);
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			button.focusIndicatorSkin = _local2;
			button.focusPadding = -1;
			var _local3:ImageSkin = new ImageSkin(this.playPauseButtonPlayUpIconTexture);
			_local3.selectedTexture = this.playPauseButtonPauseUpIconTexture;
			button.defaultIcon = _local3;
			button.hasLabelTextRenderer = false;
			button.paddingTop = this.extraSmallGutterSize;
			button.paddingRight = this.smallGutterSize;
			button.paddingBottom = this.extraSmallGutterSize;
			button.paddingLeft = this.smallGutterSize;
			button.gap = this.smallGutterSize;
			button.minWidth = this.controlSize;
			button.minHeight = this.controlSize;
		}
		
		protected function setOverlayPlayPauseToggleButtonStyles(button:PlayPauseToggleButton) : void {
			var _local2:ImageSkin = new ImageSkin(null);
			_local2.setTextureForState("up",this.overlayPlayPauseButtonPlayUpIconTexture);
			_local2.setTextureForState("hover",this.overlayPlayPauseButtonPlayUpIconTexture);
			_local2.setTextureForState("down",this.overlayPlayPauseButtonPlayUpIconTexture);
			button.defaultIcon = _local2;
			button.isFocusEnabled = false;
			button.hasLabelTextRenderer = false;
			var _local3:Quad = new Quad(1,1,13230318);
			_local3.alpha = 0.25;
			button.upSkin = _local3;
			button.hoverSkin = _local3;
		}
		
		protected function setFullScreenToggleButtonStyles(button:FullScreenToggleButton) : void {
			var _local4:Quad = new Quad(this.controlSize,this.controlSize,0xff00ff);
			_local4.alpha = 0;
			button.defaultSkin = _local4;
			var _local5:ImageSkin = new ImageSkin(null);
			_local5.setTextureForState("hover",this.quietButtonHoverSkinTexture);
			_local5.setTextureForState("down",this.buttonDownSkinTexture);
			_local5.setTextureForState("hoverAndSelected",this.toggleButtonSelectedHoverSkinTexture);
			_local5.setTextureForState("downAndSelected",this.toggleButtonSelectedDownSkinTexture);
			_local5.setTextureForState("disabledAndSelected",this.toggleButtonSelectedDisabledSkinTexture);
			_local5.width = this.controlSize;
			_local5.height = this.controlSize;
			button.setSkinForState("hover",_local5);
			button.setSkinForState("down",_local5);
			button.setSkinForState("hoverAndSelected",_local5);
			button.setSkinForState("downAndSelected",_local5);
			button.setSkinForState("disabledAndSelected",_local5);
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			button.focusIndicatorSkin = _local2;
			button.focusPadding = -1;
			var _local3:ImageSkin = new ImageSkin(this.fullScreenToggleButtonEnterUpIconTexture);
			_local3.selectedTexture = this.fullScreenToggleButtonExitUpIconTexture;
			button.defaultIcon = _local3;
			button.hasLabelTextRenderer = false;
			button.paddingTop = this.extraSmallGutterSize;
			button.paddingRight = this.smallGutterSize;
			button.paddingBottom = this.extraSmallGutterSize;
			button.paddingLeft = this.smallGutterSize;
			button.gap = this.smallGutterSize;
			button.minWidth = this.controlSize;
			button.minHeight = this.controlSize;
		}
		
		protected function setVolumeSliderStyles(slider:VolumeSlider) : void {
			slider.trackLayoutMode = "split";
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			slider.focusIndicatorSkin = _local2;
			slider.focusPadding = -1;
			slider.showThumb = false;
			if(slider.direction == "vertical") {
				slider.customMinimumTrackStyleName = "aeon-vertical-volume-slider-minimum-track";
				slider.customMaximumTrackStyleName = "aeon-vertical-volume-slider-maximum-track";
				slider.width = this.verticalVolumeSliderMinimumTrackSkinTexture.width;
				slider.height = this.verticalVolumeSliderMinimumTrackSkinTexture.height;
			} else {
				slider.customMinimumTrackStyleName = "aeon-horizontal-volume-slider-minimum-track";
				slider.customMaximumTrackStyleName = "aeon-horizontal-volume-slider-maximum-track";
				slider.width = this.horizontalVolumeSliderMinimumTrackSkinTexture.width;
				slider.height = this.horizontalVolumeSliderMinimumTrackSkinTexture.height;
			}
		}
		
		protected function setVolumeSliderThumbStyles(button:Button) : void {
			var _local2:Number = 6;
			button.defaultSkin = new Quad(_local2,_local2);
			button.defaultSkin.width = 0;
			button.defaultSkin.height = 0;
			button.hasLabelTextRenderer = false;
		}
		
		protected function setHorizontalVolumeSliderMinimumTrackStyles(track:Button) : void {
			var _local2:ImageLoader = new ImageLoader();
			_local2.scaleContent = false;
			_local2.source = this.horizontalVolumeSliderMinimumTrackSkinTexture;
			track.defaultSkin = _local2;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setHorizontalVolumeSliderMaximumTrackStyles(track:Button) : void {
			var _local2:ImageLoader = new ImageLoader();
			_local2.scaleContent = false;
			_local2.horizontalAlign = "right";
			_local2.source = this.horizontalVolumeSliderMaximumTrackSkinTexture;
			track.defaultSkin = _local2;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setVerticalVolumeSliderMinimumTrackStyles(track:Button) : void {
			var _local2:ImageLoader = new ImageLoader();
			_local2.scaleContent = false;
			_local2.verticalAlign = "bottom";
			_local2.source = this.verticalVolumeSliderMinimumTrackSkinTexture;
			track.defaultSkin = _local2;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setVerticalVolumeSliderMaximumTrackStyles(track:Button) : void {
			var _local2:ImageLoader = new ImageLoader();
			_local2.scaleContent = false;
			_local2.source = this.verticalVolumeSliderMaximumTrackSkinTexture;
			track.defaultSkin = _local2;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setMuteToggleButtonStyles(button:MuteToggleButton) : void {
			var _local4:Quad = new Quad(this.controlSize,this.controlSize,0xff00ff);
			_local4.alpha = 0;
			button.defaultSkin = _local4;
			var _local5:ImageSkin = new ImageSkin(null);
			_local5.setTextureForState("hover",this.quietButtonHoverSkinTexture);
			_local5.setTextureForState("down",this.buttonDownSkinTexture);
			_local5.setTextureForState("hoverAndSelected",this.toggleButtonSelectedHoverSkinTexture);
			_local5.setTextureForState("downAndSelected",this.toggleButtonSelectedDownSkinTexture);
			_local5.setTextureForState("disabledAndSelected",this.toggleButtonSelectedDisabledSkinTexture);
			_local5.width = this.controlSize;
			_local5.height = this.controlSize;
			button.setSkinForState("hover",_local5);
			button.setSkinForState("down",_local5);
			button.setSkinForState("hoverAndSelected",_local5);
			button.setSkinForState("downAndSelected",_local5);
			button.setSkinForState("disabledAndSelected",_local5);
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			button.focusIndicatorSkin = _local2;
			button.focusPadding = -1;
			var _local3:ImageSkin = new ImageSkin(this.muteToggleButtonLoudUpIconTexture);
			_local3.selectedTexture = this.muteToggleButtonMutedUpIconTexture;
			button.defaultIcon = _local3;
			button.showVolumeSliderOnHover = true;
			button.hasLabelTextRenderer = false;
			button.paddingTop = this.extraSmallGutterSize;
			button.paddingRight = this.smallGutterSize;
			button.paddingBottom = this.extraSmallGutterSize;
			button.paddingLeft = this.smallGutterSize;
			button.gap = this.smallGutterSize;
			button.minWidth = this.controlSize;
			button.minHeight = this.controlSize;
		}
		
		protected function setPopUpVolumeSliderStyles(slider:VolumeSlider) : void {
			slider.direction = "vertical";
			slider.trackLayoutMode = "split";
			slider.showThumb = false;
			var _local2:Image = new Image(this.focusIndicatorSkinTexture);
			_local2.scale9Grid = FOCUS_INDICATOR_SCALE_9_GRID;
			slider.focusIndicatorSkin = _local2;
			slider.focusPadding = 4;
			slider.width = this.popUpVolumeSliderMinimumTrackSkinTexture.width;
			slider.height = this.popUpVolumeSliderMinimumTrackSkinTexture.height;
			slider.minimumPadding = this.popUpVolumeSliderPaddingSize;
			slider.maximumPadding = this.popUpVolumeSliderPaddingSize;
			slider.customMinimumTrackStyleName = "aeon-pop-up-volume-slider-minimum-track";
			slider.customMaximumTrackStyleName = "aeon-pop-up-volume-slider-maximum-track";
		}
		
		protected function setPopUpVolumeSliderMinimumTrackStyles(track:Button) : void {
			var _local2:ImageLoader = new ImageLoader();
			_local2.scaleContent = false;
			_local2.verticalAlign = "bottom";
			_local2.source = this.popUpVolumeSliderMinimumTrackSkinTexture;
			track.defaultSkin = _local2;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setPopUpVolumeSliderMaximumTrackStyles(track:Button) : void {
			var _local2:ImageLoader = new ImageLoader();
			_local2.scaleContent = false;
			_local2.source = this.popUpVolumeSliderMaximumTrackSkinTexture;
			track.defaultSkin = _local2;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setSeekSliderStyles(slider:SeekSlider) : void {
			slider.direction = "horizontal";
			slider.trackLayoutMode = "split";
			slider.minimumPadding = slider.maximumPadding = -this.vSliderThumbUpSkinTexture.height / 2;
			slider.focusPaddingTop = slider.focusPaddingBottom = -2;
			slider.focusPaddingLeft = slider.focusPaddingRight = -2 + slider.minimumPadding;
			slider.minWidth = this.wideControlSize;
			slider.minHeight = this.smallControlSize;
			var _local2:Image = new Image(this.seekSliderProgressSkinTexture);
			_local2.scale9Grid = SEEK_SLIDER_MAXIMUM_TRACK_SCALE_9_GRID;
			_local2.width = this.smallControlSize;
			slider.progressSkin = _local2;
		}
		
		protected function setSeekSliderMinimumTrackStyles(track:Button) : void {
			var _local2:Image = new Image(this.seekSliderMinimumTrackSkinTexture);
			_local2.scale9Grid = SEEK_SLIDER_MINIMUM_TRACK_SCALE_9_GRID;
			_local2.width = this.wideControlSize;
			track.defaultSkin = _local2;
			track.minTouchHeight = this.controlSize;
			track.hasLabelTextRenderer = false;
		}
		
		protected function setSeekSliderMaximumTrackStyles(track:Button) : void {
			var _local2:Image = new Image(this.seekSliderMaximumTrackSkinTexture);
			_local2.scale9Grid = SEEK_SLIDER_MAXIMUM_TRACK_SCALE_9_GRID;
			_local2.width = this.wideControlSize;
			track.defaultSkin = _local2;
			track.minTouchHeight = this.controlSize;
			track.hasLabelTextRenderer = false;
		}
	}
}

