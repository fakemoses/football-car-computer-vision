// Custom Camera Implementation
// Added Reconect Functionality
// TODO: Add a way to check if the camera is down
// TODO: Add better reconnect functionality

// Fork: https://github.com/singintime/ipcapture

class CustomCam extends IPCaptureCustom {
    
    private int numUnavailable;
    private final int MAX_UNAVAILABLE = 20;
    
    CustomCam(PApplet parent, String urlString, String user, String pass) {
        super(parent, urlString, user, pass);
        this.numUnavailable = 0;
    }
    
    @Override
    public boolean isAvailable() {
        if (super.isAvailable()) {
            this.numUnavailable = 0;
            return true;
        }
        
        numUnavailable++;
        return false;
    }
    
    
    public boolean isDown() {
        return numUnavailable > MAX_UNAVAILABLE;
    }
    
    public void reconnect() {
        super.stop();
        super.start();
        numUnavailable = 0;
    }
}

public class IPCaptureCustom extends PImage implements Runnable {
    private String urlString;
    private byte[] curFrame;
    private boolean frameStarted;
    private boolean frameAvailable;
    private Thread streamReader;
    private HttpURLConnection conn;
    private BufferedInputStream httpIn;
    private ByteArrayOutputStream jpgOut;
    private volatile boolean keepAlive;
    
    public final static String VERSION = "0.4.2";
    
    public IPCaptureCustom(PApplet parent) {
        this(parent, "", "", "");
    }
    
    public IPCaptureCustom(PApplet parent, String urlString, String user, String pass) {
        super(parent.width, parent.height, RGB);
        this.parent = parent;
        parent.registerMethod("dispose", this);
        this.urlString = urlString;
        Authenticator.setDefault(new IPAuthenticator(user, pass));
        this.curFrame = new byte[0];
        this.frameStarted = false;
        this.frameAvailable = false;
        this.keepAlive = false;
    }
    
    public boolean isAlive() {
        return streamReader.isAlive();
    }
    
    public boolean isAvailable() {
        return frameAvailable;
    }
    
    public void start() {
        if (streamReader!= null && streamReader.isAlive()) {
            System.out.println("Camera already started");
            return;
        }
        streamReader = new Thread(this, "HTTP Stream reader");
        keepAlive = true;
        streamReader.start();
    }
    
    public void start(String urlString, String user, String pass) {
        this.urlString = urlString;
        Authenticator.setDefault(new IPAuthenticator(user, pass));
        this.start();
    }
    
    public void stop() {
        if (streamReader == null || !streamReader.isAlive()) {
            System.out.println("Camera already stopped");
            return;
        }
        keepAlive = false;
        streamReader = null;
    }
    
    public void dispose() {
        stop();
    }
    
    public void run() {
        URL url;
        Base64Encoder base64 = new Base64Encoder();
        
        try {
            url = new URL(urlString);
        }
        catch(MalformedURLException e) {
            System.err.println("Invalid URL");
            return;
        }
        
        try {
            conn = (HttpURLConnection)url.openConnection();
            //conn.setRequestProperty("Authorization", "Basic " + base64.encode(user + ":" + pass));
        }
        catch(IOException e) {
            System.err.println("Unable to connect: " + e.getMessage());
            return;
        }
        try {
            httpIn = new BufferedInputStream(conn.getInputStream(), 8192);
            jpgOut = new ByteArrayOutputStream(8192);
        }
        catch(IOException e) {
            System.err.println("Unable to open I/O streams: " + e.getMessage());
            return;
        }
        
        int prev = 0;
        int cur = 0;
        
        try {
            while(keepAlive && (cur = httpIn.read()) >= 0) {                
                if (prev == 0xFF && cur == 0xD8) {
                    frameStarted = true;
                    jpgOut.close();
                    jpgOut = new ByteArrayOutputStream(8192);
                    jpgOut.write((byte)prev);
                }
                if (frameStarted) {
                    jpgOut.write((byte)cur);
                    if (prev == 0xFF && cur == 0xD9) {
                        curFrame = jpgOut.toByteArray();
                        frameStarted = false;
                        frameAvailable = true;
                    }
                }
                prev = cur;
            }
        }
        catch(IOException e) {
            System.err.println("I/O Error: " + e.getMessage());
            println("Connection closed");
            
        }
        try {
            jpgOut.close();
            httpIn.close();
        }
        catch(IOException e) {
            System.err.println("Error closing I/O streams: " + e.getMessage());
            println("Connection closed");
            
        }
        println("Connection closed");
        conn.disconnect();
    }
    
    public void read() {
        ByteArrayInputStream jpgIn = new ByteArrayInputStream(curFrame);
        FrameBuffer buffer;
        buffer = new JavaFrameBuffer(jpgIn);
        buffer.toPImage(this);
        frameAvailable = false;
        try {
            jpgIn.close();
        }
        catch(IOException e) {
            System.out.println("Error closing the MJPEG input stream: " + e.getMessage());
        }
    }
}

public class IPAuthenticator extends Authenticator {
    String user, pass;
    
    public IPAuthenticator(String user, String pass) {
        super();
        this.user = user;
        this.pass = pass;
    }
    
    protected PasswordAuthentication getPasswordAuthentication() {
        return new PasswordAuthentication(this.user, this.pass.toCharArray());
    }
}

public class JavaFrameBuffer extends FrameBuffer {
    BufferedImage buffer;
    
    public JavaFrameBuffer(ByteArrayInputStream in) {
        try {
            this.buffer = ImageIO.read(in);
        }
        catch(Exception e) {
            buffer = null;
        }
    }
    
    public boolean isValid() {
        return buffer != null;
    }
    
    public int getWidth() {
        return buffer.getWidth();
    }
    
    public int getHeight() {
        return buffer.getHeight();
    }
    
    public void writePixels(int[] pixels, int w, int h) {
        buffer.getRGB(0, 0, w, h, pixels, 0, w);
    }
}


public abstract class FrameBuffer {
    public abstract boolean isValid();
    public abstract int getWidth();
    public abstract int getHeight();
    public abstract void writePixels(int[] pixels, int w, int h);
    
    public void toPImage(PImage img) {
        if (!isValid()) return;
        int w = getWidth();
        int h = getHeight();
        if (w <= 0 || h <= 0) return;
        if (w != img.width || h != img.height) {
            System.out.println("Frame resize: from " + img.width + "x" + img.height + " to " + w + "x" + h);
            img.init(w, h, PImage.RGB, 1); 
        }
        img.loadPixels();
        writePixels(img.pixels, w, h);
        img.updatePixels();
    }
}