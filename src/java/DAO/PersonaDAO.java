package DAO;

import DTO.PersonaDTO;
import UTIL.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PersonaDAO {

    /* ============================================================
          REGISTRAR CLIENTE  (idTipoPersona = 2)
       ============================================================ */
    public boolean registrar(PersonaDTO p) {
        String sql = "INSERT INTO persona (idTipoPersona, nombres, apellidos, documento, telefono, correo, direccion, estado) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, 2); // CLIENTE
            ps.setString(2, p.getNombres());
            ps.setString(3, p.getApellidos());
            ps.setString(4, p.getDocumento());
            ps.setString(5, p.getTelefono());
            ps.setString(6, p.getCorreo());
            ps.setString(7, p.getDireccion());
            ps.setInt(8, p.getEstado());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error registrar cliente: " + e.getMessage());
            return false;
        }
    }

    /* ============================================================
          REGISTRAR PROVEEDOR (idTipoPersona = 3)
       ============================================================ */
    public boolean registrarProveedor(PersonaDTO p) {

        String sql = "INSERT INTO persona (idTipoPersona, razonSocial, ruc, telefono, correo, direccion, estado) "
                + "VALUES (3, ?, ?, ?, ?, ?, ?)";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, p.getRazonSocial());
            ps.setString(2, p.getRuc());
            ps.setString(3, p.getTelefono());
            ps.setString(4, p.getCorreo());
            ps.setString(5, p.getDireccion());
            ps.setInt(6, p.getEstado());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error registrarProveedor: " + e.getMessage());
            return false;
        }
    }

    /* ============================================================
          LISTAR CLIENTES (idTipoPersona = 2)
       ============================================================ */
    public List<PersonaDTO> listarClientes(String texto) {
        List<PersonaDTO> lista = new ArrayList<>();

        String sql = "SELECT * FROM persona WHERE idTipoPersona = 2 "
                + "AND (nombres LIKE ? OR documento LIKE ?) ORDER BY idPersona DESC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, "%" + texto + "%");
            ps.setString(2, "%" + texto + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                PersonaDTO p = new PersonaDTO();
                p.setIdPersona(rs.getInt("idPersona"));
                p.setIdTipoPersona(2);
                p.setNombres(rs.getString("nombres"));
                p.setApellidos(rs.getString("apellidos"));
                p.setDocumento(rs.getString("documento"));
                p.setTelefono(rs.getString("telefono"));
                p.setCorreo(rs.getString("correo"));
                p.setDireccion(rs.getString("direccion"));
                p.setEstado(rs.getInt("estado"));
                lista.add(p);
            }

        } catch (Exception e) {
            System.out.println("Error listarClientes: " + e.getMessage());
        }

        return lista;
    }

    /* ============================================================
          LISTAR PROVEEDORES (idTipoPersona = 3)
       ============================================================ */
    public List<PersonaDTO> listarProveedores(String texto) {
        List<PersonaDTO> lista = new ArrayList<>();

        String sql = "SELECT * FROM persona WHERE idTipoPersona = 3 "
                + "AND (razonSocial LIKE ? OR ruc LIKE ?) ORDER BY idPersona DESC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, "%" + texto + "%");
            ps.setString(2, "%" + texto + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                PersonaDTO p = new PersonaDTO();
                p.setIdPersona(rs.getInt("idPersona"));
                p.setIdTipoPersona(3);
                p.setRazonSocial(rs.getString("razonSocial"));
                p.setRuc(rs.getString("ruc"));
                p.setTelefono(rs.getString("telefono"));
                p.setCorreo(rs.getString("correo"));
                p.setDireccion(rs.getString("direccion"));
                p.setEstado(rs.getInt("estado"));
                lista.add(p);
            }

        } catch (Exception e) {
            System.out.println("Error listarProveedores: " + e.getMessage());
        }

        return lista;
    }

    /* ============================================================
          LISTAR POR TIPO (1,2,3)
       ============================================================ */
    public List<PersonaDTO> listarPorTipo(int tipo) {
        List<PersonaDTO> lista = new ArrayList<>();

        String sql = "SELECT * FROM persona WHERE idTipoPersona = ? ORDER BY idPersona DESC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, tipo);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                PersonaDTO p = new PersonaDTO();
                p.setIdPersona(rs.getInt("idPersona"));
                p.setIdTipoPersona(tipo);

                if (tipo == 3) { // proveedor
                    p.setRazonSocial(rs.getString("razonSocial"));
                    p.setRuc(rs.getString("ruc"));
                } else { // cliente o trabajador
                    p.setNombres(rs.getString("nombres"));
                    p.setApellidos(rs.getString("apellidos"));
                    p.setDocumento(rs.getString("documento"));
                }

                p.setTelefono(rs.getString("telefono"));
                p.setCorreo(rs.getString("correo"));
                p.setDireccion(rs.getString("direccion"));
                p.setEstado(rs.getInt("estado"));

                lista.add(p);
            }

        } catch (Exception e) {
            System.out.println("Error listarPorTipo: " + e.getMessage());
        }

        return lista;
    }

    /* ============================================================
          EDITAR CLIENTE
       ============================================================ */
    public boolean editar(PersonaDTO p) {

        String sql = "UPDATE persona SET nombres=?, apellidos=?, documento=?, telefono=?, correo=?, direccion=?, estado=? "
                + "WHERE idPersona=?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, p.getNombres());
            ps.setString(2, p.getApellidos());
            ps.setString(3, p.getDocumento());
            ps.setString(4, p.getTelefono());
            ps.setString(5, p.getCorreo());
            ps.setString(6, p.getDireccion());
            ps.setInt(7, p.getEstado());
            ps.setInt(8, p.getIdPersona());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error editar cliente: " + e.getMessage());
            return false;
        }
    }

    /* ============================================================
          EDITAR PROVEEDOR
       ============================================================ */
    public boolean editarProveedor(PersonaDTO p) {

        String sql = "UPDATE persona SET razonSocial=?, ruc=?, telefono=?, correo=?, direccion=?, estado=? "
                + "WHERE idPersona=?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, p.getRazonSocial());
            ps.setString(2, p.getRuc());
            ps.setString(3, p.getTelefono());
            ps.setString(4, p.getCorreo());
            ps.setString(5, p.getDireccion());
            ps.setInt(6, p.getEstado());
            ps.setInt(7, p.getIdPersona());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error editar proveedor: " + e.getMessage());
            return false;
        }
    }

    /* ============================================================
          ELIMINAR
       ============================================================ */
    public boolean eliminar(int id) {

        String sql = "DELETE FROM persona WHERE idPersona=?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error eliminar persona: " + e.getMessage());
            return false;
        }
    }

    /* ============================================================
          VALIDACIONES DE UNICIDAD
       ============================================================ */
    public boolean existeCorreo(String correo, Integer excluirId) {
        String sql = "SELECT COUNT(*) FROM persona WHERE correo = ?";
        if (excluirId != null) {
            sql += " AND idPersona <> ?";
        }

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, correo);
            if (excluirId != null) {
                ps.setInt(2, excluirId);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            System.out.println("Error existeCorreo: " + e.getMessage());
        }
        return false;
    }

    public boolean existeDocumento(String documento, Integer excluirId) {
        String sql = "SELECT COUNT(*) FROM persona WHERE documento = ?";
        if (excluirId != null) {
            sql += " AND idPersona <> ?";
        }

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, documento);
            if (excluirId != null) {
                ps.setInt(2, excluirId);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            System.out.println("Error existeDocumento: " + e.getMessage());
        }
        return false;
    }

    public boolean existeRuc(String ruc, Integer excluirId) {
        String sql = "SELECT COUNT(*) FROM persona WHERE ruc = ?";
        if (excluirId != null) {
            sql += " AND idPersona <> ?";
        }

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, ruc);
            if (excluirId != null) {
                ps.setInt(2, excluirId);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            System.out.println("Error existeRuc: " + e.getMessage());
        }
        return false;
    }

}
