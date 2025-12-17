package DAO;

import DTO.ProductoDTO;
import UTIL.Conexion;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductoDAO {

    /* ============================================================
       LISTAR TODOS LOS PRODUCTOS
       ============================================================ */
    public List<ProductoDTO> listar() {
        List<ProductoDTO> lista = new ArrayList<>();

        String sql =
            "SELECT p.*, c.nombreCategoria " +
            "FROM productos p " +
            "INNER JOIN categorias c ON p.idCategoria = c.idCategoria " +
            "ORDER BY p.idProducto DESC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearProducto(rs));
            }

        } catch (Exception e) {
            System.out.println("Error listar productos: " + e.getMessage());
        }
        return lista;
    }

    /* ============================================================
       LISTAR POR CATEGORÍA
       ============================================================ */
    public List<ProductoDTO> listarPorCategoria(String categoria) {
        List<ProductoDTO> lista = new ArrayList<>();
        boolean filtrar = categoria != null && !categoria.equals("0");

        String sqlBase =
            "SELECT p.*, c.nombreCategoria " +
            "FROM productos p " +
            "INNER JOIN categorias c ON p.idCategoria = c.idCategoria ";

        String sql = filtrar
                ? sqlBase + "WHERE p.idCategoria = ? ORDER BY p.idProducto DESC"
                : sqlBase + "ORDER BY p.idProducto DESC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            if (filtrar) {
                ps.setInt(1, Integer.parseInt(categoria));
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearProducto(rs));
            }

        } catch (Exception e) {
            System.out.println("Error listarPorCategoria: " + e.getMessage());
        }

        return lista;
    }

    /* ============================================================
       REGISTRAR PRODUCTO
       ============================================================ */
    public boolean registrar(ProductoDTO p) {
        String sql =
            "INSERT INTO productos (idCategoria, nombreProducto, descripcion, precioVenta, stock, estado) " +
            "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, p.getIdCategoria());
            ps.setString(2, p.getNombreProducto());
            ps.setString(3, p.getDescripcion());
            ps.setDouble(4, p.getPrecioVenta());
            ps.setInt(5, p.getStock());
            ps.setInt(6, p.getEstado());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error registrar producto: " + e.getMessage());
            return false;
        }
    }

    /* ============================================================
       EDITAR PRODUCTO
       ============================================================ */
    public boolean editar(ProductoDTO p) {
        String sql =
            "UPDATE productos SET " +
            "idCategoria=?, nombreProducto=?, descripcion=?, precioVenta=?, stock=?, estado=? " +
            "WHERE idProducto=?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, p.getIdCategoria());
            ps.setString(2, p.getNombreProducto());
            ps.setString(3, p.getDescripcion());
            ps.setDouble(4, p.getPrecioVenta());
            ps.setInt(5, p.getStock());
            ps.setInt(6, p.getEstado());
            ps.setInt(7, p.getIdProducto());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error editar producto: " + e.getMessage());
            return false;
        }
    }

    /* ============================================================
       ELIMINAR PRODUCTO
       ============================================================ */
    public boolean eliminar(int idProducto) {
        String sql = "DELETE FROM productos WHERE idProducto=?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idProducto);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error eliminar producto: " + e.getMessage());
            return false;
        }
    }

    /* ============================================================
       OBTENER POR ID
       ============================================================ */
    public ProductoDTO obtenerPorId(int idProducto) {

        String sql =
            "SELECT p.*, c.nombreCategoria FROM productos p " +
            "INNER JOIN categorias c ON p.idCategoria = c.idCategoria " +
            "WHERE p.idProducto=?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, idProducto);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapearProducto(rs);
            }

        } catch (Exception e) {
            System.out.println("Error obtenerPorId: " + e.getMessage());
        }
        return null;
    }

    /* ============================================================
       LISTAR ACTIVOS
       ============================================================ */
    public List<ProductoDTO> listarActivos() {
        List<ProductoDTO> lista = new ArrayList<>();

        String sql =
            "SELECT p.*, c.nombreCategoria FROM productos p " +
            "INNER JOIN categorias c ON p.idCategoria = c.idCategoria " +
            "WHERE p.estado = 1 ORDER BY p.nombreProducto ASC";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearProducto(rs));
            }

        } catch (Exception e) {
            System.out.println("Error listarActivos: " + e.getMessage());
        }

        return lista;
    }

    /* ============================================================
       LISTAR FILTRADO
       ============================================================ */
    public List<ProductoDTO> listarActivosFiltrado(Integer idCategoria, String buscar) {

        List<ProductoDTO> lista = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT p.*, c.nombreCategoria " +
            "FROM productos p " +
            "INNER JOIN categorias c ON p.idCategoria = c.idCategoria " +
            "WHERE p.estado = 1 "
        );

        List<Object> params = new ArrayList<>();

        if (idCategoria != null && idCategoria > 0) {
            sql.append(" AND p.idCategoria = ? ");
            params.add(idCategoria);
        }

        if (buscar != null && !buscar.trim().isEmpty()) {
            sql.append(" AND p.nombreProducto LIKE ? ");
            params.add("%" + buscar.trim() + "%");
        }

        sql.append(" ORDER BY p.nombreProducto ASC ");

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                Object val = params.get(i);

                if (val instanceof Integer)
                    ps.setInt(i + 1, (int) val);
                else
                    ps.setString(i + 1, val.toString());
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(mapearProducto(rs));
            }

        } catch (Exception e) {
            System.out.println("Error listarActivosFiltrado: " + e.getMessage());
        }

        return lista;
    }

    /* ============================================================
       AUMENTAR STOCK DESPUÉS DE COMPRA
       ============================================================ */
    public boolean aumentarStock(int idProducto, int cantidad) {

        String sql = "UPDATE productos SET stock = stock + ? WHERE idProducto = ?";

        try (Connection cn = Conexion.conectar();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, cantidad);
            ps.setInt(2, idProducto);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error aumentarStock: " + e.getMessage());
            return false;
        }
    }
    
    /* ============================================================
           REDUCIR STOCK (VENTAS)
           ============================================================ */
        public boolean reducirStock(int idProducto, int cantidad) {

            String sql = "UPDATE productos SET stock = stock - ? WHERE idProducto = ? AND stock >= ?";

            try (Connection cn = Conexion.conectar();
                 PreparedStatement ps = cn.prepareStatement(sql)) {

                ps.setInt(1, cantidad);
                ps.setInt(2, idProducto);
                ps.setInt(3, cantidad);

                return ps.executeUpdate() > 0;

            } catch (Exception e) {
                System.out.println("Error reducirStock: " + e.getMessage());
                return false;
            }
        }


    /* ============================================================
       MAPEAR PRODUCTO DTO
       ============================================================ */
    private ProductoDTO mapearProducto(ResultSet rs) throws Exception {
        ProductoDTO p = new ProductoDTO();

        p.setIdProducto(rs.getInt("idProducto"));
        p.setIdCategoria(rs.getInt("idCategoria"));
        p.setNombreProducto(rs.getString("nombreProducto"));
        p.setDescripcion(rs.getString("descripcion"));
        p.setPrecioVenta(rs.getDouble("precioVenta"));
        p.setStock(rs.getInt("stock"));
        p.setEstado(rs.getInt("estado"));

        try {
            p.setNombreCategoria(rs.getString("nombreCategoria"));
        } catch (Exception ignore) {}

        return p;
    }
}
