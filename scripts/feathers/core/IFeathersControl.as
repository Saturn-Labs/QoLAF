package feathers.core {
	import feathers.skins.IStyleProvider;
	
	public interface IFeathersControl extends IValidating, IMeasureDisplayObject {
		function get isEnabled() : Boolean;
		
		function set isEnabled(value:Boolean) : void;
		
		function get isInitialized() : Boolean;
		
		function get isCreated() : Boolean;
		
		function get styleNameList() : TokenList;
		
		function get styleName() : String;
		
		function set styleName(value:String) : void;
		
		function get styleProvider() : IStyleProvider;
		
		function set styleProvider(value:IStyleProvider) : void;
		
		function get toolTip() : String;
		
		function set toolTip(value:String) : void;
		
		function setSize(width:Number, height:Number) : void;
		
		function move(x:Number, y:Number) : void;
		
		function resetStyleProvider() : void;
		
		function initializeNow() : void;
	}
}

