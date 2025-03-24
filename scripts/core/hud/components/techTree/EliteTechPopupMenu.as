package core.hud.components.techTree {
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.player.EliteTechs;
	import core.player.TechSkill;
	import core.scene.Game;
	import data.DataLocator;
	import data.IDataManager;
	import feathers.controls.ScrollContainer;
	import playerio.Message;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class EliteTechPopupMenu extends Sprite {
		private var container:ScrollContainer = new ScrollContainer();
		
		private var box:Box = new Box(460,430,"highlight",1,15);
		
		private var closeButton:Button;
		
		private var g:Game;
		
		private var eti:EliteTechIcon;
		
		private var textureManager:ITextureManager;
		
		private var dataManager:IDataManager;
		
		private var eliteTechs:Vector.<EliteTechBar> = new Vector.<EliteTechBar>();
		
		protected var bgr:Quad = new Quad(100,100,0x22000000);
		
		public function EliteTechPopupMenu(g:Game, eti:EliteTechIcon) {
			super();
			this.g = g;
			this.eti = eti;
			bgr.alpha = 0.5;
			bgr.alpha = 0.5;
			textureManager = TextureLocator.getService();
			dataManager = DataLocator.getService();
			load();
			addEventListener("addedToStage",stageAddHandler);
		}
		
		private function load() : void {
			var _local2:int = 0;
			var _local4:TechSkill = eti.techSkill;
			var _local3:Object = dataManager.loadKey(_local4.table,_local4.tech);
			container.width = 450;
			container.height = 385;
			container.x = 10;
			container.y = 10;
			box.addChild(container);
			closeButton = new Button(close,"Cancel");
			box.addChild(closeButton);
			if(_local3.hasOwnProperty("eliteTechs")) {
				eliteTechs = EliteTechs.getEliteTechBarList(g,_local4,_local3);
			}
			for each(var _local1 in eliteTechs) {
				_local1.y = _local2;
				_local1.x = 5;
				_local1.etpm = this;
				container.addChild(_local1);
				_local2 += _local1.height + 10;
			}
			addChild(bgr);
			addChild(box);
		}
		
		public function updateAndClose(m:Message) : void {
			if(!m.getBoolean(0)) {
				return;
			}
			eti.update(m.getInt(1));
			close();
		}
		
		public function disableAll() : void {
			for each(var _local1 in eliteTechs) {
				_local1.touchable = false;
			}
			closeButton.touchable = false;
		}
		
		protected function redraw(e:Event = null) : void {
			if(stage == null) {
				return;
			}
			closeButton.y = Math.round(box.height - 50);
			closeButton.x = Math.round(box.width / 2 - closeButton.width / 2 - 20);
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
		
		private function stageAddHandler(e:Event) : void {
			addEventListener("removedFromStage",clean);
			stage.addEventListener("resize",redraw);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
			redraw();
		}
		
		protected function close(e:TouchEvent = null) : void {
			dispatchEventWith("close");
			removeEventListeners();
		}
		
		protected function clean(e:Event) : void {
			stage.removeEventListener("resize",redraw);
			removeEventListener("removedFromStage",clean);
			removeEventListener("addedToStage",stageAddHandler);
			super.dispose();
		}
	}
}

