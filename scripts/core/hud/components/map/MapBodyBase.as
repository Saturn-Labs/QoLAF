package core.hud.components.map {
	import core.hud.components.Line;
	import core.hud.components.TextBitmap;
	import core.scene.Game;
	import core.solarSystem.Body;
	import flash.display.Sprite;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class MapBodyBase extends starling.display.Sprite {
		protected var radius:Number = 5;
		
		protected var body:Body;
		
		protected var layer:starling.display.Sprite = new starling.display.Sprite();
		
		protected var orbits:starling.display.Sprite = new starling.display.Sprite();
		
		protected var crew:starling.display.Sprite = new starling.display.Sprite();
		
		public var selected:Boolean = false;
		
		protected var hover:Boolean;
		
		protected var text:TextBitmap = new TextBitmap();
		
		protected var percentage:TextBitmap = new TextBitmap();
		
		protected var line:Line;
		
		protected var imgHover:Image;
		
		protected var imgSelected:Image;
		
		protected var selectedColor:uint = 11184895;
		
		protected var g:Game;
		
		protected var textureManager:ITextureManager;
		
		private var layerHeight:Number;
		
		private var layerWidth:Number;
		
		private var textWidth:Number;
		
		public function MapBodyBase(g:Game, container:starling.display.Sprite, body:Body) {
			super();
			this.g = g;
			this.body = body;
			text.touchable = percentage.touchable = false;
			text.batchable = true;
			line = g.linePool.getLine();
			line.init("line1",5);
			line.touchable = false;
			textureManager = TextureLocator.getService();
			selectedColor = body.selectedTypeColor;
			container.addChildAt(orbits,0);
			container.addChildAt(line,1);
			container.addChild(layer);
			if(body.type != "sun" || body.type != "warning") {
				layer.addEventListener("touch",onTouch);
			}
			layer.addEventListener("removedFromStage",clean);
		}
		
		protected function init() : void {
			layerHeight = layer.height;
			layerWidth = layer.width;
			textWidth = text.width;
		}
		
		protected function addOrbits() : void {
			if(body.children.length == 0) {
				return;
			}
			var _local2:flash.display.Sprite = new flash.display.Sprite();
			_local2.graphics.lineStyle(1.5,49151,0.3);
			for each(var _local3 in body.children) {
				if(!(_local3.type == "comet" || _local3.type == "hidden" || _local3.type == "boss" || _local3.type == "warning")) {
					_local2.graphics.drawCircle(radius,radius,_local3.course.orbitRadius * Map.SCALE);
				}
			}
			_local2.graphics.endFill();
			if(_local2.width == 0) {
				return;
			}
			var _local1:Image = TextureManager.imageFromSprite(_local2,body.key);
			_local1.touchable = false;
			orbits.addChild(_local1);
		}
		
		public function update() : void {
			layer.x = body.pos.x * Map.SCALE - radius;
			layer.y = body.pos.y * Map.SCALE - radius;
			text.x = layer.x - textWidth / 2 + layerHeight / 2;
			text.y = layer.y + layer.height;
			percentage.x = text.x + textWidth + 2;
			percentage.y = text.y;
			crew.x = layer.x + layerWidth + 5;
			crew.y = layer.y - 5;
			if(orbits.numChildren > 0) {
				orbits.x = body.pos.x * Map.SCALE - radius;
				orbits.y = body.pos.y * Map.SCALE - radius;
			}
			line.visible = false;
			if(selected && (body.pos.x != g.me.ship.x || body.pos.y != g.me.ship.y)) {
				line.visible = true;
				line.x = g.me.ship.x * Map.SCALE;
				line.y = g.me.ship.y * Map.SCALE;
				line.lineTo(layer.x + layerWidth / 2,layer.y + layerHeight / 2);
				line.color = body.selectedTypeColor;
			}
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(e.getTouch(layer,"ended")) {
				click(e);
			} else if(e.interactsWith(layer)) {
				over(e);
			} else if(!e.interactsWith(layer)) {
				out(e);
			}
		}
		
		private function click(e:TouchEvent) : void {
			selected = !selected;
			var _local2:ISound = SoundLocator.getService();
			_local2.play("3hVYqbNNSUWoDGk_pK1BdQ");
			if(selected) {
				layer.addChild(imgSelected);
				g.hud.compas.addArrow(body,selectedColor);
			} else {
				layer.removeChild(imgSelected);
				g.hud.compas.removeArrow(body);
			}
			dispatchEventWith("selection");
		}
		
		private function over(e:TouchEvent) : void {
			if(hover || selected) {
				return;
			}
			hover = true;
			layer.addChild(imgHover);
		}
		
		private function out(e:TouchEvent) : void {
			if(!hover || selected) {
				return;
			}
			hover = false;
			layer.removeChild(imgHover);
		}
		
		private function clean(e:Event = null) : void {
			removeEventListeners();
			layer.removeEventListeners();
			if(g.linePool != null) {
				g.linePool.removeLine(line);
			}
		}
	}
}

