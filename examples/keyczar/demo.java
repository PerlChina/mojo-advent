import org.keyczar.*;

public class demo {
    public static void main(String[] args) throws Exception {
        KeyczarFileReader reader = new KeyczarFileReader("./crypt-rsa-pub");
        try {
            Encrypter crypter = new Encrypter(reader);
            System.out.print(crypter.encrypt("hello") + "\n");

        } catch (org.keyczar.exceptions.KeyczarException e) {
            System.out.print(e);
        }
    }
}