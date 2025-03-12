package core.hud.components.map
{
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
	
	public class MapBodyBase extends starling.display.Sprite
	{
		protected var radius:Number = 5;
		protected var body:Body;
		
		protected var layer:starling.display.Sprite;
		
		protected var orbits:starling.display.Sprite;
		
		protected var crew:starling.display.Sprite;
		
		public var selected:Boolean = false;
		protected var hover:Boolean;
		
		protected var text:TextBitmap;
		
		protected var percentage:TextBitmap;
		
		protected var line:Line;
		
		protected var imgHover:Image;
		
		protected var imgSelected:Image;
		
		protected var selectedColor:uint = 11184895;
		protected var g:Game;
		
		protected var textureManager:ITextureManager;
		
		private var layerHeight:Number;
		
		private var layerWidth:Number;
		
		private var textWidth:Number;
		
		public function MapBodyBase(param1:Game, param2:starling.display.Sprite, param3:Body)
		{
			layer = new starling.display.Sprite();
			orbits = new starling.display.Sprite();
			crew = new starling.display.Sprite();
			text = new TextBitmap();
			percentage = new TextBitmap();
			super();
			this.g = param1;
			this.body = param3;
			text.touchable = percentage.touchable = false;
			text.batchable = true;
			line = param1.linePool.getLine();
			line.init("line1", 5);
			line.touchable = false;
			textureManager = TextureLocator.getService();
			selectedColor = param3.selectedTypeColor;
			param2.addChildAt(orbits, 0);
			param2.addChildAt(line, 1);
			param2.addChild(layer);
			if (param3.type != "sun" || param3.type != "warning")
			{
				layer.addEventListener("touch", onTouch);
			}
			layer.addEventListener("removedFromStage", clean);
		}
		
		protected function init():void
		{
			layerHeight = layer.height;
			layerWidth = layer.width;
			textWidth = text.width;
		}
		
		protected function addOrbits():void
		{
			if (body.children.length == 0)
			{
				return;
			}
			var _loc3_:flash.display.Sprite = new flash.display.Sprite();
			_loc3_.graphics.lineStyle(1.5, 49151, 0.3);
			for each (var _loc1_:* in body.children)
			{
				if (!(_loc1_.type == "comet" || _loc1_.type == "hidden" || _loc1_.type == "boss" || _loc1_.type == "warning"))
				{
					_loc3_.graphics.drawCircle(radius, radius, _loc1_.course.orbitRadius * Map.SCALE);
				}
			}
			_loc3_.graphics.endFill();
			if (_loc3_.width == 0)
			{
				return;
			}
			var _loc2_:Image = TextureManager.imageFromSprite(_loc3_, body.key);
			_loc2_.touchable = false;
			orbits.addChild(_loc2_);
		}
		
		public function update():void
		{
			layer.x = body.pos.x * Map.SCALE - radius;
			layer.y = body.pos.y * Map.SCALE - radius;
			text.x = layer.x - textWidth / 2 + layerHeight / 2;
			text.y = layer.y + layer.height;
			percentage.x = text.x + textWidth + 2;
			percentage.y = text.y;
			crew.x = layer.x + layerWidth + 5;
			crew.y = layer.y - 5;
			if (orbits.numChildren > 0)
			{
				orbits.x = body.pos.x * Map.SCALE - radius;
				orbits.y = body.pos.y * Map.SCALE - radius;
			}
			line.visible = false;
			if (selected && (body.pos.x != g.me.ship.x || body.pos.y != g.me.ship.y))
			{
				line.visible = true;
				line.x = g.me.ship.x * Map.SCALE;
				line.y = g.me.ship.y * Map.SCALE;
				line.lineTo(layer.x + layerWidth / 2, layer.y + layerHeight / 2);
				line.color = body.selectedTypeColor;
			}
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(layer, "ended"))
			{
				click(param1);
			}
			else if (param1.interactsWith(layer))
			{
				over(param1);
			}
			else if (!param1.interactsWith(layer))
			{
				out(param1);
			}
		}
		
		private function click(param1:TouchEvent):void
		{
			selected = !selected;
			var _loc2_:ISound = SoundLocator.getService();
			_loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
			if (selected)
			{
				layer.addChild(imgSelected);
				g.hud.compas.addArrow(body, selectedColor);
			}
			else
			{
				layer.removeChild(imgSelected);
				g.hud.compas.removeArrow(body);
			}
			dispatchEventWith("selection");
		}
		
		private function over(param1:TouchEvent):void
		{
			if (hover || selected)
			{
				return;
			}
			hover = true;
			layer.addChild(imgHover);
		}
		
		private function out(param1:TouchEvent):void
		{
			if (!hover || selected)
			{
				return;
			}
			hover = false;
			layer.removeChild(imgHover);
		}
		
		private function clean(param1:Event = null):void
		{
			removeEventListeners();
			layer.removeEventListeners();
			if (g.linePool != null)
			{
				g.linePool.removeLine(line);
			}
		}
	}
}
