package core.hud.components.techTree
{
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
	
	public class EliteTechPopupMenu extends Sprite
	{
		private var container:ScrollContainer;
		
		private var box:Box;
		
		private var closeButton:Button;
		
		private var g:Game;
		
		private var eti:EliteTechIcon;
		
		private var textureManager:ITextureManager;
		
		private var dataManager:IDataManager;
		
		private var eliteTechs:Vector.<EliteTechBar>;
		
		protected var bgr:Quad;
		
		public function EliteTechPopupMenu(param1:Game, param2:EliteTechIcon)
		{
			container = new ScrollContainer();
			box = new Box(460, 430, "highlight", 1, 15);
			eliteTechs = new Vector.<EliteTechBar>();
			bgr = new Quad(100, 100, 570425344);
			super();
			this.g = param1;
			this.eti = param2;
			bgr.alpha = 0.5;
			bgr.alpha = 0.5;
			textureManager = TextureLocator.getService();
			dataManager = DataLocator.getService();
			load();
			addEventListener("addedToStage", stageAddHandler);
		}
		
		private function load():void
		{
			var _loc3_:int = 0;
			var _loc2_:TechSkill = eti.techSkill;
			var _loc4_:Object = dataManager.loadKey(_loc2_.table, _loc2_.tech);
			container.width = 450;
			container.height = 385;
			container.x = 10;
			container.y = 10;
			box.addChild(container);
			closeButton = new Button(close, "Cancel");
			box.addChild(closeButton);
			if (_loc4_.hasOwnProperty("eliteTechs"))
			{
				eliteTechs = EliteTechs.getEliteTechBarList(g, _loc2_, _loc4_);
			}
			for each (var _loc1_:* in eliteTechs)
			{
				_loc1_.y = _loc3_;
				_loc1_.x = 5;
				_loc1_.etpm = this;
				container.addChild(_loc1_);
				_loc3_ += _loc1_.height + 10;
			}
			addChild(bgr);
			addChild(box);
		}
		
		public function updateAndClose(param1:Message):void
		{
			if (!param1.getBoolean(0))
			{
				return;
			}
			eti.update(param1.getInt(1));
			close();
		}
		
		public function disableAll():void
		{
			for each (var _loc1_:* in eliteTechs)
			{
				_loc1_.touchable = false;
			}
			closeButton.touchable = false;
		}
		
		protected function redraw(param1:Event = null):void
		{
			if (stage == null)
			{
				return;
			}
			closeButton.y = Math.round(box.height - 50);
			closeButton.x = Math.round(box.width / 2 - closeButton.width / 2 - 20);
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 2 - box.height / 2);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
		}
		
		private function stageAddHandler(param1:Event):void
		{
			addEventListener("removedFromStage", clean);
			stage.addEventListener("resize", redraw);
			bgr.width = stage.stageWidth;
			bgr.height = stage.stageHeight;
			redraw();
		}
		
		protected function close(param1:TouchEvent = null):void
		{
			dispatchEventWith("close");
			removeEventListeners();
		}
		
		protected function clean(param1:Event):void
		{
			stage.removeEventListener("resize", redraw);
			removeEventListener("removedFromStage", clean);
			removeEventListener("addedToStage", stageAddHandler);
			super.dispose();
		}
	}
}
