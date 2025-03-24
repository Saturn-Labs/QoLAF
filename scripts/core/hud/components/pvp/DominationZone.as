package core.hud.components.pvp {
	import com.greensock.TweenMax;
	import core.scene.Game;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	public class DominationZone {
		private var textureManager:ITextureManager;
		
		public var zoneRadius:Number = 250;
		
		public var id:int;
		
		public var name:String = "";
		
		public var ownerTeam:int;
		
		public var capCounter:int;
		
		public var nrTeam:Vector.<int> = new Vector.<int>();
		
		private var g:Game;
		
		private var friendlyZone:Image;
		
		private var neutralZone:Image;
		
		private var enemyZone:Image;
		
		private var img:Image;
		
		public var friendlyColor:uint = 255;
		
		public var neutralColor:uint = 16777215;
		
		public var enemyColor:uint = 16711680;
		
		public var x:int;
		
		public var y:int;
		
		private var oldCapCounter:int = 0;
		
		public var status:int = 0;
		
		public const STATUS_IDLE:int = 0;
		
		public const STATUS_MY_TEAM_ASSAULTING:int = 1;
		
		public const STATUS_OPPONENT_TEAM_ASSAULTING:int = 2;
		
		public function DominationZone(g:Game, obj:Object, id:int) {
			super();
			textureManager = TextureLocator.getService();
			this.g = g;
			this.id = id;
			nrTeam.push(0);
			nrTeam.push(0);
			this.x = obj.x;
			this.y = obj.y;
			friendlyZone = createZoneImg(obj,friendlyColor,"friendly");
			neutralZone = createZoneImg(obj,neutralColor,"neutral");
			enemyZone = createZoneImg(obj,enemyColor,"enemy");
			img = new Image(textureManager.getTextureByTextureName("piratebay","texture_body.png"));
			img.x = neutralZone.x - img.width / 2;
			img.y = neutralZone.y - img.height / 2 + 8;
			img.alpha = 1;
			this.g.addChildToCanvasAt(img,6);
			neutralZone.alpha = 0.25;
			this.g.addChildToCanvasAt(neutralZone,7);
			friendlyZone.alpha = 1;
			friendlyZone.scaleX = 0;
			friendlyZone.scaleY = 0;
			this.g.addChildToCanvasAt(friendlyZone,8);
			enemyZone.alpha = 1;
			enemyZone.scaleX = 0;
			enemyZone.scaleY = 0;
			this.g.addChildToCanvasAt(enemyZone,9);
			if(id == 3) {
				name = "Alpha Station";
			} else if(id == 1) {
				name = "Beta Station";
			} else if(id == 2) {
				name = "Gamma Station";
			} else if(id == 3) {
				name = "Delta Station";
			} else {
				name = "Epsilon Station";
			}
		}
		
		public function updateZone() : void {
			if(g.me == null) {
				return;
			}
			var _local1:int = g.me.team;
			var _local2:Number = Math.abs(capCounter / 10);
			if(_local1 == 0 && capCounter < 0 || _local1 == 1 && capCounter > 0) {
				TweenMax.to(enemyZone,1,{"scaleX":0});
				TweenMax.to(enemyZone,1,{"scaleY":0});
				TweenMax.to(friendlyZone,1,{"scaleX":_local2});
				TweenMax.to(friendlyZone,1,{"scaleY":_local2});
			} else if(_local1 == 0 && capCounter > 0 || _local1 == 1 && capCounter < 0) {
				TweenMax.to(friendlyZone,1,{"scaleX":0});
				TweenMax.to(friendlyZone,1,{"scaleY":0});
				TweenMax.to(enemyZone,1,{"scaleX":_local2});
				TweenMax.to(enemyZone,1,{"scaleY":_local2});
			} else {
				TweenMax.to(enemyZone,1,{"scaleX":0});
				TweenMax.to(enemyZone,1,{"scaleY":0});
				TweenMax.to(friendlyZone,1,{"scaleX":0});
				TweenMax.to(friendlyZone,1,{"scaleY":0});
			}
			if(_local1 == 0) {
				if(oldCapCounter == -10 && capCounter == -9) {
					g.textManager.createPvpText("The enemy team is assaulting " + name + "!",0,40,0xff5555);
					status = 2;
				}
				if(oldCapCounter == 10 && capCounter == 9) {
					g.textManager.createPvpText("Your team is assulting " + name + "!",0,40,0x5555ff);
					status = 1;
				}
				if(oldCapCounter == 9 && capCounter == 10) {
					g.textManager.createPvpText("The enemy team have captured " + name + "!",0,40,0xff5555);
					status = 0;
				}
				if(oldCapCounter == -9 && capCounter == -10) {
					g.textManager.createPvpText("Your team have captured " + name + "!",0,40,0x5555ff);
					status = 0;
				}
			}
			if(_local1 == 1) {
				if(oldCapCounter == -10 && capCounter == -9) {
					g.textManager.createPvpText("Your team is assaulting " + name + "!",0,40,0x5555ff);
					status = 1;
				}
				if(oldCapCounter == 10 && capCounter == 9) {
					g.textManager.createPvpText("The enemy team is assaulting " + name + "!",0,40,0xff5555);
					status = 2;
				}
				if(oldCapCounter == -9 && capCounter == -10) {
					g.textManager.createPvpText("The enemy team have captured " + name + "!",0,40,0xff5555);
					status = 0;
				}
				if(oldCapCounter == 9 && capCounter == 10) {
					g.textManager.createPvpText("Your team have captured " + name + "!",0,40,0x5555ff);
					status = 0;
				}
			}
			oldCapCounter = capCounter;
		}
		
		public function getMiniZone() : Image {
			var _local4:Image = null;
			var _local2:* = 0;
			_local2 = 0xffffff;
			var _local3:Sprite = new Sprite();
			_local3.graphics.lineStyle(1,_local2,0.2);
			var _local5:String = "radial";
			var _local8:Array = [0,_local2];
			var _local6:Array = [0,0.6];
			var _local7:Array = [0,255];
			var _local1:Matrix = new Matrix();
			_local1.createGradientBox(40,40,0,-20,-20);
			_local3.graphics.beginGradientFill(_local5,_local8,_local6,_local7,_local1);
			_local3.graphics.drawCircle(0,0,20);
			_local3.graphics.endFill();
			_local4 = TextureManager.imageFromSprite(_local3,name);
			_local4.x = x;
			_local4.y = y;
			_local4.pivotX = _local4.width / 2;
			_local4.pivotY = _local4.height / 2;
			_local4.scaleX = 1;
			_local4.scaleY = 1;
			_local4.alpha = 1;
			_local4.blendMode = "add";
			return _local4;
		}
		
		private function createZoneImg(obj:Object, colour:uint, name:String) : Image {
			var _local6:Image = null;
			var _local5:Sprite = new Sprite();
			_local5.graphics.lineStyle(1,colour,0.2);
			var _local7:String = "radial";
			var _local10:Array = [0,colour];
			var _local8:Array = [0,0.6];
			var _local9:Array = [0,255];
			var _local4:Matrix = new Matrix();
			_local4.createGradientBox(2 * zoneRadius,2 * zoneRadius,0,-zoneRadius,-zoneRadius);
			_local5.graphics.beginGradientFill(_local7,_local10,_local8,_local9,_local4);
			_local5.graphics.drawCircle(0,0,zoneRadius);
			_local5.graphics.endFill();
			_local6 = TextureManager.imageFromSprite(_local5,name);
			_local6.x = x;
			_local6.y = y;
			_local6.pivotX = _local6.width / 2;
			_local6.pivotY = _local6.height / 2;
			_local6.scaleX = 1;
			_local6.scaleY = 1;
			_local6.alpha = 0.25;
			_local6.blendMode = "add";
			return _local6;
		}
	}
}

