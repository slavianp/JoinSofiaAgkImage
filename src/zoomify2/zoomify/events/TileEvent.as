package zoomify.events {
    import flash.display.*;
    import flash.events.*;
    import zoomify.viewer.*;

    public class TileEvent extends Event {

        public static const REMOVED:String = "removed";
        public static const READY:String = "ready";

        public var loader:TileDataLoader;
        public var r:uint;
        public var c:uint;
        public var bmp:Bitmap;
        public var t:uint;

        public function TileEvent(_arg1:String, _arg2:TileDataLoader, _arg3:Bitmap, _arg4:uint, _arg5:uint, _arg6:uint, _arg7:Boolean=false, _arg8:Boolean=false){
            this.loader = _arg2;
            bmp = _arg3;
            this.t = _arg4;
            this.r = _arg5;
            this.c = _arg6;
            super(_arg1, _arg7, _arg8);
        }
    }
}//package zoomify.events 
