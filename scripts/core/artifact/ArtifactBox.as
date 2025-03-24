package core.artifact {
	import com.greensock.TweenMax;
	import core.hud.components.ToolTip;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import generics.Util;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.filters.GlowFilter;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ArtifactBox extends Sprite {
		private var p:Player;
		
		private var g:Game;
		
		public var a:Artifact;
		
		private var textureManager:ITextureManager;
		
		private var artifactImage:Image;
		
		private var frame:Image;
		
		private var toolTip:ToolTip;
		
		private var colors:Array = [0xaaaaaa,0x4488ff,0x44ee44,0xff44ff,16761634];
		
		public var locked:Boolean;
		
		public var unlockable:Boolean;
		
		public var slot:int;
		
		public function ArtifactBox(g:Game, a:Artifact) {
			super();
			this.g = g;
			this.p = g.me;
			this.a = a;
			toolTip = new ToolTip(g,this,"",null,"artifactBox");
			textureManager = TextureLocator.getService();
		}
		
		public function update() : void {
			removeChildren();
			drawFrame();
			toolTip.text = "";
			useHandCursor = false;
			removeEventListener("touch",onTouch);
			if(locked) {
				setLocked();
				if(unlockable) {
					toolTip.text = "Locked slot, click to buy.";
					addListeners();
				}
			} else if(a != null) {
				setArtifact();
				addListeners();
				addUpgradeIcon();
			}
		}
		
		private function addUpgradeIcon() : void {
			var _local1:Image = null;
			if(a.upgrading) {
				_local1 = new Image(textureManager.getTextureGUIByTextureName("upgrading"));
			} else if(a.upgraded >= 10) {
				_local1 = new Image(textureManager.getTextureGUIByTextureName("upgraded_max"));
			} else if(a.upgraded > 6) {
				_local1 = new Image(textureManager.getTextureGUIByTextureName("upgraded3"));
			} else if(a.upgraded > 3) {
				_local1 = new Image(textureManager.getTextureGUIByTextureName("upgraded2"));
			} else if(a.upgraded > 0) {
				_local1 = new Image(textureManager.getTextureGUIByTextureName("upgraded"));
			}
			if(_local1 != null) {
				_local1.x = 35;
				_local1.y = 11;
				addChild(_local1);
			}
		}
		
		private function drawFrame() : void {
			frame = new Image(textureManager.getTextureGUIByTextureName("artifact_box"));
			addChild(frame);
		}
		
		private function setArtifact() : void {
			var _local2:int = 0;
			var _local3:CrewMember = null;
			var _local4:String = null;
			frame.filter = new GlowFilter(0xffffff,1,8,1);
			frame.filter.cache();
			artifactImage = new Image(textureManager.getTextureGUIByKey(a.bitmap));
			addChild(artifactImage);
			artifactImage.pivotX = artifactImage.width / 2;
			artifactImage.pivotY = artifactImage.height / 2;
			artifactImage.x = 8 + artifactImage.width / 2 * 0.5;
			artifactImage.y = 8 + artifactImage.height / 2 * 0.5;
			artifactImage.scaleX = 0;
			artifactImage.scaleY = 0;
			TweenMax.to(artifactImage,0.3,{
				"scaleX":0.5,
				"scaleY":0.5
			});
			if(!a.revealed) {
				toolTip.text = "Click to reveal!";
				return;
			}
			_local2 = 0;
			while(_local2 < p.crewMembers.length) {
				_local3 = p.crewMembers[_local2];
				if(_local3.artifact == a.id) {
					a.upgradeTime = _local3.artifactEnd;
				}
				_local2++;
			}
			_local4 = a.name + "<br>Level " + a.levelPotential + ", strength " + a.level + "<br>";
			if(a.upgraded > 0) {
				_local4 += a.upgraded + " upgrades<br>";
			}
			if(a.upgrading) {
				_local4 += "Upgrading: " + Util.getFormattedTime(a.upgradeTime - g.time) + "<br>";
			}
			for each(var _local1 in a.stats) {
				_local4 += ArtifactStat.parseTextFromStatType(_local1.type,_local1.value,_local1.isUnique) + "<br>";
			}
			toolTip.text = _local4;
			toolTip.color = a.getColor();
		}
		
		private function setLocked() : void {
			var _local1:Image = new Image(textureManager.getTextureGUIByTextureName("lock"));
			_local1.scaleX = _local1.scaleY = 1.2;
			_local1.x = 16;
			_local1.y = 12;
			addChild(_local1);
		}
		
		private function addListeners() : void {
			useHandCursor = true;
			addEventListener("touch",onTouch);
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(e.getTouch(this,"ended")) {
				onClick(e);
			}
		}
		
		private function onClick(e:TouchEvent) : void {
			if(locked && unlockable) {
				dispatchEventWith("artifactSlotUnlock",true);
			} else {
				dispatchEventWith("activeArtifactRemoved",true);
			}
		}
		
		public function get isEmpty() : Boolean {
			return a == null;
		}
		
		public function setEmpty() : void {
			a = null;
			update();
		}
		
		public function setActive(a:Artifact) : void {
			this.a = a;
			update();
		}
		
		override public function dispose() : void {
			if(frame && frame.filter) {
				frame.filter.dispose();
				frame.filter = null;
			}
			super.dispose();
		}
	}
}

