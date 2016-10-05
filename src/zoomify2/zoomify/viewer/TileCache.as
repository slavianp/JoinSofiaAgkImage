package zoomify.viewer {
    import flash.display.*;
    import flash.events.*;
    import zoomify.events.*;
    import flash.utils.*;
    import flash.net.*;

    public class TileCache extends EventDispatcher {

        private static const MAX_CACHE_SIZE:Number = 100;

        private var lastReqArray:Array;
        private var queue:Dictionary;
        private var imagePath:String;
        private var limitsArray:Array;
        private var heightScale:Number;
        private var widthScale:Number;
        private var cacheLUT:Object;
        private var cacheArray:Array;

        public function TileCache():void{
            cacheArray = [];
            cacheLUT = {};
            limitsArray = [];
            lastReqArray = [];
            queue = new Dictionary();
            addEventListener(TileEvent.READY, tileReadyHandler, false, 0, true);
        }
        private function tileIsReady(_arg1:TileDataLoader, _arg2:uint, _arg3:uint, _arg4:uint):void{
            dispatchEvent(new TileEvent(TileEvent.READY, _arg1, (_arg1.content as Bitmap), _arg2, _arg3, _arg4));
        }
        protected function dispatchProgressEvent():void{
            var _local4:String;
            var _local5:TileDataLoader;
            var _local6:LoaderInfo;
            var _local7:uint;
            var _local8:uint;
            var _local1:uint;
            var _local2:uint;
            var _local3:uint;
            for (_local4 in queue) {
                _local5 = (queue[_local4] as TileDataLoader);
                if (_local5 != null){
                    _local6 = _local5.contentLoaderInfo;
                    _local7 = _local6.bytesLoaded;
                    _local8 = _local6.bytesTotal;
                    if ((((_local7 >= 0)) && ((_local8 >= 0)))){
                        _local1++;
                        _local2 = (_local2 + _local8);
                        _local3 = (_local3 + _local7);
                    };
                };
            };
            dispatchEvent(new TileProgressEvent(TileProgressEvent.TILE_PROGRESS, _local1, _local2, _local3));
        }
        private function tileLoaded(_arg1:Event):void{
            var _local2:TileDataLoader = (_arg1.target.loader as TileDataLoader);
            delete queue[((((_local2.t + "|") + _local2.r) + "|") + _local2.c)];
            dispatchProgressEvent();
            tileIsReady(_local2, _local2.t, _local2.r, _local2.c);
        }
        public function setPath(_arg1:String):void{
            imagePath = _arg1;
        }
        private function ioErrorHandler(_arg1:IOErrorEvent):void{
            var _local2:uint;
            while (_local2 < cacheArray.length) {
                if (cacheArray[_local2].contentLoaderInfo == _arg1.target){
                    delete queue[((((cacheArray[_local2].t + "|") + cacheArray[_local2].r) + "|") + cacheArray[_local2].c)];
                };
                _local2++;
            };
            dispatchProgressEvent();
        }
        public function calculatePathLimits(_arg1:uint, _arg2:uint, _arg3:uint):void{
            var _local7:uint;
            var _local8:uint;
            var _local4:Number = (Math.max(_arg2, _arg3) / Number(_arg1));
            var _local5:uint;
            while ((1 << _local5) < _local4) {
                widthScale = (_arg2 / ((1 << _local5) * _arg1));
                heightScale = (_arg3 / ((1 << _local5) * _arg1));
                if (_local4 > (1 << _local5)){
                    widthScale = (_arg2 / ((1 << (_local5 + 1)) * _arg1));
                };
                if (_local4 > (1 << _local5)){
                    heightScale = (_arg3 / ((1 << (_local5 + 1)) * _arg1));
                };
                _local5++;
            };
            limitsArray = [];
            var _local6:uint;
            while (_local6 <= _local5) {
                _local7 = 0;
                _local8 = (1 << _local6);
                limitsArray.push((Math.ceil((widthScale * _local8)) * Math.ceil((heightScale * _local8))));
                _local6++;
            };
        }
        public function purge(_arg1:uint=100):void{
            var _local2:TileDataLoader;
            var _local3:int;
            var _local4:Bitmap;
            var _local5:TileDataLoader;
            while (cacheArray.length > _arg1) {
                _local2 = null;
                _local3 = 0;
                while (_local3 < cacheArray.length) {
                    _local5 = (cacheArray[_local3] as TileDataLoader);
                    if (((((_local5) && (((!(_local5.immortal)) || ((_arg1 == 0)))))) && ((lastReqArray.indexOf(_local5) == -1)))){
                        _local2 = _local5;
                        break;
                    };
                    _local3++;
                };
                if (_local2 == null){
                    break;
                };
                dispatchEvent(new TileEvent(TileEvent.REMOVED, _local2, (_local2.content as Bitmap), _local2.t, _local2.r, _local2.c));
                delete queue[((((_local2.t + "|") + _local2.r) + "|") + _local2.c)];
                cacheLUT[((((_local2.t + "|") + _local2.r) + "|") + _local2.c)] = null;
                cacheArray.shift();
                _local4 = (_local2.content as Bitmap);
                if (_local4){
                    _local4.bitmapData.dispose();
                };
            };
            lastReqArray = [];
        }
        private function progress(_arg1:ProgressEvent):void{
            dispatchProgressEvent();
        }
        public function loadTile(_arg1:uint, _arg2:int, _arg3:int):Boolean{
            var _local8:int;
            var _local4:TileDataLoader = cacheLUT[((((_arg1 + "|") + _arg2) + "|") + _arg3)];
            if ((((((((_arg2 < 0)) || ((_arg3 < 0)))) || (!((_local4 == null))))) || ((imagePath == null)))){
                if (_local4 != null){
                    _local8 = cacheArray.indexOf(_local4);
                    if (_local8 != -1){
                        cacheArray.push(cacheArray.splice(_local8, 1)[0]);
                    };
                    lastReqArray.push(_local4);
                };
                return (true);
            };
            var _local5:Number = ((_arg2 * Math.ceil(((1 << _arg1) * widthScale))) + _arg3);
            var _local6:uint;
            while (_local6 < _arg1) {
                _local5 = (_local5 + limitsArray[_local6]);
                _local6++;
            };
            var _local7:TileDataLoader = new TileDataLoader(Math.floor((_local5 / 0x0100)), _arg1, _arg2, _arg3);
            _local7.load(new URLRequest(((((((((((imagePath + "/") + "TileGroup") + Math.floor((_local5 / 0x0100))) + "/") + _arg1) + "-") + _arg3) + "-") + _arg2) + ".jpg")));
            _local7.contentLoaderInfo.addEventListener(Event.COMPLETE, tileLoaded);
            _local7.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
            _local7.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            cacheLUT[((((_arg1 + "|") + _arg2) + "|") + _arg3)] = _local7;
            queue[((((_arg1 + "|") + _arg2) + "|") + _arg3)] = _local7;
            cacheArray.push(_local7);
            lastReqArray.push(_local7);
            return (false);
        }
        private function tileReadyHandler(_arg1:TileEvent):void{
            if (((((!((_arg1.t == 0))) || (!((_arg1.r == 0))))) || (!((_arg1.c == 0))))){
                return;
            };
            var _local2:Bitmap = convertTileDataToBitmap(0, 0, 0);
            if (_local2 != null){
                _arg1.loader.immortal = true;
            };
        }
        public function convertTileDataToBitmap(_arg1:uint, _arg2:int, _arg3:int):Bitmap{
            var _local4:TileDataLoader = cacheLUT[((((_arg1 + "|") + _arg2) + "|") + _arg3)];
            if (_local4 == null){
                return (null);
            };
            return ((_local4.content as Bitmap));
        }
        public function getTileData(_arg1:uint, _arg2:int, _arg3:int):TileDataLoader{
            return (cacheLUT[((((_arg1 + "|") + _arg2) + "|") + _arg3)]);
        }

    }
}//package zoomify.viewer 
