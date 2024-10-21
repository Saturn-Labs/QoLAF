package
{
	import com.greensock.TweenMax;
	import data.DataLocator;
	import data.IDataManager;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Preload extends EventDispatcher
	{
		private var textureManager:ITextureManager;
		
		private var loadingBar:LoadingBar;
		
		private var imageLoadingStarted:Boolean = false;
		
		public function Preload(param1:Sprite)
		{
			super();
			textureManager = TextureLocator.getService();
			loadingBar = new LoadingBar(760 / 2, 600 / 2);
			param1.addChild(loadingBar);
		}
		
		public function loadData():void
		{
			var _loc1_:IDataManager = DataLocator.getService();
			_loc1_.cacheCommonData();
			textureManager.loadTextures(["texture_gui1_test.xml", "texture_gui1_test.png", "texture_gui2.xml", "texture_gui2.png", "texture_main_NEW.xml", "texture_main_NEW.png", "texture_body.xml", "texture_body.png"]);
			textureManager.addEventListener("preloadProgress", onImagePreloadProgress);
			textureManager.addEventListener("preloadComplete", onImagePreloadComplete);
		}
		
		private function onImagePreloadProgress(param1:Event):void
		{
			loadingBar.update(Localize.t("Loading images..."), textureManager.percLoaded);
			if (!imageLoadingStarted)
			{
				imageLoadingStarted = true;
			}
		}
		
		private function onImagePreloadComplete(param1:Event):void
		{
			loadingBar.update(Localize.t("Loading images complete"), 100);
			textureManager.removeEventListener("preloadComplete", onImagePreloadComplete);
			textureManager.removeEventListener("preloadProgress", onImagePreloadProgress);
			preloadComplete();
		}
		
		private function preloadComplete():void
		{
			loadingBar.update(Localize.t("Done!"), 100);
			TweenMax.to(loadingBar, 0.3, {"alpha": 0, "onComplete": function():void
			{
				dispatchEventWith("preloadComplete");
			}});
		}
	}
}
