package feathers.data {
	import feathers.core.IFeathersEventDispatcher;
	
	public interface IAutoCompleteSource extends IFeathersEventDispatcher {
		function load(textToMatch:String, suggestionsResult:ListCollection = null) : void;
	}
}

