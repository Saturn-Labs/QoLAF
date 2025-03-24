package feathers.events {
	public class MediaPlayerEventType {
		public static const DISPLAY_STATE_CHANGE:String = "displayStageChange";
		
		public static const PLAYBACK_STATE_CHANGE:String = "playbackStageChange";
		
		public static const TOTAL_TIME_CHANGE:String = "totalTimeChange";
		
		public static const CURRENT_TIME_CHANGE:String = "currentTimeChange";
		
		public static const DIMENSIONS_CHANGE:String = "dimensionsChange";
		
		public static const SOUND_TRANSFORM_CHANGE:String = "soundTransformChange";
		
		public static const METADATA_RECEIVED:String = "metadataReceived";
		
		public static const LOAD_PROGRESS:String = "loadProgress";
		
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		public function MediaPlayerEventType() {
			super();
		}
	}
}

