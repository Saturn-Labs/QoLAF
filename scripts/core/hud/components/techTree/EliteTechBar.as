package core.hud.components.techTree {
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
	
	public class EliteTechBar extends Sprite {
		private var g:Game;
		
		private var icon:Image;
		
		private var name:Text;
		
		private var desc:Text;
		
		private var level:Text;
		
		private var box:Box = new Box(7 * 60,2 * 60,"light",1,2);
		
		private var techSkill:TechSkill;
		
		private var eliteTech:String;
		
		public var etpm:EliteTechPopupMenu = null;
		
		private var textureManager:ITextureManager;
		
		public function EliteTechBar(g:Game, nameText:String, descText:String, iconName:String, lvl:int, eliteTech:String, techSkill:TechSkill) {
			super();
			this.g = g;
			this.techSkill = techSkill;
			this.eliteTech = eliteTech;
			textureManager = TextureLocator.getService();
			icon = new Image(textureManager.getTextureGUIByTextureName(iconName + ".png"));
			name = new Text();
			desc = new Text();
			level = new Text();
			name.color = 0xffaa44;
			name.font = "Verdana";
			name.size = 12;
			name.alignLeft();
			desc.color = 978670;
			desc.width = 6 * 60;
			desc.size = 10;
			desc.font = "Verdana";
			desc.alignLeft();
			desc.wordWrap = true;
			level.color = 0xffaa44;
			level.width = 6 * 60;
			level.size = 12;
			level.font = "Verdana";
			level.alignRight();
			icon.x = 20;
			icon.y = 15;
			name.x = icon.width + 25;
			name.y = 15;
			desc.x = 20;
			desc.y = icon.height + 15;
			name.htmlText = nameText;
			desc.htmlText = descText;
			if(lvl < 1) {
				level.htmlText = "level: 1 / 100";
			} else {
				level.htmlText = "level: " + lvl + " / 100";
			}
			level.y = 15;
			level.x = 410;
			box.alpha = 0.5;
			box.height = desc.height + 60;
			box.addChild(icon);
			box.addChild(name);
			box.addChild(desc);
			box.addChild(level);
			addChild(box);
			this.addEventListener("touch",onTouch);
		}
		
		private function mouseOver(e:TouchEvent) : void {
			box.alpha = 1;
			box.useHandCursor = true;
		}
		
		private function mouseOut(e:TouchEvent) : void {
			box.alpha = 0.5;
			box.useHandCursor = false;
		}
		
		private function mouseClick(e:TouchEvent) : void {
			var _local2:Boolean = false;
			touchable = false;
			for each(var _local3 in techSkill.eliteTechs) {
				if(_local3.eliteTech == eliteTech) {
					techSkill.activeEliteTech = _local3.eliteTech;
					techSkill.activeEliteTechLevel = _local3.eliteTechLevel;
					_local2 = true;
					break;
				}
			}
			if(!_local2) {
				techSkill.activeEliteTech = eliteTech;
				techSkill.activeEliteTechLevel = 1;
				techSkill.eliteTechs.push(new EliteTechSkill(eliteTech,1));
			}
			g.rpc("selectActiveEliteTech",updateAndClose,techSkill.table,techSkill.tech,eliteTech);
			etpm.disableAll();
		}
		
		private function updateAndClose(m:Message) : void {
			etpm.updateAndClose(m);
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(e.getTouch(this,"ended")) {
				mouseClick(e);
			} else if(e.interactsWith(this)) {
				mouseOver(e);
			} else {
				mouseOut(e);
			}
		}
		
		override public function dispose() : void {
			removeEventListeners();
			super.dispose();
		}
	}
}

