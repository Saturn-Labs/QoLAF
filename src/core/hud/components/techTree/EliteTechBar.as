package core.hud.components.techTree
{
	import core.hud.components.Box;
	import core.hud.components.Text;
	import core.player.EliteTechSkill;
	import core.player.TechSkill;
	import core.scene.Game;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;

	public class EliteTechBar extends Sprite
	{
		private var g:Game;
		private var icon:Image;
		private var _name:Text;
		private var desc:Text;
		private var level:Text;
		private var box:Box;
		private var techSkill:TechSkill;
		private var eliteTech:String;
		public var etpm:EliteTechPopupMenu = null;
		private var textureManager:ITextureManager;
		public function EliteTechBar(param1:Game, param2:String, param3:String, param4:String, param5:int, param6:String, param7:TechSkill)
		{
			box = new Box(420, 120, "light", 1, 2);
			super();
			this.g = param1;
			this.techSkill = param7;
			this.eliteTech = param6;
			textureManager = TextureLocator.getService();
			icon = new Image(textureManager.getTextureGUIByTextureName(param4 + ".png"));
			_name = new Text();
			desc = new Text();
			level = new Text();
			_name.color = 16755268;
			_name.font = "Verdana";
			_name.size = 12;
			_name.alignLeft();
			desc.color = 978670;
			desc.width = 360;
			desc.size = 10;
			desc.font = "Verdana";
			desc.alignLeft();
			desc.wordWrap = true;
			level.color = 16755268;
			level.width = 360;
			level.size = 12;
			level.font = "Verdana";
			level.alignRight();
			icon.x = 20;
			icon.y = 15;
			_name.x = icon.width + 25;
			_name.y = 15;
			desc.x = 20;
			desc.y = icon.height + 15;
			_name.htmlText = param2;
			desc.htmlText = param3;
			if (param5 < 1)
			{
				level.htmlText = "level: 1 / 100";
			}
			else
			{
				level.htmlText = "level: " + param5 + " / 100";
			}
			level.y = 15;
			level.x = 410;
			box.alpha = 0.5;
			box.height = desc.height + 60;
			box.addChild(icon);
			box.addChild(_name);
			box.addChild(desc);
			box.addChild(level);
			addChild(box);
			this.addEventListener("touch", onTouch);
		}

		private function mouseOver(param1:TouchEvent):void
		{
			box.alpha = 1;
			box.useHandCursor = true;
		}

		private function mouseOut(param1:TouchEvent):void
		{
			box.alpha = 0.5;
			box.useHandCursor = false;
		}

		private function mouseClick(param1:TouchEvent):void
		{
			var _loc2_:Boolean = false;
			touchable = false;
			for each (var _loc3_:* in techSkill.eliteTechs)
			{
				if (_loc3_.eliteTech == eliteTech)
				{
					techSkill.activeEliteTech = _loc3_.eliteTech;
					techSkill.activeEliteTechLevel = _loc3_.eliteTechLevel;
					_loc2_ = true;
					break;
				}
			}
			if (!_loc2_)
			{
				techSkill.activeEliteTech = eliteTech;
				techSkill.activeEliteTechLevel = 1;
				techSkill.eliteTechs.push(new EliteTechSkill(eliteTech, 1));
			}
			g.rpc("selectActiveEliteTech", updateAndClose, techSkill.table, techSkill.tech, eliteTech);
			etpm.disableAll();
		}

		private function updateAndClose(param1:Message):void
		{
			etpm.updateAndClose(param1);
		}

		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(this, "ended"))
			{
				mouseClick(param1);
			}
			else if (param1.interactsWith(this))
			{
				mouseOver(param1);
			}
			else
			{
				mouseOut(param1);
			}
		}

		override public function dispose():void
		{
			removeEventListeners();
			super.dispose();
		}
	}
}
