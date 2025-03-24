package feathers.controls {
	import feathers.core.FeathersControl;
	import feathers.core.ITextRenderer;
	import feathers.core.IToolTip;
	import feathers.core.PopUpManager;
	import feathers.skins.IStyleProvider;
	import starling.display.DisplayObject;
	import starling.events.EnterFrameEvent;
	
	public class TextCallout extends Callout implements IToolTip {
		public static const DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER:String = "feathers-text-callout-text-renderer";
		
		public static var globalStyleProvider:IStyleProvider;
		
		public static var calloutFactory:Function = defaultCalloutFactory;
		
		protected var textRenderer:ITextRenderer;
		
		protected var textRendererStyleName:String = "feathers-text-callout-text-renderer";
		
		protected var _text:String;
		
		protected var _wordWrap:Boolean = true;
		
		protected var _textRendererFactory:Function;
		
		protected var _customTextRendererStyleName:String;
		
		public function TextCallout() {
			super();
			this.isQuickHitAreaEnabled = true;
		}
		
		public static function defaultCalloutFactory() : TextCallout {
			var _local1:TextCallout = new TextCallout();
			_local1.closeOnTouchBeganOutside = true;
			_local1.closeOnTouchEndedOutside = true;
			_local1.closeOnKeys = new <uint>[16777238,27];
			return _local1;
		}
		
		public static function show(text:String, origin:DisplayObject, supportedPositions:Vector.<String> = null, isModal:Boolean = true, customCalloutFactory:Function = null, customOverlayFactory:Function = null) : TextCallout {
			if(!origin.stage) {
				throw new ArgumentError("TextCallout origin must be added to the stage.");
			}
			var _local7:* = customCalloutFactory;
			if(_local7 === null) {
				_local7 = calloutFactory;
				if(_local7 === null) {
					_local7 = defaultCalloutFactory;
				}
			}
			var _local8:TextCallout = TextCallout(_local7());
			_local8.text = text;
			_local8.supportedPositions = supportedPositions;
			_local8.origin = origin;
			_local7 = customOverlayFactory;
			if(_local7 == null) {
				_local7 = calloutOverlayFactory;
				if(_local7 == null) {
					_local7 = PopUpManager.defaultOverlayFactory;
				}
			}
			PopUpManager.addPopUp(_local8,isModal,false,_local7);
			_local8.validate();
			return _local8;
		}
		
		public function get text() : String {
			return this._text;
		}
		
		public function set text(value:String) : void {
			if(this._text === value) {
				return;
			}
			this._text = value;
			this.invalidate("data");
		}
		
		public function get wordWrap() : Boolean {
			return this._wordWrap;
		}
		
		public function set wordWrap(value:Boolean) : void {
			if(this._wordWrap == value) {
				return;
			}
			this._wordWrap = value;
			this.invalidate("styles");
		}
		
		public function get textRendererFactory() : Function {
			return this._textRendererFactory;
		}
		
		public function set textRendererFactory(value:Function) : void {
			if(this._textRendererFactory == value) {
				return;
			}
			this._textRendererFactory = value;
			this.invalidate("textRenderer");
		}
		
		public function get customTextRendererStyleName() : String {
			return this._customTextRendererStyleName;
		}
		
		public function set customTextRendererStyleName(value:String) : void {
			if(this._customTextRendererStyleName == value) {
				return;
			}
			this._customTextRendererStyleName = value;
			this.invalidate("textRenderer");
		}
		
		override protected function get defaultStyleProvider() : IStyleProvider {
			if(TextCallout.globalStyleProvider !== null) {
				return TextCallout.globalStyleProvider;
			}
			return Callout.globalStyleProvider;
		}
		
		override protected function draw() : void {
			var _local3:Boolean = this.isInvalid("data");
			var _local1:Boolean = this.isInvalid("state");
			var _local4:Boolean = this.isInvalid("styles");
			var _local2:Boolean = this.isInvalid("textRenderer");
			if(_local2) {
				this.createTextRenderer();
			}
			if(_local2 || _local3 || _local1) {
				this.refreshTextRendererData();
			}
			if(_local2 || _local4) {
				this.refreshTextRendererStyles();
			}
			super.draw();
		}
		
		protected function createTextRenderer() : void {
			if(this.textRenderer !== null) {
				this.removeChild(DisplayObject(this.textRenderer),true);
				this.textRenderer = null;
			}
			var _local1:Function = this._textRendererFactory != null ? this._textRendererFactory : FeathersControl.defaultTextRendererFactory;
			this.textRenderer = ITextRenderer(_local1());
			var _local2:String = this._customTextRendererStyleName !== null ? this._customTextRendererStyleName : this.textRendererStyleName;
			this.textRenderer.styleNameList.add(_local2);
			this.content = DisplayObject(this.textRenderer);
		}
		
		protected function refreshTextRendererData() : void {
			this.textRenderer.text = this._text;
			this.textRenderer.visible = this._text && this._text.length > 0;
		}
		
		protected function refreshTextRendererStyles() : void {
			this.textRenderer.wordWrap = this._wordWrap;
		}
		
		override protected function callout_enterFrameHandler(event:EnterFrameEvent) : void {
			if(this.isCreated) {
				this.positionRelativeToOrigin();
			}
		}
	}
}

