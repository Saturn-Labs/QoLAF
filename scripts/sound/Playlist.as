package sound {
	import flash.utils.Dictionary;
	
	public class Playlist {
		private static var THEME_ARRENIUS:String = "121xDDNiD0aZuYuO54RoVw";
		
		private static var THEME_OLD_MAIN:String = "dsaasdsadasdasdasd";
		
		private static var THEME_HYPERION:String = "d_UvKVpELECadlEBTdV7jA";
		
		private static var THEME_FULZAR:String = "fbkoOOWHqU6wufVC78r88A";
		
		private static var THEME_ORGANIC:String = "ftbP3kq11EqZcrugOlZpFg";
		
		private static var THEME_VAST_SPACE:String = "IOO5z1CeyESgoUp0yIuIPQ";
		
		private static var THEME_KAPELLO:String = "yG0kamojyEmv785l8DhkBA";
		
		private static var THEME_DURIAN:String = "2B25EE69-6801-9B23-CF14-7EBD8B4D3DC5";
		
		private static var THEME_HYPERION_DISORDER:String = "swLuz6vyGEGIhyE2ZQj2tw";
		
		private static var THEME_ALONE_IN_SPACE:String = "Eh5oXkT-FEO1FXxqXdlR-g";
		
		private static var currentTrack:String = null;
		
		private static var currentPlaylist:Array = null;
		
		private static var i:int = 0;
		
		private static var initialized:Boolean = false;
		
		private static var PLAYLIST_DEFAULT:Array = [THEME_HYPERION,THEME_OLD_MAIN,THEME_ALONE_IN_SPACE];
		
		private static var PLAYLIST_HYPERION:Array = [].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_KAPELLO:Array = [THEME_KAPELLO].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_DURIAN:Array = [THEME_DURIAN,THEME_OLD_MAIN,THEME_ALONE_IN_SPACE,THEME_VAST_SPACE];
		
		private static var PLAYLIST_VENTURI:Array = [THEME_ALONE_IN_SPACE,THEME_VAST_SPACE,THEME_OLD_MAIN];
		
		private static var PLAYLIST_ARRENIUS:Array = [THEME_ARRENIUS,THEME_KAPELLO,THEME_DURIAN].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_KRITILLIAN:Array = [THEME_ORGANIC,THEME_VAST_SPACE,THEME_ARRENIUS,THEME_KAPELLO,THEME_DURIAN].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_ZERGILIN:Array = [THEME_VAST_SPACE,THEME_ORGANIC,THEME_ARRENIUS,THEME_KAPELLO,THEME_DURIAN].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_HOZAR:Array = [THEME_VAST_SPACE,THEME_ORGANIC,THEME_ARRENIUS,THEME_KAPELLO,THEME_DURIAN].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_MITRILION:Array = [THEME_ORGANIC,THEME_VAST_SPACE,THEME_ARRENIUS,THEME_KAPELLO,THEME_DURIAN].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_VIBRILIAN:Array = [THEME_ORGANIC,THEME_VAST_SPACE,THEME_ARRENIUS,THEME_KAPELLO,THEME_DURIAN].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_SARKINON:Array = [THEME_VAST_SPACE,THEME_ORGANIC,THEME_ARRENIUS,THEME_KAPELLO,THEME_DURIAN].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_NEURONA:Array = [THEME_VAST_SPACE,THEME_ORGANIC,THEME_ARRENIUS,THEME_KAPELLO,THEME_DURIAN].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_CYNAPSIAN:Array = [THEME_ORGANIC,THEME_VAST_SPACE,THEME_ARRENIUS,THEME_KAPELLO,THEME_DURIAN].concat(PLAYLIST_DEFAULT);
		
		private static var PLAYLIST_FULZAR:Array = [THEME_FULZAR].concat(PLAYLIST_CYNAPSIAN);
		
		private static var PLAYLIST_VORSRAN:Array = [].concat(PLAYLIST_FULZAR);
		
		private static var playlists:Dictionary = new Dictionary();
		
		public function Playlist() {
			super();
		}
		
		private static function randomize(a:*, b:*) : int {
			return Math.random() > 0.5 ? 1 : -1;
		}
		
		public static function init() : void {
			playlists["HrAjOBivt0SHPYtxKyiB_Q"] = PLAYLIST_HYPERION;
			playlists["rRgn1hgGh0qpWXAha3l4cw"] = PLAYLIST_KAPELLO;
			playlists["lf99t42bhEGsBmY0etltVw"] = PLAYLIST_DURIAN;
			playlists["hI1Hlu1OIUWHIxPjor1_Zw"] = PLAYLIST_VENTURI;
			playlists["DU6zMqKBIUGnUWA9eVVD-g"] = PLAYLIST_ARRENIUS;
			playlists["qTczb1IHiE-g96ytcYY-Kg"] = PLAYLIST_KRITILLIAN;
			playlists["eeiIZ18nr0-Is2jw_hLm3w"] = PLAYLIST_ZERGILIN;
			playlists["Rv0u-QG0bESaLV3ZyUj19Q"] = PLAYLIST_HOZAR;
			playlists["TbpMncDxzU-7LigSVnzSDg"] = PLAYLIST_MITRILION;
			playlists["iFIiOWjST0KHKaGgw9cN4A"] = PLAYLIST_VIBRILIAN;
			playlists["AMfRfOOoqU-PeXmFnacumw"] = PLAYLIST_SARKINON;
			playlists["6TZ84m2FoUyJqjZK8grKaw"] = PLAYLIST_NEURONA;
			playlists["AAFLLTg0nkqZaBDwy0qh0w"] = PLAYLIST_CYNAPSIAN;
			playlists["TFWG3jTSaESdIzfYva4qCQ"] = PLAYLIST_FULZAR;
			playlists["sfNQWazDdUasynuRWngLdw"] = PLAYLIST_VORSRAN;
			initialized = true;
		}
		
		public static function play(system:String) : void {
			if(!initialized) {
				init();
			}
			var _local2:ISound = SoundLocator.getService();
			currentPlaylist = playlists[system];
			if(currentPlaylist == null) {
				currentPlaylist = PLAYLIST_DEFAULT;
			}
			currentTrack = currentPlaylist[i];
			next(true);
		}
		
		public static function next(first:Boolean = false) : void {
			var firstTrack:String;
			if(first) {
				i = -1;
			}
			i++;
			if(i == currentPlaylist.length) {
				i = 0;
				firstTrack = currentPlaylist.shift();
				currentPlaylist.sort(randomize);
				currentPlaylist.unshift(firstTrack);
			}
			currentTrack = currentPlaylist[i];
			SoundLocator.getService().playMusic(currentTrack,false,true,null,function():void {
				next();
			},true);
		}
		
		public static function stop() : void {
			var _local1:ISound = SoundLocator.getService();
			_local1.stopAll();
		}
	}
}

