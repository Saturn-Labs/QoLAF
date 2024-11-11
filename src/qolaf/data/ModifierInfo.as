package qolaf.data
{
	import com.adobe.crypto.MD5;
	import embeds.qolaf.ModifiersJson;
	import flash.geom.Rectangle;
	import starling.textures.Texture;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import qolaf.utils.Query;
	import textures.ITextureManager;

	/**
	 * @author rydev
	 */
	public class ModifierInfo
	{
		private static var MODIFIERS_JSON:ByteArray = new ModifiersJson();
		private static var _modifiersArray:Array = JSON.parse(MODIFIERS_JSON.readUTFBytes(MODIFIERS_JSON.length)) as Array;
		private static var _iconCache:Dictionary = new Dictionary();
		public static function getModifier(id:int):Object
		{
			if (id == -1)
				return null;
			return Query.first(_modifiersArray, function(obj:Object):Boolean
				{
					return obj.id == id;
				});
		}

		public static function getIcon(textureManager:ITextureManager, name:String, textureName:String = "texture_gui1_test.png"):Texture
		{
			var hash:String = MD5.hash(textureName + "/" + name);
			if (hash in _iconCache)
				return _iconCache[hash] as Texture;

			var tex:Texture = textureManager.getTextureByTextureName(name, textureName);
			if (tex == null)
				return null;

			var newTex:Texture = Texture.fromTexture(tex, new Rectangle(2, 2, 36, 36));
			_iconCache[hash] = newTex;
			return newTex;
		}
	}
}