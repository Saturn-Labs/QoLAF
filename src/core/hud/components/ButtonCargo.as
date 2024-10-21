package core.hud.components
{
	import com.greensock.TweenMax;
	import core.scene.Game;
	import generics.Localize;
	import starling.display.Image;
	import starling.filters.GlowFilter;
	
	public class ButtonCargo extends ButtonHud
	{
		public static var serverSaysCargoIsFull:Boolean = false;
		
		private var capacityBar:Image;
		
		private var g:Game;
		
		private var fadeTween:TweenMax;
		
		private var text:TextBitmap;
		
		public function ButtonCargo(param1:Game, param2:Function)
		{
			super(param2, "button_cargo.png", null);
			this.g = param1;
			capacityBar = new Image(param1.textureManager.getTextureGUIByTextureName("capacity_bar"));
			capacityBar.color = 16729156;
			addChild(capacityBar);
			text = new TextBitmap();
			text.text = Localize.t("Cargo is full!");
			text.size = 26;
			text.touchable = false;
			text.batchable = true;
			text.y = -30;
			text.x = 0;
			update();
		}
		
		public function update():void
		{
			var perc:Number = g.myCargo.spaceJunkCount / g.myCargo.compressorCapacities[g.me.compressorLevel];
			perc = perc > 1 ? 1 : perc;
			if (perc < 0.5)
			{
				capacityBar.color = 4521796;
			}
			else if (perc < 0.75)
			{
				capacityBar.color = 16777028;
			}
			else
			{
				capacityBar.color = 16729156;
			}
			capacityBar.height = perc * 15;
			if (g.myCargo.isFull || serverSaysCargoIsFull)
			{
				g.tutorial.showCargoAdvice();
				capacityBar.blendMode = "add";
				if (!capacityBar.filter)
				{
					capacityBar.filter = new GlowFilter(16729156, 1, 7);
					capacityBar.filter.cache();
				}
				fadeTween = TweenMax.fromTo(capacityBar, 0.5, {"alpha": 1}, {"alpha": 0.5, "repeat": -1, "yoyo": true, "onUpdate": function():void
				{
					text.alpha = capacityBar.alpha;
				}});
				if (!contains(text))
				{
					addChild(text);
				}
			}
			else
			{
				if (contains(text))
				{
					removeChild(text);
				}
				if (fadeTween)
				{
					fadeTween.kill();
					fadeTween = null;
				}
				capacityBar.alpha = 1;
				if (capacityBar.filter)
				{
					capacityBar.filter.dispose();
					capacityBar.filter = null;
				}
				capacityBar.blendMode = "normal";
			}
			capacityBar.y = 20 - capacityBar.height;
			capacityBar.x = 22;
		}
	}
}
