package
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	
	public class IDI extends MovieClip
	{
		public var idnet:*;
		
		private var appID:String = "5510146c694862c3f000054d";
		
		private var verbose:Boolean = true;
		
		private var showPreloader:Boolean = false;
		
		private var loginCallback:Function;
		
		private var loggedIn:Boolean = false;
		
		public function IDI(param1:Function)
		{
			super();
			Security.allowInsecureDomain("*");
			Security.allowDomain("*");
			addEventListener("addedToStage", onStage);
			loginCallback = param1;
		}
		
		private function handleIDNET(param1:Event):void
		{
			var _loc2_:Object = null;
			if (idnet.type == "login")
			{
				log("hello " + idnet.userData.nickname);
				if (loginCallback != null)
				{
					loggedIn = true;
					loginCallback(idnet.userData.nickname, idnet.userData.pid, idnet.userData.email);
				}
			}
			if (idnet.type == "autoLoginFail")
			{
				idnet.toggleInterface("registration");
			}
			if (idnet.type == "submit")
			{
				log("data submitted. status is " + idnet.data.status);
			}
			if (idnet.type == "retrieve")
			{
				if (idnet.data.hasOwnProperty("error") === false)
				{
					log("LOG: data retrieved. key is " + idnet.data.key + " data is " + idnet.data.jsondata);
					_loc2_ = JSON.parse(idnet.data.jsondata);
				}
				else
				{
					log("Error: " + idnet.data.error);
				}
			}
			if (idnet.type == "delete")
			{
				log("deleted data " + idnet.data);
			}
			if (idnet.type == "advancedScoreListPlayer")
			{
				log("player score: " + idnet.data.scores[0].points);
			}
			if (idnet.type == "achievementsSave")
			{
				if (idnet.data.errorcode == 0)
				{
					log("achievement unlocked");
				}
			}
			if (idnet.type == "mapSave")
			{
				log("map saved. levelid is " + idnet.data.level.levelid);
			}
			if (idnet.type == "mapLoad")
			{
				log(idnet.data.level.name + " loaded");
			}
			if (idnet.type == "mapRate")
			{
				log("rating added");
			}
		}
		
		private function log(param1:String):void
		{
		}
		
		private function onStage(param1:Event):void
		{
			var _loc4_:LoaderContext = new LoaderContext();
			_loc4_.applicationDomain = ApplicationDomain.currentDomain;
			if (Security.sandboxType != "localTrusted")
			{
				_loc4_.securityDomain = SecurityDomain.currentDomain;
			}
			var _loc5_:String = "https://www.id.net/swf/idnet-client.swc?=" + new Date().getTime();
			var _loc2_:URLRequest = new URLRequest(_loc5_);
			var _loc3_:Loader = new Loader();
			_loc3_.contentLoaderInfo.addEventListener("complete", loadComplete, false, 0, true);
			_loc3_.load(_loc2_, _loc4_);
		}
		
		private function loadComplete(param1:Event):void
		{
			idnet = param1.currentTarget.content;
			idnet.addEventListener("IDNET", handleIDNET);
			stage.addChild(idnet);
			idnet.init(stage, appID, "", verbose, showPreloader);
		}
	}
}
