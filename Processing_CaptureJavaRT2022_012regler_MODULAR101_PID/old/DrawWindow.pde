public class DrawWindow {
    
    
    public void draw() {
        int[][] BILD;
        if (!yellow) {
            //RGB only
            
            bildverarbeitung.extractColorRGB(cam);
            BILD = bildverarbeitung.getRed();
        } else{
            //HSV
            //Apply HSV Masking then compute the int [][] BILD value
            
            yellowCV = new ColorHSV(camWidth, camHeight, HsvColorRange.YELLOW.getRange());
            out1 = maskYellow.getMask(cam, true);
            // bildverarbeitung.extractColorHSV(out1);
            // BILD = bildverarbeitung.getYellow();
            BILD = bildverarbeitung.getRed();
            
        }
        
        image(cam, 0, 0);
        float dx = (width / 2.0f) / (float)BILD[0].length;
        float dy = (height / 2.0f) / (float)BILD.length;
        noStroke();
        fill(200);
        rect(width / 2, 0, width / 2, height / 2);
        fill(0);
        for (int i = 0; i < BILD.length; i++)
        {
            for (int k = 0; k < BILD[i].length; k++)
            {
                if (BILD[i][k] ==  0)
                {
                    rect(width / 2 + (float)k * dx, 0 + (float)i * dy, dx, dy);
                }
            }
        }
        
        boolean erfolg = regler.erzeugeStellsignalAusRotbild(BILD);
        
        if (erfolg)
        {
            float spx = regler.holeSchwerpunkt();
            stroke(255, 0, 0);
            strokeWeight(3.0);
            line(width / 2 + (float)spx, 0, width / 2 + (float)spx, height / 2);
        }
        
        fill(255);
        rect(0, height / 2, width, height / 2);
        fill(0);
        textSize(30);
        text(NACHRICHT, 20, height - height / 3);
        text(udpcomfort.getTemperatur(), 20, height - height / 6);
        
        fill(255, 0, 0);
        text((int)regler.getProzent() + "%" + " e=" + regler.getRegeldifferenz(), 20, height - height / 2);
    }
}
