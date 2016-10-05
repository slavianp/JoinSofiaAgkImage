package zoomify.events {
    import flash.events.*;

    public class TileProgressEvent extends Event {

        public static const TILE_PROGRESS:String = "tileProgress";

        public var bytesLoaded:uint;
        public var files:uint;
        public var bytesTotal:uint;

        public function TileProgressEvent(_arg1:String, _arg2:uint, _arg3:uint, _arg4:uint, _arg5:Boolean=false, _arg6:Boolean=false){
            this.files = _arg2;
            this.bytesTotal = _arg3;
            this.bytesLoaded = _arg4;
            super(_arg1, _arg5, _arg6);
        }
        override public function toString():String{
            return ((((((((("[Event type=\"" + type) + "\" files=") + files) + " bytesTotal=") + bytesTotal) + " bytesLoaded=") + bytesLoaded) + "]"));
        }
        override public function clone():Event{
            return (new TileProgressEvent(type, files, bytesTotal, bytesLoaded, bubbles, cancelable));
        }

    }
}//package zoomify.events 
