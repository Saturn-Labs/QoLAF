package core.hud.components.credits {
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
	
	public class CreditBaseItem extends Sprite implements ICreditItem {
		protected var g:Game;
		protected var dataManager:IDataManager;
		protected var textureManager:ITextureManager;
		protected var selected:Boolean = false;
		protected var hover:Boolean = false;
		private var bgr:Quad = new Quad(260,50,0);
		protected var selectContainer:Sprite = new Sprite();
		protected var infoContainer:Sprite = new Sprite();
		protected var itemLabel:String;
		protected var bitmap:String;
		protected var spinner:Boolean;
		
		public function CreditBaseItem(g:Game, parent:Sprite, spinner:Boolean = false) {
			super();
			this.g = g;
			dataManager = DataLocator.getService();
			textureManager = TextureLocator.getService();
			this.spinner = spinner;
			if(spinner) {
				addChild(infoContainer);
				infoContainer.visible = true;
			} else {
				parent.addChild(infoContainer);
				infoContainer.visible = false;
			}
			addChild(selectContainer);
			addEventListener("touch",onTouch);
			drawSelectContainer();
			this.addEventListener("removedFromStage",clean);
		}
		
		protected function load() : void {
			selectContainer.addChild(bgr);
			var _local3:Texture = textureManager.getTextureGUIByTextureName(bitmap);
			var _local1:Image = new Image(_local3);
			_local1.x = 5;
			_local1.y = 5;
			addChild(_local1);
			var _local2:TextField = new TextField(selectContainer.width - _local1.width,_local1.height,itemLabel,new TextFormat("DAIDRR",14,0xaaaaaa,"left"));
			_local2.x = _local1.x + _local1.width + 10;
			_local2.y = _local1.y;
			selectContainer.addChild(_local2);
		}
		
		private function drawSelectContainer() : void {
			if(hover && !selected) {
				bgr.color = 0x6688ff;
				bgr.alpha = 0.1;
			} else if(!selected) {
				bgr.color = 0;
				bgr.alpha = 0.5;
			} else {
				bgr.color = 0x6688ff;
				bgr.alpha = 0.3;
			}
		}
		
		public function deselect() : void {
			selected = false;
			drawSelectContainer();
			showInfo(selected);
		}
		
		public function update() : void {
		}
		
		protected function showInfo(value:Boolean) : void {
			infoContainer.visible = value;
		}
		
		public function select() : void {
			onClick();
		}
		
		protected function onClick(e:TouchEvent = null) : void {
			selected = !selected;
			drawSelectContainer();
			showInfo(selected);
			if(e == null) {
				return;
			}
			e.stopPropagation();
			dispatchEvent(new TouchEvent("select",e.touches));
		}
		
		private function mouseOver(e:TouchEvent) : void {
			hover = true;
			drawSelectContainer();
		}
		
		private function mouseOut(e:TouchEvent) : void {
			hover = false;
			drawSelectContainer();
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(spinner) {
				return;
			}
			if(e.getTouch(this,"ended")) {
				onClick(e);
			} else if(e.interactsWith(this)) {
				mouseOver(e);
			} else if(!e.interactsWith(this)) {
				mouseOut(e);
			}
		}
		
		public function exit() : void {
			infoContainer.removeChildren();
		}
		
		private function clean(e:Event = null) : void {
			removeEventListener("removedFromStage",clean);
			removeEventListener("touch",onTouch);
		}
	}
}

