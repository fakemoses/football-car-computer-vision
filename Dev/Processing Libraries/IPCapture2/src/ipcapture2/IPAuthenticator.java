package ipcapture2;

import java.net.Authenticator;
import java.net.PasswordAuthentication;

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