package feathers.core {
	import flash.geom.Point;
	
	public interface ITextEditor extends IFeathersControl, ITextBaselineControl {
		function get text() : String;
		
		function set text(value:String) : void;
		
		function get displayAsPassword() : Boolean;
		
		function set displayAsPassword(value:Boolean) : void;
		
		function get maxChars() : int;
		
		function set maxChars(value:int) : void;
		
		function get restrict() : String;
		
		function set restrict(value:String) : void;
		
		function get isEditable() : Boolean;
		
		function set isEditable(value:Boolean) : void;
		
		function get isSelectable() : Boolean;
		
		function set isSelectable(value:Boolean) : void;
		
		function get setTouchFocusOnEndedPhase() : Boolean;
		
		function get selectionBeginIndex() : int;
		
		function get selectionEndIndex() : int;
		
		function setFocus(position:Point = null) : void;
		
		function clearFocus() : void;
		
		function selectRange(startIndex:int, endIndex:int) : void;
		
		function measureText(result:Point = null) : Point;
	}
}

