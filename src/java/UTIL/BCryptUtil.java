package UTIL;

import org.mindrot.jbcrypt.BCrypt;

public class BCryptUtil {

    // Encriptar contraseña
    public static String hash(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }

    // Verificar contraseña
    public static boolean verify(String password, String hashedPassword) {
        return BCrypt.checkpw(password, hashedPassword);
    }
}
