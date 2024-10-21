package core.hud.components
{
	import core.scene.Game;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.filters.ColorMatrixFilter;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewBuySlot extends Sprite
	{
		private static const HEIGHT:int = 58;
		
		private static const WIDTH:int = 52;
		
		private var box:Quad;
		
		private var img:Image;
		
		private var g:Game;
		
		private var bgColor:uint = 1717572;
		
		private var isSelected:Boolean = false;
		
		private var hovering:Boolean = false;
		
		public function CrewBuySlot(param1:Game)
		{
			super();
			this.g = param1;
			box = new Quad(273, 58, bgColor);
			addChild(box);
			var _loc4_:Text = new Text(60, 20);
			_loc4_.text = "Empty slot";
			_loc4_.color = 16623682;
			_loc4_.size = 14;
			addChild(_loc4_);
			var _loc3_:ITextureManager = TextureLocator.getService();
			img = new Image(_loc3_.getTextureGUIByKey("xsUjTub_WUKwn9VSbMrrbg"));
			img.height = 58;
			img.width = 52;
			var _loc2_:ColorMatrixFilter = new ColorMatrixFilter();
			_loc2_.adjustSaturation(-1);
			_loc2_.adjustBrightness(-0.35);
			_loc2_.adjustHue(0.75);
			img.filter = _loc2_;
			img.filter.cache();
			addChild(img);
			addEventListener("touch", onTouch);
			setSelected(false);
			addEventListener("removedFromStage", clean);
		}
		
		public function setSelected(param1:Boolean):void
		{
			param1 ? (box.alpha = 1) : (box.alpha = 0);
			isSelected = param1;
			if (!param1)
			{
				return;
			}
			dispatchEventWith("crewSelected", true);
		}
		
		private function onClick(param1:TouchEvent = null):void
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < parent.numChildren)
			{
				if (parent.getChildAt(_loc2_) is CrewDisplayBoxNew)
				{
					(parent.getChildAt(_loc2_) as CrewDisplayBoxNew).setSelected(false);
				}
				if (parent.getChildAt(_loc2_) is CrewBuySlot)
				{
					(parent.getChildAt(_loc2_) as CrewBuySlot).setSelected(false);
				}
				_loc2_++;
			}
			setSelected(true);
		}
		
		public function mOver(param1:TouchEvent):void
		{
			if (hovering)
			{
				return;
			}
			hovering = true;
			if (isSelected)
			{
				return;
			}
			box.alpha = 0.6;
		}
		
		public function mOut(param1:TouchEvent):void
		{
			if (!hovering)
			{
				return;
			}
			hovering = false;
			if (isSelected)
			{
				box.alpha = 1;
				return;
			}
			box.alpha = 0;
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(this, "ended"))
			{
				onClick(param1);
			}
			else if (param1.interactsWith(this))
			{
				mOver(param1);
			}
			else if (!param1.interactsWith(this))
			{
				mOut(param1);
			}
		}
		
		public function clean(param1:Event = null):void
		{
			removeEventListener("touch", onTouch);
			removeEventListener("removedFromStage", clean);
		}
	}
}