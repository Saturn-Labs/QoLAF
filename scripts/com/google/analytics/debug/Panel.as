package com.google.analytics.debug {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class Panel extends UISprite {
		private var _name:String;
		
		private var _backgroundColor:uint;
		
		private var _borderColor:uint;
		
		private var _colapsed:Boolean;
		
		private var _savedW:uint;
		
		private var _savedH:uint;
		
		private var _background:Shape;
		
		private var _data:UISprite;
		
		private var _title:Label;
		
		private var _border:Shape;
		
		private var _mask:Sprite;
		
		protected var baseAlpha:Number;
		
		private var _stickToEdge:Boolean;
		
		public function Panel(name:String, width:uint, height:uint, backgroundColor:uint = 0, borderColor:uint = 0, baseAlpha:Number = 0.3, alignement:Align = null, stickToEdge:Boolean = false) {
			super();
			this._name = name;
			this.name = name;
			this.mouseEnabled = false;
			this._colapsed = false;
			forcedWidth = width;
			forcedHeight = height;
			this.baseAlpha = baseAlpha;
			this._background = new Shape();
			this._data = new UISprite();
			this._data.forcedWidth = width;
			this._data.forcedHeight = height;
			this._data.mouseEnabled = false;
			this._title = new Label(name,"uiLabel",0xffffff,Align.topLeft,stickToEdge);
			this._title.buttonMode = true;
			this._title.margin.top = 0.6;
			this._title.margin.left = 0.6;
			this._title.addEventListener(MouseEvent.CLICK,this.onToggle);
			this._title.mouseChildren = false;
			this._border = new Shape();
			this._mask = new Sprite();
			this._mask.useHandCursor = false;
			this._mask.mouseEnabled = false;
			this._mask.mouseChildren = false;
			if(alignement == null) {
				alignement = Align.none;
			}
			this.alignement = alignement;
			this.stickToEdge = stickToEdge;
			if(backgroundColor == 0) {
				backgroundColor = uint(Style.backgroundColor);
			}
			this._backgroundColor = backgroundColor;
			if(borderColor == 0) {
				borderColor = uint(Style.borderColor);
			}
			this._borderColor = borderColor;
		}
		
		public function addData(child:DisplayObject) : void {
			this._data.addChild(child);
		}
		
		override protected function layout() : void {
			this._update();
			addChild(this._background);
			addChild(this._data);
			addChild(this._title);
			addChild(this._border);
			addChild(this._mask);
			mask = this._mask;
		}
		
		override protected function dispose() : void {
			this._title.removeEventListener(MouseEvent.CLICK,this.onToggle);
			super.dispose();
		}
		
		private function _update() : void {
			this._draw();
			if(this.baseAlpha < 1) {
				this._background.alpha = this.baseAlpha;
				this._border.alpha = this.baseAlpha;
			}
		}
		
		private function _draw() : void {
			var _local1:uint = 0;
			var _local2:uint = 0;
			if(Boolean(this._savedW) && Boolean(this._savedH)) {
				forcedWidth = this._savedW;
				forcedHeight = this._savedH;
			}
			if(!this._colapsed) {
				_local1 = forcedWidth;
				_local2 = forcedHeight;
			} else {
				_local1 = this._title.width;
				_local2 = this._title.height;
				this._savedW = forcedWidth;
				this._savedH = forcedHeight;
				forcedWidth = _local1;
				forcedHeight = _local2;
			}
			var _local3:Graphics = this._background.graphics;
			_local3.clear();
			_local3.beginFill(this._backgroundColor);
			Background.drawRounded(this,_local3,_local1,_local2);
			_local3.endFill();
			var _local4:Graphics = this._data.graphics;
			_local4.clear();
			_local4.beginFill(this._backgroundColor,0);
			Background.drawRounded(this,_local4,_local1,_local2);
			_local4.endFill();
			var _local5:Graphics = this._border.graphics;
			_local5.clear();
			_local5.lineStyle(0.1,this._borderColor);
			Background.drawRounded(this,_local5,_local1,_local2);
			_local5.endFill();
			var _local6:Graphics = this._mask.graphics;
			_local6.clear();
			_local6.beginFill(this._backgroundColor);
			Background.drawRounded(this,_local6,_local1 + 1,_local2 + 1);
			_local6.endFill();
		}
		
		public function onToggle(event:MouseEvent = null) : void {
			if(this._colapsed) {
				this._data.visible = true;
			} else {
				this._data.visible = false;
			}
			this._colapsed = !this._colapsed;
			this._update();
			resize();
		}
		
		public function get stickToEdge() : Boolean {
			return this._stickToEdge;
		}
		
		public function set stickToEdge(value:Boolean) : void {
			this._stickToEdge = value;
			this._title.stickToEdge = value;
		}
		
		public function get title() : String {
			return this._title.text;
		}
		
		public function set title(value:String) : void {
			this._title.text = value;
		}
		
		public function close() : void {
			this.dispose();
			if(parent != null) {
				parent.removeChild(this);
			}
		}
	}
}

