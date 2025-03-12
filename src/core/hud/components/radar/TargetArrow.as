package core.hud.components.radar
{
	import com.greensock.TweenMax;
	import core.GameObject;
	import core.scene.Game;
	import flash.geom.Point;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class TargetArrow extends Sprite
	{
		public var target:GameObject;
		
		private var g:Game;
		
		private var tween:TweenMax;
		
		public function TargetArrow(param1:Game, param2:GameObject, param3:uint)
		{
			super();
			this.g = param1;
			this.target = param2;
			var _loc4_:ITextureManager = TextureLocator.getService();
			var _loc6_:Texture = _loc4_.getTextureGUIByTextureName("map_arrow");
			var _loc5_:Image = new Image(_loc6_);
			_loc5_.color = param3;
			addChild(_loc5_);
			_loc5_.blendMode = "add";
			pivotX = width / 2;
			pivotY = height / 2;
		}
		
		public function activate():void
		{
			this.scaleX = 1;
			this.scaleY = 1;
			tween = TweenMax.to(this, 0.5, {"yoyo": true, "repeat": -1, "scaleX": 2, "scaleY": 2});
		}
		
		public function deactivate():void
		{
			if (tween != null)
			{
				tween.kill();
			}
		}
		
		public function update():void
		{
			var _loc3_:Point = g.camera.getCameraCenter();
			var _loc2_:Point = target.pos;
			if (g.camera.isOnScreen(target.pos.x, target.pos.y))
			{
				visible = false;
			}
			else
			{
				visible = true;
			}
			var _loc1_:Point = _loc2_.subtract(_loc3_);
			_loc1_.normalize(1);
			rotation = Math.atan2(_loc1_.y, _loc1_.x);
			x = _loc3_.x + _loc1_.x * g.stage.stageWidth / 3;
			y = _loc3_.y + _loc1_.y * g.stage.stageHeight / 3;
		}
	}
}
