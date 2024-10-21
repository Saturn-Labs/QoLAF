package textures
{
	import playerio.Client;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public interface ITextureManager
	{
		function loadTextures(param1:Array):void;
		
		function get percLoaded():int;
		
		function getTextureMainByKey(param1:String):Texture;
		
		function getTextureGUIByTextureName(param1:String):Texture;
		
		function getTextureGUIByKey(param1:String):Texture;
		
		function getTexturesByKey(param1:String, param2:String):Vector.<Texture>;
		
		function getTexturesMainByKey(param1:String):Vector.<Texture>;
		
		function getTexturesMainByTextureName(param1:String):Vector.<Texture>;
		
		function getTextureMainByTextureName(param1:String):Texture;
		
		function set client(param1:Client):void;
		
		function getTextureByTextureName(param1:String, param2:String):Texture;
		
		function getTextureAtlas(param1:String):TextureAtlas;
		
		function disposeCustomTextures():void;
		
		function addEventListener(param1:String, param2:Function):void;
		
		function removeEventListener(param1:String, param2:Function):void;
	}
}
