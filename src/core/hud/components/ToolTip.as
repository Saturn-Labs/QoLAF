package core.hud.components
{
	import core.scene.SceneBase;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ToolTip
	{
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
		
		public function ToolTip(param1:SceneBase, param2:DisplayObject, param3:String, param4:Array = null, param5:String = "", param6:int = 200)
		{
			super();
			g = param1;
			this.type = param5;
			this.maxWidth = param6;
			this.target = param2;
			this.imgsData = param4;
			imgs = new Vector.<Image>();
			for each (var _loc7_:* in imgsData)
			{
				addImage(_loc7_);
			}
			s = param3;
			toolTips.push(this);
			addListeners();
		}
		
		public static function disposeType(param1:String = "all"):void
		{
			var _loc2_:ToolTip = null;
			var _loc3_:int = 0;
			if (g == null)
			{
				return;
			}
			_loc3_ = toolTips.length - 1;
			while (_loc3_ > -1)
			{
				_loc2_ = toolTips[_loc3_];
				if (_loc2_.type == param1 || param1 == "all")
				{
					_loc2_.dispose();
					toolTips.splice(_loc3_, 1);
				}
				_loc3_--;
			}
		}
		
		public static function disposeAll():void
		{
			disposeType();
		}
		
		public function set text(param1:String):void
		{
			s = param1;
		}
		
		public function set color(param1:uint):void
		{
			c = param1;
		}
		
		public function addImage(param1:Object):void
		{
			var _loc2_:ITextureManager = TextureLocator.getService();
			var _loc3_:Image = new Image(_loc2_.getTextureGUIByTextureName(param1.img));
			_loc3_.x = param1.x;
			_loc3_.y = param1.y;
			imgs.push(_loc3_);
		}
		
		private function mOver(param1:TouchEvent):void
		{
			var _loc3_:Label = null;
			if (s == null || s == "")
			{
				return;
			}
			if (hover && container)
			{
				container.x = param1.getTouch(target).globalX + 10;
				container.y = param1.getTouch(target).globalY + 14;
				if (container.x + container.width + 5 > g.stage.stageWidth)
				{
					container.x = g.stage.stageWidth - container.width - 5;
				}
				if (container.y + container.height + 5 > g.stage.stageHeight)
				{
					container.y = g.stage.stageHeight - container.height - 35;
				}
				return;
			}
			hover = true;
			if (container != null)
			{
				g.addChildToOverlay(container);
			}
			else
			{
				container = new ScrollContainer();
				container.touchable = false;
				container.backgroundSkin = new Quad(40, 5, 0);
				container.padding = 4;
				g.addChildToOverlay(container);
				_loc3_ = new Label();
				_loc3_.styleNameList.add("tooltip");
				_loc3_.text = s;
				_loc3_.maxWidth = maxWidth;
				container.addChild(_loc3_);
				_loc3_.textRendererProperties.textFormat.color = c != 0 ? c : Style.COLOR_HIGHLIGHT;
				_loc3_.validate();
				_loc3_.width += 5;
				_loc3_.invalidate();
				for each (var _loc2_:* in imgs)
				{
					container.addChild(_loc2_);
				}
			}
			container.x = param1.getTouch(target).globalX + 10;
			container.y = param1.getTouch(target).globalY + 14;
			if (container.x + container.width + 5 > g.stage.stageWidth)
			{
				container.x = g.stage.stageWidth - container.width - 5;
			}
			if (container.y + container.height + 5 > g.stage.stageHeight)
			{
				container.y = g.stage.stageHeight - container.height - 35;
			}
		}
		
		private function mOut(param1:TouchEvent):void
		{
			if (!hover)
			{
				return;
			}
			hover = false;
			if (container != null)
			{
				g.removeChildFromOverlay(container, true);
				container = null;
			}
		}
		
		private function onClick(param1:TouchEvent):void
		{
			hover = false;
			if (container != null)
			{
				g.removeChildFromOverlay(container, true);
				container = null;
			}
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(target, "ended"))
			{
				onClick(param1);
			}
			else if (param1.interactsWith(target))
			{
				mOver(param1);
			}
			else if (!param1.interactsWith(target))
			{
				mOut(param1);
			}
		}
		
		public function removeListeners():void
		{
			target.removeEventListener("touch", onTouch);
		}
		
		private function addListeners():void
		{
			target.addEventListener("touch", onTouch);
		}
		
		public function dispose():void
		{
			if (container != null)
			{
				g.removeChildFromOverlay(container, true);
				container = null;
			}
			removeListeners();
			target = null;
			imgs = null;
			imgsData = null;
		}
	}
}
