package core.artifact
{
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
	
	public class ArtifactBox extends Sprite
	{
		private var p:Player;
		
		private var g:Game;
		
		public var a:Artifact;
		
		private var textureManager:ITextureManager;
		
		private var artifactImage:Image;
		
		private var frame:Image;
		
		private var toolTip:ToolTip;
		
		private var colors:Array;
		
		public var locked:Boolean;
		
		public var unlockable:Boolean;
		
		public var slot:int;
		
		public function ArtifactBox(param1:Game, param2:Artifact)
		{
			colors = [11184810, 4491519, 4517444, 16729343, 16761634];
			super();
			this.g = param1;
			this.p = param1.me;
			this.a = param2;
			toolTip = new ToolTip(param1, this, "", null, "artifactBox");
			textureManager = TextureLocator.getService();
		}
		
		public function update():void
		{
			removeChildren();
			drawFrame();
			toolTip.text = "";
			useHandCursor = false;
			removeEventListener("touch", onTouch);
			if (locked)
			{
				setLocked();
				if (unlockable)
				{
					toolTip.text = "Locked slot, click to buy.";
					addListeners();
				}
			}
			else if (a != null)
			{
				setArtifact();
				addListeners();
				addUpgradeIcon();
			}
		}
		
		private function addUpgradeIcon():void
		{
			var _loc1_:Image = null;
			if (a.upgrading)
			{
				_loc1_ = new Image(textureManager.getTextureGUIByTextureName("upgrading"));
			}
			else if (a.upgraded >= 10)
			{
				_loc1_ = new Image(textureManager.getTextureGUIByTextureName("upgraded_max"));
			}
			else if (a.upgraded > 6)
			{
				_loc1_ = new Image(textureManager.getTextureGUIByTextureName("upgraded3"));
			}
			else if (a.upgraded > 3)
			{
				_loc1_ = new Image(textureManager.getTextureGUIByTextureName("upgraded2"));
			}
			else if (a.upgraded > 0)
			{
				_loc1_ = new Image(textureManager.getTextureGUIByTextureName("upgraded"));
			}
			if (_loc1_ != null)
			{
				_loc1_.x = 35;
				_loc1_.y = 11;
				addChild(_loc1_);
			}
		}
		
		private function drawFrame():void
		{
			frame = new Image(textureManager.getTextureGUIByTextureName("artifact_box"));
			addChild(frame);
		}
		
		private function setArtifact():void
		{
			var _loc4_:int = 0;
			var _loc3_:CrewMember = null;
			var _loc2_:String = null;
			frame.filter = new GlowFilter(16777215, 1, 8, 1);
			frame.filter.cache();
			artifactImage = new Image(textureManager.getTextureGUIByKey(a.bitmap));
			addChild(artifactImage);
			artifactImage.pivotX = artifactImage.width / 2;
			artifactImage.pivotY = artifactImage.height / 2;
			artifactImage.x = 8 + artifactImage.width / 2 * 0.5;
			artifactImage.y = 8 + artifactImage.height / 2 * 0.5;
			artifactImage.scaleX = 0;
			artifactImage.scaleY = 0;
			TweenMax.to(artifactImage, 0.3, {"scaleX": 0.5, "scaleY": 0.5});
			if (!a.revealed)
			{
				toolTip.text = "Click to reveal!";
				return;
			}
			_loc4_ = 0;
			while (_loc4_ < p.crewMembers.length)
			{
				_loc3_ = p.crewMembers[_loc4_];
				if (_loc3_.artifact == a.id)
				{
					a.upgradeTime = _loc3_.artifactEnd;
				}
				_loc4_++;
			}
			_loc2_ = "<font color='#ffaa44'>" + a.name + "</font><br>Level " + a.levelPotential + ", strength " + a.level + "<br>";
			if (a.upgraded > 0)
			{
				_loc2_ += a.upgraded + " upgrades<br>";
			}
			if (a.upgrading)
			{
				_loc2_ += "Upgrading: " + Util.getFormattedTime(a.upgradeTime - g.time) + "<br>";
			}
			for each (var _loc1_:* in a.stats)
			{
				_loc2_ += ArtifactStat.parseTextFromStatType(_loc1_.type, _loc1_.value) + "<br>";
			}
			toolTip.text = _loc2_;
			toolTip.color = a.getColor();
		}
		
		private function setLocked():void
		{
			var _loc1_:Image = new Image(textureManager.getTextureGUIByTextureName("lock"));
			_loc1_.scaleX = _loc1_.scaleY = 1.2;
			_loc1_.x = 16;
			_loc1_.y = 12;
			addChild(_loc1_);
		}
		
		private function addListeners():void
		{
			useHandCursor = true;
			addEventListener("touch", onTouch);
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(this, "ended"))
			{
				onClick(param1);
			}
		}
		
		private function onClick(param1:TouchEvent):void
		{
			if (locked && unlockable)
			{
				dispatchEventWith("artifactSlotUnlock", true);
			}
			else
			{
				dispatchEventWith("activeArtifactRemoved", true);
			}
		}
		
		public function get isEmpty():Boolean
		{
			return a == null;
		}
		
		public function setEmpty():void
		{
			a = null;
			update();
		}
		
		public function setActive(param1:Artifact):void
		{
			this.a = param1;
			update();
		}
		
		override public function dispose():void
		{
			if (frame && frame.filter)
			{
				frame.filter.dispose();
				frame.filter = null;
			}
			super.dispose();
		}
	}
}
