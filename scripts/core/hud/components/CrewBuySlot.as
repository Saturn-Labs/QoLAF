package core.hud.components {
	import core.scene.Game;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.filters.ColorMatrixFilter;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewBuySlot extends Sprite {
		private static const HEIGHT:int = 58;
		
		private static const WIDTH:int = 52;
		
		private var box:Quad;
		
		private var img:Image;
		
		private var g:Game;
		
		private var bgColor:uint = 1717572;
		
		private var isSelected:Boolean = false;
		
		private var hovering:Boolean = false;
		
		public function CrewBuySlot(g:Game) {
			super();
			this.g = g;
			box = new Quad(273,58,bgColor);
			addChild(box);
			var _local2:Text = new Text(60,20);
			_local2.text = "Empty slot";
			_local2.color = 16623682;
			_local2.size = 14;
			addChild(_local2);
			var _local3:ITextureManager = TextureLocator.getService();
			img = new Image(_local3.getTextureGUIByKey("xsUjTub_WUKwn9VSbMrrbg"));
			img.height = 58;
			img.width = 52;
			var _local4:ColorMatrixFilter = new ColorMatrixFilter();
			_local4.adjustSaturation(-1);
			_local4.adjustBrightness(-0.35);
			_local4.adjustHue(0.75);
			img.filter = _local4;
			img.filter.cache();
			addChild(img);
			addEventListener("touch",onTouch);
			setSelected(false);
			addEventListener("removedFromStage",clean);
		}
		
		public function setSelected(value:Boolean) : void {
			value ? (box.alpha = 1) : (box.alpha = 0);
			isSelected = value;
			if(!value) {
				return;
			}
			dispatchEventWith("crewSelected",true);
		}
		
		private function onClick(e:TouchEvent = null) : void {
			var _local2:int = 0;
			_local2 = 0;
			while(_local2 < parent.numChildren) {
				if(parent.getChildAt(_local2) is CrewDisplayBoxNew) {
					(parent.getChildAt(_local2) as CrewDisplayBoxNew).setSelected(false);
				}
				if(parent.getChildAt(_local2) is CrewBuySlot) {
					(parent.getChildAt(_local2) as CrewBuySlot).setSelected(false);
				}
				_local2++;
			}
			setSelected(true);
		}
		
		public function mOver(e:TouchEvent) : void {
			if(hovering) {
				return;
			}
			hovering = true;
			if(isSelected) {
				return;
			}
			box.alpha = 0.6;
		}
		
		public function mOut(e:TouchEvent) : void {
			if(!hovering) {
				return;
			}
			hovering = false;
			if(isSelected) {
				box.alpha = 1;
				return;
			}
			box.alpha = 0;
		}
		
		private function onTouch(e:TouchEvent) : void {
			if(e.getTouch(this,"ended")) {
				onClick(e);
			} else if(e.interactsWith(this)) {
				mOver(e);
			} else if(!e.interactsWith(this)) {
				mOut(e);
			}
		}
		
		public function clean(e:Event = null) : void {
			removeEventListener("touch",onTouch);
			removeEventListener("removedFromStage",clean);
		}
	}
}

