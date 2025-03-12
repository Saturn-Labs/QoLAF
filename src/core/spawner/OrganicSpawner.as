package core.spawner
{
	import core.scene.Game;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class OrganicSpawner extends Spawner
	{
		private static const NR_OF_INACTIVE_FRAMES:int = 7;
		private var dmgTile:int = -1;
		private var dmgTileDuration:int = 1000;
		private var dmgTileNextReduction:Number = 0;
		private var inactiveTexturesArray:Vector.<Vector.<Texture>>;
		
		public function OrganicSpawner(param1:Game)
		{
			super(param1);
			inactiveTexturesArray = new Vector.<Vector.<Texture>>();
		}
		
		override public function update():void
		{
			var _loc1_:int = 0;
			super.update();
			if (alive && _textures.length > 0 && inactiveTexturesArray.length > 0)
			{
				if (dmgTile <= 7 - 1 && dmgTile > -1)
				{
					_loc1_ = 7 - 1 - dmgTile;
					if (_loc1_ > inactiveTexturesArray.length - 1)
					{
						_loc1_ = inactiveTexturesArray.length - 1;
					}
					changeStateTextures(inactiveTexturesArray[_loc1_]);
				}
				if (dmgTileNextReduction < g.time)
				{
					if (dmgTile > -1)
					{
						dmgTile--;
					}
					if (dmgTile == -1)
					{
						changeStateTextures(_textures, true);
					}
					dmgTileNextReduction = g.time + dmgTileDuration;
				}
			}
		}
		
		override public function switchTexturesByObj(param1:Object, param2:String = "texture_main_NEW.png"):void
		{
			var _loc3_:* = undefined;
			var _loc6_:* = undefined;
			super.switchTexturesByObj(param1, param2);
			var _loc4_:ITextureManager = TextureLocator.getService();
			if (imgObj != null)
			{
				_loc3_ = _loc4_.getTexturesMainByTextureName(imgObj.textureName.replace("active", "inactive"));
				for each (var _loc5_:* in _loc3_)
				{
					_loc6_ = new Vector.<Texture>();
					_loc6_.push(_loc5_);
					inactiveTexturesArray.push(_loc6_);
				}
			}
		}
		
		override public function takeDamage(param1:int):void
		{
			if (dmgTile < 6)
			{
				dmgTile++;
			}
			super.takeDamage(param1);
		}
	}
}
