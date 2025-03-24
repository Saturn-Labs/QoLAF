package core.spawner {
	import core.scene.Game;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class OrganicSpawner extends Spawner {
		private static const NR_OF_INACTIVE_FRAMES:int = 7;
		
		private var dmgTile:int = -1;
		
		private var dmgTileDuration:int = 1000;
		
		private var dmgTileNextReduction:Number = 0;
		
		private var inactiveTexturesArray:Vector.<Vector.<Texture>>;
		
		public function OrganicSpawner(g:Game) {
			super(g);
			inactiveTexturesArray = new Vector.<Vector.<Texture>>();
		}
		
		override public function update() : void {
			var _local1:int = 0;
			super.update();
			if(alive && _textures.length > 0 && inactiveTexturesArray.length > 0) {
				if(dmgTile <= 7 - 1 && dmgTile > -1) {
					_local1 = 7 - 1 - dmgTile;
					if(_local1 > inactiveTexturesArray.length - 1) {
						_local1 = inactiveTexturesArray.length - 1;
					}
					changeStateTextures(inactiveTexturesArray[_local1]);
				}
				if(dmgTileNextReduction < g.time) {
					if(dmgTile > -1) {
						dmgTile--;
					}
					if(dmgTile == -1) {
						changeStateTextures(_textures,true);
					}
					dmgTileNextReduction = g.time + dmgTileDuration;
				}
			}
		}
		
		override public function switchTexturesByObj(obj:Object, textureAtlas:String = "texture_main_NEW.png") : void {
			var _local4:* = undefined;
			var _local5:* = undefined;
			super.switchTexturesByObj(obj,textureAtlas);
			var _local6:ITextureManager = TextureLocator.getService();
			if(imgObj != null) {
				_local4 = _local6.getTexturesMainByTextureName(imgObj.textureName.replace("active","inactive"));
				for each(var _local3 in _local4) {
					_local5 = new Vector.<Texture>();
					_local5.push(_local3);
					inactiveTexturesArray.push(_local5);
				}
			}
		}
		
		override public function takeDamage(dmg:int) : void {
			if(dmgTile < 6) {
				dmgTile++;
			}
			super.takeDamage(dmg);
		}
	}
}

