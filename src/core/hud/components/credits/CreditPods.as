package core.hud.components.credits
{
	import core.hud.components.Button;
	import core.scene.Game;
	import core.states.gameStates.PodState;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class CreditPods extends CreditBaseItem
	{
		protected var description:String;
		
		public function CreditPods(param1:Game, param2:Sprite)
		{
			var button:Button;
			var descriptionText:TextField;
			var g:Game = param1;
			var parent:Sprite = param2;
			super(g, parent);
			bitmap = "ti_pods.png";
			itemLabel = Localize.t("AF Pods");
			description = Localize.t("A pod can reward you with a ship, weapon, artefact, upgrade reset, paint-job, flux or resources. The reward is random, but if you buy 10 pods there will be at least one rare reward.");
			button = new Button(function():void
			{
				g.enterState(new PodState(g));
			}, Localize.t("Buy Pods"), "buy");
			button.x = 5;
			infoContainer.addChild(button);
			descriptionText = new TextField(280, 50, description, new TextFormat("font13", 12, 11184810, "left"));
			descriptionText.batchable = true;
			descriptionText.y = button.height + 10;
			descriptionText.autoScale = false;
			descriptionText.autoSize = "vertical";
			descriptionText.alignPivot("left", "top");
			infoContainer.addChild(descriptionText);
			super.load();
		}
	}
}
