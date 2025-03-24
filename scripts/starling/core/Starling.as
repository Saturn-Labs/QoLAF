package starling.core {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import starling.animation.Juggler;
	import starling.display.DisplayObject;
	import starling.display.Stage;
	import starling.events.EventDispatcher;
	import starling.events.KeyboardEvent;
	import starling.events.ResizeEvent;
	import starling.events.TouchProcessor;
	import starling.rendering.Painter;
	import starling.utils.RectangleUtil;
	import starling.utils.SystemUtil;
	
	public class Starling extends EventDispatcher {
		public static const VERSION:String = "2.1.1";
		
		private static var sCurrent:Starling;
		
		private static var sAll:Vector.<Starling> = new Vector.<Starling>(0);
		
		private var _stage:starling.display.Stage;
		
		private var _rootClass:Class;
		
		private var _root:DisplayObject;
		
		private var _juggler:Juggler;
		
		private var _painter:Painter;
		
		private var _touchProcessor:TouchProcessor;
		
		private var _antiAliasing:int;
		
		private var _frameTimestamp:Number;
		
		private var _frameID:uint;
		
		private var _leftMouseDown:Boolean;
		
		private var _statsDisplay:StatsDisplay;
		
		private var _started:Boolean;
		
		private var _rendering:Boolean;
		
		private var _supportHighResolutions:Boolean;
		
		private var _skipUnchangedFrames:Boolean;
		
		private var _showStats:Boolean;
		
		private var _viewPort:Rectangle;
		
		private var _previousViewPort:Rectangle;
		
		private var _clippedViewPort:Rectangle;
		
		private var _nativeStage:flash.display.Stage;
		
		private var _nativeStageEmpty:Boolean;
		
		private var _nativeOverlay:Sprite;
		
		public function Starling(rootClass:Class, stage:flash.display.Stage, viewPort:Rectangle = null, stage3D:Stage3D = null, renderMode:String = "auto", profile:Object = "auto") {
			super();
			if(stage == null) {
				throw new ArgumentError("Stage must not be null");
			}
			if(viewPort == null) {
				viewPort = new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
			}
			if(stage3D == null) {
				stage3D = stage.stage3Ds[0];
			}
			SystemUtil.initialize();
			sAll.push(this);
			makeCurrent();
			_rootClass = rootClass;
			_viewPort = viewPort;
			_previousViewPort = new Rectangle();
			_stage = new starling.display.Stage(viewPort.width,viewPort.height,stage.color);
			_nativeOverlay = new Sprite();
			_nativeStage = stage;
			_nativeStage.addChild(_nativeOverlay);
			_touchProcessor = new TouchProcessor(_stage);
			_juggler = new Juggler();
			_antiAliasing = 0;
			_supportHighResolutions = false;
			_painter = new Painter(stage3D);
			_frameTimestamp = getTimer() / 1000;
			_frameID = 1;
			stage.scaleMode = "noScale";
			stage.align = "TL";
			for each(var _local7 in touchEventTypes) {
				stage.addEventListener(_local7,onTouch,false,0,true);
			}
			stage.addEventListener("enterFrame",onEnterFrame,false,0,true);
			stage.addEventListener("keyDown",onKey,false,0,true);
			stage.addEventListener("keyUp",onKey,false,0,true);
			stage.addEventListener("resize",onResize,false,0,true);
			stage.addEventListener("mouseLeave",onMouseLeave,false,0,true);
			stage3D.addEventListener("context3DCreate",onContextCreated,false,10,true);
			stage3D.addEventListener("error",onStage3DError,false,10,true);
			if(_painter.shareContext) {
				setTimeout(initialize,1);
			} else {
				_painter.requestContext3D(renderMode,profile);
			}
		}
		
		public static function get current() : Starling {
			return sCurrent;
		}
		
		public static function get all() : Vector.<Starling> {
			return sAll;
		}
		
		public static function get context() : Context3D {
			return !!sCurrent ? sCurrent.context : null;
		}
		
		public static function get juggler() : Juggler {
			return !!sCurrent ? sCurrent._juggler : null;
		}
		
		public static function get painter() : Painter {
			return !!sCurrent ? sCurrent._painter : null;
		}
		
		public static function get contentScaleFactor() : Number {
			return !!sCurrent ? sCurrent.contentScaleFactor : 1;
		}
		
		public static function get multitouchEnabled() : Boolean {
			return Multitouch.inputMode == "touchPoint";
		}
		
		public static function set multitouchEnabled(value:Boolean) : void {
			if(sCurrent) {
				throw new IllegalOperationError("\'multitouchEnabled\' must be set before Starling instance is created");
			}
			Multitouch.inputMode = value ? "touchPoint" : "none";
		}
		
		public static function get frameID() : uint {
			return !!sCurrent ? sCurrent._frameID : 0;
		}
		
		public function dispose() : void {
			stop(true);
			_nativeStage.removeEventListener("enterFrame",onEnterFrame,false);
			_nativeStage.removeEventListener("keyDown",onKey,false);
			_nativeStage.removeEventListener("keyUp",onKey,false);
			_nativeStage.removeEventListener("resize",onResize,false);
			_nativeStage.removeEventListener("mouseLeave",onMouseLeave,false);
			_nativeStage.removeChild(_nativeOverlay);
			stage3D.removeEventListener("context3DCreate",onContextCreated,false);
			stage3D.removeEventListener("context3DCreate",onContextRestored,false);
			stage3D.removeEventListener("error",onStage3DError,false);
			for each(var _local2 in touchEventTypes) {
				_nativeStage.removeEventListener(_local2,onTouch,false);
			}
			_touchProcessor.dispose();
			_painter.dispose();
			_stage.dispose();
			var _local1:int = int(sAll.indexOf(this));
			if(_local1 != -1) {
				sAll.removeAt(_local1);
			}
			if(sCurrent == this) {
				sCurrent = null;
			}
		}
		
		private function initialize() : void {
			makeCurrent();
			updateViewPort(true);
			dispatchEventWith("context3DCreate",false,context);
			initializeRoot();
			_frameTimestamp = getTimer() / 1000;
		}
		
		private function initializeRoot() : void {
			if(_root == null && _rootClass != null) {
				_root = new _rootClass() as DisplayObject;
				if(_root == null) {
					throw new Error("Invalid root class: " + _rootClass);
				}
				_stage.addChildAt(_root,0);
				dispatchEventWith("rootCreated",false,_root);
			}
		}
		
		public function nextFrame() : void {
			var _local1:Number = getTimer() / 1000;
			var _local2:Number = _local1 - _frameTimestamp;
			_frameTimestamp = _local1;
			if(_local2 > 1) {
				_local2 = 1;
			}
			if(_local2 < 0) {
				_local2 = 1 / _nativeStage.frameRate;
			}
			advanceTime(_local2);
			render();
		}
		
		public function advanceTime(passedTime:Number) : void {
			if(!contextValid) {
				return;
			}
			makeCurrent();
			_touchProcessor.advanceTime(passedTime);
			_stage.advanceTime(passedTime);
			_juggler.advanceTime(passedTime);
		}
		
		public function render() : void {
			var _local4:Boolean = false;
			var _local1:Number = NaN;
			var _local2:Number = NaN;
			if(!contextValid) {
				return;
			}
			makeCurrent();
			updateViewPort();
			var _local3:Boolean = _stage.requiresRedraw || mustAlwaysRender;
			if(_local3) {
				dispatchEventWith("render");
				_local4 = _painter.shareContext;
				_local1 = _viewPort.width / _stage.stageWidth;
				_local2 = _viewPort.height / _stage.stageHeight;
				_painter.nextFrame();
				_painter.pixelSize = 1 / contentScaleFactor;
				_painter.state.setProjectionMatrix(_viewPort.x < 0 ? -_viewPort.x / _local1 : 0,_viewPort.y < 0 ? -_viewPort.y / _local2 : 0,_clippedViewPort.width / _local1,_clippedViewPort.height / _local2,_stage.stageWidth,_stage.stageHeight,_stage.cameraPosition);
				if(!_local4) {
					_painter.clear(_stage.color,0);
				}
				_stage.render(_painter);
				_painter.finishFrame();
				_painter.frameID = ++_frameID;
				if(!_local4) {
					_painter.present();
				}
			}
			if(_statsDisplay) {
				_statsDisplay.drawCount = _painter.drawCount;
				if(!_local3) {
					_statsDisplay.markFrameAsSkipped();
				}
			}
		}
		
		private function updateViewPort(forceUpdate:Boolean = false) : void {
			var _local2:Number = NaN;
			if(forceUpdate || !RectangleUtil.compare(_viewPort,_previousViewPort)) {
				_previousViewPort.setTo(_viewPort.x,_viewPort.y,_viewPort.width,_viewPort.height);
				_clippedViewPort = _viewPort.intersection(new Rectangle(0,0,_nativeStage.stageWidth,_nativeStage.stageHeight));
				if(_clippedViewPort.width < 32) {
					_clippedViewPort.width = 32;
				}
				if(_clippedViewPort.height < 32) {
					_clippedViewPort.height = 32;
				}
				_local2 = _supportHighResolutions ? _nativeStage.contentsScaleFactor : 1;
				_painter.configureBackBuffer(_clippedViewPort,_local2,_antiAliasing,true);
			}
		}
		
		private function updateNativeOverlay() : void {
			_nativeOverlay.x = _viewPort.x;
			_nativeOverlay.y = _viewPort.y;
			_nativeOverlay.scaleX = _viewPort.width / _stage.stageWidth;
			_nativeOverlay.scaleY = _viewPort.height / _stage.stageHeight;
		}
		
		public function stopWithFatalError(message:String) : void {
			var _local2:Shape = new Shape();
			_local2.graphics.beginFill(0,0.8);
			_local2.graphics.drawRect(0,0,_stage.stageWidth,_stage.stageHeight);
			_local2.graphics.endFill();
			var _local3:TextField = new TextField();
			var _local4:TextFormat = new TextFormat("Verdana",14,0xffffff);
			_local4.align = "center";
			_local3.defaultTextFormat = _local4;
			_local3.wordWrap = true;
			_local3.width = _stage.stageWidth * 0.75;
			_local3.autoSize = "center";
			_local3.text = message;
			_local3.x = (_stage.stageWidth - _local3.width) / 2;
			_local3.y = (_stage.stageHeight - _local3.height) / 2;
			_local3.background = true;
			_local3.backgroundColor = 0x550000;
			updateNativeOverlay();
			nativeOverlay.addChild(_local2);
			nativeOverlay.addChild(_local3);
			stop(true);
			trace("[Starling]",message);
			dispatchEventWith("fatalError",false,message);
		}
		
		public function makeCurrent() : void {
			sCurrent = this;
		}
		
		public function start() : void {
			_started = _rendering = true;
			_frameTimestamp = getTimer() / 1000;
			setTimeout(setRequiresRedraw,100);
		}
		
		public function stop(suspendRendering:Boolean = false) : void {
			_started = false;
			_rendering = !suspendRendering;
		}
		
		public function setRequiresRedraw() : void {
			_stage.setRequiresRedraw();
		}
		
		private function onStage3DError(event:ErrorEvent) : void {
			var _local2:String = null;
			if(event.errorID == 3702) {
				_local2 = Capabilities.playerType == "Desktop" ? "renderMode" : "wmode";
				stopWithFatalError("Context3D not available! Possible reasons: wrong " + _local2 + " or missing device support.");
			} else {
				stopWithFatalError("Stage3D error: " + event.text);
			}
		}
		
		private function onContextCreated(event:Event) : void {
			stage3D.removeEventListener("context3DCreate",onContextCreated);
			stage3D.addEventListener("context3DCreate",onContextRestored,false,10,true);
			trace("[Starling] Context ready. Display Driver:",context.driverInfo);
			initialize();
		}
		
		private function onContextRestored(event:Event) : void {
			trace("[Starling] Context restored.");
			updateViewPort(true);
			dispatchEventWith("context3DCreate",false,context);
		}
		
		private function onEnterFrame(event:Event) : void {
			if(!shareContext) {
				if(_started) {
					nextFrame();
				} else if(_rendering) {
					render();
				}
			}
			updateNativeOverlay();
		}
		
		private function onKey(event:flash.events.KeyboardEvent) : void {
			if(!_started) {
				return;
			}
			var _local2:starling.events.KeyboardEvent = new starling.events.KeyboardEvent(event.type,event.charCode,event.keyCode,event.keyLocation,event.ctrlKey,event.altKey,event.shiftKey);
			makeCurrent();
			_stage.dispatchEvent(_local2);
			if(_local2.isDefaultPrevented()) {
				event.preventDefault();
			}
		}
		
		private function onResize(event:Event) : void {
			var dispatchResizeEvent:* = function():void {
				makeCurrent();
				removeEventListener("context3DCreate",dispatchResizeEvent);
				_stage.dispatchEvent(new ResizeEvent("resize",stageWidth,stageHeight));
			};
			var stageWidth:int = int(event.target.stageWidth);
			var stageHeight:int = int(event.target.stageHeight);
			if(contextValid) {
				dispatchResizeEvent();
			} else {
				addEventListener("context3DCreate",dispatchResizeEvent);
			}
		}
		
		private function onMouseLeave(event:Event) : void {
			_touchProcessor.enqueueMouseLeftStage();
		}
		
		private function onTouch(event:Event) : void {
			var _local5:Number = NaN;
			var _local3:Number = NaN;
			var _local6:int = 0;
			var _local2:String = null;
			var _local4:MouseEvent = null;
			var _local8:TouchEvent = null;
			if(!_started) {
				return;
			}
			var _local9:Number = 1;
			var _local7:Number = 1;
			var _local10:Number = 1;
			if(event is MouseEvent) {
				_local4 = event as MouseEvent;
				_local5 = _local4.stageX;
				_local3 = _local4.stageY;
				_local6 = 0;
				if(event.type == "mouseDown") {
					_leftMouseDown = true;
				} else if(event.type == "mouseUp") {
					_leftMouseDown = false;
				}
			} else {
				_local8 = event as TouchEvent;
				if(Mouse.supportsCursor && _local8.isPrimaryTouchPoint) {
					return;
				}
				_local5 = _local8.stageX;
				_local3 = _local8.stageY;
				_local6 = _local8.touchPointID;
				_local9 = _local8.pressure;
				_local7 = _local8.sizeX;
				_local10 = _local8.sizeY;
			}
			switch(event.type) {
				case "touchBegin":
					_local2 = "began";
					break;
				case "touchMove":
					_local2 = "moved";
					break;
				case "touchEnd":
					_local2 = "ended";
					break;
				case "mouseDown":
					_local2 = "began";
					break;
				case "mouseUp":
					_local2 = "ended";
					break;
				case "mouseMove":
					_local2 = _leftMouseDown ? "moved" : "hover";
			}
			_local5 = _stage.stageWidth * (_local5 - _viewPort.x) / _viewPort.width;
			_local3 = _stage.stageHeight * (_local3 - _viewPort.y) / _viewPort.height;
			_touchProcessor.enqueue(_local6,_local2,_local5,_local3,_local9,_local7,_local10);
			if(event.type == "mouseUp" && Mouse.supportsCursor) {
				_touchProcessor.enqueue(_local6,"hover",_local5,_local3);
			}
		}
		
		private function get touchEventTypes() : Array {
			var _local1:Array = [];
			if(multitouchEnabled) {
				_local1.push("touchBegin","touchMove","touchEnd");
			}
			if(!multitouchEnabled || Mouse.supportsCursor) {
				_local1.push("mouseDown","mouseMove","mouseUp");
			}
			return _local1;
		}
		
		private function get mustAlwaysRender() : Boolean {
			var _local2:Boolean = false;
			var _local1:Boolean = false;
			if(!_skipUnchangedFrames || _painter.shareContext) {
				return true;
			}
			if(SystemUtil.isDesktop && profile != "baselineConstrained") {
				return false;
			}
			_local2 = Boolean(isNativeDisplayObjectEmpty(_nativeStage));
			_local1 = !_local2 || !_nativeStageEmpty;
			_nativeStageEmpty = _local2;
			return _local1;
		}
		
		public function get isStarted() : Boolean {
			return _started;
		}
		
		public function get juggler() : Juggler {
			return _juggler;
		}
		
		public function get painter() : Painter {
			return _painter;
		}
		
		public function get context() : Context3D {
			return _painter.context;
		}
		
		public function get simulateMultitouch() : Boolean {
			return _touchProcessor.simulateMultitouch;
		}
		
		public function set simulateMultitouch(value:Boolean) : void {
			_touchProcessor.simulateMultitouch = value;
		}
		
		public function get enableErrorChecking() : Boolean {
			return _painter.enableErrorChecking;
		}
		
		public function set enableErrorChecking(value:Boolean) : void {
			_painter.enableErrorChecking = value;
		}
		
		public function get antiAliasing() : int {
			return _antiAliasing;
		}
		
		public function set antiAliasing(value:int) : void {
			if(_antiAliasing != value) {
				_antiAliasing = value;
				if(contextValid) {
					updateViewPort(true);
				}
			}
		}
		
		public function get viewPort() : Rectangle {
			return _viewPort;
		}
		
		public function set viewPort(value:Rectangle) : void {
			_viewPort = value.clone();
		}
		
		public function get contentScaleFactor() : Number {
			return _viewPort.width * _painter.backBufferScaleFactor / _stage.stageWidth;
		}
		
		public function get nativeOverlay() : Sprite {
			return _nativeOverlay;
		}
		
		public function get showStats() : Boolean {
			return _showStats;
		}
		
		public function set showStats(value:Boolean) : void {
			_showStats = value;
			if(value) {
				if(_statsDisplay) {
					_stage.addChild(_statsDisplay);
				} else {
					showStatsAt();
				}
			} else if(_statsDisplay) {
				_statsDisplay.removeFromParent();
			}
		}
		
		public function showStatsAt(horizontalAlign:String = "left", verticalAlign:String = "top", scale:Number = 1) : void {
			var stageWidth:int;
			var stageHeight:int;
			var onRootCreated:* = function():void {
				if(_showStats) {
					showStatsAt(horizontalAlign,verticalAlign,scale);
				}
				removeEventListener("rootCreated",onRootCreated);
			};
			_showStats = true;
			if(context == null) {
				addEventListener("rootCreated",onRootCreated);
			} else {
				stageWidth = _stage.stageWidth;
				stageHeight = _stage.stageHeight;
				if(_statsDisplay == null) {
					_statsDisplay = new StatsDisplay();
					_statsDisplay.touchable = false;
				}
				_stage.addChild(_statsDisplay);
				_statsDisplay.scaleX = _statsDisplay.scaleY = scale;
				if(horizontalAlign == "left") {
					_statsDisplay.x = 0;
				} else if(horizontalAlign == "right") {
					_statsDisplay.x = stageWidth - _statsDisplay.width;
				} else {
					if(horizontalAlign != "center") {
						throw new ArgumentError("Invalid horizontal alignment: " + horizontalAlign);
					}
					_statsDisplay.x = (stageWidth - _statsDisplay.width) / 2;
				}
				if(verticalAlign == "top") {
					_statsDisplay.y = 0;
				} else if(verticalAlign == "bottom") {
					_statsDisplay.y = stageHeight - _statsDisplay.height;
				} else {
					if(verticalAlign != "center") {
						throw new ArgumentError("Invalid vertical alignment: " + verticalAlign);
					}
					_statsDisplay.y = (stageHeight - _statsDisplay.height) / 2;
				}
			}
		}
		
		public function get stage() : starling.display.Stage {
			return _stage;
		}
		
		public function get stage3D() : Stage3D {
			return _painter.stage3D;
		}
		
		public function get nativeStage() : flash.display.Stage {
			return _nativeStage;
		}
		
		public function get root() : DisplayObject {
			return _root;
		}
		
		public function get rootClass() : Class {
			return _rootClass;
		}
		
		public function set rootClass(value:Class) : void {
			if(_rootClass != null && _root != null) {
				throw new Error("Root class may not change after root has been instantiated");
			}
			if(_rootClass == null) {
				_rootClass = value;
				if(context) {
					initializeRoot();
				}
			}
		}
		
		public function get shareContext() : Boolean {
			return _painter.shareContext;
		}
		
		public function set shareContext(value:Boolean) : void {
			_painter.shareContext = value;
		}
		
		public function get profile() : String {
			return _painter.profile;
		}
		
		public function get supportHighResolutions() : Boolean {
			return _supportHighResolutions;
		}
		
		public function set supportHighResolutions(value:Boolean) : void {
			if(_supportHighResolutions != value) {
				_supportHighResolutions = value;
				if(contextValid) {
					updateViewPort(true);
				}
			}
		}
		
		public function get skipUnchangedFrames() : Boolean {
			return _skipUnchangedFrames;
		}
		
		public function set skipUnchangedFrames(value:Boolean) : void {
			_skipUnchangedFrames = value;
			_nativeStageEmpty = false;
		}
		
		public function get touchProcessor() : TouchProcessor {
			return _touchProcessor;
		}
		
		public function set touchProcessor(value:TouchProcessor) : void {
			if(value == null) {
				throw new ArgumentError("TouchProcessor must not be null");
			}
			if(value != _touchProcessor) {
				_touchProcessor.dispose();
				_touchProcessor = value;
			}
		}
		
		public function get frameID() : uint {
			return _frameID;
		}
		
		public function get contextValid() : Boolean {
			return _painter.contextValid;
		}
	}
}

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

function isNativeDisplayObjectEmpty(object:DisplayObject):Boolean {
	var _local2:DisplayObjectContainer = null;
	var _local3:int = 0;
	var _local4:int = 0;
	if(object == null) {
		return true;
	}
	if(object is DisplayObjectContainer) {
		_local2 = object as DisplayObjectContainer;
		_local3 = _local2.numChildren;
		_local4 = 0;
		while(_local4 < _local3) {
			if(!isNativeDisplayObjectEmpty(_local2.getChildAt(_local4))) {
				return false;
			}
			_local4++;
		}
		return true;
	}
	return !object.visible;
}
