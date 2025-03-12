package core.hud.components.credits
{
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CreditBaseItem extends Sprite implements ICreditItem
	{
		protected var g:Game;
		
		protected var dataManager:IDataManager;
		
		protected var textureManager:ITextureManager;
		
		protected var selected:Boolean = false;
		protected var hover:Boolean = false;
		private var bgr:Quad;
		
		protected var selectContainer:Sprite;
		
		protected var infoContainer:Sprite;
		
		protected var itemLabel:String;
		
		protected var bitmap:String;
		
		protected var spinner:Boolean;
		
		public function CreditBaseItem(param1:Game, param2:Sprite, param3:Boolean = false)
		{
			bgr = new Quad(260, 50, 0);
			selectContainer = new Sprite();
			infoContainer = new Sprite();
			super();
			this.g = param1;
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
			this.spinner = param3;
			if (param3)
			{
				addChild(infoContainer);
				infoContainer.visible = true;
			}
			else
			{
				param2.addChild(infoContainer);
				infoContainer.visible = false;
			}
			addChild(selectContainer);
			addEventListener("touch", onTouch);
			drawSelectContainer();
			this.addEventListener("removedFromStage", clean);
		}
		
		protected function load():void
		{
			selectContainer.addChild(bgr);
			var _loc3_:Texture = textureManager.getTextureGUIByTextureName(bitmap);
			var _loc1_:Image = new Image(_loc3_);
			_loc1_.x = 5;
			_loc1_.y = 5;
			addChild(_loc1_);
			var _loc2_:TextField = new TextField(selectContainer.width - _loc1_.width, _loc1_.height, itemLabel, new TextFormat("DAIDRR", 14, 11184810, "left"));
			_loc2_.x = _loc1_.x + _loc1_.width + 10;
			_loc2_.y = _loc1_.y;
			selectContainer.addChild(_loc2_);
		}
		
		private function drawSelectContainer():void
		{
			if (hover && !selected)
			{
				bgr.color = 6719743;
				bgr.alpha = 0.1;
			}
			else if (!selected)
			{
				bgr.color = 0;
				bgr.alpha = 0.5;
			}
			else
			{
				bgr.color = 6719743;
				bgr.alpha = 0.3;
			}
		}
		
		public function deselect():void
		{
			selected = false;
			drawSelectContainer();
			showInfo(selected);
		}
		
		public function update():void
		{
		}
		
		protected function showInfo(param1:Boolean):void
		{
			infoContainer.visible = param1;
		}
		
		public function select():void
		{
			onClick();
		}
		
		protected function onClick(param1:TouchEvent = null):void
		{
			selected = !selected;
			drawSelectContainer();
			showInfo(selected);
			if (param1 == null)
			{
				return;
			}
			param1.stopPropagation();
			dispatchEvent(new TouchEvent("select", param1.touches));
		}
		
		private function mouseOver(param1:TouchEvent):void
		{
			hover = true;
			drawSelectContainer();
		}
		
		private function mouseOut(param1:TouchEvent):void
		{
			hover = false;
			drawSelectContainer();
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (spinner)
			{
				return;
			}
			if (param1.getTouch(this, "ended"))
			{
				onClick(param1);
			}
			else if (param1.interactsWith(this))
			{
				mouseOver(param1);
			}
			else if (!param1.interactsWith(this))
			{
				mouseOut(param1);
			}
		}
		
		public function exit():void
		{
			infoContainer.removeChildren();
		}
		
		private function clean(param1:Event = null):void
		{
			removeEventListener("removedFromStage", clean);
			removeEventListener("touch", onTouch);
		}
	}
}
