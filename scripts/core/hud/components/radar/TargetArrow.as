package core.hud.components.radar {
	import com.greensock.TweenMax;
	import core.GameObject;
	import core.scene.Game;
	import flash.geom.Point;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class TargetArrow extends Sprite {
		public var target:GameObject;
		
		private var g:Game;
		
		private var tween:TweenMax;
		
		public function TargetArrow(g:Game, target:GameObject, color:uint) {
			super();
			this.g = g;
			this.target = target;
			var _local6:ITextureManager = TextureLocator.getService();
			var _local5:Texture = _local6.getTextureGUIByTextureName("map_arrow");
			var _local4:Image = new Image(_local5);
			_local4.color = color;
			addChild(_local4);
			_local4.blendMode = "add";
			pivotX = width / 2;
			pivotY = height / 2;
		}
		
		public function activate() : void {
			this.scaleX = 1;
			this.scaleY = 1;
			tween = TweenMax.to(this,0.5,{
				"yoyo":true,
				"repeat":-1,
				"scaleX":2,
				"scaleY":2
			});
		}
		
		public function deactivate() : void {
			if(tween != null) {
				tween.kill();
			}
		}
		
		public function update() : void {
			var _local1:Point = g.camera.getCameraCenter();
			var _local2:Point = target.pos;
			if(g.camera.isOnScreen(target.pos.x,target.pos.y)) {
				visible = false;
			} else {
				visible = true;
			}
			var _local3:Point = _local2.subtract(_local1);
			_local3.normalize(1);
			rotation = Math.atan2(_local3.y,_local3.x);
			x = _local1.x + _local3.x * g.stage.stageWidth / 3;
			y = _local1.y + _local3.y * g.stage.stageHeight / 3;
		}
	}
}

