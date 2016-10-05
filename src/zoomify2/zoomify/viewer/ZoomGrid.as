package zoomify.viewer {
    import flash.display.*;
    import zoomify.*;
    import flash.events.*;
    import flash.geom.*;
    import zoomify.events.*;
    import flash.utils.*;
    import flash.text.*;
    import flash.net.*;

    public class ZoomGrid extends EventDispatcher {

        private var _enabled:Boolean = true;
        private var tierWidth:Number;
        private var fadeInSpeed:Number = 300;
        protected var tooltipTimer:Timer;
        private var fadeInTimer:Timer;
        private var widthScale:Number;
        private var currentTilesArray:Array;
        private var background:Sprite;
        public var backgroundTier:int = -1;
        private var _viewer:ZoomifyViewer;
        private var canvasSprite:Sprite;
        private var parent_mc:Sprite;
        private var imageH:uint;
        private var canvas:Sprite;
        private var imageW:uint;
        private var panConstrain:Boolean = true;
        private var firstFullViewDrawn:Boolean = false;
        private var visHeight:Number;
        private var tileX:int = 0;
        private var tileY:int = 0;
        private var maxTier:uint;
        private var maxTileY:uint;
        private var heightScale:Number;
        private var tileCache:TileCache;
        private var maxTileX:uint;
        private var fullWidth:uint;
        private var visWidth:Number;
        private var scaling:Boolean = false;
        private var padImage:uint = 0;
        protected var tooltipParent:Sprite;
        private var priorBitmap:Bitmap;
        private var numTilesY:uint;
        private var fullHeight:uint;
        public var numTiles:uint;
        private var numTilesX:uint;
        public var expectedTiles:uint;
        private var priorZoom:Number;
        private var priorTileX:int;
        private var priorTileY:int;
        private var firstTileDrawn:Boolean = false;
        private var tileSize:uint;
        private var backgroundTilesToLoad:uint = 0;
        private var backgroundTilesLoaded:uint = 0;
        private var tier:uint = 4;
        private var tilesToLoad:uint = 0;
        private var tilesLoaded:uint = 0;
        private var eventsEnabled:Boolean = false;
        protected var ratioBackgroundToFullWidth:Number = 1;
        private var hotspotsInUse:int = 0;

        public function ZoomGrid(_arg1:Sprite, _arg2:TileCache):void{
            tileCache = _arg2;
            tileCache.addEventListener(TileEvent.READY, tileLoaded, false, 0, true);
            tileCache.addEventListener(TileEvent.REMOVED, tileUnloaded, false, 0, true);
            currentTilesArray = [];
            parent_mc = _arg1;
            canvas = new Sprite();
            background = new Sprite();
            canvasSprite = new Sprite();
            priorBitmap = new Bitmap();
            priorBitmap.smoothing = true;
            canvas.addChild(background);
            canvas.addChild(priorBitmap);
            canvas.addChild(canvasSprite);
            canvas.buttonMode = true;
            canvas.useHandCursor = true;
            parent_mc.addChild(canvas);
            fadeInTimer = new Timer(50, 0);
            fadeInTimer.addEventListener("timer", fadeInTimerHandler, false, 0, true);
            fadeInTimer.start();
            addEventListener("viewerFirstTileDrawInternal", firstTileDrawGridInternalHandler, false, 0, true);
            addEventListener("viewerFirstFullViewDrawInternal", firstFullViewDrawGridInternalHandler, false, 0, true);
            tooltipTimer = new Timer(500, 1);
        }
        public function set y(_arg1:Number):void{
            var _local2:Number;
            var _local3:Number;
            if (canvas){
                _local2 = (1 << (maxTier - tier));
                _local3 = ((visHeight * _local2) / canvas.scaleX);
                _arg1 = (_arg1 - (_local3 / 2));
                canvas.y = (((_arg1 / _local2) - (tileY * tileSize)) * -(canvas.scaleY));
            };
        }
        public function get yImageSpan():Number{
            return ((((2 * y) / fullHeight) - 1));
        }
        public function active(_arg1:Boolean):void{
            parent_mc.visible = _arg1;
            if (!_arg1){
                priorBitmap.bitmapData = null;
            };
        }
        public function get viewer():ZoomifyViewer{
            return (_viewer);
        }
        public function getCanvasHeight():Number{
            return ((numTilesY * tileSize));
        }
        public function getCanvasWidth():Number{
            return ((numTilesX * tileSize));
        }
        public function setImageOffset(_arg1:Point):void{
            var _local2:Number = (tileSize * canvas.scaleX);
            canvas.x = Math.round((_arg1.x + (tileX * _local2)));
            canvas.y = Math.round((_arg1.y + (tileY * _local2)));
            constrainPan();
        }
        public function setPriorBitmap(_arg1:BitmapData):void{
            priorBitmap.bitmapData = _arg1;
            priorBitmap.smoothing = true;
        }
        public function getImageOffsetInView():Point{
            var _local1:Number = (Math.pow(2, (maxTier - tier)) * canvas.scaleX);
            return (new Point(((canvas.x * _local1) - ((tileX * tileSize) * _local1)), ((canvas.y * _local1) - ((tileY * tileSize) * _local1))));
        }
        public function set viewer(_arg1:ZoomifyViewer):void{
            _viewer = _arg1;
        }
        public function getMaxTier():uint{
            return (maxTier);
        }
        public function getMousePosition():Point{
            return (new Point(((background.mouseX * background.scaleX) / background.width), ((background.mouseY * background.scaleY) / background.height)));
        }
        public function resetScale(_arg1:Number=1):void{
            canvas.scaleX = (canvas.scaleY = _arg1);
        }
        public function updateTiles(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:uint, _arg6:Number, _arg7:Number, _arg8:uint, _arg9:uint, _arg10:Boolean=false):void{
            tierWidth = _arg6;
            var _local11:int = tileX;
            var _local12:int = tileY;
            positionCanvas();
            positionBackground();
            constrainPan();
            var _local13:Number = (getCurrentTierScale() * (_arg6 / fullWidth));
            priorBitmap.visible = (((((priorTileX == tileX)) && ((priorTileY == tileY)))) && ((_local13 > (priorZoom + 0.3))));
            priorZoom = (getCurrentTierScale() * (_arg6 / fullWidth));
            selectTiles(_arg1, _arg2, _arg3, _arg4, _arg5, getCurrentTierScale(), _arg6, _arg7, _arg8, _arg9);
            var _local14:Boolean = ((!((_local11 == tileX))) || (!((_local12 == tileY))));
            if (((_arg10) || (_local14))){
                renderUpdatedTiles();
            };
        }
        public function clearTiles(){
            currentTilesArray = [];
            backgroundTier = -1;
        }
        public function renderUpdatedTiles():void{
            var _local2:int;
            var _local3:int;
            var _local4:Bitmap;
            var _local5:Bitmap;
            canvas.removeChild(canvasSprite);
            canvasSprite = new Sprite();
            canvas.addChildAt(canvasSprite, (canvas.numChildren - hotspotsInUse));
            var _local1:int = tileY;
            while (_local1 < (tileY + numTilesY)) {
                _local2 = tileX;
                while (_local2 < (tileX + numTilesX)) {
                    _local3 = (((_local1 - tileY) * numTilesX) + (_local2 - tileX));
                    _local4 = (currentTilesArray[_local3] as Bitmap);
                    _local5 = tileCache.convertTileDataToBitmap(tier, _local1, _local2);
                    if ((((_local5 == null)) || ((_local5.bitmapData == null)))){
                        currentTilesArray[_local3] = null;
                    } else {
                        currentTilesArray[_local3] = _local5;
                        canvasSprite.addChild(_local5);
                        _local5.smoothing = true;
                        _local5.x = ((_local2 - tileX) * tileSize);
                        _local5.y = ((_local1 - tileY) * tileSize);
                        tilesLoaded = (tilesLoaded + 1);
                    };
                    _local2++;
                };
                _local1++;
            };
        }
        public function get enabled():Boolean{
            return (_enabled);
        }
        public function setFadeInSpeed(_arg1:Number):void{
            fadeInSpeed = _arg1;
        }
        protected function indexOfContainingElement(_arg1:Array, _arg2:String):Number{
            var _local3:Number = -1;
            var _local4:Number = 0;
            var _local5:Number = _arg1.length;
            while (_local4 < _local5) {
                if (_arg1[_local4].toString().indexOf(_arg2) != -1){
                    _local3 = _local4;
                    _local4 = _local5;
                } else {
                    _local4++;
                };
            };
            return (_local3);
        }
        public function positionBackground():void{
            background.x = (-(tileX) * tileSize);
            background.y = (-(tileY) * tileSize);
        }
        public function get scaleX():Number{
            return (canvas.scaleX);
        }
        public function get scaleY():Number{
            return (canvas.scaleY);
        }
        public function scaleCurrentTier(_arg1:Number, _arg2:Number, _arg3:Number):void{
            if ((((tier == 0)) && ((_arg1 <= 0)))){
                _arg1 = 1;
            };
            var _local4:Point = new Point(_arg2, _arg3);
            _local4 = canvas.globalToLocal(_local4);
            canvas.x = (canvas.x + ((_local4.x * canvas.scaleX) - (_local4.x * _arg1)));
            canvas.y = (canvas.y + ((_local4.y * canvas.scaleY) - (_local4.y * _arg1)));
            canvas.scaleY = (canvas.scaleX = _arg1);
            constrainPan();
        }
        public function tileLoaded(_arg1:TileEvent):void{
            var _local2:Bitmap;
            var _local3:Matrix;
            _arg1.bmp.alpha = 0;
            if (_arg1.t == backgroundTier){
                _arg1.loader.immortal = true;
                _local2 = tileCache.convertTileDataToBitmap(_arg1.t, _arg1.r, _arg1.c);
                if (_local2 != null){
                    _local3 = new Matrix();
                    _local3.tx = (_arg1.c * tileSize);
                    _local3.ty = (_arg1.r * tileSize);
                    background.graphics.beginBitmapFill(_local2.bitmapData, _local3, false, true);
                    background.graphics.drawRect((_arg1.c * tileSize), (_arg1.r * tileSize), _local2.bitmapData.width, _local2.bitmapData.height);
                    background.graphics.endFill();
                    backgroundTilesLoaded = (backgroundTilesLoaded + 1);
                };
            };
            if ((((((tilesLoaded >= tilesToLoad)) && (!(firstFullViewDrawn)))) && ((backgroundTilesLoaded >= backgroundTilesToLoad)))){
                firstFullViewDrawn = true;
                dispatchEvent(new Event("viewerFirstFullViewDrawInternal"));
                if (eventsEnabled){
                    dispatchEvent(new Event("viewerFirstFullViewDraw"));
                };
            };
            if (_arg1.t != tier){
                return;
            };
            renderLoadedTile();
        }
        protected function firstTileDrawGridInternalHandler(_arg1:Event):void{
            removeEventListener("viewerFirstTileDrawInternal", firstTileDrawGridInternalHandler);
        }
        override public function toString():String{
            return (((((((((((((((((((((((((((((((((((((((((("fullWidth/Height: " + fullWidth) + " / ") + fullHeight) + "\n") + "visWidth/Height: ") + visWidth) + " / ") + visHeight) + "\n") + "pixelCoords: ") + Math.round(x)) + " / ") + Math.round(y)) + "\n") + "tilePos: ") + tileX) + " / ") + tileY) + "\n") + "tileSize: ") + tileSize) + "\n") + "canvasCoords: ") + canvas.x) + " / ") + canvas.y) + "\n") + "canvasScale: ") + canvas.scaleX) + "\n") + "canvasSize: ") + Math.round(((1 << tier) * tileSize))) + " / ") + Math.round(((1 << tier) * tileSize))) + "\n") + "tier: ") + tier) + "\n") + "maxtier: ") + maxTier) + "\n"));
        }
        public function get x():Number{
            var _local1:Number = (1 << (maxTier - tier));
            var _local2:Number = ((visWidth * _local1) / canvas.scaleX);
            var _local3:Number = (((tileX * tileSize) - (canvas.x / canvas.scaleX)) * _local1);
            return ((_local3 + (_local2 / 2)));
        }
        public function get y():Number{
            var _local1:Number = (1 << (maxTier - tier));
            var _local2:Number = ((visHeight * _local1) / canvas.scaleX);
            var _local3:Number = (((tileY * tileSize) - (canvas.y / canvas.scaleY)) * _local1);
            return ((_local3 + (_local2 / 2)));
        }
        public function set xImageSpan(_arg1:Number):void{
            var _local2:Number;
            var _local3:Number;
            if (canvas){
                _local2 = (1 << (maxTier - tier));
                _local3 = ((visWidth * _local2) / canvas.scaleX);
                _arg1 = ((((_arg1 * fullWidth) / 2) - (_local3 / 2)) + (fullWidth / 2));
                canvas.x = (((_arg1 / _local2) - (tileX * tileSize)) * -(canvas.scaleX));
            };
        }
        protected function firstFullViewDrawGridInternalHandler(_arg1:Event):void{
            removeEventListener("viewerFirstFullViewDrawInternal", firstFullViewDrawGridInternalHandler);
            ratioBackgroundToFullWidth = (background.width / (background.scaleX * fullWidth));
        }
        public function getCurrentTierScale():Number{
            return (canvas.scaleX);
        }
        public function set enabled(_arg1:Boolean):void{
            canvas.buttonMode = _arg1;
            canvas.useHandCursor = _arg1;
            _enabled = _arg1;
        }
        public function scaleCurrentTierRelatively(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Point):void{
            if ((((tier == 0)) && ((_arg1 < 1)))){
                _arg1 = 1;
            };
            var _local5:Point = new Point(((_arg2 * background.width) + background.x), ((_arg3 * background.height) + background.y));
            _arg4 = canvas.globalToLocal(_arg4);
            _local5.x = (_local5.x + ((_local5.x - _arg4.x) * 0.5));
            _local5.y = (_local5.y + ((_local5.y - _arg4.y) * 0.5));
            canvas.x = (canvas.x + ((_local5.x * canvas.scaleX) - (_local5.x * _arg1)));
            canvas.y = (canvas.y + ((_local5.y * canvas.scaleY) - (_local5.y * _arg1)));
            canvas.scaleY = (canvas.scaleX = _arg1);
            constrainPan();
        }
        public function updateCanvas(_arg1:uint, _arg2:uint, _arg3:uint, _arg4:int, _arg5:Array, _arg6:Array):void{
            var _local9:uint;
            var _local10:uint;
            tileSize = _arg1;
            tier = _arg4;
            fullWidth = _arg2;
            fullHeight = _arg3;
            var _local7:Number = (Math.max(fullWidth, fullHeight) / Number(tileSize));
            var _local8:uint;
            while ((1 << _local8) < _local7) {
                widthScale = (fullWidth / ((1 << _local8) * tileSize));
                heightScale = (fullHeight / ((1 << _local8) * tileSize));
                if (_local7 > (1 << _local8)){
                    widthScale = (fullWidth / ((1 << (_local8 + 1)) * tileSize));
                };
                if (_local7 > (1 << _local8)){
                    heightScale = (fullHeight / ((1 << (_local8 + 1)) * tileSize));
                };
                _local8++;
            };
            var _local11:uint = (1 << _arg4);
            _local9 = 0;
            while (_local9 < _local11) {
                if ((_local9 * tileSize) > ((_local11 * tileSize) * widthScale)){
                    break;
                };
                maxTileX = _local9;
                _local9++;
            };
            _local10 = 0;
            while (_local10 < _local11) {
                if ((_local10 * tileSize) > ((_local11 * tileSize) * heightScale)){
                    break;
                };
                maxTileY = _local10;
                _local10++;
            };
        }
        public function setOffset(_arg1:Point, _arg2:Number):void{
            var _local3:Number = (tileSize * canvas.scaleX);
            priorTileX = (tileX = Math.floor((_arg1.x / _local3)));
            priorTileY = (tileY = Math.floor((_arg1.y / _local3)));
            canvas.x = Math.round((-(((_arg1.x / _local3) - Math.floor((_arg1.x / _local3)))) * _local3));
            canvas.y = Math.round((-(((_arg1.y / _local3) - Math.floor((_arg1.y / _local3)))) * _local3));
            priorBitmap.scaleY = (priorBitmap.scaleX = (1 / canvas.scaleX));
            priorBitmap.x = (-(canvas.x) * priorBitmap.scaleX);
            priorBitmap.y = (-(canvas.y) * priorBitmap.scaleY);
            priorBitmap.visible = true;
            background.scaleY = (background.scaleX = ((1 << tier) / Number((1 << backgroundTier))));
            background.x = (-(tileX) * tileSize);
            background.y = (-(tileY) * tileSize);
        }
        public function set scaleX(_arg1:Number):void{
            if (canvas){
                canvas.scaleX = _arg1;
            };
        }
        public function setMaxTier(_arg1:uint):void{
            maxTier = _arg1;
        }
        public function set scaleY(_arg1:Number):void{
            if (canvas){
                canvas.scaleY = _arg1;
            };
        }
        public function setEventsEnabled(_arg1:Boolean):void{
            eventsEnabled = _arg1;
        }
        public function set yImageSpan(_arg1:Number):void{
            var _local2:Number;
            var _local3:Number;
            if (canvas){
                _local2 = (1 << (maxTier - tier));
                _local3 = ((visHeight * _local2) / canvas.scaleX);
                _arg1 = ((((_arg1 * fullHeight) / 2) - (_local3 / 2)) + (fullHeight / 2));
                canvas.y = (((_arg1 / _local2) - (tileY * tileSize)) * -(canvas.scaleY));
            };
        }
        public function renderLoadedTile():void{
            var _local2:int;
            var _local3:int;
            var _local4:Bitmap;
            var _local5:Bitmap;
            canvas.removeChild(canvasSprite);
            canvasSprite = new Sprite();
            canvas.addChildAt(canvasSprite, (canvas.numChildren - hotspotsInUse));
            var _local1:int = tileY;
            while (_local1 < (tileY + numTilesY)) {
                _local2 = tileX;
                while (_local2 < (tileX + numTilesX)) {
                    _local3 = (((_local1 - tileY) * numTilesX) + (_local2 - tileX));
                    _local4 = (currentTilesArray[_local3] as Bitmap);
                    _local5 = tileCache.convertTileDataToBitmap(tier, _local1, _local2);
                    if ((((_local5 == null)) || ((_local5.bitmapData == null)))){
                        currentTilesArray[_local3] = null;
                    } else {
                        currentTilesArray[_local3] = _local5;
                        canvasSprite.addChild(_local5);
                        _local5.smoothing = true;
                        _local5.x = ((_local2 - tileX) * tileSize);
                        _local5.y = ((_local1 - tileY) * tileSize);
                        tilesLoaded = (tilesLoaded + 1);
                        if (!firstTileDrawn){
                            firstTileDrawn = true;
                            dispatchEvent(new Event("viewerFirstTileDrawInternal"));
                            if (eventsEnabled){
                                dispatchEvent(new Event("viewerFirstTileDraw"));
                            };
                        };
                    };
                    _local2++;
                };
                _local1++;
            };
            if ((((((tilesLoaded >= tilesToLoad)) && (!(firstFullViewDrawn)))) && ((backgroundTilesLoaded >= backgroundTilesToLoad)))){
                firstFullViewDrawn = true;
                dispatchEvent(new Event("viewerFirstFullViewDrawInternal"));
                if (eventsEnabled){
                    dispatchEvent(new Event("viewerFirstFullViewDraw"));
                };
            };
        }
        public function tileUnloaded(_arg1:TileEvent):void{
            var _local2:String;
            if (_arg1.bmp != null){
                for (_local2 in currentTilesArray) {
                    if (currentTilesArray[_local2] == _arg1.bmp){
                        currentTilesArray[_local2] = null;
                    };
                };
                if (canvasSprite.contains(_arg1.bmp)){
                    canvasSprite.removeChild(_arg1.bmp);
                };
            };
        }
        public function constrainPan():void{
            var _local1:Number;
            var _local2:Number;
            if (panConstrain){
                _local1 = (((widthScale * (1 << tier)) * tileSize) * canvas.scaleX);
                _local2 = (((heightScale * (1 << tier)) * tileSize) * canvas.scaleY);
                if (_local1 > visWidth){
                    if ((canvas.x - ((tileSize * tileX) * canvas.scaleX)) > 0){
                        canvas.x = ((tileSize * tileX) * canvas.scaleX);
                        if (eventsEnabled){
                            dispatchEvent(new Event("viewerConstrainingPan"));
                        };
                    };
                    if (((canvas.x - ((tileSize * tileX) * canvas.scaleX)) + _local1) < visWidth){
                        canvas.x = ((visWidth + ((tileSize * tileX) * canvas.scaleX)) - _local1);
                        if (eventsEnabled){
                            dispatchEvent(new Event("viewerConstrainingPan"));
                        };
                    };
                } else {
                    canvas.x = (((visWidth / 2) - (_local1 / 2)) + ((tileSize * tileX) * canvas.scaleX));
                };
                if (_local2 > visHeight){
                    if ((canvas.y - ((tileSize * tileY) * canvas.scaleY)) > 0){
                        canvas.y = ((tileSize * tileY) * canvas.scaleY);
                        if (eventsEnabled){
                            dispatchEvent(new Event("viewerConstrainingPan"));
                        };
                    };
                    if (((canvas.y - ((tileSize * tileY) * canvas.scaleY)) + _local2) < visHeight){
                        canvas.y = ((visHeight + ((tileSize * tileY) * canvas.scaleY)) - _local2);
                        if (eventsEnabled){
                            dispatchEvent(new Event("viewerConstrainingPan"));
                        };
                    };
                } else {
                    canvas.y = (((visHeight / 2) - (_local2 / 2)) + ((tileSize * tileY) * canvas.scaleY));
                };
                canvas.x = Math.round(canvas.x);
                canvas.y = Math.round(canvas.y);
            };
        }
        public function getOffset():Point{
            return (new Point((((tileSize * tileX) * canvas.scaleX) + -(canvas.x)), (((tileSize * tileY) * canvas.scaleY) + -(canvas.y))));
        }
        public function getImageOffset():Point{
            return (new Point((canvas.x - ((tileSize * tileX) * canvas.scaleX)), (canvas.y - ((tileSize * tileY) * canvas.scaleY))));
        }
        public function get xImageSpan():Number{
            return ((((2 * x) / fullWidth) - 1));
        }
        private function fadeInTimerHandler(_arg1:TimerEvent):void{
            var _local3:int;
            var _local4:int;
            var _local5:DisplayObject;
            var _local2:int;
            while (_local2 < numTilesY) {
                _local3 = 0;
                while (_local3 < numTilesX) {
                    _local4 = ((_local2 * numTilesX) + _local3);
                    _local5 = currentTilesArray[_local4];
                    if ((((_local5 == null)) || ((_local5.alpha == 1)))){
                    } else {
                        _local5.alpha = (_local5.alpha + (50 / fadeInSpeed));
                        if (_local5.alpha >= 1){
                            _local5.alpha = 1;
                        };
                    };
                    _local3++;
                };
                _local2++;
            };
        }
        public function getCurrentTier():int{
            return (tier);
        }
        public function offsetCanvas(_arg1:Number, _arg2:Number):int{
            var _local3:Number = canvas.x;
            var _local4:Number = canvas.y;
            canvas.x = (canvas.x + _arg1);
            canvas.y = (canvas.y + _arg2);
            constrainPan();
            var _local5:int;
            if (Math.abs(((canvas.x - _local3) - _arg1)) >= 1){
                _local5 = (_local5 | 1);
            };
            if (Math.abs(((canvas.y - _local4) - _arg2)) >= 1){
                _local5 = (_local5 | 2);
            };
            return (_local5);
        }
        public function getFadeInSpeed():Number{
            return (fadeInSpeed);
        }
        public function configureCanvas(_arg1:uint, _arg2:Number, _arg3:Number, _arg4:uint, _arg5:uint, _arg6:int, _arg7:Number, _arg8:Array, _arg9:Array):void{
            var _local12:uint;
            var _local13:uint;
            var _local15:uint;
            var _local16:uint;
            var _local17:Number;
            var _local18:Number;
            visWidth = _arg2;
            visHeight = _arg3;
            tileSize = _arg1;
            tier = _arg6;
            fullWidth = _arg4;
            fullHeight = _arg5;
            var _local10:Number = (Math.max(fullWidth, fullHeight) / Number(tileSize));
            var _local11:uint;
            while ((1 << _local11) < _local10) {
                widthScale = (fullWidth / ((1 << _local11) * tileSize));
                heightScale = (fullHeight / ((1 << _local11) * tileSize));
                if (_local10 > (1 << _local11)){
                    widthScale = (fullWidth / ((1 << (_local11 + 1)) * tileSize));
                };
                if (_local10 > (1 << _local11)){
                    heightScale = (fullHeight / ((1 << (_local11 + 1)) * tileSize));
                };
                _local11++;
            };
            imageW = (widthScale * fullWidth);
            imageH = (heightScale * fullHeight);
            var _local14:uint = (1 << _arg6);
            _local12 = 0;
            while (_local12 < _local14) {
                if ((_local12 * tileSize) > ((_local14 * tileSize) * widthScale)){
                    break;
                };
                maxTileX = _local12;
                _local12++;
            };
            _local13 = 0;
            while (_local13 < _local14) {
                if ((_local13 * tileSize) > ((_local14 * tileSize) * heightScale)){
                    break;
                };
                maxTileY = _local13;
                _local13++;
            };
            tileX = 0;
            tileY = 0;
            numTilesX = ((Math.ceil((visWidth / tileSize)) / _arg7) + 1);
            numTilesY = ((Math.ceil((visHeight / tileSize)) / _arg7) + 1);
            if (backgroundTier == -1){
                background.graphics.clear();
                backgroundTier = Math.round((_local11 / 3));
                if (backgroundTier > 2){
                    backgroundTier = 2;
                };
                _local15 = _arg8[backgroundTier];
                _local16 = _arg9[backgroundTier];
                _local17 = 0;
                while (_local17 <= (_local16 - 1)) {
                    _local18 = 0;
                    while (_local18 <= (_local15 - 1)) {
                        backgroundTilesToLoad = (backgroundTilesToLoad + 1);
                        tileCache.loadTile(backgroundTier, _local17, _local18);
                        _local18++;
                    };
                    _local17++;
                };
                background.scaleY = (background.scaleX = ((1 << tier) / Number((1 << backgroundTier))));
            };
        }
        public function getPanConstrain():Boolean{
            return (panConstrain);
        }
        public function positionCanvas():void{
            var _local1:int;
            if (canvas.x > 0){
                _local1 = Math.ceil((canvas.x / (tileSize * canvas.scaleX)));
                tileX = (tileX - _local1);
                canvas.x = (canvas.x - ((_local1 * tileSize) * canvas.scaleX));
            } else {
                if ((canvas.x + (getCanvasWidth() * canvas.scaleX)) < visWidth){
                    _local1 = Math.ceil(((visWidth - (canvas.x + (getCanvasWidth() * canvas.scaleX))) / (tileSize * canvas.scaleX)));
                    tileX = (tileX + _local1);
                    canvas.x = (canvas.x + ((_local1 * tileSize) * canvas.scaleX));
                };
            };
            if (canvas.y > 0){
                _local1 = Math.ceil((canvas.y / (tileSize * canvas.scaleY)));
                tileY = (tileY - _local1);
                canvas.y = (canvas.y - ((_local1 * tileSize) * canvas.scaleY));
            } else {
                if ((canvas.y + (getCanvasHeight() * canvas.scaleY)) < visHeight){
                    _local1 = Math.ceil(((visHeight - (canvas.y + (getCanvasHeight() * canvas.scaleY))) / (tileSize * canvas.scaleY)));
                    tileY = (tileY + _local1);
                    canvas.y = (canvas.y + ((_local1 * tileSize) * canvas.scaleY));
                };
            };
        }
        public function selectTiles(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:uint, _arg6:Number, _arg7:Number, _arg8:Number, _arg9:uint, _arg10:uint):void{
            var _local28:Number;
            if (eventsEnabled){
                dispatchEvent(new Event("viewLoadingStart"));
            };
            var _local11:Boolean;
            var _local12:Number = -((_arg1 / 2));
            var _local13:Number = (_arg1 / 2);
            var _local14:Number = -((_arg2 / 2));
            var _local15:Number = (_arg2 / 2);
            var _local16:Number = (tileSize * _arg6);
            var _local17:Number = (((_arg7 * _arg6) / 2) - ((_arg7 * _arg6) * (-(_arg3) / 2)));
            var _local18:Number = (((_arg8 * _arg6) / 2) - ((_arg8 * _arg6) * (-(_arg4) / 2)));
            var _local19:Number = (_local17 + _local12);
            var _local20:Number = (_local17 + _local13);
            var _local21:Number = (_local18 + _local14);
            var _local22:Number = (_local18 + _local15);
            var _local23:Number = Math.floor((_local19 / _local16));
            var _local24:Number = Math.floor((_local20 / _local16));
            var _local25:Number = Math.floor((_local21 / _local16));
            var _local26:Number = Math.floor((_local22 / _local16));
            if ((((_local23 < 0)) || ((_arg5 == backgroundTier)))){
                _local23 = 0;
            };
            if ((((_local24 > (_arg9 - 1))) || ((_arg5 == backgroundTier)))){
                _local24 = (_arg9 - 1);
            };
            if ((((_local25 < 0)) || ((_arg5 == backgroundTier)))){
                _local25 = 0;
            };
            if ((((_local26 > (_arg10 - 1))) || ((_arg5 == backgroundTier)))){
                _local26 = (_arg10 - 1);
            };
            if (!firstFullViewDrawn){
                tilesToLoad = (((_local24 - _local23) + 1) * ((_local26 - _local25) + 1));
            };
            var _local27:Number = _local25;
            while (_local27 <= _local26) {
                _local28 = _local23;
                while (_local28 <= _local24) {
                    if (eventsEnabled){
                        dispatchEvent(new Event("viewLoadingProgress"));
                    };
                    if (tileCache.loadTile(tier, _local27, _local28)){
                        _local11 = true;
                    };
                    _local28++;
                };
                _local27++;
            };
            if (eventsEnabled){
                dispatchEvent(new Event("viewLoadingComplete"));
            };
            if (_local11){
                tileCache.purge();
            };
        }
        public function setPanConstrain(_arg1:Boolean):void{
            panConstrain = _arg1;
        }
        public function set x(_arg1:Number):void{
            var _local2:Number;
            var _local3:Number;
            if (canvas){
                _local2 = (1 << (maxTier - tier));
                _local3 = ((visWidth * _local2) / canvas.scaleX);
                _arg1 = (_arg1 - (_local3 / 2));
                canvas.x = (((_arg1 / _local2) - (tileX * tileSize)) * -(canvas.scaleX));
            };
        }

    }
}//package zoomify.viewer 
