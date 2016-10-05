package zoomify.viewer {
    import flash.display.*;

    public class TileDataLoader extends Loader {

        public var c:uint;
        public var path:String;
        public var g:uint;
        public var r:uint;
        public var immortal:Boolean;
        public var t:uint;

        public function TileDataLoader(_arg1:uint, _arg2:uint, _arg3:uint, _arg4:uint):void{
            this.g = _arg1;
            this.t = _arg2;
            this.r = _arg3;
            this.c = _arg4;
            immortal = false;
        }
    }
}//package zoomify.viewer 
