package core.artifact
{
	import core.hud.components.Button;
	import core.hud.components.ToolTip;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import generics.ObjUtils;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class ArtifactSorting extends Sprite
	{
		private var nextX:int = 20;
		
		private var nextY:int = 0;
		
		private var padding:int = 10;
		
		private var g:Game;
		
		private var types:Vector.<Object>;
		
		private var callback:Function;
		
		private var drawCount:int = 0;
		
		private var scrollArea:ScrollContainer;
		
		private var mainBody:Sprite;
		
		public function ArtifactSorting(param1:Game, param2:Function)
		{
			var q:Quad;
			var headline:TextField;
			var tmp:Object;
			var sortLevelHigh:Button;
			var sortLevelLow:Button;
			var sortCountAsc:Button;
			var sortCountDesc:Button;
			var g:Game = param1;
			var callback:Function = param2;
			super();
			this.g = g;
			this.callback = callback;
			q = new Quad(665, 520, 0);
			q.x = -10;
			q.y = -10;
			q.alpha = 0.9;
			addChild(q);
			headline = new TextField(300, 100);
			headline.format.font = "DAIDRR";
			headline.format.size = 26;
			headline.format.color = 16777215;
			headline.format.horizontalAlign = "left";
			headline.format.verticalAlign = "top";
			headline.text = "Choose sorting:";
			headline.y = 20;
			headline.x = nextY;
			addChild(headline);
			scrollArea = new ScrollContainer();
			mainBody = new Sprite();
			scrollArea.y = 60;
			scrollArea.x = 4;
			scrollArea.width = 660;
			scrollArea.height = 400;
			tmp = g.dataManager.loadTable("ArtifactTypes");
			types = ObjUtils.ToVector(tmp, true, "name");
			drawOfSubset("health");
			drawOfSubset("convShield");
			newRow();
			drawOfSubset("armor");
			newRow();
			drawOfSubset("shield");
			drawOfSubset("convHp");
			newRow();
			drawOfSubset("power");
			drawOfSubset("all");
			newRow();
			drawOfSubset("kinetic");
			newRow();
			drawOfSubset("energy");
			newRow();
			drawOfSubset("corrosive");
			newRow();
			drawOfSubset("speed");
			drawOfSubset("refire");
			drawOfSubset("cooldown");
			newRow();
			scrollArea.addChild(mainBody);
			addChild(scrollArea);
			sortLevelHigh = new Button(function():void
			{
				closeAndSort("levelhigh");
			}, "Strength high");
			sortLevelHigh.x = nextX;
			sortLevelHigh.y = 480;
			addChild(sortLevelHigh);
			sortLevelLow = new Button(function():void
			{
				closeAndSort("levellow");
			}, "Strength low");
			sortLevelLow.x = sortLevelHigh.x + sortLevelHigh.width + 20;
			sortLevelLow.y = 480;
			addChild(sortLevelLow);
			sortCountAsc = new Button(function():void
			{
				closeAndSort("statcountasc");
			}, "Modifiers high");
			sortCountAsc.x = sortLevelLow.x + sortLevelLow.width + 20;
			sortCountAsc.y = 480;
			addChild(sortCountAsc);
			sortCountDesc = new Button(function():void
			{
				closeAndSort("statcountdesc");
			}, "Modifiers low");
			sortCountDesc.x = sortCountAsc.x + sortCountAsc.width + 20;
			sortCountDesc.y = 480;
			addChild(sortCountDesc);
		}
		
		private function newRow():void
		{
			nextX = 20;
			nextY += 60;
		}
		
		private function drawOfSubset(param1:String):void
		{
			var _loc4_:int = 0;
			var _loc3_:Object = null;
			var _loc2_:String = null;
			_loc4_ = 0;
			while (_loc4_ < types.length)
			{
				_loc3_ = types[_loc4_];
				_loc2_ = _loc3_.type;
				if (!(_loc2_.indexOf(param1) == -1 || _loc2_.indexOf("2") != -1 || _loc2_.indexOf("3") != -1))
				{
					addButton(_loc3_);
				}
				_loc4_++;
			}
		}
		
		private function addButton(param1:Object):void
		{
			var _loc2_:ITextureManager = TextureLocator.getService();
			var _loc4_:Image = new Image(_loc2_.getTextureGUIByKey(param1.bitmap));
			_loc4_.scaleX = _loc4_.scaleY = 0.7;
			_loc4_.x = nextX;
			_loc4_.y = nextY;
			_loc4_.name = param1.type;
			mainBody.addChild(_loc4_);
			nextX += _loc4_.width + padding;
			var _loc3_:ToolTip = new ToolTip(g, _loc4_, param1.name, null, "artifactBox");
			_loc4_.addEventListener("touch", onTouch);
			_loc4_.addEventListener("touch", onTouch);
			_loc4_.useHandCursor = true;
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			var _loc2_:Image = param1.currentTarget as Image;
			if (param1.getTouch(_loc2_, "ended"))
			{
				_loc2_.filter = null;
				closeAndSort(_loc2_.name);
			}
			else if (param1.interactsWith(_loc2_))
			{
				_loc2_.alpha = 0.5;
			}
			else if (!param1.interactsWith(_loc2_))
			{
				_loc2_.alpha = 1;
			}
		}
		
		private function closeAndSort(param1:String):void
		{
			callback(param1);
			parent.removeChild(this, true);
		}
	}
}
