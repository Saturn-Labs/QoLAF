package startSetup
{
	import core.hud.components.Text;
	import starling.display.Sprite;
	import starling.display.Stage;
	
	public interface IStartSetup
	{
		function get timer():Date;
		
		function set timeStart(param1:int):void;
		
		function get timeStart():int;
		
		function get progressText():Text;
		
		function get sprite():Sprite;
		
		function get getStage():Stage;
		
		function get split():String;
		
		function set joinName(param1:String):void;
		
		function get skin():String;
		
		function get pvp():Boolean;
	}
}
