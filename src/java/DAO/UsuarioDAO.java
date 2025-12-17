package DAO;

import DTO.UsuarioDTO;
import UTIL.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import org.mindrot.jbcrypt.BCrypt;

public class UsuarioDAO {

    Connection con;
    PreparedStatement ps;
    ResultSet rs;

    public UsuarioDAO() {
        con = Conexion.conectar();
    }

    // ============================================================
    // LOGIN CON BCRYPT
    // ============================================================
    public UsuarioDTO login(String usuario, String clave) {
        UsuarioDTO u = null;

        String sql = "SELECT u.idUsuario, u.idPersona, u.usuario, u.contrasena, u.rol, u.estado, "
                + "p.nombres, p.apellidos, p.documento AS dni, p.telefono, p.correo, p.direccion "
                + "FROM usuarios u "
                + "INNER JOIN persona p ON u.idPersona = p.idPersona "
                + "WHERE u.usuario = ? AND u.estado = 1";

        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, usuario);
            rs = ps.executeQuery();

            if (rs.next()) {
                String hash = rs.getString("contrasena");

                if (BCrypt.checkpw(clave, hash)) {
                    u = new UsuarioDTO();
                    u.setIdUsuario(rs.getInt("idUsuario"));
                    u.setIdPersona(rs.getInt("idPersona"));
                    u.setUsuario(rs.getString("usuario"));
                    u.setRol(rs.getString("rol"));
                    u.setEstado(rs.getInt("estado"));

                    u.setNombres(rs.getString("nombres"));
                    u.setApellidos(rs.getString("apellidos"));
                    u.setDni(rs.getString("dni"));
                    u.setTelefono(rs.getString("telefono"));
                    u.setCorreo(rs.getString("correo"));
                    u.setDireccion(rs.getString("direccion"));
                }
            }

        } catch (Exception e) {
            System.out.println("ERROR login(): " + e.getMessage());
        }

        return u;
    }

    // ============================================================
    // LISTAR TODOS LOS USUARIOS (JOIN PERSONA)
    // ============================================================
    public List<UsuarioDTO> listar() {
        List<UsuarioDTO> lista = new ArrayList<>();

        String sql = "SELECT u.idUsuario, u.idPersona, u.usuario, u.rol, u.estado, "
                + "p.nombres, p.apellidos, p.documento AS dni, p.telefono, p.correo, p.direccion "
                + "FROM usuarios u "
                + "INNER JOIN persona p ON u.idPersona = p.idPersona "
                + "ORDER BY u.idUsuario DESC";

        try {
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                UsuarioDTO u = new UsuarioDTO();

                u.setIdUsuario(rs.getInt("idUsuario"));
                u.setIdPersona(rs.getInt("idPersona"));
                u.setUsuario(rs.getString("usuario"));
                u.setRol(rs.getString("rol"));
                u.setEstado(rs.getInt("estado"));

                u.setNombres(rs.getString("nombres"));
                u.setApellidos(rs.getString("apellidos"));
                u.setDni(rs.getString("dni"));
                u.setTelefono(rs.getString("telefono"));
                u.setCorreo(rs.getString("correo"));
                u.setDireccion(rs.getString("direccion"));

                lista.add(u);
            }

        } catch (Exception e) {
            System.out.println("ERROR listar(): " + e.getMessage());
        }

        return lista;
    }

    // ============================================================
    // REGISTRAR PERSONA + USUARIO (CON HASH BCRYPT)
    // ============================================================
    public boolean registrar(UsuarioDTO u) {
        try {
            // 1. Registrar persona
            String sqlPersona = "INSERT INTO persona(idTipoPersona, nombres, apellidos, documento, telefono, correo, direccion, estado, fechaRegistro) "
                    + "VALUES (1, ?, ?, ?, ?, ?, ?, 1, NOW())";

            ps = con.prepareStatement(sqlPersona, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, u.getNombres());
            ps.setString(2, u.getApellidos());
            ps.setString(3, u.getDni());
            ps.setString(4, u.getTelefono());
            ps.setString(5, u.getCorreo());
            ps.setString(6, u.getDireccion());
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            int idPersona = 0;
            if (rs.next()) {
                idPersona = rs.getInt(1);
            }

            // 2. Registrar usuario
            String hash = BCrypt.hashpw(u.getContrasena(), BCrypt.gensalt());

            String sqlUsuario = "INSERT INTO usuarios(idPersona, usuario, contrasena, rol, estado, fechaRegistro) "
                    + "VALUES (?, ?, ?, ?, ?, NOW())";

            ps = con.prepareStatement(sqlUsuario);
            ps.setInt(1, idPersona);
            ps.setString(2, u.getUsuario());
            ps.setString(3, hash);
            ps.setString(4, u.getRol());
            ps.setInt(5, u.getEstado());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("ERROR registrar(): " + e.getMessage());
            return false;
        }
    }

    // ============================================================
    // OBTENER USUARIO POR ID
    // ============================================================
    public UsuarioDTO obtenerPorId(int idUsuario) {
        UsuarioDTO u = null;

        String sql = "SELECT u.idUsuario, u.idPersona, u.usuario, u.rol, u.estado, "
                + "p.nombres, p.apellidos, p.documento AS dni, p.telefono, p.correo, p.direccion "
                + "FROM usuarios u "
                + "INNER JOIN persona p ON u.idPersona = p.idPersona "
                + "WHERE u.idUsuario = ?";

        try {
            ps = con.prepareStatement(sql);
            ps.setInt(1, idUsuario);
            rs = ps.executeQuery();

            if (rs.next()) {
                u = new UsuarioDTO();
                u.setIdUsuario(rs.getInt("idUsuario"));
                u.setIdPersona(rs.getInt("idPersona"));
                u.setUsuario(rs.getString("usuario"));
                u.setRol(rs.getString("rol"));
                u.setEstado(rs.getInt("estado"));

                u.setNombres(rs.getString("nombres"));
                u.setApellidos(rs.getString("apellidos"));
                u.setDni(rs.getString("dni"));
                u.setTelefono(rs.getString("telefono"));
                u.setCorreo(rs.getString("correo"));
                u.setDireccion(rs.getString("direccion"));
            }

        } catch (Exception e) {
            System.out.println("ERROR obtenerPorId(): " + e.getMessage());
        }

        return u;
    }

    // ============================================================
    // ACTUALIZAR PERSONA + USUARIO (CON O SIN CAMBIO DE CLAVE)
    // ============================================================
    public boolean actualizar(UsuarioDTO u) {
        try {
            // 1. Actualizar persona
            String sqlPersona = "UPDATE persona SET nombres=?, apellidos=?, documento=?, "
                    + "telefono=?, correo=?, direccion=? WHERE idPersona=?";

            ps = con.prepareStatement(sqlPersona);
            ps.setString(1, u.getNombres());
            ps.setString(2, u.getApellidos());
            ps.setString(3, u.getDni());
            ps.setString(4, u.getTelefono());
            ps.setString(5, u.getCorreo());
            ps.setString(6, u.getDireccion());
            ps.setInt(7, u.getIdPersona());
            ps.executeUpdate();

            // 2. Actualizar usuario (con o sin contraseña)
            if (u.getContrasena() == null || u.getContrasena().trim().isEmpty()) {

                String sqlUser = "UPDATE usuarios SET usuario=?, rol=?, estado=? WHERE idUsuario=?";

                ps = con.prepareStatement(sqlUser);
                ps.setString(1, u.getUsuario());
                ps.setString(2, u.getRol());
                ps.setInt(3, u.getEstado());
                ps.setInt(4, u.getIdUsuario());

            } else {
                String hash = BCrypt.hashpw(u.getContrasena(), BCrypt.gensalt());

                String sqlUser = "UPDATE usuarios SET usuario=?, contrasena=?, rol=?, estado=? WHERE idUsuario=?";

                ps = con.prepareStatement(sqlUser);
                ps.setString(1, u.getUsuario());
                ps.setString(2, hash);
                ps.setString(3, u.getRol());
                ps.setInt(4, u.getEstado());
                ps.setInt(5, u.getIdUsuario());
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("ERROR actualizar(): " + e.getMessage());
            return false;
        }
    }

    // ============================================================
    // ELIMINAR USUARIO COMPLETO (usuario + persona)
    // ============================================================
    public boolean eliminar(int idUsuario, int idPersona) {
        try {
            // 1. borrar usuario
            String sqlUser = "DELETE FROM usuarios WHERE idUsuario=?";
            ps = con.prepareStatement(sqlUser);
            ps.setInt(1, idUsuario);
            ps.executeUpdate();

            // 2. borrar persona
            String sqlPersona = "DELETE FROM persona WHERE idPersona=?";
            ps = con.prepareStatement(sqlPersona);
            ps.setInt(1, idPersona);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("ERROR eliminar(): " + e.getMessage());
            return false;
        }
    }
}
