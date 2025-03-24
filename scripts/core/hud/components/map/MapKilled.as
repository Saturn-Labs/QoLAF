package core.hud.components.map {
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	import core.scene.Game;
	import core.states.player.Killed;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class MapKilled {
		private var scale:Number = 0.4;
		
		private var layer:Sprite = new Sprite();
		
		private var scull:Image;
		
		private var g:Game;
		
		private var timeLeftOnKillAnimation:Number = 0;
		
		private const dropShowTime:Number = 60000;
		
		private var isRunningAnimation:Boolean = false;
		
		private var tween1:TweenMax;
		
		private var tween2:TweenMax;
		
		public function MapKilled(container:Sprite, g:Game) {
			super();
			this.g = g;
			container.addChild(layer);
			layer.touchable = false;
			var _local3:ITextureManager = TextureLocator.getService();
			scull = new Image(_local3.getTextureGUIByTextureName("radar_lastkill.png"));
			scull.pivotX = scull.width / 2;
			scull.pivotY = scull.height / 2;
			layer.addChild(scull);
			scull.visible = false;
			layer.addEventListener("removedFromStage",clean);
		}
		
		public function update() : void {
			timeLeftOnKillAnimation = Killed.killedTime + 60 * 1000 - g.time;
			if(timeLeftOnKillAnimation > 0 && !g.solarSystem.isPvpSystemInEditor) {
				if(isRunningAnimation) {
					return;
				}
				layer.x = Killed.killedPosition.x * Map.SCALE;
				layer.y = Killed.killedPosition.y * Map.SCALE;
				startAnimation();
			} else if(isRunningAnimation) {
				clean();
			}
		}
		
		private function startAnimation() : void {
			isRunningAnimation = true;
			scull.alpha = 1;
			scull.visible = true;
			tween1 = TweenMax.to(scull,0.5,{
				"yoyo":true,
				"scaleX":1.15,
				"repeat":-1,
				"alpha":0.5,
				"ease":Sine.easeInOut
			});
			tween2 = TweenMax.to(scull,0.5,{
				"yoyo":true,
				"scaleY":1.15,
				"delay":-1,
				"repeat":-1,
				"ease":Sine.easeInOut
			});
		}
		
		public function clean(e:Event = null) : void {
			if(tween1 != null) {
				tween1.kill();
				tween1 = null;
			}
			if(tween2 != null) {
				tween2.kill();
				tween2 = null;
			}
			scull.visible = false;
			isRunningAnimation = false;
		}
	}
}

