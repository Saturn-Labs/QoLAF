package core.hud.components {
	import core.player.Player;
	import core.scene.Game;
	import core.weapon.Heat;
	import generics.Localize;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class PowerBar extends DisplayObjectContainer {
		private static const HEAT_WIDTH:Number = 120;
		private static const SMOOTHER_STEPS:int = 5;
		private var heatNumber:TextField;
		private var g:Game;
		private var smoother:Vector.<Number> = new Vector.<Number>();
		private var soundManager:ISound;
		private const colorRed:uint = 16724770;
		private const colorBlue:uint = 4474111;
		private var heatBar:Image;
		private var loadBar:Image;
		private var heatBarBgr:Image;
		private var turnedLow:Boolean = false;
		private var turnedOut:Boolean = false;
		
		public function PowerBar(g:Game) {
			super();
			this.g = g;
		}
		
		public function load() : void {
			var _local3:int = 0;
			var _local1:ITextureManager = TextureLocator.getService();
			heatBar = new Image(_local1.getTextureGUIByTextureName("power_bar_white"));
			heatBar.color = 4474111;
			loadBar = new Image(_local1.getTextureGUIByTextureName("power_bar_white"));
			loadBar.scaleX = 0;
			loadBar.alpha = 0.5;
			heatBarBgr = new Image(_local1.getTextureGUIByTextureName("power_bar_white"));
			heatBarBgr.color = 0x55333333;
			var _local2:Image = new Image(_local1.getTextureGUIByTextureName("text_power"));
			_local2.y = 5;
			_local2.x = 7;
			heatNumber = new TextField(40,16,"",new TextFormat("font13",13,12113919,"right"));
			heatNumber.batchable = true;
			heatBarBgr.y = -2;
			heatBarBgr.x = 0;
			heatBar.y = -1;
			heatBar.x = 2;
			loadBar.y = heatBar.y;
			loadBar.x = heatBar.x;
			_local3 = 0;
			while(_local3 < 5 - 1) {
				smoother.push(0.04 * (2 * 60));
				_local3++;
			}
			addChild(heatBarBgr);
			addChild(heatBar);
			addChild(loadBar);
			addChild(_local2);
			addChild(heatNumber);
			heatNumber.x = 2 * 60 - 43;
			heatNumber.y = 1;
			soundManager = SoundLocator.getService();
			new ToolTip(g,this,Localize.t("You need <FONT COLOR=\'#8888ff\'>POWER</FONT> to fire your weapons."),null,"power bar");
		}
		
		public function update() : void {
			var _local4:int = 0;
			var _local2:Player = g.playerManager.me;
			if(_local2.ship == null) {
				return;
			}
			var _local3:Heat = _local2.ship.weaponHeat;
			if(_local3 == null) {
				return;
			}
			var _local1:String = Math.round(_local3.heat * 100).toString();
			if(_local3.heat >= 0.4) {
				heatBar.color = 4474111;
				turnedLow = false;
				turnedOut = false;
			} else {
				if(!turnedLow) {
					turnedLow = true;
					soundManager.play("-8O67HBaKUy4hBaS3liNqw");
				} else if(_local3.heat < 0.05 && !turnedOut) {
					turnedOut = true;
					soundManager.play("mwJAopTgkUmewtewTWjqCg");
				}
				heatBar.color = 16724770;
			}
			heatNumber.text = _local1;
			smoother.push(2 * 60 * (_local3.heat / _local3.max) * 0.96 + 0.04 * (2 * 60));
			heatBar.width = 0;
			_local4 = 0;
			while(_local4 < 5) {
				heatBar.width += 1 / 5 * smoother[_local4];
				_local4++;
			}
			smoother.shift();
		}
		
		public function updateLoadBar(value:Number) : void {
			if(loadBar != null) {
				loadBar.scaleX = value;
			}
		}
	}
}

