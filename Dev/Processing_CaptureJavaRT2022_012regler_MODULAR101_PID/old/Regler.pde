public class Regler
{
    private float spx = 0.0;
    private Antrieb antrieb;
    private float prozent = 0.0;  
    private float regeldifferenz = 0.0;
    
    private float[] e_array = new float[10];  // e_summe = e_array[0] + e_array[1] + ....
    private int index = 0;
    private float dt = 0.1f; //Anpassen an frameRate(10); in setup() !!
    private float e_alt = 0.0f;
    public Regler(Antrieb antrieb)
    {
        this.antrieb = antrieb;
    }
    
    // Same process as erzeugeStellsignalAusRotbild
    // but received spx calculated before as Parameter
    // does not do calculation here
    // only processes the spx value
    // instead of spx, pakai prozent ?
    public boolean setMotorSignal(int spx, int[][] BILD)
    {
        //Schwerpunkt berechnen und einzeichnen
        //und Prozent an roten Pixeln ermitteln
        float gewicht = 0.0;
        int aktiv = 0;
        for (int i = 0;i < BILD.length;i++)
        {
            for (int k = 0;k < BILD[i].length;k++)
            {
                float wert = (float)BILD[i][k];
                spx += wert * (float)k;
                gewicht += wert;
                if (wert > 0.0) aktiv++;
                
            }
        }
        if (gewicht > 0.0)
            spx /=  gewicht;
        prozent = 100.0 * (float)aktiv / (float)(BILD.length * BILD[0].length);   
        regeldifferenz = 0.0;
        if (prozent > 1.0 && prozent < 50.0)
        { 
            // +/- 1 0=>nicht genug rote Pixel
            // e<0 => links stärker vor
            // e>0 => rechts stärker vor
            regeldifferenz = ((float)(BILD[0].length / 2) - spx) / (float)(BILD[0].length / 2);
            if (AKTIV)
            {
                float u_links = 0.0;
                float u_rechts = 0.0;
                
                //Implementierung P-Regler, PI-Regler, PID-Regler
                float P = PROPORTIONALE_VERSTAERKUNG;
                float I = INTEGRALE_VERSTAERKUNG;
                float D = DIFFERENTIALE_VERSTAERKUNG;
                float e = regeldifferenz;
                float eD = (e - e_alt) / dt;
                float eI = 0.0f;
                
                for (int i = 0;i < e_array.length;i++)
                    eI += e_array[i];
                eI *=  dt;
                float Freg = P * e + I * eI + D * eD;
                
                e_alt = e;
                e_array[index] = e;
                index++;
                index %=  e_array.length;
                
                //float Freg = P*e + I*eI + D*eD;
                //ENDE
                if (regeldifferenz < 0.0)
                {
                    u_links  = VORTRIEB;
                    u_rechts = VORTRIEB - Freg;// + PROPORTIONALE_VERSTAERKUNG*(-regeldifferenz);
                }
                else if (regeldifferenz > 0.0)
                {
                    u_links  = VORTRIEB + Freg;// + PROPORTIONALE_VERSTAERKUNG*(regeldifferenz);
                    u_rechts = VORTRIEB;
                }
                
                u_links *=  ASYMMETRIE;
                u_rechts *= (2.0 - ASYMMETRIE);
                
                antrieb.fahrt(u_links,u_rechts);
            }
            return true; //Erfolg
        }
        else
        {
            antrieb.fahrt(0.0,0.0);
            return false; //kein Erfolg
        }
        
    }
    
    
    public boolean erzeugeStellsignalAusRotbild(int[][] BILD)
    {
        //Schwerpunkt berechnen und einzeichnen
        //und Prozent an roten Pixeln ermitteln
        float gewicht = 0.0;
        int aktiv = 0;
        for (int i = 0;i < BILD.length;i++)
        {
            for (int k = 0;k < BILD[i].length;k++)
            {
                float wert = (float)BILD[i][k];
                spx += wert * (float)k;
                gewicht += wert;
                if (wert > 0.0) aktiv++;
                
            }
        }
        if (gewicht > 0.0)
            spx /=  gewicht;
        prozent = 100.0 * (float)aktiv / (float)(BILD.length * BILD[0].length);   
        regeldifferenz = 0.0;
        if (prozent > 1.0 && prozent < 50.0)
        { 
            // +/- 1 0=>nicht genug rote Pixel
            // e<0 => links stärker vor
            // e>0 => rechts stärker vor
            regeldifferenz = ((float)(BILD[0].length / 2) - spx) / (float)(BILD[0].length / 2);
            if (AKTIV)
            {
                float u_links = 0.0;
                float u_rechts = 0.0;
                
                //Implementierung P-Regler, PI-Regler, PID-Regler
                float P = PROPORTIONALE_VERSTAERKUNG;
                float I = INTEGRALE_VERSTAERKUNG;
                float D = DIFFERENTIALE_VERSTAERKUNG;
                float e = regeldifferenz;
                float eD = (e - e_alt) / dt;
                float eI = 0.0f;
                
                for (int i = 0;i < e_array.length;i++)
                    eI += e_array[i];
                eI *=  dt;
                float Freg = P * e + I * eI + D * eD;
                
                e_alt = e;
                e_array[index] = e;
                index++;
                index %=  e_array.length;
                
                //float Freg = P*e + I*eI + D*eD;
                //ENDE
                if (regeldifferenz < 0.0)
                {
                    u_links  = VORTRIEB;
                    u_rechts = VORTRIEB - Freg;// + PROPORTIONALE_VERSTAERKUNG*(-regeldifferenz);
                }
                else if (regeldifferenz > 0.0)
                {
                    u_links  = VORTRIEB + Freg;// + PROPORTIONALE_VERSTAERKUNG*(regeldifferenz);
                    u_rechts = VORTRIEB;
                }
                
                u_links *=  ASYMMETRIE;
                u_rechts *= (2.0 - ASYMMETRIE);
                
                antrieb.fahrt(u_links,u_rechts);
            }
            return true; //Erfolg
        }
        else
        {
            antrieb.fahrt(0.0,0.0);
            return false; //kein Erfolg
        }
        
    }
    
    public float holeSchwerpunkt()
    {
        return spx;
    }
    
    public float getProzent()
    {
        return prozent;
    }
    public float getRegeldifferenz()
    {
        return regeldifferenz;
    }
}
