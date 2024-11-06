package qolaf.ui.layout {
	import com.adobe.protocols.dict.DictionaryServer;
	import feathers.layout.LayoutBoundsResult;
	import feathers.layout.TiledColumnsLayout;
	import feathers.layout.ViewPortBounds;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author 
	 */
	public class InvertedTiledColumnsLayout extends TiledColumnsLayout {
		private var _invertHorizontal:Boolean = false;
		private var _invertVertical:Boolean = false;
		private var _invertHorizontalAlign:Boolean = false;
		private var _invertVerticalAlign:Boolean = false;
		
		public function InvertedTiledColumnsLayout() {
			super();
		}
		
		override public function layout(items:Vector.<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null):LayoutBoundsResult
		{
			result = super.layout(items, viewPortBounds, result);
			for (var i:int = 0; i < items.length; i++)
			{
				var item:DisplayObject = items[i];
				var container:DisplayObjectContainer = item.parent;
				if (_invertHorizontal) {
					item.x = (result.contentWidth - item.x - item.width) - (_invertHorizontalAlign ? result.contentWidth : 0);
				}
				
				if (_invertVertical) {
					item.y = (result.contentHeight - item.y - item.height) - (_invertVerticalAlign ? result.contentHeight : 0);
				}
			}
			return result;
		}
		
		public function get invertHorizontal():Boolean {
			return _invertHorizontal;
		}
		
		public function set invertHorizontal(invert:Boolean):void {
			_invertHorizontal = invert;
		}
		
		public function get invertVertical():Boolean {
			return _invertVertical;
		}
		
		public function set invertVertical(invert:Boolean):void {
			_invertVertical = invert;
		}
		
		public function get invertHorizontalAlign():Boolean {
			return _invertHorizontalAlign;
		}
		
		public function set invertHorizontalAlign(invert:Boolean):void {
			_invertHorizontalAlign = invert;
		}
		
		public function get invertVerticalAlign():Boolean {
			return _invertVerticalAlign;
		}
		
		public function set invertVerticalAlign(invert:Boolean):void {
			_invertVerticalAlign = invert;
		}
	}
}