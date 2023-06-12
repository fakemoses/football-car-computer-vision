public class Antrieb
{
    private UDPcomfort udpcomfort;
    public Antrieb(UDPcomfort udpcomfort) {
        this.udpcomfort = udpcomfort;
    }
    
    /**
    [-1,1]
    
    --------- PWM Motor -------------
    
    LINKS GRÜN | LINKS ROT | VCC | GND | RECHTS GRÜN | RECHTS ROT |
    ROT L 15   | AUS1 12   |     |     | GRÜN R 14   | AUS2 2     |
    
    
    VOR LINKS: L=0 AUS1=1
    RCK LINKS: L=1 AUS1=0
    
    VOR RECTS: R=0 AUS2=1
    RCK RECTS: R=1 AUS2=0
    
    */
    
    public void fahrt(float links, float rechts) {
        
        if (TAUSCHE_ANTRIEB_LINKS_RECHTS) {
            float h = links;
            links = rechts;
            rechts = h;
        }
        
        links  *= ASYMMETRIE;
        rechts *= (2.0 - ASYMMETRIE);
        
        if (links > 1.0f)   links  =  1.0f;
        if (links <-  1.0f)  links  = -1.0f;
        if (rechts > 1.0f)  rechts =  1.0f;
        if (rechts <-  1.0f) rechts = -1.0f;
        
        if (links >=  0.0f)
            {
            udpcomfort.send(0,255 - (int)(links * 255.0f));
            udpcomfort.send(2,1);
        }
        else
            {
            udpcomfort.send(0,(int)( -links * 255.0f));
            udpcomfort.send(2,0);
        }
        
        if (rechts >=  0.0f)
            {
            udpcomfort.send(1,255 - (int)(rechts * 255.0f));
            udpcomfort.send(3,1);
        }
        else
            {
            udpcomfort.send(1,(int)( -rechts * 255.0f));
            udpcomfort.send(3,0);
        }   
    }
}
