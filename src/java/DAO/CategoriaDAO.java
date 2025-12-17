package DAO;

import DTO.CategoriaDTO;
import UTIL.Conexion;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CategoriaDAO {

    /* ======================================================
                      LISTAR TODAS
       ====================================================== */
    public List<CategoriaDTO> listar() {
        List<CategoriaDTO> lista = new ArrayList<>();

        String sql = "SELECT * FROM Categorias ORDER BY nombreCategoria ASC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                CategoriaDTO c = new CategoriaDTO();
                c.setIdCategoria(rs.getInt("idCategoria"));
                c.setNombreCategoria(rs.getString("nombreCategoria"));
                c.setDescripcion(rs.getString("descripcion"));
                lista.add(c);
            }

        } catch (Exception e) {
            System.out.println("Error listar categorias: " + e.getMessage());
        }

        return lista;
    }


    /* ======================================================
                     LISTAR CON BUSQUEDA
       ====================================================== */
    public List<CategoriaDTO> listar(String buscar) {
        List<CategoriaDTO> lista = new ArrayList<>();

        String sql = "SELECT * FROM Categorias " +
                     "WHERE nombreCategoria LIKE ? " +
                     "ORDER BY nombreCategoria ASC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, "%" + buscar + "%");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                CategoriaDTO c = new CategoriaDTO();
                c.setIdCategoria(rs.getInt("idCategoria"));
                c.setNombreCategoria(rs.getString("nombreCategoria"));
                c.setDescripcion(rs.getString("descripcion"));
                lista.add(c);
            }

        } catch (Exception e) {
            System.out.println("Error listar categorias (buscar): " + e.getMessage());
        }

        return lista;
    }


    /* ======================================================
                        REGISTRAR
       ====================================================== */
    public boolean registrar(CategoriaDTO c) {
        String sql = "INSERT INTO Categorias (nombreCategoria, descripcion) VALUES (?, ?)";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, c.getNombreCategoria());
            ps.setString(2, c.getDescripcion());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error registrar categoria: " + e.getMessage());
            return false;
        }
    }


    /* ======================================================
                          EDITAR
       ====================================================== */
    public boolean editar(CategoriaDTO c) {
        String sql = "UPDATE Categorias SET nombreCategoria = ?, descripcion = ? WHERE idCategoria = ?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, c.getNombreCategoria());
            ps.setString(2, c.getDescripcion());
            ps.setInt(3, c.getIdCategoria());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error editar categoria: " + e.getMessage());
            return false;
        }
    }


    /* ======================================================
                          ELIMINAR
       ====================================================== */
    public boolean eliminar(int idCategoria) {
        String sql = "DELETE FROM Categorias WHERE idCategoria = ?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idCategoria);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error eliminar categoria: " + e.getMessage());
            return false;
        }
    }


    /* ======================================================
               VERIFICAR SI UNA CATEGORÍA TIENE PRODUCTOS
       ====================================================== */
    public boolean tieneProductos(int idCategoria) {
        String sql = "SELECT COUNT(*) AS total FROM Productos WHERE idCategoria = ?";
        int total = 0;

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idCategoria);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                total = rs.getInt("total");
            }

        } catch (Exception e) {
            System.out.println("Error tieneProductos: " + e.getMessage());
        }

        return total > 0; // true si tiene productos (NO se puede eliminar)
    }

}
