package com.google.analytics.debug {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	public class UISprite extends Sprite {
		private var _forcedWidth:uint;
		
		private var _forcedHeight:uint;
		
		protected var alignTarget:DisplayObject;
		
		protected var listenResize:Boolean;
		
		public var alignement:Align;
		
		public var margin:Margin;
		
		public function UISprite(alignTarget:DisplayObject = null) {
			super();
			this.listenResize = false;
			this.alignement = Align.none;
			this.alignTarget = alignTarget;
			this.margin = new Margin();
			addEventListener(Event.ADDED_TO_STAGE,this._onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE,this._onRemovedFromStage);
		}
		
		private function _onAddedToStage(event:Event) : void {
			this.layout();
			this.resize();
		}
		
		private function _onRemovedFromStage(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE,this._onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE,this._onRemovedFromStage);
			this.dispose();
		}
		
		protected function layout() : void {
		}
		
		protected function dispose() : void {
			var _local1:DisplayObject = null;
			var _local2:int = 0;
			while(_local2 < numChildren) {
				_local1 = getChildAt(_local2);
				if(_local1) {
					removeChild(_local1);
				}
				_local2++;
			}
		}
		
		protected function onResize(event:Event) : void {
			this.resize();
		}
		
		public function get forcedWidth() : uint {
			if(this._forcedWidth) {
				return this._forcedWidth;
			}
			return width;
		}
		
		public function set forcedWidth(value:uint) : void {
			this._forcedWidth = value;
		}
		
		public function get forcedHeight() : uint {
			if(this._forcedHeight) {
				return this._forcedHeight;
			}
			return height;
		}
		
		public function set forcedHeight(value:uint) : void {
			this._forcedHeight = value;
		}
		
		public function alignTo(alignement:Align, target:DisplayObject = null) : void {
			var _local3:uint = 0;
			var _local4:uint = 0;
			var _local5:uint = 0;
			var _local6:uint = 0;
			var _local7:UISprite = null;
			if(target == null) {
				if(parent is Stage) {
					target = this.stage;
				} else {
					target = parent;
				}
			}
			if(target == this.stage) {
				if(this.stage == null) {
					return;
				}
				_local3 = uint(this.stage.stageHeight);
				_local4 = uint(this.stage.stageWidth);
				_local5 = 0;
				_local6 = 0;
			} else {
				_local7 = target as UISprite;
				if(_local7.forcedHeight) {
					_local3 = _local7.forcedHeight;
				} else {
					_local3 = _local7.height;
				}
				if(_local7.forcedWidth) {
					_local4 = _local7.forcedWidth;
				} else {
					_local4 = _local7.width;
				}
				_local5 = 0;
				_local6 = 0;
			}
			switch(alignement) {
				case Align.top:
					x = _local4 / 2 - this.forcedWidth / 2;
					y = _local6 + this.margin.top;
					break;
				case Align.bottom:
					x = _local4 / 2 - this.forcedWidth / 2;
					y = _local6 + _local3 - this.forcedHeight - this.margin.bottom;
					break;
				case Align.left:
					x = _local5 + this.margin.left;
					y = _local3 / 2 - this.forcedHeight / 2;
					break;
				case Align.right:
					x = _local5 + _local4 - this.forcedWidth - this.margin.right;
					y = _local3 / 2 - this.forcedHeight / 2;
					break;
				case Align.center:
					x = _local4 / 2 - this.forcedWidth / 2;
					y = _local3 / 2 - this.forcedHeight / 2;
					break;
				case Align.topLeft:
					x = _local5 + this.margin.left;
					y = _local6 + this.margin.top;
					break;
				case Align.topRight:
					x = _local5 + _local4 - this.forcedWidth - this.margin.right;
					y = _local6 + this.margin.top;
					break;
				case Align.bottomLeft:
					x = _local5 + this.margin.left;
					y = _local6 + _local3 - this.forcedHeight - this.margin.bottom;
					break;
				case Align.bottomRight:
					x = _local5 + _local4 - this.forcedWidth - this.margin.right;
					y = _local6 + _local3 - this.forcedHeight - this.margin.bottom;
			}
			if(!this.listenResize && alignement != Align.none) {
				target.addEventListener(Event.RESIZE,this.onResize,false,0,true);
				this.listenResize = true;
			}
			this.alignement = alignement;
			this.alignTarget = target;
		}
		
		public function resize() : void {
			if(this.alignement != Align.none) {
				this.alignTo(this.alignement,this.alignTarget);
			}
		}
	}
}

