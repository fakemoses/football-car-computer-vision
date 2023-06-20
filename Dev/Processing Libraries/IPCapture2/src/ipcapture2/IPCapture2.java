
package ipcapture2;

import java.net.*;
import java.io.*;
import processing.core.*;
import ipcapture2.IPAuthenticator;

public class IPCapture2 extends PImage implements Runnable {
	private String urlString;
	private byte[] curFrame;
	private boolean frameStarted;
	private boolean frameAvailable;
	private Thread streamReader;
	private HttpURLConnection conn;
	private BufferedInputStream httpIn;
	private ByteArrayOutputStream jpgOut;
	private volatile boolean keepAlive;
	private Mode mode;

	public final static String VERSION = "0.4.2";

	public IPCapture2(PApplet parent) {
		this(parent, "", "", "");
	}

	public IPCapture2(PApplet parent, String urlString, String user, String pass) {
		super(parent.width, parent.height, RGB);
		this.parent = parent;
		parent.registerMethod("dispose", this);
		this.urlString = urlString;
		Authenticator.setDefault(new IPAuthenticator(user, pass));
		this.curFrame = new byte[0];
		this.frameStarted = false;
		this.frameAvailable = false;
		this.keepAlive = false;
		this.mode = Mode.JAVA;
	}

	public boolean isAlive() {
		return streamReader.isAlive();
	}

	public boolean isAvailable() {
		return frameAvailable;
	}

	public void reconnect() {
		throw new UnsupportedOperationException("Method not implemented yet.");
	}

	public void start() {
		if (streamReader != null && streamReader.isAlive()) {
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
		try {
			streamReader.join();
		} catch (InterruptedException e) {
			System.err.println(e.getMessage());
		}
	}

	public void dispose() {
		stop();
	}

	public void run() {
		URL url;
		Base64Encoder base64 = new Base64Encoder();

		try {
			url = new URL(urlString);
		} catch (MalformedURLException e) {
			System.err.println("Invalid URL");
			return;
		}

		try {
			conn = (HttpURLConnection) url.openConnection();
			// conn.setRequestProperty("Authorization", "Basic " + base64.encode(user + ":"
			// + pass));
		} catch (IOException e) {
			System.err.println("Unable to connect: " + e.getMessage());
			return;
		}
		try {
			httpIn = new BufferedInputStream(conn.getInputStream(), 8192);
			jpgOut = new ByteArrayOutputStream(8192);
		} catch (IOException e) {
			System.err.println("Unable to open I/O streams: " + e.getMessage());
			return;
		}

		int prev = 0;
		int cur = 0;

		try {
			while (keepAlive && (cur = httpIn.read()) >= 0) {
				if (prev == 0xFF && cur == 0xD8) {
					frameStarted = true;
					jpgOut.close();
					jpgOut = new ByteArrayOutputStream(8192);
					jpgOut.write((byte) prev);
				}
				if (frameStarted) {
					jpgOut.write((byte) cur);
					if (prev == 0xFF && cur == 0xD9) {
						curFrame = jpgOut.toByteArray();
						frameStarted = false;
						frameAvailable = true;
					}
				}
				prev = cur;
			}
		} catch (IOException e) {
			System.err.println("I/O Error: " + e.getMessage());
		}
		try {
			jpgOut.close();
			httpIn.close();
		} catch (IOException e) {
			System.err.println("Error closing I/O streams: " + e.getMessage());
		}
		conn.disconnect();
	}

	public void read() {
		ByteArrayInputStream jpgIn = new ByteArrayInputStream(curFrame);
		FrameBuffer buffer;
		if (mode == Mode.ANDROID)
			buffer = new AndroidFrameBuffer(jpgIn);
		else
			buffer = new JavaFrameBuffer(jpgIn);
		buffer.toPImage(this);
		frameAvailable = false;
		try {
			jpgIn.close();
		} catch (IOException e) {
			System.out.println("Error closing the MJPEG input stream: " + e.getMessage());
		}
	}

	public void setMode(Mode mode) {
		this.mode = mode;
	}
}
