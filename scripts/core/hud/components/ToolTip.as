package core.hud.components {
	import core.scene.SceneBase;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ToolTip {
		private static var g:SceneBase;
		
		private static var toolTips:Vector.<ToolTip> = new Vector.<ToolTip>();
		
		private var container:ScrollContainer;
		
		private var target:DisplayObject;
		
		private var s:String;
		
		private var imgs:Vector.<Image>;
		
		private var imgsData:Array;
		
		private var maxWidth:int;
		
		private var hover:Boolean;
		
		private var c:uint;
		
		public var type:String;
		
		public function ToolTip(m:SceneBase, target:DisplayObject, tooltip:String, images:Array = null, type:String = "", maxWidth:int = 200) {
			super();
			g = m;
			this.type = type;
			this.maxWidth = maxWidth;
			this.target = target;
			this.imgsData = images;
			imgs = new Vector.<Image>();
			for each(var _local7 in imgsData) {
				addImage(_local7);
			}
			s = tooltip;
			toolTips.push(this);
			addListeners();
		}
		
		public static function disposeType(s:String = "all") : void {
			var _local2:ToolTip = null;
			var _local3:int = 0;
			if(g == null) {
				return;
			}
			_local3 = toolTips.length - 1;
			while(_local3 > -1) {
				_local2 = toolTips[_local3];
				if(_local2.type == s || s == "all") {
					_local2.dispose();
					toolTips.splice(_local3,1);
				}
				_local3--;
			}
		}
		
		public static function disposeAll() : void {
			disposeType();
		}
		
		public function set text(value:String) : void {
			s = value;
		}
		
		public function set color(value:uint) : void {
			c = value;
		}
		
		public function addImage(obj:Object) : void {
			var _local3:ITextureManager = TextureLocator.getService();
			var _local2:Image = new Image(_local3.getTextureGUIByTextureName(obj.img));
			_local2.x = obj.x;
			_local2.y = obj.y;
			imgs.push(_local2);
		}
		
		private function mOver(e:TouchEvent) : void {
			var _local3:Label = null;
			if(s == null || s == "") {
				return;
			}
			if(hover && container) {
				container.x = e.getTouch(target).globalX + 10;
				container.y = e.getTouch(target).globalY + 14;
				if(container.x + container.width + 5 > g.stage.stageWidth) {
					container.x = g.stage.stageWidth - container.width - 5;
				}
				if(container.y + container.height + 5 > g.stage.stageHeight) {
					container.y = g.stage.stageHeight - container.height - 35;
				}
				return;
			}
			hover = true;
			if(container != null) {
				g.addChildToOverlay(container);
			} else {
				container = new ScrollContainer();
				container.touchable = false;
				container.backgroundSkin = new Quad(40,5,0);
				container.padding = 4;
				g.addChildToOverlay(container);
				_local3 = new Label();
				_local3.styleNameList.add("tooltip");
				_local3.text = s;
				_local3.maxWidth = maxWidth;
				container.addChild(_local3);
				_local3.textRendererProperties.textFormat.color = c != 0 ? c : Style.COLOR_HIGHLIGHT;
				_local3.validate();
				_local3.width += 5;
				_local3.invalidate();
				for each(var _local2 in imgs) {
					container.addChild(_local2);
				}
			}
			container.x = e.getTouch(target).globalX + 10;
			container.y = e.getTouch(target).globalY + 14;
			if(container.x + container.width + 5 > g.stage.stageWidth) {
				container.x = g.stage.stageWidth - container.width - 5;
			}
			if(container.y + container.height + 5 > g.stage.stageHeight) {
				container.y = g.stage.stageHeight - container.height - 35;
			}
		}
		
		private function mOut(e:TouchEvent) : void {
			if(!hover) {
				return;
			}
			hover = false;
			if(container != null) {
				g.removeChildFromOverlay(container,true);
				container = null;
			}
		}
		
		private function onClick(e:TouchEvent) : void {
			hover = false;
			if(container != null) {
				g.removeChildFromOverlay(container,true);
				container = null;
			}
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(e.getTouch(target,"ended")) {
				onClick(e);
			} else if(e.interactsWith(target)) {
				mOver(e);
			} else if(!e.interactsWith(target)) {
				mOut(e);
			}
		}
		
		public function removeListeners() : void {
			target.removeEventListener("touch",onTouch);
		}
		
		private function addListeners() : void {
			target.addEventListener("touch",onTouch);
		}
		
		public function dispose() : void {
			if(container != null) {
				g.removeChildFromOverlay(container,true);
				container = null;
			}
			removeListeners();
			target = null;
			imgs = null;
			imgsData = null;
		}
	}
}

