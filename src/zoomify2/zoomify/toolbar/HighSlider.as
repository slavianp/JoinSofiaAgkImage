package zoomify.toolbar {
    import fl.controls.*;

    public class HighSlider extends Slider {

        override protected function configUI():void{
            super.configUI();
            track.setSize(80, 15);
        }

    }
}//package zoomify.toolbar 
